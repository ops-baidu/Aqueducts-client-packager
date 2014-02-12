#!/bin/bash
set -x

project=Aqueducts
version=1.0.0

project_path=/opt/${project}
rm -rf ${project_path}
install_path=${project_path}/embedded
cache_path=${project_path}/cache
src_path=${project_path}/src
pkg_path=${project_path}/pkg

LDFLAGS="-L${install_path}/lib -I${install_path}/include"
CFLAGS="-I${install_path}/include -L${install_path}/lib"
export LDFLAGS CFLAGS

rm -rf ${project_path}
mkdir -p ${install_path} ${cache_path} ${src_path} ${pkg_path}

## 1: bin
softwares=(
yaml-0.1.4
ruby-1.9.3-p484
)

remote_addrs=(
http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
http://ruby.taobao.org/mirrors/ruby/1.9/ruby-1.9.3-p484.tar.gz
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

# 2: rubygems
software=rubygems-1.8.24
wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz -P ${cache_path}
cd ${cache_path}
tar -xzvf ${software}.tgz
cd ${cache_path}/${software}
${install_path}/bin/ruby setup.rb

## 3: gems
gems=(
fluentd
zookeeper
consistent-hashing
fluent-plugin-redis-publish
rest-client
poseidon
mime-types
)

index=0
while [ "${index}" -lt "${#gems[@]}" ] ; do
  gem=${gems[${index}]}
  ${install_path}/bin/gem install ${gem} --no-rdoc --no-ri 
  ((index++))
done

## 4: gems from git
source_gems=(
fluent-plugin-kafka
fpm
)

index=0
while [ "${index}" -lt "${#source_gems[@]}" ] ; do
  gem=${source_gems[${index}]}
  cd ${src_path}
  git clone git://github.com/ops-baidu/${gem}.git
  cd ${gem}
  ${install_path}/bin/gem build ${gem}.gemspec
  ${install_path}/bin/gem install -l ${src_path}/${gem}/${gem}-*.gem --no-rdoc --no-ri
  ((index++))
done

${install_path}/bin/gem install fpm --no-rdoc --no-ri 

rm -rf ${cache_path} ${src_path} ${install_path}/share

cd 
${install_path}/bin/fpm -s dir -t rpm -n "${project}" -v ${version} ${project_path} 
