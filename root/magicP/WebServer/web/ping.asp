<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

var ModePing=<% net_Web_GetMode_WriteValue(); %>;
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkCookie();

if (debug) {
	var wdata = [
		{ ifs:'1', ip:'' }
	]
}
else{
	
}

if(ProjectModel == MODEL_EDR_G903){
	var ifs = [
		{ value:'1', text:'WAN1' },
		{ value:'2', text:'WAN2' },
		{ value:'0', text:'LAN' }
	];

}
else{	// ProjectModel == MODEL_EDR_G902
	var ifs = [
		{ value:'1', text:'WAN' },
		{ value:'0', text:'LAN' }
	];
}




var pingb = 'Ping';


var entryNUM=0;
<!--#include file="emalert_data"-->
var wtype = { ifs:2, ip:5 };

var cur_if;
 
var myForm;
function fnInit(row) {
	if(ModePing == 1)
		document.getElementById("ifs_tr").style.display="none";
	myForm = document.getElementById('myForm');
	EditRow(row);
	
	if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)
		document.getElementById("ifs_tr").style.display="";
	else
		document.getElementById("ifs_tr").style.display="none";
}


function EditRow(row) {
	fnLoadForm(myForm, wdata[row], wtype);
	//ChgColor('tri', wdata.length, row);
}

function Activate(form)
{	
	if(isSymbol(form.ip, IPADDR))
		return;
	
	if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)
	wdata[0].ifs=form.ifs.value;

	wdata[0].ip=form.ip.value;
	form.pingTemp.value = form.pingTemp.value + wdata[0].ifs + "+";	
	form.pingTemp.value = form.pingTemp.value + wdata[0].ip + "+";	

	form.action="/goform/net_WebPingGetValue";
	form.submit();
}
/*
function stopSubmit()
{
	return false;
}
*/
</script>
</head>
<body onLoad=fnInit(0)>

<h1><script language="JavaScript">doc(PING)</script></h1>

<form name="qwe" id="myForm" method="POST" onSubmit="return stopSubmit()">
<fieldset>
	<input type="hidden" name="pingTemp" id="pingTemp" value="" />
	<% net_Web_csrf_Token(); %>
	
	<div style="height:100px;">
		<table cellpadding="1" cellspacing="3" style="width:700px;" >
			<tr id="ifs_tr">
				<td style="width:150px;">
					<script language="JavaScript">doc(IPT_NAT_IF)</script>
				</td>
				<td align="left" valign="center">
			    	<script language="JavaScript">iGenSel2('ifs', 'ifs', ifs)</script>
			    </td>
			</tr>
			<tr>
				<td style="width:150px;">
					<script language="JavaScript">doc(IPADDR)</script>
				</td>
				<td align="left" valign="center">  
		            <input type="text" id="ip" name="ip" size=50 maxlength=50>
		        </td>
			</tr>
			
		</table>
	</div>
	
  	<table align="left">
    	<tr>
          	<td><script language="JavaScript">fnbnB(pingb, 'onClick=Activate(this.form)')</script></td>
		</tr>
	</table>
</fieldset> 
</form>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

