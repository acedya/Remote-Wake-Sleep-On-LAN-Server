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

RUN chmod u+s `which ping` && \
  git clone https://github.com/acedya/Remote-Wake-Sleep-On-LAN-Server.git && \
  echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf && \
  a2enconf fqdn && \
  a2enmod headers && \
  #sed -i "s/80/81/g" /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf &&\
  mv -f Remote-Wake-Sleep-On-LAN-Server/000-default.conf /etc/apache2/sites-available/000-default.conf && \
  sed -i.bak "s/expose_php = On/expose_php = Off/g" /etc/php/7.0/apache2/php.ini && \
  sed -i.bak "s/E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED/error_reporting = E_ERROR/g" /etc/php/7.0/apache2/php.ini && \
  sed -i.bak "s/ServerSignature On/ServerSignature Off/g" /etc/apache2/conf-available/security.conf && \
  sed -i.bak "s/ServerTokens OS/ServerTokens Prod/g" /etc/apache2/conf-available/security.conf && \
  service apache2 restart && \
  mv Remote-Wake-Sleep-On-LAN-Server/* /var/www/html && \
  mv Remote-Wake-Sleep-On-LAN-Server/.htaccess /var/www/html && \
  rm -rf Remote-Wake-Sleep-On-LAN-Server/ && \
  rm -f /var/www/html/index.html && \
  mv /var/www/html/config_sample.php /var/www/html/config.php

EXPOSE 80
CMD apachectl -D FOREGROUND