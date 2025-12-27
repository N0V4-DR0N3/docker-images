# =============================================================================
# FrankenPHP + Laravel Worker
# =============================================================================
# Imagem para rodar Laravel Queue Workers
# Processa jobs, events, listeners e broadcasts
# =============================================================================

FROM dunglas/frankenphp:php8.4 AS base

# Argumentos para configuração do usuário
ARG UID=1000
ARG GID=1000

# Labels de metadados
LABEL maintainer="WebSolus"
LABEL description="Laravel Queue Worker - Processa jobs em background"
LABEL php.version="8.4"
LABEL type="worker"

ENV UID=${UID} \
    GID=${GID} \
    # Configurações de locale e timezone
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=UTC \
    # Configurações do PHP
    PHP_MEMORY_LIMIT=256M \
    PHP_MAX_EXECUTION_TIME=0 \
    # Configurações do Worker
    WORKER_QUEUE=default \
    WORKER_TRIES=3 \
    WORKER_TIMEOUT=90 \
    WORKER_SLEEP=3 \
    WORKER_MAX_JOBS=1000 \
    WORKER_MAX_TIME=3600 \
    WORKER_MEMORY=128 \
    WORKER_NUMPROCS=2

# =============================================================================
# Stage 1: Builder - Instalação de extensões
# =============================================================================
FROM base AS builder

# Instalar dependências de build (serão removidas na imagem final)
RUN apt-get update && apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    libmagickwand-dev \
    zlib1g-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        exif \
        gd \
        gettext \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        zip \
    && pecl install imagick mongodb redis \
    && docker-php-ext-enable imagick mongodb redis \
    && rm -rf /tmp/pear /var/lib/apt/lists/*

# =============================================================================
# Stage 2: Runtime - Imagem final otimizada
# =============================================================================
FROM base AS runtime

# Copiar extensões compiladas do builder
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Instalar APENAS bibliotecas runtime necessárias (sem headers -dev)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    libicu76 \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16 \
    libzip5 \
    libonig5 \
    libpq5 \
    libmagickwand-7.q16-10 \
    locales \
    supervisor \
    unzip \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/* \
    && find /var/log -type f -delete

# Criar usuário não-root
RUN groupadd --gid ${GID} --system php \
    && useradd --uid ${UID} --system --gid php --home /home/php --shell /bin/bash php \
    && mkdir -p /home/php/.composer \
    && chown -R php:php /home/php

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar configuração do PHP
COPY ./php/php.ini /usr/local/etc/php/php.ini

# Copiar configurações do Supervisor
COPY ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./supervisor/conf.d/worker.conf /etc/supervisor/conf.d/worker.conf

# Script de inicialização para substituir variáveis de ambiente
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Criar diretórios de log
RUN mkdir -p /var/log/supervisor /var/run/supervisor /app \
    && chown -R php:php /var/log/supervisor /var/run/supervisor /app /etc/supervisor \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Diretório de trabalho
WORKDIR /app

# Healthcheck - verifica se os workers estão rodando
HEALTHCHECK --interval=60s --timeout=10s --start-period=10s --retries=3 \
    CMD pgrep -f "queue:work" > /dev/null || exit 1

# Usuário não-root
USER php

# Entrypoint para processar variáveis de ambiente
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Executar Supervisor (que gerencia os workers)
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
