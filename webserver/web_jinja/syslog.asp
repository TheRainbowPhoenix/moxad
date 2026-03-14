<html>
<head>
{{ net_Web_file_include() | safe }}
<!--<title><script language="JavaScript">doc(SYSLOG_SETTING)</script></title>-->

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = [
		{ stat1:1, stat2:0, stat3:0, server1:'192.168.2.252', server2:'', server3:'', port1:'514', port2:'', port3:'' }
	]
}
else{
	var wdata = [ {{ net_Web_Syslog_WriteValue() | safe }} ]
}


var entryNUM=0;
{% include "emalert_data" ignore missing %}
var wtype = { stat1:3, stat2:3, stat3:3, server1:5, server2:5, server3:5, port1:4, port2:4, port3:4 };

var cur_if;
 
var myForm;
function fnInit(row) {
	myForm = document.getElementById('myForm');
	EditRow(row);
}


function EditRow(row) {
	fnLoadForm(myForm, wdata[row], wtype);
	//ChgColor('tri', wdata.length, row);
}

function SyslogLikeCheckFormat(form)
{
	var error=0;
	if(form.stat1.checked==false) {
		if(!isNull(form.server1.value)) {
			if(isSymbol(form.server1, "Server 1"))
				error=1;
		}
		if(!isNull(form.port1.value)) {
			if(!isPort(form.port1, 'Server 1 port'))
				error=1;
		}
	} else {
		if(isSymbol(form.server1, "Server 1") || !isPort(form.port1, 'Server 1 port'))
			error=1;
	}
	
	if(form.stat2.checked==false) {
		if(!isNull(form.server2.value)) {
			if(isSymbol(form.server2, "Server 2"))
				error=1;
		}
		if(!isNull(form.port2.value)) {
			if(!isPort(form.port2, 'Server 2 port'))
				error=1;
		}
	} else {
		if(isSymbol(form.server2, "Server 2") || !isPort(form.port2, 'Server 2 port'))
			error=1;
	}

	if(form.stat3.checked==false) {
		if(!isNull(form.server3.value)) {
			if(isSymbol(form.server3, "Server 3"))
				error=1;
		}
		if(!isNull(form.port3.value)) {
			if(!isPort(form.port3, 'Server 3 port'))
				error=1;
		}
	} else {
		if(isSymbol(form.server3, "Server 3") || !isPort(form.port3, 'Server 3 port'))
			error=1;
	}

	return error;
}

function Activate(form)
{	
	if(SyslogLikeCheckFormat(form)==1)
		return;
	
	document.getElementById("btnU").disabled="true";
	
	var i;

	if(form.stat1.checked==true)
		wdata[0].stat1=1;
	else
		wdata[0].stat1=0;

	if(form.stat2.checked==true)
		wdata[0].stat2=1;
	else
		wdata[0].stat2=0;

	if(form.stat3.checked==true)
		wdata[0].stat3=1;
	else
		wdata[0].stat3=0;
	
	wdata[0].server1 = form.server1.value;
	wdata[0].server2 = form.server2.value;
	wdata[0].server3 = form.server3.value;
	wdata[0].port1 = form.port1.value;
	wdata[0].port2 = form.port2.value;
	wdata[0].port3 = form.port3.value;

	for(i = 0 ; i < wdata.length ; i++)
	{	
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].stat1 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].stat2 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].stat3 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].server1 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].server2 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].server3 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].port1 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].port2 + "+";
		form.syslogTemp.value = form.syslogTemp.value + wdata[i].port3 + "+";
	}

	form.submit();	
}

</script>
</head>
<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(SYSLOG_SETTING)</script></h1>

<form name="qwe" id="myForm" method="POST" action="/goform/net_WebSyslogGetValue">
{{ net_Web_csrf_Token() | safe }}
<fieldset>
	<input type="hidden" name="syslogTemp" id="iptTemp" value="" />
	
	<DIV>
		<table cellpadding="1" cellspacing="3" style="width:700px;">
			<tr>
				<td style="width:50px;">
					<script language="JavaScript">doc(IPT_FILTER_ENABLE)</script><br/>
				</td>
				<td style="width:150x;" align="left" valign="center">
					<input type="checkbox" id="stat1" name="ipt_filter_enable">
				</td>
			</tr>
			<tr>
				<td style="width:100px;">
					<script language="JavaScript">doc(SYSLOG_SERVER1)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id=server1 name="server1" size=50 maxlength=50>
		        </td>
			</tr>
			<tr>
				<td style="width:100px;">
					<script language="JavaScript">doc(SYSLOG_PORT_DST)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id=port1 name="port1" size=5 maxlength=5> (1~65535)
		        </td>
			</tr>
		</table>
		
		<br>
		<hr>
		<br>
		
		<table cellpadding="1" cellspacing="3" style="width:700px;">
			<tr>
				<td style="width:50px;">
					<script language="JavaScript">doc(IPT_FILTER_ENABLE)</script><br/>
				</td>
				<td style="width:150x;" align="left" valign="center">
					<input type="checkbox" id="stat2" name="ipt_filter_enable">
				</td>
			</tr>
			<tr>
				<td style="width:100px;">
					<script language="JavaScript">doc(SYSLOG_SERVER2)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id=server2 name="server2" size=50 maxlength=50>
		        </td>
			</tr>
			<tr>
				<td style="width:100px;">
					<script language="JavaScript">doc(SYSLOG_PORT_DST)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">
		            <input type="text" id=port2 name="port2" size=5 maxlength=5> (1~65535)
		        </td>
			</tr>
		</table>

		<br>
		<hr>
		<br>
		
		<table cellpadding="1" cellspacing="3" style="width:700px;">
			<tr>
				<td style="width:50px;">
					<script language="JavaScript">doc(IPT_FILTER_ENABLE)</script><br/>
				</td>
				<td style="width:150x;" align="left" valign="center">
					<input type="checkbox" id="stat3" name="ipt_filter_enable">
				</td>
			</tr>
			<tr>
				<td style="width:100px;">
					<script language="JavaScript">doc(SYSLOG_SERVER3)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id=server3 name="server3" size=50 maxlength=50>
		        </td>
			</tr>
			<tr>
				<td style="width:100px;">
					<script language="JavaScript">doc(SYSLOG_PORT_DST)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">
		            <input type="text" id=port3 name="port3" size=5 maxlength=5> (1~65535)
		        </td>
			</tr>
		</table>
	</DIV>
	
  	<table align="left">
    	<tr>
          	<td><script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(this.form)', 'btnU')</script></td>
		</tr>
	</table>

</fieldset>

</form>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

