local redis_cluster = require "rediscluster"
local ngx_re_split=require("ngx.re").split
local ip_addr=ngx.shared.redis_cluster_addr:get('redis-addr')
local ip_addr_table=ngx_re_split(ip_addr,",")
local redis_addr={}
for key, value in ipairs(ip_addr_table) do
    local ip_addr=ngx_re_split(value,":")
    redis_addr[key]={ip=ip_addr[1],port=ip_addr[2]}
end
local config = {
    name = "testCluster",                   --rediscluster name
    serv_list=redis_addr,
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timout = 1000,               --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection
    auth="sixstar"
}
local red_c = redis_cluster:new(config)
ngx.ctx.redisObject=red_c
