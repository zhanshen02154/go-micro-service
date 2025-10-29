# Golang微服务项目架构演进实践

## 软件架构
Golang微服务项目架构演进实践, 全站为云原生架构，各微服务采用DDD领域驱动架构，Apisix作为网关。

## 技术选型

| 技术         | 版本      | 用途                      |
|------------|---------|-------------------------|
| kubernetes | 1.23.1  | 容器编排                    |
| docker     | 20.10.7 | 容器运行                    |
| jenkins    | 2.222.4 | 部署                      |
| MySQL      | 5.7.26  | 数据库                     |
| Apisix     | 3.4.1   | API网关                   | 
| harbor     | 1.8.6   | docker私有仓库              | 
| golang     | 1.20.10 | 各服务开发语言                 | 
| Consul     | 1.7.3   | 服务注册/发现                 | 
| ETCD       | 3.5.7   | 服务注册/发现/数据存储（仅用于Apisix） | 
| Go-micro   | 2.9.1   | 各服务开发框架                 | 

## 服务器配置
| 配置              | 数量 | 用途                                        |
|-----------------|----|-------------------------------------------|
| CPU x4 + 8 GB内存 | 2  | 微服务运行环境（含K8S集群、API网关）                     |
| CPU x2 + 4 GB内存 | 1  | MySQL + jenkins + Harbor + consul |
| CPU x2 + 2 GB内存 | 1  | K8S主节点                                    |

## 各服务代码仓库：

- 订单服务：https://github.com/zhanshen02154/order
- 商品服务：https://github.com/zhanshen02154/product

## 部署指南
### 基础设施服务器
- 安装Jenkins。
- 修改插件源，注意版本号。
- 打开Jenkins，安装Kubernetes CLI、GitHub、Go插件。
- 配置Go的安装目录。
- 配置流水线所需的凭证。包括：Github账号密码，Jenkins部署账号的kubeconfig（位于jenkins-kubeconfig.yaml，集群名称和密钥、命名空间）
- 执行命令将Jenkins用户添加到docker组并重启：
```bash
usermod -a -G docker jenkins && systemctl restart jenkins
```
### 服务器运行环境
- 安装kubeadm、kubelet、kubectl
- 设置kubelet垃圾回收机制

### 注意事项
- GitHub API不再支持用账号密码认证，账号密码凭证用Personal Access Token作为密码。
- 使用kubeconfig

## 本地开发环境搭建
- 下载虚拟机，安装CentOS。
- 安装Docker，并在Docker上安装Apisix 3.4.1。
- 安装MySQL
```bash
 yum install -y docker-ce-20.10.7 docker-ce-cli-20.10.7 containerd.io-1.6.33
```

