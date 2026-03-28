#!/usr/bin/env bash
set -euo pipefail

APP_DIR="/var/www"

if [ ! -f "$APP_DIR/.initialized" ]; then
  echo "==> Initializing Laravel in $APP_DIR"
  mkdir -p "$APP_DIR"
  cd "$APP_DIR"

  # Clean any leftover files from a previous failed init
  find "$APP_DIR" -mindepth 1 -delete

  # Empty LARAVEL_VERSION means latest stable
  if [ -n "${LARAVEL_VERSION:-}" ]; then
    PACKAGE="laravel/laravel:${LARAVEL_VERSION}"
  else
    PACKAGE="laravel/laravel"
  fi

  composer create-project "$PACKAGE" . --no-interaction --no-progress

  composer require --dev nunomaduro/larastan --no-interaction --no-progress

  # Remove Laravel's auto-generated compose files (we provide our own)
  rm -f compose.yaml compose.yml docker-compose.yml docker-compose.yaml

  # Copy standalone Docker setup into the app
  cp -r /docker-app/. .

  # Generate application key
  php artisan key:generate

  # Create SQLite database and run migrations
  touch database/database.sqlite
  php artisan migrate --force

  # Fix permissions
  chown -R www-data:www-data storage bootstrap/cache database

  touch /var/www/.initialized
  echo "==> Laravel initialized successfully"
fi

exec "$@"
