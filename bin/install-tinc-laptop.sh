#!/bin/bash
set -ex

if [ -z $LAPTOP_NODE_NAME ]
then
  read -p "Please specify VPN node name for laptop: " LAPTOP_NODE_NAME
fi

if [ -z $LAPTOP_LAST_OCTET ]
then
  read -p "Please specify LAPTOP_LAST_OCTET: " LAPTOP_LAST_OCTET
fi

if [ -z $EC2_NODE_IP ]
then
  read -p "Please specify EC2_NODE_IP: " EC2_NODE_IP
fi

brew install tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
printf "Name = $LAPTOP_NODE_NAME\nAddressFamily = ipv4\nInterface = tun0\nConnectTo = ec2" | sudo tee /etc/tinc/rpinet/tinc.conf
printf "Subnet = 10.0.0.$LAPTOP_LAST_OCTET/32" | sudo tee /etc/tinc/rpinet/hosts/$LAPTOP_NODE_NAME
printf '#!/bin/sh\nifconfig tun0 inet '"10.0.0.$LAPTOP_LAST_OCTET 10.0.0.1 netmask 255.255.255.0" | sudo tee /etc/tinc/rpinet/tinc-up
printf '#!/bin/sh\nifconfig $INTERFACE down' | sudo tee /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*
sudo tincd -c /etc/tinc/rpinet --pidfile=/var/run/tincd.pid -n rpinet -K4096
echo rpinet | sudo tee /etc/tinc/nets.boot
cat /etc/tinc/rpinet/hosts/$LAPTOP_NODE_NAME | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/$LAPTOP_NODE_NAME
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | sudo tee /etc/tinc/rpinet/hosts/ec2
# sudo tincd -c /etc/tinc/rpinet --pidfile=/var/run/tincd.pid -n rpinet --debug=5