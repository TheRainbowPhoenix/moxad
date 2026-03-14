<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(DHCP_)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
var No_WAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
var NoMAC_PORT = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %>;
var SYS_PORTS = <% net_Web_Get_SYS_PORTS(); %>	
var SWITCH_ROUTER=((parseInt(SYS_PORTS) > parseInt(NoMAC_PORT))&& (No_WAN > 0));
var ModelVLAN = <% net_Web_GetModel_VLAN_WriteValue(); %>;
if (!debug) {
	var SRV_DHCP = {
		dhcpen:'1',  dhcplease:'60',
		dhcpdns1:'192.168.1.1', dhcpdns2:'168.95.192.1', dhcpip1:'192.168.1.2', dhcpip2:'192.168.1.100'		
	};
	var SRV_LAN = [	
	{	lanip:'192.168.127.10', lanmask:'255.255.255.0' }	
	]
}else{
	<%net_Web_show_value('SRV_DHCP');%>
	if(SWITCH_ROUTER){
		var SRV_LAN={lanip:'192.168.127.254',lanmask:'255.255.255.0'};
	}else{
		<%net_Web_show_value('SRV_LAN');%>
	}		
	<%net_Web_show_value('SRV_VCONF');%>
		
}
if (!debug) {
	var SRV_DHCPSIP = [
	{enable:'0', hostname:'test2', hostip:'192.168.127.50', hostmac:'00:90:E8:00:00:01'},
	{enable:'1', hostname:'test3', hostip:'192.168.127.51', hostmac:'00:90:E8:00:00:02'}
	];
	var ipcnt;
	var entryNUM=0;
}else{
	<%net_Web_show_value('SRV_DHCPSIP');%>
	var ipcnt;
	var entryNUM=0;
}

	
<!--#include file="lan_data"-->
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page=0&back=0&';
var link0 = 'dhcplist.asp';

//var tablesize = { enable:'120px', hostname:'240px', hostip:'200px', hostmac:'240px'};

var enable0 = [
	{ value:0  , text:Disable_ },	{ value:1  , text:Enable_ }
];
var vobjs = {};
var newdata=new Array;
var myForm;


var table_idx = 0;
var tablefun = new table_show(document.getElementsByName('form1'),"show_available_table" ,SRV_DHCPSIP_type, SRV_DHCPSIP, table_idx, newdata, Addformat, 0);

