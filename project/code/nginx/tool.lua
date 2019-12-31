-- 文件名为 tool.lua
-- 定义一个名为 tool 的模块
local tool= {}
local redis = require "resty.redis"

function tool.get(key)
    local cache = redis.new()
    local ok, err = cache.connect(cache, '127.0.0.1', 6379)
    if not ok then
        ngx.say("failed to connect:", err)
        return false;
    end
    local intercept = cache:get(key)
    return local_ip
end

function tool.getIP()
 --从代理ip当中获取
   local local_ip = ngx.req.get_headers()["X-Real-IP"]
    if local_ip == nil then
       local_ip = ngx.req.get_headers()["x_forwarded_for"]
    end

    if local_ip == nil then
      local_ip = ngx.var.remote_addr
    end
    return local_ip
end

return tool