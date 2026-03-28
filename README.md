# laravel-skeleton-bootstrap

Infrastructure-only repository that bootstraps a fresh Laravel project on first container start.
No Laravel source files are stored in git — the app lives in a Docker named volume.

## How it works

1. `make up-containers` — Docker builds the image and starts containers. On first run, `composer create-project laravel/laravel` is executed inside the container. This takes **2–4 minutes**. Use `make logs` to follow progress.
2. Once healthy, the app is available at [http://localhost:8080](http://localhost:8080).
3. `make export-app` — copies the generated app to `./app/` with correct file ownership.
4. `make finalize` — **one-way**: replaces the repo root with the generated app and removes all bootstrap files.

## Quick start

```bash
make up-containers   # bootstrap (first run takes 2–4 min)
make logs            # follow progress
```

## Commands

| Command | Description |
|---|---|
| `make up-containers` | Start containers (bootstrap on first run) |
| `make down` | Stop containers |
| `make reset` | Destroy volume and re-bootstrap from scratch |
| `make logs` | Follow container logs |
| `make bash` | Open shell in app container |
| `make composer ARGS="require foo"` | Run composer |
| `make artisan ARGS="make:model Foo"` | Run artisan |
| `make migrate` | Run database migrations |
| `make test` | Run tests |
| `make lint` | PHP syntax check |
| `make phpstan` | Static analysis |
| `make export-app` | Copy generated app to `./app/` |
| `make finalize` | **One-way**: replace repo with generated app |

## Optional services

Start with Docker Compose profiles:

```bash
docker compose --profile mysql up -d     # MySQL 8.4
docker compose --profile mail up -d      # Mailpit (http://localhost:8025)
docker compose --profile cache up -d     # Redis
docker compose --profile node up -d      # Node.js 22
```

## Pin a specific Laravel version

```bash
LARAVEL_VERSION=11.* make up-containers
```

> Note: version pinning only applies on first run (empty volume). Use `make reset` to re-bootstrap with a different version.

## Switch to MySQL

1. Start the mysql profile: `docker compose --profile mysql up -d`
2. `make bash` and update `.env`:
   ```
   DB_CONNECTION=mysql
   DB_HOST=mysql
   DB_PORT=3306
   DB_DATABASE=laravel
   DB_USERNAME=laravel
   DB_PASSWORD=secret
   ```
3. `make migrate`

## Finalize

When ready to start building your app:

```bash
make export-app   # preview in ./app/
make finalize     # one-way, asks for confirmation
```

After `finalize`, the repo contains only the Laravel app with its own `Dockerfile`, `docker-compose.yml`, and GitHub Actions CI. The bootstrap files are gone.
