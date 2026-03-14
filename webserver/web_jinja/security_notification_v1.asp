<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script>

checkCookie();
debug = 0;

if (debug) {
	var SRV_SECURITY_NOTIFICATION_type;
    var SRV_SECURITY_NOTIFICATION=[{event_Firewall:'1', event_DosAttack:'0', event_AccessViolation:'0'}];
} else {
    {{ net_Web_show_value('SRV_SECURITY_NOTIFICATION') | safe }}
}

function fnInit(){
    var SecurityNotificationForm;
    SecurityNotificationForm = document.getElementById('SecurityNotificationForm');
    refreshData();
    fnLoadForm(SecurityNotificationForm, SRV_SECURITY_NOTIFICATION, SRV_SECURITY_NOTIFICATION_type);
}

function refreshData(){
	//var vid = SRV_VLAN[document.getElementById('sel_vid').options.selectedIndex].vlanid;
	var http_request;

	if(window.XMLHttpRequest) { // Mozilla, Safari, ...
		http_request = new XMLHttpRequest();
	}
	else if(window.ActiveXObject) { // IE
		try {
			http_request = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				http_request = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) { }
		}
	}

    // Clear the stream table first
	var rowCount = document.getElementById('tbl_securitynotification').rows.length;

	while(rowCount > 1) {
		document.getElementById('tbl_securitynotification').deleteRow(rowCount - 1);
		rowCount--;
	}

	http_request.onreadystatechange = function() {handle_data(http_request); };	
	http_request.open('GET', '/xml/web_RefreshSecurityNotificationStatus', false);
	http_request.setRequestHeader("If-Modified-Since","0");
	http_request.send(null);
}

function Refresh_Status(){
    refreshData();
}

function handle_data(http_request) {
	if (http_request.readyState == 4) {
		if (http_request.status == 200) {
			// Start pargsing
			var xmldoc = http_request.responseXML;
			var securitynotification_node = xmldoc.getElementsByTagName('securitynotification');

			for(var i = 0; i < securitynotification_node.length; i++){
				var name_node = securitynotification_node[i].getElementsByTagName('name');
                var status_node = securitynotification_node[i].getElementsByTagName('status')

				var newdata = new Array();
				newdata[0] = name_node[0].firstChild.data;
				newdata[1] = status_node[0].firstChild.data;
				newdata[2] = '';
				tableaddRow("tbl_securitynotification", 0, newdata, "center");
			}
			setTimeout("refreshData()",10000);
		}
	}
}

function AckStatus(form){
    form.action="/goform/web_AckSecurityNotificationStatus";
    form.submit();
}

function Activate(form)
{
	var i, j;
    var alert_msg="";

    if(document.getElementById('event_Firewall').checked == true)
        alert_msg = alert_msg + "Firewall ";
    if(document.getElementById('event_DoSAttack').checked==true)
        alert_msg = alert_msg + "DoS ";
    if(document.getElementById('event_AccessViolation').checked==true)
        alert_msg = alert_msg + "Trsuted Access.";

    alert("Need to enable "+alert_msg+"log function");

	form.SRV_SECURITY_NOTIFICATION_tmp.value = "";
	
    for(i in SRV_SECURITY_NOTIFICATION){
		for(j in SRV_SECURITY_NOTIFICATION[i]){
			form.SRV_SECURITY_NOTIFICATION_tmp.value = form.SRV_SECURITY_NOTIFICATION_tmp.value + SRV_SECURITY_NOTIFICATION[i][j] + "+";
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_SECURITY_NOTIFICATION";
	form.submit();	
}

</script>
</head>

<body onLoad = fnInit()>
<h1><script language="JavaScript">doc(_Security_Notification_Setting)</script></h1>
<fieldset style="width:700px">
<form id="SecurityNotificationForm" method="POST" action="">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="SRV_SECURITY_NOTIFICATION_tmp" id="SRV_SECURITY_NOTIFICATION_tmp" value=""></input>
    <table cellpadding="1" cellspacing="3">
        <tr class="r0">
		    <td>
				<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
					<script language="JavaScript">doc(Enable_)</script>
				</font>
			</td>
		</tr>
	</table>

	<table cellpadding="1" cellspacing="3">
		<tr>
			<td style="width:20%">
				<input type="checkbox" id="event_Firewall" name="event_Firewall">
			</td>
			<td align="left" valign="center">
				<script language="JavaScript">doc(_Security_Notification_Firewall)</script>
			</td>
		</tr>
		<tr>
			<td style="width:20%">
				<input type="checkbox" id="event_DoSAttack" name="event_DoSAttack">
			</td>
			<td align="left" valign="center">
				<script language="JavaScript">doc(_Security_Notification_DoSAttack)</script>
			</td>
		</tr>

		<tr >
			<td style="width:20%">
                   <input type="checkbox" id="event_AccessViolation" name="event_AccessViolation">
			</td>
			<td align="left" valign="center">
				<script language="JavaScript">doc(_Security_Notification_AccessViolation)</script>
			</td>
		</tr>
		<tr >
			<td style="width:20%">
				<input type="checkbox" id="event_LoginFail" name="event_LoginFail">
			</td>
			<td align="left" valign="center">
				<script language="JavaScript">doc(_Security_Notification_LoginFail)</script>
			</td>
		</tr>
	</table>

    <table cellpadding="1" cellspacing="3" style="width:100%">
   	    <tr>
       	    <td><script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(SecurityNotificationForm)', 'btnU')</script></td>
   		</tr>
    </table>
    <table cellpadding="1" cellspacing="3" style="width:100%">
	    <tr class="r0">
			<td>
				<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
					<script language="JavaScript">doc(_Security_Notification_Status)</script>
				</font>
			</td>
			<td align="right">
        	    (<script language="JavaScript">doc(_Security_Notification_Refresh_Interval)</script>)
			</td>
		</tr>
	</table>
        
	<table cellpadding="1" cellspacing="3" id="tbl_securitynotification" style="width:100%">
        <tr>
            <th width="50%"><script language="JavaScript">doc(Event_)</script></th>
            <th width="50%"><script language="JavaScript">doc(Status_)</script></th>
        </tr>
    </table>

    <table cellpadding="1" cellspacing="3" style="width:100%">
        <tr>
            <td><script language="JavaScript">fnbnBID(ACK_, 'onClick=AckStatus(SecurityNotificationForm)', 'btnU')</script></td>
        </tr>
	</table>
</form>
</fieldset>
</body>
