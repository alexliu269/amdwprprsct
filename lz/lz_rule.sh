#!/bin/sh
# lz_rule.sh v3.5.7
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
## -------------全局数据定义及初始化-------------------

## 版本号
LZ_VERSION=v3.5.7

## 运行状态查询命令
SHOW_STATUS="status"

## 网络地址查询命令
ADDRESS_QUERY="address"

## 解除运行锁命令
FORCED_UNLOCKING="unlock"

echo $(date) [$$]:
echo $(date) [$$]: LZ $LZ_VERSION script commands start......
echo $(date) [$$]: By LZ \(larsonzhang@gmail.com\)

## 项目文件部署路径
PATH_BASE=/jffs/scripts
PATH_LZ=${PATH_BASE}/lz
PATH_CONFIGS=${PATH_LZ}/configs
PATH_FUNC=${PATH_LZ}/func
PATH_DATA=${PATH_LZ}/data
PATH_INTERFACE=${PATH_LZ}/interface

## 调用自定义配置子例程宏定义
CALL_CONFIG_SUBROUTINE="source ${PATH_CONFIGS}"

## 调用功能子例程宏定义
CALL_FUNC_SUBROUTINE="source ${PATH_FUNC}"

## 同步锁文件路径
PATH_LOCK=/var/lock

## 文件同步锁全路径文件名
LOCK_FILE=${PATH_LOCK}/lz_rule.lock

## 脚本实例列表全路径文件名
INSTANCE_LIST=${PATH_LOCK}/lz_rule_instance.lock

## 同步锁文件ID
LOCK_FILE_ID=555

if [ "$1" != "$FORCED_UNLOCKING" ]; then
	echo "lz_$1" >> ${INSTANCE_LIST}
	## 设置文件同步锁
	[ ! -d ${PATH_LOCK} ] && { mkdir -p ${PATH_LOCK} > /dev/null 2>&1; chmod 777 ${PATH_LOCK} > /dev/null 2>&1; }
	exec 555<>"${LOCK_FILE}"; flock -x "$LOCK_FILE_ID" > /dev/null 2>&1;
	## 运行实例处理
	sed -i '/^$/d' ${INSTANCE_LIST} > /dev/null 2>&1
	sed -i '/^[ ]*$/d' ${INSTANCE_LIST} > /dev/null 2>&1
	sed -i '1d' ${INSTANCE_LIST} > /dev/null 2>&1
	if [ $( cat ${INSTANCE_LIST} 2> /dev/null | grep -c 'lz_' ) -gt 0 ]; then
		local_instance=$( cat ${INSTANCE_LIST} 2> /dev/null | grep 'lz_' | sed -n 1p | sed -e 's/^[ ]*//g' -e 's/[ ]*$//g' )
		if [ "$local_instance" = "lz_$1" \
			-a "$local_instance" != "lz_$SHOW_STATUS" -a "$local_instance" != "lz_$ADDRESS_QUERY" ]; then
			unset local_instance
			echo $(date) [$$]: The policy routing service is being started by another instance.
			echo $(date) [$$]: ----------------------------------------
			echo $(date) [$$]: LZ $LZ_VERSION script commands executed!
			echo $(date) [$$]:
			## 解除文件同步锁
			flock -u "$LOCK_FILE_ID" > /dev/null 2>&1
			exit
		fi
		unset local_instance
	fi
fi

[ "$1" != "$SHOW_STATUS" -a "$1" != "$ADDRESS_QUERY" -a "$1" != "$FORCED_UNLOCKING" ] && {
	echo $(date) [$$]: >> /tmp/syslog.log
	echo $(date) [$$]: -------- LZ $LZ_VERSION rules come here! ----------- >> /tmp/syslog.log
}

## 第一WAN口路由表ID号
WAN0=100

## 第二WAN口路由表ID号
WAN1=200

