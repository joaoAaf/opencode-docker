# 🐳 OpenCode Docker Agent

> Agente de IA OpenCode executado em ambiente Docker isolado, com integração nativa via protocolo ACP e suporte a provedores locais (LM Studio, Ollama, etc.).

## 🎯 Objetivo

Este projeto tem como objetivo executar o agente **OpenCode AI** de forma totalmente isolada em um container Docker, garantindo comunicação bidirecional com IDEs locais via protocolo **ACP (Agent Client Protocol)**. A solução permite configurações personalizadas (como integração com LM Studio/Ollama) e resolve o desafio crítico de mapeamento de caminhos absolutos, fazendo com que o container e a máquina hospedeira compartilhem exatamente a mesma estrutura de diretórios, permissões de usuário e visibilidade de arquivos.

## 📋 Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) & [Docker Compose](https://docs.docker.com/compose/) (≥20.10 para suporte a `host-gateway`)
- [Git](https://git-scm.com/)
- IDE com suporte a ACP
- LM Studio, Ollama ou servidor LLM local (opcional, para uso com modelos locais)
- OS Linux, macOS ou WSL.

## 🚀 Instalação e Execução

### 1. Estrutura do Projeto
Certifique-se de que os seguintes arquivos estejam na mesma pasta:
```
📁 projeto-opencode/
 ├── 📄 Dockerfile
 ├── 📄 entrypoint.sh
 ├── 📄 docker-compose.yml
 ├── 📄 .env.example
 └── 📄 README.md
```

### 2. Configuração do Ambiente
Crie o arquivo `.env` na raiz do projeto e ajuste com os dados do seu usuário host:
```env
# Configurações do Usuário                                                                                                                            
HOST_USER=fulano                                                                                                                                      
HOST_UID=1000                                                                                                                                         
HOST_GID=1000                                                                                                                                         
                                                                                                                                                      
# Caminho absoluto da pasta dos seus projetos na máquina hospedeira                                                                                   
WORKSPACE_PATH=/home/fulano/projetos                                                                                                                  
WORKSPACE_NAME=projetos                                                                                                                               
                                                                                                                                                      
# Caminho para arquivo de configurações personalizadas do OpenCode (Opcional)                                                                         
CUSTOM_CONFIG_PATH=/home/fulano/configs                                                                                                               
                                                                                                                                                      
# Usuário e senha do servidor web do OpenCode                                                                                                       > 
OPENCODE_SERVER_USERNAME=opencode                                                                                                                   > 
OPENCODE_SERVER_PASSWORD=admin 
```
💡 *Dica:* Descubra seu UID/GID com `id -u` e `id -g`.

### 3. Configuração do Provedor LLM
Edite o `opencode.json` para apontar para seu provedor local. Exemplo para LM Studio:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "local-model-name",
  "provider": {
    "lmstudio": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LM Studio",
      "options": {
        "baseURL": "http://host.docker.internal:1234/v1"
      }
    }
  }
}
```
📌 **Importante:** O container não enxerga `127.0.0.1`. Use sempre `host.docker.internal` e garanta que o LM Studio esteja escutando em `0.0.0.0` (não `127.0.0.1`).

### 4. Build e Inicialização
```bash
# Constrói a imagem e sobe o container em segundo plano
docker compose up -d --build

# Acompanha os logs
docker compose logs -f
```

### 5. Acesso à Interface Web
Abra no navegador: `http://localhost:4096`  
Credenciais padrão: `opencode` / `admin` (altere via variáveis de ambiente ou `.env`).

---

## 🔌 Integração com IDEs (Protocolo ACP)

O protocolo ACP requer que a IDE execute o agente via `docker exec -i opencode opencode acp`. Configure o comando de acordo com sua IDE. Para mais detalhes consulte [Suporte ACP](https://opencode.ai/docs/pt-br/acp/).

📌 **Importante:** ⚠️ Não utilize a flag -t. O protocolo ACP utiliza JSON-RPC e o pseudo-terminal quebra a comunicação.

### Visual Studio Code
Instale a extensão **ACP Client** e adicione ao `settings.json`:
```json
"acp.agents": {
  "OpenCode-Docker": {
    "command": "docker",
    "args": ["exec", "-i", "opencode", "opencode", "acp"],
    "description": "OpenCode rodando via Docker"
  }
}
```

### Zed
Crie ou edite `acp.json` na raiz do projeto (ou `~/.config/zed/zed.json`):
```json
{
  "agent_servers": {
    "OpenCode-Docker": {
      "command": "docker",
      "args": ["exec", "-i", "opencode", "opencode", "acp"],
      "description": "OpenCode rodando via Docker"
    }
  }
}
```

---

## 🛠️ Solução de Problemas Comuns

| Problema | Causa Provável | Solução |
|----------|----------------|---------|
| ACP retorna `File not found` | Caminho absoluto diferente entre host e container | Verifique se `WORKSPACE_ABSOLUTE_PATH` no `.env` é **exatamente igual** ao caminho que a IDE usa. O bind mount deve ser espelhado. |
| Container não encontra LM Studio/Ollama | Rede Docker isolada ou firewall bloqueando | 1. Garanta que `extra_hosts` está no `docker-compose.yml`.<br>2. No LM Studio, mude o host do servidor para `0.0.0.0` e reinicie.<br>3. Verifique firewall/portas. |
| `Permission denied` ao editar arquivos | UID/GID do container diferente do host | Confirme que `HOST_UID` e `HOST_GID` no `.env` correspondem ao seu usuário (`id -u` / `id -g`). |
| Porta 4096 já em uso | Conflito com outro serviço local | Altere o mapeamento no `docker-compose.yml` para `4097:4096` e acesse `http://localhost:4097`. |
| `host.docker.internal` não resolve | Versão do Docker/Compose antiga ou falta de `extra_hosts` | Atualize Docker Engine ≥20.10 e garanta que `extra_hosts: ["host.docker.internal:host-gateway"]` está no compose. |

---

## 📦 Manutenção do Ambiente

```bash
# Parar sem destruir volumes
docker compose stop

# Parar e destruir containers (volumes mantidos)
docker compose down

# Reconstruir e subir do zero
docker compose down -v && docker compose up -d --build

# Acessar shell interativo no container
docker exec -it opencode sh
```

---

## 📄 Licença & Contribuição

Este projeto é distribuído sob licença MIT.

Ajustes em permissões, rotas de rede ou variáveis de ambiente podem ser necessários conforme o ambiente host.

Para dúvidas ou sugestões, abra uma issue ou consulte a documentação oficial do [OpenCode AI](https://opencode.ai/docs).

---
