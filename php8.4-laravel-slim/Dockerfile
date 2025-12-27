# =============================================================================
# FrankenPHP + Laravel Octane - Imagem SLIM
# =============================================================================
# Versão ultra-leve sem extensões opcionais (imagick, mongodb)
# Use esta versão se não precisar dessas extensões
# Redução estimada: ~100-150MB
# =============================================================================

FROM dunglas/frankenphp:php8.4 AS base

ARG UID=1000
ARG GID=1000

LABEL maintainer="WebSolus"
LABEL description="FrankenPHP + Laravel Octane - Ultra SLIM"
LABEL php.version="8.4"
LABEL variant="slim"

ENV UID=${UID} \
    GID=${GID} \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=UTC \
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_POST_MAX_SIZE=500M \
    PHP_UPLOAD_MAX_FILESIZE=500M \
    # Configurações do Octane (configuradas automaticamente pelo entrypoint)
    OCTANE_HOST=0.0.0.0 \
    OCTANE_PORT=80 \
    OCTANE_WORKERS=auto \
    OCTANE_MAX_REQUESTS=500 \
    # Configurações do Caddy/FrankenPHP
    SERVER_NAME=":80 :443" \
    XDG_CONFIG_HOME=/var/www/html/config \
    XDG_DATA_HOME=/var/www/html/data

# =============================================================================
# Stage 1: Builder
# =============================================================================
FROM base AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    $PHPIZE_DEPS \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    zlib1g-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        bcmath \
        exif \
        gd \
        intl \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear /var/lib/apt/lists/*

# =============================================================================
# Stage 2: Runtime
# =============================================================================
FROM base AS runtime

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    libicu72 \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16 \
    libzip4 \
    libonig5 \
    libpq5 \
    locales \
    nodejs \
    npm \
    unzip \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && npm install -g chokidar-cli \
    && npm cache clean --force \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/* /root/.npm \
    && find /var/log -type f -delete \
    && find /usr/local/lib/php/extensions -name "*.a" -delete

RUN groupadd --gid ${GID} --system php \
    && useradd --uid ${UID} --system --gid php --home /home/php --shell /bin/bash php \
    && mkdir -p /home/php/.composer /home/php/.npm \
    && chown -R php:php /home/php

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/home/php/.composer

COPY ./php/php.ini /usr/local/etc/php/php.ini
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN mkdir -p /app \
    && chown -R php:php /app \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /app

EXPOSE 80 443 443/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/up || exit 1

USER php

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["php", "artisan", "octane:frankenphp"]
