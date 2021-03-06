#!/bin/bash
set -ex

# Prompt for node name and last octet in VPN IP if not provided
if [ -z $PI_NODE_NAME ]
then
  read -p "Please specify hostname of Raspberry Pi (will be used as VPN node name): " PI_NODE_NAME
fi

if [ -z $EC2_NODE_IP ]
then
  read -p "Please specify EC2_NODE_IP: " EC2_NODE_IP
fi

ssh pi@$PI_NODE_NAME cat /etc/tinc/rpinet/hosts/$PI_NODE_NAME | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/$PI_NODE_NAME
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | ssh pi@$PI_NODE_NAME sudo tee /etc/tinc/rpinet/hosts/ec2
