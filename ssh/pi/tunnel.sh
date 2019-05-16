#!/bin/bash
set -x

EC2_PUBLIC_IP=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=proxy" \
--query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" \
--no-paginate | jq -r '.[0]')
autossh -fNC -R 10011:localhost:22 8000:127.0.0.1:8000 ec2-user@$EC2_PUBLIC_IP