include flink-env.env

PLATFORM ?= linux/amd64

# COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)


TARGET_MAX_CHAR_NUM=20

## Show help with `make help`
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)


.PHONY: db-init
## Builds and runs the PostgreSQL database service
db-init:
	docker-compose up -d postgres

.PHONY: build
## Builds the Flink base image with pyFlink and connectors installed
build:
	docker build --platform ${PLATFORM} -t ${IMAGE_NAME} .

.PHONY: up
## Builds the base Docker image and starts Flink cluster
up:
	docker compose --env-file flink-env.env up --build --remove-orphans  -d

.PHONY: down
## Shuts down the Flink cluster
down:
	docker compose down --remove-orphans

.PHONY: job
## Submit the Flink job
job:
	docker-compose exec jobmanager ./bin/flink run -py /opt/job/start_job.py -d

.PHONY: stop
## Stops all services in Docker compose
stop:
	docker compose stop

.PHONY: start
## Starts all services in Docker compose
start:
	docker compose start

.PHONY: clean
## Stops and removes the Docker container as well as images with tag `<none>`
clean:
	docker compose stop
	docker ps -a --format '{{.Names}}' | grep "^${CONTAINER_PREFIX}" | xargs -I {} docker rm {}
	docker images | grep "<none>" | awk '{print $3}' | xargs -r docker rmi
	# Uncomment line `docker rmi` if you want to remove the Docker image from this set up too
	# docker rmi ${IMAGE_NAME}

.PHONY: psql
## Runs psql to query containerized postgreSQL database in CLI
psql:
	docker exec -it ${CONTAINER_PREFIX}-postgres \
    	psql -U postgres -d postgres

.PHONY: postgres-die-mac
## Removes mounted postgres data dir on local machine (mac users) and in Docker
postgres-die-mac:
	rm -r ./postgres-data && docker compose down && docker rmi apache-flink-training-postgres:latest

.PHONY: postgres-die-pc
## Removes mounted postgres data dir on local machine (PC users) and in Docker
postgres-die-pc:
	docker compose down && rmdir /s postgres-data && docker rmi apache-flink-training-postgres:latest
