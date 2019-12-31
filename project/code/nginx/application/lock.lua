local rety_lock = require "resty.lock"
local cache = ngx.shared.my_cache
local key = ngx.re.match(ngx.var.request_uri, "/([0-9]+).html")
--ngx.say(type(key))
if type(key) == "table" then
    --1.先从本地内存获取
    local res, err = cache:get(key[1])
    if res then
        ngx.say("val", res)
        return
    end
    --2.去后端源服务器获取,只允许一个请求到后端获取,并且更新缓存,加锁
    local lock, err = rety_lock:new("my_locks", { exptime = 10, timeout = 1 })

    if not lock then
        ngx.log(ngx.ERR, "创建锁对象失败")
        return
    end

    local flag_lock, err = lock:lock(key[1])
    if err then
        ngx.log(ngx.ERR, "加锁失败:", err)
    end

    if not flag_lock then
        ngx.log(ngx.ERR, "获取锁失败:占用")
        local res = cache:get_stale(key[1])
        return res
    end
    --锁成功获取,可能已经有人将结果值放入到缓存当中了,再检查下
    local res, err = cache:get(key[1])
    if res then
        lock:unlock()
        return res
    end

    --再去请求源服务器
    local req_data
    local method = ngx.var.request_method
    if method == "POST" then
        req_data = { method = ngx.HTTP_POST, body = ngx.req.read_body() }
    elseif method == "PUT" then
        req_data = { method = ngx.HTTP_PUT, body = ngx.req.read_body() }
    else
        req_data = { method = ngx.HTTP_GET }
    end
    local res, err = ngx.location.capture('/index.php',
        req_data)
    if res.status == 200 then
        ngx.say(res.body)
    end
    lock:unlock()
end
