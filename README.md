# PHP Docker Images Collection

Coleção de imagens Docker otimizadas para **Laravel** com suporte a **FrankenPHP/Octane** e **Apache**.

## 📦 Imagens Disponíveis

### 🚀 FrankenPHP (Recomendado para Produção)

Imagens de alta performance usando **FrankenPHP** com **Laravel Octane**.

| Imagem | Descrição | Tamanho |
|--------|-----------|---------|
| `websolusoficial/php:8.4-laravel` | Laravel + Octane + FrankenPHP (instala Octane automaticamente) | ~973MB |
| `websolusoficial/php:8.4-scheduler` | Laravel Scheduler com Supervisor | ~979MB |
| `websolusoficial/php:8.4-worker` | Laravel Queue Workers com Supervisor | ~979MB |

### 🔧 Apache (Legacy)

Imagens tradicionais usando **Apache** como servidor web.

| Imagem | Descrição |
|--------|-----------|
| `websolusoficial/php:8.4-apache` | PHP 8.4 + Apache base |
| `websolusoficial/php:8.4-horizon` | PHP 8.4 + Horizon + Supervisor |
| `websolusoficial/php:8.4-puppeteer` | PHP 8.4 + Puppeteer para testes e2e |
| `websolusoficial/laravel:php8.3` | Stack Laravel completa (PHP 8.3) |

---

## 🚀 Imagens FrankenPHP

### 1. websolusoficial/php:8.4-laravel

Imagem principal para rodar **Laravel com Octane** usando FrankenPHP.

#### ✨ Características

- **PHP 8.4.15** (ZTS - Thread Safe)
- **FrankenPHP 1.10.1** com Caddy 2.10.2
- **Instalação automática do Octane** - Não precisa instalar no projeto!
- HTTP/2 e HTTP/3 nativos
- Early Hints para melhor performance
- Workers persistentes (boot único)
- Execução como usuário não-root

#### 📦 Extensões PHP

bcmath, exif, gd, gettext, intl, opcache, pcntl, pdo_mysql, pdo_pgsql, zip, imagick, mongodb, redis

#### 🔧 Uso Rápido

```bash
# Basta montar seu projeto Laravel
docker run -d -p 80:80 -p 443:443 -v $(pwd):/app websolusoficial/php:8.4-laravel
```

O Octane será instalado automaticamente na primeira execução!

#### Docker Compose

```yaml
services:
  app:
    image: websolusoficial/php:8.4-laravel
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - .:/app
    environment:
      - APP_ENV=production
```

---

### 2. websolusoficial/php:8.4-scheduler

Imagem para rodar o **Laravel Scheduler** (`schedule:work`).

#### 🔧 Uso

```yaml
services:
  scheduler:
    image: websolusoficial/php:8.4-scheduler
    volumes:
      - .:/app
    environment:
      - APP_ENV=production
    depends_on:
      - app
```

---

### 3. websolusoficial/php:8.4-worker

Imagem para rodar **Queue Workers** (`queue:work`).

#### ⚙️ Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `WORKER_QUEUE` | default | Filas a processar |
| `WORKER_TRIES` | 3 | Tentativas por job |
| `WORKER_TIMEOUT` | 90 | Timeout em segundos |
| `WORKER_NUMPROCS` | 2 | Número de workers |
| `WORKER_MAX_JOBS` | 1000 | Jobs antes de reciclar |

#### 🔧 Uso

```yaml
services:
  worker:
    image: websolusoficial/php:8.4-worker
    volumes:
      - .:/app
    environment:
      - WORKER_QUEUE=default,high
      - WORKER_NUMPROCS=4
    depends_on:
      - app
      - redis
```

---

## 📋 Exemplo Completo (Docker Compose)

```yaml
services:
  # Aplicação principal (FrankenPHP + Octane)
  app:
    image: websolusoficial/php:8.4-laravel
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - .:/app
    environment:
      - APP_ENV=production
    depends_on:
      - redis
      - mysql

  # Scheduler (tarefas agendadas)
  scheduler:
    image: websolusoficial/php:8.4-scheduler
    volumes:
      - .:/app
    depends_on:
      - app

  # Workers (filas)
  worker:
    image: websolusoficial/php:8.4-worker
    volumes:
      - .:/app
    environment:
      - WORKER_QUEUE=default,high,low
      - WORKER_NUMPROCS=4
    depends_on:
      - app
      - redis

  # Redis
  redis:
    image: redis:alpine

  # MySQL
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: laravel
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

---

## 🔧 Imagens Apache (Legacy)

### websolusoficial/php:8.4-apache

Imagem base com PHP 8.4 e Apache.

```dockerfile
FROM websolusoficial/php:8.4-apache

COPY --chown=php:php . /var/www/html

RUN composer install
```

### websolusoficial/php:8.4-horizon

Estende a imagem base com Supervisor para Laravel Horizon.

```yaml
services:
  horizon:
    image: websolusoficial/php:8.4-horizon
    volumes:
      - .:/var/www/html
    depends_on:
      - redis
```

---

## 🏗️ Build Local

```bash
# FrankenPHP - Laravel
cd php8.4-laravel && docker build --network=host -t websolusoficial/php:8.4-laravel .

# FrankenPHP - Scheduler
cd php8.4-scheduler && docker build --network=host -t websolusoficial/php:8.4-scheduler .

# FrankenPHP - Worker
cd php8.4-worker && docker build --network=host -t websolusoficial/php:8.4-worker .

# Apache
cd php8.4-apache && docker build -t websolusoficial/php:8.4-apache .
```

> **Nota**: Use `--network=host` se houver problemas de timeout durante o build.

---

## 📁 Estrutura do Repositório

```
├── php8.4-laravel/          # FrankenPHP + Octane (principal)
│   ├── Dockerfile
│   ├── Caddyfile
│   ├── docker-entrypoint.sh
│   ├── php/php.ini
│   └── README.md
├── php8.4-scheduler/        # Laravel Scheduler
│   ├── Dockerfile
│   ├── php/php.ini
│   └── supervisor/
├── php8.4-worker/           # Queue Workers
│   ├── Dockerfile
│   ├── docker-entrypoint.sh
│   ├── php/php.ini
│   └── supervisor/
├── php8.4-apache/           # Apache (legacy)
├── php8.4-horizon/          # Horizon (legacy)
├── php8.4-puppeteer/        # Puppeteer (legacy)
└── laravel-php8.3/          # Laravel PHP 8.3 (legacy)
```

---

## 🆘 Suporte

Para problemas ou sugestões, abra uma issue no repositório do GitHub.

## 📄 Licença

MIT
