local ngx_re_split = require("ngx.re").split
local ip_addr = ngx.shared.redis_cluster_addr:get('redis-addr')
local ip_addr_table = ngx_re_split(ip_addr, ",")

local redis_addr = {}
for key, value in ipairs(ip_addr_table) do
    local ip_addr = ngx_re_split(value, ":")
    redis_addr[key] = { ip = ip_addr[1], port = ip_addr[2] }
end

local config = {
    name = "testCluster",      --rediscluster name
    serv_list = redis_addr,
    keepalive_timeout = 60000, --redis connection pool idle timeout
    keepalive_cons = 1000,     --redis connection pool size
    connection_timeou = 1000,  --timeout while connecting
    max_redirection = 5,       --maximum retry attempts for redirection
    auth = "sixstar"
}

local redis_cluster = require "rediscluster"
local red_c = redis_cluster:new(config)

--在redis当中嵌入lua脚本
local res,err=red_c:eval([[
    local key=KEYS[1]
    local val = ARGV[1]
    local res,err=redis.call('bf.exists',key,val)
    return res
     --业务逻辑
]],1,'{shop_list}','10')
ngx.say("xxx")
if res then

end
