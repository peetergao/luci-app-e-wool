# luci-app-e-wool

OpenWRT 插件 魔改于jerrykuku的京东签到服务

自娱自乐

代码全靠百度

没有过多的解释

https://github.com/lxk0301/jd_scripts  套壳工具 Docker 并发版 只为了方便管理

只提供AArch64 构架lpk 因为我没有其他平台设备

# 准备环境

opkg update && opkg install git git-http wget curl

最重要：需要 docker-compose 支持 需要 docker-compose 支持 需要 docker-compose 支持

# 使用说明

0、设置项目目录（一般放在opt里面即可，但是要确保有足够的空间）

1、填写cookies

2、点击【初始化容器】（挂梯子以免镜像拉取失败）

3、初始化完毕就可以了 脚本会根据作者设定的时间运行

4、如果更新cookies 或者更新其他参数，保存后，点击 【启动/更新容器】 即可

5、UA设置 不会别弄，会导致很多脚本运行出错

6、互助码提取，一天活再执行，或者手动执行相关脚本然后再进行提取

7、运行模式，选择【追加模式】如果不了解这方面的话，默认即可

8、更新插件：这个最好挂梯子，更新完毕，最好重启下设备

9、剩下的自行体会，插件佛系更新
 
![image](https://github.com/XiaYi1002/luci-app-e-wool/blob/master/img/main.png)

# 非常感谢

排名不分先后

chongshengB 提供技术支持

https://github.com/chongshengB

lxk0301 提供项目

https://github.com/lxk0301

jerrykuku 提供插件

https://github.com/jerrykuku/luci-app-jd-dailybonus

