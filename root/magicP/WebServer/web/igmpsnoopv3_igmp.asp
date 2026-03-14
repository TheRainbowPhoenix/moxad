<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">

	<script language="JavaScript" src="mdata.js"></script>
	<script type="text/javascript">
	<!--
	<% net_Web_show_value("SRV_VLAN"); %>
    <% net_Web_show_value("SRV_VPLAN");%>

	var PORT_DESC = [<% net_webPortDesc(); %>];
    var used_vid = new Array(SRV_VPLAN.length);
    for(i =0; i< SRV_VPLAN.length; i++){
        used_vid[i]=0;
    }

    var index = 1;
    function check_vid_bridge(vid){
        var k,j;
        var pvid_for_brg = 0;
        for(k=0; k<SRV_VPLAN.length; k++){
            if(vid == SRV_VPLAN[k].pvid){
                if(SRV_VPLAN[k].bridge_group_id != 0 ){
                    pvid_for_brg = 0;
                    break;
                }
                else{
                    for(j=0; j < SRV_VPLAN.length; j++){
                        if(used_vid[j] == 0){
                            used_vid[j] = vid;
                            pvid_for_brg = 1;
                            break;
                        }
                        else{
                            if(vid == used_vid[j]){
                                pvid_for_brg = 0;
                                break;
                            }
                        }
                    break;
                    }
                }
            }
            else{
                pvid_for_brg  = 1;
            }
        }
        return pvid_for_brg;
    }

	function fnInit()
	{
		// Build the vid selection
		for(var i = 0; i < SRV_VLAN.length; i++) {
            if(check_vid_bridge(SRV_VLAN[i].vlanid)){
			    document.getElementById('sel_vid').options.add(new Option(SRV_VLAN[i].vlanid, i));
            }
		}

		if(SRV_VLAN.length > 0) {
			refreshData();
		}
	}
	//-->
	</script>

</head>

<body onload="fnInit()">
<h1><script language="JavaScript">doc(IGMPSNOOPV3_IGMP_TABLE)</script></h1>
<script language="JavaScript">



function refreshData() {
	var http_request = new Array();
	var vid = SRV_VLAN[document.getElementById('sel_vid').options.selectedIndex].vlanid;

	// Clear the group table first
	var rowCount = document.getElementById('tbl_group').rows.length;

	for(var i = 0; i < 2; i++) {
		if(window.XMLHttpRequest) { // Mozilla, Safari, ...
			http_request[i] = new XMLHttpRequest();
		}
		else if(window.ActiveXObject) { // IE
			try {
				http_request[i] = new ActiveXObject("Msxml2.XMLHTTP");
			} catch (e) {
				try {
					http_request[i] = new ActiveXObject("Microsoft.XMLHTTP");
				} catch (e) { }
			}
		}
	}

	while(rowCount > 1) {
		document.getElementById('tbl_group').deleteRow(rowCount - 1);
		rowCount--;
	}

	// Clear the querier table
	document.getElementById('tbl_querier_as_querier').innerHTML = '';
	document.getElementById('tbl_querier_static_mcast_port').innerHTML = '';
	document.getElementById('tbl_querier_mcast_router_port').innerHTML = '';
	document.getElementById('tbl_querier_querier_connect_port').innerHTML = '';

	// Request the group data
   	http_request[0].onreadystatechange = function() {handle_group_data(http_request[0]); };
	http_request[0].open('GET', '/xml/igmpsnoopv3_group_xml?vid=' + vid, false);
	http_request[0].setRequestHeader("If-Modified-Since","0");
	http_request[0].send(null);

	// Request the querier data
   	http_request[1].onreadystatechange = function() {handle_querier_data(http_request[1]); };
	http_request[1].open('GET', '/xml/igmpsnoopv3_querier_xml?vid=' + vid, false);
	http_request[1].setRequestHeader("If-Modified-Since","0");
	http_request[1].send(null);
}

function handle_group_data(http_request) {
	if (http_request.readyState == 4) {
		if (http_request.status == 200) {
			// Start pargsing
			var xmldoc = http_request.responseXML;
			var group_node = xmldoc.getElementsByTagName('group');

			for(var i = 0; i < group_node.length; i++) {
				var addr_node = group_node[i].getElementsByTagName('addr');
				var port_node = group_node[i].getElementsByTagName('port');
				var version_node = group_node[i].getElementsByTagName('version');
				var filter_node = group_node[i].getElementsByTagName('filter');
				var source_node = group_node[i].getElementsByTagName('source');

				var newdata = new Array();
				newdata[0] = i + 1;
				newdata[1] = addr_node[0].firstChild.data;
				newdata[2] = port_node[0].firstChild.data;
				newdata[3] = version_node[0].firstChild.data;
				if(filter_node[0].firstChild)
					newdata[4] = filter_node[0].firstChild.data;
				if(source_node[0].firstChild)
					newdata[5] = source_node[0].firstChild.data;

				tableaddRow("tbl_group", 0, newdata, "center");
			}

		}
	}
}

