#!/bin/bash
# =============================================================================
# Docker Entrypoint - Laravel Octane + FrankenPHP
# =============================================================================
# Este script:
# 1. Verifica se existe um projeto Laravel
# 2. Instala o laravel/octane se não estiver instalado
# 3. Configura o Octane para FrankenPHP
# 4. Inicia o servidor FrankenPHP
# =============================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar se estamos no diretório da aplicação
cd /app

# Verificar se existe um projeto Laravel (composer.json com laravel/framework)
if [ -f "composer.json" ]; then
    log_info "Projeto Laravel detectado"
    
    # Verificar se o vendor existe
    if [ ! -d "vendor" ]; then
        log_warn "Diretório vendor não encontrado. Executando composer install..."
        composer install --no-interaction --prefer-dist --optimize-autoloader
    fi
    
    # Verificar se o Octane está instalado
    if ! composer show laravel/octane > /dev/null 2>&1; then
        log_info "Instalando laravel/octane..."
        composer require laravel/octane --no-interaction
        
        # Publicar configuração do Octane se artisan existir
        if [ -f "artisan" ]; then
            log_info "Configurando Octane para FrankenPHP..."
            php artisan octane:install --server=frankenphp --no-interaction 2>/dev/null || true
        fi
    else
        log_info "laravel/octane já está instalado"
    fi
    
    # Gerar chave da aplicação se não existir
    if [ -f ".env" ] && [ -f "artisan" ]; then
        if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
            log_info "Gerando APP_KEY..."
            php artisan key:generate --no-interaction 2>/dev/null || true
        fi
    fi
    
    # Executar cache de configuração em produção
    if [ "$APP_ENV" = "production" ] && [ -f "artisan" ]; then
        log_info "Otimizando para produção..."
        php artisan config:cache 2>/dev/null || true
        php artisan route:cache 2>/dev/null || true
        php artisan view:cache 2>/dev/null || true
    fi
else
    log_warn "Nenhum projeto Laravel encontrado em /app"
    log_warn "Monte seu projeto Laravel em /app para iniciar"
fi

# Executar comando passado ou iniciar FrankenPHP
if [ $# -gt 0 ]; then
    exec "$@"
else
    log_info "Iniciando FrankenPHP com Octane..."
    exec frankenphp run --config /etc/caddy/Caddyfile
fi
