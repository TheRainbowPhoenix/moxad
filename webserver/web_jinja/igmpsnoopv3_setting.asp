<html>
<head>  
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
	<script language="JavaScript" src="mdata.js"></script>
	<script type="text/javascript">
	checkCookie();
	<!--
	var PORT_DESC = [{{ net_webPortDesc() | safe }}];
	{{ net_Web_show_value("SRV_IGMPSNOOPV3_SET") | safe }}
	{{ net_Web_show_value("SRV_VLAN") | safe }}

	function tblAddForamt(idx, newdata, igmp_enable)
	{
		// Index
		newdata[0] = idx + 1;

		// Vid
		SRV_IGMPSNOOPV3_SET[idx].vid = SRV_VLAN[idx].vlanid;
		newdata[1] = SRV_IGMPSNOOPV3_SET[idx].vid;

		// Enable
		if(igmp_enable) {
			if(parseInt(SRV_IGMPSNOOPV3_SET[idx].enable) == 1)
				newdata[2] = "<input type='checkbox' name='enable' id='chk_enable_" + idx + "' onclick='tblReload();' checked>Enable";
			else
				newdata[2] = "<input type='checkbox' name='enable' id='chk_enable_" + idx + "' onclick='tblReload();'>Enable";
		}
		else {
			if(parseInt(SRV_IGMPSNOOPV3_SET[idx].enable) == 1)
				newdata[2] = "<input type='checkbox' name='enable' id='chk_enable_" + idx + "' onclick='tblReload();' checked disabled>Enable";
			else
				newdata[2] = "<input type='checkbox' name='enable' id='chk_enable_" + idx + "' onclick='tblReload();' disabled>Enable";
		}

		// Querier mode
		newdata[3] = "<table cellspacing='0' cellpadding='0'>";
		newdata[3] += "<tr><td><input type='hidden' name='querier_mode" + idx + "' id='querier_mode_" + idx + "' value='" + SRV_IGMPSNOOPV3_SET[idx].querier_mode + "'>";
		if(parseInt(SRV_IGMPSNOOPV3_SET[idx].enable) == 1) {
			if(parseInt(SRV_IGMPSNOOPV3_SET[idx].querier_mode) == 0) {
				newdata[3] += "<input type='checkbox' name='querier_mode_enable' id='chk_querier_mode_enable_" + idx + "' onclick='onQuerierModeChange(" + idx + ");'>Enable</td></tr>";
				newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v2_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='1' checked disabled>V1/V2</td></tr>";
				newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v3_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='2' disabled>V3</td></tr>";
			}
			else {
				newdata[3] += "<input type='checkbox' name='querier_mode_enable' id='chk_querier_mode_enable_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' checked>Enable</td></tr>";			
				if(parseInt(SRV_IGMPSNOOPV3_SET[idx].querier_mode) == 1) {
					newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v2_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='1' checked>V1/V2</td></tr>";
					newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v3_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='2'>V3</td></tr>";
				}
				else {
					newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v2_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='1'>V1/V2</td></tr>";
					newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v3_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='2' checked>V3</td></tr>";
				}
			}
		}
		else {
			newdata[3] += "<input type='checkbox' name='querier_mode_enable' id='chk_querier_mode_enable_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' disabled>Enable</td></tr>";
			newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v2_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='1' checked disabled>V1/V2</td></tr>";
			newdata[3] += "<tr><td><input type='radio' name='querier_mode_value" + idx + "' id='chk_querier_mode_v3_" + idx + "' onclick='onQuerierModeChange(" + idx + ");' value='2' disabled>V3</td></tr>";
		}
		newdata[3] += "</table>";

		// Static multicast querier port
		newdata[4] = "<table width='400' cellspacing='0' cellpadding='0'><tr>";
		for(var port = 0; port < PORT_DESC.length; port++) {
			if(port % 8 == 7) {
				// A new row
				newdata[4] += "</tr><tr>";
			}

			if(parseInt(SRV_IGMPSNOOPV3_SET[idx].enable) == 1) {
				if(parseInt(SRV_IGMPSNOOPV3_SET[idx]['port' + port]))
					newdata[4] += "<td><input type='checkbox' name='port" + port + "' id='chk_port" + port + "_" + idx + "' checked>" + PORT_DESC[port].index + "</td>";
				else
					newdata[4] += "<td><input type='checkbox' name='port" + port + "' id='chk_port" + port + "_" + idx + "'>" + PORT_DESC[port].index + "</td>";
			}
			else {
				if(parseInt(SRV_IGMPSNOOPV3_SET[idx]['port' + port]))
					newdata[4] += "<td><input type='checkbox' name='port" + port + "' id='chk_port" + port + "_" + idx + "' checked disabled>" + PORT_DESC[port].index + "</td>";
				else
					newdata[4] += "<td><input type='checkbox' name='port" + port + "' id='chk_port" + port + "_" + idx + "' disabled>" + PORT_DESC[port].index + "</td>";
			}
		}
		newdata[4] += "</tr></table>";
	}

	function tblInit(){
		var newdata = new Array;
		var	igmp_enable = false;

		for(var i = 0; i < SRV_VLAN.length; i++) {
			if(parseInt(SRV_IGMPSNOOPV3_SET[i].enable) == 1) {
				igmp_enable = true;
				break;
			}
		}

		// Create table
		for(var i = 0; i < SRV_VLAN.length; i++) {
			tblAddForamt(i, newdata, igmp_enable);
			tableaddRow("tbl_igmpsnoopv3", 0, newdata, "center");
		}
	}

	function tblLoad() {
		for(var i = 0; i < SRV_VLAN.length; i++) {
			// Read enable
			if(parseInt(SRV_IGMPSNOOPV3_SET[i].enable) == 1)
				document.getElementById('chk_enable_' + i).checked = true;
			else
				document.getElementById('chk_enable_' + i).checked = false;

			// Read querier mode
			if(parseInt(SRV_IGMPSNOOPV3_SET[i].querier_mode) == 0) {
				document.getElementById('chk_querier_mode_enable_' + i).checked = false;
			}
			else {
				document.getElementById('chk_querier_mode_enable_' + i).checked = true;
				if(parseInt(SRV_IGMPSNOOPV3_SET[i].querier_mode) == 1) {
					document.getElementById('chk_querier_mode_v2_' + i).checked = true;
					document.getElementById('chk_querier_mode_v3_' + i).checked = false;
				}
				else {
					 document.getElementById('chk_querier_mode_v2_' + i).checked = false;
					 document.getElementById('chk_querier_mode_v3_' + i).checked = true;
				}
			}

			// Read port settings
			for(var port = 0; port < PORT_DESC.length; port++) {
				if(parseInt(SRV_IGMPSNOOPV3_SET[i]['port' + port]) == 1)
					document.getElementById('chk_port' + port + '_' + i).checked = true;
				else
					document.getElementById('chk_port' + port + '_' + i).checked = false;
			}
		}
	}

	function tblReload() {
		// Set the UI from the settings
		if(document.getElementById('chk_igmp_enable').checked) {
			document.getElementById('txt_igmp_query_interval').disabled = false;
			for(var idx = 0; idx < SRV_VLAN.length; idx++) {
				document.getElementById('chk_enable_' + idx).disabled = false;

				document.getElementById('chk_querier_mode_enable_' + idx).disabled = false;
				document.getElementById('chk_querier_mode_v2_' + idx).disabled = false;
				document.getElementById('chk_querier_mode_v3_' + idx).disabled = false;

				// Enable ports
				for(var port = 0; port < PORT_DESC.length; port++) {
					document.getElementById('chk_port' + port + '_' + idx).disabled = true;
				}
			}
		}
		else {
			document.getElementById('txt_igmp_query_interval').disabled = true;

			for(var idx = 0; idx < SRV_VLAN.length; idx++) {
				document.getElementById('chk_enable_' + idx).disabled = true;
				document.getElementById('chk_enable_' + idx).checked = false;

				document.getElementById('chk_querier_mode_enable_' + idx).disabled = true;
				document.getElementById('chk_querier_mode_v2_' + idx).disabled = true;
				document.getElementById('chk_querier_mode_v3_' + idx).disabled = true;

				// Disable ports
				for(var port = 0; port < PORT_DESC.length; port++) {
					document.getElementById('chk_port' + port + '_' + idx).disabled = true;
				}
			}
		}

		for(var idx = 0; idx < SRV_VLAN.length; idx++) {
			if(document.getElementById('chk_enable_' + idx).checked) {
				// Enable querier mode
				document.getElementById('chk_querier_mode_enable_' + idx).disabled = false;
				if(document.getElementById('chk_querier_mode_enable_' + idx).checked) {
					document.getElementById('chk_querier_mode_v2_' + idx).disabled = false;
					document.getElementById('chk_querier_mode_v3_' + idx).disabled = false;
				}
				else {
					document.getElementById('chk_querier_mode_v2_' + idx).disabled = true;
					document.getElementById('chk_querier_mode_v3_' + idx).disabled = true;
				}

				// Enable all ports
				for(var port = 0; port < PORT_DESC.length; port++) {
					document.getElementById('chk_port' + port + '_' + idx).disabled = false;
				}
			}
			else {
				// Disable querier mode
				document.getElementById('chk_querier_mode_enable_' + idx).disabled = true;
				document.getElementById('chk_querier_mode_v2_' + idx).disabled = true;
				document.getElementById('chk_querier_mode_v3_' + idx).disabled = true;

				// Disable all ports
				for(var port = 0; port < PORT_DESC.length; port++) {
					document.getElementById('chk_port' + port + '_' + idx).disabled = true;
				}
			}
		}
	}

	function fnInit() 
	{
		// Check if the IGMP Snooping enable
		document.getElementById('chk_igmp_enable').checked = false;
		document.getElementById('txt_igmp_query_interval').value = SRV_IGMPSNOOPV3_SET[0].query_interval;
		for(var i = 0; i < SRV_VLAN.length; i++) {			
			if(SRV_IGMPSNOOPV3_SET[i].enable == 1) {
				document.getElementById('chk_igmp_enable').checked = true;				
				break;
			}
		}
		
		tblInit();
	}

	function onQuerierModeChange(idx) {
		// Set the value of 'querier_mode'
		if(document.getElementById('chk_querier_mode_enable_' + idx).checked) {
			if(document.getElementById('chk_querier_mode_v2_' + idx).checked)
				document.getElementById('querier_mode_' + idx).value = 1;
			else
				document.getElementById('querier_mode_' + idx).value = 2;

			document.getElementById('chk_querier_mode_v2_' + idx).disabled = false;
			document.getElementById('chk_querier_mode_v3_' + idx).disabled = false;
		}
		else {
			document.getElementById('querier_mode_' + idx).value = 0;

			document.getElementById('chk_querier_mode_v2_' + idx).disabled = true;
			document.getElementById('chk_querier_mode_v3_' + idx).disabled = true;
		}
	}

	function Activate(form)
	{
		// Build the post data
		var data = document.getElementById("post_data");
		data.value = "";
		for(var idx = 0; idx < SRV_VLAN.length; idx++) {
			// Vid
			data.value += (SRV_IGMPSNOOPV3_SET[idx].vid + "+");

			// Enable
			if(document.getElementById('chk_enable_' + idx).checked)
				data.value += "1+";
			else
				data.value += "0+";

			// Query interval
			data.value += document.getElementById('txt_igmp_query_interval').value + "+";

			// Querier mode
			data.value += document.getElementById('querier_mode_' + idx).value + "+";

			// Static multicast querier portmap
			for(var port = 0; port < PORT_DESC.length; port++) {
				if(document.getElementById('chk_port' + port + '_' + idx).checked)
					data.value += "1+";
				else
					data.value += "0+";
			}
		}

		form.submit();
	}
	//-->
	</script>

	<style type="text/css">
	.title1
	{
		font-family:Arial, Helvetica, sans-serif, Marlett;
		font-size:16pt;
		font-weight: bold;
		color:#007C60;
	}
	.title2
	{
		font-family:Arial, Helvetica, sans-serif, Marlett;
		font-size:12pt;
		font-weight: bold;
		color:#FF9900;
	}
	.blue
	{
		font-family:Arial, Helvetica, sans-serif, Marlett;
		font-size:8pt;
		color:#0000FF;
	}

	</style>
