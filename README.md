# Portainer Service with Traefik Integration

Este projeto disponibiliza o painel de gerenciamento do [Portainer CE](https://www.portainer.io/) utilizando Docker Compose, integrado ao reverse proxy [cloud-traefik-gateway](https://github.com/kdsousa/cloud-traefik-gateway) para roteamento e gerenciamento automático de certificados SSL/TLS.

---

## 📌 Pré-requisitos

1. **Rede Docker Compartilhada**:
   A rede externa `traefik` precisa estar criada e em execução no servidor. Esta rede é mantida pelo repositório [cloud-traefik-gateway](https://github.com/kdsousa/cloud-traefik-gateway).

   Caso precise criá-la manualmente antes de subir a stack:
   ```bash
   docker network create traefik
   ```

2. **DNS Configurado**:
   O apontamento DNS do subdomínio deve estar direcionado para o IP do seu servidor onde o Traefik está rodando.

---

## 🚀 Como Executar

### Implantação Automatizada (via Makefile)

O projeto conta com um `Makefile` configurado para sincronizar os arquivos via `rsync` e reiniciar o container no servidor remoto:

```bash
make deploy
```

---

## ⚙️ Estrutura do Projeto

* `docker-compose.yml`: Define o serviço do Portainer CE, volume persistente, conexão à rede `traefik` e labels de roteamento HTTP/HTTPS.
* `Makefile`: Automação do processo de deploy remoto via SSH e rsync.