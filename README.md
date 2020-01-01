# 缓存架构
## 利用consul存储服务地址信息
* 1.安装consul

```docker run -d -p 8700:8500 -h node1 --name node1 consul agent -server -bootstrap-expect=1 -node=node1 -client 0.0.0.0 -ui```
* 2.设置服务地址信息(ip地址和端口请更换为自己的)

```curl -X PUT -d '{"weight":1,"max_fails":2,"fail_timeout":10}' http://127.0.0.1:8700/v1/kv/upstreams/servers/140.143.16.122:8002```
## lua连接redis集群
* 1.redis集群包地址 

```https://github.com/steve0511/resty-redis-cluster```
 
* 2.源码目录通过make生成.so文件，通过lua_package_cpath加载.so文件 
* 3.定时获取集群信息，动态获取集群地址 通过在进程启动的时候定时获取redis连接地址,在使用时获取内存内的redis集群地址

```curl -X PUT -d '140.143.16.122:6392' http://127.0.0.1:8700/v1/kv/redis-cluster-2/```
## 图示

## 一.nginx分发层
* 1.动态负载均衡(地址从consul中获取)
* 2.动态切换负载均衡的方式(从consul获取)
## 二.nginx应用层
* 1.nginx内存缓存,使用mlcache(字典)缓存热点数据,缓存会过期
* 2.利用布隆过滤器防止缓存穿透(过滤异常请求)
* 3.从redis集群中尝试读取缓存,读取到把值设置到nginx字典中(分布式锁,防止缓存击穿)
* 4.经过去重队列后,尝试从源服务器当中读取(防止脏数据,旧数据覆盖新数据的缓存)
* 5.lua做模板动态渲染(前后端分离可以直接返回数据)
* 6.缓存失效时间随机(防止缓存雪崩)
* 7.限流,降级
