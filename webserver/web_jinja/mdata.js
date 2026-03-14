function hilight(hi, obj)
{
	if (hi) {
		obj.style.color = "#F0F000";
		obj.style.backgroundColor = "#336699";
	} else {
		obj.style.color = '';
		obj.style.backgroundColor = '';
	}
}

var TREE_FORMAT = [
//0. true if only one branch can be opened at same time
	true,
//1. default style for all nodes
	"class=MenuL",
//2. table styles for each level's Table (border size, border color, background color...)
	["class=MenuH border=0 cellspacing=0 cellpadding=0",
	 "class=MenuL border=1"],
//3. tr styles for each level's List (default style will be used for undefined levels)
	["class=MenuH",
	 "class=MenuL"],
//4. td styles for each level's List (default style will be used for undefined levels)
	["class=MenuH",
	 "class=MenuL"],
//5. images for listed items.
	//"images/open_folder.jpg"
	"images/open_folder.gif"
];

var TREE_NODES = [
	[Basic_Configuration, null, null,
		//['MAX WAN & Wizard', 'maxwan.htm', 'main'],
		//[MAX_WAN, 'maxwan.htm', 'main'],
		[Primary_Setup, 'primary.htm', 'main'],
		[LAN_DHCP, 'lan.htm', 'main']
],	[Advanced_Port, null, null,
		[Port_Options, 'portop.htm', 'main'],
		[Load_Balancing, 'loading.htm', 'main'],
		[Advanced_PPPoE, 'pppoe.htm', 'main'],
		[Advanced_PPTP,  'pptp.htm', 'main']
],	[Advanced_Configuration, null, null,
		[Host_IP, 'hostip.htm', 'main'],
		[Routing_, 'sroute.htm', 'main'],
		[Virtual_Server, 'cvserver.htm', 'main'],
		[Special_Application, 'spapp.htm', 'main'],
		[Dynamic_DNS, 'dydns.htm', 'main'],
		[Multi_DMZ, 'dmz.htm', 'main'],
		[UPnP_Setup, 'upnp.htm', 'main'],
		[NAT_Setup, 'nat.htm', 'main'],
		[Advanced_Feature, 'adv.htm', 'main']
],	[Security_Management, null, null,
		[URL_FIlter, 'url.htm', 'main'],
		[Access_Filter, 'acfilter.htm', 'main'],
		[Session_Limit, 'slim.htm', 'main'],
		[SysFilter_Exception, 'sfilter.htm', 'main']
// For VPN Devices
],	[VPN_Configuration, null, null,
		[IKE_Global_Setup,'ipsec.htm','main'],
		[IPSec_Policy_Setup,'vpn.htm','main'],
		//['Mesh Group','vpnmeshgrp.htm','main'],
		[Mesh_Group,'vpnmeshgrporg.htm','main'],
		[VPN_Logs, 'ipseclog.htm', 'main']
],	[QoS_Configuration, null, null,
		[QoS_Setup, 'qosmain.htm', 'main'],
		[QoS_Policy, 'qpolicy.htm', 'main']
// For Inbound Load Balance
//],	['', null, null,
],	[DNS_Configuration, null, null,
		[DNS_Setup, 'dnset.htm', 'main'],
		[Map_Host_URL, 'mapurl.htm', 'main']
		//[DNS_Setup, 'dnset.htm', 'main'],
		//['Map_Host_URL', 'dnsrec.htm', 'main']
],	[Management_Assistant, null, null,
		[Admin__Setup, 'admin.htm', 'main'],
		[Email_Alert, 'emalert.htm', 'main'],
		[SNMP_, 'snmp.htm', 'main'],
		[Syslog_, 'syslog.htm', 'main'],
		[Upgrade_Firmware, 'upgrade.htm', 'main']
],	[Network_Info, null, null,
		[System_Status, 'netstat.htm', 'main'],
		[WAN_Status, 'wanstat.htm', 'main'],
// For Link to Company WebSite
		//[Exit_, 'http://www.leadfly.com', '_top']
]
];

function menu(tit) { }
