#!/usr/bin/env bash
autossh -fNC -R 10011:localhost:22 -i ~/.ssh/${PI_PRIVATE_SSH_KEY} ec2-user@${EC2_PUBLIC_IP}