FROM raspbian/stretch

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y -q \
  git \
  apache2 \
  php \
  libapache2-mod-php \
  wakeonlan \
  php-curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/archive/*.deb

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY config_sample.php /var/www/html/config.php
COPY ["index.php", ".htaccess", "bootstrap", "ssl.conf", "/var/www/html/"]

RUN chmod u+s `which ping` && \
  echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && \
  a2enconf fqdn && \
  a2enmod headers && \
  sed -i.bak "s/expose_php = On/expose_php = Off/g" /etc/php/7.0/apache2/php.ini && \
  sed -i.bak "s/E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED/error_reporting = E_ERROR/g" /etc/php/7.0/apache2/php.ini && \
  sed -i.bak "s/ServerSignature On/ServerSignature Off/g" /etc/apache2/conf-available/security.conf && \
  sed -i.bak "s/ServerTokens OS/ServerTokens Prod/g" /etc/apache2/conf-available/security.conf && \
  rm -f /var/www/html/index.html && \
  service apache2 restart

EXPOSE 80
CMD apachectl -D FOREGROUND