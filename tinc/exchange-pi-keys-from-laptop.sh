#!/bin/bash
set -ex

ssh pi@$PI_NODE_NAME cat /etc/tinc/rpinet/hosts/$PI_NODE_NAME | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/$PI_NODE_NAME
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | ssh pi@$PI_NODE_NAME sudo tee /etc/tinc/rpinet/hosts/ec2