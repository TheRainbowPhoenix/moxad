<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
var NoIFS = <% net_Web_GetNO_IFS_WriteValue(); %>;
checkCookie();
if (!debug) {
	var SRV_LAN = {
		lanip:'192.168.1.1', lanmask:'255.255.255.0', dhsen:'1', anyen:'0', dhtm:'60',
		dns1:'192.168.1.1', dns2:'168.95.192.1', dhip1:'192.168.1.2', dhip2:'192.168.1.100'		
	};
	var wan = [
	{	ipad:'192.168.9.10', mask:'255.255.255.0' },
	{	ipad:'192.168.8.10', mask:'255.255.255.0' },
	{	ipad:'192.168.7.10', mask:'255.255.255.0' }	
	]
}else{
	//<%net_Web_show_value("SRV_LAN");%>
	<%net_Web_show_value('SRV_VCONF');%>			
	<%net_Web_show_value('SRV_VLAN');%>	
	
	var wan = [
		<%net_webLan_Wan_IP();%>
	]	
	Ipset = [<%net_websIpset();%>]
}
if(NoIFS ==3){
	var wan0 = [{ value:0, text:'WAN1' },	{ value:1, text:'WAN2' },	{ value:2, text:'LAN' }];
}else if(NoIFS == 2){
	var wan0 = [{ value:0, text:'WAN' },	{ value:1, text:'LAN' }];
}else if(NoIFS == 1){
	var wan0 = [{ value:0, text:'LAN' }];
}else{
	var wan0 = [{ value:0, text:'LAN' }];
}
	
<!--#include file="lan_data"-->
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page=0&back=0&';
var iftyp0 = [
	{ value:0, text:Static_IP },	{ value:0x10, text:WAN_ },
];
var seliptype = { type:'select', id:'v_type', name:'type', size:1, onChange:'', option:iftyp0 };
var seliface = { type:'select', id:'vlan_interface', name:'interface', size:1, onChange:'VConf_fnChgIface(this.value)', option:wan0 };

var vobjs = {};
var vname = [ 'anyen', 'arpen', 'arip1', 'arip2' ];
var tablefun=new Array;
var table_idx = 0;
var newdata0=new Array;
var LanForm;
var chflag=0xff;
var VLAN_MAX = 16;

function VConf_fnChgIface(value) {
	if(if_data.length<=1)
		return;
	if(value == ""&&chflag==0xff){
		value = 0;
	}else if(value == ""){
		value=chflag;
	}	
	table_index.value=value;
	if(chflag == value){
		return;
	}else{
		chflag = value;
	}	
	if(table_index.value){
		tablefun[table_index.value].show();
		VConf_Total_IP();				
		fnLoadForm(LanForm, if_data[value][0], SRV_VCONF_type);	
	}else{
		table_index.value=value;
	}
	if(value == 0){
		document.getElementById("vlan_interface").disabled=true;
	}
	
	
}

