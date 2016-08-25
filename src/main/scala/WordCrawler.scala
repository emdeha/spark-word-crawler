/* WordCrawler.scala */
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.streaming._
import org.apache.spark.streaming.dstream._
import org.apache.spark.mllib.linalg.{Vectors, Vector}
import org.apache.spark.mllib.clustering.StreamingKMeans

object WordCrawler {
  def replaceEmpty(s: String): String = {
    if (s.isEmpty) "0" else s
  }

  def toLabelVectorTup(s: String): (Double, Vector) = {
    val parts = s.split(',')
    val label = parts(0).toDouble
    val features = parts.tail.map(replaceEmpty(_)).map(_.toDouble)
    (label, Vectors.dense(features))
  }

  def main(args: Array[String]) {
    if (args.length != 1) {
      println("Usage: WordCrawler <train_data_file>")
      return
    }

    val conf = new SparkConf().setMaster("local[2]").setAppName("WordCrawler")
    val ssc = new StreamingContext(conf, Seconds(1))

    val trainingData = ssc.textFileStream(args(0)).map(Vectors.parse)

    val lines = ssc.socketTextStream("localhost", 1337)
    val testData = lines
      .flatMap(_.split("\n"))
      .map(toLabelVectorTup)
      .cache()

    val model = new StreamingKMeans()
      .setK(3)
      .setDecayFactor(1.0)
      .setRandomCenters(4, 0.0)

    model.trainOn(trainingData)
    model.predictOnValues(testData).print()

    ssc.start()
    ssc.awaitTermination()
  }
}
