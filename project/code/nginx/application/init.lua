--进程启动触发
--启动订阅者

local delay = 5
local handler
handler = function(premature)
    local resty_consul = require('resty.consul')
    local consul = resty_consul:new({
        host = "140.143.16.122",
        port = 8700,
        connect_timeout = (60 * 1000), -- 60s
        read_timeout = (60 * 1000), -- 60s
    })

    local res, err = consul:list_keys("redis-cluster") -- Get all keys
    if not res then
        ngx.log(ngx.ERR, err)
        return
    end

    local keys = {}
    if res.status == 200 then
        keys = res.body
    end

    local ip_addr = ''
    --分隔函数
    local ngx_re_split = require("ngx.re").split
    for key, value in ipairs(keys) do
        local res, err = consul:get_key(value) --获取value值
        if not res then
            ngx.log(ngx.ERR, err)
            return
        end
        -- 如果是最后一个就不拼接,逗号分隔
        if table.getn(keys) == key then
            ip_addr = ip_addr .. res.body[1].Value
        else
            ip_addr = ip_addr .. res.body[1].Value .. ','
        end
    end
    ngx.shared.redis_cluster_addr:set('redis-addr', ip_addr)
end
local sub = function(premature)
    --连接redis去订阅
    local redis = require "resty.redis"
    local cjson = require "cjson"
    local red = redis:new()
    red:connect("140.143.16.122",6391)
    red:auth("sixstar")
    while 1 do
        local ok,err = red:subscribe("cacheUpdate")
        local res,err=red:read_reply() --订阅的频道中获取
        ngx.log(ngx.ERR,"订阅消息-----------",cjson.encode(res))
        --缓存更新
        local mlcache=require "resty.mlcache"
        local cache,err=mlcache.new("cache_name","my_cache",{
            lru_size=500,--设置缓存的个数
            ttl=5,--缓存过期时间
            neg_ttl=6,--L3返回nil的保存时间
            ipc_shm="ipc_cache"--用于将L2的缓存设置到L1
        })
        if not cache then
            ngx.log(ngx.ERR,"缓存创建失败",err)
        end
        math.randomseed(tostring(os.time()))
        local expire_time=math.random(1,6)
        res=cache:set("cache",{ttl=expire_time},"xxx")
        ngx.log(ngx.ERR,"缓存更新成功吗",res)
    end
end
if (0 == ngx.worker.id()) then
    ngx.timer.at(0,sub)
    --第一次立即执行
    local ok, err = ngx.timer.at(0, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer:", err)
        return
    end
    --第二次定时执行
    local ok, err = ngx.timer.every(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer:", err)
        return
    end
    ngx.log(ngx.ERR, "---进程启动")
end

