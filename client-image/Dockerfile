###############################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

FROM flink:1.13.1-scala_2.12-java11

# Copy sql-client script
COPY sql-client/ /opt/sql-client
RUN mkdir -p /opt/sql-client/lib

# Download connector libraries
RUN wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/org/apache/flink/flink-json/1.13.1/flink-json-1.13.1.jar; \
    wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/org/apache/flink/flink-sql-connector-kafka_2.12/1.13.1/flink-sql-connector-kafka_2.12-1.13.1.jar; \
    wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/org/apache/flink/flink-sql-connector-elasticsearch7_2.12/1.13.1/flink-sql-connector-elasticsearch7_2.12-1.13.1.jar; \
    wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/org/apache/flink/flink-connector-jdbc_2.12/1.13.1/flink-connector-jdbc_2.12-1.13.1.jar; \
    wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/org/postgresql/postgresql/42.2.14/postgresql-42.2.14.jar; \
    wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/mysql/mysql-connector-java/8.0.25/mysql-connector-java-8.0.25.jar; \
    wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/org/apache/flink/flink-connector-kafka_2.12/1.13.1/flink-connector-kafka_2.12-1.13.1.jar; \
    wget -P /opt/sql-client/lib/ https://maven.aliyun.com/repository/central/org/apache/kafka/kafka-clients/2.4.1/kafka-clients-2.4.1.jar;


# Copy configuration
COPY conf/* /opt/flink/conf/

WORKDIR /opt/sql-client
ENV SQL_CLIENT_HOME /opt/sql-client

COPY exec.sql /opt/sql-client
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
