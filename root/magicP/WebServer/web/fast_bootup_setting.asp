<html>
<head>
<% net_Web_file_include(); %>


<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

checkMode(<% net_Web_GetMode_WriteValue(); %>);
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkCookie();

if (!debug) {

}else{
	<%net_Web_show_value('SRV_FAST_BOOTUP');%>		
}

var dep_fastboot_redundant = <% net_Web_getConfig_Redundant_and_Fastbootup_WriteValue(); %>;

var myForm;
	
function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_FAST_BOOTUP, SRV_FAST_BOOTUP_type);
}

function activate(form) 
{
	if(document.getElementById('enable').checked == true && dep_fastboot_redundant.redundant_enable == 1){
		alert("Cannot enable \"Fast Bootup\" and \"Redundant Protocols\" at the same time.");
	}
	else{
		form.action = "/goform/net_Web_get_value?SRV=SRV_FAST_BOOTUP";
		form.submit();
	}
}

</script>
</head>
			
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(_FAST_BOOTUP_SETTING)</script></h1>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_FAST_BOOTUP_tmp" id="SRV_FAST_BOOTUP_tmp" value="SRV_FAST_BOOTUP_tmp" />
<% net_Web_csrf_Token(); %>

<fieldset>
<table cellpadding=1 cellspacing=2 border=0 width=600px>  
 <tr align="left" >
  <td width=180px><script language="JavaScript">doc(Enable_)</script></td>
  <td><input type="checkbox" id=enable name="enable"></td>
 </tr>
</table>

<div class="r2" id="warning_txt">
    <p><font color="red"><b>Warning!</b></font></p>
    <p><font color="red"><b>"Fast Bootup" CANNOT work together with Turbo Ring and RSTP protocols.</b></font></p>
</div>

<div style="width:100%; text-align:left; margin-top:25px;" >
	<script language="JavaScript">fnbnB(Submit_, 'onClick=activate(myForm)')</script>
</div>

</fieldset>
</form>

</body>
</html>

