#!/bin/bash
#
#本人比较懒，直接修改自 <jerrykuku@qq.com>的京东签到脚本，额，我更懒，改自ChongshengB之后的脚本
#

NAME=e-wool
TEMP_SCRIPT=/tmp/JD_DailyBonus.js
LOG_HTM=/www/e-wool.htm
usage() {
    cat <<-EOF
		Usage: app.sh [options]
		Valid options are:

		    -a                      初始化
		    -b                      更新参数			
		    -c                      更新任务 
		    -d                      替换任务
			-t                      提取互助码
		    -w                      停止&删除
		    -x                      更新
		    -y                      停止
		    -z                      重启
		    -h                      Help
EOF
    exit $1
}

# Common functions

uci_get_by_name() {
    local ret=$(uci get $NAME.$1.$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_get_by_type() {
    local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_set_by_type() {
	uci add_list $NAME.@$1[0].$2=$3 2>/dev/null
	uci commit $NAME
}

uci_dellist_by_type() {
	uci delete $NAME.@$1[0].$2 2>/dev/null
	uci commit $NAME
}

cancel() {
    if [ $# -gt 0 ]; then
        echo "$1"
    fi
    exit 1
}
# 寻找目标
run() {
    cookies=$(uci_get_by_type global cookiebkye)
	if [ ! -n "$cookies" ]; then
	echo "未设置cookies 请先配置好cookies 请先配置好cookies 请先配置好cookies 再进行初始化" >>$LOG_HTM && exit 1
    else
    echo "Cookies已配置 开始执行..." >>$LOG_HTM 2>&1
	echo "注：Cookies 中不能带有空格哦" >>$LOG_HTM 2>&1
	echo "注：Cookies 中不能带有空格哦" >>$LOG_HTM 2>&1
	echo "注：Cookies 中不能带有空格哦" >>$LOG_HTM 2>&1
    fi
}

# 收购铜锣湾
a_run() {
	jd_dir2=$(uci_get_by_type global jd_dir)
	if [ ! -d $jd_dir2 ]; then
# 场地没被收购 赶紧拿下
    echo "创建脚本目录..." >>$LOG_HTM 2>&1
    mkdir $jd_dir2
	chmod -R 777 $jd_dir2
    else
	echo "停止并删除容器..." >>$LOG_HTM 2>&1
# 场地被卖了 管它的 抢就对了
# 带上家伙去他地盘
	cd $jd_dir2
# 宰了他们主事的
	docker-compose down >>$LOG_HTM 2>&1
# 火烧了他的地盘
	rm -rf $jd_dir2
    echo "容器已停止并删除" >>$LOG_HTM 2>&1
    fi
}

# 开始建设铜锣湾
b_run() {
	notify_enable=$(uci_get_by_type global notify_enable)
    jd_dir2=$(uci_get_by_type global jd_dir)
	sckey=$(uci_get_by_type global serverchan)
    tg_token=$(uci_get_by_type global tg_token)
    tg_id=$(uci_get_by_type global tg_id)
    igot=$(uci_get_by_type global igot)
	ua=$(uci_get_by_type global useragent)
	wait=$(uci_get_by_type global beansignstop)
	men=$(uci_get_by_type global cont_men 256M)
	jd_cname=$(uci_get_by_type global jd_cname jd_scripts)
	cron_model=$(uci_get_by_type global cron_model)
	qq_skey=$(uci_get_by_type global qq_skey)
	qq_mode=$(uci_get_by_type global qq_mode)
    echo "配置脚本参数..." >>$LOG_HTM 2>&1	
	if [ ! -d $jd_dir2 ]; then
	#场地没被收购 赶紧拿下
    mkdir $jd_dir2
	chmod -R 777 $jd_dir2
	fi
# 配置酷推推送模式
    if [ $qq_mode -eq 0 ]; then
	qmode=send
	elif [ $qq_mode -eq 1 ]; then
	qmode=group
	elif [ $qq_mode -eq 2 ]; then
	qmode=wx
	fi
# 配置yml
	cat <<-EOF > $jd_dir2/docker-compose.yml
version: "3.7"
services:
	EOF
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		cat <<-EOF >> $jd_dir2/docker-compose.yml
    $jd_cname$j:
      image: akyakya/jd_scripts
      deploy:
        resources:
          limits:
            memory: $men
      container_name: $jd_cname$j
      restart: always
      network_mode: "host"
      volumes:
        - ./my_crontab_list.sh:/scripts/docker/my_crontab_list.sh
        - ./logs$j:/scripts/logs
        - ./docker_crontabs:/etc/crontabs
        -  /etc/localtime:/etc/localtime
      tty: true
      environment:
        # 注意环境变量填写值的时候一律不需要引号（""或者''）下面这些只是事例，根据自己的需求增加删除
        #jd cookies
        # 例: JD_COOKIE=pt_key=XXX;pt_pin=XXX;
        - JD_COOKIE=$ck
        #微信server酱通
        - PUSH_KEY=$sckey
        #telegram机器人通知
        - TG_BOT_TOKEN=$tg_token
        - TG_USER_ID=$tg_id
        #酷推推送
        - QQ_MODE=$qmode
        - QQ_SKEY=$qq_skey
        #通知形式
        - JD_BEAN_SIGN_NOTIFY_SIMPLE=
        #自定义此库里京东系列脚本的UserAgent，不懂不知不会UserAgent的请不要随意填写内容。
        - JD_USER_AGENT=$ua
        #自定义签到延迟
        - JD_BEAN_STOP=$wait
        #自定义参数
        #如果使用自定义定时任务,取消下面一行的注释
        - CUSTOM_LIST_FILE=my_crontab_list.sh
        # - CUSTOM_LIST_MERGE_TYPE=overwrite
		EOF
		let j++
	done
	j=`expr $j - 1`
	chmod -R 777 $jd_dir2
	echo "判断通知形式..." >>$LOG_HTM 2>&1
	if [ $notify_enable -eq 0 ]; then
    echo "当前形式： 简要通知" >>$LOG_HTM 2>&1
	sed -i  's/- JD_BEAN_SIGN_NOTIFY_SIMPLE=/&true/' $jd_dir2/docker-compose.yml
	else
	echo "当前形式： 原始通知" >>$LOG_HTM 2>&1
	fi
	if [ $cron_model -eq 1 ]; then
    echo "判断计划任务运行模式..." >>$LOG_HTM 2>&1
	echo "当前模式：覆盖模式" >>$LOG_HTM 2>&1
	sed -i 's/# - CUSTOM_LIST_MERGE_TYPE=overwrite/- CUSTOM_LIST_MERGE_TYPE=overwrite/g' $jd_dir2/docker-compose.yml
	else
	echo "当前模式：追加模式" >>$LOG_HTM 2>&1
	fi
}

# 签约商户
c_run() {
    echo "增加自定义参数..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    grep "list diyhz" /etc/config/e-wool >$jd_dir2/diyhz.log
    sed -i "s/\'//g" $jd_dir2/diyhz.log
    sed -i "s/list diyhz//g" $jd_dir2/diyhz.log
    sed -i 's/^[ \t]*//g' $jd_dir2/diyhz.log
	sed -i 's/^/- &/g' $jd_dir2/diyhz.log
	while read linea
	do
    sed -i "/#自定义参数/a\'        $linea'" $jd_dir2/docker-compose.yml
	sed -i "s/\'//g" $jd_dir2/docker-compose.yml
	rm -rf $jd_dir2/diyhz.log
	done < $jd_dir2/diyhz.log
}

# 商户营业时间
d_run() {
    echo "配置计划任务计划..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
	cron_model=$(uci_get_by_type global cron_model)
	if [ $cron_model -eq 0 ]; then
	echo "当前模式：追加模式" >>$LOG_HTM 2>&1
	echo "追加自定义任务列表到默认任务列表中..." >>$LOG_HTM 2>&1
    grep "list crondiy" /etc/config/e-wool >$jd_dir2/my_crontab_list.sh
    sed -i "s/\'//g" $jd_dir2/my_crontab_list.sh
    sed -i "s/list crondiy//g" $jd_dir2/my_crontab_list.sh
    sed -i 's/^[ \t]*//g' $jd_dir2/my_crontab_list.sh
	sed -i '1i\# 以下是追加的计划任务' $jd_dir2/my_crontab_list.sh
	echo "追加完毕 更新容器任务列表..." >>$LOG_HTM 2>&1
	elif [ $cron_model -eq 1 ]; then
	echo "当前模式：覆盖模式" >>$LOG_HTM 2>&1
	echo "请自行添加计划任务列表：my_crontab_list.sh 至项目根目录" >>$LOG_HTM 2>&1
	fi
	if [[ $cron_model -eq 1 && $crondiy_enable -eq 1 ]]; then
	echo "追加自定义任务列表到默认任务列表中：my_crontab_list.sh..." >>$LOG_HTM 2>&1
	sed -i '/# 以下是追加的计划任务/,/# 以上是追加的计划任务/d' $jd_dir2/my_crontab_list.sh
    grep "list crondiy" /etc/config/e-wool >$jd_dir2/my_crontab_list.log
    sed -i "s/\'//g" $jd_dir2/my_crontab_list.log
    sed -i "s/list crondiy//g" $jd_dir2/my_crontab_list.log
    sed -i 's/^[ \t]*//g' $jd_dir2/my_crontab_list.log
	sed -i '1i\# 以下是追加的计划任务' $jd_dir2/my_crontab_list.log
	sed -i '$a\# 以上是追加的计划任务'  $jd_dir2/my_crontab_list.log
	cat $jd_dir2/my_crontab_list.log >> $jd_dir2/my_crontab_list.sh
	echo "追加完毕 更新容器任务列表..." >>$LOG_HTM 2>&1	
	rm -rf $jd_dir2/my_crontab_list.log
	fi
	chmod -R 777 $jd_dir2
}

# 处理cookies空格
ck_run() {
	grep "list cookiebkye" /etc/config/e-wool >/tmp/cookies.log
	sed -i "s/	list cookiebkye //g" /tmp/cookies.log
	sed -i s/[[:space:]]//g /tmp/cookies.log
	sed -i 's/^/	list cookiebkye &/g' /tmp/cookies.log
	uci_dellist_by_type global cookiebkye
    chmod -R 755 /etc/config/e-wool
	cat /tmp/cookies.log >> /etc/config/e-wool
	rm -rf /tmp/cookies.log
}

# 作者自定义脚本（不公开）
diy_run() {
	if [ ! -f "/usr/share/e-wool/diyrun.sh" ];then
	echo "哼"
	else
	echo "执行自定义脚本" >>$LOG_HTM 2>&1
	/usr/share/e-wool/diyrun.sh
	fi
}
# 替换计划任务
h_run() {
    jd_dir2=$(uci_get_by_type global jd_dir)
	cron_model=$(uci_get_by_type global cron_model)
    echo "开始拉取云端任务列表：crontab_list.sh..." >>$LOG_HTM 2>&1
	cd $jd_dir2
	curl -o crontab_list.sh https://cdn.jsdelivr.net/gh/lxk0301/jd_scripts@master/docker/crontab_list.sh >> $LOG_HTM 2>&1
	echo "拉取完毕 文件存放在项目根目录 crontab_list.sh" >>$LOG_HTM 2>&1
	echo "判断运行模式..." >>$LOG_HTM 2>&1
	if [ $cron_model -eq 1 ]; then
	echo "当前模式：覆盖模式" >>$LOG_HTM 2>&1
	echo "开始替换任务..." >>$LOG_HTM 2>&1
	cp -R crontab_list.sh my_crontab_list.sh
	echo "任务已替换完成 如需让 my_crontab_list.sh 生效，请点击【更新计划任务】" >>$LOG_HTM 2>&1
	else
	echo "当前模式：追加模式 不执行替换..." >>$LOG_HTM 2>&1
	fi
	chmod -R 777 $jd_dir2
}

# 手动执行脚本
sd_run() {
	jd_dir2=$(uci_get_by_type global jd_dir)
	jd_cname=$(uci_get_by_type global jd_cname jd_scripts)
	sh=$(uci_get_by_type global sd_run)
	echo "开始执行任务..." >> $LOG_HTM 2>&1
	echo "本次执行脚本：$sh" >> $LOG_HTM 2>&1
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		docker exec $jd_cname$j node /scripts/$sh >> $LOG_HTM 2>&1
    cat <<-EOF > $jd_dir2/docker_crontabs/sd_run.sh
#!/bin/sh
node /scripts/$sh |ts >> /scripts/logs/$sh.log 2>&1
		EOF
	chmod 755 $jd_dir2/docker_crontabs/sd_run.sh
    jd_cname=$(uci_get_by_type global jd_cname jd_scripts)
	for ck in $(uci_get_by_type global cookiebkye); do
	j=1
		let j++
	done
	docker exec -i $jd_cname$j sh /etc/crontabs/sd_run.sh &
	uci_dellist_by_type global sd_run
	rm -rf $jd_dir2/docker_crontabs/sd_run.sh
}

#互助码提取
allshare_code(){
	#清除旧的助力码
	uci_dellist_by_type global jxgc_sharecode
	uci_dellist_by_type global ddgc_sharecode
	uci_dellist_by_type global zddd_sharecode
	uci_dellist_by_type global nc_sharecode
	uci_dellist_by_type global pet_sharecode
	uci_dellist_by_type global jdzzsc_sharecode
	uci_dellist_by_type global czjsc_sharecode
	jd_dir2=$(uci_get_by_type global jd_dir)
	j=1
	for ck in $(uci_get_by_type global cookiebkye); do
		old=0
		if test ! -f "$jd_dir2/logs$j/sharecode.log" ; then
			echo "cookie$j未检测到互助码日志文件" >> $LOG_HTM 2>&1
		else
			ddsc=`sed -n '/东东工厂好友互助码】.*/'p $jd_dir2/logs$j/sharecode.log | awk '{print $1}' | sed -e 's/【京东账号.*好友互助码】//g'`
			jxsc=`sed -n '/京喜工厂好友互助码】.*/'p $jd_dir2/logs$j/sharecode.log | awk '{print $1}' | sed -e 's/【京东账号.*好友互助码】//g'`
			zdsc=`sed -n '/京东种豆得豆好友互助码】.*/'p $jd_dir2/logs$j/sharecode.log | awk '{print $1}' | sed -e 's/【京东账号.*好友互助码】//g'`
			ncsc=`sed -n '/东东农场好友互助码】.*/'p $jd_dir2/logs$j/sharecode.log | awk '{print $1}' | sed -e 's/【京东账号.*好友互助码】//g'`
			petsc=`sed -n '/东东萌宠好友互助码】.*/'p $jd_dir2/logs$j/sharecode.log | awk '{print $1}' | sed -e 's/【京东账号.*好友互助码】//g'`
			jdzzsc=`sed -n '/京东赚赚好友互助码】.*/'p $jd_dir2/logs$j/sharecode.log | awk '{print $1}' | sed -e 's/【京东账号.*好友互助码】//g'`
			czjsc=`sed -n '/crazyJoy任务好友互助码】.*/'p $jd_dir2/logs$j/sharecode.log | awk '{print $1}' | sed -e 's/【京东账号.*好友互助码】//g'`
			if test -n "$ddsc" ; then
				uci_set_by_type global ddgc_sharecode $ddsc
				echo "cookie$j东东工厂互助码:"$ddsc >> $LOG_HTM 2>&1
			fi
			if test -n "$jxsc" ; then
				uci_set_by_type global jxgc_sharecode $jxsc
				echo "cookie$j京喜工厂互助码:"$jxsc >> $LOG_HTM 2>&1
			fi
			if test -n "$zdsc" ; then
				uci_set_by_type global zddd_sharecode $zdsc
				echo "cookie$j京东种豆得豆互助码:"$zdsc >> $LOG_HTM 2>&1
			fi
			if test -n "$ncsc" ; then
				uci_set_by_type global nc_sharecode $ncsc
				echo "cookie$j东东农场互助码:"$ncsc >> $LOG_HTM 2>&1
			fi
			if test -n "$petsc" ; then
				uci_set_by_type global pet_sharecode $petsc
				echo "cookie$j东东萌宠互助码:"$petsc >> $LOG_HTM 2>&1
			fi
			if test -n "$jdzzsc" ; then
				uci_set_by_type global jdzzsc_sharecode $jdzzsc
				echo "cookie$j京东赚赚互助码:"$jdzzsc >> $LOG_HTM 2>&1
			fi
			if test -n "$czjsc" ; then
				uci_set_by_type global czjsc_sharecode $czjsc
				echo "cookie$j crazyJoy互助码:"$czjsc >> $LOG_HTM 2>&1
			fi
		fi
		let j++
	done

}

# 开始运营
w_run() {
    echo "启动容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility up -d >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

# 场地重新规划建设
x_run() {
    echo "更新镜像..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility pull >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}
# 疫情爆发，躲起来
y_run() {
    echo "停止容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility stop >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

# 疫情过了，赶紧重新营业
z_run() {
    echo "重启容器..." >>$LOG_HTM 2>&1
    jd_dir2=$(uci_get_by_type global jd_dir)
    cd $jd_dir2
    docker-compose --compatibility restart >>$LOG_HTM 2>&1
    echo "任务已完成" >>$LOG_HTM 2>&1
}

system_time() {
time3=$(date "+%Y-%m-%d %H:%M:%S")
echo "系统时间：$time3" >$LOG_HTM 2>&1
}

	
while getopts ":abcdsotxyzh" arg; do
    case "$arg" in
	#初始化
    a)
	    system_time
		run
	    a_run
        b_run
		c_run
		d_run
		diy_run
		h_run
		w_run
        exit 0
        ;;
	#更新参数
    b)
	    system_time
        b_run
		c_run
		d_run
		diy_run
		w_run
        exit 0
        ;;
	#更新任务
    c)
	    system_time
        d_run
		z_run
        exit 0
        ;;
	#替换计划任务
    d)
	    system_time
        h_run
		z_run
        exit 0
        ;;
	#保存&应用
    s)
	    system_time
		ck_run
		sd_run
        exit 0
        ;;
	#提取互助码
	t)
	    system_time
	    echo "开始提取助力码" >$LOG_HTM 2>&1
		allshare_code
		echo "助力码提取完毕" >>$LOG_HTM 2>&1
        exit 0
        ;;
    #停止&删除
    w)
		system_time
        a_run
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
	#更新
    x)
	    system_time
        x_run
        exit 0
        ;;
	#停止
    y)
	    system_time
        y_run
        exit 0
        ;;
	#重启	
    z)
	   system_time
	    z_run
        exit 0
        ;;
	#帮助
    h)
        usage 0
        ;;
    esac
done
