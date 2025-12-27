# PHP 8.4 + FrankenPHP (Laravel Octane) - SLIM

Imagem Docker **ultra-otimizada** para rodar **Laravel** com **Octane** usando **FrankenPHP**.

**Esta é a versão SLIM** - ~100MB menor que a versão completa, sem extensões opcionais (imagick, mongodb, gettext).

## 🚀 Características

- **PHP 8.4** com extensões essenciais para Laravel
- **FrankenPHP** - Servidor de aplicação PHP de alta performance baseado em Caddy
- **Octane Worker Mode** - Workers persistentes para máxima performance
- **Multi-Stage Build** - Imagem otimizada para menor tamanho possível
- **Instalação automática do Octane** - Não precisa instalar no projeto!
- **Watch Mode inteligente** - Ativado automaticamente em dev, desabilitado em produção
- **HTTP/2 e HTTP/3** - Suporte nativo via FrankenPHP
- **Early Hints** - Melhor performance de carregamento
- **Debian Trixie** - Base estável
- **Segurança** - Executa como usuário não-root

> **Versão Slim disponível:** Para uma imagem ~100MB menor sem imagick e mongodb, use `php8.4-laravel-slim-slim/`

## ✨ Instalação Automática do Octane

Esta imagem **instala automaticamente** o `laravel/octane` quando o container inicia!

O que o entrypoint faz:
1. Detecta se existe um projeto Laravel em `/app`
2. Executa `composer install` se o vendor não existir
3. Instala `laravel/octane` automaticamente se não estiver no projeto
4. Configura o Octane para usar FrankenPHP (`octane:install --server=frankenphp`)
5. Instala dependências Node.js se houver `package.json`
6. Gera `APP_KEY` se necessário
7. Otimiza cache em produção (`config:cache`, `route:cache`, `view:cache`)
8. Inicia o servidor FrankenPHP com Octane

**Watch Mode:** Configurado **automaticamente** baseado no `APP_ENV`:
- **Desenvolvimento** (`local`, `dev`, `testing`): Watch **ATIVO** + 1 worker + caches limpos
- **Produção** (`production`, `prod`): Watch **DESATIVADO** + workers otimizados + caches ativos

O `chokidar-cli` já está **instalado globalmente** na imagem!

## 📦 Extensões PHP Incluídas

**Versão Slim - Otimizada:**
- bcmath, exif, gd, intl
- opcache, pcntl, pdo_mysql, pdo_pgsql
- zip, redis

**Extensões removidas** (disponíveis na versão completa):
- ❌ imagick (economia: ~50MB)
- ❌ mongodb (economia: ~30MB)
- ❌ gettext (economia: ~5MB)

> **Versão completa disponível:** Para todas extensões, use [php8.4-laravel](../php8.4-laravel/)

## 🔧 Uso

### Build

```bash
docker build -t websolusoficial/php:8.4-laravel-slim .
```

### Run

```bash
docker run -d \
  -p 80:80 \
  -p 443:443 \
  -p 443:443/udp \
  -v $(pwd):/app \
  -e APP_ENV=production \
  websolusoficial/php:8.4-laravel-slim
```

### Docker Compose

```yaml
services:
  app:
    image: websolusoficial/php:8.4-laravel-slim
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"  # HTTP/3 (QUIC)
    volumes:
      - .:/app
    environment:
      - APP_ENV=production
      - OCTANE_WORKERS=4
      - OCTANE_MAX_REQUESTS=500
      # Watch mode é desabilitado automaticamente em produção
```

### Desenvolvimento com Watch Mode

O watch mode é **configurado automaticamente**:

```yaml
services:
  app:
    image: websolusoficial/php:8.4-laravel-slim
    ports:
      - "80:80"
    volumes:
      - .:/app
    environment:
      - APP_ENV=local  # Watch ATIVO automaticamente
```

**O que acontece automaticamente:**
- ✅ Watch mode habilitado
- ✅ 1 worker (melhor para debug)
- ✅ Caches limpos a cada inicialização
- ✅ Hot-reload em mudanças de código

**Forçar watch OFF em desenvolvimento:**
```yaml
environment:
  - APP_ENV=local
  - OCTANE_WATCH=false  # Forçar desabilitar
```

