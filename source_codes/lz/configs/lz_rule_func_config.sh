#!/bin/sh
# lz_rule_func_config.sh v3.6.3
# By LZ 妙妙呜 (larsonzhang@gmail.com)

# 本版本采用CIDR（无类别域间路由，Classless Inter-Domain Routing）技术
# 是一个在Internet上创建附加地址的方法，这些地址提供给服务提供商（ISP），再由ISP分配给客户。
# CIDR将路由集中起来，使一个IP地址代表主要骨干提供商服务的几千个IP地址，从而减轻Internet路由器的负担。
# ————百度百科

#BEIGIN

## 技巧：
##       上传编辑好的firewall-start文件和本代码至路由器后，开关防火墙即可启动本代码，不必重启路由器。
##       也可通过SSH命令行窗口直接输入如下命令：
##       启动/重启        /jffs/scripts/lz/lz_rule.sh
##       暂停运行         /jffs/scripts/lz/lz_rule.sh stop
##       终止运行         /jffs/scripts/lz/lz_rule.sh STOP
##       恢复缺省配置     /jffs/scripts/lz/lz_rule.sh default
##       动态分流模式配置 /jffs/scripts/lz/lz_rule.sh rn
##       静态分流模式配置 /jffs/scripts/lz/lz_rule.sh hd
##       IPTV模式配置     /jffs/scripts/lz/lz_rule.sh iptv
##       运行状态查询     /jffs/scripts/lz/lz_rule.sh status
##       网址信息查询     /jffs/scripts/lz/lz_rule.sh address 网址 [第三方DNS服务器IP地址（可选项）]
##       解除运行锁       /jffs/scripts/lz/lz_rule.sh unlock
## 提示：
##     1."启动/重启"命令用于手工启动或重启脚本服务。
##     2."暂停运行"命令仅是暂时关闭策略路由服务，重启路由器、线路接入或断开、WAN口IP改变、防火墙开关等
##       事件都会导致本脚本自启动重新运行。
##     3."终止运行"命令将彻底停止脚本提供的所有服务，需SSH命令行窗口手动启动方可运行。
##       卸载脚本前需先执行此命令。
##     4."恢复缺省配置"命令可将脚本的参数配置恢复至出厂的缺省状态。
##     5.脚本针对路由器WAN口通道的数据传输过程内置三种运行模式，按需设置或混搭采用相应的"动态路由"、"静
##       态路由"的网络数据路由传输技术方式，运行模式是策略分流服务所采用的技术组合和实现方式。
##       "动态路由"采用基于连接跟踪的报文数据包地址匹配标记导流的数据路由传输技术，能通过算法动态生成数
##       据经由路径，较少占用系统策略路由库静态资源。
##       "静态路由"采用按数据来源和目标地址通过经由路径规则直接映射网络出口的数据路由传输技术，当经由路
##       径规则条目数很多时会大量占用系统策略路由库的静态资源，若硬件平台性能有限，会出现数据库启动加载
##       时间过长的现象。
##     6.脚本为方便用户使用，提供两种应用模式（动态分流模式、静态分流模式）和一种基于静态分流模式的子场
##       景应用模式（IPTV模式）。应用模式结合用户应用需求和使用场景，将脚本内置的运行模式进行了应用层级
##       业务封装，自动设置脚本的运行模式，简化了脚本参数配置的复杂性，是策略分流服务基础的应用解决方案。
##       "动态分流模式"原名"普通模式"，"静态分流模式"原名"极速模式"。
##       脚本缺省应用模式为"动态分流模式"。
##     7."动态分流模式配置"命令原名"恢复普通模式"命令，主要采用动态路由技术，将脚本应用模式配置自动设置
##       为"动态分流模式"。
##       "动态分流模式"站点访问速度快、时延小，系统资源占用少，适合网页访问、聊天社交、影音视听、在线游
##       戏等日常应用场景。
##     8."静态分流模式配置"命令原名"极速模式配置"命令，用于将当前配置自动优化并修改为路由器最大带宽性能
##       传输模式配置。路由器所有WAN口通道全部采用静态路由方式。
##       老型号或弱势机型可能会有脚本服务启动时间过长的情况，可通过合理设定网段出口参数解决，可将条目数
##       量巨大的数据文件的网址/网段流量出口（例如：中国大陆其他运营商目标网段流量出口、中国电信目标网段
##       流量出口）与"中国大陆之外所有运营商及所有未被定义的目标网段流量出口"保持一致。
##       "静态分流模式"适用于高流量带宽的极速下载应用场景，路由器系统资源占用大，对硬件性能要求高，不适
##       于主频800MHz（含）以下CPU的路由器采用。
##     9."IPTV模式配置"命令仅用于路由器双线路连接方式中第一WAN口接入运营商宽带，第二WAN口接入运营商IPTV
##       网络的应用场景，会将脚本配置文件中的所有运营商目标网段流量出口参数自动修改为0，指向路由器的第一
##       WAN口。用户如果有运营商宽带IPTV机顶盒，请将IPTV机顶盒内网IP地址条目填入脚本配置文件"IPTV设置"部
##       分中的参数iptv_box_ip_lst_file所指定的IPTV机顶盒内网IP地址列表数据文件iptv_box_ip_lst.txt中，可
##       同时输入多个机顶盒ip地址条目，并在脚本配置文件中完成IPTV功能的其他设置，以确保IPTV机顶盒能够以
##       有线/无线方式连接到路由器后，能够完整接入运营商IPTV网络，全功能使用机顶盒的原有功能，包括直播、
##       回放、点播等，具体填写方法也可参考有关使用说明和案例。
##    10."IPTV模式配置"命令在路由器上提供运营商宽带、运营商IPTV传输的传输通道、IGMP组播数据转内网传输
##       代理以及UDPXY组播数据转HTTP流传输代理的参数配置，用户可在PC、手机等与路由器有线或无线连接的终
##       端上使用vlc或者potplayer等软件播放udpxy代理过的播放源地址，如：
##       http://192.168.50.1:8888/rtp/239.76.253.100:9000，其中192.168.50.1:8888为路由器本地地址及udpxy
##       访问端口。用户如需使用其他传输代理等优化技术请自行部署及配置，如需添加额外的脚本代码，建议使用
##       高级设置中的"外置用户自定义配置脚本"、"外置用户自定义双线路脚本"及"外置用户自定义清理资源脚本"
##       三个功能，并在指定的脚本文件中添加代码，使用方法参考脚本配置文件中的相应注释说明。
##    11.配置命令用于脚本配置参数的修改，简化脚本特殊工作模式参数配置的工作量，执行后会自动完成脚本相应
##       模式配置参数的修改，后续再次手工修改配置参数或进行脚本的启动/重启操作请使用“启动/重启”命令，无
##       需再次用模式配置命令作为相应模式脚本的启动命令。
##    12."解除运行锁"命令用于在脚本运行过程中，由于意外原因中断运行，如操作Ctrl+C键等，导致程序被同步运
##       行安全机制锁住，在不重启路由器的情况下，脚本无法再次启动或有关命令无法继续执行，可通过此命令强
##       制解锁。注意，在脚本正常运行过程中不要执行此命令。

