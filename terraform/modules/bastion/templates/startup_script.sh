#! /bin/bash
# Change SSH Port
echo "Port ${ssh_port}" >> /etc/ssh/sshd_config
service sshd restart

### HIST FILE FORMAT, UNLIMTED RENTION