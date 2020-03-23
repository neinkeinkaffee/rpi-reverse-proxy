# rpi-reverse-proxy

## Provision a proxy on AWS EC2

Generate an ssh key and upload it to your AWS account.
```
ssh-keygen -f ~/.ssh/aws
```

Provision an EC2 instance with an Elastic IP and tinc installed and configured.
```
cd terraform
terraform apply -var keyfile=/Users/neinkeinkaffee/.ssh/aws.pub
```

## Setup tinc on Raspberry Pi as client and exchange keys with EC2 host

The EC2 instance will run `terraform/install-tinc-on-host.sh` on start up and this will install and configure tinc on the instance as VPN host.

Run `tinc/install-tinc-on-client.sh` on the Raspberry Pi to install and configure tinc as client on it.
```
scp tinc/install-tinc-on-client.sh pi@$PI_HOST:/home/pi
ssh pi@$PI_IP NODE_NAME=pi2 NODE_LAST_OCTET=3 ./install-tinc-on-client.sh
```

Run `tinc/exchange-keys-between-client-and-host.sh` from your laptop to have the EC2 instance and the Raspberry Pi exchange their public keys.

Next, startup tinc on the EC2 instance and then on the Raspberry Pi.
```
ssh ubuntu@$EC2_IP 
sudo tincd -n rpinet -D -d3 

ssh pi@$PI_IP 
sudo tincd -n rpinet -D -d3 
```

If we did everything right, you should now be able to ping the Raspberry Pi via its private VPN IP `10.0.0.x` from the EC2 instance and vice versa.