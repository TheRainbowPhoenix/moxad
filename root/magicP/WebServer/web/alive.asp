<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(Alive_Name)</script></title>
<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
if (!debug) {
	var wdata = [
		{ stat1:'1', stat2:'1', ip:'0.0.0.0', interval:'180', retry:'3', timeout:'30000' }
	]
}
else{
	var wdata = [ <% net_Web_Alive_WriteValue(); %> ]
}


var addb = 'Add';
var modb = 'Modify';
var updb = 'Activate';
var delb = 'Delete';

var entryNUM=0;
<!--#include file="emalert_data"-->
var wtype = { stat1:3, stat2:3, ip:5, interval:4, retry:4, timeout:4 };

var cur_if;
 
var myForm;
function fnInit(row) {
	myForm = document.getElementById('myForm');
	EditRow(row);
	if(wdata[0].stat2==true){
		document.getElementById("ip").disabled="";
		document.getElementById("interval").disabled="";
		document.getElementById("retry").disabled="";
		document.getElementById("timeout").disabled="";
	}
	else{	
		document.getElementById("ip").disabled="true";
		document.getElementById("interval").disabled="true";
		document.getElementById("retry").disabled="true";
		document.getElementById("timeout").disabled="true";
	}
}


function EditRow(row) {
	fnLoadForm(myForm, wdata[row], wtype);
	//ChgColor('tri', wdata.length, row);
}

function Activate(form)
{
	//form.btnA.disabled = true;
	if(AliveLikeCheckFormat(form)==1) {
		//form.btnA.disabled = false;
		return;
	}
	
	document.getElementById("btnU").disabled="true";
	
	if(form.stat1.checked==true)
		wdata[0].stat1=1;
	else
		wdata[0].stat1=0;
	if(form.stat2.checked==true)
		wdata[0].stat2=1;
	else
		wdata[0].stat2=0;

	wdata[0].ip=form.ip.value;
	wdata[0].interval=form.interval.value;
	wdata[0].retry=form.retry.value;
	wdata[0].timeout=form.timeout.value;
	
	form.aliveTemp.value = form.aliveTemp.value + wdata[0].stat1 + "+";
	form.aliveTemp.value = form.aliveTemp.value + wdata[0].stat2 + "+";
	form.aliveTemp.value = form.aliveTemp.value + wdata[0].ip + "+";	
	form.aliveTemp.value = form.aliveTemp.value + wdata[0].interval + "+";	
	form.aliveTemp.value = form.aliveTemp.value + wdata[0].retry + "+";	
	form.aliveTemp.value = form.aliveTemp.value + wdata[0].timeout + "+";	

	form.submit();	
}

function ICMPCheck(CheckStat)
{
	if(CheckStat==true){
		document.getElementById("stat1").checked=false;		
		document.getElementById("ip").disabled="";
		document.getElementById("interval").disabled="";
		document.getElementById("retry").disabled="";
		document.getElementById("timeout").disabled="";
	}
	else{	
		document.getElementById("ip").disabled="true";
		document.getElementById("interval").disabled="true";
		document.getElementById("retry").disabled="true";
		document.getElementById("timeout").disabled="true";
	}
}


function LinkCheck(CheckStat)
{
	if(CheckStat==true){
		document.getElementById("stat2").checked=false;		
		document.getElementById("ip").disabled="true";
		document.getElementById("interval").disabled="true";
		document.getElementById("retry").disabled="true";
		document.getElementById("timeout").disabled="true";
	}	
}

function AliveLikeCheckFormat(form)
{
	var error=0;

	if(!IsIpOK(form.ip, 'IP')){
		error=1;
	}
	if(!IsInRange(form.interval, "Interval", 1, 1000)){
		error=1;
	}
	if(!IsInRange(form.retry, "Retry", 1, 100)){
		error=1;
	}
	if(!IsInRange(form.timeout, "Timeout", 100, 10000)){
		error=1;
	}
	if(form.timeout.value > form.interval.value*1000){
		alert(MsgHead[1]+"timeout is more than interval");
	}
	
	return error;
}

</script>
</head>
<body class=main onLoad=fnInit(0)>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[2].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[2])</script>
<script language="JavaScript">mainh()</script>	

<form name="qwe" id="myForm" method="POST" action="/goform/net_WebAliveGetValue">
	<input type="hidden" name="aliveTemp" id="aliveTemp" value="" />
	<% net_Web_csrf_Token(); %>
	
	<DIV style="height:150px;">
		<table cellpadding="1" cellspacing="3" style="width:700px;">
			
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Alive_LinkCheck)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="checkbox" id="stat1" name="ipt_filter_enable" onclick="LinkCheck(this.checked)">
		        </td>
			</tr>
			
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Alive_PingCheck)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="checkbox" id="stat2" name="ipt_filter_enable" onclick="ICMPCheck(this.checked)">
		        </td>
			</tr>

			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Alive_IP)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id="ip" name="ip" size=15 maxlength=15>
		        </td>
			</tr>
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Alive_Interval)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id="interval" name="interval" size=5 maxlength=5> sec (1~1000)
		        </td>
			</tr>
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Alive_Retry)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id="retry" name="retry" size=5 maxlength=5> (1~100)
		        </td>
			</tr>
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Alive_TimeOut)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="text" id="timeout" name="timeout" size=5 maxlength=5> ms (100~10000)
		        </td>
			</tr>
			
		</table>
	</DIV>
	
  	<table class="tf" align="center">
    	<tr>
          	<td><script language="JavaScript">fnbnBID(updb, 'onClick=Activate(this.form)', 'btnU')</script></td>
          	<td width="15"></td>
          	<td><script language="JavaScript">fnbnB(Cancel_,'onClick=location.reload()')</script></td>
		</tr>
	</table>
    
</form>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

