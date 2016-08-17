# Spark Word Crawler
Apache Spark analyisis of paragraphs in websites

## Project setup

1. Install Apache Spark
2. Modify `exec.sh` and `prepare.sh` to use your Spark's install directory
3. Install and run `sbt package`

## Project startup

1. Run `prepare.sh` to startup the Spark back-end
2. Run `exec.sh WordCrawler target/scala-2.10/word-crawler-project_2.10-1.0.jar`
