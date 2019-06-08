# rpi-reverse-proxy



## Provision a proxy on AWS EC2

Generate an ssh key and upload it to your AWS account.
> Replace $KEY_NAME by the name of the key that you reference with `aws_instance.proxy.key_name` in terraform/proxy.tf.
```
ssh-keygen -f ~/.ssh/aws
aws ec2 import-key-pair --key-name $KEY_NAME \
  --public-key-material file://$HOME//.ssh/aws.pub
```

Provision an EC2 instance with an Elastic IP.
```
pushd terraform
terraform apply
popd
```

## Setup VPN between EC2 and Raspberry Pi with tinc

You first need to generate key pairs for both the EC2 instance and the Raspberry Pi.
This can be run from your local machine:

> Replace `$EC2_PUBLIC_IP` by the Elastic IP of your EC2 instance and `$RASPBERRY_PI_LOCAL_IP` by your Raspberry Pi's local network IP.

```
# generate keys for EC2
docker run \
    --rm \
    --net=host \
    --device=/dev/net/tun \
    --cap-add NET_ADMIN \
    --volume $(pwd)/tinc/cloud:/etc/tinc \
    jenserat/tinc generate-rsa-keys 4096
    
# generate keys for Raspberry Pi    
docker run -d \
        --rm \
        --net=host \
        --device=/dev/net/tun \
        --cap-add NET_ADMIN \
        --volume $(pwd)/tinc/pi:/etc/tinc \
        jordancrawford/rpi-tinc generate-rsa-keys 4096

# exchange host configuration with public keys
cp $(pwd)/tinc/cloud/hosts/cloud $(pwd)/tinc/pi/hosts
cp $(pwd)/tinc/pi/hosts/pi $(pwd)/tinc/cloud/hosts

# copy tinc config folders to EC2 instance and Raspberry Pi 
scp -r $(pwd)/tinc/cloud ec2-user@$EC2_PUBLIC_IP:/home/ec2-user/tinc-cloud
scp -r $(pwd)/tinc/pi ec2-user@$RASPBERRY_PI_LOCAL_IP:/home/pi/tinc-pi
```

This needs to happen on the EC2 instance:
```
# install docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

# start tinc    
docker run -d \
    --name tinc \
    --net=host \
    --device=/dev/net/tun \
    --cap-add NET_ADMIN \
    --volume /home/ec2-user/tinc-cloud:/etc/tinc 
    jenserat/tinc start -D -d5    
```

This needs to happen on the Raspberry Pi:
```
# install docker
curl -sSL https://get.docker.com | sh

# start tinc 
docker run -d \
    --name tinc \
    --net=host \
    --device=/dev/net/tun \
    --cap-add NET_ADMIN \
    --volume /home/pi/tinc-pi:/etc/tinc \
    jordancrawford/rpi-tinc
```

## Start nginx proxy on EC2 that forwards requests to Raspberry Pi
Build and start a dockerized nginx on EC2 that proxies requests against the Raspberry pi server or servers.
```
# install docker-compose
pip install docker-compose

# start nginx proxy
docker-compose -f tinc/nginx-proxy/letsencrypt/docker-compose.yml run -d
```

## Configure HTTPS for nginx in docker with letsencrypt-manager

letsencrypt-manager (https://github.com/gitsf/docker-letsencrypt-manager) simplifies adding and auto-renewing Let's Encrypt certificates.

To install:
```
git clone https://github.com/gitsf/docker-letsencrypt-manager.git
echo alias letsencrypt-manager=\'docker-letsencrypt-manager/letsencrypt-manager\' >> ~/.bashrc && source ~/.bashrc
```

To add a new (non-wildcard) certificate, start up the nginx container.
letsencrypt-manager will see to it that a test file gets created in the acme-webroot.
It then tries to request it.
If that request is successful, Let's Encrypt will validate the certificate.
```
docker-compose up -d # specify path of docker-compose.yml with -f if not inside the same folder as this README.md
letsencrypt-manager add some-domain-name.de www.some-domain-name.de [and maybe more alternative domain names]...
```

Note that for the challenge to complete successfully 
 * Port 80 on the machine must be open to the world (Let's Encrypt doesn't have fixed IPs that we could whitelist).
 * You must create DNS entries for DOMAIN_NAME www.DOMAIN_NAME, e.g. an A Record for DOMAIN_NAME pointing to your IP and a CNAME for www.DOMAIN_NAME pointing to DOMAIN_NAME.

Unless LE_EMAIL is set in a file called .env, letsencrypt-manager will ask for it interactively when requesting a certificate.