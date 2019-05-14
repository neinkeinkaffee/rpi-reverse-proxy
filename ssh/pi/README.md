# Setup reverse tunnel with ssh

Open crontab config with `crontab -e` and add the lines 

```
@reboot /home/pi/tunnel.sh
0 0-6 * * * /home/pi/update-ip.sh pi
```
