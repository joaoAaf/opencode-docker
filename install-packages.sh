#!/bin/sh

# install-packages.sh - Instala pacotes customizáveis para o OpenCode Docker
# Recebe a lista de pacotes como argumento (separados por vírgula)
# Uso: ./install-packages.sh "openjdk21-jdk,maven"

set -e

PACKAGES="$1"

# Verifica se a variável está vazia ou contém apenas espaços
if [ -z "$(echo "$PACKAGES" | tr -d '[:space:]')" ]; then
    echo ">>> Nenhum pacote customizado definido. Pulando instalação."
    exit 0
fi

# Converte vírgulas em espaços e instala os pacotes
# Se algum pacote falhar, o build será interrompido com erro
echo ">>> Instalando pacotes customizados: $PACKAGES"
apk add --no-cache $(echo "$PACKAGES" | tr ',' ' ')

echo ">>> Pacotes customizados instalados com sucesso."
