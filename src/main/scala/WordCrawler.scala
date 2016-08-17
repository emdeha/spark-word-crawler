/* WordCrawler.scala */
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.streaming._
import org.apache.spark.streaming.dstream._
import org.apache.spark.sql._

object WordCrawler {
  def main(args: Array[String]) {
    val conf = new SparkConf().setMaster("local[2]").setAppName("TextProcApp")
    val ssc = new StreamingContext(conf, Seconds(10))

    val lines = ssc.socketTextStream("localhost", 1337)
    val words = lines.flatMap(_.split(" "))
    words.foreachRDD { rdd =>
      val sqlCtx = SQLContext.getOrCreate(rdd.sparkContext)
      import sqlCtx.implicits._

      rdd.toDF("words").show()
    }

    ssc.start()
    ssc.awaitTermination()
  }
}
