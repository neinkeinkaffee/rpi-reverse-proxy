#!/bin/bash
set -x

EC2_PUBLIC_IP=$(~/.local/bin/aws ec2 describe-instances --filter "Name=tag:Name,Values=proxy" \
--query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" \
--no-paginate | jq -r '.[0]')
autossh -fNC -R 10011:localhost:22 ec2-user@$EC2_PUBLIC_IP