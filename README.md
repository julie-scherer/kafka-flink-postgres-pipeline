# Apache Flink Training
Week 5 Apache Flink Streaming Pipelines

## :pushpin: Getting started 

### Pre-requisites

The following components will need to be installed:

1. Docker [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
2. Docker compose [https://docs.docker.com/compose/install/#installation-scenarios](https://docs.docker.com/compose/install/#installation-scenarios)

### Local setup

Clone/fork the repo and navigate to the root directory

```bash
git clone https://github.com/EcZachly-Inc-Bootcamp/apache-flink-training.git
cd apache-flink-training
```

### Configure credentials

Save the `flink-env.env` file shared in Discord at the root of the repository. You'll need to modify some configurations regarding local postgres, such as `POSTGRES_USERNAME` and `POSTGRES_PASSWORD`.

:exclamation: Please do **not** push or share the environment file outside the bootcamp as it contains the credentials to cloud Kafka resources that could be compromised. :exclamation:

## :boom: Running the pipeline

Run the following commands:

```bash
make up # to build the base docker image and deploy docker compose services
make job # to deploy flink job
make down # to stop running docker containers
make clean # to remove the docker container and image
```

To see all the make commands that're available and what they do, run:

```bash
make help
```
