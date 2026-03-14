<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();
if (!debug) {
	var SRV_VPNG = {
		enable:'0', natt:'1'	
	};
}else{
	{{ net_Web_show_value('SRV_VPNG') | safe }}		
}


var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];


var actb = 'Active';
var myForm;
var vpng_selstate = { type:'select', id:'v_enable', name:'enable', size:1, option:wtyp0 };
var vpng_log_level = { type:'select', id:'logenable', name:'logenable', size:1, option:wtyp0 };

{% include "lan_data" ignore missing %}
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page=0&back=0&';

function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_VPNG, SRV_VPNG_type);
}

function stopSubmit()
{
	return false;
}
</script>
</head>				
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(VPN_G_Settings_)</script></h1>
<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_VPNG">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2 border=0 width=600px>
 <tr align="left">
  <td width=180px><script language="JavaScript">doc(IPsec_STATE_)</script></td>
  <td><script language="JavaScript">fnGenSelect(vpng_selstate, '')</script></td>
 </tr>   
 <tr align="left" >
  <td width=180px><script language="JavaScript">doc(IPsec_NATT_)</script></td>
  <td><input type="checkbox" id=v_natt name="natt"></td>
  </tr>
  <tr align="left" >
	  	<td style="width:180px;"><script language="JavaScript">doc(VPN_EVENT_LOG_)</script></td>
	  	<td style="width:100px;" align="left" valign="center"><script language="JavaScript">iGenSel2('logenable', 'logenable', wtyp0)</script></td>

	  	<td style="width:10px;"><script language="JavaScript">doc(MOXA_FLASH_)</script></td>
  		<td style="width:40px;" align="left" valign="center"><input type="checkbox" id=vflash name="vflash"></td>
  		
		<td style="width:10px;"><script language="JavaScript">doc(SYSLOG_SERVER_)</script></td>
  		<td style="width:40px;" align="left" valign="center"><input type="checkbox" id=vsyslog name="vsyslog"></td>

	  	<td style="width:70px;"><script language="JavaScript">doc(SNMP_TRAP_)</script></td>
	  	<td style="width:40px;" align="left" valign="center"><input type="checkbox" id=vtrap name="vtrap"></td>
  </tr> 
</table>

<p><table align=left>
 <tr>
  <td style="width:600px" align=left><script language="JavaScript">fnbnS(Submit_, '')</script></td>
  <td width=15></td></tr>
</table></p>
</fieldset>
</form>
</body></html>
