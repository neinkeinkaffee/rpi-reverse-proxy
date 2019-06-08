#!/bin/sh

until /usr/bin/docker info; do echo .; sleep 1; done
/usr/bin/docker rm -f tinc
/usr/bin/docker run -d --net=host --cap-add NET_ADMIN --device=/dev/net/tun -v /home/pi/tinc-pi:/etc/tinc --name tinc jordancrawford/rpi-tinc