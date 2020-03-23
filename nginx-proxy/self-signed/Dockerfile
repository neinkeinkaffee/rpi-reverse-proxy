FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
RUN apk --no-cache add openssl && \
    openssl req -x509 -newkey rsa:4096 -keyout /etc/ssl/private/snakeoil-key.pem -out /etc/ssl/snakeoil-cert.pem -days 365 -nodes -subj '/CN=localhost' && \
    apk del --purge openssl