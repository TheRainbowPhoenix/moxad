<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(Quick_Setting)</script></title>
<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
var VALID_PAGE_NUM = 7;
var hw_version = <% net_Web_GetVERSION_HW_WriteValue(); %>;
if (debug) {
	var devimage = {
		     dev:"image/EDR-810.gif"
            ,f_brg:"image/Fiber-BR.png" ,c_brg:"image/Copper-BR.png" ,c_brgR:"image/Copper-BR-right.png"
		    ,f_lan:"image/Fiber-LAN.png",c_lan:"image/Copper-LAN.png",c_lanR:"image/Copper-LAN-right.png"
            ,f_wan:"image/Fiber-WAN.png",c_wan:"image/Copper-WAN.png",c_wanR:"image/Copper-WAN-right.png"
	};

	if(hw_version==2){
		devimage["dev"] = "image/EDR-810_HW2.png";
	}

	var devpos = {//data can be changed depend on situation
		 dev:{ top:'0', left:'0',sizex:'162', sizey:'407'}
		,port0:{ top:'329', left:'42',sizex:'25', sizey:'32'}
		,port1:{ top:'329', left:'83',sizex:'25', sizey:'32'}  
		,port2:{ top:'290', left:'42',sizex:'25', sizey:'32'}  
		,port3:{ top:'290', left:'83',sizex:'25', sizey:'32'}  
		,port4:{ top:'252', left:'42',sizex:'25', sizey:'32'}  
		,port5:{ top:'252', left:'83',sizex:'25', sizey:'32'}  
		,port6:{ top:'213', left:'42',sizex:'25', sizey:'32'}  
		,port7:{ top:'213', left:'83',sizex:'25', sizey:'32'}  
		,port8:{ top:'154', left:'36',sizex:'29', sizey:'39'}  
		,port9:{ top:'102', left:'36',sizex:'29', sizey:'39'}   
	};

}else{
	
}
<%net_Web_show_value('SRV_BRG');%>
<%net_Web_show_value('SRV_VLAN');%>
<%net_Web_show_value('SRV_VPLAN');%>
<%net_Web_show_value('SRV_IP_CLIENT');%>
<%net_Web_show_value('SRV_VCONF');%>
<%net_Web_show_value('SRV_DHCP');%>
var wdata = [ <% net_Web_IPT_NAT_WriteValue(); %> ];
var port_desc=[<%net_webPortDesc();%>];
var SYSPORTS = <% net_Web_Get_SYS_PORTS(); %>;	
var NoWAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
var NoMAC_PORT = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %>;
var SWITCH_ROUTER=(parseInt((NoWAN+1)) > parseInt(NoMAC_PORT));
var SRV_DHCP_DEFAULT={dhcp_en:'1',dhcp_lease:'60',dhcp_dns1:'0.0.0.0',dhcp_dns2:'0.0.0.0',dhcp_ip1:'192.168.127.1',dhcp_ip2:'192.168.127.252',dhcp_netmask:'255.255.255.0',dhcp_gateway:'0.0.0.0',dhcp_ntp:'0.0.0.0'};
var SRV_DHCP_BRG={dhcp_en:'1',dhcp_lease:'60',dhcp_dns1:'0.0.0.0',dhcp_dns2:'0.0.0.0',dhcp_ip1:'192.168.126.1',dhcp_ip2:'192.168.126.252',dhcp_netmask:'255.255.255.0',dhcp_gateway:'0.0.0.0',dhcp_ntp:'0.0.0.0'};

var NAT_DEFAULT = { srv:2, stat:'1', ifs:'48', prot:'', ip1:'', ip2:'', ip3:'192.168.127.1', ip4:'192.168.127.252', ip5:'', ip6:'', ip7:'', ip8:'', ip9:'', ip10:'', port1:'', port2:'', otoifid:'4096', vrrp_binding:'', name:'' };
var NAT_BRG = { srv:2, idx:0, stat:'1', ifs:'48', prot:'', ip1:'', ip2:'', ip3:'192.168.126.1', ip4:'192.168.126.252', ip5:'', ip6:'', ip7:'', ip8:'', ip9:'', ip10:'', port1:'', port2:'', otoifid:'' };


var wtyp0 = [
	{ value:0, text:Static_IP },	{ value:1, text:Dynamic_IP },
	{ value:4, text:PPPoE_ }
];
var selwtyp = { type:'select', id:'wtyp', name:'proto', size:1, onChange:'fnChgLType(this.value)', option:wtyp0 };
var vobjs = {};
var valid_page=new Array();


var myForm;

function fnEnPPTP(pptpen) {
	with (myForm) {
		psrv.disabled=!pptpen;
		pusr.disabled=!pptpen;
		ppwd.disabled=!pptpen;
	}
}
function fnChgLType(val) {
	with (document) {
		vobjs.trst0.display = (val==0) ? '' : 'none' ;
		vobjs.trst1.display = (val==0) ? '' : 'none' ;
		vobjs.trst2.display = (val==0) ? '' : 'none' ;
		vobjs.trst3.display = (val==0) ? '' : 'none' ;		
		vobjs.TDpen.disabled = val==4 ;
		vobjs.TDpphd.innerHTML = (val==4 ? PPPoE_ : PPTP_ ) +' '+ Dialup_;

		vobjs.trpp0.display = (val==4) ? 'none' : '' ;
		vobjs.trpp1.display = (val==4) ? 'none' : '' ;
		vobjs.troe0.display = (val==4) ? '' : 'none' ;
		vobjs.troe1.display = (val==4) ? '' : 'none' ;
	}

	fnEnPPTP(myForm.ppen.checked);
}
var mode_index=0;
var dhcp_valid_range_low="";
var dhcp_valid_range_high="";
var lan_valid_range_low="";
var lan_valid_range_high="";
var dhcp_valid_range_low_brg="";
var dhcp_valid_range_high_brg="";
var brg_valid_range_low="";
var brg_valid_range_high="";

