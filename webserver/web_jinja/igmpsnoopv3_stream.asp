<html>
<head>  
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
	<script language="JavaScript" src="mdata.js"></script>

	<script type="text/javascript">
	<!--
	var PORT_DESC = [{{ net_webPortDesc() | safe }}];
	{{ net_Web_show_value("SRV_VLAN") | safe }}

	function fnInit() 
	{
		// Build the vid selection
		for(var i = 0; i < SRV_VLAN.length; i++) {
			document.getElementById('sel_vid').options.add(new Option(SRV_VLAN[i].vlanid, i));
		}

		if(SRV_VLAN.length > 0) {
			refreshData();
		}
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
<h1><script language="JavaScript">doc(IGMPSNOOPV3_STREAM_TABLE)</script></h1>  

<script language="JavaScript">
<!--


function refreshData() {
	var vid = SRV_VLAN[document.getElementById('sel_vid').options.selectedIndex].vlanid;
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
	var rowCount = document.getElementById('tbl_stream').rows.length;
	while(rowCount > 1) {
		document.getElementById('tbl_stream').deleteRow(rowCount - 1);
		rowCount--;
	}

	http_request.onreadystatechange = function() {handle_data(http_request); };	
	http_request.open('GET', '/xml/igmpsnoopv3_stream_xml?vid=' + vid, false);
	http_request.setRequestHeader("If-Modified-Since","0");
	http_request.send(null);
}

function handle_data(http_request) {
	if (http_request.readyState == 4) {
		if (http_request.status == 200) {
			// Start pargsing
			var xmldoc = http_request.responseXML;
			var stream_node = xmldoc.getElementsByTagName('stream');

			for(var i = 0; i < stream_node.length; i++) {
				var group_node = stream_node[i].getElementsByTagName('group');
				var source_node = stream_node[i].getElementsByTagName('source');
				var port_node = stream_node[i].getElementsByTagName('port');
				var portmap_node = stream_node[i].getElementsByTagName('portmap');

				var newdata = new Array();
				newdata[0] = i + 1;
				newdata[1] = group_node[0].firstChild.data;
				newdata[2] = source_node[0].firstChild.data;
				newdata[3] = port_node[0].firstChild.data;

				newdata[4] = '';
				var portmap = parseInt(portmap_node[0].firstChild.data, 16);
				for(var port = 0, val = 1; port < PORT_DESC.length; port++, val = val << 1) {
					if(portmap & val) {
						newdata[4] += PORT_DESC[port].index + ',';
					}
				}
				
				tableaddRow("tbl_stream", 0, newdata, "center");
			}

		}
	}
}
//-->
</script>

<fieldset>
<table cellpadding="2" cellspacing="1" border="0">
	<tr>		
		<td><select id="sel_vid" onchange="refreshData();" style="display: none"></select></td>
		<td class="r0" width="5%"></td>
	</tr>
	<tr>
		
		<td>
			<table border="0" id="tbl_stream"><tr>
				<th width="50">Index</th>
				<th width="150">Stream Group</th>
				<th width="150">Stream Source</th>
				<th width="100">Port</th>
				<th width="250">Member Ports</th>
			</tr></table>
		</td>
		<td></td>
	</tr>
</table>
</fieldset>
</body>
</html>