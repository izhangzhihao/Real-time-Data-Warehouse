CREATE
DATABASE IF NOT EXISTS staging;


create table staging.t_fact_online_order
(
    order_id           varchar(128) NOT NULL,
    user_id            varchar(128) NOT NULL,
    user_name          varchar(128) NOT NULL,
    order_total_amount decimal,
    actual_amount      decimal,
    post_amount        decimal,
    order_pay_amount   decimal,
    total_discount     decimal,
    pay_type           varchar(128),
    source_type        varchar(128),
    order_status       varchar(128),
    note               varchar(128),
    confirm_status     varchar(128),
    payment_time       timestamp,
    delivery_time      timestamp,
    receive_time       timestamp,
    comment_time       timestamp,
    delivery_company   varchar(128),
    delivery_code      varchar(128),
    business_date      date,
    return_flag        varchar(128),
    created_at         timestamp,
    updated_at         timestamp,
    deleted_at         timestamp,
    PRIMARY KEY (order_id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'online_order',
      'debezium.slot.name' = 'online_order'
      );


create table staging.t_fact_online_order_detail
(
    id                    varchar(128),
    order_id              varchar(128),
    product_code          varchar(128),
    product_name          varchar(128),
    product_type          varchar(128),
    product_quantity      int,
    product_pic           varchar(128),
    product_amount        decimal,
    product_actual_amount decimal,
    created_at            timestamp,
    updated_at            timestamp,
    deleted_at            timestamp,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'online_order_detail',
      'debezium.slot.name' = 'online_order_detail'
      );



create table staging.t_dim_store
(
    store_id        varchar(128),
    store_name      varchar(128),
    owner_id        varchar(128),
    owner_name      varchar(128),
    store_province  varchar(128),
    store_city      varchar(128),
    store_county    varchar(128),
    store_address   varchar(128),
    store_open_time varchar(128),
    created_at      timestamp,
    updated_at      timestamp,
    deleted_at      timestamp,
    PRIMARY KEY (store_id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'store',
      'debezium.slot.name' = 'store'
      );



create table staging.t_fact_offline_order
(
    store_order_id     varchar(128),
    user_id            varchar(128),
    store_id           varchar(128),
    store_name         varchar(128),
    pos_id             varchar(128),
    seq_number         bigint,
    business_date      date,
    payment_time       timestamp,
    operator_id        varchar(128),
    operator_name      varchar(128),
    order_total_amount decimal,
    actual_amount      timestamp,
    order_pay_amount   timestamp,
    total_discount     timestamp,
    return_flag        varchar(128),
    created_at         timestamp,
    updated_at         timestamp,
    deleted_at         timestamp,
    PRIMARY KEY (store_order_id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'offline_order',
      'debezium.slot.name' = 'offline_order'
      );



create table staging.t_fact_offline_order_detail
(
    id                    varchar(128),
    order_id              varchar(128),
    product_code          varchar(128),
    product_name          varchar(128),
    product_type          varchar(128),
    product_quantity      int,
    product_amount        decimal,
    product_actual_amount decimal,
    created_at            timestamp,
    updated_at            timestamp,
    deleted_at            timestamp,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'offline_order_detail',
      'debezium.slot.name' = 'offline_order_detail'
      );



create table staging.t_fact_delivery
(
    order_id                varchar(128),
    delivery_no             varchar(128),
    product_code            varchar(128),
    product_quantity        varchar(128),
    delivery_company        varchar(128),
    delivery_code           varchar(128),
    receiver_name           varchar(128),
    receiver_phone          varchar(128),
    receiver_post_code      varchar(128),
    receiver_province       varchar(128),
    receiver_city           varchar(128),
    receiver_region         varchar(128),
    receiver_detail_address varchar(128),
    created_at              timestamp,
    updated_at              timestamp,
    deleted_at              timestamp,
    PRIMARY KEY (delivery_no) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'delivery',
      'debezium.slot.name' = 'delivery'
      );



create table staging.t_fact_return
(
    order_id                varchar(128),
    return_id               varchar(128),
    return_application_time varchar(128),
    return_amount           varchar(128),
    return_status           varchar(128),
    return_type             varchar(128),
    return_reason           varchar(128),
    return_address          varchar(128),
    return_delivery_company varchar(128),
    return_delivery_code    varchar(128),
    created_at              timestamp,
    updated_at              timestamp,
    deleted_at              timestamp,
    PRIMARY KEY (return_id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'return',
      'debezium.slot.name' = 'return'
      );



create table staging.t_fact_return_detail
(
    id                   varchar(128),
    order_id             varchar(128),
    return_id            varchar(128),
    product_code         varchar(128),
    return_quantity      varchar(128),
    product_price        varchar(128),
    product_return_price varchar(128),
    created_at           timestamp,
    updated_at           timestamp,
    deleted_at           timestamp,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'return_detail',
      'debezium.slot.name' = 'return_detail'
      );



create table staging.t_dim_user
(
    user_id          varchar(128),
    user_name        varchar(128),
    user_phone       varchar(128),
    login_password   varchar(128),
    user_potrait_url varchar(128),
    register_time    varchar(128),
    user_platform    varchar(128),
    register_channel varchar(128),
    gender           varchar(128),
    wechat_id        varchar(128),
    city             varchar(128),
    birthday         date,
    created_at       timestamp,
    updated_at       timestamp,
    deleted_at       timestamp,
    PRIMARY KEY (user_id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = '"user"',
      'debezium.slot.name' = 'user'
      );


create table staging.t_dim_product
(
    product_code       varchar(128),
    product_name       varchar(128),
    product_type       varchar(128),
    product_type2      varchar(128),
    product_pic        varchar(128),
    product_brand      varchar(128),
    product_attribute1 varchar(128),
    product_status     varchar(128),
    product_channel    varchar(128),
    created_at         timestamp,
    updated_at         timestamp,
    deleted_at         timestamp,
    PRIMARY KEY (product_code) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'product',
      'debezium.slot.name' = 'product'
      );



create table staging.t_dim_product_sku
(
    product_code          varchar(128),
    product_sku_code      varchar(128),
    product_sku_name      varchar(128),
    product_type          varchar(128),
    product_color         varchar(128),
    product_net_content   varchar(128),
    product_sp_code       varchar(128),
    product_sp_name       varchar(128),
    product_sp_short_name varchar(128),
    created_at            timestamp,
    updated_at            timestamp,
    deleted_at            timestamp,
    PRIMARY KEY (product_code) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'product_sku',
      'debezium.slot.name' = 'product_sku'
      );



create table staging.t_dim_product_package
(
    product_code         varchar(128),
    product_type         varchar(128),
    product_package_code varchar(128),
    product_package_name varchar(128),
    product_color        varchar(128),
    created_at           timestamp,
    updated_at           timestamp,
    deleted_at           timestamp,
    PRIMARY KEY (product_code) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'product_package',
      'debezium.slot.name' = 'product_package'
      );



create table staging.t_dim_package_sku
(
    id                   varchar(128),
    product_package_code varchar(128),
    product_package_name varchar(128),
    product_sku_code     varchar(128),
    product_sku_name     varchar(128),
    product_sku_quantity varchar(128),
    created_at           timestamp,
    updated_at           timestamp,
    deleted_at           timestamp,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'package_sku',
      'debezium.slot.name' = 'package_sku'
      );



create table staging.t_dim_product_price
(
    id              varchar(128),
    product_code    varchar(128),
    product_price   decimal,
    product_channel varchar(128),
    created_at      timestamp,
    updated_at      timestamp,
    deleted_at      timestamp,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'product_price',
      'debezium.slot.name' = 'product_price'
      );



create table staging.t_dim_campaign
(
    campaign_code       varchar(128),
    campaign_name       varchar(128),
    campaign_start_time timestamp NOT NULL,
    campaign_end_time   timestamp NOT NULL,
    created_at          timestamp,
    updated_at          timestamp,
    deleted_at          timestamp,
    PRIMARY KEY (campaign_code) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'campaign',
      'debezium.slot.name' = 'campaign'
      );


create table staging.t_dim_promotion
(
    promotion_code       varchar(128),
    promotion_name       varchar(128),
    campaign_code        varchar(128),
    campaign_name        varchar(128),
    promotion_start_time timestamp NOT NULL,
    promotion_end_time   timestamp NOT NULL,
    created_at           timestamp,
    updated_at           timestamp,
    deleted_at           timestamp,
    PRIMARY KEY (promotion_code) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'promotion',
      'debezium.slot.name' = 'promotion'
      );


create table staging.t_dim_promotion_sku
(
    id               varchar(128),
    promotion_code   varchar(128),
    promotion_name   varchar(128),
    product_sku_code varchar(128),
    product_sku_name varchar(128),
    is_active        varchar(128),
    created_at       timestamp,
    updated_at       timestamp,
    deleted_at       timestamp,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'promotion_sku',
      'debezium.slot.name' = 'promotion_sku'
      );



create table staging.t_fact_user_promotion_record
(
    id             varchar(128),
    user_id        varchar(128),
    promotion_id   varchar(128),
    promotion_code varchar(128),
    order_id       varchar(128),
    created_at     timestamp,
    updated_at     timestamp,
    deleted_at     timestamp,
    PRIMARY KEY (id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'user_promotion_record',
      'debezium.slot.name' = 'user_promotion_record'
      );



create table staging.t_dim_coupon
(
    coupon_code                  varchar(128),
    coupon_name                  varchar(128),
    campaign_code                varchar(128),
    coupon_acquire_type          varchar(128),
    coupon_pay_type              varchar(128),
    coupon_channel               varchar(128),
    coupon_discount              varchar(128),
    coupon_number                bigint,
    coupon_limit                 bigint,
    coupon_distribute_start_time timestamp NOT NULL,
    coupon_distribute_end_time   timestamp NOT NULL,
    coupon_start_time            timestamp NOT NULL,
    coupon_end_time              timestamp NOT NULL,
    coupon_create_time           timestamp NOT NULL,
    created_at                   timestamp,
    updated_at                   timestamp,
    deleted_at                   timestamp,
    PRIMARY KEY (coupon_code) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'coupon',
      'debezium.slot.name' = 'coupon'
      );



create table staging.t_fact_coupon_receive
(
    coupon_require_id   varchar(128),
    user_id             varchar(128),
    coupon_code         varchar(128),
    coupon_acquire_time varchar(128),
    coupon_acquire_type varchar(128),
    coupon_use_status   varchar(128),
    created_at          timestamp,
    updated_at          timestamp,
    deleted_at          timestamp,
    PRIMARY KEY (coupon_require_id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'coupon_receive',
      'debezium.slot.name' = 'coupon_receive'
      );


create table staging.t_fact_coupon_write_off
(
    coupon_require_id  varchar(128),
    order_id           varchar(128),
    coupon_code        varchar(128),
    coupon_redeem_time varchar(128),
    coupon_redeem_type varchar(128),
    coupon_use_status  varchar(128),
    created_at         timestamp,
    updated_at         timestamp,
    deleted_at         timestamp,
    PRIMARY KEY (coupon_require_id) NOT ENFORCED
) WITH (
      'connector' = 'postgres-cdc',
      'hostname' = 'postgres',
      'port' = '5432',
      'username' = 'postgres',
      'password' = 'postgres',
      'database-name' = 'postgres',
      'schema-name' = 'public',
      'table-name' = 'coupon_write_off',
      'debezium.slot.name' = 'coupon_write_off'
      );




