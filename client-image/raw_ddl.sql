CREATE
DATABASE IF NOT EXISTS `raw`;


create table `raw`.t_fact_online_order
(
    id                 varchar(128),
    order_id           varchar(128),
    user_id            varchar(128),
    user_name          varchar(128),
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
    payment_time       TIMESTAMP(3),
    delivery_time      TIMESTAMP(3),
    receive_time       TIMESTAMP(3),
    comment_time       TIMESTAMP(3),
    delivery_company   varchar(128),
    delivery_code      varchar(128),
    business_date      date,
    return_flag        varchar(128),
    created_at         TIMESTAMP(3),
    updated_at         TIMESTAMP(3),
    deleted_at         TIMESTAMP(3),
    start_time         TIMESTAMP(3),
    end_time           TIMESTAMP(3),
    is_valid           int,
    PRIMARY KEY (id) NOT ENFORCED
) PARTITIONED BY (business_date) WITH (
    'connector'='hudi',
    'path' = '/data/raw/t_fact_online_order',
    'table.type' = 'MERGE_ON_READ',
    'read.streaming.enabled' = 'true',
    'write.batch.size' = '100',
    'write.tasks' = '1',
    'compaction.tasks' = '1',
    'compaction.delta_seconds' = '60',
    'write.precombine.field' = 'updated_at',
    'read.tasks' = '1',
    'read.streaming.check-interval' = '60',
    'read.streaming.start-commit' = '20210816000000',
);


