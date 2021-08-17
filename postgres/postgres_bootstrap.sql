-- This extension provides a function to generate a version 4 UUID, we must enable the extension first.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

create table online_order
(
    order_id           UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    user_id            varchar(128)     NOT NULL,
    user_name          varchar(128)     NOT NULL,
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
    business_date      date                      DEFAULT CURRENT_DATE,
    return_flag        varchar(128),
    created_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at         timestamp
);

ALTER TABLE online_order
    REPLICA IDENTITY FULL;

create table online_order_detail
(
    id                    UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    order_id              varchar(128),
    product_code          varchar(128),
    product_name          varchar(128),
    product_type          varchar(128),
    product_quantity      int,
    product_pic           varchar(128),
    product_amount        decimal,
    product_actual_amount decimal,
    created_at            timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at            timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at            timestamp
);

ALTER TABLE online_order_detail
    REPLICA IDENTITY FULL;


create table store
(
    store_id        UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    store_name      varchar(128),
    owner_id        varchar(128),
    owner_name      varchar(128),
    store_province  varchar(128),
    store_city      varchar(128),
    store_county    varchar(128),
    store_address   varchar(128),
    store_open_time varchar(128),
    created_at      timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at      timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at      timestamp
);

ALTER TABLE store
    REPLICA IDENTITY FULL;


create table offline_order
(
    store_order_id     UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    user_id            varchar(128),
    store_id           varchar(128),
    store_name         varchar(128),
    pos_id             varchar(128),
    seq_number         bigint,
    business_date      date                      DEFAULT CURRENT_DATE,
    payment_time       timestamp,
    operator_id        varchar(128),
    operator_name      varchar(128),
    order_total_amount decimal,
    actual_amount      timestamp,
    order_pay_amount   timestamp,
    total_discount     timestamp,
    return_flag        varchar(128),
    created_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at         timestamp
);

ALTER TABLE offline_order
    REPLICA IDENTITY FULL;


create table offline_order_detail
(
    id                    UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    order_id              varchar(128),
    product_code          varchar(128),
    product_name          varchar(128),
    product_type          varchar(128),
    product_quantity      int,
    product_amount        decimal,
    product_actual_amount decimal,
    created_at            timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at            timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at            timestamp
);

ALTER TABLE offline_order_detail
    REPLICA IDENTITY FULL;


create table delivery
(
    order_id                varchar(128),
    delivery_no             UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
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
    created_at              timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at              timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at              timestamp
);

ALTER TABLE delivery
    REPLICA IDENTITY FULL;


create table return
(

    order_id                varchar(128),
    return_id               UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    return_application_time varchar(128),
    return_amount           varchar(128),
    return_status           varchar(128),
    return_type             varchar(128),
    return_reason           varchar(128),
    return_address          varchar(128),
    return_delivery_company varchar(128),
    return_delivery_code    varchar(128),
    created_at              timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at              timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at              timestamp
);

ALTER TABLE return
    REPLICA IDENTITY FULL;


create table return_detail
(
    id                   UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    order_id             varchar(128),
    return_id            varchar(128),
    product_code         varchar(128),
    return_quantity      varchar(128),
    product_price        varchar(128),
    product_return_price varchar(128),
    created_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at           timestamp
);

ALTER TABLE return_detail
    REPLICA IDENTITY FULL;


create table "user"
(
    user_id          UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
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
    created_at       timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at       timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at       timestamp
);

ALTER TABLE "user"
    REPLICA IDENTITY FULL;

create table product
(
    product_code       UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    product_name       varchar(128),
    product_type       varchar(128),
    product_type2      varchar(128),
    product_pic        varchar(128),
    product_brand      varchar(128),
    product_attribute1 varchar(128),
    product_status     varchar(128),
    product_channel    varchar(128),
    created_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at         timestamp
);

ALTER TABLE product
    REPLICA IDENTITY FULL;


create table product_sku
(
    product_code          UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    product_sku_code      varchar(128),
    product_sku_name      varchar(128),
    product_type          varchar(128),
    product_color         varchar(128),
    product_net_content   varchar(128),
    product_sp_code       varchar(128),
    product_sp_name       varchar(128),
    product_sp_short_name varchar(128),
    created_at            timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at            timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at            timestamp
);

