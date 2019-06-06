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

Note that for the challenge to complete successfully 
 * Port 80 on the machine must be open to the world (Let's Encrypt doesn't have fixed IPs that we could whitelist).
 * You must create DNS entries for DOMAIN_NAME www.DOMAIN_NAME, e.g. an A Record for DOMAIN_NAME pointing to your IP and a CNAME for www.DOMAIN_NAME pointing to DOMAIN_NAME.

Unless LE_EMAIL is set in a file called .env, letsencrypt-manager will ask for it interactively when requesting a certificate.