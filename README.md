# Golang微服务架构演进实践

## 声明
- 本项目为个人项目，内置部分自编组件，请勿在未经允许的前提下使用Releases的产物及源码用于商业用途，若需合作请发送邮件到zhanshen02154@gmail.com联系作者本人。
- 严禁将代码及产物用于非法活动如赌博、诈骗、洗钱等，一经发现将追究法律责任！

## 项目概述
以“订单支付成功回调扣减商品库存”链路进行微服务架构演进的深度实践，总体为事件驱动架构，服务是DDD领域驱动架构，分为订单服务和商品服务（支付服务和订单服务合并以减少服务器的使用降低服务器成本，库存服务同理）。 项目采用Scrum作为迭代管理模型，周期为2周，管理工具
为Github Project。

项目旨在模拟微服务架构演进、项目管理规范及优秀技术实践，包含CI/CD流水线实现自动化部署。从1.0的GRPC跨服务调用到事件驱动架构，最终实现异步通信解耦，摆脱对GRPC客户端的依赖，解决2.0版DTM分布式事务操作
MySQL造成性能急剧下降的问题，用幂等性确保消息不会重复处理，将处理失败/推送失败的数据放入死信队列做回滚操作，保证服务高可用的同时提升系统吞吐量。 各微服务为领域驱动架构，大量使用面向接口编程，除DTM对
顶层业务代码侵入明显以外其余组件均设计为可插拔结构，基础设施层的替换不影响领域层、接口层和应用层。

由于go micro v4无原生支持DTM分布式事务的组件且资料匮乏，故自行编写编解码器适配GRPC模式下的DTM以确保能正常访问GRPC接口。

5.0版本引入Jaeger实现从GRPC请求到发布/订阅事件的监控，并于6.0版细化到对投递消息到死信队列的追踪，调用链路监控进一步完善。

6.0版引入Prometheus实现基本监控，包括kafka、MySQL、ETCD、Redis和微服务的监控，精准定位性能瓶颈，K8S集群仅部署Prometheus Agent用于上报数据，利用阿里云的免费额度实现零成本监控。

6.2开始将Jaeger和ES等可观测性基础设施迁移到阿里云应用监控服务以降低服务器使用成本，退订一台服务器。

## 项目特点
- 实现端到端交付。
- 用事件驱动架构解耦跨服务通信提升吞吐量，最高达1596Qps。
- 6.0.0起转向负载测试，回调接口峰值为761Qps。性能大幅提升。
- 具备服务健康检查。
- 使用自编的事务管理器结合GORM的事务完成事务处理实现数据一致性。
- 配置去中心化，避免对configmap的依赖。
- 依托GitHub结合Jenkins流水线实现CI/CD。
- 将自行编写DTM专用的编解码器植入框架弥补go micro v4无原生支持的问题。
- 修改Go micro v4的broker底层源码以支持带key发布到kafka实现消息顺序消费。
- 用死信队列及幂等性保证系统可靠。

## 技术选型

| 开发语言及工具          | 版本      | 用途                 |
|------------------|---------|--------------------|
| kubernetes       | 1.23.1  | 容器编排               |
| docker           | 20.10.7 | 容器运行               |
| jenkins          | 2.346.1 | CI/CD              |
| MySQL            | 5.7.26  | 数据库                |
| Apisix           | 3.4.1   | API网关              | 
| harbor           | 1.8.6   | docker私有仓库         | 
| golang           | 1.20.10 | 各服务开发语言            | 
| Consul           | 1.7.3   | 服务注册/发现            | 
| ETCD             | 3.5.7   | Apisix、分布式锁        | 
| Go-micro         | 4.11.0  | 各服务开发框架            | 
| Github           | -       | 代码托管和项目管理          | 
| LUA              | -       | 编写Fluent bit过滤器    | 
| Opentelemetry    | -       | 链路追踪               | 
| Fluent bit       | 4.1.0   | 收集Apisix和微服务的日志    | 
| DTM              | 1.19    | 分布式事务              | 
| Kafka            | 3.1.0   | 收集Apisix日志、项目的核心组件 | 
| Prometheus Agent | 2.43    | 收集并上报监控指标          |

## 各服务器组件配置

k8s-master为K8S集群主节点，k8s-node1--3为子节点。

