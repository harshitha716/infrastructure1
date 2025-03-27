package backupfunction

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"net/http"
	"os"
	"regexp"
	"sync"
	"time"

	database "cloud.google.com/go/spanner/admin/database/apiv1"
)

var (
	projectName    = os.Getenv("PROJECTNAME")
	instanceName   = os.Getenv("INSTANCENAME")
	databaseName   = os.Getenv("DATABASENAME")
	webhookUrl     = os.Getenv("WEBHOOKURL")
	client         *database.DatabaseAdminClient
	clientOnce     sync.Once
	validDBPattern = regexp.MustCompile("^projects/(?P<project>[^/]+)/instances/(?P<instance>[^/]+)/databases/(?P<database>[^/]+)$")
)

func parseprojectName(db string) (project, instance, database string, err error) {
	matches := validDBPattern.FindStringSubmatch(db)
	if len(matches) == 0 {
		return "", "", "", fmt.Errorf(
			"Failed to parse database name from %q according to pattern %q", db, validDBPattern.String())
	}
	return matches[1], matches[2], matches[3], nil
}

type PubSubMessage struct {
	Data []byte `json:"data"`
}

type BackupParameters struct {
	BackupID string `json:"backupId"`
	Database string `json:"database"`
	Expire   string `json:"expire"`
}

func SpannerCreateBackup(ctx context.Context, m PubSubMessage) error {
	clientOnce.Do(func() {
		var err error
		client, err = database.NewDatabaseAdminClient(context.Background())
		if err != nil {
			log.Printf("Failed to create an instance of DatabaseAdminClient: %v", err)
			SendSlackNotification(err.Error(), false)
			return
		}
	})
	if client == nil {
		err := errors.New("Client should not be nil")
		SendSlackNotification(err.Error(), false)
		return fmt.Errorf("Client should not be nil")
	}

	var params BackupParameters
	err := json.Unmarshal(m.Data, &params)
	if err != nil {
		SendSlackNotification(err.Error(), false)
		return fmt.Errorf("Failed to parse data %s: %v", string(m.Data), err)
	}
	expire, err := time.ParseDuration(params.Expire)
	if err != nil {
		SendSlackNotification(err.Error(), false)
		return fmt.Errorf("Failed to parse expire duration %s: %v", params.Expire, err)
	}
	_, err = createBackup(ctx, params.BackupID, params.Database, expire)
	if err != nil {
		SendSlackNotification(err.Error(), false)
		fmt.Println(err)
		return err
	}

	SendSlackNotification("db backup has been triggered successfully :white_check_mark:", true)
	return nil
}

func createBackup(ctx context.Context, backupID, dbName string, expire time.Duration) (*database.CreateBackupOperation, error) {
	now := time.Now()
	if backupID == "" {
		_, _, dbID, err := parseprojectName(dbName)
		if err != nil {
			return nil, fmt.Errorf("Failed to start a backup operation for database [%s]: %v", dbName, err)
		}
		backupID = fmt.Sprintf("schedule-%s-%d", dbID, now.UTC().Unix())
	}
	expireTime := now.Add(expire)
	op, err := client.StartBackupOperation(ctx, backupID, dbName, expireTime)
	if err != nil {
		return nil, fmt.Errorf("Failed to start a backup operation for database [%s], expire time [%s], backupID = [%s] with error = %v", dbName, expireTime.Format(time.RFC3339), backupID, err)
	}
	log.Printf("Create backup operation [%s] started for database [%s], expire time [%s], backupID = [%s]", op.Name(), dbName, expireTime.Format(time.RFC3339), backupID)
	return op, nil
}

type AutoGenerated struct {
	Blocks      []Blocks      `json:"blocks"`
	Attachments []Attachments `json:"attachments"`
}
type Text struct {
	Type string `json:"type"`
	Text string `json:"text"`
}
type Fields struct {
	Type string `json:"type"`
	Text string `json:"text"`
}
type Blocks struct {
	Type   string   `json:"type"`
	Text   *Text    `json:"text,omitempty"`
	Fields []Fields `json:"fields,omitempty"`
}
type AttachmentBlocks struct {
	Type string `json:"type"`
	Text Text   `json:"text"`
}
type Attachments struct {
	Color  string             `json:"color"`
	Blocks []AttachmentBlocks `json:"blocks"`
}

func SendSlackNotification(reason string, success bool) error {
	var color string
	var header string
	if success {
		color = "#00FF00"
		header = "DB backup trigger success :white_check_mark:"
	} else {
		color = "#E01E5A"
		header = "DB back up failed :x:"
	}
	currentTime := time.Now()
	a := currentTime.Format(time.RFC1123)
	blockAuto := AutoGenerated{
		Blocks: []Blocks{
			{
				Type: "header",
				Text: &Text{
					Type: "plain_text",
					Text: header,
				},
			},
			{
				Type: "section",
				Fields: []Fields{
					{
						Type: "mrkdwn",
						Text: "*Time:*\n " + a,
					},
					{
						Type: "mrkdwn",
						Text: "*Project :*\n" + projectName,
					},
					{
						Type: "mrkdwn",
						Text: "*DB name* \n " + databaseName,
					},
					{
						Type: "mrkdwn",
						Text: "*InstanceName* \n" + instanceName,
					},
				},
			},
		},
		Attachments: []Attachments{
			{
				Color: color,
				Blocks: []AttachmentBlocks{
					{
						Type: "section",
						Text: Text{
							Type: "mrkdwn",
							Text: reason,
						},
					},
				},
			},
		},
	}
	slackBody, _ := json.Marshal(blockAuto)
	req, err := http.NewRequest(http.MethodPost, webhookUrl, bytes.NewBuffer(slackBody))
	if err != nil {
		return err
	}

	req.Header.Add("Content-Type", "application/json")

	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}

	buf := new(bytes.Buffer)
	buf.ReadFrom(resp.Body)
	fmt.Printf("%s \n", buf)
	if buf.String() != "ok" {
		return errors.New("Non-ok response returned from Slack")
	}
	return nil
}
