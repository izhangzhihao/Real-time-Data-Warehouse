## Real-time Data Warehouse For E-commerce

Real-time Data Warehouse with: [Kafka](https://github.com/izhangzhihao/Real-time-Data-Warehouse/tree/kafka)
| [Hudi](https://github.com/izhangzhihao/Real-time-Data-Warehouse/tree/hudi)

<p align="center">
<img width="700" alt="demo_overview" src="https://user-images.githubusercontent.com/12044174/125452701-2717d438-c2e5-43f9-94c9-aaa804774699.png">
</p>

#### Getting the setup up and running

`docker compose build`

`docker compose up -d`

#### Check everything really up and running

`docker compose ps`

You should be able to access the Flink Web UI (http://localhost:8081), as well as Kibana (http://localhost:5601).

## Flink connectors

https://ci.apache.org/projects/flink/flink-docs-release-1.13/docs/connectors/table/overview/
https://flink-packages.org/categories/connectors

## staging

Start the Flink SQL Client:

```bash
docker compose exec sql-client ./sql-client.sh
```

Testing insert & query works:

```sql
CREATE TABLE t1
(
    uuid VARCHAR(20), -- you can use 'PRIMARY KEY NOT ENFORCED' syntax to mark the field as record key
    name VARCHAR(10),
    age  INT,
    ts   TIMESTAMP(3), 
    `partition` VARCHAR(20)
) PARTITIONED BY (`partition`) WITH (
    'connector' = 'hudi',
    'path' = '/data/t1',
    'write.tasks' = '1', -- default is 4 ,required more resource
    'compaction.tasks' = '1', -- default is 10 ,required more resource
    'table.type' = 'COPY_ON_WRITE', -- this creates a MERGE_ON_READ table, by default is COPY_ON_WRITE
    'read.tasks' = '1', -- default is 4 ,required more resource
    'read.streaming.enabled' = 'true', -- this option enable the streaming read
    'read.streaming.start-commit' = '20210712134429', -- specifies the start commit instant time
    'read.streaming.check-interval' = '4' -- specifies the check interval for finding new source commits, default 60s.
);

-- insert data using values
INSERT INTO t1
VALUES ('id1', 'Danny', 23, TIMESTAMP '1970-01-01 00:00:01', 'par1'),
       ('id2', 'Stephen', 33, TIMESTAMP '1970-01-01 00:00:02', 'par1'),
       ('id3', 'Julian', 53, TIMESTAMP '1970-01-01 00:00:03', 'par2'),
       ('id4', 'Fabian', 31, TIMESTAMP '1970-01-01 00:00:04', 'par2'),
       ('id5', 'Sophia', 18, TIMESTAMP '1970-01-01 00:00:05', 'par3'),
       ('id6', 'Emma', 20, TIMESTAMP '1970-01-01 00:00:06', 'par3'),
       ('id7', 'Bob', 44, TIMESTAMP '1970-01-01 00:00:07', 'par4'),
       ('id8', 'Han', 56, TIMESTAMP '1970-01-01 00:00:08', 'par4');

SELECT *
FROM t1;
```

Submit staging jobs:

```bash
docker compose exec sql-client bash
${FLINK_HOME}/bin/sql-client.sh embedded -f /opt/sql-client/staging_ddl.sql -d ${FLINK_HOME}/conf/sql-client-conf.yaml
```

Check data:

```sql
SELECT * FROM staging.t_fact_online_order;
```

## raw


Submit raw jobs:

```bash
docker compose exec sql-client bash
${FLINK_HOME}/bin/sql-client.sh embedded -f /opt/sql-client/raw_ddl.sql -d ${FLINK_HOME}/conf/sql-client-conf.yaml
${FLINK_HOME}/bin/sql-client.sh embedded -f /opt/sql-client/raw_init.sql -d ${FLINK_HOME}/conf/sql-client-conf.yaml
```

Check data:

```sql
SELECT * FROM `raw`.t_fact_online_order;
```

## agg


## ads

Finally, create a
simple [dashboard in Kibana](https://www.elastic.co/guide/en/kibana/current/dashboard-create-new-dashboard.html)

## References

* [Flink SQL DDL](https://docs.google.com/document/d/1TTP-GCC8wSsibJaSUyFZ_5NBAHYEB1FVmPpP7RgDGBA/edit)
* [Flink SQL Client](https://ci.apache.org/projects/flink/flink-docs-release-1.13/docs/dev/table/sqlclient/)
* [Flink SQL Cookbook](https://github.com/ververica/flink-sql-cookbook)
* [Change Data Capture with Flink SQL and Debezium](https://noti.st/morsapaes/liQzgs/change-data-capture-with-flink-sql-and-debezium)