### Produção (Otimizado Automaticamente)

```yaml
services:
  app:
    image: websolusoficial/php:8.4-laravel-slim
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - .:/app
    environment:
      - APP_ENV=production  # Otimizações automáticas
```

**O que acontece automaticamente:**
- ❌ Watch mode desabilitado
- ⚡ Workers = número de CPUs
- 📦 Caches criados (config, routes, views, events)
- 🚀 Máxima performance

```yaml
services:
  app:
    image: websolusoficial/php:8.4-laravel-slim
    ports:
      - "80:80"
    volumes:
      - .:/app
    environment:
      - APP_ENV=local  # Watch ATIVO automaticamente
```

**O que acontece automaticamente:**
- ✅ Watch mode habilitado
- ✅ 1 worker (melhor para debug)
- ✅ Caches limpos a cada inicialização
- ✅ Hot-reload em mudanças de código

**Forçar watch OFF em desenvolvimento:**
```yaml
environment:
  - APP_ENV=local
  - OCTANE_WATCH=false  # Forçar desabilitar
```

## ⚙️ Variáveis de Ambiente

### Aplicação e Servidor

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `APP_ENV` | local | Ambiente da aplicação (controla watch e otimizações) |
| `SERVER_NAME` | :80 :443 | Endereços que o servidor deve escutar |
| `OCTANE_HOST` | 0.0.0.0 | IP que o Octane deve escutar |
| `OCTANE_PORT` | 80 | Porta do Octane |
| `OCTANE_WORKERS` | auto | Número de workers (auto = 1 em dev, nproc em prod) |
| `OCTANE_MAX_REQUESTS` | 500 | Requests antes de reiniciar worker |
| `OCTANE_WATCH` | auto | Hot-reload (auto = true em dev, false em prod) |
| `OCTANE_LOG_LEVEL` | - | Nível de log (error, warning, info, debug) |

### Configurações PHP

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `PHP_MEMORY_LIMIT` | 512M | Limite de memória PHP |
| `PHP_MAX_EXECUTION_TIME` | 300 | Tempo máximo de execução (segundos) |
| `PHP_POST_MAX_SIZE` | 500M | Tamanho máximo do POST |
| `PHP_UPLOAD_MAX_FILESIZE` | 500M | Tamanho máximo de upload |

### Locale

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `LANG` | en_US.UTF-8 | Locale do sistema |
| `LANGUAGE` | en_US:en | Configuração de idioma |
| `LC_ALL` | en_US.UTF-8 | Locale para todas as categorias |
| `TZ` | UTC | Timezone do container |

### Exemplo com Configuração Personalizada

```bash
docker run -d \
  -p 80:80 \
  -v $(pwd):/app \
  -e APP_ENV=production \
  -e OCTANE_WORKERS=8 \
  -e OCTANE_MAX_REQUESTS=1000 \
  -e PHP_MEMORY_LIMIT=1G \
  -e PHP_UPLOAD_MAX_FILESIZE=100M \
  -e TZ=America/Sao_Paulo \
  websolusoficial/php:8.4-laravel-slim
```

## �️ Modo Desenvolvimento (Hot Reload)

Para habilitar o hot-reload durante o desenvolvimento, use a variável `OCTANE_WATCH`:

```bash
docker run -d \
  -p 80:80 \
  -v $(pwd):/app \
  -e OCTANE_WATCH=true \
  websolusoficial/php:8.4-laravel-slim
```

O entrypoint instala automaticamente o `chokidar` se necessário. Você também pode instalar manualmente no projeto:

```bash
npm install --save-dev chokidar
```

## �🔒 Segurança

- Executa como usuário `php` (não-root)
- Headers de segurança configurados
- Funções perigosas desabilitadas
- OPcache otimizado para produção

## 📋 Setup Laravel

**Você NÃO precisa instalar o Octane manualmente!** A imagem faz isso automaticamente.

Basta montar seu projeto Laravel e iniciar o container:

```bash
docker run -d -p 80:80 -v $(pwd):/app websolusoficial/php:8.4-laravel-slim
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
