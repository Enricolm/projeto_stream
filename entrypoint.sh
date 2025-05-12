#!/bin/bash

SPARK_WORKLOAD=$1

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"

if [ "$SPARK_WORKLOAD" == "master" ]; then
  exec start-master.sh -p 7077 --webui-port 9090

elif [ "$SPARK_WORKLOAD" == "worker" ]; then
  exec start-worker.sh spark://spark-master:7077

elif [ "$SPARK_WORKLOAD" == "history" ]; then
  export SPARK_HISTORY_OPTS="-Dspark.history.fs.logDirectory=file:/opt/spark/spark-events -Dspark.history.ui.port=18080"
  exec start-history-server.sh

elif [ "$SPARK_WORKLOAD" == "jupyter" ]; then
  echo "Starting Jupyter Notebook..."
  jupyter notebook --notebook-dir=/opt/spark/apps \
                   --ip=0.0.0.0 \
                   --port=8888 \
                   --no-browser \
                   --allow-root

elif [ "$SPARK_WORKLOAD" == "spark-submit" ]; then
  echo "Running spark-submit with arguments: ${@:2}"
  exec spark-submit "${@:2}"

else
  echo "Unknown SPARK_WORKLOAD: $SPARK_WORKLOAD"
  exit 1
fi
