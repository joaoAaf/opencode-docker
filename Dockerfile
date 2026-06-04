FROM node:lts-alpine3.23

# DELETA o usuário "node" para liberar o UID e GID 1000
RUN deluser node

# Instala as dependências de sistema essenciais para o OpenCode
RUN apk update && apk add --no-cache \
    bash \
    curl \
    git \
    openssh-client \
    ca-certificates \
    su-exec

# Instalação dos pacotes customizados definidos pelo usuário
ARG CUSTOM_PACKAGES=""

COPY install-packages.sh /usr/local/bin/install-packages.sh
RUN chmod +x /usr/local/bin/install-packages.sh && \
    /usr/local/bin/install-packages.sh "$CUSTOM_PACKAGES"

# Instala o OpenCode globalmente
RUN npm install -g opencode-ai

# Copia o script de entrypoint para dentro do container e dá permissão de execução
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Variáveis padrão (podem ser sobrescritas no docker run)
ENV OPENCODE_SERVER_PASSWORD="admin" \
    OPENCODE_SERVER_USERNAME="opencode" \
    PORT=4096

EXPOSE 4096

# Define o entrypoint. O container sempre vai rodar este script primeiro como root.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# O CMD é repassado para o entrypoint.sh na variável "$@"
CMD ["opencode", "web", "--hostname", "0.0.0.0", "--port", "4096"]
