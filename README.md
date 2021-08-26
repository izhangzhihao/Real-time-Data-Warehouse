## Real-time Data Warehouse with Apache Spark & Delta

<!-- <p align="center">
<img width="700" alt="demo_overview" src="https://user-images.githubusercontent.com/12044174/130965499-f7cce75a-0e68-4ad3-9774-5f74b74acbae.png">
</p> -->

#### Getting the setup up and running

`docker compose up -d`

#### Check everything really up and running

`docker compose ps`

## Postgres

Start the Postgres client to have a look at the source tables and run some DML statements later:

```bash
docker compose exec postgres env PGOPTIONS="--search_path=claims" bash -c 'psql -U $POSTGRES_USER postgres'
```

#### What tables are we dealing with?

```sql
SELECT *
FROM information_schema.tables
WHERE table_schema = 'claims';
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

## NOTE

The logic is pretty much the same with the [Hudi](https://github.com/izhangzhihao/Real-time-Data-Warehouse/tree/hudi)
version except write Scala code instead of SQL.

## References

* [Query an older snapshot of a table (time travel)](https://docs.delta.io/latest/delta-batch.html#-deltatimetravel)

* [Simplify CDC pipeline with Spark Streaming SQL and Delta Lake](https://www.iteblog.com/ppt/sparkaisummit-north-america-2020-iteblog/simplify-cdc-pipeline-with-spark-streaming-sql-and-delta-lake-iteblog.com.pdf)

* [SPIP: Support Streaming SQL interface in Spark](https://docs.google.com/document/d/19degwnIIcuMSELv6BQ_1VQI5AIVcvGeqOm5xE2-aRA0/edit)

* [Structured Streaming + Kafka Integration Guide (Kafka broker version 0.10.0 or higher](https://spark.apache.org/docs/latest/structured-streaming-kafka-integration.html)