---
layout: post
title: Microservice Basic Knowledge
disqus: y
share: y
categories: [Architecture]
tags: [Microservice]
---

## 基础知识
区别于传统的单体式应用程序( Monolithic application )。  
**优点：**  
开发测试部署都比较容易。  
**缺点：**  
耦合(coupling)强，即使分成了多个模块，打包后还是一整个，比如微软的word。以整个应用程序为单位。部署时间久，一个小改动也需要重新部署全部。  

微服务就是将模块之间尽量隔离开，每个部件可以单独运行。之间使用API通信，各服务可以使用任意语言，同时自动部署。优点类似面向服务的体系结构 SOA (Service-Oriented Architecture)。    
**优点：**  
各个开发团队开开心心自己搞自己的技术栈。可以针对瓶颈服务进行扩展；单个节点的部署改动比较容易。  
**缺点：**  
就是复杂，集成测试极其复杂，而且提交的一个服务的代码变动仍然可能影响全局，一个关键服务炸了整个服务也炸了（所以建议多个region），花费明显高。监控也是很困难。安全性控制也会变得困难（API直接就Oath了）。

## 关键细节
这里会有一个叫做服务注册中心的东西，复杂客户端和服务器端的联系，客户端订阅服务注册中心，服务端需要将服务注册到服务注册中心，服务注册中心会将服务器的更新信息发送到客服端去。然后客户端就直接和目标服务器建立联系了。所以这个服务注册中心和之前的UI application有点像，不过微服务下连具体UI也在微服务下面，然后服务器注册中心更像是一个API gateway。

**RPC(Remote Procedure Call) vs Restful:**   
服务器之间的通讯通过RPC而不是HTTP来实现。 
1.RPC面向过程，只发送 GET 和 POST 请求。RESTful面向资源，使用 POST、DELETE、PUT、GET等请求。  
2.不过HTTP要包含不少无用文件头，浪费流量。而RPC显然要高效很多（就如同java的rmi，显然比restfull来的快）。RPC也不是长链接，不需要什么3次握手之类。  
3.HTTP(restful)是应用层，TCP是传输协议，所以支持范围最广，任何语言编写的符合HTTP标准就行，比如JSON之类。RPC有限制，不过通过thrift或者gRPC也是可以支持非常多的语言的。  

**服务发现:**   
流行的就是netflix eureka。注意微服务架构的服务器都是动态的，服务调用时，无需知道目标服务的真实地址，只需要知道服务Key，然后到服务发现系统里获取对应的地址即可。这个服务器发现包括了客户端发现和服务端发现，因为服务器也需要找其他服务。显然服务发现需要高可用，否则，客户端和服务端都无法工作了，这就需要类似zookeeper的health check以及容灾设置了。

**服务发现 - 服务如何确定自身的IP地址及端口？**  
一般可以创建服务注册表,最简单的解决方案就是手动配置。在DevOps时代，再使用手动配置，就显得不那么专业了，而且人工的介入，也增加了系统运维的成本与风险。所以我们选择，自动获取本机IP地址，但是这里有一个问题，也是我在实际运用中遇到的问题就是本地会有多个网卡的情况，这是比较麻烦的，所以那时候我建议每台机器只配置一个网卡，以减少不确定性，后来有人说，直接往服务注册中心发送一个Socket连接就可以了，通过Socket实例获取本机IP。

**API gateway网关：**  
微服务有无网关和有网关的架构，有网关的其实更多。  
服务网关 = 路由转发 + 过滤器，可以隔离和隐藏微服务，在网关中进行权限过滤，限制流量，负载均衡，并和注册服务协作进行智能路由等。  
缺点：  
1.多了一层，影响一点效率。感觉加了这层，和一个前端没啥区别呢？（比如tomcat等反向代理）  
2.有单点故障问题，所以通常还需要在前头挂上nginx做负载均衡。  
网关也早有人写了，比如Kong，Traefik，Ambassador，Tyk，Zuul。注意kubernetes是不包含网关的。

## 流行框架
**1)服务治理型的 RPC 框架**  
有Dubbo、Motan 等，这类的 RPC 框架的特点是功能丰富，提供高性能的远程调用以及服务发现和治理功能，适用于大型服务的微服务化拆分以及管理，对于特定语言（Java）的项目可以十分友好的透明化接入。但缺点是语言耦合度较高，跨语言支持难度较大。
Dubbo：阿里巴巴的开源Java RPC框架  
TAF：腾讯内部使用的微服务架构 TAF（Total Application Framework），只支持c++  
对于这里框架，RPC = socket + 动态代理

