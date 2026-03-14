<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});		
{{ net_Web_show_value('SRV_TOS_MAPPING') | safe }}

var prioritysel = [
	{ value:0, text:Low_},	{ value:1, text:Normal_}, { value:2, text:Medium_}, { value:3, text:High_}
];

function show_headline()
{
    var i;
    for(i=0;i<4;i++)
	{
	    document.write('<th width="10%">ToS</th>');						
        document.write('<th width="15%">Level</th>');
	}
					
}
function paddingLeft(str,lenght){
	if(str.length >= lenght)
	return str.toUpperCase() ;
	else
	return paddingLeft("0" +str,lenght);
}

function show_ToS_map()
{
    var i,j,k;
    for(i=0;i<64;i++)
	{
	    j=i*4;
		j=j.toString(16);
		j=paddingLeft(j,2);
		k=i+1;
		if ((i == 0)|| !(i % 4))
		{
		    document.write('</tr>');
			document.write('<tr bgcolor="#FFFFFF">');
		}
		document.write('<td width="10%"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#007C60"><b>0x'+j+'('+k+')</b></font></td>');
		document.write('<td width="15%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#007C60">');
		iGenSel2('tosmap'+i,'tosmap'+i,prioritysel);
		document.write('</font></div></td>');
	}
	document.write('</tr>');
}
var myForm;
function fnInit() 
{
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_TOS_MAPPING, SRV_TOS_MAPPING_type);	
}

</script>
</head>
<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc(tos_mapping)</script></h1>
<form id=myForm method="post" name="tos_mapping_form" action="/goform/net_Web_get_value?SRV=SRV_TOS_MAPPING">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table><tr><td>
<table width="100%" align="left" border="0"><tr>
  <td width="70%"><DIV style="OVERFLOW: auto; OVERFLOW-X: hidden;  HEIGHT: 300; ">
    <table width="100%" align="left" border="0">
      <tr bgcolor="#007C60">
        <script language="JavaScript">show_headline()</script>
      </tr>
	  <tr>
	        <td colspan=8>
			<table width="100%" align="left" border="0">
			<script language="JavaScript">show_ToS_map()</script></table></td>
	  </tr>
	</table>
  </DIV></td>  
</tr></table>
</td></tr>

<tr><td>
	<table width="670" border="0" align="left">
		<tr>
		<td><script language="JavaScript">fnbnS(Submit_, '')</script></td> 
		</tr>
	</table>
</td></tr>
</table>
</fieldset>
</form>
</body>
</html>