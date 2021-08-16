#!/bin/bash

${FLINK_HOME}/bin/sql-client.sh embedded -f /opt/sql-client/staging.sql -d ${FLINK_HOME}/conf/sql-client-conf.yaml