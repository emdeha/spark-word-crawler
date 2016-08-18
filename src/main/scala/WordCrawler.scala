/* WordCrawler.scala */
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.streaming._
import org.apache.spark.streaming.dstream._
import org.apache.spark.sql._

object WordCrawler {
  def main(args: Array[String]) {
    val conf = new SparkConf().setMaster("local[2]").setAppName("TextProcApp")
    val ssc = new StreamingContext(conf, Seconds(1))

    val lines = ssc.socketTextStream("localhost", 1337)
    val meanWords = lines.flatMap(_.split(" ")).filter(word => word.length > 3)
    val wordCounts = meanWords.map(word => (word, 1)).reduceByKey(_ + _)
    wordCounts.foreachRDD(rdd => {
      Console.println("\n\n--------\n")
      rdd.sortBy(wc => wc._2, false).take(10).foreach(println)
    })

    ssc.start()
    ssc.awaitTermination()
  }
}
