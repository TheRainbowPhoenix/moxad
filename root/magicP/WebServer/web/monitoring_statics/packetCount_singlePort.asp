<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../main_style.css">
<script type="text/javascript" src="../jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="../moxa_common.js"></script>
<script language="JavaScript">

	var http_request;
	var port=0;
	var old_TxTotal=0, old_TxUnicast=0, old_TxBroadcast=0, old_TxMulticast=0, old_TxCollision=0,
		old_RxTotal=0, old_RxUnicast=0, old_RxBroadcast=0, old_RxMulticast=0, old_RxPause=0,
		old_Late=0, old_Excessive=0, old_CRCError=0, old_Discard=0, old_Undersize=0, old_Fragments=0, old_Oversize=0, old_Jabber=0;

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

	Request = {
        QueryString : function( key ){
            var svalue = location.search.match( new RegExp( "[\?\&]" + key + "=([^\&]*)(\&?)", "i" ) );
            return svalue ? svalue[1] : svalue;
        }
    };


	function CounterString_get(newValue,oldValue){
		var retString;

		if((newValue-oldValue)>0){
			retString = newValue + "+" + String(parseInt(newValue)-parseInt(oldValue));
		}else{
			retString = newValue + "+ 0";
		}
		
		return retString;
	}
		
	function refreshStatisticsData()
	{
		http_request.onreadystatechange = function()
		{
			if (http_request.readyState == 4) {
				if (http_request.status == 200) {
					
					// Start parsing
					var xmldoc = http_request.responseXML;
					var root_node = xmldoc.getElementsByTagName('port_statistics');
					var data_node, item, value;

					if(root_node.length > 0)
					{
						// TX
						data_node = root_node[0].getElementsByTagName('TxTotal');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_TxTotal');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_TxTotal);
							old_TxTotal = value;
						}

						data_node = root_node[0].getElementsByTagName('TxUnicast');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_TxUnicast');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_TxUnicast);							
							old_TxUnicast = value;
						}

						data_node = root_node[0].getElementsByTagName('TxBroadcast');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_TxBroadcast');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_TxBroadcast);							
							old_TxBroadcast = value;
						}

						data_node = root_node[0].getElementsByTagName('TxMulticast');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_TxMulticast');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_TxMulticast);							
							old_TxMulticast = value;
						}

						data_node = root_node[0].getElementsByTagName('TxCollision');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_TxCollision');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_TxCollision);							
							old_TxCollision = value;
						}
						
						// RX
						data_node = root_node[0].getElementsByTagName('RxTotal');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_RxTotal');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_RxTotal);							
							old_RxTotal = value;
						}

						data_node = root_node[0].getElementsByTagName('RxUnicast');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_RxUnicast');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_RxUnicast);							
							old_RxUnicast = value;
						}

						data_node = root_node[0].getElementsByTagName('RxBroadcast');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_RxBroadcast');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_RxBroadcast);							
							old_RxBroadcast = value;
						}
						
						data_node = root_node[0].getElementsByTagName('RxMulticast');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_RxMulticast');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_RxMulticast);							
							old_RxMulticast = value;
						}

						data_node = root_node[0].getElementsByTagName('RxPause');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_RxPause');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_RxPause);							
							old_RxPause = value;
						}

						// Error
						data_node = root_node[0].getElementsByTagName('Late');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_Late');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_Late);							
							old_Late = value;
						}

						data_node = root_node[0].getElementsByTagName('Excessive');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_Excessive');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_Excessive);							
							old_Excessive = value;
						}

						data_node = root_node[0].getElementsByTagName('CRCError');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_CRCError');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_CRCError);							
							old_CRCError = value;
						}

						data_node = root_node[0].getElementsByTagName('Discard');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_Discard');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_Discard);							
							old_Discard = value;
						}

						data_node = root_node[0].getElementsByTagName('Undersize');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_Undersize');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_Undersize);							
							old_Undersize = value;
						}

						data_node = root_node[0].getElementsByTagName('Fragments');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_Fragments');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_Fragments);							
							old_Fragments = value;
						}

						data_node = root_node[0].getElementsByTagName('Oversize');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_Oversize');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_Oversize);							
							old_Oversize = value;
						}

						data_node = root_node[0].getElementsByTagName('Jabber');
						if(data_node && data_node.length > 0) {
							item = document.getElementById('id_Jabber');
							value = data_node[0].getAttribute('value');
							item.value = CounterString_get(value,old_Jabber);							
							old_Jabber = value;
						}
						
					}
						
				}
			}

		}
	
		http_request.open('GET', '../xml/GetPortStatisticsData?port='+port, false);
		http_request.send(null);
		
	}

	function webInit()
	{	
		port = Request.QueryString("port");
	
		refreshStatisticsData();

		setInterval(refreshStatisticsData, 5000);
	}


	$(document).ready(function(){
		webInit();
	});	
	

