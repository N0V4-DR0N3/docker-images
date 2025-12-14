# PHP 8.4 + Laravel Scheduler

Imagem Docker para rodar o **Laravel Scheduler** (tarefas agendadas).

## 🚀 Características

- **PHP 8.4** com extensões essenciais para Laravel
- **Supervisor** para gerenciar o processo do scheduler
- **schedule:work** - Verifica tarefas a cada minuto
- **Alpine Linux** - Imagem leve
- **Logs em stdout/stderr** - Compatível com Docker

## 📦 O que faz

Esta imagem executa `php artisan schedule:work` que:

- Verifica tarefas agendadas a cada minuto
- Não requer configuração de cron
- Mantém o processo rodando continuamente
- Logs em tempo real

## 🔧 Uso

### Build

```bash
docker build -t websolusoficial/php:8.4-scheduler .
```

### Run

```bash
docker run -d \
  -v $(pwd):/app \
  -e APP_ENV=production \
  websolusoficial/php:8.4-scheduler
```

### Docker Compose

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
      - redis
```

## ⚙️ Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `PHP_MEMORY_LIMIT` | 256M | Limite de memória PHP |
| `TZ` | UTC | Timezone do container e PHP |

## 📋 Configuração Laravel

Defina suas tarefas agendadas em `app/Console/Kernel.php`:

```php
protected function schedule(Schedule $schedule)
{
    $schedule->command('inspire')->hourly();
    $schedule->command('telescope:prune')->daily();
    $schedule->command('queue:prune-batches')->daily();
}
```

Ou usando o novo formato do Laravel 11+:

```php
// routes/console.php
use Illuminate\Support\Facades\Schedule;

Schedule::command('inspire')->hourly();
Schedule::command('telescope:prune')->daily();
```

## 🏥 Healthcheck

A imagem verifica se o processo `schedule:work` está rodando.

## 🔒 Segurança

- Executa como usuário `php` (não-root)
- Apenas processos necessários rodando