**2)跨语言调用型的 RPC 框架**  
有 Thrift、gRPC 等，这一类的 RPC 框架重点关注于服务的跨语言调用，能够支持大部分的语言进行语言无关的调用，非常适合于为不同语言提供通用远程服务的场景。但这类框架没有服务发现相关机制，实际使用时一般需要代理层进行请求转发和负载均衡策略控制。  
gRPC：Google开发的高性能、通用的开源RPC框架，基于ProtoBuf(Protocol Buffers)序列化协议开发。支持多种语言  
thrift：Facebook 开发的内部系统跨语言的高性能 RPC 框架，可以通过代码生成器，生成各种编程语言的 Client 端和 Server 端的 SDK 代码，支持多种语言。  

## Service Mesh（服务网格）
Service Mesh（服务网格）被认为是下一代微服务架构，Service Mesh并没有给我们带来新的功能，它是用于解决其他工具已经解决过的服务网络调用、限流、熔断和监控等问题，只不过这次是在Cloud Native 的 kubernetes 环境下的实现。Service Mesh之于微服务，就像TCP/IP之于互联网，TCP/IP为网络通信提供了面向连接的、可靠的、基于字节流的基础通信功能，你不再需要关心底层的重传、校验、流量控制、拥塞控制。用了Service Mesh你也不必去操心「服务治理」的细节，不需要对服务做特殊的改造，所有业务之外的功能都由Service Mesh帮你去做了。

**什么是kubernetes呢？**  
简称 k8s，是一个开源的 Linux 容器自动化运维平台，它消除了容器化应用程序在部署、伸缩时涉及到的许多手动操作。换句话说，你可以将多台主机组合成集群来运行 Linux 容器，而 Kubernetes 可以帮助你简单高效地管理那些集群。说白了就是管理容器。  
用了kubernetes可以：  
1）服务发现和负载均衡。Kubernetes 可以使用 DNS 名称或自己的 IP 地址公开容器，如果到容器的流量很大，Kubernetes 可以负载均衡并分配网络流量，从而使部署稳定。  
2）存储编排。Kubernetes 允许您自动挂载您选择的存储系统，例如本地存储、公共云提供商等。  
3）自动部署和回滚。您可以使用 Kubernetes 描述已部署容器的所需状态，它可以以受控的速率将实际状态更改为所需状态。就是版本控制了。  
4）自我修复。Kubernetes 重新启动失败的容器、替换容器、杀死不响应用户定义的运行状况检查的容器，并且在准备好服务之前不将其通告给客户端。  
5）密钥与配置管理。  
6）支持多种containter，现在也包括docker。

**为什么用容器container（VM）?**   
因为主机的情况个体性差异太大，用容易就消除了差异。标准化了部署，云服务必备。

**kubernetes和zookeeper的关系？**  
zookeeper用来管理服务集群，kubernetes用来管容器集群。所以kubernetes管理的容器里面还可以装zookeeper。

## Reference
1. [Mastering Chaos - A Netflix Guide to Microservices](https://www.youtube.com/watch?v=CZ3wIuvmHeM)   
2. [微服务，一文带你彻底搞懂](https://labuladong.github.io/ebook/%E6%8A%95%E7%A8%BF/%E9%9D%A2%E8%AF%95%E9%83%BD%E5%9C%A8%E9%97%AE%E7%9A%84%E5%BE%AE%E6%9C%8D%E5%8A%A1%EF%BC%8C%E4%B8%80%E6%96%87%E5%B8%A6%E4%BD%A0%E5%BD%BB%E5%BA%95%E6%90%9E%E6%87%82.html)  
3. [微服务调用为啥用RPC框架，http不更简单吗？](https://zhuanlan.zhihu.com/p/61364466)  
4. [Thrift 简单介绍](https://www.jianshu.com/p/8f25d057a5a9)  
5. [十分钟带你理解Kubernetes核心概念](http://www.dockone.io/article/932)  
6. [微服务探索与实践—服务注册与发现](https://juejin.im/post/6844903837476585480)
7. [API网关在微服务中的应用](https://juejin.im/post/6844903934067212301)  
8. [为什么微服务一定要有网关？](https://zhuanlan.zhihu.com/p/101341556)  