</script>
</head>

<body>

	<table style='width:700px;'>
		<tr>
			<th style='width:20%; font-size:13px;'><%gettext("Tx Total");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Tx Unicast");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Tx Multicast");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Tx Broadcast");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Tx Collision");%></th>
		</tr>
		<tr>
			<td style='width:20%;'> <input id="id_TxTotal" 	   style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_TxUnicast"   style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_TxMulticast" style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_TxBroadcast" style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_TxCollision" style='border:none; width:100%;' value='0' readonly>	</td>
		</tr>
	</table>

	<table style='width:700px; margin-top:5px;'>
		<tr>
			<th style='width:20%; font-size:13px;'><%gettext("Rx Total");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Rx Unicast");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Rx Multicast");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Rx Broadcast");%></th>
			<th style='width:20%; font-size:13px;'><%gettext("Rx Pause");%></th>
		</tr>
		<tr>
			<td style='width:20%;'> <input id="id_RxTotal" 		style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_RxUnicast" 	style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_RxMulticast"  style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_RxBroadcast"  style='border:none; width:100%;' value='0' readonly>	</td>
			<td style='width:20%;'> <input id="id_RxPause" 		style='border:none; width:100%;' value='0' readonly>	</td>
		</tr>
	</table>

	<table style='width:700px; margin-top:5px;'>
		<tr>
			<th style="width:25%; font-size:13px;" colspan="2"><%gettext("Tx");%></th>
			<th style="width:75%; font-size:13px;" colspan="6"><%gettext("Rx");%></th>
		</tr>
		<tr>
			<th style='width:12.5%; font-size:13px;'><%gettext("Late");%></th>
			<th style='width:12.5%; font-size:13px;'><%gettext("Excessive");%></th>

			<th style='width:12.5%; font-size:13px;'><%gettext("CRC Error");%></th>
			<th style='width:12.5%; font-size:13px;'><%gettext("Discard");%></th>
			<th style='width:12.5%; font-size:13px;'><%gettext("Undersize");%></th>
			<th style='width:12.5%; font-size:13px;'><%gettext("Fragments");%></th>
			<th style='width:12.5%; font-size:13px;'><%gettext("Oversize");%></th>
			<th style='width:12.5%; font-size:13px;'><%gettext("Jabber");%></th>
			
		</tr>
		<tr>
			<td style='width:12.5%;'> <input id="id_Late" 		style='border:none; width:100%;' value='0' readonly> </td>
			<td style='width:12.5%;'> <input id="id_Excessive" 	style='border:none; width:100%;' value='0' readonly> </td>
			<td style='width:12.5%;'> <input id="id_CRCError" 	style='border:none; width:100%;' value='0' readonly> </td>
			<td style='width:12.5%;'> <input id="id_Discard" 	style='border:none; width:100%;' value='0' readonly> </td>
			<td style='width:12.5%;'> <input id="id_Undersize" 	style='border:none; width:100%;' value='0' readonly> </td>
			<td style='width:12.5%;'> <input id="id_Fragments" 	style='border:none; width:100%;' value='0' readonly> </td>
			<td style='width:12.5%;'> <input id="id_Oversize" 	style='border:none; width:100%;' value='0' readonly> </td>
			<td style='width:12.5%;'> <input id="id_Jabber" 	style='border:none; width:100%;' value='0' readonly> </td>
		</tr>
	</table>
	
</body>
</html>
