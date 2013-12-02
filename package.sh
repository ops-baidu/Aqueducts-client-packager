#!/bin/bash

project=Aqueducts
version=1.0.0

project_path=/opt/${project}
install_path=${project_path}/embedded
cache_path=${project_path}/cache
src_path=${project_path}/src
pkg_path=${project_path}/pkg

LDFLAGS="-L${install_path}/lib -I${install_path}/include"
CFLAGS="-I${install_path}/include -L${install_path}/lib"
export LDFLAGS CFLAGS

mkdir -p ${install_path} ${cache_path} ${src_path} ${pkg_path}

## 1: bin
softwares=(
yaml-0.1.4
ruby-1.9.3-p448
)

remote_addrs=(
http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p448.tar.gz
)

software_count=${#softwares[@]}
index=0

while [ "${index}" -lt "${software_count}" ] ; do
  software=${softwares[${index}]}
  remote_addr=${remote_addrs[${index}]}

  wget ${remote_addr} -P ${cache_path}
  cd ${cache_path}
  tar -xzf ${software}.tar.gz
    cd ${software}
    ./configure --prefix=${install_path}
    make -j 3
    make -j 3 install
  
  ((index++))
done 

## 2: rubygems
#software=rubygems-1.8.24
#wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz -P ${cache_path}
#cd ${cache_path}
#gzip ${software}.tgz 
#tar -xvf ${software}.tar
#cd ${cache_path}/${software}
#${install_path}/bin/ruby setup.rb

## 3: gems
gems=(
fluentd
zookeeper
consistent-hashing
fluent-plugin-redis-publish
)

index=0
while [ "${index}" -lt "${#gems[@]}" ] ; do
  gem=${gems[${index}]}
  ${install_path}/bin/gem install ${gem} --no-rdoc --no-ri 
  ((index++))
done

## 4: gems from git
source_gems=(
kafka-rb
fluent-plugin-kafka
)

index=0
while [ "${index}" -lt "${#source_gems[@]}" ] ; do
  gem=${source_gems[${index}]}
  cd ${src_path}
  git clone http://github.com/ops-baidu/${gem}.git
  cd ${gem}
  ${install_path}/bin/gem build ${gem}.gemspec
  ${install_path}/bin/gem install -l ${src_path}/${gem}/${gem}-*.gem
  ((index++))
done

fpm -s dir -t rpm -n "${project}" -v ${version} --prefix ${project_path} 
