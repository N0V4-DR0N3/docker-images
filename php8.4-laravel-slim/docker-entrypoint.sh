#!/bin/bash
# =============================================================================
# Docker Entrypoint - Laravel Octane + FrankenPHP
# =============================================================================
# Este script:
# 1. Verifica se existe um projeto Laravel
# 2. Instala o laravel/octane se não estiver instalado
# 3. Configura o Octane para FrankenPHP
# 4. Garante que chokidar esteja instalado para watch mode
# 5. Inicia o servidor FrankenPHP com Octane
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
    
    # Verificar se há dependências Node.js para instalar
    if [ -f "package.json" ] && [ ! -d "node_modules" ]; then
        log_info "Instalando dependências Node.js..."
        npm install --silent 2>/dev/null || log_warn "Falha ao instalar dependências Node.js"
    fi
    
    # Gerar chave da aplicação se não existir
    if [ -f ".env" ] && [ -f "artisan" ]; then
        if ! grep -q "^APP_KEY=base64:" .env 2>/dev/null; then
            log_info "Gerando APP_KEY..."
            php artisan key:generate --no-interaction 2>/dev/null || true
        fi
    fi
    
    # Detectar ambiente automaticamente se não definido
    if [ -z "$APP_ENV" ] && [ -f ".env" ]; then
        APP_ENV=$(grep -E "^APP_ENV=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" || echo "local")
        export APP_ENV
        log_info "Ambiente detectado: $APP_ENV"
    fi
    
    # Configurar comportamento baseado no ambiente
    if [ "$APP_ENV" = "production" ] || [ "$APP_ENV" = "prod" ] && [ -f "artisan" ]; then
        log_info "⚡ Ambiente de PRODUÇÃO detectado"
        log_info "Otimizando para produção..."
        
        # Caches de otimização
        php artisan config:cache 2>/dev/null || true
        php artisan route:cache 2>/dev/null || true
        php artisan view:cache 2>/dev/null || true
        php artisan event:cache 2>/dev/null || true
        
        # Forçar desabilitação do watch em produção
        export OCTANE_WATCH=false
        log_warn "❌ Watch mode DESABILITADO (produção)"
        
        # Otimizar workers para produção
        if [ "$OCTANE_WORKERS" = "auto" ]; then
            # Em produção, usar mais workers
            OCTANE_WORKERS=$(nproc)
            log_info "Workers ajustados para produção: $OCTANE_WORKERS"
        fi
    else
        log_info "🛠️ Ambiente de DESENVOLVIMENTO detectado ($APP_ENV)"
        
        # Limpar caches em desenvolvimento para evitar problemas
        if [ -f "artisan" ]; then
            php artisan config:clear 2>/dev/null || true
            php artisan route:clear 2>/dev/null || true
            php artisan view:clear 2>/dev/null || true
        fi
        
        # Watch mode ativo por padrão em desenvolvimento
        if [ -z "$OCTANE_WATCH" ] || [ "$OCTANE_WATCH" = "true" ] || [ "$OCTANE_WATCH" = "1" ]; then
            export OCTANE_WATCH=true
            log_info "✅ Watch mode HABILITADO (desenvolvimento)"
        fi
        
        # Usar menos workers em desenvolvimento
        if [ "$OCTANE_WORKERS" = "auto" ]; then
            OCTANE_WORKERS=1
            log_info "Workers ajustados para desenvolvimento: $OCTANE_WORKERS"
        fi
    fi
else
    log_warn "Nenhum projeto Laravel encontrado em /app"
    log_warn "Monte seu projeto Laravel em /app para iniciar"
fi

# Executar comando passado ou iniciar Octane com FrankenPHP
log_info "Argumentos recebidos: $# ($@)"
if [ $# -gt 0 ]; then
    log_warn "Executando comando customizado: $@"
    exec "$@"
else
    # Octane é instalado automaticamente no início do script
    if [ -f "artisan" ]; then
        log_info "Iniciando Laravel Octane com FrankenPHP..."
        log_info "Ambiente: ${APP_ENV:-local} | Workers: ${OCTANE_WORKERS} | Watch: ${OCTANE_WATCH}"
        
        # Configurações via variáveis de ambiente
        OCTANE_HOST="${OCTANE_HOST:-0.0.0.0}"
        OCTANE_PORT="${OCTANE_PORT:-80}"
        OCTANE_MAX_REQUESTS="${OCTANE_MAX_REQUESTS:-500}"
        
        # Construir argumentos do Octane
        OCTANE_ARGS="--host=$OCTANE_HOST --port=$OCTANE_PORT --workers=$OCTANE_WORKERS --max-requests=$OCTANE_MAX_REQUESTS"
        
        # Adicionar --watch se habilitado (apenas desenvolvimento)
        if [ "$OCTANE_WATCH" = "true" ] || [ "$OCTANE_WATCH" = "1" ]; then
            log_info "✅ Hot-reload ativo (chokidar-cli global)"
            OCTANE_ARGS="$OCTANE_ARGS --watch"
            
            # Verificar se chokidar está instalado
            if ! command -v chokidar &> /dev/null; then
                log_error "chokidar-cli não encontrado! Instalando..."
                npm install -g chokidar-cli
            else
                log_info "chokidar-cli encontrado: $(which chokidar)"
            fi
        fi
        
        # Adicionar --log-level se definido
        if [ -n "$OCTANE_LOG_LEVEL" ]; then
            OCTANE_ARGS="$OCTANE_ARGS --log-level=$OCTANE_LOG_LEVEL"
        fi
        
        # Verificar permissões do diretório (importante para watch mode)
        if [ ! -w "/app" ]; then
            log_warn "Diretório /app não é gravável! Watch mode pode não funcionar."
            log_warn "Verifique os volumes montados e permissões."
        fi
        
        log_info "Comando: php artisan octane:frankenphp $OCTANE_ARGS"
        exec php artisan octane:frankenphp $OCTANE_ARGS
    else
        log_error "Nenhum projeto Laravel encontrado em /app"
        log_error "Monte seu projeto Laravel em /app para iniciar"
        exit 1
    fi
fi
