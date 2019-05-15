#!/usr/bin/env bash
set -x

# Credits go to https://advancedweb.hu/2019/04/02/sg_allow_ip/

if [[ $1 = "pi" ]]
then
    PORT=22
else
    PORT=2222
fi

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
if [[ $1 = "pi" ]]
then
    CIDRS=$(aws ec2 describe-security-groups --group-ids $SG \
        | jq -r '.SecurityGroups[].IpPermissions[]
        | select(.FromPort == 22 and .ToPort == 22) | .IpRanges[].CidrIp')
else
    CIDRS=$(aws ec2 describe-security-groups --group-ids $SG \
        | jq -r '.SecurityGroups[].IpPermissions[]
        | select(.FromPort == 2222 and .ToPort == 2222) | .IpRanges[].CidrIp')
fi

# Revoke access for currently allowed IP ranges
for ip in $CIDRS; do
	[ "$MYIP/32" != "$ip" ] && aws ec2 revoke-security-group-ingress \
		--group-id $SG --protocol tcp --port $PORT --cidr $ip
done

# Allow access for IP of this machine
[ -z $(echo "$CIDRS" | grep "$MYIP/32") ] && aws ec2 authorize-security-group-ingress \
    --group-id $SG --protocol tcp --port $PORT --cidr "$MYIP/32"

if [[ $1 != "pi" ]]
then
    EC2_PUBLIC_IP=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=proxy" \
--query "Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp" \
--no-paginate | jq -r '.[0]')
    ssh -t -i ~/.ssh/aws-free-tier ec2-user@$EC2_PUBLIC_IP ssh -p 10011 pi@localhost
fi