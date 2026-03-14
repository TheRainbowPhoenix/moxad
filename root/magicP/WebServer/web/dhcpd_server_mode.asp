<html>
<head>
<script language="JavaScript" src=doc.js></script>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie();

if (!debug) {
	var SRV_DHCP_SVR_MODE_type = { mode: 3 };
	var SRV_DHCP_SVR_MODE = { mode: 0 };
}else{	
	<%net_Web_show_value('SRV_DHCP_SVR_MODE');%>
}
	
var myForm;

function fnInit() {
	if (SRV_DHCP_SVR_MODE["mode"] == 0)
		document.getElementById("mode_dis").checked = true;
	else if (SRV_DHCP_SVR_MODE["mode"] == 1)
		document.getElementById("mode_dsip").checked = true;
	else if (SRV_DHCP_SVR_MODE["mode"] == 2)
		document.getElementById("mode_pip").checked = true;
}

</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(DHCP_Server_Mode)</script></h1>
<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_DHCP_SVR_MODE">
<fieldset>
<input type="hidden" name="em_hidden" id="em_hidden" value="" >
<% net_Web_csrf_Token(); %>
<table width="100%" border="0" align="left">
<tr align="left">
	<td><input type="radio" name="mode" id="mode_dis" value="0"><script>doc(Disable_)</script></td>   
</tr>
<tr align="left">
	<td><input type="radio" name="mode" id="mode_dsip" value="1"><script>doc(DHCP_Server_Mode_DSIP)</script></td>   
</tr>
<tr align="left">
	<td><input type="radio" name="mode" id="mode_pip" value="2"><script>doc(DHCP_Server_Mode_PIP)</script></td>   
</tr>
    	
<tr>
	<td><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett"></font></div></td>
	<td><script language="JavaScript">fnbnS(Submit_, '')</script></td>
</tr>
</table>
</fieldset>
</form>
</body></html>

