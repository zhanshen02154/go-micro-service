# Golang微服务架构演进实践

## 项目描述
以“订单支付成功回调扣减商品库存”链路进行微服务架构演进实践，项目架构为云原生架构，分为订单服务和商品服务，基本实现端到端交付。

该项目由网课教程改造而成，原版的架构仅有领域层且无法部署在K8S也无法实现跨服务通信，现已全部替换为领域驱动架构，包含领域层、应用层、基础设施层、接口层，所有逻辑全部重写，基本实现去中心化。

使用GitHub Project进行项目管理，模式为Scrum，迭代周期为2周。

## 项目特点
- 采用GRPC跨服务通信实现订单支付成功回调调用商品服务扣减库存
- 使用自编的事务管理器结合GORM的事务完成事务处理实现数据一致性
- 原版为配置文件不易维护故改为Consul的K/V存储
- 增加K8S专用的健康检查探针（原版无此功能）
- 原版使用的GORM 1.9.6升级为1.30.0
- 依托GitHub结合Jenkins流水线实现CI/CD。

## 项目文档
- [变更日志](./docs/CHANGELOG.md)
- [决策记录](./docs/DECISIONS.md)

## 总项目目录结构
```tree
├─.chglog   # git-chglog配置文件及模板
├─consul    # Consul安装脚本及配置文件
├─docker    # Docker安装脚本及配置文件
├─docs      # 项目文档
├─etcd      # ETCD安装脚本
├─harbor    # Harbor安装脚本及配置文件
├─jenkins   # Jenkins安装脚本及配置文件
├─k8s-config # K8S安装脚本及配置文件
└─mysql     # mysql安装脚本及配置文件
```

## 各服务代码仓库：

- 订单服务：https://github.com/zhanshen02154/order
- 商品服务：https://github.com/zhanshen02154/product

## 技术选型

| 技术         | 版本      | 用途                      |
|------------|---------|-------------------------|
| kubernetes | 1.23.1  | 容器编排                    |
| docker     | 20.10.7 | 容器运行                    |
| jenkins    | 2.222.4 | CI/CD                   |
| MySQL      | 5.7.26  | 数据库                     |
| Apisix     | 3.4.1   | API网关                   | 
| harbor     | 1.8.6   | docker私有仓库              | 
| golang     | 1.20.10 | 各服务开发语言                 | 
| Consul     | 1.7.3   | 服务注册/发现                 | 
| ETCD       | 3.5.7   | 服务注册/发现/数据存储（仅用于Apisix） | 
| Go-micro   | 2.9.1   | 各服务开发框架                 | 
| Github     | -       | 代码托管平台                  | 

## 服务器配置
| 配置              | 数量 | 用途                                               |
|-----------------|----|--------------------------------------------------|
| CPU x4 + 8 GB内存 | 2  | 微服务运行环境（含K8S集群、Apisix、Apisix Ingress Controller） |
| CPU x2 + 4 GB内存 | 1  | MySQL + jenkins + Harbor + consul                |
| CPU x2 + 2 GB内存 | 1  | K8S主节点                                           |

## 部署流程
- github创建/合并Pull Request触发WebHook
- Jenkine接收webhook的信息
- 拉取代码
- 编译
- 构建Docker镜像
- 推送到Harbor
- 用jenkins专用的kubeconfig和set image命令部署
- 部署失败则回滚到最近一次成功的reversion

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

## 本地开发环境搭建
- 下载虚拟机，安装CentOS。
- 安装Docker，并在Docker上安装Apisix 3.4.1。
- 安装MySQL
```bash
 yum install -y docker-ce-20.10.7 docker-ce-cli-20.10.7 containerd.io-1.6.33
```

