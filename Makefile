include .env

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
	@echo "Building Docker image and starting Flink cluster..."
	@docker compose --env-file .env up --build --remove-orphans -d
	@echo "Docker container deployed successfully! Check the status of the running containers in the Docker Desktop."
	@echo "Monitor the cluster in the Flink UI: http://localhost:8081/"


.PHONY: down
## Shuts down the Flink cluster
down: cancel
	@echo "Shutting down Flink cluster and removing Docker containers..."
	@docker compose down --remove-orphans
	@echo "Containers removed."


.PHONY: start
start: up

.PHONY: stop
stop: down

.PHONY: restart
restart: down up

.PHONY: job
## Submit the Flink job
job:
	@echo "Submitting the Flink job..."
	@docker compose exec -d jobmanager ./bin/flink run -py /opt/src/job/start_job.py --pyFiles /opt/src
	@echo "Flink job submitted successfully! Please wait a moment for it to appear in the Flink UI: http://localhost:8081/#/job/running"
	@echo "You can check the job's status in the Docker container logs of 'jobmanager' for more details."

.PHONY: aggregation_job
## Submit the aggregation Flink job
aggregation_job:
	@echo "Submitting the aggregation Flink job..."
	@docker compose exec -d jobmanager ./bin/flink run -py /opt/src/job/aggregation_job.py --pyFiles /opt/src
	@echo "Aggregation Flink job submitted successfully! Please wait a moment for it to appear in the Flink UI: http://localhost:8081/#/job/running"
	@echo "You can check the job's status in the Docker container logs of 'jobmanager' for more details."


.PHONY: cancel
## Cancels any running Flink jobs
cancel:
	@echo "Canceling Flink jobs..."
	@JOB_IDS=$$(docker compose exec jobmanager ./bin/flink list -r | grep RUNNING | awk '{print $$4}'); \
	if [ -z "$$JOB_IDS" ]; then \
		echo "No running Flink jobs found."; \
	else \
		for job_id in $$JOB_IDS; do \
			docker compose exec -d jobmanager ./bin/flink cancel $$job_id; \
			echo "Flink job with ID $$job_id canceled successfully!"; \
		done; \
	fi


.PHONY: psql
## Open a psql session in the PostgreSQL container
psql: 
	@echo "Opening psql session in the PostgreSQL container... Type 'exit' to exit out of the Postgres CLI."
	@docker exec -it pyflink-postgres psql -U postgres -d postgres -p 5632


.PHONY: sql-client
## Open the Flink SQL client
sql-client:
	@echo "Opening Flink SQL client..."
	@docker-compose run sql-client
