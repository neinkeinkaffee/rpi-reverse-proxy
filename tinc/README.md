# Setup VPN between EC2 and Raspberry Pi with tinc

You first need to generate key pairs for both the EC2 instance and the Raspberry Pi.
This can be run from your local machine:
```
# generate keys for EC2
docker run \
    --rm \
    --net=host \
    --device=/dev/net/tun \
    --cap-add NET_ADMIN \
    --volume ${project_root}/tinc/cloud:/etc/tinc \
    jenserat/tinc generate-rsa-keys 4096
    
# generate keys for Raspberry Pi    
docker run -d \
        --rm \
        --net=host \
        --device=/dev/net/tun \
        --cap-add NET_ADMIN \
        --volume ${project_root}/tinc/pi:/etc/tinc \
        jordancrawford/rpi-tinc generate-rsa-keys 4096

# exchange host configuration with public keys
cp ${project_root}/tinc/cloud/hosts/cloud ${project_root}/tinc/pi/hosts
cp ${project_root}/tinc/pi/hosts/pi ${project_root}/tinc/cloud/hosts

# copy tinc config folders to EC2 instance and Raspberry Pi 
scp -r ${project_root}/tinc/cloud ec2-user@${EC2_PUBLIC_IP}:/home/ec2-user/tinc-cloud
scp -r ${project_root}/tinc/pi ec2-user@${RASPBERRY_PI_LOCAL_IP}:/home/pi/tinc-pi
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

Build and start a dockerized nginx on EC2 that proxies requests against the Raspberry pi server or servers.
```
docker build . -t proxy
docker run -d --name proxy --publish 443:443 proxy
```