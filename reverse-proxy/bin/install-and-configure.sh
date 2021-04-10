#!/bin/bash
set -ex

sudo apt-get update > /dev/null && sudo apt-get install -y tinc
sudo mkdir -p /etc/tinc/rpinet/hosts
printf "Name = $PI_NODE_NAME\nAddressFamily = ipv4\nInterface = tun0\nConnectTo = ec2" | sudo tee /etc/tinc/rpinet/tinc.conf
printf "Subnet = 10.0.2.$PI_LAST_OCTET/32" | sudo tee /etc/tinc/rpinet/hosts/$PI_NODE_NAME
printf "#!/bin/sh\n" | sudo tee /etc/tinc/rpinet/tinc-up
printf "ip link set "'$'"INTERFACE up\n" | sudo tee -a /etc/tinc/rpinet/tinc-up
printf "ip addr add 10.0.2.$PI_LAST_OCTET/32 dev "'$'"INTERFACE\n" | sudo tee -a /etc/tinc/rpinet/tinc-up
printf "ip route add 10.0.2.0/24 dev "'$'"INTERFACE\n" | sudo tee -a /etc/tinc/rpinet/tinc-up
printf "#!/bin/sh\n" | sudo tee /etc/tinc/rpinet/tinc-down
printf "ip route del 10.0.2.0/24 dev "'$'"INTERFACE\n" | sudo tee -a /etc/tinc/rpinet/tinc-down
printf "ip addr del 10.0.2.$PI_LAST_OCTET/32 dev "'$'"INTERFACE\n" | sudo tee -a /etc/tinc/rpinet/tinc-down
printf "ip link set "'$'"INTERFACE down\n" | sudo tee -a /etc/tinc/rpinet/tinc-down
sudo chmod 755 /etc/tinc/rpinet/tinc-*
sudo tincd -n rpinet -K4096
sudo systemctl enable tinc@rpinet
sudo systemctl start tinc@rpinet
