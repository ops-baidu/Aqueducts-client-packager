#!/usr/bin/env bash

tmp_dir=`date +%Y%m%d%H%M`
mkdir ${tmp_dir}
cd ${tmp_dir}

mkdir output src

cd src

wget -q http://download.aqueducts.baidu.com/jdk_1.6.tar.gz && tar xzf jdk_1.6.tar.gz &&  rm -f jdk_1.6.tar.gz
JAVA_HOME=`pwd`/jdk1.6.0_27_x64
PATH=${JAVA_HOME}/bin:$PATH

#git clone http://gitlab.baidu.com/qudongfang/logstash.git && git checkout aqueducts
git clone -b aqueducts --single-branch http://gitlab.baidu.com/qudongfang/logstash.git
cd logstash && make flatjar && cp -f ./build/logstash-*.jar ../output && cd ../

#git clone http://gitlab.baidu.com/qudongfang/logstash-kafka.git && git checkout aqueducts
git clone -b aqueducts --single-branch http://gitlab.baidu.com/qudongfang/logstash-kafka.git
cd logstash-kafka && make flatjar && cp -f ./build/logstash-*.jar ../output && cd ../

cd ../output

mkdir -p ~/nfs/download/${tmp_dir}/
cp -f logstash-kafka-*.jar ~/nfs/download/${tmp_dir}/ 