var button_disable = 0 ;

function check_input_fcormat(){
	var token, i;
	if(!IpAddrNotMcastIsOK(document.getElementsByName("lanip")[0], IP_Address) || !NetMaskIsOK(document.getElementsByName("lanmask")[0], Subnet_Mask))
		return 1;

	token = document.getElementsByName("lanmask")[0].value.split('.');
	for(i=0;i<3;i++){
		if(token[i]!="255"){
			alert(Subnet_Mask+" must less than C class");
				return 1;
		}
	}
	
	
	if(!IpAddrNotMcastIsOK(document.getElementsByName("brgip")[0], IP_Address) || !NetMaskIsOK(document.getElementsByName("brgmask")[0], Subnet_Mask))
		return 1;
	if(myForm.wtyp.value==4){
		if(isNull(myForm.eusr.value) ||	isNull(myForm.epwd.value)){
			alert(PPPoE_Dialup + " User Name or Password Null")
			return 1;
		}else{
			if( isSymbol(myForm.eusr, PPPoE_Dialup + 'User Name')
			 || isSymbol(myForm.epwd, PPPoE_Dialup + 'Password')
			 || isSymbol(myForm.ehnm, PPPoE_Dialup + 'Host Name')) {
				return 1;
			}
		}
	} else {
		if(myForm.wtyp.value == 0) {
			if(!IpAddrNotMcastIsOK(myForm.stip,IP_Address) || !NetMaskIsOK(myForm.stmk, "Subnet_Mask")) {
				return 1;
			}
		}
		if(myForm.ppen.checked) {
			if(isNull(myForm.pusr.value) ||	isNull(myForm.ppwd.value)) {
				alert(PPTP_Connection + " User Name or Password is Null");
				return 1;
			} else {
				if( isSymbol(myForm.pusr, PPTP_Connection + 'User Name')
			 	|| isSymbol(myForm.ppwd, PPTP_Connection + 'Password')) {
					return 1;
				}
			}
			if(!isNull(myForm.psrv.value))
				if(!IsIpOK(myForm.psrv,PPTP_Connection + IP_Address))
					return 1;
		}
	}
	return 0;
} 




function save_valid_page(){
    var i,index;
    var port_status = 0;
    index = 1;
    valid_page[0] = 0;
    for(i=0; i<SYSPORTS; i++){
		if(port_type[i] == devimage["f_lan"] || port_type[i] == devimage["c_lan"] || port_type[i] == devimage["c_lanR"]){
            port_status = port_status | 0x01;
        }
        if(port_type[i] == devimage["f_brg"] || port_type[i] == devimage["c_brg"] || port_type[i] == devimage["c_brgR"]){
            port_status = port_status | 0x02;
        }
        if(port_type[i] == devimage["f_wan"] || port_type[i] == devimage["c_wan"] || port_type[i] == devimage["c_wanR"]){
            port_status = port_status | 0x04;
        }
    }
    
    if(port_status & 0x01){
        valid_page[index] = 1;
        index++;
    }
    if(port_status & 0x02){
        valid_page[index] = 2;
        index++
    }
    if(port_status & 0x04){
        valid_page[index] = 3;
        index++
    }

    valid_page[index] = 4;
    index++;
    valid_page[index] = 5;
    index++;
    valid_page[index] = 6;
    
    return port_status;
}

function show_nav_bar(index){
    var i;
    for(i=0 ;i<4 ;i++){
        if(i == index){
     	    document.getElementById("bar"+i).className="r5";
        }else{
      	    document.getElementById("bar"+i).className="r1";
        }
    }
    return;
}


function fnChgLMode(mode_array_index) {
	var i;
	if(check_input_fcormat()){
		return;
	}
    var port_status=0;
    port_status = save_valid_page();
    mode = valid_page[mode_array_index];

	//mode_index = mode;
    mode_index = mode_array_index;
	if(mode==0){
		document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="none";
        show_nav_bar(0);
	}else if(mode==1){
		document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="";
        show_nav_bar(1);
	}else if(mode==2){
		document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="";
        show_nav_bar(1);
    }else if(mode==3){
        document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="";
        show_nav_bar(1);
    }else if(mode==4){
		document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="";
    
        var lanip = document.getElementsByName("lanip")[0].value;
		var lanmask=document.getElementsByName("lanmask")[0].value;
		var lannet=fnIp2Net(lanip,lanmask);

		var brgip = document.getElementsByName("brgip")[0].value;
		var brgmask=document.getElementsByName("brgmask")[0].value;
		var brgnet=fnIp2Net(brgip,brgmask);

		lan_valid_range_check(lannet, lanip, lanmask);
		brg_valid_range_check(brgnet, brgip, brgmask);

		document.getElementById("dhcpip1").value = dhcp_valid_range_low;
		document.getElementById("dhcpip2").value = dhcp_valid_range_high;
		document.getElementById("natip1").value = lan_valid_range_low;
		document.getElementById("natip2").value = lan_valid_range_high;
		
        document.getElementById("dhcpip3").value = dhcp_valid_range_low_brg;
		document.getElementById("dhcpip4").value = dhcp_valid_range_high_brg;
		document.getElementById("natip3").value = brg_valid_range_low;
		document.getElementById("natip4").value = brg_valid_range_high;

        document.getElementById("lan_table").style.display = "none";
   	    document.getElementById("brg_table").style.display = "none";

        if(port_status & 0x01){
            document.getElementById("lan_table").style.display = "";
        }
        if(port_status & 0x02){
    	    document.getElementById("brg_table").style.display = "";
        }
        show_nav_bar(2);
    }else if(mode==5){
		document.getElementById("nexb").style.display="none";
		document.getElementById("act").style.display="";
		document.getElementById("preb").style.display="";
        show_nav_bar(3);
    }
    else{
		document.getElementById("nexb").style.display="none";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="none";
   		document.getElementById("dhcpip1").style.display = "none";
		document.getElementById("dhcpip2").style.display = "none";
		document.getElementById("natip1").style.display  = "none";
		document.getElementById("natip2").style.display  = "none";

   		document.getElementById("dhcpip3").style.display = "none";
		document.getElementById("dhcpip4").style.display = "none";
		document.getElementById("natip3").style.display  = "none";
		document.getElementById("natip4").style.display  = "none";

        show_nav_bar(3);
    }
	for(i=0;i<VALID_PAGE_NUM;i++){
		if(i==mode){
    		//document.getElementById("p"+i).className="r5";
			document.getElementById("p"+i).style.display="";
			document.getElementById(i+"_table").style.display="";
            if(i==2){
                if(port_status != 0x02){
    			    document.getElementById("brg_goose_tr").style.display="none";
                }
            }
		}else{
			//document.getElementById("p"+i).className="r8";
			document.getElementById("p"+i).style.display="none";
			document.getElementById(i+"_table").style.display="none";
		}		
	}
    
}

