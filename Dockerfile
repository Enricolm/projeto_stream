FROM python:3.10-bullseye AS spark-base

ENV SPARK_VERSION=3.5.5
ENV HADOOP_VERSION=3

ARG SPARK_DIR="/opt/spark"
ARG HADOOP_DIR="/opt/hadoop"

ENV SPARK_HOME=${SPARK_DIR}
ENV SPARK_NO_DAEMONIZE=true
ENV HADOOP_HOME=${HADOOP_DIR}
ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      vim \
      unzip \
      rsync \
      openjdk-11-jdk \
      build-essential \
      software-properties-common \
      ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p "$HADOOP_HOME" "$SPARK_HOME"

RUN mkdir -p /opt/spark/spark-events

WORKDIR $SPARK_HOME

RUN curl https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark-${SPARK_VERSION}-bin-hadoop3.tgz \
 && tar xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory $SPARK_HOME --strip-components 1 \
 && rm -rf spark-${SPARK_VERSION}-bin-hadoop3.tgz

COPY requirements.txt . 
RUN pip install --no-cache-dir -r requirements.txt && pip install notebook ipykernel

ENV PATH="$SPARK_HOME/sbin:$SPARK_HOME/bin:${PATH}"
ENV PYSPARK_PYTHON python3

COPY spark-defaults.conf "$SPARK_HOME/conf"

RUN chmod -R 755 /opt/spark

COPY entrypoint.sh /opt/spark/

RUN chmod +x /opt/spark/entrypoint.sh && chmod -R 755 /opt/spark

ENTRYPOINT ["/opt/spark/entrypoint.sh"]
CMD ["bash"]

EXPOSE 8888
