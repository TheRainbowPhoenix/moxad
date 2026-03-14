<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script type="text/javascript"></script>
<script language="JavaScript">
checkCookie();
var ModelName = <%net_Web_GetModelName_WriteValue(); %>;

function Activate(form)
{
	if(form.chkexcludecert.checked == true) {
		form.excludecert.value = 1;
	}
	else {
		form.excludecert.value = 0;
	}
	
	form.action="/goform/FactoryDefault";	
	form.submit();	
     
	return;
}

function fnInit()
{  
	return;
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(Reset_Factory_Default)</script></h1>
<fieldset>
<!--<form method="post" name="factory_form" action="/goform/FactoryDefault" target="mid" >-->
<form id=myForm method="POST">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="excludecert" id="excludecert" value="1">
	<table width="600px" border="0">
  		<tr>     		
  			<td colspan=2><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			This function will reset all settings to their factory default values. </font></div></td>  			
  		</tr>
  		<tr> 
  			<td colspan=2><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			Be aware that previous settings will be lost. </font></div></td>  			
  		</tr>
            <tr name="trexcludecert" id="trexcludecert">  			
  			<td width="20px"><input type="checkbox" name="chkexcludecert" id="chkexcludecert" checked></td>
  			<td> Keep "Certificate Management" and  "Authentication Certificate" configuration </td>
 	    </tr>
            <tr></tr> 		
  		<tr>
  			<td colspan=2><div align="left"><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></div></td>	
  		</tr>
	</table>
</fieldset>

</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>
