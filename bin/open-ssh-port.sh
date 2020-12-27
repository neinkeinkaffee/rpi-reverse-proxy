#!/usr/bin/env bash
set -ex

# Credits go to https://advancedweb.hu/2019/04/02/sg_allow_ip/

# Find the ID of the EC2 instance's security group
SG=$(aws ec2 describe-instances --region eu-central-1 --filter "Name=tag:Name,Values=proxy" \
--query "Reservations[].Instances[].SecurityGroups[].GroupId" \
--no-paginate | jq -r '.[0]')

# Find the public IP of this machine
while : ; do
	MYIP=$(curl -s ifconfig.me)
	[ -z "$MYIP" ] || break
done

# Find currently allowed IP ranges (variable interpolation in jq isn't working as documented)
CIDRS=$(aws ec2 describe-security-groups --region eu-central-1 --group-ids $SG \
    | jq -r '.SecurityGroups[].IpPermissions[]
    | select(.FromPort == 22 and .ToPort == 22) | .IpRanges[].CidrIp')

# Revoke access for currently allowed IP ranges
for ip in $CIDRS; do
	[ "$MYIP/32" != "$ip" ] && aws ec2 revoke-security-group-ingress \
	  --region eu-central-1 \
		--group-id $SG --protocol tcp --port 22 --cidr $ip >> /dev/null
done

# Allow access for IP of this machine
[ -z $(echo "$CIDRS" | grep "$MYIP/32") ] && aws ec2 authorize-security-group-ingress \
	  --region eu-central-1 \
    --group-id $SG --protocol tcp --port 22 --cidr "$MYIP/32" > /dev/null

# Add the EC2 host key to .ssh/known_hosts
ELASTIC_IP=$(aws ec2 describe-instances --region eu-central-1 --filter "Name=tag:Name,Values=proxy" --query "Reservations[].Instances[].PublicIpAddress" | jq -r '.[0]')
sed -i '.bkp' '/^'"$ELASTIC_IP"'/d' ~/.ssh/known_hosts
ssh-keyscan $ELASTIC_IP>> ~/.ssh/known_hosts