var port_type=new Array;
function check_port_imag(index, ret_type){
	var imag, value;
	if(EDR_IF_IS_FIBER(port_desc, index)){
		if(port_type[index] == devimage["f_lan"]){
			value=0;
			imag=devimage["f_wan"];			
		}else if (port_type[index] == devimage["f_wan"]){
            value=2;
            imag=devimage["f_brg"];
        }
        else{
			value=1;
			imag=devimage["f_lan"];
		}
	}else{
		if(index%2==0){
			if(port_type[index] == devimage["c_lan"]){
				value=0;
				imag=devimage["c_wan"];
			}else if(port_type[index] == devimage["c_wan"]){
                value = 2;
                imag = devimage["c_brg"];
            }
            else{
				value = 1;
				imag=devimage["c_lan"];
			}
		}else{
			if(port_type[index] == devimage["c_lanR"]){
				value=0;
				imag=devimage["c_wanR"];
			}else if(port_type[index] == devimage["c_wanR"]){
                value = 2;
                imag = devimage["c_brgR"];
            }
            else{
				value=1;
				imag=devimage["c_lanR"];
			}			
		}		
	}
	
	if(ret_type==0){
		return imag;
	}else{
		return value;
	}
	
}

function port_chang(index){
	var imag;
	imag = check_port_imag(index,0);
	document.getElementById(index).src=imag;
	port_type[index]=imag;
}

function ChgLanIP(){


}


function brg_valid_range_check(brgnet, brgip, brgmask){
	var init_ip = brgnet+1;
	var end_ip = brgnet+255-parseInt(brgmask.split('.')[3])-1;
	var brgiparray=fnIp2Net(brgip,"255.255.255.255");

	brg_valid_range_low = brgip.split('.')[0]+'.'+brgip.split('.')[1]+'.'+brgip.split('.')[2]+'.'+(parseInt(brgip.split('.')[3])-(brgiparray-init_ip)).toString();
	brg_valid_range_high= brgip.split('.')[0]+'.'+brgip.split('.')[1]+'.'+brgip.split('.')[2]+'.'+(parseInt(brgip.split('.')[3])+(end_ip-brgiparray)).toString();
	if(end_ip-brgiparray > brgiparray- init_ip){
		dhcp_valid_range_low_brg=brgip.split('.')[0]+'.'+brgip.split('.')[1]+'.'+brgip.split('.')[2]+'.';
		dhcp_valid_range_low_brg+=(parseInt(brgip.split('.')[3])+1).toString();
		dhcp_valid_range_high_brg=brgip.split('.')[0]+'.'+brgip.split('.')[1]+'.'+brgip.split('.')[2]+'.';
		dhcp_valid_range_high_brg+=(parseInt(brgip.split('.')[3])+(end_ip-brgiparray)-1).toString();
	}else{
		dhcp_valid_range_low_brg=brgip.split('.')[0]+'.'+brgip.split('.')[1]+'.'+brgip.split('.')[2]+'.';
		dhcp_valid_range_low_brg+=(parseInt(brgip.split('.')[3])-(brgiparray-init_ip)).toString();
		dhcp_valid_range_high_brg=brgip.split('.')[0]+'.'+brgip.split('.')[1]+'.'+brgip.split('.')[2]+'.';
		dhcp_valid_range_high_brg+=(parseInt(brgip.split('.')[3])-1).toString();
	}
}


function inet_ntoa(num){
    var nbuffer = new ArrayBuffer(4);
    var ndv = new DataView(nbuffer);
    ndv.setUint32(0, num);

    var a = new Array();
    for(var i = 0; i < 4; i++){
        a[i] = ndv.getUint8(i);
    }
    return a.join('.');
}

function lan_valid_range_check(lannet, lanip, lanmask){
	var init_ip = lannet+1;
	//var end_ip = lannet+255-parseInt(lanmask.split('.')[3])-1;
	var end_ip = lannet + fnIp2Net("255.255.255.255","255.255.255.255") - fnIp2Net(lanmask,"255.255.255.255") -1;
	var laniparray=fnIp2Net(lanip,"255.255.255.255");

	lan_valid_range_low = inet_ntoa(init_ip);
	lan_valid_range_high = inet_ntoa(end_ip);
	
	if(end_ip-laniparray > laniparray- init_ip){//start ip is lanip +1
		//dhcp_valid_range_low=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.';
		//dhcp_valid_range_low+=(parseInt(lanip.split('.')[3])+1).toString();
		dhcp_valid_range_low=inet_ntoa(laniparray+1);
		//dhcp_valid_range_high=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.';
		//dhcp_valid_range_high+=(parseInt(lanip.split('.')[3])+(end_ip-laniparray)-1).toString();
		if(end_ip-laniparray > 253){
			dhcp_valid_range_high=inet_ntoa(laniparray+253);
		}else{
			dhcp_valid_range_high=inet_ntoa(end_ip);
		}
		
	}else{//start ip is init_ip +1
		//dhcp_valid_range_low=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.'; 
		//dhcp_valid_range_low+=(parseInt(lanip.split('.')[3])-(laniparray-init_ip)).toString();
		//dhcp_valid_range_high=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.';
		//dhcp_valid_range_high+=(parseInt(lanip.split('.')[3])-1).toString();

		if(laniparray- init_ip > 253){
			dhcp_valid_range_low=inet_ntoa(laniparray-253);
	}else{
			dhcp_valid_range_low=inet_ntoa(init_ip);
		}

		dhcp_valid_range_high=inet_ntoa(laniparray-1);
		
	}
}

