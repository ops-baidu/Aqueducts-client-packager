aqueducts项目日志数据采集agent，基于logstash，数据发布到kafka。

修改点：

1. logstash/input/file 增加host in_time字段，删除path字段，设置默认stat_interval = 0.75,即750ms
2. logstash/input/file 依赖ruby-filewatch gem，修改tail.rb中sysread buffer，减少发送延迟，提高发送能力
3. logstash/input/file 读取文件数据依赖libffi.so，jar包中默认libffi.so依赖glibc 2.5, RHEL 4.4无法启动，重新编译libffi.so，替换
4. logstash/output/kafka jruby-kafka异步发送，从zk获取kafka broker最新机器列表
5. logstash/output/kafka 自动附加host idc ip product service 字段
