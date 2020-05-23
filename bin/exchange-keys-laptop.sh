#!/bin/bash
set -ex

if [ -z $EC2_NODE_IP ]
then
  read -p "Please specify EC2_NODE_IP: " EC2_NODE_IP
fi

cat /etc/tinc/rpinet/hosts/laptop | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/laptop
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | sudo tee /etc/tinc/rpinet/hosts/ec2