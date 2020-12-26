#!/bin/bash

# Install certbot
sudo apt update > /dev/null && sudo apt install -y python3-pip
pip3 install --upgrade certbot-dns-cloudflare
sudo mkdir -p /home/ubuntu/.secrets/certbot
echo "dns_cloudflare_api_token = ${CLOUDFLARE_API_TOKEN}" >> /home/ubuntu/.secrets/certbot/cloudflare.ini
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /home/ubuntu/.secrets/certbot/cloudflare.ini --non-interactive --agree-tos -d *.${DOMAIN} -m ${EMAIL}

# Run nginx in docker with docker-compose
sudo apt install -y docker-compose
sudo chown ubuntu:docker /var/run/docker.sock
wget -P /home/ubuntu https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/nginx/docker-compose.yml
wget -P /home/ubuntu https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/nginx/nginx.conf.template
DOMAIN=${DOMAIN} AGENT0=${AGENT0} AGENT1=${AGENT1} AGENT2=${AGENT2} docker-compose up -d

# Install and configure tinc
sudo apt install -y tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
echo -e "Name = ec2\nAddressFamily = ipv4\nInterface = tun0" | sudo tee /etc/tinc/rpinet/tinc.conf
ec2_public_ip=$(curl -s ifconfig.me)
echo -e "Address = $ec2_public_ip\nSubnet = 10.0.2.1/32" | sudo tee /etc/tinc/rpinet/hosts/ec2
sudo tincd -n rpinet -K4096
echo -e '#!/bin/sh\nip link set $INTERFACE up\nip addr add 10.0.2.1/32 dev $INTERFACE\nip route add 10.0.2.0/24 dev $INTERFACE' | sudo tee /etc/tinc/rpinet/tinc-up
echo -e '#!/bin/sh\nip route del 10.0.2.0/24 dev $INTERFACE\nip addr del 10.0.2.1/32 dev $INTERFACE\nip link set $INTERFACE down' | sudo tee /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*
sudo tincd -n rpinet -D --debug=3 --logfile=/var/log/tinc.rpinet.log
sudo systemctl enable tinc@rpinet
sudo systemctl start tinc@rpinet
