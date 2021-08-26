package com.github.izhangzhihao


case class DebeziumEvent(payload: Payload)
case class Payload(op: String, source: Source, before: String, after: String)
case class Source(ts_ms: Long, lsn: Long, table: String)
case class Member(id: Int,
                  c_d_id: Float,
                  first_name: String,
                  last_name: String,
                  address: String,
                  address_city: String,
                  address_country: String,
                  insurance_company: String,
                  insurance_number: String,
                  ts_created: String,
                  ts_updated: String)

case class AccidentClaims(claim_id: Int,
                          claim_total: Float,
                          claim_total_receipt: String,
                          claim_currency: String,
                          member_id: Int,
                          accident_date: String,
                          accident_type: String,
                          accident_detail: String,
                          claim_date: String,
                          claim_status: String,
                          ts_created: String,
                          ts_updated: String
                         )