| 组件               | Request           | Limits             | 数量 | 服务器名                              |
|------------------|-------------------|--------------------|----|-----------------------------------|
| Apisix           | 500m CPU + 512M内存 | 1100m CPU + 1GB内存  | 2  | k8s-node1 + k8s-node3             |
| 订单服务             | 500m CPU + 128M内存 | 1100m CPU + 512M内存 | 2  | k8s-node1 + k8s-node2             |
| 商品服务             | 500m CPU + 128M内存 | 1000m CPU + 450M内存 | 2  | k8s-node1 + k8s-node2             |
| fluent bit       | 100m CPU + 128M内存 | 500m CPU + 512M内存  | 3  | k8s-node1 + k8s-node2 + k8s-node3 | 
| Prometheus Agent | 100m CPU + 128M内存 | 1000m CPU + 800M内存 | 1  | k8s-node3                         |
| MySQL            | -                 | -                  | 1  | 基础设施服务器1                          |
| Redis            | -                 | -                  | 1  | 基础设施服务器1                          |
| ETCD             | -                 | -                  | 1  | 基础设施服务器1                          |
| Consul           | -                 | -                  | 1  | 基础设施服务器1                          |
| Jenkins          | -                 | -                  | 1  | 基础设施服务器1                          |
| Harbor           | -                 | -                  | 1  | 基础设施服务器1                          |
| Kafka            | -                 | -                  | 1  | 基础设施服务器1、k8s-node3                |
| Docker           | -                 | -                  | 1  | 所有节点                              |
| K8S基础组件calico等   | -                 | -                  | 1  | K8S集群                             |

## 总项目文档
- [变更日志](./docs/CHANGELOG.md)
- [决策记录](./docs/DECISIONS.md)

## 项目压测及负载测试报告

由于从6.0开始使用的组件大量增加需要验证系统稳定性故转向负载测试确认系统安全边界，故从6.0.0起转向负载测试。

### 说明
压测及负载测试环境使用本地电脑的Nginx配置负载均衡充当“负载均衡器”连接NodePort类型的Apisix，关闭无用的服务减少TCP连接尽量减少干扰但难以避免，最新版的负载测试结果显示最高峰为761Qps，
P95延迟41ms，每个服务2个副本，单个Pod配置1核CPU + 512Mi内存。

