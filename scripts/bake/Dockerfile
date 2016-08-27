FROM ubuntu:14.04
MAINTAINER Kevin Krummenauer <kevin@whiledo.de>

WORKDIR /data

RUN apt-get update && apt-get install -y \
        apache2 \
        git

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
RUN a2enconf le
RUN mkdir -p /var/www/html/.well-known/acme-challenge
RUN chgrp -R www-data /var/www/html/.well-known && chmod -R g+s /var/www/html/.well-known
RUN apache2ctl -D BACKGROUND

EXPOSE 80 443

CMD ["apache2ctl", "-D", "FOREGROUND"]