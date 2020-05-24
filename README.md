# rpi-reverse-proxy

## Provision a proxy on AWS EC2

Generate an ssh key and upload it to your AWS account.
```
ssh-keygen -f ~/.ssh/aws
```

Fill in the values for the variables `keyfile` (absolute path to the public ssh key you generate, see above), `domain`, `email` and `cloudflare_api_token` in `terraform.tfvars.template` and rename it to `terraform.tfvars`.

Then provision an EC2 instance with an Elastic IP and certbot and tinc installed and configured.
```
cd terraform
terraform apply -var-file=terraform.tfvars
```

## Setup tinc on Raspberry Pi as client and exchange keys with EC2 host

On your laptop, to install and configure tinc as client on it, and have the EC2 instance and the Raspberry Pi exchange their public keys, run 
```
PI_NODE_NAME=kleener-punker PI_LAST_OCTET=12 EC2_NODE_IP=123.123.123.123 ./bin/install-tinc-pi.sh
```
Make sure to provide `PI_NODE_NAME`, `PI_LAST_OCTET` and `EC2_NODE_IP`, the script will prompt you for values if it finds they're empty.

To install and configure tinc as client on your laptop, and have the EC2 instance and your laptop exchange their public keys, run 
```
LAPTOP_NODE_NAME=laptop1 LAPTOP_LAST_OCTET=11 EC2_NODE_IP=123.123.123.123 ./bin/install-tinc-laptop.sh
```
Make sure to provide `LAPTOP_NODE_NAME`, `LAPTOP_LAST_OCTET` and `EC2_NODE_IP`, the script will prompt you for values if it finds they're empty.

If everything worked as expected you should now be able to ping the Raspberry Pi via its private VPN IP `10.0.0.x` from your laptop and vice versa.