function handle_querier_data(http_request) {

	if (http_request.readyState == 4) {

		if (http_request.status == 200) {
			// Start pargsing
			var xmldoc = http_request.responseXML;
			var igmp_node = xmldoc.getElementsByTagName('igmpsnoopv3');

			if(igmp_node.length > 0) {
				var querier_node = igmp_node[0].getElementsByTagName('querier');
				var static_portmap_node = igmp_node[0].getElementsByTagName('static_portmap');
				var learned_portmap_node = igmp_node[0].getElementsByTagName('learned_portmap');
				var querier_portmap_node = igmp_node[0].getElementsByTagName('querier_portmap');
				var querier_elected_ip_node = igmp_node[0].getElementsByTagName('elected_ip');
				var nonquerier_elected_ip_node = igmp_node[0].getElementsByTagName('learned_ip');

					if(parseInt(querier_node[0].firstChild.data))
						document.getElementById('tbl_querier_as_querier').innerHTML = 'Yes';
					else
						document.getElementById('tbl_querier_as_querier').innerHTML = 'No';

					var portmap;
					if( static_portmap_node[0].firstChild != null ){
						portmap = parseInt(static_portmap_node[0].firstChild.data, 16);

						for(var port = 0, val = 1; port < PORT_DESC.length; port++, val = val << 1) {
							if(portmap & val) {
								document.getElementById('tbl_querier_static_mcast_port').innerHTML += PORT_DESC[port].index + ',';
							}
						}
					}
					if( learned_portmap_node[0].firstChild != null ){
						var igmp_nonquerier_elected_ip = nonquerier_elected_ip_node[0].firstChild.data;
						portmap = parseInt(learned_portmap_node[0].firstChild.data, 16);
						for(var port = 0, val = 1; port < PORT_DESC.length; port++, val = val << 1) {
							if(portmap & val) {
								document.getElementById('tbl_querier_mcast_router_port').innerHTML += PORT_DESC[port].index + '(' + parseInt(igmp_nonquerier_elected_ip.split(' ')[0],16)+ '.' + parseInt(igmp_nonquerier_elected_ip.split(' ')[1],16) +'.'+ parseInt(igmp_nonquerier_elected_ip.split(' ')[2],16) +'.'+ parseInt(igmp_nonquerier_elected_ip.split(' ')[3],16) + ')';
							}
						}
					}
					if( querier_portmap_node[0].firstChild != null ){
						portmap = parseInt(querier_portmap_node[0].firstChild.data, 16);
						var igmp_querier_elected_ip = querier_elected_ip_node[0].firstChild.data;
						for(var port = 0, val = 1; port < PORT_DESC.length; port++, val = val << 1) {
							if(portmap & val) {
								document.getElementById('tbl_querier_querier_connect_port').innerHTML += PORT_DESC[port].index + '(' + parseInt(igmp_querier_elected_ip.split('.')[0],16)+ '.' + parseInt(igmp_querier_elected_ip.split(' ')[1],16) +'.'+ parseInt(igmp_querier_elected_ip.split(' ')[2],16) +'.'+ parseInt(igmp_querier_elected_ip.split(' ')[3],16) + ')';
							}
						}
					}

			}
		}
	}
}
//-->
</script>

<fieldset>
<table cellpadding="2" cellspacing="1" border="0">
	<tr>
		<td class="r0" width="5%">VID:</td>
		<td><select id="sel_vid" onchange="refreshData();"></select></td>
		<td class="r0" width="5%"></td>
	</tr>
	<tr>
		<td></td>
		<td>
			<table border="0" id="tbl_querier">
				<tr>
					<th width="200">Auto Learned Multicast Router Port</th>
					<th width="150">Static Multicast Router Port</th>
					<th width="150">Querier Connected Port</th>
					<th width="200">Act as Querier</th>
				</tr>
				<tr>
					<td id="tbl_querier_mcast_router_port"></td>
					<td id="tbl_querier_static_mcast_port"></td>
					<td id="tbl_querier_querier_connect_port"></td>
					<td id="tbl_querier_as_querier"></td>
				</tr>
			</table>
			<br />
			<table border="0" id="tbl_group"><tr>
				<th width="50">Index</th>
				<th width="150">Group</th>
				<th width="100">Port</th>
				<th width="120">Version</th>
				<th width="120">Filter Mode</th>
				<th width="160">Sources</th>
			</tr></table>
		</td>
		<td></td>
	</tr>
</table>
</fieldset>
</body>
</html>
