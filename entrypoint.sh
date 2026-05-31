#!/bin/sh

# Verifica se as variaveis foram passadas, se utiliza os valores padrão.
USER_NAME=${USERNAME:-opencode}
USER_ID=${USER_UID:-1000}
GROUP_ID=${USER_GID:-1000}
WORKSPACE_NAME=${WORKSPACE:-workspace}
HOME_PATH="/home/$USER_NAME"

# Cria o grupo se ele não existir
if ! grep -q "^$USER_NAME:" /etc/group; then
    addgroup -g "$GROUP_ID" "$USER_NAME"
fi

# Cria o usuário se ele não existir
if ! grep -q "^$USER_NAME:" /etc/passwd; then
    adduser -D -u "$USER_ID" -G "$USER_NAME" -h "$HOME_PATH" -s /bin/sh "$USER_NAME"
fi

# Garante que as pastas de configuração do OpenCode existem
mkdir -p "$HOME_PATH/$WORKSPACE_NAME" \
         "$HOME_PATH/.local/share/opencode" \
         "$HOME_PATH/.config/opencode" \
         "$HOME_PATH/.local/state/opencode"

# Garante que o novo usuário é o dono absoluto do seu diretório home
chown -R "$USER_NAME:$USER_NAME" "$HOME_PATH"

# Executa o comando passado no CMD (opencode web...) MAS cortando os privilégios de root
# e assumindo a identidade do usuário recém-criado
exec su-exec "$USER_NAME" "$@"
