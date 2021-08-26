package com.github.izhangzhihao

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.functions.{col, lit}
import org.apache.spark.sql.streaming.Trigger

object CDC {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder()
      .master("local[*]")
      .appName("CDC")
      .getOrCreate()

    import org.apache.spark.sql._
    import spark.implicits._

    val inputSchema = implicitly[Encoder[Payload]].schema

    val inputDF = spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", "127.0.0.1:9092")
      .option("subscribe", "pg_claims.claims.members")
      .option("startingOffsets", "earliest")
      .load()


    import org.apache.spark.sql._


    val extractedDF = inputDF
      .selectExpr("CAST(value AS STRING)")
      .select(functions.from_json($"value", inputSchema).as("data"))
      .select(functions.from_json($"data.after", implicitly[Encoder[Member]].schema).as("member"))
      .select(
        col("member.id"),
        col("member.c_d_id"),
        col("member.last_name"),
        col("member.address"),
        col("member.address_city"),
        col("member.address_country"),
        col("member.insurance_company"),
        col("member.insurance_number"),
        col("member.ts_created"),
        col("member.ts_updated")
          as 'row)


    writeAsDelta("./data/staging/" + "members", extractedDF).awaitTermination()

    //spark.read.format("delta").load("./data/staging/members").show()


    def writeAsDelta(deltaTableName: String, df: DataFrame) = {
      val query = df
        .writeStream
        .trigger(Trigger.ProcessingTime("5 seconds"))
        .foreachBatch { (batchDF: DataFrame, batchID: Long) =>
          println(s"Writing to Delta $batchID")
          batchDF.write
            .format("delta")
            .mode("append")
            .save(deltaTableName)
        }
        .outputMode("update")
        .start()
      query
    }
  }
}
