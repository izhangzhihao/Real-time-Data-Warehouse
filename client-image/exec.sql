CREATE CATALOG datasource WITH (
    'type'='jdbc',
    'property-version'='1',
    'base-url'='jdbc:postgresql://postgres:5432/',
    'default-database'='postgres',
    'username'='postgres',
    'password'='postgres'
);

CREATE DATABASE IF NOT EXISTS datasource;

CREATE TABLE datasource.accident_claims WITH (
                                            'connector' = 'kafka',
                                            'topic' = 'pg_claims.claims.accident_claims',
                                            'properties.bootstrap.servers' = 'kafka:9092',
                                            'properties.group.id' = 'accident_claims-consumer-group',
                                            'format' = 'debezium-json',
                                            'scan.startup.mode' = 'earliest-offset'
                                            ) LIKE datasource.postgres.`claims.accident_claims` ( EXCLUDING OPTIONS);


CREATE TABLE datasource.members WITH (
                                    'connector' = 'kafka',
                                    'topic' = 'pg_claims.claims.members',
                                    'properties.bootstrap.servers' = 'kafka:9092',
                                    'properties.group.id' = 'members-consumer-group',
                                    'format' = 'debezium-json',
                                    'scan.startup.mode' = 'earliest-offset'
                                    ) LIKE datasource.postgres.`claims.members` ( EXCLUDING OPTIONS);


CREATE DATABASE IF NOT EXISTS dwd;

CREATE TABLE dwd.accident_claims
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
) WITH ( --PARTITIONED BY (ds)
  'connector'='upsert-kafka',
  'topic'='dwd_accident_claims',
  'properties.bootstrap.servers'='kafka:9092',
  'properties.group.id'='dwd_accident_claims_table',
--   'scan.startup.mode'='earliest-offset',
  'key.format' = 'csv',
  'value.format' = 'csv'
);


CREATE TABLE dwd.members
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
    ds                  VARCHAR(20),
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector'='upsert-kafka',
      'topic'='dwd_members',
      'properties.bootstrap.servers'='kafka:9092',
      'properties.group.id'='dwd_members_table',
      'key.format' = 'csv',
      'value.format' = 'csv'
      );


INSERT INTO dwd.accident_claims
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
       SUBSTRING(claim_date, 0, 9)
FROM datasource.accident_claims;

INSERT INTO dwd.members
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
       SUBSTRING(ts_created, 0, 9)
FROM datasource.members;



CREATE DATABASE IF NOT EXISTS dwb;


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


CREATE DATABASE IF NOT EXISTS dws;

CREATE TABLE dws.insurance_costs
(
    es_key            STRING PRIMARY KEY NOT ENFORCED,
    insurance_company STRING,
    accident_detail   STRING,
    accident_agg_cost DOUBLE
) WITH (
      'connector' = 'elasticsearch-7', 'hosts' = 'http://elasticsearch:9200', 'index' = 'agg_insurance_costs'
      );


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