## 项目文件管理函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
lz_project_file_management() {
	## 使项目文件部署路径、配置脚本、功能脚本和数据文件处于可运行状态
	[ ! -d ${PATH_LZ} ] && mkdir -p ${PATH_LZ} > /dev/null 2>&1
	chmod 775 ${PATH_LZ} > /dev/null 2>&1
	[ ! -d ${PATH_CONFIGS} ] && mkdir -p ${PATH_CONFIGS} > /dev/null 2>&1
	chmod 775 ${PATH_CONFIGS} > /dev/null 2>&1
	[ ! -d ${PATH_FUNC} ] && mkdir -p ${PATH_FUNC} > /dev/null 2>&1
	chmod 775 ${PATH_FUNC} > /dev/null 2>&1
	[ ! -d ${PATH_DATA} ] && mkdir -p ${PATH_DATA} > /dev/null 2>&1
	chmod 775 ${PATH_DATA} > /dev/null 2>&1
	[ ! -d ${PATH_INTERFACE} ] && mkdir -p ${PATH_INTERFACE} > /dev/null 2>&1
	chmod 775 ${PATH_INTERFACE} > /dev/null 2>&1
	cd ${PATH_CONFIGS}/ > /dev/null 2>&1 && chmod -R 775 * > /dev/null 2>&1
	cd ${PATH_FUNC}/ > /dev/null 2>&1 && chmod -R 775 * > /dev/null 2>&1
	cd ${PATH_DATA}/ > /dev/null 2>&1 && chmod -R 775 * > /dev/null 2>&1
	cd ${PATH_INTERFACE}/ > /dev/null 2>&1 && chmod -R 775 * > /dev/null 2>&1
	cd ${PATH_LZ}/ > /dev/null 2>&1 && chmod -R 775 * > /dev/null 2>&1

	## 检查脚本关键文件是否存在，若有不存在项则退出运行。
	local local_scripts_file_exist=1
	[ ! -f ${PATH_FUNC}/lz_initialize_config.sh ] && {
		echo $(date) [$$]: The file ${PATH_FUNC}/lz_initialize_config.sh does not exist.
		echo $(date) [$$]: LZ ${PATH_FUNC}/lz_initialize_config.sh does not exist. >> /tmp/syslog.log
		local_scripts_file_exist=0
	}
	[ ! -f ${PATH_FUNC}/lz_define_global_variables.sh ] && {
		echo $(date) [$$]: The file ${PATH_FUNC}/lz_define_global_variables.sh does not exist.
		echo $(date) [$$]: LZ ${PATH_FUNC}/lz_define_global_variables.sh does not exist. >> /tmp/syslog.log
		local_scripts_file_exist=0
	}
	[ ! -f ${PATH_FUNC}/lz_clear_custom_scripts_data.sh ] && {
		echo $(date) [$$]: The file ${PATH_FUNC}/lz_clear_custom_scripts_data.sh does not exist.
		echo $(date) [$$]: LZ ${PATH_FUNC}/lz_clear_custom_scripts_data.sh does not exist. >> /tmp/syslog.log
		local_scripts_file_exist=0
	}
	[ ! -f ${PATH_FUNC}/lz_rule_func.sh ] && {
		echo $(date) [$$]: The file ${PATH_FUNC}/lz_rule_func.sh does not exist.
		echo $(date) [$$]: LZ ${PATH_FUNC}/lz_rule_func.sh does not exist. >> /tmp/syslog.log
		local_scripts_file_exist=0
	}
	[ ! -f ${PATH_FUNC}/lz_rule_status.sh ] && {
		echo $(date) [$$]: The file ${PATH_FUNC}/lz_rule_status.sh does not exist.
		echo $(date) [$$]: LZ ${PATH_FUNC}/lz_rule_status.sh does not exist. >> /tmp/syslog.log
		local_scripts_file_exist=0
	}
	[ ! -f ${PATH_FUNC}/lz_rule_address_query.sh ] && {
		echo $(date) [$$]: The file ${PATH_FUNC}/lz_rule_address_query.sh does not exist.
		echo $(date) [$$]: LZ ${PATH_FUNC}/lz_rule_address_query.sh does not exist. >> /tmp/syslog.log
		local_scripts_file_exist=0
	}
	if [ "$local_scripts_file_exist" = "0" ]; then
		echo $(date) [$$]: Policy routing service can\'t be started.
		echo $(date) [$$]: -------- No LZ $LZ_VERSION rules run! -------------- >> /tmp/syslog.log
		echo $(date) [$$]: >> /tmp/syslog.log
		return 1
	fi
	return 0
}

