/* WordCrawler.scala */
import org.apache.spark._
import org.apache.spark.rdd._
import org.apache.spark.streaming._
import org.apache.spark.streaming.dstream._
import org.apache.spark.mllib.linalg.{Vectors, Vector}
import org.apache.spark.mllib.clustering.{StreamingKMeans, KMeans, KMeansModel}

object WordCrawler {
  def replaceEmpty(s: String): String = {
    if (s.isEmpty) "0" else s
  }

  def customSplit(s: String, d: Char): Array[String] = {
    if (s.isEmpty) return Array()

    val part = s.takeWhile(!_.equals(d))
    val rest = s.dropWhile(!_.equals(d))
    if (rest.length == 1) return Array(part, "")
    if (rest.length == 0) return Array(part)

    Array(part) ++ customSplit(s.dropWhile(!_.equals(d)).tail, d)
  }

  def toVectors(s: String): Vector = {
    val features = customSplit(s, ',').map(replaceEmpty(_)).map(_.toDouble)
    Vectors.dense(features)
  }

  def toHostPort(arg: String): Tuple2[String, Int] = {
    val hostPort = arg.split(':')
    (hostPort(0), hostPort(1).toInt)
  }

  def main(args: Array[String]) {
    if (args.length != 2) {
      println(args.mkString(","))
      println("Usage: WordCrawler <training_host>:<training_port> <monitoring_host>:<monitoring_port>")
      return
    }

    val conf = new SparkConf().setMaster("local[2]").setAppName("WordCrawler")
    val model = new StreamingKMeans()
      .setK(3)
      .setDecayFactor(1.0)
      .setRandomCenters(11, 0.0)

    // Set training of the model
    val ssc = new StreamingContext(conf, Seconds(1))
    val (trainHost, trainPort) = toHostPort(args(0))
    val trainLines = ssc.socketTextStream(trainHost, trainPort)
    val trainingData = trainLines
      .map(toVectors)
      .cache()
    model.trainOn(trainingData)

    // Make predictions
    val (monitHost, monitPort) = toHostPort(args(1))
    val predLines = ssc.socketTextStream(monitHost, monitPort)
    val predictionData = predLines
      .map(toVectors)
      .cache()

    model.predictOn(predictionData).print()

    ssc.start()
    ssc.awaitTermination()
  }
}
