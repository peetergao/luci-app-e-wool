local jd = "e-wool"
local uci = luci.model.uci.cursor()
local sys = require "luci.sys"

m = Map(jd)
-- [[ 薅羊毛Docker版-基本设置 ]]--

s = m:section(TypedSection, "global",
              translate("手动执行脚本"))
s.anonymous = true

o = s:option(Value, "sd_run", translate("输入脚本名称"))
o.rmempty = true
o.description = translate("<br/>说明：<br/>1、填入需要执行的脚本名称，如京豆变动通知脚本：jd_bean_change.js<br/>2、点击 保存&应用 即可<br/>3、保存后会一直处于配置正在应用更改，直到脚本执行完成<br/>4、按cookies顺序执行，没有并发<br/>5、执行完成，可以在日志查看执行情况")

return m