ALTER TABLE product_sku
    REPLICA IDENTITY FULL;


create table product_package
(
    product_code         UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    product_type         varchar(128),
    product_package_code varchar(128),
    product_package_name varchar(128),
    product_color        varchar(128),
    created_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at           timestamp
);

ALTER TABLE product_package
    REPLICA IDENTITY FULL;


create table package_sku
(
    id                   UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    product_package_code varchar(128),
    product_package_name varchar(128),
    product_sku_code     varchar(128),
    product_sku_name     varchar(128),
    product_sku_quantity varchar(128),
    created_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at           timestamp
);

ALTER TABLE package_sku
    REPLICA IDENTITY FULL;


create table product_price
(
    id              UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    product_code    varchar(128),
    product_price   decimal,
    product_channel varchar(128),
    created_at      timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at      timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at      timestamp
);

ALTER TABLE product_price
    REPLICA IDENTITY FULL;


create table campaign
(
    campaign_code       UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    campaign_name       varchar(128),
    campaign_start_time timestamp        NOT NULL,
    campaign_end_time   timestamp        NOT NULL,
    created_at          timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at          timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at          timestamp
);

ALTER TABLE campaign
    REPLICA IDENTITY FULL;

create table promotion
(
    promotion_code       UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    promotion_name       varchar(128),
    campaign_code        varchar(128),
    campaign_name        varchar(128),
    promotion_start_time timestamp        NOT NULL,
    promotion_end_time   timestamp        NOT NULL,
    created_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at           timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at           timestamp
);

ALTER TABLE promotion
    REPLICA IDENTITY FULL;

create table promotion_sku
(
    id               UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    promotion_code   varchar(128),
    promotion_name   varchar(128),
    product_sku_code varchar(128),
    product_sku_name varchar(128),
    is_active        varchar(128),
    created_at       timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at       timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at       timestamp
);

ALTER TABLE promotion_sku
    REPLICA IDENTITY FULL;


create table user_promotion_record
(
    id             UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    user_id        varchar(128),
    promotion_id   varchar(128),
    promotion_code varchar(128),
    order_id       varchar(128),
    created_at     timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at     timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at     timestamp
);

ALTER TABLE user_promotion_record
    REPLICA IDENTITY FULL;


create table coupon
(
    coupon_code                  UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    coupon_name                  varchar(128),
    campaign_code                varchar(128),
    coupon_acquire_type          varchar(128),
    coupon_pay_type              varchar(128),
    coupon_channel               varchar(128),
    coupon_discount              varchar(128),
    coupon_number                bigint,
    coupon_limit                 bigint,
    coupon_distribute_start_time timestamp        NOT NULL,
    coupon_distribute_end_time   timestamp        NOT NULL,
    coupon_start_time            timestamp        NOT NULL,
    coupon_end_time              timestamp        NOT NULL,
    coupon_create_time           timestamp        NOT NULL,
    created_at                   timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at                   timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at                   timestamp
);

ALTER TABLE coupon
    REPLICA IDENTITY FULL;


create table coupon_receive
(
    coupon_require_id   UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    user_id             varchar(128),
    coupon_code         varchar(128),
    coupon_acquire_time varchar(128),
    coupon_acquire_type varchar(128),
    coupon_use_status   varchar(128),
    created_at          timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at          timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at          timestamp
);

ALTER TABLE coupon_receive
    REPLICA IDENTITY FULL;

create table coupon_write_off
(
    coupon_require_id  UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    order_id           varchar(128),
    coupon_code        varchar(128),
    coupon_redeem_time varchar(128),
    coupon_redeem_type varchar(128),
    coupon_use_status  varchar(128),
    created_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    updated_at         timestamp                 DEFAULT CURRENT_TIMESTAMP,
    deleted_at         timestamp
);

ALTER TABLE coupon_write_off
    REPLICA IDENTITY FULL;



COMMIT;