## 运行实例检测函数
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：
##     0--有新实例开始运行
##     1--无新实例开始运行
lz_check_instance() {
	[ $( cat ${INSTANCE_LIST} 2> /dev/null | grep -c 'lz_' ) -le 0 ] && return 1
	local local_instance=$( cat ${INSTANCE_LIST} 2> /dev/null | grep 'lz_' | sed -n 1p | sed -e 's/^[ ]*//g' -e 's/[ ]*$//g' )
	[ "$local_instance" != "lz_$1" -o "$local_instance" = "lz_$SHOW_STATUS" -o "$local_instance" = "lz_$ADDRESS_QUERY"  ] && return 1
	echo $(date) [$$]: The policy routing service is being started by another instance.
	echo $(date) [$$]: LZ Another script instance is running. >> /tmp/syslog.log
	echo $(date) [$$]: -------- LZ $LZ_VERSION rules running! ------------- >> /tmp/syslog.log
	echo $(date) [$$]: >> /tmp/syslog.log
	return 0
}

## 实例退出处理函数
## 输入项：
##     全局变量及常量
## 返回值：无
lz_instance_exit() {
	[ $( cat ${INSTANCE_LIST} 2> /dev/null | grep -c 'lz_' ) -le 0 ] && \
		rm -rf ${INSTANCE_LIST} > /dev/null 2>&1
}

## ---------------------主执行脚本---------------------

