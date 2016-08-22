/* WordCrawler.scala */
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.streaming._
import org.apache.spark.streaming.dstream._
import org.apache.spark.sql._

object WordCrawler {
  case class Paragraph(url: String, data: String)

  def isComma(ch: Char) = ch == ','

  def parse(line: String) = {
    val url = line.takeWhile(!isComma(_))
    val data = line.dropWhile(!isComma(_))
    Paragraph(url, data.tail)
  }

  def main(args: Array[String]) {
    val conf = new SparkConf().setMaster("local[2]").setAppName("WordCrawler")
    val ssc = new StreamingContext(conf, Seconds(1))

    val lines = ssc.socketTextStream("localhost", 1337)
    lines.flatMap(_.split("\n")).foreachRDD(line => {
      val parsed = line.map(parse)
      parsed.foreach(println)
    })

    ssc.start()
    ssc.awaitTermination()
  }
}
