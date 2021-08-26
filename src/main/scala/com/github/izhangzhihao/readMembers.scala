package com.github.izhangzhihao

import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.streaming.Trigger

object readMembers {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder()
      .master("local[*]")
      .appName("CDC")
      .getOrCreate()

    import org.apache.spark.sql._
    import spark.implicits._

    val df = spark.read.format("delta").load("./data/staging/members")

    df.show()
  }
}