## ----------------------------------------------------
## -------客户端或指定网址访问路由器出口自定义区-------

## 策略规则优先级执行顺序：由高到低排列，系统抢先执行高优先级策略。
##     IPTV机顶盒线路流量出口静态路由方式分流出口规则（iptv_box_ip_lst_file）
##     本地客户端网址/网段分流黑名单列表负载均衡静态路由方式出口规则（local_ipsets_file）
##     OpenVPNServer客户端访问互联网流量出口静态路由方式分流出口规则
##     第一WAN口用户自定义源网址/网段至目标网址/网段高优先级流量出口列表静态路由方式绑定出口规则（high_wan_1_src_to_dst_addr_file）
##     第二WAN口用户自定义源网址/网段至目标网址/网段流量出口列表静态路由方式绑定出口规则（wan_2_src_to_dst_addr_file）
##     第一WAN口用户自定义源网址/网段至目标网址/网段流量出口列表静态路由方式绑定出口规则（wan_1_src_to_dst_addr_file）
##     最高高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则--优先级ID：IP_RULE_PRIO_CUSTOM_TOP_HIGH
##     最高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则--优先级ID：IP_RULE_PRIO_CUSTOM_TOP
##     第二WAN口客户端及源网址/网段高优先级流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（high_wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段高优先级流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（high_wan_1_client_src_addr_file）
##     路由器主机内部应用访问外网及外网访问路由器静态路由方式出入口规则
##     高优先级用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则--优先级ID：IP_RULE_PRIO_CUSTOM_HIGH
##     用户自定义客户端或特定网址/网段流量出口静态路由方式命令绑定分流出口规则--优先级ID：IP_RULE_PRIO_CUSTOM
##     第二WAN口客户端及源网址/网段流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段流量出口列表（总条目数≤list_mode_threshold阈值时）静态路由方式绑定出口规则（wan_1_client_src_addr_file）
##     用户自定义目标网址/网段(2)（总条目数≤list_mode_threshold阈值时）流量静态路由方式分流出口规则（custom_data_file_2）
##     用户自定义目标网址/网段(1)（总条目数≤list_mode_threshold阈值时）流量静态路由方式分流出口规则（custom_data_file_1）
##     国内运营商目标网址/网段静态路由方式分流第二WAN口流量出口规则
##     国内运营商目标网址/网段静态路由方式分流第一WAN口流量出口规则
##     第二WAN口客户端及源网址/网段高优先级流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（high_wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段高优先级流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（high_wan_1_client_src_addr_file）
##     端口流量动态路由方式分流出口规则
##     协议流量动态路由方式分流出口规则
##     第二WAN口客户端及源网址/网段流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（wan_2_client_src_addr_file）
##     第一WAN口客户端及源网址/网段流量出口列表（总条目数>list_mode_threshold阈值时）动态路由方式绑定出口规则（wan_1_client_src_addr_file）
##     国内运营商及用户自定义目标网址/网段动态路由方式分流第二WAN口流量出口规则
##     国内运营商及用户自定义目标网址/网段动态路由方式分流第一WAN口流量出口规则
##     国外运营商目标网段流量动态路由方式分流出口规则
##     系统采用负载均衡技术自动分配流量出口规则
##     未被规则和已定义网址/网段数据覆盖的流量分流出口规则


