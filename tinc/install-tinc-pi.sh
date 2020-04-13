#!/bin/bash
set -ex

if [ -z $PI_NODE_NAME ]
then
  read -p "Please specify PI_NODE_NAME: " PI_NODE_NAME
fi

if [ -z $PI_LAST_OCTET ]
then
  read -p "Please specify PI_LAST_OCTET: " PI_LAST_OCTET
fi

sudo apt-get install -y awscli jq tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
printf "Name = $PI_NODE_NAME\nAddressFamily = ipv4\nInterface = tun0\nConnectTo = ec2" | sudo tee /etc/tinc/rpinet/tinc.conf
printf "Subnet = 10.0.0.$PI_LAST_OCTET/32" | sudo tee /etc/tinc/rpinet/hosts/$PI_NODE_NAME
printf '#!/bin/sh\nifconfig $INTERFACE '"10.0.0.$PI_LAST_OCTET netmask 255.255.255.0" | sudo tee /etc/tinc/rpinet/tinc-up
printf '#!/bin/sh\nifconfig $INTERFACE down' | sudo tee /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*
tincd -n rpinet -K4096
sudo systemctl enable tinc@rpinet
sudo systemctl start tinc@rpinet
(crontab -l 2>/dev/null; echo "@reboot $(which systemctl) start tinc@rpinet") | crontab -
cat << 'EOF' > open-vpn-port.sh
#!/usr/bin/env bash
set -ex

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
    | select(.FromPort == 655 and .ToPort == 655 and .IpProtocol == "tcp") | .IpRanges[].CidrIp')

# Revoke access for currently allowed IP ranges
for ip in $CIDRS; do
	[ "$MYIP/32" != "$ip" ] && aws ec2 revoke-security-group-ingress \
		--group-id $SG --protocol tcp --port 655 --cidr $ip
	[ "$MYIP/32" != "$ip" ] && aws ec2 revoke-security-group-ingress \
		--group-id $SG --protocol udp --port 655 --cidr $ip
done

# Allow access for IP of this machine
[ -z $(echo "$CIDRS" | grep "$MYIP/32") ] && aws ec2 authorize-security-group-ingress \
    --group-id $SG --protocol tcp --port 655 --cidr "$MYIP/32"
[ -z $(echo "$CIDRS" | grep "$MYIP/32") ] && aws ec2 authorize-security-group-ingress \
    --group-id $SG --protocol udp --port 655 --cidr "$MYIP/32"
EOF
chmod +x open-vpn-port.sh
(crontab -l 2>/dev/null; echo "0 4-7 * * * $(which sh) open-vpn-port.sh") | crontab -
(crontab -l 2>/dev/null; echo "@reboot $(which sh) open-vpn-port.sh") | crontab -