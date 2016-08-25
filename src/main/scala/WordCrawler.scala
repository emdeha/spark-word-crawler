/* WordCrawler.scala */
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.streaming._
import org.apache.spark.streaming.dstream._
import org.apache.spark.mllib.linalg.Vectors

object WordCrawler {
  def replaceEmpty(s: String): String = {
    if (s.isEmpty) "0" else s
  }

  def main(args: Array[String]) {
    val conf = new SparkConf().setMaster("local[2]").setAppName("WordCrawler")
    val ssc = new StreamingContext(conf, Seconds(1))

    val lines = ssc.socketTextStream("localhost", 1337)
    lines.flatMap(_.split("\n")).foreachRDD(line => {
      // TODO: Replace empty values with zeroes
      //       Parse as vector
      //       Specify time to train
      //       Use KMeans
      // val parsed = line.flatMap(_.split(",")).map(replaceEmpty(_))/* .fold("")(_ ++ "," ++ _) */.map(Vectors.parse)
      val parsed = line.map(s => Vectors.dense(s.split(',').map(replaceEmpty(_)).map(_.toDouble))).cache()
      parsed.foreach(println)
      println("--- batch done ---")
    })

    ssc.start()
    ssc.awaitTermination()
  }
}
