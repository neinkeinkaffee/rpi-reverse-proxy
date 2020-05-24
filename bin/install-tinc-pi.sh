#!/bin/bash

set -ex

# Prompt for node name and last octet in VPN IP if not provided
if [ -z $HOST_NAME ]
then
  read -p "Please specify hostname of Raspberry Pi (will be used as VPN node name): " HOST_NAME
fi

if [ -z $LAST_OCTET ]
then
  read -p "Please specify what should be used as last octet in the Raspberry Pi's VPN IP: " LAST_OCTET
fi

if [ -z $EC2_NODE_IP ]
then
  read -p "Please specify EC2_NODE_IP: " EC2_NODE_IP
fi

# Install tinc on Raspberry Pi
set +e
export PI_NODE_NAME=$HOST_NAME PI_LAST_OCTET=$LAST_OCTET
ENV_VARS='$PI_NODE_NAME:$PI_LAST_OCTET'
envsubst "$ENV_VARS" < $(pwd)/bin/install-tinc.sh | ssh pi@$HOST_NAME sh -
set -e

# Exchange keys between Raspberry Pi and the VPN server running on EC2
ssh pi@$PI_NODE_NAME cat /etc/tinc/rpinet/hosts/$PI_NODE_NAME | ssh ubuntu@$EC2_NODE_IP sudo tee /etc/tinc/rpinet/hosts/$PI_NODE_NAME
ssh ubuntu@$EC2_NODE_IP cat /etc/tinc/rpinet/hosts/ec2 | ssh pi@$PI_NODE_NAME sudo tee /etc/tinc/rpinet/hosts/ec2