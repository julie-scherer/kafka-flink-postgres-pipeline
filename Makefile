include flink-env.env

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


.PHONY: up
## Builds the base Docker image and starts Flink cluster
up:
	docker compose --env-file flink-env.env up --build --remove-orphans  -d

.PHONY: down
## Shuts down the Flink cluster
down:
	docker compose down

.PHONY: job
## Submit the Flink job
job:
	docker-compose exec jobmanager ./bin/flink run -py /opt/job/start_job.py -d

.PHONY: clean
## Removes Docker container and image from this set up
clean:
	docker rmi ${IMAGE_NAME}
	docker rm ${CONTAINER_PREFIX}

.PHONY: psql
psql:
	docker exec -it postgres-container \
    	psql -U postgres -d postgres
