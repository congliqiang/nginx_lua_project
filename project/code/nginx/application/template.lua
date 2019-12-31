--local template = require "resty.template"
--nax.sy('xxx')
--template.render("view.html", { message = "Hello, World!" })
res = ngx.location.capture(
    'index.php?'..ngx.var.request_uri,req_data
)
ngx.say(res.status)
 -- 判断状态码决定是否打印，如果返回不是200
if res.status == ngx.HTTP_OK then
     ngx.say(res.body)
    return
end