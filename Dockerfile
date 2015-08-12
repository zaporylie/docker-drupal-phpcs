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
RUN echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile /dev/null\n" >> /root/.ssh/config

VOLUME /reports
VOLUME /workspace

ENV GIT_AFTER=HEAD \
 GIT_BEFORE=HEAD~1 \
 GIT_CLONE_PATH=/workspace \
 GIT_CLONE_URL=https://github.com/drupal/drupal.git \
 GIT_BRANCH=7.x \
 REPORT_FORMAT=checkstyle \
 REPORT_PATH=/reports \
 REPORT_FILENAME=checkstyle-result.xml \
 DEBUG=FALSE

CMD ["/tmp/test.sh"]
