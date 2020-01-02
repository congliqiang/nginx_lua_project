local redis_cluster = require "rediscluster"
local ngx_re_split=require("ngx.re").split
local config = {
    name = "testCluster",                   --rediscluster name
    serv_list={{
        ip="140.143.16.122",port=6390
    }},
    keepalive_timeout = 60000,              --redis connection pool idle timeout
    keepalive_cons = 1000,                  --redis connection pool size
    connection_timout = 1000,               --timeout while connecting
    max_redirection = 5,                    --maximum retry attempts for redirection
    auth="sixstar"
}
local red_c = redis_cluster:new(config)
ngx.update_time()
local key="{api_1_20}"
-- 设计下key,假设api有编号
local res,err = red_c:eval([[
        --  通过url判断访问是哪个服务
        local  app_name=KEYS[1]   --标识是哪个应用
        local  rareLimit=redis.call("HMGET",app_name,"max_burst","rate","curr_permits","last_second")   --从redis当中取出来
        local  max_burst=tonumber(rareLimit[1])  --令牌桶最大的容量
        local  rate=tonumber(rareLimit[2])   --每秒生成令牌的个数
        local  last_second = rareLimit[4] -- 最后一次的访问时间
        local  curr_second = ARGV[1] -- 当前时间
        local  curr_permits=tonumber(rareLimit[3]) --当前桶里剩余令牌(跟1s内的消耗有关系,请求有关系)
        local  permits    =  ARGV[2]  -- 这次请求消耗的令牌数
        local  default_curr_permits=max_burst -- 默认令牌数,默认添加10个

        --通过判断是有有最后一次的访问时间,如果满足条件,证明不是第一次获取令牌了
        if (type(last_second)) ~= "boolean" and last_second ~= nil then
               --距离我上次访问,按照速率大概产生了多个个令牌
               local reverse_permits = math.floor( ((curr_second - last_second) / 1000) * rate )  -- 当前时间-最后一次访问的时间 / 1000 * 速率
               -- 如果访问的时间较短,允许突发数量
               local expect_curr_permits= reverse_permits + curr_permits
               -- 最终能够使用的令牌,不能超过最大令牌数
               default_curr_permits=math.min(expect_curr_permits,max_burst)
        else
              --记录下访问时间,并且减去消耗令牌数
             local res=redis.call("HMSET",app_name,"last_second",curr_second,"curr_permits",default_curr_permits - permits)
             if res =="ok" then
               return 1
             end
        end

        -- 当前能够使用的令牌 - 请求消耗的令牌 > 0,就能够成功获取令牌
        if (default_curr_permits - permits >= 0 ) then
             --记录下访问时间,并且减去消耗令牌数
             redis.call("HMSET",app_name,"last_second",curr_second,"curr_permits",default_curr_permits - permits)
             return 1
        else
             --令牌不够,只需要重置下桶里的令牌数,否则是负值导致,如果一直刷新将导致一直无法请求(看需求)
            redis.call("HMSET",app_name,"curr_permits",default_curr_permits)
            return 0
        end
        -- 业务逻辑
 ]],1,key,string.format("%.3f",ngx.now() * 1000 ),1)
ngx.header.content_type="text/html; charset=utf-8"
if tonumber(res) ~= 1 then
    ngx.say("无可用令牌")
end