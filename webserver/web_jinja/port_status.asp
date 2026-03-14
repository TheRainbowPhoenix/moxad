<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">	
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}		
{{ net_Web_show_value('SRV_PORT_LINK_STATUS') | safe }}


var speedsel = [
	{ value:0, text:AUTO_},	{ value:1, text:FULL_100M_}, { value:2, text:HALF_100M_}, { value:3, text:FULL_10M_}, { value:4, text:HALF_10M_}
];
var gigaspeedsel = [
	{ value:0, text:AUTO_}, { value:5, text:FULL_1G_},	{ value:1, text:FULL_100M_}, { value:2, text:HALF_100M_}, { value:3, text:FULL_10M_}, { value:4, text:HALF_10M_}
];
var fdxsel = [
	{ value:0, text:Disable_},	{ value:1, text:Enable_}
];
var mdisel = [
	{ value:0, text:AUTO_},	{ value:1, text:MDI_}, { value:2, text:MDIX_}
];
var disfdx = [
	{ value:0, text:Disable_}
];
var trkspeedsel = [
	{ value:0, text:FULL_100M_}
];
var nosel = [
	{ value:0, text:"----"}
];





function showPortStatus(port_desc, media_type, link_status, mdi_status, flow_ctrl, port_state)
{
	var customInfoTable = document.getElementById('port_setting_table');
	var row, cell;
	
	row = customInfoTable.insertRow(customInfoTable.rows.length);

	cell = document.createElement("td");
	cell.style.textAlign = 'center';
	cell.innerHTML = port_desc;

	row.appendChild(cell);

	cell = document.createElement("td");
	cell.style.textAlign = 'center';
	cell.innerHTML = media_type;
	
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.style.textAlign = 'center';
	cell.innerHTML = link_status;
	
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.style.textAlign = 'center';
	cell.innerHTML = mdi_status;
	
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.style.textAlign = 'center';
	cell.innerHTML = flow_ctrl;
	
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.style.textAlign = 'center';
	cell.innerHTML = port_state;
	
	row.appendChild(cell);
	
}



function tableinit(){
	var i;
	for(i=0; i<SYSPORTS; i++){
		showPortStatus(SRV_PORT_LINK_STATUS[i].port_desc, SRV_PORT_LINK_STATUS[i].media_type, SRV_PORT_LINK_STATUS[i].link_status, SRV_PORT_LINK_STATUS[i].mdi_status, 
			SRV_PORT_LINK_STATUS[i].flow_ctrl, SRV_PORT_LINK_STATUS[i].port_state);
	}
	//enableCheck(SRV_PORT_SETTING);
}


function stopSubmit()
{
	return false;
}

var myForm;
function fnInit() {
	myForm = document.getElementById('myForm');	
	var i;
	tableinit();
	fnLoadForm(myForm, SRV_PORT_LINK_STATUS, SRV_PORT_LINK_STATUS_type);
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc("Port Status")</script></h1>
<form id=myForm method="post" onSubmit="return stopSubmit()">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table width="100%" border="0" align="left">
<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td width="97%" colspan="2">
		<table width="690" border="0" align="left" id="port_setting_table">
  			<tr bgcolor="#007C60">
  				<th width="8%" class=s0><script language="JavaScript">doc(Port_)</script></th>
    			<th width="16%" class=s0><script language="JavaScript">doc(MediaType_)</script></th>
    			<th width="12%"><script language="JavaScript">doc(LinkStatus_)</script></th>    			
    			<th width="15%" class=s0><script language="JavaScript">doc(Mdi_)</script></th>
    			<th width="15%" class=s0><script language="JavaScript">doc(Fdx_)</script></th>
    			<th width="15%" class=s0><script language="JavaScript">doc(PortStat_)</script></th>
  			</tr>
		</table>
	</td>
</tr>
</table>
</fieldset>

</form>
</body>
</html>
