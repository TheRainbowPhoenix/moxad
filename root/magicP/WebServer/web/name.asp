<html><head><title>Moxa Logo</title>
<% net_Web_file_include(); %>
<STYLE type="TEXT/CSS">
.top {
	font-family: Arial;
	font-weight: bold;
	font-size: 18pt;
	color:rgb(0,154,130);
}
</STYLE>
</head>

<script language="JavaScript">
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
var ModelNmae = <%net_Web_GetModelName_WriteValue(); %>;

function ShowTitle()
{	
	document.write(ModelNmae + ' Industrial Secure Router');		
}
</script>

<body style="margin: 0px;">
<table cellpadding="0" cellspacing="0" width="100%">
<tr><td border="0" width="193">
    <img src="image/logo_a.jpg" border="0">
</td>
<td border="0" width=""> 
    <img src="image/side.jpg" border="0">
</td>
<td class="top">
	<script language="JavaScript">ShowTitle()</script>
</td>
<td border="0" align="right"> 
    <img src="image/logo_b.jpg" border="0">
</td>
	</tr>
</table></body></html>
