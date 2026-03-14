<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = [
		{ stat1:1, stat2:1, stat3:1, timer:100 }
	]
}
else{
	var wdata = [ <% net_Web_Confirm_WriteValue(); %> ]
	var NoWAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
	var NoMAC_PORT = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %> ;
	var SWITCH_ROUTER=(parseInt((NoWAN+1)) > parseInt(NoMAC_PORT));	
}



var NetworkMode = <% net_Web_GetMode_WriteValue(); %>;

var entryNUM=0;
<!--#include file="emalert_data"-->
var wtype = { stat1:3, stat2:3, stat3:3, stat4:3, timer:4 };

var cur_if;
 
var myForm;
function fnInit(row) {
	myForm = document.getElementById('myForm');
	EditRow(row);
	if(NetworkMode == 0){	// router mode
		document.getElementById("stat4").disabled="true";
	}
	else{
		document.getElementById("stat4").disabled="";
	}
	if(SWITCH_ROUTER){
		document.getElementById("l2_confirm").style.display="none";
	}
}


function EditRow(row) {

	fnLoadForm(myForm, wdata[row], wtype);
	//ChgColor('tri', wdata.length, row);
}

function Activate(form)
{	
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

	if(NetworkMode == 1){	// bridge mode
		if(form.stat4.checked==true)
			wdata[0].stat4=1;
		else
			wdata[0].stat4=0;
	}
	
	wdata[0].timer = form.timer.value;
	if (!IsInRange(form.timer, TIMER_CONFIRM, 10, 3600))
		return;

	form.confirmTemp.value = form.confirmTemp.value + wdata[0].stat1 + "+";
	form.confirmTemp.value = form.confirmTemp.value + wdata[0].stat2 + "+";
	form.confirmTemp.value = form.confirmTemp.value + wdata[0].stat3 + "+";
	form.confirmTemp.value = form.confirmTemp.value + wdata[0].stat4 + "+";
	form.confirmTemp.value = form.confirmTemp.value + wdata[0].timer + "+";		

	if(AuthUser=='admin')
		form.submit();	
}





</script>
</head>
<body onLoad=fnInit(0)>

<h1><script language="JavaScript">doc(CONFIRM)</script></h1>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[2].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[2])</script>
<script language="JavaScript">mainh()</script>	

<form name="qwe" id="myForm" method="POST" action="/goform/net_WebConfirmGetValue">
<% net_Web_csrf_Token(); %>
<fieldset>
	<input type="hidden" name="confirmTemp" id="confirmTemp" value="" />

	<div>
		<table cellpadding="1" cellspacing="3" style="width:400px;">	
			<tr>
				<td style="width:50x;" align="left" valign="center">
					<script language="JavaScript">doc(FILTER_CONFIRM)</script>
				</td>
				<td align="left" valign="center">
					<input type="checkbox" id="stat1" name="stat1">
				</td>
				
			</tr>
			
			<tr>
				<td style="width:50x;" align="left" valign="center">
					<script language="JavaScript">doc(NAT_CONFIRM)</script>
				</td>
				<td align="left" valign="center">
					<input type="checkbox" id="stat2" name="stat2">
				</td>
			</tr>

			<tr>
				<td style="width:50x;" align="left" valign="center">
					<script language="JavaScript">doc(ACCESS_CONFIRM)</script>
				</td>
				<td align="left" valign="center">
					<input type="checkbox" id="stat3" name="stat3">
				</td>
			</tr>

			<tr id="l2_confirm">
				<td style="width:50x;" align="left" valign="center">
					<script language="JavaScript">doc(LAYER2_CONFIRM)</script>
				</td>
				<td align="left" valign="center">
					<input type="checkbox" id="stat4" name="stat4"> <script language="JavaScript">doc(WORK_IN_BRIDGE_MODE)</script>
				</td>
			</tr>

			<tr>
				<td style="width:50x;" align="left" valign="center">
					<script language="JavaScript">doc(TIMER_CONFIRM)</script>
				</td>
				<td  align="left" valign="center">  
		            <input type="text" id=timer name="timer" size=5 maxlength=5>(sec)
		        </td>
				
			</tr>	
		</table>
	</div>
	<div>
	<table align="left" valign="up">
    	<tr>
          	<td><script language="JavaScript">fnbnB(APPLY_, 'onClick=Activate(myForm)')</script></td>
		</tr>
	</table>
	</div>
</fieldset>

</form>


<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

