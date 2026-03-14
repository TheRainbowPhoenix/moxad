<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}		
var SYSTRUNKS = {{ net_Web_Get_SYS_TRUNKS() | safe }}
var port_desc=[{{ net_webPortDesc() | safe }}];
{{ net_Web_show_value('SRV_COS_MAPPING') | safe }}
{{ net_Web_show_value('SRV_QOS_CLASSIFICATION') | safe }}
{{ net_Web_show_value('SRV_TRUNK_SETTING') | safe }}
var port_prisel = [
	{ value:0, text:"------"}, { value:1, text:"------"}, { value:2, text:"------"}, { value:3, text:"------"}, { value:4, text:"------"},
	{ value:5, text:"------"}, { value:6, text:"------"}, { value:7, text:"------"}
];

var prioritysel = [
	{ value:0, text:Low_},	{ value:1, text:Normal_}, { value:2, text:Medium_}, { value:3, text:High_}
];

var queuingsel = [
	{ value:0, text:Weight_},	{ value:1, text:Strict_}
];
var trunk_check=new Array;
var MAX_COS=8;
function Addformat(idx, newdata)
{	
    if(idx<SYSPORTS)
    {	
	newdata[0] = port_desc[idx].index;
	newdata[1] = "<input type=checkbox name="+'enable_tos'+idx+ " " + ((parseInt(SRV_QOS_CLASSIFICATION['enable_tos'+idx])) ? 'checked':'') +" >";
	newdata[2] = "<input type=checkbox name="+'enable_cos'+idx+ " " + ((parseInt(SRV_QOS_CLASSIFICATION['enable_cos'+idx])) ? 'checked':'') +" >";
	newdata[3] = iGenSel2Str('port_pri' + idx,'port_pri' + idx,port_prisel );
    }
	else
	{
	var trkid=idx-SYSPORTS+1;
	newdata[0] = 'Trk'+trkid;	
	newdata[1] = "<input type=checkbox name="+'enable_tos'+idx+ " " + ((parseInt(SRV_QOS_CLASSIFICATION['enable_tos'+idx])) ? 'checked':'') +" >";
	newdata[2] = "<input type=checkbox name="+'enable_cos'+idx+ " " + ((parseInt(SRV_QOS_CLASSIFICATION['enable_cos'+idx])) ? 'checked':'') +" >";
	newdata[3] = iGenSel2Str('port_pri' + idx,'port_pri' + idx,port_prisel );
	}
}
function prisel_init()
{
    var i;
    for(i=0;i<MAX_COS;i++)
	{
		port_prisel[i].text=i + "(" + prioritysel[SRV_COS_MAPPING['cosmap'+i]].text + ")";
	}
}
function tableinit(){
	var newdata=new Array;
	var i;
		
	//for(i=0; i<port_count; i++){
	for(i=0; i<SYSPORTS; i++){
	    if(SRV_TRUNK_SETTING[i].trkgrp==0)
	    {
		    Addformat(i, newdata);
		    tableaddRow("qos_setting_table", i, newdata, "left");
	    }
		else
		{
		    Addformat(i, newdata);
		    tableaddRowHidden("qos_setting_table", i, newdata, "left");
		    trunk_check[SRV_TRUNK_SETTING[i].trkgrp]=1;
		}
	}
	for(i=0;i< SYSTRUNKS;i++)
		{
		   if( trunk_check[i+1]==1)
		   	{
		    Addformat(SYSPORTS+i, newdata);
		    tableaddRow("qos_setting_table", i, newdata, "left");		   	    
		   	}
		   else
		   	{
		   	Addformat(SYSPORTS+i, newdata);
		    tableaddRowHidden("qos_setting_table", i, newdata, "left");
		   	}
		}
}
var myForm;
function fnInit() 
{
	myForm = document.getElementById('myForm');	
		prisel_init();
	tableinit();
	fnLoadForm(myForm, SRV_QOS_CLASSIFICATION, SRV_QOS_CLASSIFICATION_type);	
}

</script>
</head>
<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc(qos_classification)</script></h1>
<form id=myForm method="post" name="qos_classification_form" action="/goform/net_Web_get_value?SRV=SRV_QOS_CLASSIFICATION">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=1 width="100%" border=0>
 <tr>
  <td width="200"><script language="JavaScript">doc("Scheduling Mechanism")</script></td>
  <td width="500"><script language="JavaScript">iGenSel2('queuing', 'queuing', queuingsel)</script></td></tr>
</table>
<table cellpadding=1 cellspacing=1 width="100%" border=0>
 <tr>
  <td width="600"><DIV style="OVERFLOW: auto; OVERFLOW-X: hidden;  HEIGHT: 300; ">
		<table align="left" id="qos_setting_table">
  			<tr bgcolor="#007C60">
  				<th width="10%">Port</th>
    			<th width="30%">Inspect ToS</th>
    			<th width="30%">Inspect CoS</th>
    			<th width="30%">Port Priority</th>
  			</tr>
		</table></DIV></td>
  <td width="100"></td>
 </tr>
</table>
<table width="100%" border="0" align="left">
 <td><script language="JavaScript">fnbnS(Submit_, '')</script></td> 
</table>
</fieldset>
</form>
</body>
</html>