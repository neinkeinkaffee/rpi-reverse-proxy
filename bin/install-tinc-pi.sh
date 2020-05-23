#!/bin/bash

set -ex

# prompt for pi's node name and last octet in VPN IP if they're not provided
if [ -z $HOST_NAME ]
then
  read -p "Please specify hostname of Raspberry Pi (will be used as ssh hostname and VPN node name): " PI_NODE_NAME
fi

if [ -z $LAST_OCTET ]
then
  read -p "Please specify what should be used as last octet in the Raspberry Pi's VPN IP: " LAST_OCTET
fi

export PI_NODE_NAME=$HOST_NAME PI_LAST_OCTET=$LAST_OCTET
ENV_VARS='$PI_NODE_NAME:$PI_LAST_OCTET'

envsubst "$ENV_VARS" < install_tinc.sh | ssh pi@$HOST_NAME sh -