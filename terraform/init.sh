#! /bin/bash

# Install certbot
sudo apt-get update
sudo apt-get install -y python3-pip
pip3 install --upgrade certbot-dns-cloudflare
sudo mkdir -p /home/ubuntu/.secrets/certbot
echo "dns_cloudflare_api_token = ${CLOUDFLARE_API_TOKEN}" >> /home/ubuntu/.secrets/certbot/cloudflare.ini
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /home/ubuntu/.secrets/certbot/cloudflare.ini --non-interactive --agree-tos -d ${DOMAIN} -m ${EMAIL}

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
sudo tincd -n rpinet -D --debug=5
(crontab -l 2>/dev/null; echo "@reboot $(which tincd) -n rpinet -D --debug=5") | crontab -

# Run nginx in docker with docker-compose
sudo apt-get install -y docker-compose
sudo chown $USER:docker /var/run/docker.sock
wget https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/nginx/docker-compose.yml
wget https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/nginx/nginx.conf.template
DOMAIN=${DOMAIN} docker-compose up -d