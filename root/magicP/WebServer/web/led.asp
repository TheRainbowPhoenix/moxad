<html>
<head>
<% net_Web_file_include(); %>
<HTML><HEAD><TITLE>Status</TITLE>
<script language="JavaScript" src=mdata.js></script>
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
<script language="JavaScript">
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
var hw_version = <% net_Web_GetVERSION_HW_WriteValue(); %>;

if (!debug) {

	var wdata = {
			eth0:'192.168.127.254',eth1:'192.168.2.100',eth2:'61.62.63.64',pw1:'0',pw2:'1',thermal:'45',fault_led:'0'
		};
	var wdata1 = {
			model:'EDR-G903', mac1:'00-90-E8-00-00-02', mac2:'00-90-E8-00-00-03',serial:'1234',fw_ver:'V1.0 build 09012219'
		};
}else{
		var wdata = {//data can be changed depend on situation
			<%net_webledset1();%>	
		};
		var wdata1 = {//data is static
			<%net_webledset2();%>	
		};
}


function setformdata(type){
	var i, idx;
	var flag = 0;
	if(type == 0){
		for(i in wdata1){
			document.getElementsByName(i)[hw_version-1].innerHTML 	= 	wdata1[i];
		}
		/*document.getElementById("model").innerHTML 	= 	wdata1.model;
		document.getElementById("mac0").innerHTML 	= 	wdata1.mac0;
		document.getElementById("mac1").innerHTML 	= 	wdata1.mac1;
		document.getElementById("mac2").innerHTML 	= 	wdata1.mac2;
		document.getElementById("serial").innerHTML 	= 	wdata1.serial;
		document.getElementById("fw_ver").innerHTML 	= 	wdata1.fw_ver;		*/
	}
	for(i in wdata){		
		//alert(wdata[i]);
		/*if(document.getElementById(i)==null){
			continue;
		}
		if(wdata[i]=="hidden"){
			flag = 1;			
			//document.getElementById(i).style.display = 'none';
			document.getElementById(i).innerHTML = '';
		}else{			
			document.getElementById(i).style.display = '';
			document.getElementById(i).innerHTML = wdata[i];
		}*/
		if(document.getElementsByName(i).length==0){
			continue;
		}
		
		if(document.getElementsByName(i).length > 1){
			idx = hw_version-1;
		}else{
			idx=0;
		}
		
		
		if(wdata[i]=="hidden"){
			flag = 1;			
			//document.getElementById(i).style.display = 'none';
			document.getElementsByName(i)[idx].innerHTML = '';
		}else{
			document.getElementsByName(i)[idx].style.display = '';
			document.getElementsByName(i)[idx].innerHTML = wdata[i];
		}

		
	}
	if(flag==1){
		for(var idx=0; idx < document.getElementsByName("wan").length;idx++){
			//document.getElementsByName("wan")[idx].style.display = (flag==1)?'none':'';
			document.getElementsByName("wan")[idx].innerHTML = '';
		}
	}
	/*document.getElementById("eth2").innerHTML 	= 	wdata.eth2;
	document.getElementById("eth1").innerHTML 	= 	wdata.eth1;
	document.getElementById("eth0").innerHTML 	= 	wdata.eth0;		
	document.getElementById("pw1").innerHTML  	= 	wdata.pw1 == 	   '1'?"<img border=\"0\" src=\"image\/LED-Yellow.jpg\" width=\"13\" height=\"6\">":"<img border=\"0\" src=\"image\/orange.jpg\" width=\"13\" height=\"6\">";
	document.getElementById("pw2").innerHTML  	= 	wdata.pw2 == 	   '1'?"<img border=\"0\" src=\"image\/LED-Yellow.jpg\" width=\"13\" height=\"6\">":"<img border=\"0\" src=\"image\/orange.jpg\" width=\"13\" height=\"6\">";
	document.getElementById("fault_led").innerHTML  = 	wdata.fault_led == '1'?"<img border=\"0\" src=\"image\/LED-Red.jpg\" width=\"13\" height=\"6\">":"<img border=\"0\" src=\"image\/orange.jpg\" width=\"13\" height=\"6\">";	*/
}

function fnInit() {
	var panel_system;
	if(hw_version==2){
		panel_system=document.getElementById("HW_2").style;
	}else{
		hw_version =1;
		panel_system=document.getElementById("HW_1").style;		
	}
	panel_system.display="";
	setformdata(0);	
	makeRequest("/xml/net_led_xml", LedReqContents ,0);		
}


