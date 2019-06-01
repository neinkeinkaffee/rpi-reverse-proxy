# Configuring HTTPS for nginx in docker with letsencrypt-manager

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

Note that port 80 must be open to the world for the challenge to complete succesfully (because Let's Encrypt doesn't have fixed IPs that we could whitelist).

If LE_EMAIL is set in a file called .env, letsencrypt-manager will not ask for it interactively when requesting a certificate.