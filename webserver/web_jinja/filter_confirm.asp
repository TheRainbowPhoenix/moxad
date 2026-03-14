<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(SAVE_CONFIRM)</script></title>
<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script type="text/javascript">
</script>
</head>
<body class=main>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>
<!--<form method="post" name="factory_form" action="/goform/Restart" target="mid" >-->
<form id=myForm method="POST" action="/goform/Filter_CheckConfirm">
{{ net_Web_csrf_Token() | safe }}
<div align="center">
<input type="hidden" name="confirm_tmp" id="confirmtmp" value="" >
	<table width="90%" border="0" align="center">
		<table height = 50>&nbsp;</table>
  		<tr> 
    		<td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	</font></div></td>
    		<td width="70%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			Press "Confirm "button to save the change. </font></div></td>
  			<td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	</font></div></td>
  		</tr>  		
  		<tr>
  			<td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	</font></div></td>
            <td width="14%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
  				</font></div></td>	
  			<td width="56%"><div align="left">
  			 <script language="JavaScript">fnbnS('Confirm', '')</script></td> 			
  			<td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	</font></div></td>
  		</tr>
	</table>
</div>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>