- [6.2.0负载测试报告](https://github.com/zhanshen02154/order/issues/173)
- [6.1.0负载测试报告](https://github.com/zhanshen02154/order/issues/161)
- [6.0.0负载测试报告](https://github.com/zhanshen02154/order/issues/151)
- [5.0.0压测报告](https://github.com/zhanshen02154/order/issues/125)
- [4.0.0压测报告](https://github.com/zhanshen02154/go-micro-service/issues/28)
- [3.0.0压测报告](https://github.com/zhanshen02154/order/issues/72)
- [2.0.0压测报告](https://github.com/zhanshen02154/order/issues/53)
- [1.0.0压测报告](https://github.com/zhanshen02154/go-micro-service/issues/13)

## 项目改造前后对比
本项目由网课教程改造而成，改造前后的对比如下：

| 改造前                     | 改造后                                                                                                                                            |
|-------------------------|------------------------------------------------------------------------------------------------------------------------------------------------|
| 仅有领域层、仓储层和handler       | 分为领域层、应用层、接口层、 基础设施层，handler合并到接口层，整个项目全部重写                                                                                                    |
| 配置文件硬编码                 | 用Consul的K/V获取配置，提升配置灵活性                                                                                                                        |
| go micro框架版本为2.9.1      | 升级到4.11.0，详情见决策记录[ADR-006: 集成DTM分布式事务组件](https://github.com/zhanshen02154/go-micro-service/blob/master/docs/DECISIONS.md#adr-006-集成DTM分布式事务组件) |
| 拥有电商平台的各项服务但无法通信        | 选取订单支付成功回调链路实现跨服务通信架构演进                                                                                                                        |     
| GORM版本为1.9.6            | 升级到GORM 1.30.0                                                                                                                                 |     
| 无健康检查                   | 具备健康检查                                                                                                                                         |     
| 无工程化管理                  | 遵循git提交规范，用Scrum配合Github Project管理各个迭代，遵循敏捷开发的基本原则如MVP，永远只完成最核心最迫切的任务。                                                                         |     
| 无知识传承                   | 关注知识传承，如变更日志、决策记录、自述文件。                                                                                                                        |     
| 无CI/CD                  | 具备CI/CD流水线                                                                                                                                     |     
| 系统性能未经验证                | 有压测和负载测试验证                                                                                                                                     |
| 仅实现基本业务功能               | 订单支付回调链路实现高可用、高吞吐量，从GRPC微服务通信逐步迭代到事件驱动架构。                                                                                                      |
| 仅演示集成到Jaeger和Prometheus | 接入阿里云可观测服务实现支付回调过程的全链路追踪和基础设施监控。                                                                                                               |
| 无日志                     | 包含GRPC请求日志、Apisix请求日志、发布日志、订阅日志，通过fluent bit收集并存储到Elasticsearch<br/>                                                                           |
| 无分布式锁                   | 从ETCD分布式锁到Redis分布式锁                                                                                                                            |
| 无Api网关接入                | 接入API网关                                                                                                                                        |

## 各服务代码仓库及相关文档
### 订单服务

- [代码仓库](https://github.com/zhanshen02154/order)

- [变更日志](https://github.com/zhanshen02154/order/blob/master/docs/CHANGELOG.md)

- [决策记录](https://github.com/zhanshen02154/order/blob/master/docs/DECISIONS.md)

### 商品服务

- [代码仓库](https://github.com/zhanshen02154/product)

- [变更日志](https://github.com/zhanshen02154/product/blob/master/docs/CHANGELOG.md)

- [决策记录](https://github.com/zhanshen02154/product/blob/master/docs/DECISIONS.md)

## 项目部分基础设施截图
- [微服务及Apisix](./docs/dev.png)
- [可观测性基础设施](./docs/observability.png)
- [Harbor](./docs/harbor.png)
- [Jenkins](./docs/jenkins.png)
- [Consul](./docs/consul.png)

### 后续规划
- 引入配置热更新减少频繁重启
- 转向Serverless

## 部署指南
### 基础设施
- 安装Jenkins。
- 修改插件源，注意版本号。
- 打开Jenkins，安装Kubernetes CLI、GitHub、Go插件。
- 配置Go的安装目录。
- 配置流水线所需的凭证。包括：Github账号密码，Jenkins部署账号的kubeconfig（位于jenkins-kubeconfig.yaml，集群名称和密钥、命名空间、用户名修改成实际的用户）
- 将Jenkins用户添加到docker组并重启Jenkins。
```bash
usermod -a -G docker jenkins && systemctl restart jenkins
```
- K8S有关Jenkins的角色、规则、角色绑定应用到K8S集群：
```bash
kubectl apply -f <filename>
```
- 定时任务CronJob所需的文件：clean-unused-images.yaml、crictl-configmap.yaml添加到K8S集群。
- 添加服务和deployment到K8S集群。
- 部署ETCD给Apisix使用，配置文件已提供。

### 服务器运行环境
- 安装kubeadm、kubelet、kubectl
- 设置kubelet垃圾回收机制

### 注意事项
- GitHub API不再支持用账号密码认证，账号密码凭证用Personal Access Token作为密码。
- 严格按照kubeconfig的模板，通过Dashboard找到账号的密码

### 部署kafka
- 在基础设施服务器节点1和基础设施服务器节点2上传kafka，并创建logs目录，执行：sudo chown -R kafka:kafka /path/to/kafka
- 两台基础设施服务器执行sudo yum install -y java-1.8.0-openjdk
- 进入kafka目录执行：chmod +x -R kafka:kafka bin/*.sh。
- 根据java安装目录确定JAVA_HOME，更改install.sh里的“JAVA_HOME=”所在的行。
- 执行install.sh。
- 进入logs目录查看meta.properties里面有集群的UUID将其复制出来。
- 到另一个节点的kafka目录里执行bin/kafka-storage.sh format -t $SERVERUUID -c config/kraft/server.properties（$SERVERUUID就是基础设施服务器节点1获得的集群UUID）。

## 部署Fluent bit
- ```bash
  helm install fluent-bit fluent/fluent-bit --version 0.54.0 --values fluent-bit-values.yaml -n observability
  ```
## 接入阿里云SLS
- 创建2个服务和Apisix的Project，Apisix的Logstore名为request，其余两个服务都要创建的logstore分别是request、publish、subscribe、sql、core。
- fluent bit配置按比例采集和Filter的RewriteTag，对不同的服务设置不同的Tag。
- fluent bit创建2个OUTPUT配置两个服务的topics和topic_key（日志的type字段），topic_key的数据对应logstore，rdkafka.sasl.username对应project（这里只能写死或使用环境变量），Brokers是Project名称和私网地址的组合，端口号10011。
- Apisix的日志在全局规则里配置SLS-logger即可，压测前要禁用该插件防止生成大量日志。
  
## 接入阿里云Opentelemetry
- 连接私网的Opentelemetry地址，域名和Path分开。
  
### 部署Prometheus Agent
- 创建Prometheus的ConfigMap，配置Remote Write对接阿里云的云监控及Job（生产环境需要增加对集群的监控）。
- 用helm和prometheus.yaml文件安装Prometheus Agent。

## 本地开发环境搭建
- 下载虚拟机，安装CentOS。
- 安装Docker，并在Docker上安装Apisix 3.4.1。
```bash
 yum install -y docker-ce-20.10.7 docker-ce-cli-20.10.7 containerd.io-1.6.33
```
- 安装MySQL
- 安装Jaeger 1.74.0-all-in-one
- 安装kafka 3.0.1，用kraft模式
- 安装postman直连微服务