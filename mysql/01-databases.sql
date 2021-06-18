CREATE DATABASE IF NOT EXISTS `dwd`;
CREATE DATABASE IF NOT EXISTS `dwb`;

use dwd;
CREATE TABLE accident_claims
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
    ts_updated          VARCHAR(20)
);

CREATE TABLE members
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
    ts_updated        VARCHAR(20)
);

use dwb;
CREATE TABLE accident_claims
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
    ts_updated          VARCHAR(20)
);

CREATE TABLE members
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
    ts_updated        VARCHAR(20)
);