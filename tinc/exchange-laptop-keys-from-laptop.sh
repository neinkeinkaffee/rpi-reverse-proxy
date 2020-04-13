#!/bin/bash
set -ex

if [ -z $LAPTOP_NODE_NAME ]
then
  read -p "Please specify LAPTOP_NODE_NAME: " LAPTOP_NODE_NAME
fi

if [ -z $EC2_NODE_IP ]
then
  read -p "Please specify EC2_NODE_IP: " EC2_NODE_IP
fi

cat /etc/tinc/rpinet/hosts/$LAPTOP_NODE_NAME | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/$LAPTOP_NODE_NAME
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | sudo tee /etc/tinc/rpinet/hosts/ec2