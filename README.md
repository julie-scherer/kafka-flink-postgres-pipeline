# Apache Flink Training
Week 5 Apache Flink Streaming Pipelines

## Installation

[Installing minikube+helm+flink](https://www.notion.so/Installing-minikube-helm-flink-44828e96d2874ca39a96fc9f1d618364)

### Pre-requisites

The following components will need to be installed:

1. docker [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
2. docker compose [https://docs.docker.com/compose/install/#installation-scenarios](https://docs.docker.com/compose/install/#installation-scenarios)

### Flink (with pyFlink)

The Apache foundation provides container images and kubernetes operators for Flink out of the box, but these do not contain pyFlink support, they also do not include the jar files for certain connectors (e.g. the flink SQL kafka connector which we will be using). So we will build a custom image based on the public flink image. 

#### Step 1

Clone this repo:

```bash
git clone https://github.com/EcZachly-Inc-Bootcamp/apache-flink-training.git
cd apache-flink-training
```

#### Step 2

```bash
make help
```

This should show you your options and what they do. As of this writing, they are:

```bash
Usage:
make <target>

Targets:
  help                 Show help with `make help`
  up                   Starts the Flink cluster, also builds the image if it has not been built yet
  down                 Shuts down the Flink cluster, cleans dangling images
  clean                Removes unused artifacts from this setup
```

#### Step 3

We will use:
- `make up` to deploy locally within docker compose
- `make down` to stop the Flink job and tear down the docker container
- `docker exec -it <job manager id> flink run -py /job/start_job.py` this submits the job to the job manager
