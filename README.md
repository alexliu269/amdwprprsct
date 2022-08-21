# amdwprprsct
Asuswrt-Merlin dual WAN port router policy routing service configuration tool

华硕改版固件路由器外网双线路接入策略路由服务配置工具

<strong>v3.7.1</strong>

本软件不是为实现网络带速叠加应用而设计，也不专注于实现路由器多个出口链路网络或带宽的聚合，而是用于在双线路接入路由器的不同网络出口之间精准控制网络访问经由路径，可有效解决路由器双线路接入时不能正常登录和访问网站，以及网络访问卡慢、断流、不稳定等问题，提高路由器使用的稳定性、流畅性和带宽资源利用率，挖掘和发挥设备潜能和剩余价值，减少设备重复采购，改善电磁环境，提高生活质量。避免因WiFi信号太多，经常为切换使用SSID而纠结，预防选择恐惧症。

<strong>主要功能</strong>

<strong>一、基础功能</strong>
<ul><li>可按如下11个网络运营商IPv4目标网段的划分分配路由器流量出口：</li>
<ul><li>国外运营商网段</li>
<li>中国电信网段</li>
<li>中国联通/网通网段</li>
<li>中国移动网段</li>
<li>中国铁通网段</li>
<li>中国教育网网段</li>
<li>长城宽带/鹏博士网段</li>
<li>中国大陆其他运营商网段</li>
<li>香港地区运营商网段</li>
<li>澳门地区运营商网段</li>
<li>台湾地区运营商网段</li></ul>
<li>可任意设置上述某个待访问网络运营商目标网段的数据流量使用指定的路由器出口。</li>
<li>可采用均分出口或反向均分出口方式分配流量出口，将待访问运营商目标网段条目平均划分为两部分，前一部分匹配路由器第一WAN口，后一部分匹配第二WAN口，或者是反向匹配流量出口。</li>
<li>可任意设置上述某个待访问网络运营商目标网段的数据流量由系统采用负载均衡技术自动分配流量出口。</li>
<li>定时自动更新ISP网络运营商CIDR网段数据。</li></ul>

<strong>二、高级功能</strong>
<ul><li>可自定义目标网址/网段流量出口和流量出口方式。</li>
<li>可按照优先级自定义本地网络中的客户端及源网址/网段流量出口。</li>
<li>可按照优先级自定义源网址/网段至目标网址/网段流量出口。</li>
<li>可设置本地客户端网址/网段分流黑名单，指定某个客户端访问外网时不按照分流规则输出流量，由系统采用负载均衡技术自动分配流量出口。</li>
<li>端口分流。</li>
<li>和谐上网Fancyss插件服务支持。</li>
<li>支持路由器内置的虚拟专网服务器，可设置远程客户端通过路由器访问外网时的路由器线路出口。</li>
<li>可设置外网访问路由器主机WAN入口。</li></ul>

<strong>三、运行功能</strong>
<ul><li>应用模式：可选择动态分流模式、静态分流模式两种应用模式中的一种。</li>
<li>可设置是否启用路由表缓存功能。</li>
<li>可设置自动清理路由表缓存功能。</li></ul>

<strong>四、IPTV功能</strong>
<ul><li>IPTV机顶盒播放源接入口及IGMP组播数据转内网传输代理设置功能。</li>
<li>IGMP组播管理协议版本号设置功能。</li>
<li>hnd平台机型核心网桥组播控制方式设置功能。</li>
<li>IPTV机顶盒访问IPTV线路方式设置功能，支持直连IPTV线路、按服务地址访问两种方式。</li>
<li>IPTV机顶盒内网IP地址设置功能。</li>
<li>IPTV网络服务IP网址/网段列表数据文件设置功能。</li>
<li>路由器WAN口IPTV连接方式设置功能，支持PPPoE、静态IP、DHCP或IPoE的连接方式。</li>
<li>UDPXY组播数据转HTTP流传输代理设置功能，可根据需要设置UDPXY端口号、缓冲区大小、内网客户端数量。</li></ul>

<strong>五、外置脚本功能</strong>
<ul><li>外置用户自定义配置脚本设置功能。</li>
<li>外置用户自定义双线路脚本设置功能。</li>
<li>外置用户自定义清理资源脚本设置功能。</li></ul>

<strong>六、相关资料</strong>
<ul><li>华硕改版固件路由器双线路双拨策略分流方案教程（入门必读）</li>
<li>LZ路由器双线路双拨策略分流脚本小白安装教程（入门必读）</li>
<li>IPTV之路由器单双线接入方式的超简单实现教程</li>
<li>双线路双拨路由器IPTV设置小白教程</li>
<li>北京联通IPTV机顶盒如何通过无线连接路由器实现收看电视？</li>
<li>华硕arm平台路由器单臂路由终极解决方案教程</li>
<li>华硕hnd_axhnd_axhnd.675x平台路由器单臂路由解决方案及脚本教程</li></ul>

<strong>安装及使用方法</strong>
<ul>华硕改版固件路由器双线路双拨策略分流方案
https://www.koolcenter.com/posts/85
(出处: KoolCenter)</ul>
