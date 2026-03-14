<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
if (!debug) {

}else{
	<%net_Web_show_value('SRV_VRRP_GLOBAL');%>		
}


var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];


var actb = 'Active';
var myForm;

<!--#include file="lan_data"-->
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page=0&back=0&';

function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_VRRP_GLOBAL, SRV_VRRP_GLOBAL_type);
}

function stopSubmit()
{
	return false;
}
</script>
</head>				
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(VRRP_GLOBAL_ETTING_)</script></h1>
<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_VRRP_GLOBAL">
<fieldset>
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0 width=600px>
 
  <tr class="r0">
	<td style="width:100px;" align="left"><script language="JavaScript">doc(VRRP_ENABLE_TITLE)</script></td>
  </tr>
  <tr align="left" >
  	<td><script language="JavaScript">doc(IPT_NAT_ENABLE)</script></td>
  	<td valign="center"><script language="JavaScript">iGenSel2('VrrpEnable', 'VrrpEnable', wtyp0)</script></td>
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