</head>

<body class="main" onload="fnInit()">
<h1><script language="JavaScript">doc(IGMPSNOOPV3_SETTING);</script></h1>

<form method="post" action="/goform/net_Web_get_value?SRV=SRV_IGMPSNOOPV3_SET" onkeypress="touchLasttime()" target="mid" name="frm_igmpsnoopv3_setting" id="frm_igmpsnoopv3_setting">
<fieldset>
<input type="hidden" name="SRV_IGMPSNOOPV3_SET_tmp" id="post_data" />
{{ net_Web_csrf_Token() | safe }}
<table cellpadding="2" cellspacing="1" border="0">
	<tr><td>
		<table border="0"><tr>
			<td width="200">IGMP Snooping Enable <input type="checkbox" name="enable" id="chk_igmp_enable" onclick="tblReload();" /></td>
			<td width="200">Query Interval <input type="text" size="2" name="query_interval" id="txt_igmp_query_interval" /> s</td>
			<td></td>
		</tr></table>
	</td></tr>
	<tr><td>
		<table border="0" id="tbl_igmpsnoopv3"><tr>
			<th width="50">Index</th>
			<th width="50">VID</th>
			<th width="100" class=s0>IGMP Snooping</th>
			<th width="100">Querier</th>
			<th width="400">Static Multicast Querier Port</th>
		</tr></table>
	</td></tr>
</table>
<br />
<table><tr>
	<td align="center" border="0" ><script language="JavaScript">fnbnB(Submit_, 'onClick=Activate(this.form);')</script></td>
</tr></table>
</fieldset>
</form>

</body>
</html>