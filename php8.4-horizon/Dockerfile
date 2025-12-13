FROM websolusoficial/php:8.4-apache

USER root

# Criar todos os diretórios necessários
RUN mkdir -p \
    /var/log/horizon \
    /var/run/supervisor \
    /var/log/supervisor \
    && chown -R php:php /var/log/horizon \
    && chown -R php:php /var/log/supervisor \
    && chown -R php:php /var/run/supervisor

# Copiar nova configuração do Supervisor para Horizon
COPY --chown=php:php ./supervisor/conf.d/horizon.conf /etc/supervisor/conf.d/

# Ajustar permissões
RUN chown -R php:php /etc/supervisor \
    && chmod 755 /etc/supervisor/conf.d/horizon.conf

EXPOSE 80

USER php

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]