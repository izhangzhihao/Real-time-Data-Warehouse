-- SET 'sql-client.execution.result-mode' = 'changelog';
-- select id,order_id,delivery_code,start_time,end_time,is_valid from `raw`.t_fact_online_order;

INSERT
OVERWRITE `raw`.t_fact_online_order
SELECT *
FROM (
         SELECT R.id,
                R.order_id,
                R.user_id,
                R.user_name,
                R.order_total_amount,
                R.actual_amount,
                R.post_amount,
                R.order_pay_amount,
                R.total_discount,
                R.pay_type,
                R.source_type,
                R.order_status,
                R.note,
                R.confirm_status,
                R.payment_time,
                R.delivery_time,
                R.receive_time,
                R.comment_time,
                R.delivery_company,
                R.delivery_code,
                R.business_date,
                R.return_flag,
                R.created_at,
                R.updated_at,
                R.deleted_at,
                if(S.updated_at IS NULL, TO_TIMESTAMP('1000-01-01 00:00:00'), R.updated_at) AS start_time,
                S.updated_at                                                                AS end_time,
                0                                                                           AS is_valid
         FROM `raw`.t_fact_online_order AS R
                  INNER JOIN staging.t_fact_online_order AS S
                             ON R.order_id = S.order_id
         WHERE R.is_valid = 1
         UNION ALL
         SELECT UUID()                          as id,
                S.order_id,
                S.user_id,
                S.user_name,
                CAST(S.order_total_amount AS DECIMAL),
                CAST(S.actual_amount AS DECIMAL),
                CAST(S.post_amount AS DECIMAL),
                CAST(S.order_pay_amount AS DECIMAL),
                CAST(S.total_discount AS DECIMAL),
                S.pay_type,
                S.source_type,
                S.order_status,
                S.note,
                S.confirm_status,
                CAST(S.payment_time AS TIMESTAMP),
                CAST(S.delivery_time AS TIMESTAMP),
                CAST(S.receive_time AS TIMESTAMP),
                CAST(S.comment_time AS TIMESTAMP),
                S.delivery_company,
                S.delivery_code,
                CAST(S.business_date AS DATE),
                S.return_flag,
                CAST(S.created_at AS TIMESTAMP),
                CAST(S.updated_at AS TIMESTAMP),
                CAST(S.deleted_at AS TIMESTAMP),
                CAST(S.updated_at AS TIMESTAMP) AS start_time,
                CAST('9999-12-31 00:00:00' AS TIMESTAMP),
                1                               AS is_valid
         FROM staging.t_fact_online_order AS S
     ) AS UPDATE_AND_NEW;