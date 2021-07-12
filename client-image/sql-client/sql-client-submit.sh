#!/bin/bash

${FLINK_HOME}/bin/sql-client.sh embedded -d ${FLINK_HOME}/conf/sql-client-conf.yaml -f /opt/sql-client/exec.sql