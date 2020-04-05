#!/usr/bin/env bash
set -x

# Credits go to https://advancedweb.hu/2019/04/02/sg_allow_ip/

# Find the ID of the EC2 instance's security group
SG=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=proxy" \
--query "Reservations[].Instances[].SecurityGroups[].GroupId" \
--no-paginate | jq -r '.[0]')

# Find the public IP of this machine
while : ; do
	MYIP=$(curl -s ifconfig.me)
	[ -z "$MYIP" ] || break
done

# Find currently allowed IP ranges (variable interpolation in jq isn't working as documented)
CIDRS=$(aws ec2 describe-security-groups --group-ids $SG \
    | jq -r '.SecurityGroups[].IpPermissions[]
    | select(.FromPort == 22 and .ToPort == 22) | .IpRanges[].CidrIp')

# Revoke access for currently allowed IP ranges
for ip in $CIDRS; do
	[ "$MYIP/32" != "$ip" ] && aws ec2 revoke-security-group-ingress \
		--group-id $SG --protocol tcp --port 22 --cidr $ip
	[ "$MYIP/32" != "$ip" ] && aws ec2 revoke-security-group-ingress \
		--group-id $SG --protocol tcp --port 443 --cidr $ip
done

# Allow access for IP of this machine
[ -z $(echo "$CIDRS" | grep "$MYIP/32") ] && aws ec2 authorize-security-group-ingress \
    --group-id $SG --protocol tcp --port 22 --cidr "$MYIP/32"
[ -z $(echo "$CIDRS" | grep "$MYIP/32") ] && aws ec2 authorize-security-group-ingress \
    --group-id $SG --protocol tcp --port 443 --cidr "$MYIP/32"
