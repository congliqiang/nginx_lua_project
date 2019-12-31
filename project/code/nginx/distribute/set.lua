local flag=ngx.shared.load:get("load")
local load_blance=''
if tonumber(flag)==1 then
    load_blance="upstream_server_round"
elseif tonumber(flag) == 2 then
    load_blance="upstream_server_conn"
else
    load_blance="upstream_server_hash"
end

return load_blance