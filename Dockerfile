FROM composer:latest AS composer

COPY ./app/ /app/

RUN chmod +x /app/smtp2sms.php

WORKDIR /app

RUN composer install --ignore-platform-reqs

FROM debian:9-slim

LABEL MAINTAINER="Christian Pedersen <christian.pedersen@zentura.dk>"

ENV DEBIAN_FRONTEND=noninteractive

RUN rm /etc/localtime && \
  ln -s /usr/share/zoneinfo/Europe/Copenhagen /etc/localtime

RUN apt-get update && \
  apt-get install rsyslog supervisor postfix sasl2-bin php-cli curl php-curl php-mailparse ca-certificates -y --no-install-recommends && \
  rm -Rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

COPY master.cf /etc/postfix/master.cf

COPY --from=composer /app/ /app/

ENV SMTP_USER=username:password

EXPOSE 25

CMD ["supervisord", "-c /etc/supervisor/supervisord.conf"]
