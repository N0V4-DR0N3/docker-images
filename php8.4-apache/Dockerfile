FROM php:8.4-apache

# Argumentos para configuração do usuário
ARG UID=1000
ARG GID=1000

ENV UID=${UID} \
    GID=${GID} \
    APACHE_DOCUMENT_ROOT=/var/www/html/public \
    APACHE_RUN_USER=php \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# Instalar dependências em uma única camada
RUN apt-get update && apt-get install -yqq --no-install-recommends \
    apt-utils \
    ca-certificates \
    cron \
    curl \
    g++ \
    git \
    gnupg \
    icu-devtools \
    imagemagick \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg62-turbo-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libmcrypt-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libssl-dev \
    libzip-dev \
    locales \
    nano \
    pkg-config \
    supervisor \
    unzip \
    zip \
    zlib1g-dev \
    zsh \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoclean

# Configurar locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen

# Configurar e instalar extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    gd \
    gettext \
    intl \
    mbstring \
    pcntl \
    pdo_mysql \
    zip

# Instalar extensões PECL
RUN pecl install imagick mongodb redis \
    && docker-php-ext-enable \
    imagick \
    mongodb \
    opcache \
    redis

# Instalar Node.js e Bun
RUN curl -sL https://deb.nodesource.com/setup_22.x | bash \
    && apt-get install -y nodejs \
    && npm install -g npm bun \
    && rm -rf /var/lib/apt/lists/*

# Configurar Apache
RUN a2enmod rewrite \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Configurar usuário PHP
RUN addgroup --gid ${GID} --system php \
    && adduser --uid ${UID} --system --ingroup php --disabled-password --shell /usr/bin/zsh --home /home/php php \
    && mkdir -p /home/php/.composer \
    && chown -R php:php /home/php

# Configurar permissões do Apache
RUN chown -R php:php /var/www/html \
    && echo "export APACHE_RUN_USER=php" >> /etc/apache2/envvars \
    && echo "export APACHE_RUN_GROUP=php" >> /etc/apache2/envvars

# Instalar Composer
COPY --chown=php:php ./php/php.ini /usr/local/etc/php/php.ini
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && chmod +x /usr/local/bin/composer

# Configurar ZSH para usuário PHP
USER php
WORKDIR /home/php

# Instalar Oh My Zsh e plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && mkdir -p "$HOME/.zsh" \
    && git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"

# Copiar configuração do ZSH
COPY --chown=php:php ./.zshrc /home/php/.zshrc

USER root

# Configurar Supervisor
RUN mkdir -p /var/run/supervisor /var/log/supervisor /etc/supervisor/conf.d \
    && chown -R php:php /var/run/supervisor /var/log/supervisor /etc/supervisor/conf.d

# Copiar configurações do Supervisor
COPY --chown=php:php ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY --chown=php:php ./supervisor/conf.d/*.conf /etc/supervisor/conf.d/

# Configurar permissões do Supervisor
RUN chown -R php:php /var/log/supervisor /var/run/supervisor /etc/supervisor

USER php
WORKDIR /var/www/html

EXPOSE 80

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
