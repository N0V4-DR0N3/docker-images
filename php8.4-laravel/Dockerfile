# =============================================================================
# FrankenPHP + Laravel Octane - Imagem Base
# =============================================================================
# Imagem otimizada para rodar Laravel com Octane usando FrankenPHP
# Oferece performance superior com suporte a HTTP/2, HTTP/3 e Early Hints
# =============================================================================

FROM dunglas/frankenphp:php8.4

# Argumentos para configuração do usuário
ARG UID=1000
ARG GID=1000

# Labels de metadados
LABEL maintainer="WebSolus"
LABEL description="FrankenPHP + Laravel Octane - Imagem otimizada para produção"
LABEL php.version="8.4"
LABEL frankenphp.version="latest"

ENV UID=${UID} \
    GID=${GID} \
    # Configurações do FrankenPHP/Octane
    SERVER_NAME=":80 :443" \
    FRANKENPHP_CONFIG="worker ./public/index.php" \
    APP_ENV=production \
    # Configurações de locale e timezone
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TZ=UTC \
    # Configurações do PHP (podem ser sobrescritas com -e)
    PHP_MEMORY_LIMIT=512M \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_POST_MAX_SIZE=500M \
    PHP_UPLOAD_MAX_FILESIZE=500M

# Instalar dependências do sistema em uma única camada
RUN apt-get update && apt-get install -yqq --no-install-recommends \
    ca-certificates \
    curl \
    git \
    libicu-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libpq-dev \
    libmagickwand-dev \
    locales \
    unzip \
    zip \
    zlib1g-dev \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Configurar e instalar extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
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
    zip

# Instalar extensões PECL
RUN pecl install imagick mongodb redis \
    && docker-php-ext-enable \
    imagick \
    mongodb \
    redis

# Criar usuário não-root para segurança
RUN groupadd --gid ${GID} --system php \
    && useradd --uid ${UID} --system --gid php --home /home/php --shell /bin/bash php \
    && mkdir -p /home/php/.composer \
    && chown -R php:php /home/php

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar configuração do PHP
COPY ./php/php.ini /usr/local/etc/php/php.ini

# Copiar Caddyfile para configuração do FrankenPHP
COPY ./Caddyfile /etc/caddy/Caddyfile

# Copiar script de entrypoint
COPY ./docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Criar diretório da aplicação e ajustar permissões
RUN mkdir -p /app \
    && chown -R php:php /app \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# Configurar diretório de trabalho
WORKDIR /app

# Expor portas HTTP e HTTPS
EXPOSE 80 443

# Healthcheck para monitoramento
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/up || exit 1

# Usar usuário não-root
USER php

# Entrypoint para instalar Octane automaticamente e iniciar o servidor
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Sem CMD - o entrypoint decide se usa octane:frankenphp ou frankenphp run
