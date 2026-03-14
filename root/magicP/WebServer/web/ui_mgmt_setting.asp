<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie();

debug = 0;
if (debug) {
	var wdatatype = { moxa_utility:3, telnet:3, ssh:3, http:3, https:3, telnet_port:4, ssh_port:4, http_port:4, https_port:4 };
	var wdata = [
		{ moxa_utility:1, telnet:1, ssh:1, http:1, https:1, telnet_port:23, ssh_port:22, http_port:80, https_port:443}
	]

}
else{
	<% net_Web_show_value("SRV_UI_MGMT"); %>
}

var myForm;

function fnInit() {
	myForm = document.getElementById('myForm');

	fnLoadForm(myForm, SRV_UI_MGMT, SRV_UI_MGMT_type);

	/* if(wdata[0].stat1==true){
		document.getElementById("port_limit").disabled="";
		document.getElementById("port_burst").disabled="";
	}
	else{	
		document.getElementById("port_limit").disabled="true";
		document.getElementById("port_burst").disabled="true";
	}
	if(wdata[0].stat10==true){
		document.getElementById("icmp_limit").disabled="";
		document.getElementById("icmp_burst").disabled="";
	}
	else{	
		document.getElementById("icmp_limit").disabled="true";
		document.getElementById("icmp_burst").disabled="true";
	}
	if(wdata[0].stat11==true){
		document.getElementById("syn_limit").disabled="";
		document.getElementById("syn_burst").disabled="";
	}
	else{	
		document.getElementById("syn_limit").disabled="true";
		document.getElementById("syn_burst").disabled="true";
	}
	if(wdata[0].stat12==true){
		document.getElementById("arp_limit").disabled="";
		document.getElementById("arp_burst").disabled="";
	}
	else{	
		document.getElementById("arp_limit").disabled="true";
		document.getElementById("arp_burst").disabled="true";
	}*/

	return;
}



function uiIsSettingConflict(form)
{
	var proto_ports = new Array(4);
	var pilot_port = 0;
	var i = 0, j = 0, pilot_index = 0;
	
	if(form.telnet.checked) {
		proto_ports[i] = form.telnet_port.value;
		i++;
	}

	if(form.ssh.checked) {
		proto_ports[i] = form.ssh_port.value;
		i++;
	}

	if(form.http.checked) {
		proto_ports[i] = form.http_port.value;
		i++;
	}

	if(form.https.checked) {
		proto_ports[i] = form.https_port.value;
		i++;
	}

	if(i > 1) { // multiple protocol ports setting
		for(pilot_index = 0; pilot_index < i; pilot_index++) {
			pilot_port = proto_ports[pilot_index];
			for(j = 0; j < i; j++) {
				if(pilot_index != j && (pilot_port == proto_ports[j])) {
					alert("Setting of protocol ports is conflict !");
					return 1;
				}
			}
		}
	}

	return 0;
}

function uiIsValidSetting(form)
{

	if(form.telnet.checked) {
		if(!isNumber(form.telnet_port.value)){
			alert("Telnet port must be a number and not NULL") ;
			return 0;
		}
		else{
			if(form.telnet_port.value > 65535 || form.telnet_port.value < 1){
				alert("Telnet port is invaild, the interval is from 1 to 65535 !") ;
				return 0;
			}
		}
	}

	if(form.ssh.checked) {
		if(!isNumber(form.ssh_port.value)){
			alert("SSH port must be a number and not NULL") ;
			return 0;
		}
		else{
			if(form.ssh_port.value > 65535 || form.ssh_port.value < 1){
				alert("SSH port is invaild, the interval is from 1 to 65535 !") ;
				return 0;
			}
		}
	}

	if(form.http.checked) {
		if(!isNumber(form.http_port.value)){
			alert("HTTP port must be a number and not NULL") ;
			return 0;
		}
		else{
			if(form.http_port.value > 65535 || form.http_port.value < 1){
				alert("HTTP port is invaild, the interval is from 1 to 65535 !") ;
				return 0;
			}
		}
	}

	if(form.https.checked) {
		if(!isNumber(form.https_port.value)){
			alert("HTTPS port must be a number and not NULL") ;
			return 0;
		}
		else{
			if(form.https_port.value > 65535 || form.https_port.value < 1){
				alert("HTTPS port is invaild, the interval is from 1 to 65535 !") ;
				return 0;
			}
		}
	}

	if(uiIsSettingConflict(form)) {
		return 0;
	}

	if(!isNumber(form.maxuser_http_https.value)){
		alert("Maximum Login Users For HTTP+HTTPS is invaild must be a number and not NULL") ;
		return 0;
	}
	else{
		if(form.maxuser_http_https.value > 10|| form.maxuser_http_https.value < 1){
			alert("Maximum Login Users For HTTP+HTTPS is invaild, the interval is from 1 to 10 !") ;
			return 0;
		}
	}

	if(!isNumber(form.maxuser_telnet_ssh.value)){
		alert("Maximum Login Users For Telnet+SSH must be a number and not NULL") ;
		return 0;
	}
	else{
		if(form.maxuser_telnet_ssh.value > 5 || form.maxuser_telnet_ssh.value < 1){
			alert("Maximum Login Users For Telnet+SSH, the interval is from 1 to 5 !") ;
			return 0;
		}
	}

	if(!isNumber(form.webAutoLogoutNum.value)){
		alert("Auto Logout Setting must be a number and not NULL") ;
		return 0;
	}
	else{
		if(form.webAutoLogoutNum.value > 1440 || form.webAutoLogoutNum.value < 0){
			alert("Auto Logout Setting is invaild, the interval is from 0 to 1440 !") ;
			return 0;
		}
	}

	return 1; // Valid setting
}


