# Golang微服务架构演进实践

## 声明
- 本项目为个人项目，内置部分自编组件，请勿在未经允许的前提下使用Releases的产物及源码用于商业用途，若需合作请发送邮件到zhanshen02154@gmail.com联系作者本人。
- 严禁将代码及产物用于非法活动如赌博、诈骗、洗钱等，一经发现将追究法律责任！

## 项目描述
以“订单支付成功回调扣减商品库存”链路进行微服务架构演进实践，总体架构为事件驱动架构，分为订单服务和商品服务（支付服务和订单服务合并以减少服务器的使用降低个人项目开发成本）。 

项目旨在模拟微服务架构演进、项目管理规范及优秀技术实践，包含CI/CD流水线实现自动化部署。从1.0的GRPC跨服务调用到事件驱动架构，实现异步通信解耦，摆脱对GRPC 客户端的依赖，解决2.0版DTM分布式事务操作
MySQL造成性能急剧下降的问题，用幂等性确保消息不会重复处理，将处理失败/推送失败的数据放入死信队列做回滚操作，在保证服务高可用的同时提升系统吞吐量。 各微服务为领域驱动架构，大量使用面向接口编程，除DTM对
顶层业务代码侵入明显以外其余组件均设计为可插拔结构，基础设施层的替换不影响领域层、接口层和应用层。

go micro v4无原生支持DTM分布式事务的组件且资料匮乏，故自行编写编解码器适配GRPC模式下的DTM，同时修正

项目管理工具为Github Project，用Scrum进行项目管理，迭代周期为2周。

## 项目特点
- 实现端到端交付。
- 用事件驱动架构解耦跨服务通信提升吞吐量，极限压测结果显示1.0版仅为215Qps，2.0版为65QPS（因DTM操作数据库加上当时基础设施服务器仅2核4G导致系统压力过大）直至当前5.0版的1596Qps，P95延迟从2.0版超过2秒到如今的71ms
性能大幅提升。
- 具备服务健康检查。
- 使用自编的事务管理器结合GORM的事务完成事务处理实现数据一致性。
- 配置去中心化，避免对configmap的依赖。
- 依托GitHub结合Jenkins流水线实现CI/CD。
- 将自行编写DTM专用的编解码器植入框架弥补go micro v4无原生支持的问题。
- 修改Go micro v4的broker底层源码以支持带key发布到kafka实现消息顺序消费。
- 用死信队列及幂等性保证系统可靠性。

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
| 无知识传承                   | 关注知识传承，如变更日志、决策记录、自述文件，用Scrum管理项目，运用Github Project管理各个迭代，遵循敏捷开发的基本原则如MVP、灵活调整任务等。                                                              |     
| 无CI/CD                  | 具备CI/CD流水线                                                                                                                                     |     
| 系统性能未经验证                | 有压测和负载测试验证                                                                                                                                     |
| 仅实现基本业务功能               | 订单支付回调链路实现高可用、高吞吐量，从GRPC微服务通信逐步迭代到事件驱动架构。                                                                                                      |
| 仅演示集成到Jaeger和Prometheus | 实现支付回调过程的全链路追踪和基础设施监控，各组件分开部署符合生产要求                                                                                                            |
| 无日志                     | 包含GRPC请求日志、Apisix请求日志、发布日志、订阅日志，通过fluent bit收集并存储到Elasticsearch                                                                                |

## 各服务代码仓库及相关文档
### 订单服务
- 代码仓库: https://github.com/zhanshen02154/order
- 变更日志: https://github.com/zhanshen02154/order/blob/master/docs/CHANGELOG.md
- 决策记录: https://github.com/zhanshen02154/order/blob/master/docs/DECISIONS.md

### 商品服务
- 代码仓库: https://github.com/zhanshen02154/product
- 变更日志: https://github.com/zhanshen02154/product/blob/master/docs/CHANGELOG.md
- 决策记录: https://github.com/zhanshen02154/product/blob/master/docs/DECISIONS.md

## 技术选型

| 开发语言及工具             | 版本      | 用途                 |
|---------------------|---------|--------------------|
| kubernetes          | 1.23.1  | 容器编排               |
| docker              | 20.10.7 | 容器运行               |
| jenkins             | 2.346.1 | CI/CD              |
| MySQL               | 5.7.26  | 数据库                |
| Apisix              | 3.4.1   | API网关              | 
| harbor              | 1.8.6   | docker私有仓库         | 
| golang              | 1.20.10 | 各服务开发语言            | 
| Consul              | 1.7.3   | 服务注册/发现            | 
| ETCD                | 3.5.7   | Apisix、分布式锁        | 
| Go-micro            | 4.11.0  | 各服务开发框架            | 
| Github              | -       | 代码托管和项目管理          | 
| LUA                 | -       | 编写Fluent bit过滤器    | 
| Jaeger（非all-in-one） | 1.74.0  | 链路追踪               | 
| Elasticsearch       | 8.18.8  | 存储链路追踪和日志          | 
| Fluent bit          | 4.1.0   | 收集Apisix和微服务的日志    | 
| DTM                 | 1.19    | 分布式事务              | 
| Kafka     | 3.1.0   | 收集Apisix日志、项目的核心组件 | 

## 服务器各节点配置及运行的组件
| 服务器配置          | 数量 | 组件                                                                                                                                     |
|----------------|----|----------------------------------------------------------------------------------------------------------------------------------------|
| CPU x 4 + 8G内存 | 5  | Apisix（2个副本）、订单服务x2、商品服务x2、fluent bit、Jaeger Collector、Elasticsearch、fluent bit、Jaeger Ingester、Consul、ETCD、MySQL、kafka、Jenkins、Harbor |
| CPU x 2 + 2G内存 | 1  | K8S主节点                                                                                                                                 |

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

## 部署Elasticsearch
- 设置K8S集群节点标签，根据nodeSelector的规则来设置
- 用elasticsearch.yaml和configMap部署到K8S集群
- [点击此处](https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.18.8-windows-x86_64.zip)下载ES到本地电脑， 用elasticsearch-certutil http生成自签证书（生产环境要用CA机构颁发的证书）
- 用生成好的ca.p12生成ca.pem用于Jaeger和其他客户端与ES通信
- 创建带有http.p12的secret
- 应用configMap文件：es.conf
- 应用elasticsearch.yaml部署到K8S集群
- 为jaeger和fluentbit开通ES的账号

## 部署Fluent bit
- 应用fluent-bit-conf.yaml加载configmap
- 创建带有ca.pem的secret
- ```bash
  helm install fluent-bit fluent/fluent-bit --version 0.54.0 --values fluent-bit-values.yaml -n observability
  ```
## 部署Jaeger
- 创建用于Jaeger的secret，包含ca.pem
- ```bash
  helm install jaeger jaegertracing/jaeger \
  --namespace observability \
  --version 3.2.0 \
  -f jaeger-values.yaml
  ```

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