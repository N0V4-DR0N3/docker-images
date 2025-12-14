# PHP 8.4 + Laravel Queue Worker

Imagem Docker para rodar **Laravel Queue Workers** (jobs, events, listeners).

## 🚀 Características

- **PHP 8.4** com extensões essenciais para Laravel
- **Supervisor** para gerenciar múltiplos workers
- **Configuração flexível** via variáveis de ambiente
- **Auto-restart** em caso de falha
- **Graceful shutdown** - Aguarda jobs em execução
- **Alpine Linux** - Imagem leve

## 📦 O que faz

Esta imagem executa `php artisan queue:work` para:

- Processar jobs da fila (Redis, Database, SQS, etc.)
- Executar listeners de eventos
- Processar broadcasts
- Executar jobs de notificações

## 🔧 Uso

### Build

```bash
docker build -t websolusoficial/php:8.4-worker .
```

### Run

```bash
docker run -d \
  -v $(pwd):/app \
  -e WORKER_QUEUE=default,high \
  -e WORKER_NUMPROCS=4 \
  websolusoficial/php:8.4-worker
```

### Docker Compose

```yaml
services:
  worker:
    image: websolusoficial/php:8.4-worker
    volumes:
      - .:/app
    environment:
      - APP_ENV=production
      - WORKER_QUEUE=default,high,low
      - WORKER_NUMPROCS=4
      - WORKER_TRIES=3
      - WORKER_TIMEOUT=90
      - WORKER_MAX_JOBS=1000
    depends_on:
      - app
      - redis
```

## ⚙️ Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `WORKER_QUEUE` | default | Filas a processar (separadas por vírgula) |
| `WORKER_TRIES` | 3 | Tentativas antes de falhar o job |
| `WORKER_TIMEOUT` | 90 | Timeout em segundos por job |
| `WORKER_SLEEP` | 3 | Segundos entre verificações de fila vazia |
| `WORKER_MAX_JOBS` | 1000 | Jobs antes de reiniciar worker |
| `WORKER_MAX_TIME` | 3600 | Segundos antes de reiniciar worker (1h) |
| `WORKER_MEMORY` | 128 | Limite de memória em MB |
| `WORKER_NUMPROCS` | 2 | Número de processos worker |
| `PHP_MEMORY_LIMIT` | 256M | Limite de memória PHP |
| `TZ` | UTC | Timezone do container e PHP |

## 📋 Exemplo: Múltiplas Filas

Para processar filas com prioridade:

```yaml
services:
  # Worker para filas de alta prioridade
  worker-high:
    image: websolusoficial/php:8.4-worker
    environment:
      - WORKER_QUEUE=high
      - WORKER_NUMPROCS=4
      - WORKER_TIMEOUT=60

  # Worker para filas padrão
  worker-default:
    image: websolusoficial/php:8.4-worker
    environment:
      - WORKER_QUEUE=default
      - WORKER_NUMPROCS=2

  # Worker para filas de baixa prioridade (jobs longos)
  worker-low:
    image: websolusoficial/php:8.4-worker
    environment:
      - WORKER_QUEUE=low
      - WORKER_NUMPROCS=1
      - WORKER_TIMEOUT=3600
      - WORKER_MAX_JOBS=100
```

## 🏥 Healthcheck

A imagem verifica se os processos `queue:work` estão rodando.

## 🔄 Graceful Shutdown

Os workers aguardam até 330 segundos para finalizar jobs em execução antes de parar. Isso garante que jobs não sejam interrompidos durante deploys.

## 🔒 Segurança

- Executa como usuário `php` (não-root)
- Apenas processos necessários rodando
- Logs em stdout/stderr para Docker
