#!/usr/bin/env bash
set -x

echo "Which of your Raspberry Pis do you want to connect to?"
echo "0 pi0"
echo "1 pi1"
echo "2 pi2"
read PI

EC2_PUBLIC_IP=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=proxy" \
--query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" \
--no-paginate | jq -r '.[0]')
ssh pi@${EC2_PUBLIC_IP} -p 1${PI}${PI}11