## 自定义客户端或指定特定网址/网段访问的路由器网络出口
## 提示：
##     1.可定义一些内网网址/绑定使用指定WAN口访问外网，实际中可随时根据需要将终端IP切换到这些网址，从而
##       使用指定的WAN口访问外网。现实中有些网站会将访问请求跨网段跳转到另一处，同时会验证你的出口是否
##       唯一，这时你可能需要这段时间内走固定WAN口出游，这些预定义内网网址/网段就很有用了。
##     2.此外，还可在此设定访问某些外网地址使用指定的路由器WAN口。
##     3.为提高传输性能，使用命令方式将客户端绑定路由器网络出口后，建议同时将客户端本地网址/网段填入
##       local_ipsets_data.txt（本地客户端网址/网段流量出口列表绑定黑名单数据文件）中，阻止路由器对该客户
##       端设备进行额外的网址/网段分流、协议分流及端口分流计算。
##     4.此功能也可使用网址/网段列表数据文件方式，通过lz_rule_config.sh中的路由器WAN口客户端及源网址/网段
##       列表绑定功能或用户自定义目标网址/网段功能来替代，或使用WAN口用户自定义源网址/网段至目标网址/网段
##       流量出口列表绑定功能替代下述命令方式，该类方式无需填写本地客户端网址/网段流量出口列表绑定黑名单
##       数据文件，脚本已含内置的自动处理机制。

## 命令格式：
##     第一WAN口：ip add [ from 源IP地址/ip网段/all ] [ to 目标IP地址/ip网段/all ] table $WAN0 prio $[优先级]
##     第二WAN口：ip add [ from 源IP地址/ip网段/all ] [ to 目标IP地址/ip网段/all ] table $WAN1 prio $[优先级]
## 说明：[...] 为可选项，但前两个[...] 必留其一，且两个[...] 中的IP地址/ip网段/all不能相同；
##       使用网段表示法时，务必用ip地址计算器（网上找）验算，得到的地址范围内的地址是否是需要的网络地址；
##       [优先级]为必选项，按照上面的策略优先级执行顺序选择。

