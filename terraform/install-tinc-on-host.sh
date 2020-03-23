#! /bin/bash

# Smoke test
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
echo "<h1>Hello from the rpinet remote host</h1>" | sudo tee /var/www/html/index.html

# Install and configure tinc
sudo apt-get install -y tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
echo -e "Name = ec2\nAddressFamily = ipv4\nInterface = tun0" | sudo tee /etc/tinc/rpinet/tinc.conf
ec2_public_ip=$(curl -s ifconfig.me)
echo -e "Address = $ec2_public_ip\nSubnet = 10.0.0.1/32" | sudo tee /etc/tinc/rpinet/hosts/ec2
sudo tincd -n rpinet -K4096
echo -e '#!/bin/sh\nifconfig $INTERFACE 10.0.0.1 netmask 255.255.255.0' | sudo tee /etc/tinc/rpinet/tinc-up
echo -e '#!/bin/sh\nifconfig $INTERFACE down' | sudo tee /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*