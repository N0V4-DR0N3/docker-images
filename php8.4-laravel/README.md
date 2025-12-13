# PHP 8.4 + FrankenPHP (Laravel Octane)

Imagem Docker otimizada para rodar **Laravel** com **Octane** usando **FrankenPHP**.

## 🚀 Características

- **PHP 8.4** com extensões essenciais para Laravel
- **FrankenPHP** - Servidor de aplicação PHP de alta performance
- **Octane Worker Mode** - Workers persistentes para máxima performance
- **Instalação automática do Octane** - Não precisa instalar no projeto!
- **HTTP/2 e HTTP/3** - Suporte nativo
- **Early Hints** - Melhor performance de carregamento
- **Debian Trixie** - Base estável
- **Segurança** - Executa como usuário não-root

## ✨ Instalação Automática do Octane

Esta imagem **instala automaticamente** o `laravel/octane` quando o container inicia!

O que o entrypoint faz:
1. Detecta se existe um projeto Laravel em `/app`
2. Executa `composer install` se o vendor não existir
3. Instala `laravel/octane` automaticamente se não estiver no projeto
4. Configura o Octane para usar FrankenPHP
5. Gera `APP_KEY` se necessário
6. Otimiza cache em produção (`config:cache`, `route:cache`, `view:cache`)
7. Inicia o servidor FrankenPHP

## 📦 Extensões PHP Incluídas

- bcmath, exif, gd, gettext, intl
- opcache, pcntl, pdo_mysql, pdo_pgsql
- zip, imagick, mongodb, redis

## 🔧 Uso

### Build

```bash
docker build -t websolusoficial/php:8.4-laravel .
```

### Run

```bash
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -v $(pwd):/app \
  -e APP_ENV=production \
  websolusoficial/php:8.4-laravel
```

### Docker Compose

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
      - FRANKENPHP_MAX_REQUESTS=1000
```

## ⚙️ Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `APP_ENV` | production | Ambiente da aplicação |
| `OCTANE_HOST` | 0.0.0.0 | IP que o servidor deve escutar |
| `OCTANE_PORT` | 80 | Porta do servidor |
| `OCTANE_WORKERS` | auto | Número de workers (auto = 2x CPUs) |
| `OCTANE_MAX_REQUESTS` | 500 | Requests antes de reiniciar worker |
| `PHP_MEMORY_LIMIT` | 512M | Limite de memória PHP |
| `PHP_MAX_EXECUTION_TIME` | 300 | Tempo máximo de execução |
| `PHP_POST_MAX_SIZE` | 500M | Tamanho máximo do POST |
| `PHP_UPLOAD_MAX_FILESIZE` | 500M | Tamanho máximo de upload |

### Exemplo com Configuração Personalizada

```bash
docker run -d \
  -p 80:80 \
  -v $(pwd):/app \
  -e OCTANE_WORKERS=8 \
  -e OCTANE_MAX_REQUESTS=1000 \
  websolusoficial/php:8.4-laravel
```

## 🔒 Segurança

- Executa como usuário `php` (não-root)
- Headers de segurança configurados
- Funções perigosas desabilitadas
- OPcache otimizado para produção

## 📋 Setup Laravel

**Você NÃO precisa instalar o Octane manualmente!** A imagem faz isso automaticamente.

Basta montar seu projeto Laravel e iniciar o container:

```bash
docker run -d -p 80:80 -v $(pwd):/app websolusoficial/php:8.4-laravel
```

### Opcional: Instalar manualmente

Se preferir instalar o Octane no projeto antes:

```bash
composer require laravel/octane
php artisan octane:install --server=frankenphp
```

## 🏥 Healthcheck

A imagem inclui healthcheck que verifica a rota `/up` do Laravel.
Certifique-se de que essa rota existe em seu `routes/web.php`:

```php
Route::get('/up', fn() => response('OK'));
```
