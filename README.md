# OPSFLOW (Microservices + JWT + Sidekiq + Redis)

Projeto didático para demonstrar **comunicação entre microserviços Rails**, autenticação via **JWT**, e processamento assíncrono com **Sidekiq + Redis**.

## Visão geral

Fluxo principal (MVP):

1. **auth-service** cria usuário e faz login → retorna um **JWT**
2. **intent-service** recebe uma intenção (`text`) do usuário autenticado
3. **planner-service** recebe um request `/plans/from_intent`, enfileira um job no **Redis**
4. **Sidekiq (planner-service)** consome o job e:
   - cria um **Workflow** no **process-service**
   - cria uma **Task "done"** no **task-service**

Resultado: você consegue provar com `curl` que existe uma **task concluída** gerada automaticamente.

---

## Serviços e portas

- **auth-service** → `http://localhost:3001`
- **intent-service** → `http://localhost:3002`
- **planner-service** → `http://localhost:3003`
- **process-service** → `http://localhost:3004`
- **task-service** → `http://localhost:3005`

Infra (Docker Compose):

- Redis → `localhost:6380`
- Postgres:
  - auth_db → `5433`
  - intent_db → `5434`
  - process_db → `5435`
  - task_db → `5436`

---

## Pré-requisitos

- Ruby + Bundler (compatível com Rails 8)
- Docker + Docker Compose
- `redis-cli` e `psql` (opcional, mas ajuda no debug)

---

## Setup rápido

### 1) Subir infraestrutura (Redis + Postgres)

Na raiz do projeto:

```bash
docker compose up -d
docker ps
