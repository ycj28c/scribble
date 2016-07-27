---
layout: post
title: Chef Learn 
disqus: y
share: y
---

7/21/2016
---------
今日忽然对chef有了一定的概念
我们Equilar的cookbook分为两部分，定义machine node的equilar_chef部分和application 的比如insight/cookbooks

1. 先说applicaion相关的insight/cookbooks

最重要的是metadata.rb文件，这个定义了recipe的名字，比如：

```ruby
name             'insight'
```

然后还有在这里加载ruby的library，从而扩展ruby的function来操作系统，比如：

```ruby
depends "ant"
depends "ark_equilar"
depends "cleanup"
```

1.1 Recipes

其实这就是一个recipe，是属于insight自己的recipe，直接的linux操作在cookbooks/recipes中，各种ruby可以直接对操作系统操作，比如：

```ruby
remote_file deploy_properties do
  source "#{download_base}/#{node.insight.server.dl_properties}.#{node.insight.server.deploy_env}"
  notifies :stop, "service[#{node[:insight][:server][:service]}]", :immediately
end
```

这个脚本就是从操作远程文件
remote_file就是ruby命令，可以通过include_recipe增加命令。
最常用的有file, service, package,template等chef自带的命令。

1.2 attribute

这个就是定义属性，很容易理解，比如：

```ruby
default[:insight][:user] =              'insight'
default[:insight][:group] =             'insight'
default[:insight][:system_type] =       'qa'
```

全部都是键值对的关系

1.3 templates

Insight/templates/default里面的文件是以erb为扩展名的，可以结果attribute和template命令来刷配置文件。比如：

```ruby
RMI_BIND_ADDRESS=<%= @bind_address %>
RMI_LISTEN_PORT=<%= @listen_port %>
RMI_BIND_PORT=<%= @bind_port %>
```

当通过template命令设置时候，就能把各个机器自定义的attribute刷新过去

2. 然后就是equilar_chef的node部分

2.1 certificates不知道，不常用

2.2 config不知道，不常用

2.3 data_bags不知道，不常用

2.4 environments

这个可以和node结果，定义一些环境的通用设置，比如insight jboss每个环境都是一样的，但是包含四台机器，那么就把通用的attribute定义在environments，把自定义的内容设置在各个node里面，通过"chef_type": "environment"来标识该文件是environment文件

2.5 nodes

这个node和具体的虚拟机是一一对应的，
通过run_list来使用recipe，比如：

```ruby
  "run_list": [
    "recipe[equilar_base::hq_base]",
    "recipe[atlas::deploy]",
    "recipe[insight::deploy]",
    "recipe[insight::deploy-ps]",
    "recipe[sayonpay]"
  ],
```

就可以使用insight/cookbooks/recipes里面的deploy.rb，deploy-ps.rb等recipe了，注意顺序 
通过"chef_environment": "build_env"表明所要使用的环境，
然后还可以增加一堆自定义的attributes和ruby命令等等。

2.6 role 不清楚，不常用

2.7 scripts估计是用来设置常用script的，比如增加linux用户之类，不知道和chef有啥关系

>所以正确使用chef的方法就是，每个project要写好自己要用的ruby >recipe，it人员则是设置好服务器的environment，而Node的设置需要project人员或者和it人员共同设置。
>Recipe管理应该是通过git和chef软件统一管理，然后就可以设置好服务器了，其实一点也不简单。
>Chef最大的好处就是可以自动判断和更新系统设置，不管是一个文本还是一个版本还是其他不同，很强大，当然bug也不少。
