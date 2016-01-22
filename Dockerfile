FROM drupaldocker/php:fpm

MAINTAINER Jakub Piasecki <jakub@piaseccy.pl>

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get -yq install shunit2 curl git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer global require drupal/coder  

ENV SHA=HEAD \
 CONFIG_FILE=".phpcs.yaml" \
 PROJECT_ROOT="/var/www/html" \
 DEBUG=FALSE

COPY phpcs.sh /tmp/phpcs.sh
COPY php.ini /usr/local/etc/php/
COPY .phpcs.yml /tmp/.phpcs.yml

RUN chmod +x /tmp/phpcs.sh

CMD ["/tmp/phpcs.sh"]