function LedReqContents(http_request) {
	var nm, data;		
	var xmldoc;			
    if (http_request.readyState == 4) {
		if (http_request.status == 200) {			
			//xmldoc = http_request.responseText;
			//alert(xmldoc);
			xmldoc = http_request.responseXML;	
			var logoutTime=$(xmldoc).find('Auto-Logout_Time').text();
			web_cookie_create("Auto-Logout_Time",logoutTime);		
			//alert(xmldoc.getElementsByTagName('eth0').length);
			//alert(xmldoc.getElementsByTagName('eth0')[0].firstChild.nodeValue);
			for(nm in wdata){
				if(xmldoc.getElementsByTagName(nm)[0] == null){
					continue;
				}
				wdata[nm] = xmldoc.getElementsByTagName(nm)[0].firstChild.nodeValue;
			}
			setformdata(1);
			//alert("alertContents before");
			setTimeout("makeRequest('/xml/net_led_xml', LedReqContents ,0);",1000);
			//alert("alertContents after");
		} else {
			//alert('There was a problem with the request.');
				
			for(nm in wdata){				
				wdata[nm] = 'Connecting.........';				
			}
			setformdata(1);
			setTimeout("makeRequest('/xml/net_led_xml', LedReqContents ,0);",1000);
		}
	}
}

function ShowIp() {
	var i, len, str;
	len=0;
	for(i in wdata){
		if(i.substring(0,3)=='eth'){
			len++;
		}
	}

	for(i=0; i < len; i++){
		if(i=='0'){
			str = '<td><li>LAN IP</li></td>';
		}else{			
			str = '<td><li>WAN';
			if(len>2){
				str+=(len-i);
			}
			str+=' IP</li></td>';
		}
        if(i == '0'){
            if(wdata.mode == 'bridge'){
        		document.write(str);
           	   	str = '<td name = br'+i+'>-&nbsp;192.168.126.254</td>';
            }else{
        		document.write(str);
          	   	str = '<td name = eth'+i+'>-&nbsp;192.168.127.254</td>';
            }
        }
        else{
     		document.write(str);
	    	str = '<td name = eth'+i+'>-&nbsp;192.168.127.254</td>';
        }
		
    	document.write(str);	
	}
	for(i=0; i < 4-len*2; i++ ){
		document.write('<td></td>');
	}
	
}

function ShowWanIp() {
	var count,i;
	for(i in wdata){
		if(i.substring(0, 3)=="mac")
			count++;
	}
	if(count > 2){
		for(i=0; i < count; i++){
			document.write('<td id="wan"><li>WAN'+i+1+' IP</li></td>');
			document.write('<td name = eth2>-&nbsp;192.168.'+2+i+'.254</td>');
		}
	}else{
		document.write('<td id="wan"><li>WAN IP</li></td>');
		document.write('<td name = eth1>-&nbsp;192.168.2.254</td>');
	}
	
	/*if(ProjectModel == MODEL_EDR_G903){
		document.write('<td id="wan"><li>WAN1 IP</li></td>');
		document.write('<td name = eth2>-&nbsp;192.168.2.254</td>');
		document.write('<td id="wan"><li>WAN2 IP</li></td>');
		document.write('<td name = eth1>-&nbsp;192.168.3.254</td>');
	}
	else{
		document.write('<td id="wan"><li>WAN IP</li></td>');
		document.write('<td name = eth1>-&nbsp;192.168.2.254</td>');
	}*/
}

function ShowLanIp() {
	var count,i;
	for(i in wdata){
		if(i.substring(0, 3)=="mac")
			count++;
	}
	document.write('<td><li>LAN IP</li></td>');
	document.write('<td name = eth0>-&nbsp;192.168.127.254</td>');
	for(i=count; i < 3; i++){
		document.write('<td></td>');
		document.write('<td></td>');
	}
	/*if(ProjectModel == MODEL_EDR_G903){
		document.write('<td><li>LAN IP</li></td>');
		document.write('<td name = eth0>-&nbsp;192.168.127.254</td>');
	}
	else{
		document.write('<td><li>LAN IP</li></td>');
		document.write('<td name = eth0>-&nbsp;192.168.127.254</td>');
		document.write('<td></td>');
		document.write('<td></td>');
	}*/
}

function ShowMac() {	
	var i, len, str;
	len=0;
	for(i in wdata1){
		if(i.substring(0,3)=='mac'){
			len++;
		}
	}
	for(i=0; i < len; i++){
		if(i=='0'){
			str = '<td><li>LAN MAC</li></td>';
		}else{
			str = '<td><li>WAN'+(len-i)+' MAC</li></td>';
		}
		document.write(str);
		str = '<td name = mac'+i+'>-&nbsp;00:90:E8:00:00:0'+i+'</td>';
		document.write(str);	
	}
	if(len < 6-len*2){
		for(i=0; i < 6-len*2; i++ ){
			document.write('<td></td>');
		}
	}
}


function ShowWanMac() {	

	if(ProjectModel == MODEL_EDR_G903){
		document.write('<td><li>WAN1 MAC</li></td>');
		document.write('<td name = mac2>-&nbsp;00:90:E8:00:00:01</td>');
		document.write('<td><li>WAN2 MAC</li></td>');
		document.write('<td name = mac1>-&nbsp;00:90:E8:00:00:02</td>');
	}
	else{
		document.write('<td><li>WAN MAC</li></td>');
		document.write('<td name = mac1>-&nbsp;00:90:E8:00:00:01</td>');
	}
}

