# Apache Flink Training
Week 5 Apache Flink Streaming Pipelines

## :pushpin: Getting started 

### :whale: Installations

To run this repo, the following components will need to be installed:

1. [Docker](https://docs.docker.com/get-docker/) (required)
2. [Docker compose](https://docs.docker.com/compose/install/#installation-scenarios) (required)
3. Make (recommended) -- see below
    - On most Linux distributions and macOS, `make` is typically pre-installed by default. To check if `make` is installed on your system, you can run the `make --version` command in your terminal or command prompt. If it's installed, it will display the version information. 
    - Otherwise, you can try following the instructions below, or you can just copy+paste the commands from the `Makefile` into your terminal or command prompt and run manually.

        ```bash
        # On Ubuntu or Debian:
        sudo apt-get update
        sudo apt-get install build-essential

        # On CentOS or Fedora:
        sudo dnf install make

        # On macOS:
        xcode-select --install

        # On windows:
        choco install make # uses Chocolatey, https://chocolatey.org/install
        ```

### :computer: Local setup

Clone/fork the repo and navigate to the root directory on your local computer.

```bash
git clone https://github.com/EcZachly-Inc-Bootcamp/apache-flink-training.git
cd apache-flink-training
```

### :dizzy: Configure credentials

1. Copy `example.env` to `flink-env.env`.

    ```bash
    cp example.env flink-env.env
    ```

2. Use `vim` or your favorite text editor to update `KAFKA_PASSWORD`, `KAFKA_GROUP`, `KAFKA_TOPIC`, and `KAFKA_URL` with the credentials in the `flink-env.env` file Zach shared in Discord.

    ```bash
    vim flink-env.env
    ```
    
    ```bash
    KAFKA_PASSWORD="" # update this value
    KAFKA_GROUP="" # update this value
    KAFKA_TOPIC="" # update this value
    KAFKA_URL="" # update this value

    CONTAINER_PREFIX=eczachly-flink
    IMAGE_NAME=pyflink/pyflink:1.16.0-scala_2.12
    FLINK_VERSION=1.16.0
    PYTHON_VERSION=3.7.9

    POSTGRES_URL="jdbc:postgresql://host.docker.internal:5432/postgres"
    JDBC_BASE_URL="jdbc:postgresql://host.docker.internal:5432"
    POSTGRES_USER=postgres
    POSTGRES_PASSWORD=postgres
    POSTGRES_DB=postgres
    ```

    **:exclamation: Please do *not* push or share the environment file outside the bootcamp as it contains the credentials to cloud Kafka resources that could be compromised. :exclamation:**

    Other notes ~

    &rarr; _You can safely ignore the rest of the credentials in the `flink-env.env` file in Discord since the repo has since been updated and everything else you need is conveniently included in the `example.env`._

    &rarr; _You might also need to modify the configurations for the containerized postgreSQL instance such as `POSTGRES_USER` and `POSTGRES_PASSWORD`. Otherwise, you can leave the default username and password as `postgres`._


## :boom: Running the pipeline

1. Build the Docker image and deploy the services in the `docker-compose.yml` file, including the PostgreSQL database and Flink cluster. This will (should) also create the sink table, `processed_events`, where Flink will write the Kafka messages to.

    ```bash
    make up

    #// if you dont have make, you can run:
    # docker compose --env-file flink-env.env up --build --remove-orphans  -d
    ```

    **:star: Wait until the Flink UI is running at [http://localhost:8081/](http://localhost:8081/) before proceeding to the next step.** _Note the first time you build the Docker image it can take anywhere from 5 to 30 minutes. Future builds should only take a few second, assuming you haven't deleted the image since._

    :information_source: After the image is built, Docker will automatically start up the job manager and task manager services. This will take a minute or so. Check the container logs in Docker desktop and when you see the line below, you know you're good to move onto the next step.

    ```
    taskmanager Successful registration at resource manager akka.tcp://flink@jobmanager:6123/user/rpc/resourcemanager_* under registration id <id_number>
    ```

2. Check that the `processed_events` table was created by using the `psql` command to query the database in the CLI.

    ```bash
    make psql 
    # or see `Makefile` to execute the command manually in your terminal or command prompt

    # The output should look something like this:
    docker exec -it eczachly-flink-postgres \
            psql -U postgres -d postgres
    psql (15.3 (Debian 15.3-1.pgdg110+1))
    Type "help" for help.

    postgres=#
    ```

    To list the tables in the current database, run the `\dt` command. You should see something like this:
    ```bash
    postgres=# \dt
                List of relations
    Schema |       Name       | Type  |  Owner   
    --------+------------------+-------+----------
    public | processed_events | table | postgres
    (1 row)
    ```

    :bangbang: If you don't see the `processed_events` table in the database, you can excute the command below in the Docker desktop terminal inside the postgres container.
    ```bash
    psql -U postgres -d postgres -f docker-entrypoint-initdb.d/init.sql
    ```

    Use the `\q` command to exit the psql CLI.
    ```bash
    postgres=# \q
    ```


3. Now that the Flink cluster is up and running, it's time to finally run the PyFlink job! :smile:

    ```bash
    make job

    #// if you dont have make, you can run:
    # docker-compose exec jobmanager ./bin/flink run -py /opt/job/start_job.py -d
    ```

    After about a minute, you should see a prompt that the job's been submitted (e.g., `Job has been submitted with JobID <job_id_number>`). Now go back to the [Flink UI](http://localhost:8081/#/job/running) to see the job running! :tada:

4. Trigger an event from the Kafka source by visiting [www.zachwilson.tech](https://www.zachwilson.tech/) and then query the `processed_events` table in your postgreSQL database to confirm the data/events were added.

    ```bash
    make psql
    # or see `Makefile` to execute the command manually in your terminal or command prompt

    # expected output:
    docker exec -it eczachly-flink-postgres psql -U postgres -d postgres
    psql (15.3 (Debian 15.3-1.pgdg110+1))
    Type "help" for help.

    postgres=# SELECT COUNT(*) FROM processed_events;
    count 
    -------
    739
    (1 row)
    ```

5. When you're done, you can stop and/or clean up the Docker resources by running the commands below.

    ```bash
    make stop # to stop running services in docker compose
    make down # to stop and remove docker compose services
    make clean # to remove the docker container and dangling images
    ```

    :grey_exclamation: Note the `/var/lib/postgresql/data` directory inside the PostgreSQL container is mounted to the `./postgres-data` directory on your local machine. This means the data will persist across container restarts or removals, so even if you stop/remove the container, you won't lose any data written within the container.

------

:information_source: To see all the make commands that're available and what they do, run:

```bash
make help
```

As of the time of writing this, the available commands are:

```bash

Usage:
  make <target>

Targets:
  help                 Show help with `make help`
  db-init              Builds and runs the PostgreSQL database service
  build                Builds the Flink base image with pyFlink and connectors installed
  up                   Builds the base Docker image and starts Flink cluster
  down                 Shuts down the Flink cluster
  job                  Submit the Flink job
  stop                 Stops all services in Docker compose
  start                Starts all services in Docker compose
  clean                Stops and removes the Docker container as well as images with tag `<none>`
  psql                 Runs psql to query containerized postgreSQL database in CLI
  postgres-die-mac     Removes mounted postgres data dir on local machine (mac users) and in Docker
  postgres-die-pc      Removes mounted postgres data dir on local machine (PC users) and in Docker
```
