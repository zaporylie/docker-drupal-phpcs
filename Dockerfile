FROM ubuntu:trusty


RUN DEBIAN_FRONTEND=noninteractive apt-get update \
  && apt-get -yq install shunit2 curl php5 php5-curl

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install git

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && composer global require drupal/coder  

COPY test.sh /tmp/test.sh
RUN chmod +x /tmp/test.sh

RUN mkdir /root/.ssh
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config

ENV SHA1=HEAD \
 BRANCH=7.x \
 FORMAT=full \
 DEBUG=FALSE \
 CLONE_URL=https://github.com/drupal/drupal.git

ENTRYPOINT ["/bin/bash"]
CMD ["/tmp/test.sh"]
