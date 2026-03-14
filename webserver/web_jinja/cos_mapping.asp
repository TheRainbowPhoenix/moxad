<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});		
{{ net_Web_show_value('SRV_COS_MAPPING') | safe }}

var prioritysel = [
	{ value:0, text:Low_},	{ value:1, text:Normal_}, { value:2, text:Medium_}, { value:3, text:High_}
];

function show_CoS_map()
{
    var i;
	for(i=0;i<8;i++)
	{
	    document.write('<tr bgcolor="#FFFFFF">');
		document.write('<td width="25%"><div align="center"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#007C60"><b>'+i+'</b></font></div></td>');
		document.write('<td width="25%"><div align="center"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#007C60">');
		iGenSel2('cosmap'+i,'cosmap'+i,prioritysel);
		document.write('</font></div></td>');
		document.write('</tr>');
	}
}
var myForm;
function fnInit() 
{
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_COS_MAPPING, SRV_COS_MAPPING_type);	
}

</script>
</head>
<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc(cos_mapping)</script></h1>
<form id=myForm method="post" name="cos_mapping_form" action="/goform/net_Web_get_value?SRV=SRV_COS_MAPPING">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table>
<tr><td>
	<table border="0" align="left"><tr>
	 <td align="left">
	   <table width="400" border="0" align="center">
	     <tr bgcolor="#007C60">
	  		<th width="100">CoS</th>
	    	<th width="300">Priority Queue</th>
	  	 </tr>
		 	<script language="JavaScript">show_CoS_map()</script>
	  	</table></td>
	 </tr>
	</table>
</td></tr>

<tr><td>
	<table width="670" border="0" align="left">
	  <tr> <td><script language="JavaScript">fnbnS(Submit_, '')</script></td> </tr>
	</table>
</td></tr>
</table>

</fieldset>
</form>
</body>
</html>