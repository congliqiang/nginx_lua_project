local tool=require "tool"


--ngx.log(ngx.ERR, "ip------: ", local_ip)


local_ip=tool.getIP()
local intercept = tool.get(local_ip)
if intercept == local_ip then
    ngx.exec("@client2")
    return
end

ngx.exec("@client1")

--[[
local ok, err = cache:close()
    if not ok then
      ngx.say("failed to close:", err)
    return
end

]]