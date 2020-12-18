#!/bin/bash
#
NAME=e-wool
LOG_HTM=/www/e-wool.htm

uci_get_by_name() {
    local ret=$(uci get $NAME.$1.$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_get_by_type() {
    local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

cancel() {
    if [ $# -gt 0 ]; then
        echo "$1"
    fi
    exit 1
}
# 更新程序
    echo "实验性功能" >$LOG_HTM 2>&1
	jd_dir2=$(uci_get_by_type global jd_dir)
	cd $jd_dir2	
	rm -rf luci-app-e-wool
	echo "开始拉取文件..." >>$LOG_HTM 2>&1
	GIT_CURL_VERBOSE=1 git clone https://github.com/XiaYi1002/luci-app-e-wool.git >>$LOG_HTM 2>&1
    if [ $? -eq 0 ];then
	echo "云端文件下载成功..开始更新..." >>$LOG_HTM 2>&1
	cp -Rf  $jd_dir2/luci-app-e-wool/luasrc/controller/*  /usr/lib/lua/luci/controller/
	chmod -R 644 /usr/lib/lua/luci/controller/e-wool.lua
	cp -Rf  $jd_dir2/luci-app-e-wool/luasrc/model/cbi/e-wool/* /usr/lib/lua/luci/model/cbi/e-wool/
	chmod -R 644 /usr/lib/lua/luci/model/cbi/e-wool/
	cp -Rf  $jd_dir2/luci-app-e-wool/luasrc/view/e-wool/* /usr/lib/lua/luci/view/e-wool/
    chmod -R 644 /usr/lib/lua/luci/view/e-wool/
	cp -Rf $jd_dir2/luci-app-e-wool/root/usr/share/e-wool/* /usr/share/e-wool/
    chmod -R 755 /usr/share/e-wool/
	echo "更新完毕...若功能异常...重启下设备...实在不行就卸载重装..." >>$LOG_HTM 2>&1
	echo "清理垃圾..." >>$LOG_HTM 2>&1
	rm -rf $jd_dir2/luci-app-e-wool
	else
	echo "文件拉取失败...建议开启梯子进行更新..." >>$LOG_HTM 2>&1
	rm -rf $jd_dir2/luci-app-e-wool
	fi
	echo "任务已完成" >>$LOG_HTM 2>&1
	