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
    | select(.FromPort == 2222 and .ToPort == 2222) | .IpRanges[].CidrIp')

# Revoke access for currently allowed IP ranges
for ip in $CIDRS; do
	[ "$MYIP/32" != "$ip" ] && aws ec2 revoke-security-group-ingress \
		--group-id $SG --protocol tcp --port 2222 --cidr $ip
done

# Allow access for IP of this machine
[ -z $(echo "$CIDRS" | grep "$MYIP/32") ] && aws ec2 authorize-security-group-ingress \
    --group-id $SG --protocol tcp --port 2222 --cidr "$MYIP/32"

echo "Which of your Raspberry Pis do you want to connect to?"
echo "0 pi0"
echo "1 pi1"
echo "2 pi2"
read PI

EC2_PUBLIC_IP=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=proxy" \
--query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" \
--no-paginate | jq -r '.[0]')
ssh -t -i ~/.ssh/aws-free-tier ec2-user@${EC2_PUBLIC_IP} ssh -p 1${PI}${PI}11 pi@localhost
