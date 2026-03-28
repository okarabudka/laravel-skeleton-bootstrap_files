# Makefile

SHELL = /bin/bash

ifndef VERBOSE
MAKEFLAGS += --no-print-directory
endif

help:
	@printf '\t\t'
	@make print-color-blue TEXT='** Available commands **\n\n'
	@make print-color-green TEXT='up-containers'
	@printf '\t\tstart containers (bootstraps Laravel on first run)\n'
	@make print-color-green TEXT='down'
	@printf '\t\tstop containers\n'
	@make print-color-green TEXT='reset'
	@printf '\t\tdestroy volume and re-bootstrap Laravel from scratch\n'
	@make print-color-green TEXT='logs'
	@printf '\t\tshow container logs\n'
	@make print-color-green TEXT='bash'
	@printf '\t\topen shell in app container\n'
	@make print-color-green TEXT='composer'
	@printf '\t\trun composer command (ARGS="require foo")\n'
	@make print-color-green TEXT='artisan'
	@printf '\t\trun artisan command (ARGS="make:model Foo")\n'
	@make print-color-green TEXT='migrate'
	@printf '\t\trun database migrations\n'
	@make print-color-green TEXT='test'
	@printf '\t\trun PHPUnit via artisan\n'
	@make print-color-green TEXT='lint'
	@printf '\t\tPHP syntax check\n'
	@make print-color-green TEXT='phpstan'
	@printf '\t\tstatic analysis\n'
	@make print-color-green TEXT='export-app'
	@printf '\t\tcopy generated app to ./app\n'
	@make print-color-green TEXT='finalize'
	@printf '\t\treplace repo with generated app and remove bootstrap files\n'

up-containers:
	@make docker-compose-exec COMPOSE_CMD="up -d --build"

down:
	@make docker-compose-exec COMPOSE_CMD="down"

reset:
	@make docker-compose-exec COMPOSE_CMD="down"
	@docker volume rm $$(docker compose config 2>/dev/null | awk '/^name:/ {print $$2 "_app_data"}') 2>/dev/null || true
	@make docker-compose-exec COMPOSE_CMD="up -d --build"

logs:
	@make docker-compose-exec COMPOSE_CMD="logs -f --tail=200"

composer:
	@make docker-exec CONTAINER="app" CONTAINER_CMD='bash -c "composer $(ARGS)"'

artisan:
	@make docker-exec CONTAINER="app" CONTAINER_CMD='bash -c "php artisan $(ARGS)"'

bash:
	@make docker-exec CONTAINER="app" CONTAINER_CMD='bash'

migrate:
	@make docker-exec CONTAINER="app" CONTAINER_CMD='bash -c "php artisan migrate"'

test:
	@make docker-exec CONTAINER="app" CONTAINER_CMD='bash -c "php artisan test"'

lint:
	@make docker-exec CONTAINER="app" CONTAINER_CMD='bash -c "find app tests -name \"*.php\" -print0 | xargs -0 -n1 php -l"'

phpstan:
	@make docker-exec CONTAINER="app" CONTAINER_CMD='bash -c "vendor/bin/phpstan analyse"'

export-app:
	@mkdir -p app
	@docker compose run --rm --entrypoint sh \
		-v "$$(pwd)/app:/export" app \
		-c "cp -a /var/www/. /export && rm -f /export/.initialized && chown -R $$(id -u):$$(id -g) /export"

finalize:
	@bash scripts/finalize.sh

docker-exec:
	@docker compose exec $(CONTAINER) $(CONTAINER_CMD)

docker-compose-exec:
	@docker compose $(COMPOSE_CMD)

print-color-green:
	@printf '\033[0;32m${TEXT}\033[0m'

print-color-blue:
	@printf '\033[0;36m${TEXT}\033[0m'
