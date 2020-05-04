# rpi-reverse-proxy

## Provision a proxy on AWS EC2

Generate an ssh key and upload it to your AWS account.
```
ssh-keygen -f ~/.ssh/aws
```

Provision an EC2 instance with an Elastic IP and certbot and tinc installed and configured.
```
cd terraform
terraform apply -var-file=terraform.tfvars
```

## Setup tinc on Raspberry Pi as client and exchange keys with EC2 host

On your Raspberry Pi, to install and configure tinc as client on it, run 
```
wget https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/tinc/install-tinc-pi.sh | PI_NODE_NAME=pi2 PI_LAST_OCTET=3 sh -
```
Make sure to pass in `PI_NODE_NAME` and `PI_LAST_OCTET`.

On your laptop, to have the EC2 instance and the Raspberry Pi exchange their public keys, run
```
wget https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/tinc/exchange-pi-keys-from-laptop.sh
```
and provide `PI_NODE_NAME` and `EC2_NODE_IP` when prompted.

If everything worked as expected you should now be able to ping the Raspberry Pi via its private VPN IP `10.0.0.x` from the EC2 instance and vice versa.