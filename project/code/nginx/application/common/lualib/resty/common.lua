local common = {}
local ngx_re_split = require("ngx.re").split
local redis_cluster = require "rediscluster"

function common.filter(key, val)
    local ip_addr = ngx.shared.redis_cluster_addr:get('redis-addr')
    local ip_addr_table = ngx_re_split(ip_addr, ",")

    local redis_addr = {}
    for key, value in ipairs(ip_addr_table) do
        local ip_addr = ngx_re_split(value, ":")
        redis_addr[key] = { ip = ip_addr[1], port = ip_addr[2] }
    end

    local config = {
        name = "testCluster", --rediscluster name
        serv_list = redis_addr,
        keepalive_timeout = 60000, --redis connection pool idle timeout
        keepalive_cons = 1000, --redis connection pool size
        connection_timeou = 1000, --timeout while connecting
        max_redirection = 5, --maximum retry attempts for redirection
        auth = "sixstar"
    }
    local red_c = redis_cluster:new(config)
    --在redis当中嵌入lua脚本
    local res, err = red_c:eval([[
    local key=KEYS[1]
    local val = ARGV[1]
    local res,err=redis.call('bf.exists',key,val)
    return res
     --业务逻辑
]], 1, key, val)
    if err then
        ngx.log(ngx.ERR, "过滤错误:", err)
        return false
    end
    return res
end

function common.send(url)
    local req_data
    local method = ngx.var.request_method
    if method == "POST" then
        req_data = { method = ngx.HTTP_POST, body = ngx.req.read_body() }
    elseif method == "PUT" then
        req_data = { method = ngx.HTTP_PUT, body = ngx.req.read_body() }
    else
        req_data = { method = ngx.HTTP_GET }
    end
    local uri = ngx.var.request.uri
    if uri == nil then
        uri = ''
    end
    ngx.say(url .. uri)
    local res, err = ngx.location.capture(url .. uri,
        req_data)
    if res.status == 200 then
        ngx.say(res.body)
    end
    return
end

return common