# coding: UTF-8 
# Cookbook Name:: flume collector
# Attributes:: default
default["flume_collector"]["version"] = "1.8.0"
default["flume_collector"]["download_url"] = "http://52.77.221.71/flume/apache-flume-1.8.0-bin.tar.gz"
default["flume_collector"]["base_dir"]  = "/opt/grab"
default["flume_collector"]["spool_dir"]  = "/data/d1/flume/spool"
default["flume_collector"]["pid_dir"]  = "/var/run/flume"
default["flume_collector"]["graphitehost"]  = "13.250.12.97"


# Kafka Brokers in each colo
default["flume_collector"]["kafka_brokers"]['grab']  = "172.31.0.228:9092,172.31.27.143:9092,172.31.40.42:9092"

# Zookeeper Quorum in each colo
default["flume_collector"]["kafka_zookeeper"]['grab']  = "172.31.0.228:2181,172.31.27.143:2181,172.31.40.42:2181"

