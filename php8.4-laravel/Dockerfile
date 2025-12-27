# =============================================================================
# FrankenPHP + Laravel Octane - Imagem Otimizada
# =============================================================================
# Imagem ultra-otimizada para rodar Laravel com Octane usando FrankenPHP
# Oferece performance superior com suporte a HTTP/2, HTTP/3 e Early Hints
# Tamanho reduzido usando multi-stage build
# =============================================================================

FROM dunglas/frankenphp:php8.4 AS base

# Argumentos para configuração do usuário
ARG UID=1000
ARG GID=1000

# Labels de metadados
LABEL maintainer="WebSolus"
LABEL description="FrankenPHP + Laravel Octane - Imagem ultra-otimizada"
LABEL php.version="8.4"
LABEL frankenphp.version="latest"

ENV UID=${UID} \
    GID=${GID} \
    # Configurações de locale e timezone
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=UTC \
    # Configurações do PHP (podem ser sobrescritas com -e)
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
# Stage 1: Builder - Instalação de extensões e dependências
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
    nodejs \
    npm \
    unzip \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && npm install -g chokidar-cli \
    && npm cache clean --force \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/* \
    && find /var/log -type f -delete

# Criar usuário não-root para segurança
RUN groupadd --gid ${GID} --system php \
    && useradd --uid ${UID} --system --gid php --home /home/php --shell /bin/bash php \
    && mkdir -p /home/php/.composer /home/php/.npm \
    && chown -R php:php /home/php

# Instalar Composer e configurar
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/home/php/.composer

# Copiar configuração do PHP
COPY ./php/php.ini /usr/local/etc/php/php.ini

# Copiar script de entrypoint
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Criar diretório da aplicação e ajustar permissões
RUN mkdir -p /app \
    && chown -R php:php /app \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Configurar diretório de trabalho
WORKDIR /app

# Expor portas HTTP, HTTPS e HTTP/3 (UDP)
EXPOSE 80 443 443/udp

# Healthcheck para monitoramento
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/up || exit 1

# Usar usuário não-root
USER php

# Entrypoint para instalar Octane automaticamente e iniciar o servidor
# Não usar CMD aqui, pois o entrypoint decide o que executar baseado no ambiente
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
