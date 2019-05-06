# rpi-reverse-proxy

Generate an ssh key and upload it to your AWS account.
```
ssh-keygen -f ~/.ssh/aws
aws ec2 import-key-pair --key-name $KEY_NAME \
  --public-key-material file://$HOME//.ssh/aws.pub
```