function VConf_Addformat(mod,i)
{	
	var j=0, str;	
	var k;
	j = 0;

	for(k in SRV_VCONF_type){		
		if(k == "interface" || k=="type")
			continue;
		if(document.getElementById('LanForm')[k].type=="hidden"){
			if(mod==1){
				if(SRV_VCONF_type[k]==4){
					document.getElementById('LanForm')[k].value=0;
				}else{
					document.getElementById('LanForm')[k].value="";
				}
			}
			continue;
		}
		
		if(SRV_VCONF_type[k] == 3){			
			if(mod==0){
				if(if_data[table_index.value][i][k]==1)
					newdata0[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
				else
					newdata0[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
			}else{
				if(document.getElementById('LanForm')[k].checked==true)
					newdata0[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
				else
					newdata0[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
			}				
		}else{
			if(mod==0){
				newdata0[j] = if_data[table_index.value][i][k]; 			
			}else{
				newdata0[j] = document.getElementById('LanForm')[k].value;
			}
		}
		

		
		//if(SRV_VCONF_type[k] == 2){			
		if(document.getElementsByName(k)[0].type=="select-one"){
			var tmp=document.getElementsByName(k)[0];
			var idx;
			for(idx = 0; idx< tmp.length; idx++){
				if(tmp.options[idx].value==newdata0[j]){
					newdata0[j]=tmp.options[idx].text;
					break;
				}
			}
		}
		/*if(k == "vid"){
			//str = wan0[newdata0[0]].text;
			newdata0[0]+='.'+newdata0[j];
		}*/
		
		j++;
	}	
}

function VConf_Total_IP()
{
	if(if_data[table_index.value].length > VLAN_MAX || if_data[table_index.value].length  < 0){		
		alert('Number of IP is over or wrong');
		with(document){
			getElementById('btnA').disabled = true;			
			getElementById('btnD').disabled = false;			
			getElementById('btnM').disabled = false;			
			getElementById('btnS').disabled = true;
		}				
	}else if(if_data[table_index.value].length == VLAN_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else if(if_data[table_index.value].length == 1){		
		with (document) {		
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else{		
		with (document) {		
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}	
	document.getElementById("totalipcnt").innerHTML = VLAN_IF_List + ' ('+if_data[table_index.value].length +'/' +VLAN_MAX+')';
}

function check_vlan_inuse( vlanid, sel){
	var i,j;

	
	for(i=0;i< Ipset.length;i++){
		if(Ipset[i].vid==vlanid)
			return 0;
	}

	for(i = 0 ; i < wan0.length ; i++)
	{
		for(j = 0 ; j < if_data[i].length ; j++)
		{
			if((sel == 2) && (j == tNowrow_Get())) { // "Modify" clicked ignore the now row
				continue;
			}
			if(if_data[i][j].vid==vlanid)
				return 2;
		}		
	}
	return 1;
}

/*
	Return: 
		0 is OK, otherwise name is conflict
*/
function lan_checkIfname(name, sel)
{
	var i, j;
	

	for(i = 0 ; i < wan0.length ; i++) {
		for(j = 0 ; j < if_data[i].length ; j++) {
			if((sel == 2) && (j == tNowrow_Get())) { // "Modify" clicked ignore the now row
				continue;
			}

			//alert(if_data[i][j].ifname);
			if(if_data[i][j].ifname == name) { // name conflict
				
				return 1;
			}
		}		
	}
	
	return 0;
}

var if_data=new Array;
var vidsel = [{ value:"0", text:"--------"}];

function show_vlan(){
	var i, idx, len;

	idx=0; 
	len = document.getElementById("vid").options.length;
	for(i = 0;i < len;i++){
		document.getElementById("vid").options.remove(i);   		
	}

	for(i=0; i < SRV_VLAN.length; i++){
		if(check_vlan_inuse(SRV_VLAN[i].vlanid, 0)){
			var varItem = new Option(SRV_VLAN[i].vlanid, SRV_VLAN[i].vlanid);      
          	document.getElementById("vid").options.add(varItem);   						
			idx++;
		}
	}
	//document.writc(iGenSel2Str(\'vid\', \'vid\', vidsel)); 
}


function VConf_Tabbtn_sel(form, sel)
{	
	if(sel == 0 || sel == 2){
		if(sel == 0){ // "Add"
			table_idx = VLAN_MAX;
		}else{ // "Modify"
			table_idx = tNowrow_Get();
		}

		if(!(IpAddrIsOK(form.v_ip, IP_Address)) || !(NetMaskIsOK(form.v_mask, Subnet_Mask)))
		{
			return;
		}
		if(table_idx == 0){
			if(document.getElementById("vid").options.selectedIndex!=0){
				alert("The VID of LAN is set by the first entry of VLAN");
				return;
			}
			if(document.getElementById("stat").checked!=true){
				alert("The Enable of LAN is always on");
				return;
			}
		}

		if(lan_checkIfname(form.ifname.value, sel) != 0) {
			alert("The interface name is conflict !!");
			return;
		}
		
		var net=fnIp2Net(form.v_ip.value, form.v_mask.value);

		for(var i = 0 ; i < wan0.length ; i++)
		{
			for(var j = 0 ; j < if_data[i].length ; j++)
			{
				if(table_idx == j)
					continue;
				var check_mask;
				if(fnIp2Net(if_data[i][j].mask, if_data[i][j].mask) > fnIp2Net(form.v_mask.value, form.v_mask.value)){
					check_mask=form.v_mask.value;
				}else{
					check_mask=if_data[i][j].mask;
				}
				if(fnIp2Net(if_data[i][j].ip, check_mask) == fnIp2Net(form.v_ip.value, check_mask)){
					alert("LAN IP is in same IP segment with others");
					return;
				}
			}		
		}
		if(check_vlan_inuse(document.getElementById('LanForm')['vid'].value, sel)==2){
			alert("VLAN id is in use");
			return;
		}
	}
	

	if(sel == 0){
		VConf_Addformat(1,0);
		tablefun[table_index.value].add();	
	}else if(sel == 1){
		tablefun[table_index.value].del();
	}else if(sel == 2){
		tablefun[table_index.value].mod();
	}
	VConf_Total_IP();	
}

function VConf_Activate(form)
{	
	var i,j,k;

	var LanForm = document.getElementById('LanForm');	

	//form.lanip.value = if_data[0][0]["ip"];
	//form.lanmask.value= if_data[0][0]["mask"];
	
	for(i = 0 ; i < wan0.length ; i++)
	{
		for(j = 0 ; j < if_data[i].length ; j++)
		{
			for (var k in if_data[i][j]){
				form.vlantmp.value = form.vlantmp.value + if_data[i][j][k] + "+";		
			}
		}		
	}
	
	//form.action="/goform/net_Web_get_value?SRV=SRV_VCONF&SRV0=SRV_LAN";
	form.action="/goform/net_Web_get_value?SRV=SRV_VCONF";
	form.submit();	
}



function ChgLanIP() {
	/*var netwk = fnIp2Net( LanForm.lanip.value, LanForm.lanmask.value ) ;
	var same = 0;
	for (var i in wan)
		same |= (netwk==wan[i].netwk)
	if (same)
		alert(lan_alert);*/
	//vobjs.anyen.disabled = same;
}

function Activate(form)
{
	if(!IpAddrNotMcastIsOK(form.lanip, IP_Address) || !NetMaskIsOK(form.lanmask, Subnet_Mask))
		return;
	alert("If you change LAN IP address or Subnet Mask, maybe the DHCP Server, NAT, Firewall and more need reconfiguration");
	form.submit();
}

function Entry_Init(row) {
	if(row == 0){
		with(document){
			getElementById('btnD').disabled = true;		
		}				
	}else{
		with(document){
			getElementById('btnD').disabled = false;	

		}
	}
}

function fnEnBcast(checked)
{
	if(checked == true){
		document.getElementById('bcastIP').disabled = false;
	}
	else{
		document.getElementById('bcastIP').disabled = true;
		document.getElementById('bcastIP').checked = false;
	}
}

function fnInit() {	
	//Lan
	LanForm = document.getElementById('LanForm');	
	with (document) {		
		for (var i in vname)
			vobjs[vname[i]] = getElementById(vname[i]);
		for (var i in wan)
			wan[i].netwk = fnIp2Net(wan[i].ipad, wan[i].mask);
	}	

	//Vlan Config
	table_index=document.getElementById("vlan_interface");
	for(i=0;i< wan0.length; i++){
		if_data[i]=new Array;
		tablefun[i]=new table_show(document.getElementsByName('LanForm'),"show_available_table" ,SRV_VCONF_type, if_data[i], table_idx, newdata0, VConf_Addformat, Entry_Init);
	}
	/*if_data[0][0]=new Array;
	if_data[0][0]["enable"]=1;
	if_data[0][0]["ifname"]="LAN";
	if_data[0][0]["vid"]=SRV_VLAN[0]["vlanid"];
	if_data[0][0]["ip"]=SRV_LAN["lanip"];
	if_data[0][0]["mask"]=SRV_LAN["lanmask"];*/
	for(var i = 0; i < SRV_VCONF.length; i++){
		if_data[SRV_VCONF[i]["interface"]][if_data[SRV_VCONF[i]["interface"]].length]=new Array;
		if_data[SRV_VCONF[i]["interface"]][if_data[SRV_VCONF[i]["interface"]].length-1]=SRV_VCONF[i];			
	}
	tablefun[0].show();
	fnLoadForm(LanForm, if_data[table_index.value][0], SRV_VCONF_type);
	ChgLanIP();
	show_vlan();
	VConf_Total_IP();
	Entry_Init(0);
}

</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(LAN_CONFIG)</script></h1>

<fieldset>
<form id=LanForm name=LanForm method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="SRV_VCONF_tmp" id="vlantmp" value="" >
<input type="hidden" name="lanip" id="lanip" value="" >
<input type="hidden" name="lanmask" id="lanmask" value="" >
<table cellpadding=1 cellspacing=2 border =0>
<tr><td>
<table cellpadding=1 cellspacing=1 border=0 width=100%>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(LAN_IP_Configuration)</script></td></tr>
 <tr align="left">
  <td width=80px style="display:none"><script language="JavaScript">doc(Interface_)</script></td> 
  <td width=150px style="display:none"><script language="JavaScript">fnGenSelect(seliface, '')</script></td>
  <td width=80px><script language="JavaScript">doc(Name_)</script></td> 
  <td width=150px><input type="text" id=ifname name="ifname" size=20 maxlength=40></td>
  <td width=80px><script language="JavaScript">doc(V_ID_)</script></td>
  <td><script language="JavaScript">iGenSel2('vid','vid',vidsel);</script></td></tr>
 <tr align="left">   
  <td width=80px><script language="JavaScript">doc(Enable_)</script></td>
  <td width=150px><input type="checkbox" id=stat name="enable" value=1></td>
  <td width=80px><script language="JavaScript">doc(DIR_BCAST)</script></td>
  <td width=150px><input type="checkbox" id=bcast name="bcast" value=0 onChange="fnEnBcast(this.checked)"></td>
  <td width=80px><script language="JavaScript">doc(OVERWRITE_SRC_IP)</script></td>
  <td width=150px><input type="checkbox" id=bcastIP name="bcastIP" value=0></td>
  <td width=80px style="display:none"><script language="JavaScript">doc(Type_)</script></td> 
  <td width=150px style="display:none"><script language="JavaScript">fnGenSelect(seliptype, '')</script></td></tr>  
 <tr align="left">
  <td><script language="JavaScript">doc(IP_Address)</script></td>
  <td><input type="text" id=v_ip name="ip" size=15 maxlength=15></td>
  <td><script language="JavaScript">doc(Subnet_Mask)</script></td>
  <td><input type="text" id=v_mask name="mask" size=15 maxlength=15></td>
  <td><input type="hidden" id=v_routing name="routing"></td></tr>
  <td><input type="hidden" id=v_dvmrp name="dvmrp"></td></tr>
</table>
</td></tr>
<tr><td>
<table align=left border=0>
 <tr>
  <td width=400px><script language="JavaScript">fnbnBID(addb, 'onClick=VConf_Tabbtn_sel(this.form,0)', 'btnA')</script>
  				  <script language="JavaScript">fnbnBID(delb, 'onClick=VConf_Tabbtn_sel(this.form,1)', 'btnD')</script>
  				  <script language="JavaScript">fnbnBID(modb, 'onClick=VConf_Tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=300px><script language="JavaScript">fnbnSID(Submit_, 'onClick=VConf_Activate(this.form)', 'btnS')</script></td></tr>
</table>
</td></tr>
<tr><td>
<table align=left border=0>
	<tr style="height:50px"></tr>
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2 id="show_available_table" border=0>
<tr class=r0>
 <td id = "totalipcnt" colspan=3><script language="JavaScript"></script></td>
 <td></td></tr>
 <tr align="left">
  <th width=120px style="display:none"><script language="JavaScript">doc(Interface_)</script></th>
  <th width=210px><script language="JavaScript">doc(Name_)</script></th>
  <th width=120px><script language="JavaScript">doc(Enable_)</script></th>    
  <th width=120px style="display:none"><script language="JavaScript">doc(Type_)</script></th>    
  <th width=150px><script language="JavaScript">doc(V_ID_)</script></th>
  <th width=200px><script language="JavaScript">doc(IP_Address)</script></th>
  <th width=240px><script language="JavaScript">doc(Subnet_Mask)</script></th>
  <th width=120px class="s0"><script language="JavaScript">doc(DIR_BCAST)</script></th>	
  <th width=120px class="s0"><script language="JavaScript">doc(OVERWRITE_SRC_IP)</script></th></tr>
</table>
</td></tr>
<table>
</form>
<fieldset>

</body></html>
