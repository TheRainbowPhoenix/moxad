<html>
<head>
<script language="JavaScript" src=doc.js></script>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=common.js></script>
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var myForm;
    
function fnInit() 
{	
		
	myForm = document.getElementById('myForm');	
	
}

function stopSubmit()
{
	return false;
}
</script>
</head>
    
<body onLoad=fnInit()>
<h1>OpenVPN Client Status</h1>

<fieldset width="700px">
<form id="myForm" name="myForm" mathod="GET">
    
<table align=left border=0>
<tr style="height:50px"></tr>
</table>


<table cellpadding=1 cellspacing=2 id="show_openvpn_status" style="width:630px">
 <tr>
<textarea name="textarea_openvpnStatus" rows="20" cols="80" style="font-size:15px; font-family: Arial, Helvetica, sans-serif, Marlett" readonly>
<% net_Web_openvpnShowStatus(1); %>
</textarea>
 </tr>
</table>


</form>
</fieldset>

</body></html>