__lz_main() {

	echo $(date) [$$]: Initialization script configuration parameters......

	## 初始化脚本配置
	## 输入项：
	##     $1--主执行脚本运行输入参数
	## 返回值：无
	${CALL_FUNC_SUBROUTINE}/lz_initialize_config.sh "$1"

	## 运行实例检测
	## 输入项：
	##     $1--主执行脚本运行输入参数
	##     全局变量及常量
	## 返回值：
	##     0--有新实例开始运行
	##     1--无新实例开始运行
	lz_check_instance "$1" && return

	## 载入脚本配置参数
	## 策略分流的用户自定义配置在/jffs/scripts/lz/configs/目录下的lz_rule_config.sh
	## 和lz_rule_func_config.sh文件中
	${CALL_CONFIG_SUBROUTINE}/lz_rule_config.sh

	## 全局常量、变量定义及初始化
	## 输入项：
	##     全局常量
	## 返回值：无
	${CALL_FUNC_SUBROUTINE}/lz_define_global_variables.sh

	## 载入函数功能定义
	${CALL_FUNC_SUBROUTINE}/lz_rule_func.sh

	echo $(date) [$$]: Configuration parameters initialization is complete.
	echo $(date) [$$]: Get the router device information......

	## 启动延时5秒
#	sleep 5s

	## 删除自动清理路由表缓存定时任务
	if [ -n "$( cru l | grep "#${CLEAR_ROUTE_CACHE_TIMEER_ID}#" )" ]; then
		cru d ${CLEAR_ROUTE_CACHE_TIMEER_ID} > /dev/null 2>&1
	fi

	## 获取策略分流运行模式
	## 输入项：
	##     全局变量及常量
	## 返回值：
	##     policy_mode--分流模式（0：模式1；1：模式2；>1：模式3或处于单线路无须分流状态）
	##     0--当前为双线路状态
	##     1--当前为非双线路状态
	lz_get_policy_mode

	lz_check_instance "$1" && return

	## 获取路由器基本信息并输出至系统记录
	## 输入项：
	##     $1--主执行脚本运行输入参数
	##     全局变量
	##         route_hardware_type--路由器硬件类型
	##         route_os_name--路由器操作系统名称
	##         policy_mode--分流模式
	## 返回值：
	##     MATCH_SET--iptables设置操作符宏变量，全局常量
	##     route_local_ip--路由器本地IP地址，全局变量
	lz_get_route_info "$1"

	lz_check_instance "$1" && return

	echo $(date) [$$]: Initializes the policy routing library......
	echo $(date) [$$]: -------- LZ $LZ_VERSION rules initializing! -------- >> /tmp/syslog.log

	## 处理系统负载均衡分流策略规则
	## 输入项：
	##     $1--规则优先级（$IP_RULE_PRIO_BALANCE--ASUS原始；$IP_RULE_PRIO + 1--脚本定义）
	##     全局常量
	## 返回值：无
	lz_sys_load_balance_control "$(( $IP_RULE_PRIO + 1 ))"

	## 加载ipset组件
	## 输入项：
	##     $1--主执行脚本运行输入参数
	## 返回值：无
	lz_load_ipset_module "$1"

	## 加载hashlimit组件
	## 输入项：
	##     $1--主执行脚本运行输入参数
	## 返回值：无
	[ "$limit_client_download_speed" = "0" ] && lz_load_hashlimit_module "$1"

	## 数据清理
	## 输入项：
	##     $1--主执行脚本运行输入参数
	##     全局常量
	## 返回值：
	##     ip_rule_exist--删除后剩余条目数，正常为0，全局变量
	lz_data_cleaning "$1"

	echo $(date) [$$]: Policy routing library has been initialized.
	echo $(date) [$$]: -------- LZ $LZ_VERSION rules initialized! --------- >> /tmp/syslog.log

	## 接到停止运行命令
	## SSH中执行“/jffs/scripts/lz_rule.sh stop”或“/jffs/scripts/lz_rule.sh STOP”，都会立刻停止本脚本配
	## 置的策略路由服务，若“/jffs/firewall-start”中的“/jffs/scripts/lz_rule.sh”引导启动命令未清除，路
	## 由器重启、线路接入或断开、防火墙开关等事件都会导致自启动运行本脚本。
	if [ "$1" = "stop" -o "$1" = "STOP" ]; then
		## 输出IPTV规则条目数至系统记录
		## 输出当前单项分流规则的条目数至系统记录
		## 输入项：
		##     $1--规则优先级
		## 返回值：
		##     ip_rule_exist--条目总数数，全局变量
		lz_single_ip_rule_output_syslog "$IP_RULE_PRIO_IPTV"

		## 输出当前分流规则每个优先级的条目数至系统记录
		## 输入项：
		##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
		##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
		##     全局变量（ip_rule_exist）
		## 返回值：无
		lz_ip_rule_output_syslog "$IP_RULE_PRIO_TOPEST" "$IP_RULE_PRIO"

		## 清除接口脚本文件
		## 输入项：
		##     $1--主执行脚本运行输入参数
		##     全局常量
		## 返回值：无
		lz_clear_interface_scripts "$1"

		## 恢复系统负载均衡分流策略规则为系统初始的优先级状态
		## 处理系统负载均衡分流策略规则
		## 输入项：
		##     $1--规则优先级（$IP_RULE_PRIO_BALANCE--ASUS原始；$IP_RULE_PRIO + 1--脚本定义）
		##     全局常量
		## 返回值：无
		lz_sys_load_balance_control "$IP_RULE_PRIO_BALANCE"

		echo $(date) [$$]: Policy routing service has stopped.
		echo $(date) [$$]: -------- LZ $LZ_VERSION rules stopped! ------------- >> /tmp/syslog.log

		## SS服务支持
		## 输入项：
		##     全局变量及常量
		## 返回值：无
		lz_ss_support

		echo $(date) [$$]: >> /tmp/syslog.log

		return
	fi

	## 创建firewall-start启动文件并添加脚本引导项
	## 输入项：
	##     全局常量
	## 返回值：无
	lz_create_firewall_start_command

	## 创建更新ISP网络运营商CIDR网段数据的脚本文件及定时任务
	## 输入项：
	##     $1--主执行脚本运行输入参数
	##     全局变量及常量
	## 返回值：无
	lz_create_update_ispip_data_file "$1"

	## 载入外置用户自定义配置脚本文件
	if [ "$custom_config_scripts" = "0" -a ! -z "$custom_config_scripts_filename" ]; then
		if [ -f "$custom_config_scripts_filename" ]; then
			chmod 775 "$custom_config_scripts_filename" > /dev/null 2>&1
			source "$custom_config_scripts_filename"
		fi
	fi

	lz_check_instance "$1" && return

	## 流量路由策略部署
	## 脚本中先add的rule优先级低
	## 脚本使用 IP_RULE_PRIO+1 ~ IP_RULE_PRIO_TOPEST、IP_RULE_PRIO_IPTV 42个优先级，数值越小，优先级越高，网络访问
	## 数据包优先匹配高优先级规则
	## 部署条件：双线接入成功，系统内成功自建wan0、wan1路由表，案中规则尚未部署
	## 重要说明：WAN0口指路由器接入宽带的第一WAN口，路由表为wan0；WAN1口指第二WAN口，路由表为wan1
	## 案例背景：第一WAN口接联通宽带，300M，响应快，公网出口IP，稳定，上行带宽小
	##           第二WAN口接移动宽带，300M，时延大，内网出口IP，承诺话费送的
	##           尽可能选品质好的宽带接第一WAN口
	##           若与本案例应用背景不同，可在/jffs/scripts/lz/configs/目录下的lz_rule_config.sh和
	##           lz_rule_func_config.sh文件中“用户运行策略自定义区”修改路由器策略路由配置

	## 双线路
	if [ -n "$( ip route | grep nexthop | sed -n 1p )" -a $ip_rule_exist = 0 ]; then

		echo $(date) [$$]: The router has successfully joined into two WANs.
		echo $(date) [$$]: Policy routing service is being started......

		## 部署流量路由策略
		## 输入项：
		##     $1--主执行脚本运行输入参数
		##     全局常量及变量
		## 返回值：无
		lz_deployment_routing_policy "$1"

		## 输出IPTV规则条目数至系统记录
		## 输出当前单项分流规则的条目数至系统记录
		## 输入项：
		##     $1--规则优先级
		## 返回值：
		##     ip_rule_exist--条目总数数，全局变量
		lz_single_ip_rule_output_syslog "$IP_RULE_PRIO_IPTV"

		## 输出当前分流规则每个优先级的条目数至系统记录
		## 输入项：
		##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
		##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
		##     全局变量（ip_rule_exist）
		## 返回值：无
		lz_ip_rule_output_syslog "$IP_RULE_PRIO_TOPEST" "$IP_RULE_PRIO"

		echo $(date) [$$]: Policy routing service has been started successfully.
		echo $(date) [$$]: -------- LZ $LZ_VERSION rules run ok! -------------- >> /tmp/syslog.log

		## SS服务支持
		## 输入项：
		##     全局变量及常量
		## 返回值：无
		lz_ss_support

		echo $(date) [$$]: >> /tmp/syslog.log

	## 单线路
	elif [ -n "$( ip route | grep default | sed -n 1p )" -a $ip_rule_exist = 0 ]; then

		echo $(date) [$$]: The router is connected to only one WAN.
		echo $(date) [$$]: ----------------------------------------
		echo $(date) [$$]: LZ The router is connected to only one WAN. >> /tmp/syslog.log
		echo $(date) [$$]: ----------------------------------------------- >> /tmp/syslog.log

		## 启动单网络的IPTV机顶盒服务
		## 输入项：
		##     $1--主执行脚本运行输入参数
		##     全局常量及变量
		## 返回值：无
		lz_start_single_net_iptv_box_services "$1"

		## 输出IPTV规则条目数至系统记录
		## 输出当前单项分流规则的条目数至系统记录
		## 输入项：
		##     $1--规则优先级
		## 返回值：
		##     ip_rule_exist--条目总数数，全局变量
		lz_single_ip_rule_output_syslog "$IP_RULE_PRIO_IPTV"

		## 输出当前分流规则每个优先级的条目数至系统记录
		## 输入项：
		##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
		##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
		##     全局变量（ip_rule_exist）
		## 返回值：无
		lz_ip_rule_output_syslog "$IP_RULE_PRIO_TOPEST" "$IP_RULE_PRIO"

		## 清除接口脚本文件
		## 输入项：
		##     $1--主执行脚本运行输入参数
		##     全局常量
		## 返回值：无
		lz_clear_interface_scripts "$1"

		if [ "$ip_rule_exist" -gt "0" ]; then
			echo $(date) [$$]: Only IPTV rules is running.
			echo $(date) [$$]: -------- LZ $LZ_VERSION IPTV rules is running. ----- >> /tmp/syslog.log
		else
			echo $(date) [$$]: The policy routing service isn\'t running.
			echo $(date) [$$]: -------- No LZ $LZ_VERSION rules run! -------------- >> /tmp/syslog.log
		fi

		## SS服务支持
		## 输入项：
		##     全局变量及常量
		## 返回值：无
		lz_ss_support

		echo $(date) [$$]: >> /tmp/syslog.log

	## 无外网连接
	else

		echo $(date) [$$]: The router hasn\'t been connected to the two WANs.
		echo $(date) [$$]: LZ The router hasn\'t been connected to the two WANs. >> /tmp/syslog.log

		## 输出IPTV规则条目数至系统记录
		## 输出当前单项分流规则的条目数至系统记录
		## 输入项：
		##     $1--规则优先级
		## 返回值：
		##     ip_rule_exist--条目总数数，全局变量
		lz_single_ip_rule_output_syslog "$IP_RULE_PRIO_IPTV"

		## 输出当前分流规则每个优先级的条目数至系统记录
		## 输入项：
		##     $1--IP_RULE_PRIO_TOPEST--分流规则条目优先级上限数值（例如：IP_RULE_PRIO-40=24960）
		##     $2--IP_RULE_PRIO--既有分流规则条目优先级下限数值（例如：IP_RULE_PRIO=25000）
		##     全局变量（ip_rule_exist）
		## 返回值：无
		lz_ip_rule_output_syslog "$IP_RULE_PRIO_TOPEST" "$IP_RULE_PRIO"

		## 清除接口脚本文件
		## 输入项：
		##     $1--主执行脚本运行输入参数
		##     全局常量
		## 返回值：无
		lz_clear_interface_scripts "$1"

		echo $(date) [$$]: The policy routing service isn\'t running.
		echo $(date) [$$]: -------- No LZ $LZ_VERSION rules run! -------------- >> /tmp/syslog.log
		echo $(date) [$$]: >> /tmp/syslog.log
	fi
}

## 项目文件管理
## 输入项：
##     $1--主执行脚本运行输入参数
##     全局变量及常量
## 返回值：
##     0--成功
##     1--失败
if lz_project_file_management; then
	if [ "$1" = "$FORCED_UNLOCKING" ]; then
		## 解除运行锁函数
		## 输入项：
		##     全局变量及常量
		## 返回值：无
		llz_forced_unlocking() {
			local local_db_unlocked=0
			until [ $( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" ) -le 0 ]
			do
				ip rule show | grep "from 168.168.168.168 to 169.169.169.169" | \
					sed "s/^\(.*\)\:.*$/ip rule del prio \1/g" | \
					awk '{system($0 " > \/dev\/null 2>\&1")}'
				ip route flush cache > /dev/null 2>&1
				local_db_unlocked=1
			done
			if [ $local_db_unlocked != 0 ]; then
				echo $(date) [$$]: The policy routing database was successfully unlocked.
			else
				echo $(date) [$$]: The policy routing database is not locked.
			fi
			rm -rf ${INSTANCE_LIST} > /dev/null 2>&1
			if [ -f "${LOCK_FILE}" ]; then
				rm -rf ${INSTANCE_LIST} > /dev/null 2>&1
				echo $(date) [$$]: Program synchronization lock has been successfully unlocked.
			else
				echo $(date) [$$]: There is no program synchronization lock.
			fi
		}
		llz_forced_unlocking
	elif [ "$1" = "$SHOW_STATUS" ]; then
		## 载入函数功能定义
		${CALL_FUNC_SUBROUTINE}/lz_rule_status.sh
	elif [ "$1" = "$ADDRESS_QUERY" ]; then
		## 载入函数功能定义
		if [ -z "$2" -o -n "$( echo "$2" | grep -Eo '^[ ]*$' )" ]; then
			echo $(date) [$$]: The input parameter \( network address \) can\'t be null.
		else
			${CALL_FUNC_SUBROUTINE}/lz_rule_address_query.sh "$2" "$3"
		fi
	else
		## 极限情况下文件锁偶有锁不住的情况发生，与预期不符。利用系统自带的策略路由数据库做进程间异步模式同步，
		## 虽会降低些效率，代码也不好看，但作为同步过程中的二次防御手段还是很值得。一旦脚本执行过程中意外中断，
		## 可通过手工删除垃圾规则条目或重启路由器清理策略路由库中的垃圾数据
		if [ $( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" ) = 0 ]; then
			## 临时规则，用于进程间同步，防止启动时系统或其它应用同时调用和执行两个以上的lz脚本实例
			## 如与系统中现有规则冲突，可酌情修改；高手们会用更好的方法，请教教我，谢啦！
			ip rule add from 168.168.168.168 to 169.169.169.169

			## 刷新系统cache，使上述命令立即生效
			ip route flush cache > /dev/null 2>&1

			sleep 1s

			if [ $( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" ) -gt 1 ]; then
				ip rule del from 168.168.168.168 to 169.169.169.169 > /dev/null 2>&1

				ip route flush cache > /dev/null 2>&1

				echo $(date) [$$]: LZ Another script instance is running. >> /tmp/syslog.log
				echo $(date) [$$]: -------- LZ $LZ_VERSION rules running! ------------- >> /tmp/syslog.log
				echo $(date) [$$]: >> /tmp/syslog.log

				echo $(date) [$$]: The policy routing service is being started by another instance.
				echo $(date) [$$]: ----------------------------------------
				echo $(date) [$$]: LZ $LZ_VERSION script commands executed!
				echo $(date) [$$]:

				## 实例退出处理
				## 输入项：
				##     全局变量及常量
				## 返回值：无
				lz_instance_exit

				## 解除文件同步锁
				flock -u "$LOCK_FILE_ID" > /dev/null 2>&1
				exit
			fi

			## 主执行脚本
			__lz_main "$1"

			## 删除进程间同步用临时规则，要与脚本开始时的添加命令一致
			until [ $( ip rule show | grep -c "from 168.168.168.168 to 169.169.169.169" ) -le 0 ]
			do
				ip rule show | grep "from 168.168.168.168 to 169.169.169.169" | \
					sed -e "s/^.*\:/ip rule del /g" | \
					awk '{system($0 " > \/dev\/null 2>\&1")}'
				ip route flush cache > /dev/null 2>&1
			done

			## 刷新系统cache，使上述命令立即生效
			ip route flush cache > /dev/null 2>&1

		else

			echo $(date) [$$]: The policy routing service is being started by another instance.
			echo $(date) [$$]: LZ Another script instance is running. >> /tmp/syslog.log
			echo $(date) [$$]: -------- LZ $LZ_VERSION rules running! ------------- >> /tmp/syslog.log
			echo $(date) [$$]: >> /tmp/syslog.log
		fi
	fi
fi

[ "$1" != "$ADDRESS_QUERY" ] && echo $(date) [$$]: ----------------------------------------
echo $(date) [$$]: LZ $LZ_VERSION script commands executed!
echo $(date) [$$]:

[ "$1" != "$FORCED_UNLOCKING" ] && {
	lz_instance_exit
	## 解除文件同步锁
	flock -u "$LOCK_FILE_ID" > /dev/null 2>&1
}

#END
