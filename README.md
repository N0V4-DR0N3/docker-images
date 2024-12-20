# PHP Docker Images Collection

Este repositório contém três imagens Docker otimizadas para desenvolvimento PHP com Laravel:

## Imagens Disponíveis

### 1. websolusoficial/php:8.4-apache

Imagem base com PHP 8.4 e Apache.

#### Características:

- PHP 8.4 com Apache
- Extensões PHP populares (Redis, MongoDB, Imagick)
- Node.js e Bun instalados
- ZSH com Oh My ZSH e plugins
- Composer
- Utilitários de desenvolvimento

#### Uso Básico:

```dockerfile
FROM websolusoficial/php:8.4-apache

USER php

COPY --chown=php:php . /var/www/html

RUN composer install && \
    bun install
```

### 2. websolusoficial/php:8.4-horizon

Estende a imagem base, adicionando suporte ao Laravel Horizon.

#### Características Adicionais:

- Supervisor configurado
- Laravel Horizon pronto para uso
- Configurações otimizadas para filas
- Logs estruturados

#### Uso Básico:

```dockerfile
FROM websolusoficial/php:8.4-horizon

USER php

COPY --chown=php:php . /var/www/html

RUN composer install && \
    bun install
```

#### Configuração do docker-compose.yml:

```yaml
services:
  app:
    image: websolusoficial/php:8.4-horizon
    volumes:
      - .:/var/www/html
    depends_on:
      - redis

  redis:
    image: redis:alpine
```

### 3. websolusoficial/php:8.4-node20-puppeteer

Estende a imagem Horizon, adicionando Google Chrome e fontes.

#### Características Adicionais:

- Google Chrome Stable
- Pacotes de fontes completos
- Configurado para headless browsing
- Suporte a PDF e screenshots

#### Uso Básico:

```dockerfile
FROM websolusoficial/php:8.4-node20-puppeteer

USER php

COPY --chown=php:php . /var/www/html

RUN composer install && \
    bun install
```

## Uso com Docker Compose

Exemplo de `docker-compose.yml` completo:

```yaml
version: '3.8'

services:
  app:
    image: websolusoficial/php:8.4-node20-puppeteer
    volumes:
      - .:/var/www/html
    ports:
      - "80:80"
    environment:
      - APP_ENV=local
      - REDIS_HOST=redis
    depends_on:
      - redis
      - mysql

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: laravel
    ports:
      - "3306:3306"
```

## Desenvolvimento

Para contribuir ou personalizar as imagens:

1. Clone o repositório
2. Faça suas modificações
3. Construa as imagens:

```bash
# Imagem base
docker build -t websolusoficial/php:8.4-apache .

# Imagem Horizon
docker build -f Dockerfile.horizon -t websolusoficial/php:8.4-horizon .

# Imagem Puppeteer
docker build -f Dockerfile.puppeteer -t websolusoficial/php:8.4-node20-puppeteer .
```

## Suporte

Para problemas ou sugestões, abra uma issue no repositório do GitHub.

## Licença

MIT
