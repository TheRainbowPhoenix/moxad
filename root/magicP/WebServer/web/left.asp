<html>
<HTML>
<HEAD>
	<% net_Web_file_include(); %>
	<TITLE>Untitled	Document</TITLE>
	<STYLE type="TEXT/CSS">
		A:link {	COLOR:#414042; TEXT-DECORATION:	none	}
		A:visited	 {	color:#414042; text-decoration:	none }
		A:hover	{	COLOR:#FF0000; TEXT-DECORATION:	none }
		body {background-attachment: fixed;
			  background-image: url("image/side.jpg");
			  background-repeat: repeat-y;
			  margin: 0;
			  background-position: right;
			  font-family: Arial;
			}
		table {
				border-collapse: collapse;
			}
	</STYLE>
</HEAD>
<BODY style="font-family: Verdana;	font-size: 10pt; overflow-y:auto;overflow-x:hidden;">
<SCRIPT language=JavaScript src="d4-43.js"></SCRIPT>
<table width="100%">
	<tr height="40">
		<td></td>
	</tr>
	<tr>
		<td>
			<SCRIPT	language=JavaScript>
			var NetworkMode = <% net_Web_GetMode_WriteValue(); %>;
			var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
			var ModelVLAN = <% net_Web_GetModel_VLAN_WriteValue(); %>;
			var ModelDVMRP = <% net_Web_GetModel_DVMRP_WriteValue(); %>;
			var No_WAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
			var NoMAC_PORT = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %>;
			var SYS_PORTS = <% net_Web_Get_SYS_PORTS(); %>	
			var SWITCH_ROUTER=((parseInt(SYS_PORTS) > parseInt(NoMAC_PORT))&& (No_WAN > 0));
			var ModelRADIUS = <% net_Web_GetModel_RADIUS_WriteValue(); %>;
			var ModeVPN = <% net_Web_GetMode_VPN_WriteValue(); %>;
			var ModeL2TP = <% net_Web_GetMode_L2TP_WriteValue(); %>;
            checkCookie();
            var AuthUser = Get_Auth();
			
foldersTree =MainFld("Home", "overview.asp")
    
	aux1 = insFld(foldersTree, gFld("Quick Setting Profiles",""))
		//insDoc(aux1, gLnk(0, "WAN Routing Quick Setting", "wan_routing_quick_setting.asp"))
		//insDoc(aux1, gLnk(0, "Bridge Routing Quick Setting", "bridge_quick_setting.asp"))
		insDoc(aux1, gLnk(0, "Interface Type Quick Setting", "wizard.asp"))

	aux1 = insFld(foldersTree, gFld("System",""))
		insDoc(aux1, gLnk(0, "Fast Bootup Settings",      "fast_bootup_setting.asp"))
		insDoc(aux1, gLnk(0, "System Information", 	"system_setting.asp"))
        if(AuthUser != "user"){
		    insDoc(aux1, gLnk(0, "User Account", 	"user_account.asp"))
        }
		insDoc(aux1, gLnk(0, "Password Login Policy", 	"password_login_policy.asp"))
		insDoc(aux1, gLnk(0, "Date and Time", 	"time_setting.asp"))
			
		aux2 = insFld(aux1, gFld("Warning Notification",""))			
			insDoc(aux2, gLnk(0, "System Event Settings", 	"system_event_type.asp"))
			insDoc(aux2, gLnk(0, "Port Event Settings", 	"port_event_type.asp"))
			insDoc(aux2, gLnk(0, "Event Log Settings", 	"eventlog_setting.asp"))
			insDoc(aux2, gLnk(0, "Email Setup", 	"emalert.asp"))
			insDoc(aux2, gLnk(0, "Syslog Server Settings", 	"syslog.asp"))
			insDoc(aux2, gLnk(0, "Relay Warning Status", 	"relay_alarm_list_show.asp"))

		insDoc(aux1, gLnk(0, "Setting Check", 	"check_confirm.asp"))
		aux2 = insFld(aux1, gFld("System File Update",""))
			insDoc(aux2, gLnk(0, "Remote TFTP",	"tftp_setting.asp"))
			insDoc(aux2, gLnk(0, "Local Import/Export",	"upgrade.asp"))
            insDoc(aux2, gLnk(0, "ABC_02 Import/Export", "abc_upgrade.asp"))
		insDoc(aux1, gLnk(0, "Restart", 		"restart_setting.asp"))
		insDoc(aux1, gLnk(0, "Factory Default", 	"factory_default_setting.asp"))	

	aux1 = insFld(foldersTree, gFld("Layer 2 Functions",""))
		aux2 = insFld(aux1, gFld("Port",""))
			insDoc(aux2, gLnk(0, "Port Settings", "port_setting.asp"))		
			insDoc(aux2, gLnk(0, "Port status", "port_status.asp"))		
			aux3 = insFld(aux2, gFld("Link Aggregation",""))
				insDoc(aux3, gLnk(0, "Port Trunking", "trunk_setting.asp"))
				insDoc(aux3, gLnk(0, "Trunking status", "trunk_table.asp"))
			insDoc(aux2, gLnk(0, "Port Mirror", 	"mirror_port_setting.asp"))
		insDoc(aux1, gLnk(0, "Redundant Protocols", 	"con_redundancy.asp"))

		aux2 = insFld(aux1, gFld("Virtual LAN",""))
			insDoc(aux2, gLnk(0, "VLAN Settings", "tagbase_vlan_hybrid_bridge_group_setting.asp"))
			insDoc(aux2, gLnk(0, "VLAN Table", "vlan_table.asp"))

		aux2 = insFld(aux1, gFld("Multicast",""))
			aux3 = insFld(aux2, gFld("IGMP Snooping"))
				//insDoc(aux3, gLnk(0, "IGMP Snooping Settings", "igmpsnoopv3_setting.asp"))
				insDoc(aux3, gLnk(0, "IGMP Snooping Settings", "igmpsnoopv3_setting_bridge.asp"))
				insDoc(aux3, gLnk(0, "IGMP Table", "igmpsnoopv3_igmp.asp"))
				insDoc(aux3, gLnk(0, "Stream Table", "igmpsnoopv3_stream.asp"))
			insDoc(aux2, gLnk(0, "Static Multicast MAC", "smcast_mac_setting.asp"))

		aux2 = insFld(aux1, gFld("QoS and Rate Control",""))
			insDoc(aux2, gLnk(0, "QoS Classification", "qos_classification.asp"))	
			insDoc(aux2, gLnk(0, "CoS Mapping", "cos_mapping.asp"))
			insDoc(aux2, gLnk(0, "ToS/DiffServ Mapping", "tos_mapping.asp"))
			insDoc(aux2, gLnk(0, "Rate Limiting", "rate_limit.asp"))
		insDoc(aux1, gLnk(0, "MAC Address Table", "mac_table.asp?show_list=0&show_page=0&show_refresh=0"))

	aux1 = insFld(foldersTree, gFld("Network",""))
		aux2 = insFld(aux1, gFld("Interface",""))
			insDoc(aux2, gLnk(0, "MTU Configuration", 		"mtu_adjust.asp"))
			insDoc(aux2, gLnk(0, "WAN", 	"wan_bridge.asp"))
			insDoc(aux2, gLnk(0, "LAN", 	"lan_bridge.asp"))
		    insDoc(aux2, gLnk(0, "Bridge", 	"br.asp"))

	aux1 = insFld(foldersTree, gFld("Network Service",""))
		aux2 = insFld(aux1, gFld("DHCP",""))
			insDoc(aux2, gLnk(0, "Global Setting", "dhcpd_server_mode.asp"))
			insDoc(aux2, gLnk(0, "DHCP Server", "dhcpd_dip.asp"))
			insDoc(aux2, gLnk(0, "Static DHCP", "dhcpd_sip.asp"))
			//insDoc(aux2, gLnk(0, "IP-Port Binding", "dhcpd_pip.asp"))
		    insDoc(aux2, gLnk(0, "IP-Port Binding", "dhcpd_pip_bridge.asp"))
            
			insDoc(aux2, gLnk(0, "Client List", "dhcpd_leases_table.asp?show_page=0"))
		aux2 = insFld(aux1, gFld("SNMP",""))
			insDoc(aux2, gLnk(0, "SNMP Setup", "snmp.asp"))
			//insDoc(aux2, gLnk(0, "SNMP Trap Type", "snmp_trap_setting.asp"))
		insDoc(aux1, gLnk(0, "Dynamic DNS", "dydns.asp"))
		if(No_WAN > 1){
			insDoc(aux1, gLnk(0, "WAN Backup", 	"alive.asp"))
		}
	
	aux1 = insFld(foldersTree, gFld("Routing",""))
		aux2 = insFld(aux1, gFld("Unicast Route"))
			insDoc(aux2, gLnk(0, "Static Route", 	"route_setting.asp"))
			insDoc(aux2, gLnk(0, "RIP", 	"rip.asp"))
			aux3 = insFld(aux2, gFld("OSPF"))
				insDoc(aux3, gLnk(0, "Global Settings", "ospf_global_setting.asp"))
				insDoc(aux3, gLnk(0, "Area Settings", "ospf_area_setting.asp"))
				insDoc(aux3, gLnk(0, "Interface Settings", "ospf_interface_setting.asp"))				
				insDoc(aux3, gLnk(0, "Virtual Link Settings", "ospf_vlink_setting.asp"))
				insDoc(aux3, gLnk(0, "Area Aggregation Settings", "ospf_area_aggre_setting.asp"))
				insDoc(aux3, gLnk(0, "Neighbor Table", "ospf_nbr_show.asp"))
				insDoc(aux3, gLnk(0, "LSA Table", "ospf_db_show.asp"))
			insDoc(aux2, gLnk(0, "Routing Table", 	"routing_table.asp?r_type=A"))

		aux2 = insFld(aux1, gFld("Multicast Route"))
			insDoc(aux2, gLnk(0, "Global Setting", 	"mroute_mode.asp"))
			insDoc(aux2, gLnk(0, "Static Multicast", "smcast_setting.asp"))
			aux3 = insFld(aux2, gFld("DVMRP")) 			
				insDoc(aux3, gLnk(0, "Setting", "dvmrp.asp")) 
				insDoc(aux3, gLnk(0, "DVMRP Routing Table", "dvmrp_routing_table.asp"))
				insDoc(aux3, gLnk(0, "DVMRP Neighbors Table", "dvmrp_neighbors_list.asp"))
			aux3 = insFld(aux2, gFld("PIM-SM"))
				insDoc(aux3, gLnk(0, "Setting", "pimsm_setting.asp"))
				insDoc(aux3, gLnk(0, "RP Setting", 	"pimsm_rp_setting.asp"))
				insDoc(aux3, gLnk(0, "PIM-SSM Setting", "pimsm_ssm_setting.asp"))
				insDoc(aux3, gLnk(0, "PIM-SM RP Set Table", "pimsm_rp_show.asp"))
				insDoc(aux3, gLnk(0, "Neighbors Tables", "pimsm_neighbors_show.asp"))
				insDoc(aux3, gLnk(0, "PIM Multicast Routing Table", "pimsm_routing_table.asp"))				
			insDoc(aux2, gLnk(0, "Multicast Forwarding Table", "mcroute_table.asp"))
		insDoc(aux1, gLnk(0, "Broadcast Forwarding", "bcast_forward.asp"))
		if(NetworkMode == 0){
			aux2 = insFld(aux1, gFld("VRRP"))
			insDoc(aux2, gLnk(0, "Global Setting", 	"vrrp_global.asp"))	
			insDoc(aux2, gLnk(0, "VRRP Setting", 	"vrrp.asp"))
		}
			
	aux1 = insFld(foldersTree, gFld("NAT",""))
		insDoc(aux1, gLnk(0, "NAT Setting", "ipt_nat.asp"))
			
	aux1 = insFld(foldersTree, gFld("Firewall",""))
		insDoc(aux1, gLnk(0, "Policy Overview", "filter.asp"))
		insDoc(aux1, gLnk(0, "Layer 2 Policy", 	"layer2_filter.asp"))
        //insDoc(aux1, gLnk(0, "Policy Setup", 	"ipt_filter.asp"))
   		insDoc(aux1, gLnk(0, "Layer 3 Policy", 	"ipt_filter_bridge.asp"))
    
		insDoc(aux1, gLnk(0, "Modbus Policy", 	"modbus_bridge.asp"))
		insDoc(aux1, gLnk(0, "DoS Defense", 	"ipt_dos.asp"))
	if(ModeVPN || !SWITCH_ROUTER){	
		aux1 = insFld(foldersTree, gFld("VPN",""))			
			aux2 = insFld(aux1, gFld("IPSec"))		
			insDoc(aux2, gLnk(0, "Global Setting", "vpn_global_setting.asp"))
			insDoc(aux2, gLnk(0, "IPSec Setting", "ipsec_setting.asp"))
			insDoc(aux2, gLnk(0, "IPSec Status", "ipsec_status.asp"))
			if(ModeL2TP){
				insDoc(aux1, gLnk(0, "L2TP Server", "l2tp_setting_multi_account.asp"))				
			}else{
				insDoc(aux1, gLnk(0, "L2TP Server", "l2tp_setting.asp"))					
			}
			aux4 = insFld(aux1, gFld("OpenVPN"))
			aux5 = insFld(aux4, gFld("OpenVPN Server"))
			insDoc(aux5, gLnk(0, "Server Setting", "openvpn_server.asp"))			
			insDoc(aux5, gLnk(0, "User Management", "openvpn_user.asp"))
			insDoc(aux5, gLnk(0, "Server to User Config", "openvpn_server_usercfg.asp"))
			insDoc(aux5, gLnk(0, "OpenVPN Server Status", "openvpn_status_server.asp"))
			aux6 = insFld(aux4, gFld("OpenVPN Client"))
			insDoc(aux6, gLnk(0, "Client Setting", "openvpn_client.asp"))
			insDoc(aux6, gLnk(0, "OpenVPN Client Status", "openvpn_status_client.asp"))
	}


	aux1 = insFld(foldersTree, gFld("Certificate Management",""))		
		insDoc(aux1, gLnk(0, "Local Certificate", "cer_mgmt.asp"))
		insDoc(aux1, gLnk(0, "Trusted CA Certificate", "ca_upload.asp"))
		aux2 = insFld(aux1, gFld("Certificate Signing Request"))
		insDoc(aux2, gLnk(0, "Key Pair Generate", "rsa_key_generate.asp"))
		insDoc(aux2, gLnk(0, "CSR Generate", "csr.asp"))
		aux2 = insFld(aux1, gFld("CA Server"))
		insDoc(aux2, gLnk(0, "Certificate Create", "cer_generate.asp"))	
		
	aux1 = insFld(foldersTree, gFld("Security",""))
		insDoc(aux1, gLnk(0, "User Interface Management", 	"ui_mgmt_setting.asp"))
		insDoc(aux1, gLnk(0, "Auth Certificate", "auth_cert.asp"))
		insDoc(aux1, gLnk(0, "Trusted Access", 	"accessible_setting.asp"))
		if(ModelRADIUS == RETURN_TRUE){
			insDoc(aux1, gLnk(0, "RADIUS", 	"radius.asp"))
		}
		insDoc(aux1, gLnk(0, "Security Notification", 	"security_notification_v1.asp"))
		
	aux1 = insFld(foldersTree, gFld("Diagnosis",""))	    
		insDoc(aux1, gLnk(0, "Ping", 	"ping.asp"))
		insDoc(aux1, gLnk(0, "LLDP", 	"lldp_setting.asp"))
		insDoc(aux1, gLnk(0, "ARP Table", 	"arp_table.asp"))

	aux1 = insFld(foldersTree, gFld("Monitor",""))
		insDoc(aux1, gLnk(0, "Statistics", "monitoring_statics/monitoringStatics.asp"))
		insDoc(aux1, gLnk(0, "Event Log", 	"show_log.asp?show_page=1&show_range=0&show_level=7&show_category=0"))
		insDoc(aux1, gLnk(0, "Connection Status","con_status.asp"))
		insDoc(aux1, gLnk(0, "Fiber Check","ddm_enhance.asp"))
		
	insDoc(foldersTree, gLnk(0, "Logout", "logout_actively.asp"))

/*
		insDoc(aux1, gLnk(0, "SettingCheck", 	"check_confirm.asp"))
*/
initializeDocument()
			</SCRIPT>
			<table width="210">
				<tr>
					<td>
						<div align="center">
							<img src="image/goahead.gif" border="0" height="30" width="155">
						</div>
						<div align="center"><font size="1">
							Best viewed with IE 7 above at resolution 1024 x 768
						</font></div>
					</td>
				</tr>
			</table>
			<table width="210" height="120">
				<tr><td> </td></tr>
				<tr><td> </td></tr>
				<tr><td> </td></tr>
				<tr><td> </td></tr>
				<tr><td> </td></tr>
				<tr><td> </td></tr>
				<tr><td> </td></tr>
			</table>
		</td>
	</tr>
</table>
</BODY>
</HTML>
