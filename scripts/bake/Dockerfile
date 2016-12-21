FROM ubuntu:14.04
MAINTAINER Kevin Krummenauer <kevin@whiledo.de>

WORKDIR /data

RUN apt-get update && apt-get install -y \
        apache2 \
        git \
        unzip \
        wget \
        dnsutils

RUN wget https://releases.hashicorp.com/vault/0.6.4/vault_0.6.4_linux_amd64.zip && \
    unzip vault_0.6.4_linux_amd64 && \
    mv vault /usr/local/bin
RUN echo "" > /var/www/html/index.html
RUN git clone https://github.com/letsencrypt/letsencrypt
RUN /data/letsencrypt/letsencrypt-auto --help
ADD conf/sites-available/ /etc/apache2/sites-available/
ADD conf/conf-available/ /etc/apache2/conf-available/
ADD conf/keys /etc/ssl/
RUN a2ensite default-ssl
RUN a2enmod ssl
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_wstunnel
RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enconf le
RUN mkdir -p /var/www/html/.well-known/acme-challenge
RUN chgrp -R www-data /var/www/html/.well-known && chmod -R g+s /var/www/html/.well-known

# Install Forego
ADD Procfile /
ADD https://github.com/jwilder/forego/releases/download/v0.16.1/forego /usr/local/bin/forego
RUN chmod u+x /usr/local/bin/forego

RUN apache2ctl -D BACKGROUND
ADD docker-entrypoint.sh /
EXPOSE 80 443

# CMD ["apache2ctl", "-D", "FOREGROUND"]
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
