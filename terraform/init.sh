#! /bin/bash

# Install certbot
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y universe
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot python-certbot-nginx
echo "dns_cloudflare_api_key = ${CLOUDFLARE_API_KEY}" >> ~/.secrets/certbot/cloudflare.ini
echo "dns_cloudflare_email = ${CLOUDFLARE_EMAIL}" >> ~/.secrets/certbot/cloudflare.ini
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini --non-interactive --agree-tos --domains $DOMAIN --email $EMAIL

# Install and configure tinc
sudo apt-get install -y tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
echo -e "Name = ec2\nAddressFamily = ipv4\nInterface = tun0" | sudo tee /etc/tinc/rpinet/tinc.conf
ec2_public_ip=$(curl -s ifconfig.me)
echo -e "Address = $ec2_public_ip\nSubnet = 10.0.0.1/32" | sudo tee /etc/tinc/rpinet/hosts/ec2
sudo tincd -n rpinet -K4096
echo -e '#!/bin/sh\nip link set $INTERFACE up\nip addr add 10.0.0.1/32 dev $INTERFACE\nip route add 10.0.0.0/24 dev $INTERFACE' | sudo tee /etc/tinc/rpinet/tinc-up
echo -e '#!/bin/sh\nip route del 10.0.0.0/24 dev $INTERFACE\nip addr del 10.0.0.1/32 dev $INTERFACE\nip link set $INTERFACE down' | sudo tee /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*
sudo tincd -n rpinet -D -d3