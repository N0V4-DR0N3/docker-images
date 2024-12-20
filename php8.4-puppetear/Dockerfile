FROM websolusoficial/php:8.4-horizon

USER root

# Adicionar chave e repositório do Google Chrome
RUN apt-get update && apt-get install -y wget gnupg2 \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list

# Instalar Google Chrome, fontes e dependências
RUN apt-get update && apt-get install -yqq --no-install-recommends \
    google-chrome-stable \
    fonts-liberation \
    fonts-roboto \
    fonts-dejavu \
    fonts-dejavu-core \
    fonts-dejavu-extra \
    fonts-noto \
    fonts-freefont-ttf \
    fontconfig \
    libxss1 \
    libxtst6 \
    xdg-utils \
    libgconf-2-4 \
    libnss3 \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libgdk-pixbuf2.0-0 \
    libgtk-3-0 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoclean

# Configurar variáveis de ambiente para o Chrome
ENV CHROME_BIN=/usr/bin/google-chrome \
    CHROME_PATH=/usr/lib/google-chrome/

# Verificar versão do Chrome instalada
RUN google-chrome --version

# Configurar permissões
RUN mkdir -p /home/php/.cache/puppeteer \
    && chown -R php:php /home/php/.cache

USER php

# Manter o comando original do Horizon
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
