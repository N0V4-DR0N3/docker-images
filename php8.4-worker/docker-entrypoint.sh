#!/bin/bash
# =============================================================================
# Docker Entrypoint - Laravel Worker
# =============================================================================
# Substitui variáveis de ambiente na configuração do Supervisor
# =============================================================================

set -e

# Substituir variáveis de ambiente no arquivo de configuração do worker
if [ -f /etc/supervisor/conf.d/worker.conf ]; then
    sed -i "s|\${WORKER_QUEUE}|${WORKER_QUEUE:-default}|g" /etc/supervisor/conf.d/worker.conf
    sed -i "s|\${WORKER_TRIES}|${WORKER_TRIES:-3}|g" /etc/supervisor/conf.d/worker.conf
    sed -i "s|\${WORKER_TIMEOUT}|${WORKER_TIMEOUT:-90}|g" /etc/supervisor/conf.d/worker.conf
    sed -i "s|\${WORKER_SLEEP}|${WORKER_SLEEP:-3}|g" /etc/supervisor/conf.d/worker.conf
    sed -i "s|\${WORKER_MAX_JOBS}|${WORKER_MAX_JOBS:-1000}|g" /etc/supervisor/conf.d/worker.conf
    sed -i "s|\${WORKER_MAX_TIME}|${WORKER_MAX_TIME:-3600}|g" /etc/supervisor/conf.d/worker.conf
    sed -i "s|\${WORKER_MEMORY}|${WORKER_MEMORY:-128}|g" /etc/supervisor/conf.d/worker.conf
    sed -i "s|\${WORKER_NUMPROCS}|${WORKER_NUMPROCS:-2}|g" /etc/supervisor/conf.d/worker.conf
fi

# Executar comando passado
exec "$@"
