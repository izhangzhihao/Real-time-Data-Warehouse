val sparkVersion = "3.1.2"



lazy val root = project
  .in(file("."))
  .settings(
    name := "Real-time-Data-Warehouse",
    version := "0.1.0",

    scalaVersion := "2.12.14",

    libraryDependencies ++= Seq(
      "org.apache.spark" %% "spark-core" % sparkVersion,
      "org.apache.spark" %% "spark-sql" % sparkVersion,
      "org.apache.spark" %% "spark-sql-kafka-0-10" % sparkVersion,
      "org.apache.spark" %% "spark-streaming-kafka-0-10" % sparkVersion,
      "io.delta" %% "delta-core" % "1.0.0"
    )
  )