#!/usr/bin/env bash
set -x

tmp_dir=`date +%Y%m%d%H%M`
output_dir=~/nfs/download/logstash/${tmp_dir}
current_dir=~/nfs/download/logstash/current
JAVA_HOME=`pwd`/jdk1.6.0_27_x64
PATH=${JAVA_HOME}/bin:$PATH

if [ ! -d "${JAVA_HOME}" ]; then
  wget -q http://download.aqueducts.baidu.com/jdk_1.6.tar.gz && tar xzf jdk_1.6.tar.gz &&  rm -f jdk_1.6.tar.gz
fi

mkdir -p ${tmp_dir} ${output_dir}
cd ${tmp_dir}

git clone -b aqueducts http://gitlab.baidu.com/qudongfang/logstash.git
cd logstash && make flatjar
cp ./build/logstash-* ${output_dir} && cd ../
rm -f ${current_dir} && ln -s ${output_dir} ${current_dir}

git clone -b aqueducts http://gitlab.baidu.com/qudongfang/logstash-kafka.git
cd logstash-kafka && make flatjar
mkdir -p ~/nfs/download/logstash/${tmp_dir}/ && cp -f ./build/logstash-* ${outout_dir}