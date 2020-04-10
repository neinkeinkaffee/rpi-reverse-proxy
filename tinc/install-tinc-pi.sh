#!/bin/bash
set -ex

sudo apt-get install -y tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
printf "Name = $NODE_NAME\nAddressFamily = ipv4\nInterface = tun0\nConnectTo = ec2" | sudo tee /etc/tinc/rpinet/tinc.conf
printf "Subnet = 10.0.0.$NODE_LAST_OCTET/32" | sudo tee /etc/tinc/rpinet/hosts/$NODE_NAME
printf '#!/bin/sh\nifconfig $INTERFACE '"10.0.0.$NODE_LAST_OCTET netmask 255.255.255.0" | sudo tee /etc/tinc/rpinet/tinc-up
printf '#!/bin/sh\nifconfig $INTERFACE down' | sudo tee /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*
tincd -n rpinet -K4096
echo rpinet | sudo tee /etc/tinc/nets.boot