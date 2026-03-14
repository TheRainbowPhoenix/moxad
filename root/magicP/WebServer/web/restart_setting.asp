<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script type="text/javascript">
</script>
<script language="JavaScript">checkCookie();</script>
</head>
<body>

<h1><script language="JavaScript">doc(Restart_)</script></h1>

<form id=myForm method="POST" action="/goform/Restart">
<fieldset>
<% net_Web_csrf_Token(); %>
<div align="center">
<input type="hidden" name="restart_tmp" id="restarttmp" value="" >
	<table width="90%" border="0" align="left">
  		<tr> 
    		<td ><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			This function will restart the system. </font></div></td>  			
  		</tr>  		
  		<tr>  			
  			<td ><div align="left">
  			 <script language="JavaScript">fnbnS(Submit_, '')</script></td> 			  			
  		</tr>
	</table>
</div>
</fieldset>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>
