include flink-env.env

CONTAINER_NAME ?= apache-flink-training
IMAGE_NAME ?= kafka-flink-postgres:latest

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


## Builds the base Docker image and starts Flink cluster
up: ./Dockerfile
	docker compose --env-file flink-env.env up --build --remove-orphans  -d

## Shuts down the Flink cluster
down: ./Dockerfile
	docker compose down

## Submit the Flink job
job: ./Dockerfile
	docker-compose exec jobmanager ./bin/flink run -py /opt/job/start_job.py -d

## Removes Docker container and image from this set up
clean: ./Dockerfile
	docker rmi ${IMAGE_NAME}
	docker rm ${CONTAINER_NAME}
