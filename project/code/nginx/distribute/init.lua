--进程启动触发

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
    local res, err = consul:get_key("load") --获取value值
    if not res then
        ngx.log(ngx.ERR, err)
        return
    end
    ngx.log(ngx.ERR, "获取到是否要切换的标记", res.body[1].value)
    ngx.shared.load:set('redis-addr', res.body[1].value)
end

if (0 == ngx.worker.id()) then
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

