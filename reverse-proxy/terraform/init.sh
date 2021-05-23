#!/bin/bash

# Install packages
sudo apt-get update > /dev/null
sudo apt-get install -y docker-compose python3-pip tinc

# Run certbot
sudo apt-get remove -y python3-cryptography
sudo apt-get autoremove -y
sudo pip3 install --upgrade certbot-dns-cloudflare
sudo mkdir -p /home/ubuntu/.secrets/certbot
echo "dns_cloudflare_api_token = ${CLOUDFLARE_API_TOKEN}" >> /home/ubuntu/.secrets/certbot/cloudflare.ini
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /home/ubuntu/.secrets/certbot/cloudflare.ini --non-interactive --agree-tos -d *.${DOMAIN} -m ${EMAIL}

# Run nginx
sudo chown ubuntu:docker /var/run/docker.sock
wget -P /home/ubuntu https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/reverse-proxy/nginx/docker-compose.yml
wget -P /home/ubuntu https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/reverse-proxy/nginx/nginx.conf.template
while (! docker stats --no-stream ); do
  echo "Waiting for Docker to launch..."
  sleep 1
done
DOMAIN=${DOMAIN} AGENT0=${AGENT0} AGENT1=${AGENT1} AGENT2=${AGENT2} docker-compose -f /home/ubuntu/docker-compose.yml up -d &> /home/ubuntu/docker-compose.log

# Run tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
echo -e "Name = ec2\nAddressFamily = ipv4\nInterface = tun0" | sudo tee /etc/tinc/rpinet/tinc.conf
ec2_private_key=$(echo ${EC2_PRIVATE_KEY} | base64 -d)
echo -e "$ec2_private_key" | sudo tee /etc/tinc/rpinet/rsa_key.priv
sudo chmod 600 /etc/tinc/rpinet/rsa_key.priv
ec2_public_ip=$(curl -s ifconfig.me)
ec2_public_key=$(echo ${EC2_PUBLIC_KEY} | base64 -d)
echo -e "Address = $ec2_public_ip\nSubnet = 10.0.2.1/32\n$ec2_public_key" | sudo tee /etc/tinc/rpinet/hosts/ec2
echo -e '#!/bin/sh\nip link set $INTERFACE up\nip addr add 10.0.2.1/32 dev $INTERFACE\nip route add 10.0.2.0/24 dev $INTERFACE' | sudo tee /etc/tinc/rpinet/tinc-up
echo -e '#!/bin/sh\nip route del 10.0.2.0/24 dev $INTERFACE\nip addr del 10.0.2.1/32 dev $INTERFACE\nip link set $INTERFACE down' | sudo tee /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*
agent0_public_key=$(echo ${AGENT0_PUBLIC_KEY} | base64 -d)
echo -e "Address = ${AGENT0}\nSubnet = 10.0.2.10/32\n$agent0_public_key" | sudo tee /etc/tinc/rpinet/hosts/pi0
agent1_public_key=$(echo ${AGENT1_PUBLIC_KEY} | base64 -d)
echo -e "Address = ${AGENT1}\nSubnet = 10.0.2.11/32\n$agent1_public_key" | sudo tee /etc/tinc/rpinet/hosts/pi1
agent2_public_key=$(echo ${AGENT2_PUBLIC_KEY} | base64 -d)
echo -e "Address = ${AGENT2}\nSubnet = 10.0.2.12/32\n$agent2_public_key" | sudo tee /etc/tinc/rpinet/hosts/pi2
#sudo tincd -n rpinet --debug=3
sudo systemctl enable tinc@rpinet
sudo systemctl start tinc@rpinet

# Store kubeconfig
echo $PIKUBECONFIG | base64 -d > /home/ubuntu/.kube/config
