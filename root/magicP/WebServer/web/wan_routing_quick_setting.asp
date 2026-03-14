<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(WAN_ROUTING_QUICK_SETTING_)</script></title>
<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

checkCookie();

var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
if (debug) {
	var devimage = {
		dev:"image/EDR-810.gif",f_lan:"image/Fiber-LAN.png",f_wan:"image/Fiber-WAN.png",c_lan:"image/Copper-LAN.png",c_wan:"image/Copper-WAN.png"
			,c_lanR:"image/Copper-LAN-right.png",c_wanR:"image/Copper-WAN-right.png"

	};
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

var NAT_DEFAULT = { srv:2, idx:0, stat:'1', ifs:'48', prot:'', ip1:'', ip2:'', ip3:'192.168.127.1', ip4:'192.168.127.252', ip5:'', ip6:'', ip7:'', ip8:'', ip9:'', ip10:'', port1:'', port2:'', otoifid:'' };

var wtyp0 = [
	{ value:0, text:Static_IP },	{ value:1, text:Dynamic_IP },
	{ value:4, text:PPPoE_ }
];
var selwtyp = { type:'select', id:'wtyp', name:'proto', size:1, onChange:'fnChgLType(this.value)', option:wtyp0 };
var vobjs = {};

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
var button_disable = 0 ;

function check_input_fcormat(){

	if(!IpAddrNotMcastIsOK(document.getElementsByName("lanip")[0], IP_Address) || !NetMaskIsOK(document.getElementsByName("lanmask")[0], Subnet_Mask))
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




function fnChgLMode(mode) {
	var i;
	if(check_input_fcormat()){
		return;
	}
		

	mode_index = mode;
	if(mode==0){
		document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="none";
	}else if(mode==1){
		document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="";
	}else if(mode==2){
		document.getElementById("nexb").style.display="";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="";
	}else if(mode==3){
		document.getElementById("nexb").style.display="none";
		document.getElementById("act").style.display="";
		document.getElementById("preb").style.display="";
		var lanip = document.getElementsByName("lanip")[0].value;
		var lanmask=document.getElementsByName("lanmask")[0].value;
		var lannet=fnIp2Net(lanip,lanmask);
		lan_valid_range_check(lannet, lanip, lanmask);
		document.getElementById("dhcpip1").value = dhcp_valid_range_low;
		document.getElementById("dhcpip2").value = dhcp_valid_range_high;
		document.getElementById("natip1").value = lan_valid_range_low;
		document.getElementById("natip2").value = lan_valid_range_high;
    }else{
		document.getElementById("nexb").style.display="none";
		document.getElementById("act").style.display="none";
		document.getElementById("preb").style.display="none";
   		document.getElementById("dhcpip1").style.display = "none";
		document.getElementById("dhcpip2").style.display = "none";
		document.getElementById("natip1").style.display  = "none";
		document.getElementById("natip2").style.display  = "none";
    }
	for(i=0;i<5;i++){
		if(i==mode){
			document.getElementById("p"+i).className="r5";
			document.getElementById(i+"_table").style.display="";
		}else{
			document.getElementById("p"+i).className="r8";
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
		}else{
			value=1;
			imag=devimage["f_lan"];
		}
	}else{
		if(index%2==0){
			if(port_type[index] == devimage["c_lan"]){
				value=0;
				imag=devimage["c_wan"];
			}else{
				value=1;
				imag=devimage["c_lan"];
			}
		}else{
			if(port_type[index] == devimage["c_lanR"]){
				value=0;
				imag=devimage["c_wanR"];
			}else{
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


function lan_valid_range_check(lannet, lanip, lanmask){
	var init_ip = lannet+1;
	var end_ip = lannet+255-parseInt(lanmask.split('.')[3])-1;
	var laniparray=fnIp2Net(lanip,"255.255.255.255");

	lan_valid_range_low = lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.'+(parseInt(lanip.split('.')[3])-(laniparray-init_ip)).toString();
	lan_valid_range_high=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.'+(parseInt(lanip.split('.')[3])+(end_ip-laniparray)).toString();
	if(end_ip-laniparray > laniparray- init_ip){
		dhcp_valid_range_low=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.';
		dhcp_valid_range_low+=(parseInt(lanip.split('.')[3])+1).toString();
		dhcp_valid_range_high=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.';
		dhcp_valid_range_high+=(parseInt(lanip.split('.')[3])+(end_ip-laniparray)-1).toString();
	}else{
		dhcp_valid_range_low=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.';
		dhcp_valid_range_low+=(parseInt(lanip.split('.')[3])-(laniparray-init_ip)).toString();
		dhcp_valid_range_high=lanip.split('.')[0]+'.'+lanip.split('.')[1]+'.'+lanip.split('.')[2]+'.';
		dhcp_valid_range_high+=(parseInt(lanip.split('.')[3])-1).toString();
	}
}
function Send(form, val){
	var i,j,k;
	var lanip,lanmask;

	if(val==0){
		fnChgLMode(mode_index-1);		
	}else if(val==1){
		fnChgLMode(mode_index+1);		
	}else{
    if(button_disable == 0){
		document.getElementsByName("SRV_VLAN_tmp")[0].value="";		
		for(i=0;i<2;i++){			
			document.getElementsByName("SRV_VLAN_tmp")[0].value+=(i+1)+'+';			
			for(j=0;j<SRV_VPLAN.length; j++){				
				if(j<SYSPORTS&&check_port_imag(j,1)==i){
					document.getElementsByName("SRV_VLAN_tmp")[0].value+= 2+'+';	
				}else{
					document.getElementsByName("SRV_VLAN_tmp")[0].value+= 0+'+';	
				}
			}
		}	
		document.getElementsByName("SRV_VPLAN_tmp")[0].value="";
		for(i=0;i<SRV_VPLAN.length;i++){
			for(k in SRV_VPLAN_type){
				if(k=="pvid" && i < SYSPORTS){
					if(check_port_imag(i,1)==0){
						document.getElementsByName("SRV_VPLAN_tmp")[0].value+=1+'+';
					}else{
						document.getElementsByName("SRV_VPLAN_tmp")[0].value+=2+'+';
					}
				}else{
					document.getElementsByName("SRV_VPLAN_tmp")[0].value+=0+'+';
				}				
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
		var lannet=fnIp2Net(lanip,lanmask);

        

		form.action="/goform/net_WebWanRoutingQuickSetting_GetValue?SRV=SRV_VPLAN&SRV0=SRV_VLAN&SRV1=SRV_VCONF&wan=1&vid=2&state=1";
		form.action+="&SRV2=SRV_DHCP_SVR_MODE";
		form.action+="&SRV3=SRV_DHCP";
		
        button_disable = 1;
		fnChgLMode(4);

		lan_valid_range_check(lannet, lanip, lanmask);			
		if(!document.getElementById("dhcpen").checked==true){			
			SRV_DHCP_DEFAULT["dhcp_en"]="";			
		}else{
			form.mode.value=1;		
			SRV_DHCP_DEFAULT["dhcp_ip1"]=dhcp_valid_range_low;
			SRV_DHCP_DEFAULT["dhcp_ip2"]=dhcp_valid_range_high;			
			SRV_DHCP_DEFAULT["dhcp_gateway"]=lanip;			
			//SRV_DHCP_DEFAULT["dhcpip1"]=;
		}
		/*for(k in SRV_DHCP_DEFAULT){			
			form.action+="&"+k+"="+SRV_DHCP_DEFAULT[k];			
		}*/

		form.SRV_DHCP_tmp.value="";
		for(j in SRV_DHCP_type){
			if(SRV_DHCP_DEFAULT[j]){
				form.SRV_DHCP_tmp.value = form.SRV_DHCP_tmp.value + SRV_DHCP_DEFAULT[j] + "+";			
			}else{
				form.SRV_DHCP_tmp.value = form.SRV_DHCP_tmp.value + "0" + "+";			
			}
		}				
		
		
		form.natTemp.value="";
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
		form.natTemp.value += 0 + "+";
		//alert(document.getElementsByName("natTemp")[0].value)
		form.submit();	
		//alert(document.getElementsByName("SRV_VLAN_tmp")[0].value);
		//alert(form.action);
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
			imag= devimage["f_lan"];
		}else{		
			if(j%2==0){
				imag=devimage["c_lan"];
			}else{
				imag=devimage["c_lanR"];
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
	document.getElementById("p"+0).className="r5";
	document.getElementById("wtyp").selectedIndex=1;
	fnChgLMode(0);
	img_init();	
	fnChgLType(0);
	fnChgLType(1);
	fnCheckWanImg();
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
  	    <td class=r8 id="p0" name="setmode" ><script language="JavaScript">doc(Select_WAN_Port);</script></td>
  	    <td class=r8 id="p1" name="setmode" ><script language="JavaScript">doc(LAN_IP_Configuration);</script></td>
  	    <td class=r8 id="p2" name="setmode" ><script language="JavaScript">doc(WAN_)</script>&nbsp;&nbsp;<script language="JavaScript">doc(Configuration_);</script></td>
  	    <td class=r8 id="p3" name="setmode" ><script language="JavaScript">doc(Service_);doc(" ");doc(Enable_);</script></td>      
  	    <td class=r8 id="p4" name="setmode" ></td>

       </tr>
      </table>
     </td>
    </tr>
    <tr>
     <td valign="top" align="left">
      <table style="height:350px;width:400px;" border="0" cellpadding="0" cellspacing="0">
      <tr id="0_table">
       <td>
        <table border="0" align="center">
         <tr>
          <td>
           <img src="image/Arrow.png">
          </td>
          <td class=r0 valign="middle" align="left">
          	Click on the ports to select WAN or LAN
          </td>
          </tr>          
  	   	</table>
       </td>
      </tr>
      <tr id="1_table">
       <td valign="top">
        <table border="0">
  	   	 <!--tr class=r0>
  	   	  <td colspan=4><script language="JavaScript">doc(LAN_IP_Configuration)</script></td></tr-->
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
    <tr id="3_table">
     <td valign="top">
      <table >
       <tr class=r1 >
        <td  style="width:40px"><input type="checkbox" id=dhcpen checked ></td>
        <td colspan=2><script language="JavaScript">doc(Enable_);doc(" ");doc(DHCP_Server);</script></td>
       </tr> 
       <tr class=r1 >
        <td></td>
       	<td><script language="JavaScript">doc(Offered_IP_Range)</script></td>  
  	   	<td><input type="text" id=dhcpip1 name="dhcpip1" size=15 maxlength=15 disabled >~
  		<input type="text" id=dhcpip2 name="dhcpip2" size=15 maxlength=15 disabled></td>
       </tr> 
       <tr class=r1 > 
       	<td  style="width:40px"><input type="checkbox" id=naten name="naten" checked></td>
        <td colspan=2><script language="JavaScript">doc(Enable_);doc(" ");doc("N-1");doc(" ");doc("NAT");</script></td>
       </tr>
       <tr class=r1 >
        <td></td>
       	<td><script language="JavaScript">doc(IPT_SRC_IP_RANGE)</script></td>  
  	   	<td><input type="text" id=natip1 name="natip1" size=15 maxlength=15 disabled >~
  		<input type="text" id=natip2 name="natip2" size=15 maxlength=15 disabled></td>
       </tr> 
      </table>
     </td>
    </tr>
    <tr id="4_table">
     <td valign="top">
      <table >
       <tr class=r1 >
       	<td><script language="JavaScript">doc(WAN_WAIT_MSG_)</script></td>  
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
