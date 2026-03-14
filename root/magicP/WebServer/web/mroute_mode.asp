<html>
<head>
<script language="JavaScript" src=doc.js></script>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=common.js></script>
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();

if (!debug) {
	var SRV_MROUTE_MODE_type = { mroute_mode: 3 };
	var SRV_MROUTE_MODE = { mroute_mode: 0 };
}else{	
	<%net_Web_show_value('SRV_MROUTE_MODE');%>
}
	
var myForm;

function fnInit() {
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_MROUTE_MODE, SRV_MROUTE_MODE_type);	
}

</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(MROUTE_MODE_)</script></h1>

<fieldset>
<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_MROUTE_MODE">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="em_hidden" id="em_hidden" value="" >	  
<table width="100%" border="0" align="left">
<tr align="left">
	<td width="30%"><input type="radio" name="mroute_mode" id="mode_dis" value="0"><script>doc(Disable_)</script></td>   
</tr>
<tr align="left">
	<td><input type="radio" name="mroute_mode" id="mode_smroute" value="1"><script>doc(SMCRoute)</script></td>   
</tr>
<tr align="left">
	<td><input type="radio" name="mroute_mode" id="mode_dvmrp" value="2"><script>doc(DVMRP_)</script></td>   
</tr>
<tr align="left">
	<td><input type="radio" name="mroute_mode" id="mode_pim_sm" value="3"><script>doc(PIM_SM_)</script></td>   
</tr>
    	
<tr>
	<td><script language="JavaScript">fnbnS(Submit_, '')</script></td>
</tr>
</table>
</form>
</fieldset>

</body></html>

