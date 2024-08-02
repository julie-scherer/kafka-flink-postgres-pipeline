import os
from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import EnvironmentSettings, TableEnvironment, StreamTableEnvironment
from pyflink.table.catalog import JdbcCatalog


FLINK_JARS_PATH = "/opt/flink/lib"
def add_pipeline_jars(t_env):
    jars = []
    for file in os.listdir(FLINK_JARS_PATH):
        if file.endswith('.jar'):
            jars.append(os.path.basename(file))
    str_jars = ';'.join(['file://'+ FLINK_JARS_PATH +'/'+ jar for jar in jars])
    t_env.get_config().get_configuration().set_string("pipeline.jars", str_jars)
    return t_env

def create_kafka_source(t_env):
    table_name = "events"
    source_ddl = f"""
        CREATE TABLE {table_name} (
            url VARCHAR,
            referrer VARCHAR,
            user_agent VARCHAR,
            host VARCHAR,
            ip VARCHAR,
            headers VARCHAR,
            event_time VARCHAR,
            event_timestamp AS TO_TIMESTAMP(event_time),
            WATERMARK FOR event_timestamp AS event_timestamp - INTERVAL '15' SECOND
        ) WITH (
            'connector' = 'kafka',
            'properties.bootstrap.servers' = '{os.environ.get('KAFKA_URL')}',
            'topic' = '{os.environ.get('KAFKA_TOPIC')}',
            'properties.ssl.endpoint.identification.algorithm' = '',
            'properties.group.id' = '{os.environ.get('KAFKA_GROUP')}',
            'properties.security.protocol' = 'SSL',
            'properties.ssl.truststore.location' = '/var/private/ssl/kafka_truststore.jks',
            'properties.ssl.truststore.password' = '{os.environ.get("KAFKA_PASSWORD")}',
            'properties.ssl.keystore.location' = '/var/private/ssl/kafka_client.jks',
            'properties.ssl.keystore.password' = '{os.environ.get("KAFKA_PASSWORD")}',
            'scan.startup.mode' = 'earliest-offset',
            'properties.auto.offset.reset' = 'earliest',
            'format' = 'json'
        );
        """
    t_env.execute_sql(source_ddl)
    return table_name


def create_processed_events_sink(t_env):
    table_name = 'processed_events'
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            url VARCHAR
        ) WITH (
            'connector' = 'jdbc',
            'url' = '{os.environ.get("POSTGRES_URL")}',
            'table-name' = '{table_name}',
            'username' = '{os.environ.get("POSTGRES_USER", "postgres")}',
            'password' = '{os.environ.get("POSTGRES_PASSWORD", "postgres")}',
            'driver' = 'org.postgresql.Driver'
        );
        """
    t_env.execute_sql(sink_ddl)
    return table_name


def log_processing():
    # Set up the execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    # env.enable_checkpointing(10)
    # env.set_parallelism(1)

    # Set up the table environment
    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    t_env = StreamTableEnvironment.create(env, environment_settings=settings)
    
    # Add pipeline jars
    t_env = add_pipeline_jars(t_env)
    
    try:
        # Create Kafka table
        source_table = create_kafka_source(t_env)

        # Create postgreSQL table
        sink_table = create_processed_events_sink(t_env)

        # ref: https://nightlies.apache.org/flink/flink-docs-release-1.16/docs/dev/python/table/python_table_api_connectors/
        t_env.sql_query(f"SELECT url FROM {source_table}") \
            .execute_insert(f"{sink_table}") \
            .wait()
    
    except Exception as e:
        print("Writing records from Kafka to JDBC failed:", str(e))


if __name__ == '__main__':
    log_processing()

