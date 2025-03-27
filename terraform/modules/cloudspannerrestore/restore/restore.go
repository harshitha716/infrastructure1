package restore

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	database "cloud.google.com/go/spanner/admin/database/apiv1"
	adminpb "google.golang.org/genproto/googleapis/spanner/admin/database/v1"
)

func Httptrigger(w http.ResponseWriter, r *http.Request) {
	var request struct {
		NewInstanceId    string `json:"newInstanceId"`
		NewDatabaseID    string `json:"newDatabaseID"`
		BackupID         string `json:"backupID"`
		BackupInstanceId string `json:"backupInstanceId"`
		ProjectId        string `json:"projectId"`
	}

	if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
		log.Printf("Failed to Parse json: %v", err)
		fmt.Fprintln(w, err)
		return
	}

	if request.NewInstanceId == "" {
		request.NewInstanceId = request.BackupInstanceId
	}

	ctx := context.Background()
	err := restore(ctx, request.ProjectId, request.BackupID, request.BackupInstanceId, request.NewInstanceId, request.NewDatabaseID)

	if err != nil {
		log.Printf("Failed restore operation: %v", err)
		fmt.Fprintln(w, err)
		return
	} else {
		fmt.Fprintln(w, "restore started")
	}
	return
}

func restore(ctx context.Context, ProjectId string, BackupID string, BackupInstanceId string, NewInstanceId string, NewDatabaseID string) (err error) {
	adminClient, err := database.NewDatabaseAdminClient(ctx)
	defer adminClient.Close()
	if err != nil {
		log.Printf("Failed to create an instance of DatabaseAdminClient: %v", err)
		fmt.Println(err.Error())
		return err
	}
	instanceName := "projects/" + ProjectId + "/instances/" + NewInstanceId
	databaseID := NewDatabaseID
	backupName := "projects/" + ProjectId + "/instances/" + BackupInstanceId + "/backups/" + BackupID
	_, err = adminClient.RestoreDatabase(ctx, &adminpb.RestoreDatabaseRequest{
		Parent:     instanceName,
		DatabaseId: databaseID,
		Source: &adminpb.RestoreDatabaseRequest_Backup{
			Backup: backupName,
		},
	})
	if err != nil {
		log.Printf("Failed to do restore operation: %v", err)
		fmt.Println(err.Error())
		return err
	}
	return nil
}