function ShowLanMac() {	
	if(ProjectModel == MODEL_EDR_G903){
		document.write('<td><li>LAN MAC</li></td>');
		document.write('<td name = mac0>-&nbsp;00:90:E8:00:00:03</td>');
	}
	else{
		document.write('<td><li>LAN MAC</li></td>');
		document.write('<td name = mac0>-&nbsp;00:90:E8:00:00:03</td>');
		document.write('<td></td>');
		document.write('<td></td>');
	}
}


//JustinJZ

function ShowUsbStatus(){
    document.write('<td><li>ABC-02-USB-T</li></td>');
    document.write('<td name = usb_ready></td>');
}


function ShowUSBStatus_LED(){
    document.write('<td>STATE</td>');
    document.write('<td name = usb_led></td>');
}



</script>
	<STYLE type="TEXT/CSS">

	body {
		background-image:url(image/status_bg.jpg);
		font-family:arial;
		background-repeat:repeat-x;
	}
		
	ul {
		list-style-type:none;
		margin-left:0px;
		margin-top:15px;
		text-indent: 10px;
	}
	
	li {
		list-style-type:none;
		
		background-image:url(image/status_node.jpg);
		background-repeat:no-repeat;
		background-position:0 0.4em;
		padding-left:0px;
		font-size: 8.67pt;
		color: #FFFFFF;
		font-weight: bold;
		text-indent: 10px;
	}

	table {
		font-size: 8.67pt;
		color: #FFFFFF;
		height: 45px;
		width: 100%;
		border-collapse: collapse;
	}		
	</STYLE>
</HEAD>

<BODY style="margin:0px; padding-top: 5px" onLoad=fnInit()>

<table id="HW_1" style="display:none;">
	<tr>
		<td width="11%"><li>Device Name</li></td>
		<td width="18%" name = devname>-&nbsp;</td>
		<td width="11%"><li>Serial NO.</li></td>
		<td width="13%" name = serial>-&nbsp;</td>
		<td width="11%"><li>Firmware</li></td>
		<td width="18%" name = fw_ver>-&nbsp;</td>
		<td width="5%">PWR 1</td>
		<td width="4%" name = pw1><img border="0" src="image/orange.jpg" width="13" height="6"></td>
		<td width="5%">MSTR</td>
		<td width="4%" name = master_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>
	</tr>
	<tr>
		<script language="JavaScript">ShowMac()</script>
		<!--script language="JavaScript">ShowWanMac()</script>
		<script language="JavaScript">ShowLanMac()</script-->
		<td>PWR 2</td>
		<td name = pw2><img border="0" src="image/orange.jpg" width="13" height="6"></td>
		<td>CPLR</td>
		<td name = coupling_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>
	</tr>
	<tr>
		<script language="JavaScript">ShowIp()</script>
		<script language="JavaScript">ShowUsbStatus()</script>

		<!--script language="JavaScript">ShowWanIp()</script>
		<script language="JavaScript">ShowLanIp()</script-->
		<td>FAULT</td>
		<td name = fault_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>
		<script language="JavaScript">ShowUSBStatus_LED()</script>
	</tr>
</table>

<table id="HW_2" style="display:none;">
	<tr>
		<td width="11%"><li>Device Name</li></td>
		<td width="18%" name = devname>-&nbsp;</td>
		<td width="11%"><li>Serial NO.</li></td>
		<td width="13%" name = serial>-&nbsp;</td>
		<td width="11%"><li>Firmware</li></td>
		<td width="9%" name = fw_ver>-&nbsp;</td>
		<td width="5%">PWR 1</td>
		<td width="4%" name = pw1><img border="0" src="image/orange.jpg" width="13" height="6"></td>
		<td width="5%">FAULT</td>
		<td width="4%" name = fault_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>
		<td width="5%">VRRP.M</td>
		<td width="4%" name = vrrp_m_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>
	</tr>
	<tr>
		<script language="JavaScript">ShowMac()</script>
		<td>PWR 2</td>
		<td name = pw2><img border="0" src="image/orange.jpg" width="13" height="6"></td>
		<td>MSTR</td>
		<td name = master_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>
		<td>VPN</td>
		<td name = vpn_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>
	</tr>
	<tr>
		<script language="JavaScript">ShowIp()</script>
		<script language="JavaScript">ShowUsbStatus()</script>
		<script language="JavaScript">ShowUSBStatus_LED()</script>
		<td>CPLR</td>
		<td name = coupling_led><img border="0" src="image/orange.jpg" width="13" height="6"></td>		
	</tr>
</table>


</BODY>
</HTML>
