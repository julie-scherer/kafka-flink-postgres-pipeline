# Apache Flink Training
Week 5 Apache Flink Streaming Pipelines

## :pushpin: Getting started 

### Pre-requisites

The following components will need to be installed:

1. Docker [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
2. Docker compose [https://docs.docker.com/compose/install/#installation-scenarios](https://docs.docker.com/compose/install/#installation-scenarios)
3. Make

### Local setup

Clone/fork the repo and navigate to the root directory

```bash
git clone https://github.com/EcZachly-Inc-Bootcamp/apache-flink-training.git
cd apache-flink-training
```

### Configure credentials

Copy `example.env` to `flink-env.env`:

```bash
cp example.env flink-env.env
```

Update `KAFKA_PASSWORD`, `KAFKA_GROUP`, `KAFKA_TOPIC`, and `KAFKA_URL` with the values in the `flink-env.env` file shared in Discord. You might also need to modify some configurations for the containerized postgreSQL instance, such as `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`.

:exclamation: Please do **not** push or share the environment file outside the bootcamp as it contains the credentials to cloud Kafka resources that could be compromised. :exclamation:

## :boom: Running the pipeline

Run the command below to build the base docker image and deploy docker compose services:

```bash
make up

# or if you dont have make:
docker compose --env-file flink-env.env up --build --remove-orphans  -d
```

**:alarm_clock: Wait until the Flink UI is running at [localhost:8081](localhost:8081). This may take a minute or so.**

Once the Flink cluster is up and running, run the command below to deploy the flink job:

```bash
make job

# or without make, you can run:
docker-compose exec jobmanager ./bin/flink run -py /opt/job/start_job.py -d
```

After you're finished, you can clean up the Docker resources by running these commands

```bash
make down # to stop running docker containers
make clean # to remove the docker container and image
```

To see all the make commands that're available and what they do, run:

```bash
make help
```
