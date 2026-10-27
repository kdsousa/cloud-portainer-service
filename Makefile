# ==============================================================================
# CONFIGURAÇÕES DE AMBIENTE
# ==============================================================================
# Carrega as variáveis do arquivo .env se ele existir localmente
-include .env

# Variáveis com valores padrão (podem ser sobrescritas no .env ou via terminal)
SERVER      ?= usuario@ip_ou_dominio_do_servidor
KEY         ?= ~/.ssh/sua_chave.pem
REMOTE_PATH ?= ~/portainer-service

# Nome do projeto extraído automaticamente da pasta atual
PROJECT_NAME := $(shell basename $(shell pwd))

.PHONY: help rsync setup deploy logs status stop down

# ==============================================================================
# COMANDOS PRINCIPAIS
# ==============================================================================

## help: Exibe esta lista de comandos e descrições
help:
	@echo "Uso: make [comando]"
	@echo ""
	@echo "Comandos disponíveis:"
	@sed -n 's/^##//p' $(MAKEFILE_LIST) | column -t -s ':'

## rsync: Sincroniza os arquivos locais com o servidor remoto (exceto sensíveis/temporários)
rsync:
	@echo "--> Sincronizando arquivos com o servidor remoto..."
	rsync -azv \
		--exclude '.git*' \
		--exclude '.env' \
		-e "ssh -i $(KEY)" . $(SERVER):$(REMOTE_PATH)

## setup: Configuração inicial no servidor (garante diretório remoto e sobe a stack)
setup: rsync
	@echo "--> Executando setup inicial do Portainer no servidor..."
	ssh -i $(KEY) $(SERVER) "\
		mkdir -p $(REMOTE_PATH) && \
		cd $(REMOTE_PATH) && \
		docker compose up -d"

## deploy: Sincroniza arquivos e reinicia os containers no servidor
deploy: rsync
	@echo "--> Atualizando aplicação no servidor..."
	ssh -i $(KEY) $(SERVER) "\
		cd $(REMOTE_PATH) && \
		docker compose down && \
		docker compose up -d"

## logs: Exibe os logs em tempo real do Portainer no servidor
logs:
	ssh -i $(KEY) $(SERVER) "docker logs portainer -f --tail 100"

## status: Mostra o estado dos containers e recursos do projeto no servidor
status:
	ssh -i $(KEY) $(SERVER) "cd $(REMOTE_PATH) && docker compose ps"

## stop: Interrompe os containers sem removê-los
stop:
	@echo "--> Parando os containers no servidor..."
	ssh -i $(KEY) $(SERVER) "cd $(REMOTE_PATH) && docker compose stop"

## down: Para e remove os containers da stack no servidor
down:
	@echo "--> Removendo a stack do Portainer no servidor..."
	ssh -i $(KEY) $(SERVER) "cd $(REMOTE_PATH) && docker compose down"