# OpenClaw Docker (Producao) - v2026.2.26

Projeto Docker pronto para deploy em Linux com **OpenClaw fixo na versao `2026.2.26`**, persistencia de dados e scripts operacionais.

## Estrutura

- `Dockerfile`
- `docker-compose.yml`
- `.env.example`
- `docker/bootstrap.sh`
- `docker/healthcheck.sh`
- `scripts/deploy.sh`
- `scripts/update.sh`
- `scripts/backup.sh`

## Pre-requisitos

- Linux x86_64 com Docker Engine e Docker Compose plugin (`docker compose`)
- Acesso a internet para build da imagem
- Porta `18789` liberada no servidor (ou ajustar em `.env`)

## Como rodar (local ou servidor)

1. Clone o repositorio e entre na pasta.
2. Crie o arquivo de ambiente:

```bash
cp .env.example .env
```

3. Suba o servico:

```bash
./scripts/deploy.sh up
```

## Validacao da instalacao

Executar:

```bash
docker compose exec -T openclaw-gateway openclaw --version
docker compose exec -T openclaw-gateway openclaw status
docker compose ps
```

Resultado esperado:

- `openclaw --version` retorna `2026.2.26`
- `openclaw status` sem erro
- container `openclaw-gateway` em `healthy`

## Persistencia de dados

Todos os dados criticos ficam em `./data/openclaw` (host) montado em `/home/node/.openclaw` (container).

Paths persistidos (explicitos):

- `./data/openclaw/openclaw.json` (config)
- `./data/openclaw/state/` (estado)
- `./data/openclaw/sessions/` (sessoes)
- `./data/openclaw/memory/` (memoria)
- `./data/openclaw/logs/` (logs)
- `./data/openclaw/workspace/` (workspace/artefatos)

Teste de persistencia:

```bash
docker compose down
docker compose up -d
```

Os dados permanecem em `./data/openclaw`.

## Operacao

Subir ou recriar:

```bash
./scripts/deploy.sh up
```

Restart seguro (recreate do servico sem derrubar stack inteira):

```bash
./scripts/deploy.sh restart
```

Status operacional:

```bash
./scripts/deploy.sh status
```

Backup basico:

```bash
./scripts/backup.sh
```

O arquivo sai em `./backups/openclaw_data_YYYYMMDD_HHMMSS.tar.gz`.

## Atualizacao de versao

### Atualizar mantendo versao atual do `.env`

```bash
./scripts/update.sh
```

### Atualizar para nova versao

```bash
./scripts/update.sh 2026.3.10
```

Isso atualiza `OPENCLAW_VERSION` e `OPENCLAW_IMAGE_NAME` no `.env`, rebuilda a imagem e recria o container.

## Rollback

1. Defina a versao anterior no `.env` (`OPENCLAW_VERSION` e `OPENCLAW_IMAGE_NAME`).
2. Reaplique:

```bash
./scripts/update.sh
```

3. Valide:

```bash
docker compose exec -T openclaw-gateway openclaw --version
docker compose exec -T openclaw-gateway openclaw status
```

## Rede Docker

Por padrao, a rede `openclaw-net` e criada automaticamente (`OPENCLAW_NETWORK_EXTERNAL=false`).

Para usar rede externa existente:

1. No `.env`, configure:

```dotenv
OPENCLAW_NETWORK_EXTERNAL=true
OPENCLAW_NETWORK_NAME=minha-rede-existente
```

2. Garanta que a rede ja exista:

```bash
docker network ls | grep minha-rede-existente
```

## Troubleshooting

Logs do servico:

```bash
docker compose logs -f openclaw-gateway
```

Healthcheck:

```bash
docker inspect --format='{{json .State.Health}}' openclaw-gateway
```

Se `openclaw status` falhar:

- verificar versao: `docker compose exec -T openclaw-gateway openclaw --version`
- verificar config em `./data/openclaw/openclaw.json`
- recriar servico: `./scripts/deploy.sh restart`

Se aparecer `Permission denied` em `/home/node/.openclaw/*`:

- ajustar owner no host Linux: `sudo chown -R 1000:1000 data/openclaw`
- ajustar permissoes: `sudo chmod -R u+rwX,go-rwx data/openclaw`
- subir novamente: `./scripts/deploy.sh up`

## Publicar no GitHub

```bash
git init
git add .
git commit -m "chore: production docker setup for OpenClaw 2026.2.26"
git branch -M main
git remote add origin <URL_DO_REPOSITORIO>
git push -u origin main
```

## Decisoes tecnicas

- **Versao travada** por `ARG OPENCLAW_VERSION` no build e validacao explicita com `openclaw --version` para impedir fallback silencioso.
- **Persistencia centralizada** em `./data/openclaw` para backup/restauracao simples e previsivel.
- **Healthcheck duplo** (`openclaw status` + HTTP local) para detectar erro de processo e erro de gateway.
- **`restart: unless-stopped`** para comportamento estavel de producao apos reboot do host.
