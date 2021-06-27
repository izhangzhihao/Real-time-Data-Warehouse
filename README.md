## Docker

To keep things simple, this demo uses a Docker Compose setup that makes it easier to bundle up all the services you need
for your Real-time Data Warehouse:

<p align="center">
<img width="700" alt="demo_overview" src="https://user-images.githubusercontent.com/12044174/123548508-94b73400-d797-11eb-837a-beeb3b2a0535.png">
</p>

#### Getting the setup up and running

`docker compose build`

`docker compose up -d`

#### Check everything really up and running

`docker compose ps`

You should be able to access the Flink Web UI (http://localhost:8081), as well as Kibana (http://localhost:5601).

## Postgres

Start the Postgres client to have a look at the source tables and run some DML statements later:

```bash
docker compose exec postgres env PGOPTIONS="--search_path=claims" bash -c 'psql -U $POSTGRES_USER postgres'
```

#### What tables are we dealing with?

```sql
SELECT * FROM information_schema.tables WHERE table_schema = 'claims';
```

## Debezium

Start the [Debezium Postgres connector](https://debezium.io/documentation/reference/1.2/connectors/postgresql.html)
using the configuration provided in the `register-postgres.json` file:

```bash
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-postgres.json
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-postgres-members.json
```

Check that the connector is running:

```bash
curl http://localhost:8083/connectors/claims-connector/status # | jq
```

The first time it connects to a Postgres server, Debezium takes
a [consistent snapshot](https://debezium.io/documentation/reference/1.2/connectors/postgresql.html#postgresql-snapshots)
of all database schemas; so, you should see that the pre-existing records in the `accident_claims` table have already
been pushed into your Kafka topic:

```bash
docker compose exec kafka /kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic pg_claims.claims.accident_claims
```

> ℹ️ Have a quick read about the structure of these events in the [Debezium documentation](https://debezium.io/documentation/reference/1.2/connectors/postgresql.html#postgresql-change-events-value).

### Is it working?

In the tab you used to start the Postgres client, you can now run some DML statements to see that the changes are
propagated all the way to your Kafka topic:

```sql
INSERT INTO accident_claims (claim_total, claim_total_receipt, claim_currency, member_id, accident_date, accident_type,
                             accident_detail, claim_date, claim_status)
VALUES (500, 'PharetraMagnaVestibulum.tiff', 'AUD', 321, '2020-08-01 06:43:03', 'Collision', 'Blue Ringed Octopus',
        '2020-08-10 09:39:31', 'INITIAL');
```

```sql
UPDATE accident_claims
SET claim_total_receipt = 'CorrectReceipt.pdf'
WHERE claim_id = 1001;
```

```sql
DELETE
FROM accident_claims
WHERE claim_id = 1001;
```

In the output of your Kafka console consumer, you should now see three consecutive events with `op` values equal
to `c` (an _insert_ event), `u` (an _update_ event) and `d` (a _delete_ event).

## Flink connectors

https://ci.apache.org/projects/flink/flink-docs-release-1.13/docs/connectors/table/overview/
https://flink-packages.org/categories/connectors
https://github.com/knaufk/flink-faker/

## Datasource ingestion

Start the Flink SQL Client:

```bash
docker compose exec sql-client ./sql-client.sh
```

Register
a [Postgres catalog](https://ci.apache.org/projects/flink/flink-docs-stable/dev/table/connectors/jdbc.html#postgres-database-as-a-catalog)
, so you can access the metadata of the external tables over JDBC:

```sql
CREATE CATALOG datasource WITH (
    'type'='jdbc',
    'property-version'='1',
    'base-url'='jdbc:postgresql://postgres:5432/',
    'default-database'='postgres',
    'username'='postgres',
    'password'='postgres'
);

-- CREATE CATALOG kudu WITH (
--     'type'='kudu',
--     'kudu.masters' = 'kudu-master-1:7051'
-- );
```

```sql
CREATE DATABASE IF NOT EXISTS datasource;
```

Create a changelog table to consume the change events from the `pg_claims.claims.accident_claims` topic, with the same
schema as the `accident_claims` source table, that consumes the `debezium-json` format:

```sql
CREATE TABLE datasource.accident_claims WITH (
                                            'connector' = 'kafka',
                                            'topic' = 'pg_claims.claims.accident_claims',
                                            'properties.bootstrap.servers' = 'kafka:9092',
                                            'properties.group.id' = 'accident_claims-consumer-group',
                                            'format' = 'debezium-json',
                                            'scan.startup.mode' = 'earliest-offset'
                                            ) LIKE datasource.postgres.`claims.accident_claims` ( EXCLUDING OPTIONS);
```

and `members` table:

```sql
CREATE TABLE datasource.members WITH (
                                    'connector' = 'kafka',
                                    'topic' = 'pg_claims.claims.members',
                                    'properties.bootstrap.servers' = 'kafka:9092',
                                    'properties.group.id' = 'members-consumer-group',
                                    'format' = 'debezium-json',
                                    'scan.startup.mode' = 'earliest-offset'
                                    ) LIKE datasource.postgres.`claims.members` ( EXCLUDING OPTIONS);
```

Check data:

```sql
SELECT * FROM datasource.accident_claims;
SELECT * FROM datasource.members;
```

## DWD

Create a database in DWD layer:

```sql
CREATE DATABASE IF NOT EXISTS dwd;
```

https://github.com/apache/bahir-flink/tree/master/flink-connector-kudu#supported-data-types

https://kudu.apache.org/docs/command_line_tools_reference.html#table-create

https://jsonformatter.curiousconcept.com/

```json
{
  "table_name": "dwd_accident_claims",
  "schema": {
    "columns": [
      {
        "column_name": "claim_id",
        "column_type": "INT64",
        "is_nullable": false
      },
      {
        "column_name": "ds",
        "column_type": "STRING",
        "is_nullable": false
      },
      {
        "column_name": "claim_total",
        "column_type": "DOUBLE",
        "is_nullable": true
      },
      {
        "column_name": "claim_total_receipt",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "claim_currency",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "member_id",
        "column_type": "INT32",
        "is_nullable": true
      },
      {
        "column_name": "accident_date",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "accident_type",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "accident_detail",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "claim_date",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "claim_status",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "ts_created",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "ts_updated",
        "column_type": "STRING",
        "is_nullable": true
      }
    ],
    "key_column_names": [
      "claim_id",
      "ds"
    ]
  },
  "partition": {
    "hash_partitions": [
      {
        "columns": [
          "ds"
        ],
        "num_buckets": 2,
        "seed": 100
      }
    ],
    "range_partition": {
      "columns": [
        "claim_id"
      ],
      "range_bounds": [
        {
          "upper_bound": {
            "bound_type": "inclusive",
            "bound_values": [
              "2"
            ]
          }
        },
        {
          "lower_bound": {
            "bound_type": "exclusive",
            "bound_values": [
              "2"
            ]
          },
          "upper_bound": {
            "bound_type": "inclusive",
            "bound_values": [
              "3"
            ]
          }
        }
      ]
    }
  },
  "extra_configs": {
    "configs": {
      "kudu.table.history_max_age_sec": "3600"
    }
  },
  "num_replicas": 1
}
```

```json
{
  "table_name": "dwd_members",
  "schema": {
    "columns": [
      {
        "column_name": "id",
        "column_type": "INT64",
        "is_nullable": false
      },
      {
        "column_name": "ds",
        "column_type": "STRING",
        "is_nullable": false
      },
      {
        "column_name": "first_name",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "last_name",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "address",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "address_city",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "address_country",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "insurance_company",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "insurance_number",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "ts_created",
        "column_type": "STRING",
        "is_nullable": true
      },
      {
        "column_name": "ts_updated",
        "column_type": "STRING",
        "is_nullable": true
      }
    ],
    "key_column_names": [
      "id",
      "ds"
    ]
  },
  "partition": {
    "hash_partitions": [
      {
        "columns": [
          "ds"
        ],
        "num_buckets": 2,
        "seed": 100
      }
    ],
    "range_partition": {
      "columns": [
        "id"
      ],
      "range_bounds": [
        {
          "upper_bound": {
            "bound_type": "inclusive",
            "bound_values": [
              "2"
            ]
          }
        },
        {
          "lower_bound": {
            "bound_type": "exclusive",
            "bound_values": [
              "2"
            ]
          },
          "upper_bound": {
            "bound_type": "inclusive",
            "bound_values": [
              "3"
            ]
          }
        }
      ]
    }
  },
  "extra_configs": {
    "configs": {
      "kudu.table.history_max_age_sec": "3600"
    }
  },
  "num_replicas": 1
}
```


```shell
docker compose exec kudu-master-1 sh
kudu table create kudu-master-1:7051 '{"table_name":"dwd_accident_claims","schema":{"columns":[{"column_name":"claim_id","column_type":"INT64","is_nullable":false},{"column_name":"ds","column_type":"STRING","is_nullable":false},{"column_name":"claim_total","column_type":"DOUBLE","is_nullable":true},{"column_name":"claim_total_receipt","column_type":"STRING","is_nullable":true},{"column_name":"claim_currency","column_type":"STRING","is_nullable":true},{"column_name":"member_id","column_type":"INT32","is_nullable":true},{"column_name":"accident_date","column_type":"STRING","is_nullable":true},{"column_name":"accident_type","column_type":"STRING","is_nullable":true},{"column_name":"accident_detail","column_type":"STRING","is_nullable":true},{"column_name":"claim_date","column_type":"STRING","is_nullable":true},{"column_name":"claim_status","column_type":"STRING","is_nullable":true},{"column_name":"ts_created","column_type":"STRING","is_nullable":true},{"column_name":"ts_updated","column_type":"STRING","is_nullable":true}],"key_column_names":["claim_id","ds"]},"partition":{"hash_partitions":[{"columns":["ds"],"num_buckets":2,"seed":100}],"range_partition":{"columns":["claim_id"],"range_bounds":[{"upper_bound":{"bound_type":"inclusive","bound_values":["2"]}},{"lower_bound":{"bound_type":"exclusive","bound_values":["2"]},"upper_bound":{"bound_type":"inclusive","bound_values":["3"]}}]}},"extra_configs":{"configs":{"kudu.table.history_max_age_sec":"3600"}},"num_replicas":1}'
kudu table create kudu-master-1:7051 '{"table_name":"dwd_members","schema":{"columns":[{"column_name":"id","column_type":"INT64","is_nullable":false},{"column_name":"ds","column_type":"STRING","is_nullable":false},{"column_name":"first_name","column_type":"STRING","is_nullable":true},{"column_name":"last_name","column_type":"STRING","is_nullable":true},{"column_name":"address","column_type":"STRING","is_nullable":true},{"column_name":"address_city","column_type":"STRING","is_nullable":true},{"column_name":"address_country","column_type":"STRING","is_nullable":true},{"column_name":"insurance_company","column_type":"STRING","is_nullable":true},{"column_name":"insurance_number","column_type":"STRING","is_nullable":true},{"column_name":"ts_created","column_type":"STRING","is_nullable":true},{"column_name":"ts_updated","column_type":"STRING","is_nullable":true}],"key_column_names":["id","ds"]},"partition":{"hash_partitions":[{"columns":["ds"],"num_buckets":2,"seed":100}],"range_partition":{"columns":["id"],"range_bounds":[{"upper_bound":{"bound_type":"inclusive","bound_values":["2"]}},{"lower_bound":{"bound_type":"exclusive","bound_values":["2"]},"upper_bound":{"bound_type":"inclusive","bound_values":["3"]}}]}},"extra_configs":{"configs":{"kudu.table.history_max_age_sec":"3600"}},"num_replicas":1}'
kudu table list kudu-master-1:7051
# kudu table delete kudu-master-1:7051 dwd_accident_claims
# kudu table delete kudu-master-1:7051 dwd_members
```


```sql
CREATE TABLE dwd.accident_claims
(
    claim_id            BIGINT,
    ds                  VARCHAR(20),
    claim_total         DOUBLE,
    claim_total_receipt VARCHAR(50),
    claim_currency      VARCHAR(3),
    member_id           INT,
    accident_date       VARCHAR(20),
    accident_type       VARCHAR(20),
    accident_detail     VARCHAR(20),
    claim_date          VARCHAR(20),
    claim_status        VARCHAR(10),
    ts_created          VARCHAR(20),
    ts_updated          VARCHAR(20)
) WITH (
  'connector.type' = 'kudu',
  'kudu.masters' = 'kudu-master-1:7051',
  'kudu.table' = 'dwd_accident_claims',
  'kudu.hash-columns' = 'ds',
  'kudu.primary-key-columns' = 'claim_id,ds'
);
```

```sql
CREATE TABLE dwd.members
(
    id                BIGINT,
    ds                VARCHAR(20),
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    address           VARCHAR(50),
    address_city      VARCHAR(10),
    address_country   VARCHAR(10),
    insurance_company VARCHAR(25),
    insurance_number  VARCHAR(50),
    ts_created        VARCHAR(20),
    ts_updated        VARCHAR(20)
) WITH (
      'connector.type' = 'kudu',
      'kudu.masters' = 'kudu-master-1:7051',
      'kudu.table' = 'dwd_members',
      'kudu.hash-columns' = 'ds',
      'kudu.primary-key-columns' = 'id,ds'
      );
```

and submit a continuous query to the Flink cluster that will write the data from datasource into dwd table(ES):

```sql
INSERT INTO dwd.accident_claims
SELECT claim_id,
       SUBSTRING(claim_date, 0, 9),
       claim_total,
       claim_total_receipt,
       claim_currency,
       member_id,
       accident_date,
       accident_type,
       accident_detail,
       claim_date,
       claim_status,
       ts_created,
       ts_updated
FROM datasource.accident_claims;
```

```sql
INSERT INTO dwd.members
SELECT id,
       SUBSTRING(ts_created, 0, 9),
       first_name,
       last_name,
       address,
       address_city,
       address_country,
       insurance_company,
       insurance_number,
       ts_created,
       ts_updated
FROM datasource.members;
```

Check data:

```sql
SELECT * FROM dwd.accident_claims;
SELECT * FROM dwd.members;
```

## DWB

Create a database in DWB layer:

```sql
CREATE DATABASE IF NOT EXISTS dwb;
```

```sql
CREATE TABLE dwb.accident_claims
(
    claim_id            BIGINT,
    claim_total         DOUBLE,
    claim_total_receipt VARCHAR(50),
    claim_currency      VARCHAR(3),
    member_id           INT,
    accident_date       VARCHAR(20),
    accident_type       VARCHAR(20),
    accident_detail     VARCHAR(20),
    claim_date          VARCHAR(20),
    claim_status        VARCHAR(10),
    ts_created          VARCHAR(20),
    ts_updated          VARCHAR(20),
    ds                  VARCHAR(20),
    PRIMARY KEY (claim_id) NOT ENFORCED
) WITH (
      'connector'='upsert-kafka',
      'topic'='dwb_accident_claims',
      'properties.bootstrap.servers'='kafka:9092',
      'properties.group.id'='dwb_accident_claims',
      'key.format' = 'csv',
      'value.format' = 'csv'
      );
```

```sql
CREATE TABLE dwb.members
(
    id                BIGINT,
    first_name        VARCHAR(50),
    last_name         VARCHAR(50),
    address           VARCHAR(50),
    address_city      VARCHAR(10),
    address_country   VARCHAR(10),
    insurance_company VARCHAR(25),
    insurance_number  VARCHAR(50),
    ts_created        VARCHAR(20),
    ts_updated        VARCHAR(20),
    ds                VARCHAR(20),
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector'='upsert-kafka',
      'topic'='dwb_members',
      'properties.bootstrap.servers'='kafka:9092',
      'properties.group.id'='dwb_members_table',
      'key.format' = 'csv',
      'value.format' = 'csv'
      );
```

```sql
INSERT INTO dwb.accident_claims
SELECT claim_id,
       claim_total,
       claim_total_receipt,
       claim_currency,
       member_id,
       accident_date,
       accident_type,
       accident_detail,
       claim_date,
       claim_status,
       ts_created,
       ts_updated,
       ds
FROM dwd.accident_claims;
```

```sql
INSERT INTO dwb.members
SELECT id,
       first_name,
       last_name,
       address,
       address_city,
       address_country,
       insurance_company,
       insurance_number,
       ts_created,
       ts_updated,
       ds
FROM dwd.members;
```

Check data:

```sql
SELECT * FROM dwb.accident_claims;
SELECT * FROM dwb.members;
```

## DWS

Create a database in DWS layer:

```sql
CREATE DATABASE IF NOT EXISTS dws;
```

```sql
CREATE TABLE dws.insurance_costs
(
    es_key            STRING PRIMARY KEY NOT ENFORCED,
    insurance_company STRING,
    accident_detail   STRING,
    accident_agg_cost DOUBLE
) WITH (
      'connector' = 'elasticsearch-7', 'hosts' = 'http://elasticsearch:9200', 'index' = 'agg_insurance_costs'
      );
```

and submit a continuous query to the Flink cluster that will write the aggregated insurance costs
per `insurance_company`, bucketed by `accident_detail` (or, what animals are causing the most harm in terms of costs):

```sql
INSERT INTO dws.insurance_costs
SELECT UPPER(SUBSTRING(m.insurance_company, 0, 4) || '_' || SUBSTRING(ac.accident_detail, 0, 4)) es_key,
       m.insurance_company,
       ac.accident_detail,
       SUM(ac.claim_total) member_total
FROM dwb.accident_claims ac
         JOIN dwb.members m
              ON ac.member_id = m.id
WHERE ac.claim_status <> 'DENIED'
GROUP BY m.insurance_company, ac.accident_detail;
```

Finally, create a
simple [dashboard in Kibana](https://www.elastic.co/guide/en/kibana/current/dashboard-create-new-dashboard.html) with a
1s refresh rate and use the (very rustic) `postgres_datagen.sql` data generator script to periodically insert some
records into the Postgres source table, creating visible changes in your results:

```bash
cat ./postgres_datagen.sql | docker exec -i flink-sql-cdc_postgres_1 psql -U postgres -d postgres
```









References:

* [Flink SQL Client](https://ci.apache.org/projects/flink/flink-docs-release-1.13/docs/dev/table/sqlclient/)
* [Flink SQL Cookbook](https://github.com/ververica/flink-sql-cookbook)
* [Change Data Capture with Flink SQL and Debezium](https://noti.st/morsapaes/liQzgs/change-data-capture-with-flink-sql-and-debezium)