## 为避免脚本升级更新或重新安装导致配置重置为缺省状态，需要重新录入自定义代码，强烈建议将代码放入lz_rule_config.sh中定义的
## 外置用户自定义双线路脚本文件中，今后不需要在此文件中重复添加和编辑代码。或可将此文件复制并重命名为上述外置用户自定义双线
## 路脚本文件，并在lz_rule_config.sh中设置为可执行状态。另外，切不可在外置用户自定义双线路脚本文件与本文件中保存相同的可执
## 行的自定义脚本命令代码。

## 第二WAN口：路由表ID号为 WAN1
## 指定如下地址的客户端绑定使用WAN1口访问外网，优先级优先级按上述策略优先级执行顺序选择，条目可添加、减少或删除；
## 如下命令条目为示例，请根据实际需求修改，不需要可删除（初始处于注释状态，不影响脚本正常运行）；
## 若直接修改下述示例条目命令使用，请删除行首处"#"号注释符。
#ip rule add from 10.0.0.63 table $WAN1 prio $IP_RULE_PRIO_CUSTOM_TOP_HIGH	## 我的移动机顶盒，必须走第二WAN口的移动宽带才能播放视频
#ip rule add from 10.0.0.234/31 table $WAN1 prio $IP_RULE_PRIO_CUSTOM_HIGH	## 为我手机和其他设备10.0.0.234~235两个地址预留使用第二WAN口

## 第一WAN口：路由表ID号为 WAN0
## 指定如下地址的客户端绑定使用WAN0口访问外网，优先级：优先级按上述策略优先级执行顺序选择，条目可添加、减少或删除；
## 如下命令条目为示例，请根据实际需求修改，不需要可删除（初始处于注释状态，不影响脚本正常运行）；
## 若直接修改下述示例条目命令使用，请删除行首处"#"号注释符。
#ip rule add from all to 10.0.0.8 table $WAN0 prio $IP_RULE_PRIO_CUSTOM_TOP_HIGH	## 我的网盘，WAN口应与外网访问路由器WAN口一致
#ip rule add from 10.0.0.8 table $WAN0 prio $IP_RULE_PRIO_CUSTOM_TOP_HIGH	## 我的网盘，WAN口应与外网访问路由器WAN口一致
#ip rule add from all to 60.12.67.92 table $WAN0 prio $IP_RULE_PRIO_CUSTOM_TOP	## 使用高优先级通过第一WAN口访问该网址（www.asus.com.cn）
#ip rule add from all to 103.10.4.108 table $WAN0 prio $IP_RULE_PRIO_CUSTOM_TOP_HIGH	## 使用高优先级通过第一WAN口访问该网址（www.asuscomm.com）
#ip rule add from 10.0.0.76 table $WAN0 prio $IP_RULE_PRIO_CUSTOM	## 我的 MacBook Air 笔记本，要运行某联通应用，必须使用第一WAN口
#ip rule add from 10.0.0.210 table $WAN0 prio $IP_RULE_PRIO_CUSTOM_TOP_HIGH	## 我的智能平板电视，需使用固定WAN口访问被ISP绑定的视频
#ip rule add from 10.0.0.228/30 table $WAN0 prio $IP_RULE_PRIO_CUSTOM_TOP	## 为我手机和其他设备10.0.0.228~229两个地址预留使用第一WAN口


## 其他自定义脚本代码（仅在双线路同时接通广域网络条件下执行）
## 若需设置和初始化自定义全局变量请在同目录的lz_rule_config.sh文件内添加相应代码
## 若需启动或停止服务时清理相关数据和释放占用的系统资源，请在/jffs/scripts/lz/func目录中的lz_clear_custom_scripts_data.sh文件内嵌入相应脚本代码
<<EOF
if [ -f "/目录名/自定义脚本文件名.sh" ]; then
	chmod +x "/目录名/自定义脚本文件名.sh" > /dev/null 2>&1
	/bin/sh /目录名/自定义脚本文件名.sh
fi
EOF


## -----客户端或指定网址访问路由器出口自定义区结束-----
## ----------------------------------------------------

#END
