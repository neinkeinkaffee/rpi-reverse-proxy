#!/bin/bash
set -ex

cat /etc/tinc/rpinet/hosts/$LAPTOP_NODE_NAME | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/$LAPTOP_NODE_NAME
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | sudo tee /etc/tinc/rpinet/hosts/ec2