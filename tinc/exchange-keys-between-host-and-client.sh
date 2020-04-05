#!/bin/bash

ssh pi@$NODE_IP sudo apt-get install -y tinc
ssh pi@$NODE_IP tincd -n rpinet -K4096
ssh pi@$NODE_IP cat /etc/tinc/rpinet/hosts/$NODE_NAME | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/$NODE_NAME
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | ssh pi@$NODE_IP sudo tee /etc/tinc/rpinet/hosts/ec2