function EditRow(row) {
	fnLoadForm(myForm, SRV_DHCPSIP[row], SRV_DHCPSIP_type);
	ChgColor('tri', SRV_DHCPSIP.length, row);
}
var SIP_MAX = 256;
function Total_IP()
{
	if(SRV_DHCPSIP.length > SIP_MAX || SRV_DHCPSIP.length  < 0){		
		alert('Number of ip is Over or Wrong');
		with(document){
			getElementById('btnA').disabled = true;			
			getElementById('btnD').disabled = false;			
			getElementById('btnM').disabled = false;			
			getElementById('btnS').disabled = true;
		}				
	}else if(SRV_DHCPSIP.length == SIP_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else if(SRV_DHCPSIP.length == 0){		
		with (document) {		
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = true;
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
	document.getElementById("totalipcnt").innerHTML = '('+SRV_DHCPSIP.length +'/' +SIP_MAX+')';
	//document.getElementById("totalipcnt").innerHTML = SRV_DHCPSIP.length + ' / 256';
}

function tabbtn_sel(form, sel)
{	
	if(sel == 0 || sel == 2){
		if(sel == 0){
			table_idx = SIP_MAX;
		}else{
			table_idx = tNowrow_Get();
		}
		if(duplicate_check(table_idx, SRV_DHCPSIP, "hostname", document.getElementById('myForm')["hostname"].value, DHCP_SIP + ' ' + Name_  + ' ' + document.getElementById('myForm')["hostname"].value + ' '  + "is already existed")<0){
			return;
		}
		if(!(IpAddrIsOK(form.hostip,Static_IP)))
		{
			return;
		}
		
		
		if((isSymbol(document.getElementById('myForm')["hostname"], Name_)))
		{
			return;
		}
		if(!MacAddrIsOK(document.getElementById('myForm')["hostmac"], 'MAC Address')){
			return;
		}
		document.getElementById('myForm')["hostmac"].value = mac_format(document.getElementById('myForm')["hostmac"].value);
		if(duplicate_check(table_idx, SRV_DHCPSIP, "hostmac", document.getElementById('myForm')["hostmac"].value, DHCP_SIP + ' ' + MAC_Address  + ' ' + document.getElementById('myForm')["hostmac"].value + ' '  + "is already existed")<0){
			return;
		}
	}
	if(sel == 0){		
		Addformat(1,0);
		tablefun.add();	
	}else if(sel == 1){
		tablefun.del();
	}else if(sel == 2){
		tablefun.mod();
	}
	Total_IP();	
}

function Addformat(mod,i)
{	
	var j;	
	var k;
	var j = 0;
	var type;
	//alert(SRV_DHCPSIP.length);
	for(k in SRV_DHCPSIP_type){
		type = document.getElementsByName(k)[0].type;
		if(type == "checkbox"){
			if(mod==0){
				if(SRV_DHCPSIP[i][k]==1)
					newdata[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
				else
					newdata[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
			}else{
				if(document.getElementById('myForm')[k].checked==true)
					newdata[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
				else
					newdata[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
			}	
			j++;	
			continue;	
		}
			
		if(mod==0){
			newdata[j] = SRV_DHCPSIP[i][k]; 
		}else{
			newdata[j] = document.getElementById('myForm')[k].value;
		}		
		j++;
	}	
	//alert("newdata.length  "+newdata.length);
}


function Activate(form)
{	
	var i;
	var j;

	var myForm = document.getElementById('myForm');	
	var netwk1, netwk2;
	var same = 0;
	if(document.getElementById('dhcpen').checked==true){
		netwk1 = fnIp2Net( myForm.dhcpip1.value, SRV_LAN.lanmask );	
		netwk2 = fnIp2Net( myForm.dhcpip2.value, SRV_LAN.lanmask );		
		
		same |= !(netwk1==SRV_LAN.netwk);
		same |= !(netwk2==SRV_LAN.netwk);	

		//netwk1 = fnIp2Net( myForm.dhcpip1.value, '255.255.0.0' );
		//netwk2 = fnIp2Net( myForm.dhcpip2.value, '255.255.0.0' );
			
		//same |= (netwk1==netwk2)?0:2;
		if(same & 1){
			alert(dhcp_alert);
			//return;
		}//else if(same & 2){
		//	alert(dhcp_class_alert);
		//	return;
		//}
	
		if(!(SerIpRangeCheck(document.getElementById('myForm')["dhcpip1"].value,document.getElementById('myForm')["dhcpip2"].value, 512)))
		{
			return;
		}
		if(document.getElementById('myForm')["dhcplease"].value<5)
		{
			alert(dhcp_lease_alert);
			return;
		}
	}

	for(i = 0 ; i < SRV_DHCPSIP.length ; i++)
	{	
		for (var j in SRV_DHCPSIP[i]){
			//alert(j);
			form.SRV_DHCPSIP_tmp.value = form.SRV_DHCPSIP_tmp.value + SRV_DHCPSIP[i][j] + "+";		
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_DHCP&SRV0=SRV_DHCPSIP";	
	form.submit();	
}

/*function ChgDHCPIP(i) {
	var myForm = document.getElementById('myForm');	
	var netwk;
	if(i == 0){
		netwk = fnIp2Net( myForm.dhcpip1.value, SRV_LAN.lanmask ) ;
	}else{
		netwk = fnIp2Net( myForm.dhcpip2.value, SRV_LAN.lanmask ) ;
	}	
	
	same |= !(netwk==SRV_LAN.netwk)	
	//if (!same)		
	//vobjs.anyen.disabled = same;
}*/

function fnInit() {	
	myForm = document.getElementById('myForm');	
	with (document) {		
		if(ModelVLAN){
			SRV_LAN.lanip = SRV_VCONF[0].ip;
			SRV_LAN.lanmask = SRV_VCONF[0].mask;
		}
		SRV_LAN.netwk = fnIp2Net(SRV_LAN.lanip, SRV_LAN.lanmask);
	}	
	fnLoadForm(myForm, SRV_DHCP, SRV_DHCP_type);
	tablefun.show();
	Total_IP();
	EditRow(0);		
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="SRV_DHCPSIP_tmp" id="SRV_DHCPSIP_tmp" value="" >
<table cellpadding=1 cellspacing=2 border =0>
<tr><td>
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:100%">
 <tr class=r0 >
  <td colspan=4><script language="JavaScript">doc(DHCP_Configuration)</script></td></tr>  
 <tr class=r1 align="left">
  <td width=40px><script language="JavaScript">doc(Enable_)</script></td>
  <td><input type="checkbox" id=dhcpen name="dhcpen"></td>
  <td width=75px><script language="JavaScript">doc(Lease_Time);doc("&nbsp;&nbsp;");</script></td>
  <td><input type="text" id=dhcplease name="dhcplease" size=5 maxlength=5>(<script language="JavaScript">;doc(min__);</script>)</td></tr>  
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:100%">
 <tr class=r2 align="left">
  <td width=140px><script language="JavaScript">doc(DNS_Server_IP_for_Client)</script></td>
  <td><input type="text" id=dhcpdns1 name="dhcpdns1" size=15 maxlength=15>&nbsp;&nbsp;
  <input type="text" id=dhcpdns2 name="dhcpdns2" size=15 maxlength=15></td></tr>
  <td></td>
 <tr class=r1 align="left">  
  <td><script language="JavaScript">doc(Offered_IP_Range)</script></td>  
  <td><input type="text" id=dhcpip1 name="dhcpip1" size=15 maxlength=15 >~
  <input type="text" id=dhcpip2 name="dhcpip2" size=15 maxlength=15 ></td></tr> 
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=1 border=0 width=100%>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(DHCP_SIP)</script></td></tr>
 <tr class=r2 align="left">
  <td width=50px><script language="JavaScript">doc(Enable_)</script></td>
  <td width=150px><input type="checkbox" id=enable name="enable" value=1></td>
  <td width=100px><script language="JavaScript">doc(Name_)</script></td>
  <td><input type="text" id=hostname name="hostname" size=10 maxlength=10 ></td>  
 <tr class=r1 align="left">
  <td><script language="JavaScript">doc(Static_IP)</script></td>
  <td><input type="text" id=hostip name="hostip" size=15 maxlength=15></td>
  <td><script language="JavaScript">doc(MAC_Address)</script></td>    
  <td><input type="text" id=hostmac name="hostmac" size=15 maxlength=17></td>
</table>
</td></tr>
<tr><td>
<table align=left border=0>
 <tr>
  <td width=50px><script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script></td>
  <td width=70px><script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script></td>
  <td width=120px><script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td></tr>
 <tr>
  <script language="JavaScript">color_line("blue",4)</script>
 </tr>
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2 id="show_available_table" border=0>
<tr class=r0>
 <td><script language="JavaScript">doc(DHCP_SIP_List)</script></td>
 <td id = "totalipcnt" colspan=3></td></tr>
 <tr class=r5 align="left">
  <td width=120px><script language="JavaScript">doc(Enable_)</script></td>
  <td width=240px><script language="JavaScript">doc(Name_)</script></td>
  <td width=200px><script language="JavaScript">doc(Static_IP)</script></td>
  <td width=240px><script language="JavaScript">doc(MAC_Address)</script></td> </tr>
</table>
</td></tr>
<table>
</form>
</body></html>