/*check all ports are LAN port or BRG port.
 * return 1: all ports are LAN/BRG or WAN.
 */

function check_all_ports(){
    var i,j;
    var port_type_flag=1;

    for(i=0; i<SRV_VPLAN.length; i++){
        if(i<SYSPORTS){
            if(check_port_imag(i, 1) != 2){
                for(j=i;j<SRV_VPLAN.length;j++){
                    if(j<SYSPORTS){
                        if(check_port_imag(j,1) !=2 ){
                            if(check_port_imag(i, 1) != check_port_imag(j,1)){
                                port_type_flag = 0;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return port_type_flag;

}

/*check all ports are BRG ports.
 * return 1: all ports are BRG ports.
 */

function check_all_brg_ports(){
    var i;
    var port_type_flag=1;
    for(i=0; i<SYSPORTS; i++){
        if(check_port_imag(i, 1) != 1){
            port_type_flag=0;
            break;
        }
    }

    return port_type_flag;
}


function Send(form, val){
	var i,j,k;
	var lanip,lanmask;
    var brgip, brgmask;
    var bridge_vid = 4040;
    var bridge_port_num = 0;
    var lan_port_num = 0;
    var port_map=new Array(15);
    var port=0;
    var idx=0;

    for(i=0;i<15;i++){
        port_map[i]=0;
    }

	if(val==0){
		fnChgLMode(mode_index-1);		
	}else if(val==1){
		fnChgLMode(mode_index+1);		
	}else{
    if(button_disable == 0) {
        document.getElementsByName("SRV_VLAN_tmp")[0].value="";
        document.getElementsByName("SRV_VPLAN_tmp")[0].value="";
        /*set vlan ID and bridge_group_id*/
        for(i=0;i<SRV_VPLAN.length;i++){
            for(k in SRV_VPLAN_type){
                if(k=="pvid" && i < SYSPORTS){
                    if(check_port_imag(i,1) == 1){
                        document.getElementsByName("SRV_VPLAN_tmp")[0].value += bridge_vid + "+";
                        port_map[idx]=bridge_vid;
                        idx++;
                        bridge_vid++;
                        bridge_port_num++;
                    }else if(check_port_imag(i,1)== 2){
                        document.getElementsByName("SRV_VPLAN_tmp")[0].value += 2 + "+";
                        port_map[idx]=2;
                        idx++;
                    }else if(check_port_imag(i,1) == 0){
                        document.getElementsByName("SRV_VPLAN_tmp")[0].value += 1 + "+";
                        lan_port_num++;
                        port_map[idx]=1;
                        idx++;
                    }
                }else if ((k == "bridge_group_id") && (i < SYSPORTS)){
                    if(check_port_imag(i,1) == 1){
                        document.getElementsByName("SRV_VPLAN_tmp")[0].value += 8001 + "+";
                    }else{
                        document.getElementsByName("SRV_VPLAN_tmp")[0].value += 0 + "+";
                    }
                
                }else{
                        document.getElementsByName("SRV_VPLAN_tmp")[0].value += 0 + "+";
                }
            }
        }
        bridge_vid = 4040;

        /*LAN*/
        document.getElementsByName("SRV_VLAN_tmp")[0].value += 1 + "+";
        for(k=0 ; k < SRV_VPLAN.length; k++){
            if(k < SYSPORTS){
                if(check_port_imag(k,1) == 0){
                    document.getElementsByName("SRV_VLAN_tmp")[0].value += 2 + "+";
                }else{
                    document.getElementsByName("SRV_VLAN_tmp")[0].value += 0 + "+";
                }
            }else{
                document.getElementsByName("SRV_VLAN_tmp")[0].value += 0 + "+";
            }
                
        }
        /*WAN*/
        document.getElementsByName("SRV_VLAN_tmp")[0].value += 2 + "+";
        for(k=0 ; k < SRV_VPLAN.length; k++){
            if(k < SYSPORTS){
                if(check_port_imag(k,1) == 2){
                    document.getElementsByName("SRV_VLAN_tmp")[0].value += 2 + "+";
                }else{
                    document.getElementsByName("SRV_VLAN_tmp")[0].value += 0 + "+";
                }
            }else{
                document.getElementsByName("SRV_VLAN_tmp")[0].value += 0 + "+";
            }
        }

        /*bridge*/
        for(i=0 ; i<bridge_port_num;i++){
            document.getElementsByName("SRV_VLAN_tmp")[0].value += bridge_vid + "+";
            for(k=0; k< SRV_VPLAN.length; k++){
                if(k < SYSPORTS){
                    if(check_port_imag(k,1) == 1){
                        if(port_map[k] == bridge_vid){
                            document.getElementsByName("SRV_VLAN_tmp")[0].value += 2 + "+";
                        }
                        else{
                            document.getElementsByName("SRV_VLAN_tmp")[0].value += 0 +  "+";
                        }
                    }
                    else{
                        document.getElementsByName("SRV_VLAN_tmp")[0].value += 0 + "+";
                    }
                }else{
                    document.getElementsByName("SRV_VLAN_tmp")[0].value += 0 + "+";
                }
            }
            bridge_vid++;
        }
        
		form.brgtmp.value="";
    	for (k in SRV_BRG_type){
	    	if(k=="ifnameUsr"){
				form.brgtmp.value += "BRG_LAN" + "+"; 
            }else if(k == "enable"){
                if(bridge_port_num == 0){
     			    form.brgtmp.value += 0 + "+";
                }else{
 			        form.brgtmp.value += 1 + "+";
                }
            }else if(k=="ip"){
				brgip = document.getElementsByName("brgip")[0].value;
				form.brgtmp.value += brgip + "+"; 	
			}else if(k=="mask"){
				brgmask=document.getElementsByName("brgmask")[0].value;
				form.brgtmp.value += brgmask + "+"; 	
			}else if(k=="bridge_group_id"){
				form.brgtmp.value += 8001 + "+"; 
            }else if(k=="stp"){
                form.brgtmp.value += 0 + "+";
            }else if(k=="goose"){
                if(document.getElementById("brg_goose").checked == true){
                    if(check_all_brg_ports()){
                        form.brgtmp.value += 1 + "+";
                    }else{
                        form.brgtmp.value += 0 + "+";                   
                    }
                }
                else
                    form.brgtmp.value += 0 + "+";
            }

		}

		form.vconftmp.value="";
		for (k in SRV_VCONF_type){
			if(k=="ip"){
				lanip = document.getElementsByName("lanip")[0].value;
				form.vconftmp.value += lanip + "+"; 	
			}else if(k=="mask"){
				lanmask=document.getElementsByName("lanmask")[0].value;
				form.vconftmp.value += lanmask + "+"; 	
			}else if(k=="enable"){
				form.vconftmp.value += 1 + "+"; 	
			}else if(k=="vid"){
				form.vconftmp.value += 1 + "+"; 	
			}else if(k=="ifname"){
				form.vconftmp.value += "LAN" + "+"; 	
			}else{
				form.vconftmp.value += 0 + "+"; 
			}			
		}


		var brgnet=fnIp2Net(brgip,brgmask);
		var lannet=fnIp2Net(lanip,lanmask);

        lan_valid_range_check(lannet, lanip, lanmask);			
		brg_valid_range_check(brgnet, brgip, brgmask);
        
        if(check_all_ports() == 0){
	        if(fnIp2Net(lanip, lanmask) == fnIp2Net(brgip, brgmask)){
		        alert("LAN IP is in same IP segment with BRG IP");
    		    return;
            }
        }
		form.action="/goform/net_WebBridgeRoutingQuickSetting_GetValue?SRV=SRV_VPLAN&SRV0=SRV_VLAN&SRV1=SRV_VCONF&SRV2=SRV_BRG&wan=1&vid=2&state=1";

		form.action+="&SRV3=SRV_DHCP_SVR_MODE";
		form.action+="&SRV4=SRV_DHCP";
        button_disable = 1;
		fnChgLMode(mode_index+1);
		

        if(lan_port_num != 0){
		    if(!document.getElementById("dhcpen").checked==true){			
			    SRV_DHCP_DEFAULT["dhcp_en"]="";			
    		}else{
	    		form.mode.value=1;		
		    	SRV_DHCP_DEFAULT["dhcp_ip1"]=dhcp_valid_range_low;
    			SRV_DHCP_DEFAULT["dhcp_ip2"]=dhcp_valid_range_high;			
	    		SRV_DHCP_DEFAULT["dhcp_gateway"]=lanip;			
		    	//SRV_DHCP_DEFAULT["dhcpip1"]=;
    		}
        }

        if(bridge_port_num != 0){
    		if(!document.getElementById("dhcpen_brg").checked==true){			
	    		SRV_DHCP_BRG["dhcp_en"]="";			
    		}else{
	    		form.mode.value=1;		
		    	SRV_DHCP_BRG["dhcp_ip1"]=dhcp_valid_range_low_brg;
			    SRV_DHCP_BRG["dhcp_ip2"]=dhcp_valid_range_high_brg;			
    			SRV_DHCP_BRG["dhcp_gateway"]=brgip;			
		    }
        }

		/*for(k in SRV_DHCP_DEFAULT){			
			form.action+="&"+k+"="+SRV_DHCP_DEFAULT[k];			
		}*/

		form.SRV_DHCP_tmp.value="";
        if(lan_port_num != 0){
		    for(j in SRV_DHCP_type){
			    if(SRV_DHCP_DEFAULT[j]){
				    form.SRV_DHCP_tmp.value = form.SRV_DHCP_tmp.value + SRV_DHCP_DEFAULT[j] + "+";			
    			}else{
	    			form.SRV_DHCP_tmp.value = form.SRV_DHCP_tmp.value + "0" + "+";			
		    	}
    		}				
        }

        if(bridge_port_num !=0 ){
		    for(j in SRV_DHCP_type){
			    if(SRV_DHCP_BRG[j]){
				    form.SRV_DHCP_tmp.value = form.SRV_DHCP_tmp.value + SRV_DHCP_BRG[j] + "+";			
    			}else{
	    			form.SRV_DHCP_tmp.value = form.SRV_DHCP_tmp.value + "0" + "+";			
		    	}
    		}				
        }
		
		
		form.natTemp.value="";
        if(lan_port_num != 0){
		    if(document.getElementById("naten").checked==true){					
    			NAT_DEFAULT["ip3"]=lan_valid_range_low;
	    		NAT_DEFAULT["ip4"]=lan_valid_range_high;		
		    	for(k in NAT_DEFAULT){
			    	if(k=="idx"){
    				    	continue;
	    			}
		    		form.natTemp.value+=NAT_DEFAULT[k]+'+';			
			    }			
    		}
        }

        if(bridge_port_num != 0){
            if(document.getElementById("naten_brg").checked==true){					
			    NAT_BRG["ip3"]=brg_valid_range_low;
    			NAT_BRG["ip4"]=brg_valid_range_high;		
	    		for(k in NAT_BRG){
		    		if(k=="idx"){
			    		continue;
    				}
	    			form.natTemp.value+=NAT_BRG[k]+'+';			
		    	}			
		    }
        }

		form.natTemp.value += 0 + "+";
		form.submit();	
	}
    }
	
}

function img_init(){
	var cell, imag;
	var row,dev_img_x,dev_img_y;
	var table = document.getElementById('dev_setting');
	var p_x,p_y;

	
	row=table.getElementsByTagName("tr")[table.getElementsByTagName("tr").length-1];
	imag=devimage["dev"];
	cell = document.createElement("td");
	//cell.innerHTML="<img style=\"POSITION:fixed;top:"+devpos["dev"]['top']+";left:"+devpos["dev"]['left']+";\" id=\"dev\" src="+imag+"></img>";
	cell.innerHTML="<img style=\"POSITION:relative;\" id=\"dev\" src="+imag+"></img>";
	row.appendChild(cell);
	table.style.heigth=devpos["dev"]['sizey'];
	table.style.width=devpos["dev"]['sizex'];
	dev_img_x=document.getElementById("dev").offsetLeft;
	dev_img_y=document.getElementById("dev").offsetTop;
	for(j=0;j<port_desc.length;j++){		
		cell = document.createElement("td");
		if(EDR_IF_IS_FIBER(port_desc, j)){
            if(SRV_IP_CLIENT[0].vid == SRV_VPLAN[j].pvid){
                imag = devimage["f_wan"];
            }else{
                if(SRV_VPLAN[j].bridge_group_id != 0){
   	    		    imag= devimage["f_brg"];
                }else{
			        imag= devimage["f_lan"];
                }
            }
		}else{		
			if(j%2==0){
                if(SRV_IP_CLIENT[0].vid == SRV_VPLAN[j].pvid){
                    imag = devimage["c_wan"];
                }else{
                    if(SRV_VPLAN[j].bridge_group_id != 0){
        			    imag=devimage["c_brg"];
                    }else{
			    	    imag=devimage["c_lan"];
                    }
                }
			}else{
                if(SRV_IP_CLIENT[0].vid == SRV_VPLAN[j].pvid){
                    imag = devimage["c_wanR"];
                }else{
                    if(SRV_VPLAN[j].bridge_group_id != 0){
    			        imag=devimage["c_brgR"];
                    }else{
	    			    imag=devimage["c_lanR"];
                    }
                }
			}				
		}
		p_x = parseInt(devpos["port"+j]['left']);
		p_y = parseInt(devpos["port"+j]['top']);
		//p_x = parseInt(devpos["port"+j]['left']);
		//p_y = parseInt(devpos["port"+j]['top']);
		//p_x = 0;
		//p_y = 0;
		
		cell.innerHTML="<DIV><img onclick=port_chang("+j+") onMouseover=\"this.style.cursor='hand';\"  style=\"POSITION:absolute;top:"+p_y+";left:"+p_x+";\" id="+j+" src="+imag+"></img></DIV>";
		port_type[j]=imag;
		row.appendChild(cell);
	}			
}

var port_name="port";
function fnCheckWanImg(){
	var i,j,name;
	if(SRV_IP_CLIENT[0].vid!=0){
		for(i=0;i<SRV_VLAN.length;i++){
			if(SRV_IP_CLIENT[0].vid==SRV_VLAN[i].vlanid){
				for(j=0;j<port_desc.length;j++){
					name = port_name+j;					
					if(SRV_VLAN[i][name]!=0){
						port_chang(j);
					}
				}
				break;
			}
		}
	}

}


var vname = ['trst0', 'trst1', 'trst2', 'trst3', 'trpp0','trpp1', 'troe0', 'troe1' ];
var vnam2 = ['TDpen', 'TDpphd'];
function fnInit() {	
	myForm = document.getElementById('myForm');
	with (document) {		
		for (var i in vname)
			vobjs[vname[i]] = getElementById(vname[i]).style;
		for (var i in vnam2)
			vobjs[vnam2[i]] = getElementById(vnam2[i]);
	}
    document.getElementById("p"+0).className="r8";
	document.getElementById("wtyp").selectedIndex=1;
	fnChgLMode(0);
	img_init();	
	fnChgLType(0);
	fnChgLType(1);
	//fnCheckWanImg();
}

function stopSubmit()
{
	return false;
}	

</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_VLAN_tmp" id="vlantmp" value="" >
<input type="hidden" name="SRV_VPLAN_tmp" id="vplantmp" value="" >
<input type="hidden" name="SRV_VCONF_tmp" id="vconftmp" value="" >
<input type="hidden" name="SRV_BRG_tmp" id="brgtmp" value="" >
<input type="hidden" name="natTemp" id="natTemp" value="" >
<input type="hidden" name="mode" value=0 >
<input type="hidden" name="SRV_DHCP_tmp" value="" >
<% net_Web_csrf_Token(); %>

<table border="0" style="width:650px;">
 <tr>
  <td valign="top">
   <table id="dev_setting" cellpadding="0" cellspacing="0" style="POSITION:relative;">
   <tr>
   <!--td>
   <img src="image/EDR-810.png" height="407" width="162">
   </td-->
   </tr>
   </table>
  </td>
  <td valign="top">
   <table>
    <tr>
     <td colspan=4>
     
      <table border="0" cellpadding="0" cellspacing="0">
       <tr align="center"> 	
  	    <td class=r8 id="bar0" name="bar_mode" >Port Type</script></td>
  	    <td class=r8 id="bar1" name="bar_mode" ><script language="JavaScript">doc(Interface_);</script></td>
  	    <td class=r8 id="bar2" name="bar_mode" ><script language="JavaScript">doc(Service_);</script></td>
  	    <td class=r8 id="bar3" name="bar_mode" >Confirm</td>
       </tr>
      </table>
      
      <table border="0" cellpadding="0" cellspacing="0">
       <tr align="center"> 	
  	    <td class=r8 id="p0" name="setmode" ><script language="JavaScript">doc(Select_Port_Type);</script></td>
  	    <td class=r8 id="p1" name="setmode" ><script language="JavaScript">doc(LAN_IP_Configuration);</script></td>
  	    <td class=r8 id="p2" name="setmode" ><script language="JavaScript">doc(BRIDGE_IP_Configuration);</script></td>
  	    <td class=r8 id="p3" name="setmode" ><script language="JavaScript">doc(WAN_)</script>&nbsp;&nbsp;<script language="JavaScript">doc(Configuration_);</script></td>
  	    <td class=r8 id="p4" name="setmode" ><script language="JavaScript">doc(Service_);doc(" ");doc(Enable_);</script></td>
  	    <td class=r8 id="p5" name="setmode" ><script language="JavaScript">doc(SAVE_CONFIRM);</script></td>
  	    <td class=r8 id="p6" name="setmode" ><script language="JavaScript">doc(SAVE_CONFIRM);</script></td>
       </tr>
      </table>
     </td>
    </tr>
    <tr>
     <td valign="top" align="left">
      <table style="height:350px;width:450px;" border="0" cellpadding="0" cellspacing="0">
      <tr id="0_table">
       <td>
        <table border="0" align="center">
         <tr>
          <td>
           <img src="image/Arrow.png">
          </td>
          <td class=r0 valign="middle" align="left">
          	Click on the ports to select WAN, LAN or BRG.
          </td>
          </tr>          
  	   	</table>
       </td>
      </tr>
      <tr id="1_table">
       <td valign="top">
        <table border="0">
  	   	 <tr class=r1 valign="top">
  	   	  <td width = 90px><script language="JavaScript">doc(IP_Address)</script></td>
  	   	  <td><input type="text" id=lan_ip name="lanip" size=15 maxlength=15 onChange=ChgLanIP() value="192.168.127.254" ></td>
  	   	 </tr> 
  	   	 <tr class=r1 valign="top">
  	   	  <td width = 90px><script language="JavaScript">doc(Subnet_Mask)</script></td>
  	   	  <td><input type="text" id=lan_mask name="lanmask" size=15 maxlength=15 onChange=ChgLanIP() value="255.255.255.0"></td>
  	   	 </tr>
  	   	</table>
       </td>
      </tr>

      <tr id="2_table">
       <td valign="top">
        <table border="0">
  	   	 <tr class=r1 valign="top">
  	   	  <td width = 90px><script language="JavaScript">doc(IP_Address)</script></td>
  	   	  <td><input type="text" id=brg_ip name="brgip" size=15 maxlength=15 onChange=ChgLanIP() value="192.168.126.254" ></td>
  	   	 </tr> 
  	   	 <tr class=r1 valign="top">
  	   	  <td width = 90px><script language="JavaScript">doc(Subnet_Mask)</script></td>
  	   	  <td><input type="text" id=brg_mask name="brgmask" size=15 maxlength=15 onChange=ChgLanIP() value="255.255.255.0"></td>
  	   	 </tr>
  	   	 <tr class=r1 valign="top" id="brg_goose_tr">
  	   	  <td width = 90px><script language="JavaScript">doc(BR_GOOSE_MSG_)</script></td>
  	   	  <td><input type="checkbox" id=brg_goose name="brggoose" value=0></td>
  	   	 </tr>
  	   	</table>
       </td>
      </tr>

      <tr id="3_table">
       <td valign="top"> 
        <table align="left" valign="top" >
  		 <tr class=r0 valign="top">
  		  <td colspan=4><script language="JavaScript">doc(Connect_Type)</script></td>
  		  </tr>
  		 <tr class=r1>
  		  <td colspan=4>
  			<script language="JavaScript">fnGenSelect(selwtyp, '')</script>
  		  </td></tr>
  		 <tr class=r1 colspan=4>
  		  <script language="JavaScript">hr(4)</script></tr>
  		 <tr class=r0 id=trst0>
  		  <td colspan=4><script language="JavaScript">doc(Address_Information)</script></td></tr>  
  		  <td colspan=4>
  		  <table>
  		   <tr class=r1 id=trst1>
  		    <td style="width:90px"><script language="JavaScript">doc(IP_Address)</script></td>
  		    <td style="width:150px"><input type="text" size=15 maxlength=15 id=stip name="ipaddr"></td>
  		    <td style="width:90px"><script language="JavaScript">doc(Gateway_)</script></td>
  		    <td><input type="text" size=15 maxlength=15 id=stgw name="gateway"></td></tr>
  		    <td></td>
  		   <tr class=r2 id=trst2>
  		    <td><script language="JavaScript">doc(Subnet_Mask)</script></td>
  		    <td><input type="text" size=15 maxlength=15 id=stmk name="netmask"></td></tr>
  		    <td></td>
  		   <tr class=r1 id=trst3>
  		    <script language="JavaScript">hr(4)</script>
  		  </table></td></tr>
  		 <tr class=r0>
  		  <td colspan=4 id=TDpphd><script language="JavaScript">doc(PPPoE_Dialup)</script></td></tr>
  		  <tr class=r1 id=trpp0 align="left">
             <td style="width:120px" id=TDpen align="left"><script language="JavaScript">doc(PPTP_Connection)</script></td>
             <td style="width:150px"><input type="checkbox" id=ppen name="pptp_en" onClick="fnEnPPTP(this.checked)"><script language="JavaScript">doc(Enable_)</script></td>
             <td style="width:90px"><script language="JavaScript">doc(IP_Address)</script></td>
             <td><input type="text" size=15 maxlength=15 id=psrv name="pptp_srvr"></td>
            </tr>
  		 <tr class=r2 id=trpp1>
  		  <td align="left"><script language="JavaScript">doc(User_Name)</script></td>
  		  <td><input type="text" size=15 maxlength=47 id=pusr name="pptp_user"></td>
  		  <td align="left"><script language="JavaScript">doc(Password_)</script></td>
  		  <td><input type="text" size=15 maxlength=35 id=ppwd name="pptp_pswd"></td></tr>
  		 <tr class=r2 id=troe0>
  		  <td style="width:120px"><script language="JavaScript">doc(User_Name)</script></td>
  		  <td style="width:150px"><input type="text" size=15 maxlength=47 id=eusr name="poe_user"></td>
  		  <td style="width:90px"><script language="JavaScript">doc(Password_)</script></td>
  		  <td><input type="text" size=15 maxlength=35 id=epwd name="poe_pswd"></td></tr>
  		 <tr class=r1 id=troe1>
  		  <td ><script language="JavaScript">doc(Host_Name)</script></td>
  		  <td><input type="text" size=15 maxlength=35 id=ehnm name="poe_host"></td></tr>
  		 <tr class=r2>
  		  <script language="JavaScript">hr(4)</script></tr> 
  		</table>
     </td>
    </tr>
    <tr id="4_table">
     <td valign="top">
      <table id = "lan_table">
       <tr class=r1 >
        <td style="width:40px"><input type="checkbox" id=dhcpen checked ></td>
        <td colspan=4><script language="JavaScript">doc(Enable_);doc(" ");doc(DHCP_Server);doc(" ");doc("at");doc(" ");doc("LAN");doc(" ");doc("Interface")</script></td>
       </tr> 
       <tr class=r1 >
        <td></td>
        <td></td>
       	<td style="width:200px"><script language="JavaScript">doc(Offered_IP_Range)</script></td>  
  	   	<td style="width:30px">From</td>
        <td><input type="text" id=dhcpip1 name="dhcpip1" size=15 maxlength=15 disabled></td>
  		<td style="width:15px">To</td>
        <td><input type="text" id=dhcpip2 name="dhcpip2" size=15 maxlength=15 disabled></td>
       </tr> 
       <tr class=r1 > 
       	<td  style="width:40px"><input type="checkbox" id=naten name="naten" checked></td>
        <td  colspan=4><script language="JavaScript">doc(Enable_);doc(" ");;doc("N-1");doc(" ");doc("NAT");doc(" ");doc("for");doc(" ");doc("LAN");doc(" ");doc("Interface");doc(" ");doc("to");doc(" ");doc("WAN")</script></td>
       </tr>
       <tr class=r1 >
        <td></td>
        <td></td>
       	<td><script language="JavaScript">doc(IP_RANGE)</script></td>  
  	   	<td style="width:30px">From</td>
  	   	<td><input type="text" id=natip1 name="natip1" size=15 maxlength=15 disabled></td>
  		<td style="width:15px">To</td>
  		<td><input type="text" id=natip2 name="natip2" size=15 maxlength=15 disabled></td>
       </tr> 
       </table>

       <table id="brg_table">
       <tr class=r1>
        <td style="width:40px"><input type="checkbox" id=dhcpen_brg checked ></td>
        <td colspan=4><script language="JavaScript">doc(Enable_);doc(" ");doc(DHCP_Server);doc(" ");doc("at");doc(" ");doc(Bridge);doc(" ");doc("Interface")</script></td>
       </tr> 
       <tr class=r1>
        <td></td>
        <td></td>
       	<td style="width:200px"><script language="JavaScript">doc(Offered_IP_Range)</script></td>  
  	   	<td style="width:30px">From</td>
  	   	<td><input type="text" id=dhcpip3 name="dhcpip3" size=15 maxlength=15 disabled></td>
  		<td style="width:15px">To</td>
  		<td><input type="text" id=dhcpip4 name="dhcpip4" size=15 maxlength=15 disabled></td>
       </tr> 
       <tr class=r1 > 
       	<td style="width:40px"><input type="checkbox" id=naten_brg name="naten_brg" checked></td>
        <td colspan=4><script language="JavaScript">doc(Enable_);doc(" ");doc("N-1");doc(" ");doc("NAT");doc(" ");doc("for");doc(" ");doc(Bridge);doc(" ");doc("Interface");doc(" ");doc("to");doc(" ");doc("WAN")</script></td>
       </tr>
       <tr class=r1 >
        <td></td>
        <td></td>
       	<td><script language="JavaScript">doc(IP_RANGE)</script></td>  
  	   	<td style="width:30px">From</td>
  	   	<td><input type="text" id=natip3 name="natip3" size=15 maxlength=15 disabled></td>
  		<td style="width:15px">To</td>
  		<td><input type="text" id=natip4 name="natip4" size=15 maxlength=15 disabled></td>
       </tr> 
      </table>
     </td>
    </tr>
    <tr id="5_table">
     <td valign="top">
      <table >
       <tr class=r1 >
       	<td>After applying, please check your configuration.</td>  
       </tr> 
      </table>
     </td>
    </tr>

    <tr id="6_table">
     <td valign="top">
      <table >
       <tr class=r1 >
       	<td><script language="JavaScript">doc(BR_WAIT_MSG_)</script></td>  
       </tr> 
      </table>
     </td>
    </tr>

    </table>
     </td>
    </tr>
    <tr>
     <td valign="top">
      <table border=0>
       <tr>
		  <td align="left" id="preb"><script language="JavaScript">fnbnB(PRE_STEP_, 'onClick=Send(this.form,0)')</script></td>
		  <td align="right" id="nexb"><script language="JavaScript">fnbnB(NEXT_STEP_, 'onClick=Send(this.form,1)')</script></td>
		  <td align="right" id="act"><script language="JavaScript">fnbnB(Submit_, 'onClick=Send(this.form,2)')</script></td>
	   </tr>  
      </table>
     </td>
    </tr>
   </table>
  </td>
 </tr>
</table>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
