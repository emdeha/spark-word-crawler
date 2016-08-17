DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# perl $DIR/broker.pl &
$HOME/Downloads/spark-1.6.2-bin-hadoop2.6/bin/spark-submit --class $1 $2 2>$1.log