function Activate(form)
{	
	if(uiIsValidSetting(form)) {
		document.getElementById("btnU").disabled="true";

		form.action="/goform/net_Web_get_value?SRV=SRV_UI_MGMT";	
		form.submit();
	}
}

</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(UI_MGMT_SETTING)</script></h1>
<fieldset>
<form name="qwe" id="myForm" method="POST" action="">
	<% net_Web_csrf_Token(); %>
	<DIV style="height:350px;">
		<table cellpadding="1" cellspacing="3" style="width:500px;">

			<tr class="r0">
				<td style="width:60px;">	
					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
						<script language="JavaScript">doc(Enable_)</script>
					</font>
				</td>
				<td style="width:100x;" align="left" valign="center">
				</td>
			</tr>
			

			
			
		</table>		
		<table style="width:440px;">
			<tr>
				<td style="width:60px;" align="left" align="left">
					<input type="checkbox" id="moxa_utility" name="moxa_utility">
				</td>
				<td style="width:200x;" align="left" align="left">
					<script language="JavaScript">doc(UI_MGMT_MOXA_UTILITY)</script>
				</td>
				<td style="width:80px;" align="left" valign="center">					
					<script language="JavaScript">doc(UI_MGMT_UTILITY_PORT)</script>
				</td>
				<td style="width:100px;" align="left" valign="center">					
					<input type="text" value="4000,4001" size=10 disabled="disabled">
		        </td>
			</tr>
			
			<tr>
				<td style="width:60px;" align="left" align="left">
					<input type="checkbox" id="telnet" name="telnet">
				</td>
				<td style="width:200px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_TELNET)</script>
				</td>
				<td style="width:80px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_TELNET_PORT)</script>
				</td>
				<td  style="width:100px;" align="left" valign="center">
					<input type="text" id=telnet_port name="telnet_port" size=10 maxlength=5>
		        </td>
		        
			</tr>

			<tr >
				<td style="width:60px;" align="left" align="left">
					<input type="checkbox" id="ssh" name="ssh">
				</td>
				<td style="width:200px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_SSH)</script>
				</td>
				<td style="width:80px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_SSH_PORT)</script>
				</td>
				<td  style="width:100px;" align="left" valign="center">
					<input type="text" id=ssh_port name="ssh_port" size=10 maxlength=5>
				</td>
		        
			</tr>
			
			<tr >
				<td style="width:60px;" align="left" align="left">
					<input type="checkbox" id="http" name="http">
				</td>
				<td style="width:200px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_HTTP)</script>
				</td>
				<td style="width:80px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_HTTP_PORT)</script>
				</td>
				<td  style="width:100px;" align="left" valign="center">
					<input type="text" id=http_port name="http_port" size=10 maxlength=5>
		        </td>
		        
			</tr>

			<tr >
				<td style="width:60px;" align="left" align="left">
					<input type="checkbox" id="https" name="https">
				</td>
				<td style="width:200px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_HTTPS)</script>
				</td>
				<td style="width:80px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_SSL_PORT)</script>
				</td>
				<td style="width:100px;" align="left" valign="center"> 
					<input type="text" id=https_port name="https_port" size=10 maxlength=5>
		        </td>        
			</tr>	

            <tr style=height:40px>
                <td style="width:60px;" align="left" valign="center">
                    <input type="checkbox" id="ping_response" name="ping_response">
                </td>
				<td style="width:300px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_PING_RESPONSE_TO_WAN)</script>
				</td>
            </tr>

		</table>
		<table cellpadding="1" cellspacing="3" >
			<tr>
				<td style="width:330px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_MAX_LOGIN_USER_FOR_HTTP_HTTPS)</script>
				</td>
				<td align="left" valign="center"> 
					<input type="text" id=maxuser_http_https name="maxuser_http_https" size=10 maxlength=5> (1~10)
		        </td>    
			</tr>
			<tr>
				<td style="width:330px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_MAX_LOGIN_USER_FOR_TELNET_SSH)</script>
				</td>
				<td align="left" valign="center"> 
					<input type="text" id=maxuser_telnet_ssh name="maxuser_telnet_ssh" size=10 maxlength=5> (1~5)
		        </td>    
			</tr>
			<tr>
				<td style="width:330px;" align="left" valign="center">
					<script language="JavaScript">doc(UI_MGMT_AUTO_LOGOUT_SETTING)</script>
				</td>
				<td align="left" valign="center"> 
					<input type="text" id=webAutoLogoutNum name="webAutoLogoutNum" size=10 maxlength=5> (0~1440; 0 for Disable)
		        </td>    
			</tr>
		</table>
	</div>

</form>

<DIV style="height:30px">
	<table align="left" valign="up">
    	<tr>
          	<td><script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(myForm)', 'btnU')</script></td>
		</tr>
	</table>
</DIV>
</fieldset>
</body></html>
