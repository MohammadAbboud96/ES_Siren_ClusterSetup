## Install Siren ER

### Run the RabbitMQ Docker
    . create a folder named rabbitmq_conf and copy custom.conf and definitions.json to that folder.
    . docker run -d  -u 1001 -p 0.0.0.0:4369:4369 -p 0.0.0.0:5551:5551 -p 0.0.0.0:5552:5552 -p 0.0.0.0:5672:5672 -p 0.0.0.0:25672:25672 -p 0.0.0.0:15672:15672 -v /path/to/rabbitmq_conf:/bitnami/rabbitmq/conf -e RABBITMQ_DISK_FREE_ABSOLUTE_LIMIT=1GB bitnami/rabbitmq@sha256:aed08fb7575370fe516bda449a58524fbd7360fa250d4380c09515bd09ec8b50

### Run Logstash to load the RabbitMQ load queue
    . create a folder named logstash_http_rabbitmq_pipeline and copy logstash_http_rabbitmq.conf to it.
    . docker run -d --add-host=host.docker.internal:172.17.0.1 -e RABBITMQ_HOST=host.docker.internal -e RABBITMQ_USER=user -e RABBITMQ_PASSWORD=passw0rd -e LOGSTASH_HTTP_PORT=8080 -p 8080:8080 -v /path/to/logstash_http_rabbitmq_pipeline/:/usr/share/logstash/pipeline/ docker.elastic.co/logstash/logstash-oss:8.1.3

### Add transform pipeline
    . At the Transform Data step, use the following Additional transform pipeline. (json-ws-processor)

### Install and Configure Senzing
    . docker run -d --name postgresql -e POSTGRES_USER=g2 -e POSTGRES_PASSWORD=password -e POSTGRES_DB=G2 -p 5432:5432 postgres:14-alpine
    # download senzing
        . export SENZING_RPM_DIR=/home/user/senzing/downloads
        . mkdir -p ${SENZING_RPM_DIR}
        . sudo docker run --rm --volume ${SENZING_RPM_DIR}:/download senzing/yumdownloader senzingapi-3.1.2-22182 senzingdata-v3
    
    # install senzing
        . export SENZING_VOLUME=/home/user/senzing/senzing
        . mkdir ${SENZING_VOLUME}
        . sudo docker run --rm --volume ${SENZING_VOLUME}/data:/opt/senzing/data --volume ${SENZING_VOLUME}/g2:/opt/senzing/g2 --volume ${SENZING_RPM_DIR}:/data --env SENZING_ACCEPT_EULA=I_ACCEPT_THE_SENZING_EULA senzing/yum:1.1.8 -y localinstall /data/senzingdata-v3-3.0.0-22119.x86_64.rpm /data/senzingapi-3.1.2-22182.x86_64.rpm
    
    # run the senzing/postgresql-client docker to add Senzing tables to PostgreSQL
        . export SENZING_VOLUME=/home/user/senzing/senzing
        . export DATABASE_HOST=host.docker.internal
        . export SENZING_DATABASE_URL=postgresql://g2:password@${DATABASE_HOST}:5432/G2
        . sudo docker run --add-host=host.docker.internal:172.17.0.1 -e SENZING_DATABASE_URL=${SENZING_DATABASE_URL} -e SENZING_SQL_FILES="/opt/senzing/g2/resources/schema/g2core-schema-postgresql-create.sql /app/insert-senzing-configuration.sql" --name senzing-postgres-init --rm --tty --volume ${SENZING_VOLUME}/g2:/opt/senzing/g2 senzing/postgresql-client:2.2.0

    #  initialise your Senzing installation with configuration for PostgreSQL
        . export SENZING_VOLUME=/home/user/senzing/senzing 
        . export DATABASE_HOST=host.docker.internal
        . export SENZING_DATABASE_URL=postgresql://g2:password@${DATABASE_HOST}:5432/G2
        . sudo docker run --add-host=host.docker.internal:172.17.0.1 --rm --user root  --volume ${SENZING_VOLUME}/data/3.0.0:/opt/senzing/data --volume ${SENZING_VOLUME}/etc:/etc/opt/senzing --volume ${SENZING_VOLUME}/g2:/opt/senzing/g2 --volume ${SENZING_VOLUME}/var:/var/opt/senzing --env SENZING_DATABASE_URL=${SENZING_DATABASE_URL} senzing/init-container:2.0.1


### Run Senzing Stream Loader
    . export SENZING_VOLUME=/home/user/senzing/senzing
    . export DATABASE_HOST=host.docker.internal
    . export SENZING_DATABASE_URL=postgresql://g2:password@${DATABASE_HOST}:5432/G2
    # stream-loader
        . sudo docker run -d --restart always --add-host=host.docker.internal:172.17.0.1 -e SENZING_DATA_SOURCE=TEST -e SENZING_DATABASE_URL=${SENZING_DATABASE_URL} -e SENZING_ENTITY_TYPE=GENERIC -e SENZING_LOG_LEVEL=info -e SENZING_MONITORING_PERIOD_IN_SECONDS=60 -e SENZING_RABBITMQ_HOST=host.docker.internal -e SENZING_RABBITMQ_PASSWORD=passw0rd -e SENZING_RABBITMQ_QUEUE=senzing-rabbitmq-queue -e SENZING_RABBITMQ_ROUTING_KEY=senzing.records  -e SENZING_RABBITMQ_EXCHANGE=senzing-rabbitmq-exchange -e SENZING_RABBITMQ_USERNAME=user -e SENZING_SUBCOMMAND=rabbitmq-withinfo -e SENZING_THREADS_PER_PROCESS=4 -e SENZING_RABBITMQ_USE_EXISTING_ENTITIES=true -e SENZING_RABBITMQ_HEARTBEAT_IN_SECONDS=10000 --volume ${SENZING_VOLUME}/data/3.0.0:/opt/senzing/data --volume ${SENZING_VOLUME}/etc:/etc/opt/senzing --volume ${SENZING_VOLUME}/g2:/opt/senzing/g2 --volume ${SENZING_VOLUME}/var:/var/opt/senzing senzing/stream-loader:2.0.2

### Run Logstash to update Elasticsearch with updated data from PostgreSQL
    . docker run  -d --add-host=host.docker.internal:172.17.0.1 -e RABBITMQ_HOST=host.docker.internal -e RABBITMQ_USER=user -e RABBITMQ_PASSWORD=passw0rd -e DB_HOST=host.docker.internal -e DB_USER=g2 -e DB_PASSWORD=password -e ES_USER=sirenadmin -e ES_PASSWORD=password -e ES_HOST=host.docker.internal -e PASSTHROUGH_FIELDS=AMOUNT,STATUS,PRIMARY_NAME_LAST -e DB_DRIVER_PATH=/usr/share/logstash/postgresql-42.4.0.jar -e PIPELINE_WORKERS=1 -e PIPELINE_BATCH_SIZE=1 -v /path/to/siren_senzing_updater_pipeline/:/usr/share/logstash/pipeline/ -v /path/to/postgresql-42.4.0.jar:/usr/share/logstash/postgresql-42.4.0.jar docker.elastic.co/logstash/logstash-oss:8.1.3

