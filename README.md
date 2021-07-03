## Real-time Data Warehouse with Apache Spark & Delta

<!-- <p align="center">
<img width="700" alt="demo_overview" src="https://user-images.githubusercontent.com/12044174/123548508-94b73400-d797-11eb-837a-beeb3b2a0535.png">
</p> -->

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

## Start the Spark SQL Client:

```bash
docker compose exec polynote spark-sql --packages io.delta:delta-core_2.12:1.0.0,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
```


OR

```bash
docker compose exec polynote spark-sql -f exec.sql --packages io.delta:delta-core_2.12:1.0.0,org.apache.spark:spark-sql-kafka-0-10_2.12:3.1.2 --conf "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension" --conf "spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog"
```

This DDL is used to define a stream table. We can create a stream table like same way spark supports data source table creation. Besides, there is no obvious difference between static table definition and stream table definition.

```sql
CREATE TABLE accident_claims_cdc
USING kafka
options (
subscribe="pg_claims.claims.accident_claims", kafka.bootstrap.servers="kafka:9092"
);
```


## Execute streaming job from Polynote

http://localhost:8192

## References

* [Simplify CDC pipeline with Spark Streaming SQL and Delta Lake](https://www.iteblog.com/ppt/sparkaisummit-north-america-2020-iteblog/simplify-cdc-pipeline-with-spark-streaming-sql-and-delta-lake-iteblog.com.pdf)

* [SPIP: Support Streaming SQL interface in Spark](https://docs.google.com/document/d/19degwnIIcuMSELv6BQ_1VQI5AIVcvGeqOm5xE2-aRA0/edit)

* [Structured Streaming + Kafka Integration Guide (Kafka broker version 0.10.0 or higher](https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html)