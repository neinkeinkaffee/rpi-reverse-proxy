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

Run `tinc/install-tinc-pi.sh` on the Raspberry Pi to install and configure tinc as client on it.
```
ssh pi@$PI_HOST wget https://raw.githubusercontent.com/neinkeinkaffee/rpi-reverse-proxy/master/tinc/install-tinc-pi.sh | PI_NODE_NAME=pi2 PI_LAST_OCTET=3 sh -
```

Run `tinc/exchange-keys-between-client-and-host.sh` on your laptop to have the EC2 instance and the Raspberry Pi exchange their public keys.

If we did everything right, you should now be able to ping the Raspberry Pi via its private VPN IP `10.0.0.x` from the EC2 instance and vice versa.