create table `raw`.t_fact_online_order_detail
(
    order_id              varchar(128),
    product_code          varchar(128),
    product_name          varchar(128),
    product_type          varchar(128),
    product_quantity      int,
    product_pic           varchar(128),
    product_amount        decimal,
    product_actual_amount decimal,
    created_at            TIMESTAMP(3),
    updated_at            TIMESTAMP(3),
    deleted_at            TIMESTAMP(3),
    start_time            TIMESTAMP(3),
    end_time              TIMESTAMP(3),
    is_valid              int,
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_online_order_detail',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_store
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
    created_at      TIMESTAMP(3),
    updated_at      TIMESTAMP(3),
    deleted_at      TIMESTAMP(3),
    start_time      TIMESTAMP(3),
    end_time        TIMESTAMP(3),
    is_valid        int,
    PRIMARY KEY (store_id) NOT ENFORCED
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_store',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_fact_offline_order
(
    store_order_id     varchar(128),
    user_id            varchar(128),
    store_id           varchar(128),
    store_name         varchar(128),
    pos_id             varchar(128),
    seq_number         bigint,
    business_date      date,
    payment_time       TIMESTAMP(3),
    operator_id        varchar(128),
    operator_name      varchar(128),
    order_total_amount decimal,
    actual_amount      TIMESTAMP(3),
    order_pay_amount   TIMESTAMP(3),
    total_discount     TIMESTAMP(3),
    return_flag        varchar(128),
    created_at         TIMESTAMP(3),
    updated_at         TIMESTAMP(3),
    deleted_at         TIMESTAMP(3),
    start_time         TIMESTAMP(3),
    end_time           TIMESTAMP(3),
    is_valid           int,
    PRIMARY KEY (store_order_id) NOT ENFORCED
) PARTITIONED BY (business_date) WITH (
    'connector'='hudi',
    'path' = '/data/raw/t_fact_offline_order',
    'table.type' = 'MERGE_ON_READ',
    'read.streaming.enabled' = 'true',
    'write.batch.size' = '100',
    'write.tasks' = '1',
    'compaction.tasks' = '1',
    'compaction.delta_seconds' = '60',
    'write.precombine.field' = 'updated_at',
    'read.tasks' = '1',
    'read.streaming.check-interval' = '60',
    'read.streaming.start-commit' = '20210816000000'
);



create table `raw`.t_fact_offline_order_detail
(
    order_id              varchar(128),
    product_code          varchar(128),
    product_name          varchar(128),
    product_type          varchar(128),
    product_quantity      int,
    product_amount        decimal,
    product_actual_amount decimal,
    created_at            TIMESTAMP(3),
    updated_at            TIMESTAMP(3),
    deleted_at            TIMESTAMP(3),
    start_time            TIMESTAMP(3),
    end_time              TIMESTAMP(3),
    is_valid              int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_offline_order_detail',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_fact_delivery
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
    created_at              TIMESTAMP(3),
    updated_at              TIMESTAMP(3),
    deleted_at              TIMESTAMP(3),
    start_time              TIMESTAMP(3),
    end_time                TIMESTAMP(3),
    is_valid                int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_delivery',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_fact_return
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
    created_at              TIMESTAMP(3),
    updated_at              TIMESTAMP(3),
    deleted_at              TIMESTAMP(3),
    start_time              TIMESTAMP(3),
    end_time                TIMESTAMP(3),
    is_valid                int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_return',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_fact_return_detail
(
    order_id             varchar(128),
    return_id            varchar(128),
    product_code         varchar(128),
    return_quantity      varchar(128),
    product_price        varchar(128),
    product_return_price varchar(128),
    created_at           TIMESTAMP(3),
    updated_at           TIMESTAMP(3),
    deleted_at           TIMESTAMP(3),
    start_time           TIMESTAMP(3),
    end_time             TIMESTAMP(3),
    is_valid             int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_return_detail',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_user
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
    created_at       TIMESTAMP(3),
    updated_at       TIMESTAMP(3),
    deleted_at       TIMESTAMP(3),
    start_time       TIMESTAMP(3),
    end_time         TIMESTAMP(3),
    is_valid         int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_user',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );


create table `raw`.t_dim_product
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
    created_at         TIMESTAMP(3),
    updated_at         TIMESTAMP(3),
    deleted_at         TIMESTAMP(3),
    start_time         TIMESTAMP(3),
    end_time           TIMESTAMP(3),
    is_valid           int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_product',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_product_sku
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
    created_at            TIMESTAMP(3),
    updated_at            TIMESTAMP(3),
    deleted_at            TIMESTAMP(3),
    start_time            TIMESTAMP(3),
    end_time              TIMESTAMP(3),
    is_valid              int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_product_sku',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_product_package
(
    product_code         varchar(128),
    product_type         varchar(128),
    product_package_code varchar(128),
    product_package_name varchar(128),
    product_color        varchar(128),
    created_at           TIMESTAMP(3),
    updated_at           TIMESTAMP(3),
    deleted_at           TIMESTAMP(3),
    start_time           TIMESTAMP(3),
    end_time             TIMESTAMP(3),
    is_valid             int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_product_package',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_package_sku
(
    product_package_code varchar(128),
    product_package_name varchar(128),
    product_sku_code     varchar(128),
    product_sku_name     varchar(128),
    product_sku_quantity varchar(128),
    created_at           TIMESTAMP(3),
    updated_at           TIMESTAMP(3),
    deleted_at           TIMESTAMP(3),
    start_time           TIMESTAMP(3),
    end_time             TIMESTAMP(3),
    is_valid             int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_package_sku',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_product_price
(
    product_code    varchar(128),
    product_price   decimal,
    product_channel varchar(128),
    created_at      TIMESTAMP(3),
    updated_at      TIMESTAMP(3),
    deleted_at      TIMESTAMP(3),
    start_time      TIMESTAMP(3),
    end_time        TIMESTAMP(3),
    is_valid        int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_product_price',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_campaign
(
    campaign_code       varchar(128),
    campaign_name       varchar(128),
    campaign_start_time TIMESTAMP(3) NOT NULL,
    campaign_end_time   TIMESTAMP(3) NOT NULL,
    created_at          TIMESTAMP(3),
    updated_at          TIMESTAMP(3),
    deleted_at          TIMESTAMP(3),
    start_time          TIMESTAMP(3),
    end_time            TIMESTAMP(3),
    is_valid            int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_campaign',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );


create table `raw`.t_dim_promotion
(
    promotion_code       varchar(128),
    promotion_name       varchar(128),
    campaign_code        varchar(128),
    campaign_name        varchar(128),
    promotion_start_time TIMESTAMP(3) NOT NULL,
    promotion_end_time   TIMESTAMP(3) NOT NULL,
    created_at           TIMESTAMP(3),
    updated_at           TIMESTAMP(3),
    deleted_at           TIMESTAMP(3),
    start_time           TIMESTAMP(3),
    end_time             TIMESTAMP(3),
    is_valid             int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_promotion',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );


create table `raw`.t_dim_promotion_sku
(
    promotion_code   varchar(128),
    promotion_name   varchar(128),
    product_sku_code varchar(128),
    product_sku_name varchar(128),
    is_active        varchar(128),
    created_at       TIMESTAMP(3),
    updated_at       TIMESTAMP(3),
    deleted_at       TIMESTAMP(3),
    start_time       TIMESTAMP(3),
    end_time         TIMESTAMP(3),
    is_valid         int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_promotion_sku',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_fact_user_promotion_record
(
    user_id        varchar(128),
    promotion_id   varchar(128),
    promotion_code varchar(128),
    order_id       varchar(128),
    created_at     TIMESTAMP(3),
    updated_at     TIMESTAMP(3),
    deleted_at     TIMESTAMP(3),
    start_time     TIMESTAMP(3),
    end_time       TIMESTAMP(3),
    is_valid       int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_user_promotion_record',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_dim_coupon
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
    coupon_distribute_start_time TIMESTAMP(3) NOT NULL,
    coupon_distribute_end_time   TIMESTAMP(3) NOT NULL,
    coupon_start_time            TIMESTAMP(3) NOT NULL,
    coupon_end_time              TIMESTAMP(3) NOT NULL,
    coupon_create_time           TIMESTAMP(3) NOT NULL,
    created_at                   TIMESTAMP(3),
    updated_at                   TIMESTAMP(3),
    deleted_at                   TIMESTAMP(3),
    start_time                   TIMESTAMP(3),
    end_time                     TIMESTAMP(3),
    is_valid                     int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_dim_coupon',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );



create table `raw`.t_fact_coupon_receive
(
    coupon_require_id   varchar(128),
    user_id             varchar(128),
    coupon_code         varchar(128),
    coupon_acquire_time varchar(128),
    coupon_acquire_type varchar(128),
    coupon_use_status   varchar(128),
    created_at          TIMESTAMP(3),
    updated_at          TIMESTAMP(3),
    deleted_at          TIMESTAMP(3),
    start_time          TIMESTAMP(3),
    end_time            TIMESTAMP(3),
    is_valid            int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_coupon_receive',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );


create table `raw`.t_fact_coupon_write_off
(
    coupon_require_id  varchar(128),
    order_id           varchar(128),
    coupon_code        varchar(128),
    coupon_redeem_time varchar(128),
    coupon_redeem_type varchar(128),
    coupon_use_status  varchar(128),
    created_at         TIMESTAMP(3),
    updated_at         TIMESTAMP(3),
    deleted_at         TIMESTAMP(3),
    start_time         TIMESTAMP(3),
    end_time           TIMESTAMP(3),
    is_valid           int
) WITH (
      'connector' = 'hudi',
      'path' = '/data/raw/t_fact_coupon_write_off',
      'table.type' = 'MERGE_ON_READ',
      'read.streaming.enabled' = 'true',
      'write.batch.size' = '100',
      'write.tasks' = '1',
      'compaction.tasks' = '1',
      'compaction.delta_seconds' = '60',
      'write.precombine.field' = 'updated_at',
      'read.tasks' = '1',
      'read.streaming.check-interval' = '60',
      'read.streaming.start-commit' = '20210816000000',
      );




