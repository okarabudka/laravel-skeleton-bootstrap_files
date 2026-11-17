# Laravel-Skeleton-Bootstrap

An infrastructure-only repository that creates a fresh Laravel project inside Docker on first start and can then hand it over as a plain Laravel repository.

## Context

A personal starter template built by Oleksandr Karabudka in March 2026, as the Laravel counterpart of the Symfony bootstrap repository. The idea: no framework source code is kept in git; the current Laravel version is installed with Composer when the container starts for the first time, so a new project always begins from an up-to-date skeleton with a ready Docker setup, static analysis and CI.

## Features

- First start runs `composer create-project laravel/laravel` inside the `app` container (latest stable, or a pinned version via `LARAVEL_VERSION`).
- Automatic setup after install: Larastan as a dev dependency, application key, SQLite database file and migrations, file permissions.
- Health check on an `.initialized` marker; nginx starts only after the app is ready.
- Optional services through Docker Compose profiles: MySQL 8.4, Mailpit, Redis, Node.js 22.
- Makefile commands for Composer, Artisan, migrations, tests, syntax check and PHPStan.
- `make export-app` copies the generated app to `./app/` for review.
- `make finalize` (one-way, asks for confirmation) replaces the repository content with the generated app, which then contains its own `Dockerfile`, `docker-compose.yml`, PHPStan config and GitHub Actions CI.

## Tech stack

- PHP 8.4 (FPM) with pdo_mysql, pdo_sqlite, gd, intl, opcache, zip, bcmath; Composer 2
- Laravel (latest stable by default), Larastan / PHPStan
- nginx, SQLite (default), optional MySQL 8.4, Redis, Mailpit, Node.js 22
- Docker Compose, Makefile, Bash
- GitHub Actions (CI template for the generated app)

## Architecture

- `Dockerfile` builds the PHP image with dev and OPcache settings baked in; its entrypoint `docker/entrypoint/init-laravel.sh` bootstraps Laravel into the `app_data` named volume on first run and then starts PHP-FPM.
- `docker/nginx` builds the web server image that serves the same volume.
- `docker-app/` holds the files that are copied into the generated app: a standalone `Dockerfile`, `docker-compose.yml`, nginx config, `phpstan.neon` (level 5) and `.github/workflows/ci.yml` (composer validate, migrations on SQLite, PHPStan, tests).
- `scripts/finalize.sh` exports the app from the volume with host file ownership, checks that it is a Laravel app (`artisan` exists), removes all bootstrap files and copies the app to the repository root.

## Getting started

Requires Docker, Docker Compose and make.

```bash
make up-containers   # build and start; first run installs Laravel (2 to 4 minutes)
make logs            # follow progress
```

Open http://localhost:8080 (port configurable with `APP_PORT`).

Pin a Laravel version on the first run (or after `make reset`):

```bash
LARAVEL_VERSION=11.* make up-containers
```

Optional services:

```bash
docker compose --profile mysql up -d   # MySQL 8.4
docker compose --profile mail up -d    # Mailpit (http://localhost:8025)
docker compose --profile cache up -d   # Redis
docker compose --profile node up -d    # Node.js 22
```

To switch to MySQL, start the `mysql` profile, open a shell with `make bash`, set `DB_CONNECTION=mysql`, `DB_HOST=mysql`, `DB_PORT=3306`, `DB_DATABASE`, `DB_USERNAME` and `DB_PASSWORD` in `.env` (defaults in `docker-compose.yml`), then run `make migrate`.

Other commands: `make down`, `make reset` (delete the volume and bootstrap again), `make bash`, `make composer ARGS="require foo"`, `make artisan ARGS="make:model Foo"`, `make help`.

When ready to build the actual project:

```bash
make export-app   # preview the app in ./app/
make finalize     # one-way: replace the repository with the generated app
```

## Testing

The repository itself has no tests. For the generated app:

```bash
make test      # php artisan test
make lint      # php -l on app/ and tests/
make phpstan   # PHPStan with Larastan
```

After `finalize`, the same checks run in GitHub Actions.

## Status

Personal starter template, created in March 2026 and not changed since.

## License

MIT, see [LICENSE](LICENSE).
