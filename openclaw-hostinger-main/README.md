# OpenClaw Hostinger (Docker Compose)

Projeto pronto para subir no GitHub e instalar na Hostinger usando arquivo `.yml`.

## Arquivos

- `docker-compose.yml`: stack principal com `openclaw` + `sandbox`.
- `.env.example`: variaveis de ambiente base.

## 1) Publicar no GitHub

```bash
git init
git add .
git commit -m "feat: openclaw hostinger compose"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/openclaw-hostinger-main.git
git push -u origin main
```

## 2) Preparar servidor Hostinger (VPS)

```bash
cd /opt
git clone https://github.com/SEU_USUARIO/openclaw-hostinger-main.git
cd openclaw-hostinger-main
cp .env.example .env
mkdir -p data
```

Edite o token no `.env`:

```bash
nano .env
```

Troque `OPENCLAW_GATEWAY_TOKEN` por um valor forte.

## 3) Subir com Docker Compose

```bash
docker compose pull
docker compose up -d
```

## 4) Acessar

- Gateway: `http://IP_DO_SERVIDOR:18789`
- Canvas Host: `http://IP_DO_SERVIDOR:18793`

## 5) Primeiro onboarding

Configure OpenClaw dentro do container:

```bash
docker exec -it openclaw openclaw configure
```

## Comandos uteis

```bash
docker compose logs -f
docker compose restart
docker compose down
```

## Observacoes

- Este projeto foi baseado no `openclaw-docker-main` e simplificado para deploy rapido na Hostinger.
- O bind de `/var/run/docker.sock` esta habilitado para recursos avancados do OpenClaw.
- Em producao, use firewall para liberar apenas portas necessarias.