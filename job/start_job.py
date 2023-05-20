from pyflink.table import EnvironmentSettings, TableEnvironment, DataTypes
from pyflink.table.descriptors import Schema

import os
# Create a StreamExecutionEnvironment
env = EnvironmentSettings.in_streaming_mode()
table_env = TableEnvironment.create(env)


source_ddl = f"""
    CREATE TABLE events (
        url VARCHAR,
        referrer VARCHAR,
        user_agent VARCHAR,
        host VARCHAR,
        ip VARCHAR,
        headers VARCHAR,
        event_time VARCHAR,
        event_timestamp AS TO_TIMESTAMP(event_time),
        -- declare time_ltz as event time attribute and use 5 seconds delayed watermark strategy
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
    )
"""

table_env.execute_sql(source_ddl)

table_env.execute_sql(f"""
CREATE TABLE processed_events (
   url VARCHAR
) WITH (
   'connector' = 'jdbc',
   'url' = '{os.environ.get("POSTGRES_URL")}',
   'table-name' = 'processed_events',
   'username' = '{os.environ.get("POSTGRES_USERNAME")}',
   'password' = '{os.environ.get("POSTGRES_PASSWORD")}'
);
""")

stmt_set = table_env.create_statement_set()
# only single INSERT query can be accepted by `add_insert_sql` method
stmt_set \
    .add_insert_sql("INSERT INTO processed_events SELECT url FROM events")
# execute all statements together
table_result2 = stmt_set.execute()
# get job status through TableResult
print(table_result2.get_job_client().get_job_status())
