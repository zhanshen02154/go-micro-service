
<a name="v4.0.0"></a>
## [v4.0.0](https://github.com/zhanshen02154/go-micro-service/compare/v3.0.0...v4.0.0) (2025-12-23)

### Features

* **docker配置:** 新增fluent bit镜像源

### Performance Improvements

* **mysql配置文件:** 调整数据库配置参数


<a name="v3.0.0"></a>
## [v3.0.0](https://github.com/zhanshen02154/go-micro-service/compare/v2.0.0...v3.0.0) (2025-12-09)

### Features

* 新增kafka配置文件


<a name="v2.0.0"></a>
## [v2.0.0](https://github.com/zhanshen02154/go-micro-service/compare/v1.0.0...v2.0.0) (2025-11-28)

### Features

* 新增DTM组件配置


<a name="v1.0.0"></a>
## v1.0.0 (2025-11-13)

### Bug Fixes

* **apisix-values.yaml:** 修复gateway的Pod反亲和性失效
* **kubeconfig文件格式:** 修改kubeconfig文件使其成为模板
* **order服务的K8S部署文件:** pod反亲和改为软亲和
* **product服务K8S部署文件:** 修改Pod反亲和策略为软亲和

### Features

* MySQL部署文件及文档
* **ETCD安装脚本:** 新增ETCD安装脚本
* **Jenkins部署脚本:** 新增Jenkins安装脚本
* **changelog:** 新增git-chglog配置文件和模板
* **config:** 修改部署文件，增加configmap
* **docker部署脚本:** 新增关闭交换
* **harbor:** 新增harbor部署脚本及配置文件
* **mysql:** 新增MySQL配置及本地账号创建

