# Golang微服务项目架构演进实践

## 软件架构
Golang微服务项目架构演进实践, 全站为云原生架构，各微服务采用DDD领域驱动架构，Apisix作为网关。

## 技术选型

| 技术         | 版本      | 用途         |
|------------|---------|------------|
| kubernetes | 1.23.1  | 容器编排       |
| docker     | 20.10.7 | 容器运行       |
| jenkins    | 2.222.4 | 部署         |
| MySQL      | 5.7.26  | 数据库        |
| Apisix     | 3.9     | API网关      | 
| harbor     | 1.8.6   | docker私有仓库 | 
| golang     | 1.20.10 | 各服务开发语言    | 

## 服务器配置
| 配置              | 数量 | 用途                                        |
|-----------------|----|-------------------------------------------|
| CPU x4 + 8 GB内存 | 3  | 微服务运行环境（含K8S集群、API网关）                     |
| CPU x2 + 4 GB内存 | 1  | MySQL + jenkins + Harbor + consul + redis |

## 本地开发环境
```bash
 yum install -y docker-ce-20.10.7 docker-ce-cli-20.10.7 containerd.io-1.5.4
```

