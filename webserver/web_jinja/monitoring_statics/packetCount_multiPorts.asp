<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../main_style.css">
<script type="text/javascript" src="../jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="../moxa_common.js"></script>
<script language="JavaScript">

	var http_request;
	var showTable;
	var func=0, type=0;
	/*
	var old_TxTotal = "0", old_TxUnicast = "0", old_TxBroadcast = "0", old_TxMulticast = "0", old_TxCollision = "0",
		old_RxTotal = "0", old_RxUnicast = "0", old_RxBroadcast = "0", old_RxMulticast = "0", old_RxPause = "0",
		old_Late = "0", old_Excessive = "0", old_CRCError = "0", old_Discard = "0", old_Undersize = "0", old_Fragments = "0", old_Oversize = "0", old_Jabber = "0",
		old_TxError = "0", old_RxError = "0";
	*/
		
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
	
	function getStatisticsData()
	{
		http_request.onreadystatechange = function()
		{
			if (http_request.readyState == 4) {
				if (http_request.status == 200) {
					
					// Start parsing
					var xmldoc = http_request.responseXML;
					var root_node = xmldoc.getElementsByTagName('group_statistics');
					var data_node, item;

					if(root_node.length > 0)
					{
						data_node = root_node[0].getElementsByTagName('port_info');

						var name, value, row, cell;

						for(var index = 0; index < data_node.length; ++index)
						{
							var port_info = data_node[index];

							if(type == 0)
							{	
								// Total
								row = showTable.insertRow(showTable.rows.length);

								cell = document.createElement('td');
								name = port_info.getAttribute('name');
								cell.style.fontSize = "13px";
								cell.innerHTML = name;
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('TxTotal');
								cell.id = name + "_" + "TxTotal";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('TxError');
								cell.id = name + "_" + "TxError";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('RxTotal');
								cell.id = name + "_" + "RxTotal";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
		
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('RxError');
								cell.id = name + "_" + "RxError";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

							}
							else if(type == 1)
							{
								// Tx
								row = showTable.insertRow(showTable.rows.length);

								cell = document.createElement('td');
								name = port_info.getAttribute('name');
								cell.style.fontSize = "13px";
								cell.innerHTML = name;
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('TxTotal');
								cell.id = name + "_" + "TxTotal";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('TxUnicast');
								cell.id = name + "_" + "TxUnicast";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('TxMulticast');
								cell.id = name + "_" + "TxMulticast";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('TxBroadcast');
								cell.id = name + "_" + "TxBroadcast";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('TxCollision');
								cell.id = name + "_" + "TxCollision";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);
								
							}
							else if(type == 2)
							{
								// Rx
								row = showTable.insertRow(showTable.rows.length);

								cell = document.createElement('td');
								name = port_info.getAttribute('name');
								cell.style.fontSize = "13px";
								cell.innerHTML = name;
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('RxTotal');
								cell.id = name + "_" + "RxTotal";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('RxUnicast');
								cell.id = name + "_" + "RxUnicast";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('RxMulticast');
								cell.id = name + "_" + "RxMulticast";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('RxBroadcast');
								cell.id = name + "_" + "RxBroadcast";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('RxPause');
								cell.id = name + "_" + "RxPause";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);
								
							}
							else if(type == 3)
							{
								// Error
								row = showTable.insertRow(showTable.rows.length);

								cell = document.createElement('td');
								name = port_info.getAttribute('name');
								cell.style.fontSize = "13px";
								cell.innerHTML = name;
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('Late');
								cell.id = name + "_" + "Late";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('Excessive');
								cell.id = name + "_" + "Excessive";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('CRCError');
								cell.id = name + "_" + "CRCError";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('Discard');
								cell.id = name + "_" + "Discard";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('Undersize');
								cell.id = name + "_" + "Undersize";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('Fragments');
								cell.id = name + "_" + "Fragments";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('Oversize');
								cell.id = name + "_" + "Oversize";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);

								cell = document.createElement('td');
								value = port_info.getAttribute('Jabber');
								cell.id = name + "_" + "Jabber";
								cell.value = value;
								cell.innerHTML = "<input style='border:none; width:100%;' readonly value='" + value +"+0'>";
								row.appendChild(cell);
								
							}
							
						}
						
					}
						
				}
			}
			
		}

		http_request.open('GET', '../xml/GetGroupStatisticsData?func='+func+'&type='+type, false);
		http_request.send(null);
		
	}

	function refreshStatisticsData()
	{
		http_request.onreadystatechange = function()
		{
			if (http_request.readyState == 4) {
				if (http_request.status == 200) {
					
					// Start parsing
					var xmldoc = http_request.responseXML;
					var root_node = xmldoc.getElementsByTagName('group_statistics');
					var data_node, item;

					if(root_node.length > 0)
					{
						data_node = root_node[0].getElementsByTagName('port_info');

						var name, value, new_value, row, cell;

						for(var index = 0; index < data_node.length; ++index)
						{
							var port_info = data_node[index];

							if(type == 0)
							{	
								// Total
								name = port_info.getAttribute('name');

								cell = document.getElementById(name + "_" + "TxTotal");
								if(cell) {
									value = port_info.getAttribute('TxTotal');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}
							
								cell = document.getElementById(name + "_" + "TxError");
								if(cell) {
									value = port_info.getAttribute('TxError');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "RxTotal");
								if(cell) {
									value = port_info.getAttribute('RxTotal');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "RxError");
								if(cell) {
									value = port_info.getAttribute('RxError');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

							}
							else if(type == 1)
							{
								// Tx
								name = port_info.getAttribute('name');

								cell = document.getElementById(name + "_" + "TxTotal");
								if(cell) {
									value = port_info.getAttribute('TxTotal');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "TxUnicast");
								if(cell) {
									value = port_info.getAttribute('TxUnicast');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "TxMulticast");
								if(cell) {
									value = port_info.getAttribute('TxMulticast');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "TxBroadcast");
								if(cell) {
									value = port_info.getAttribute('TxBroadcast');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "TxCollision");
								if(cell) {
									value = port_info.getAttribute('TxCollision');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}
								
							}
							else if(type == 2)
							{
								// Rx
								name = port_info.getAttribute('name');

								cell = document.getElementById(name + "_" + "RxTotal");
								if(cell) {
									value = port_info.getAttribute('RxTotal');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "RxUnicast");
								if(cell) {
									value = port_info.getAttribute('RxUnicast');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "RxMulticast");
								if(cell) {
									value = port_info.getAttribute('RxMulticast');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "RxBroadcast");
								if(cell) {
									value = port_info.getAttribute('RxBroadcast');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "RxPause");
								if(cell) {
									value = port_info.getAttribute('RxPause');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

							}
							else if(type == 3)
							{
								// Error
								name = port_info.getAttribute('name');

								cell = document.getElementById(name + "_" + "Late");
								if(cell) {
									value = port_info.getAttribute('Late');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}
								
								cell = document.getElementById(name + "_" + "Excessive");
								if(cell) {
									value = port_info.getAttribute('Excessive');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "CRCError");
								if(cell) {
									value = port_info.getAttribute('CRCError');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "Discard");
								if(cell) {
									value = port_info.getAttribute('Discard');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "Undersize");
								if(cell) {
									value = port_info.getAttribute('Undersize');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "Fragments");
								if(cell) {
									value = port_info.getAttribute('Fragments');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "Oversize");
								if(cell) {
									value = port_info.getAttribute('Oversize');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

								cell = document.getElementById(name + "_" + "Jabber");
								if(cell) {
									value = port_info.getAttribute('Jabber');
									new_value = CounterString_get(value,cell.value);
									cell.firstChild.value = new_value;
									cell.value = value;
								}

							}
							
						}
						
					}
						
				}
			}
			
		}

		http_request.open('GET', '../xml/GetGroupStatisticsData?func='+func+'&type='+type, false);		
		http_request.send(null);
		
	}
	
	function webInit()
	{	
		func = Request.QueryString("func");
		type = Request.QueryString("type");

		var showTableHeader, showDiv;
		

		if(type == 0) {
			showTable = document.getElementById('id_TotalTable');
			showTable.style.display = "";
			showTableHeader = document.getElementById('id_TotalTableHeader');
			showTableHeader.style.display = "";
			showDiv = document.getElementById('id_divTotal');
			showDiv.style.display = "";
		} else if(type == 1) {
			showTable = document.getElementById('id_TxTable');
			showTable.style.display = "";
			showTableHeader = document.getElementById('id_TxTableHeader');
			showTableHeader.style.display = "";
			showDiv = document.getElementById('id_divTx');
			showDiv.style.display = "";
		} else if(type == 2) {
			showTable = document.getElementById('id_RxTable');
			showTable.style.display = "";
			showTableHeader = document.getElementById('id_RxTableHeader');
			showTableHeader.style.display = "";
			showDiv = document.getElementById('id_divRx');
			showDiv.style.display = "";
		} else if(type == 3) {
			showTable = document.getElementById('id_ErrorTable');
			showTable.style.display = "";
			showTableHeader = document.getElementById('id_ErrorTableHeader');
			showTableHeader.style.display = "";
			showDiv = document.getElementById('id_divError');
			showDiv.style.display = "";
		}

		getStatisticsData();

		setInterval(refreshStatisticsData, 5000);
		
	}

	$(document).ready(function(){
		webInit();
	});	
	

</script>
</head>

<body>

	<table id='id_TotalTableHeader' style='width:680px; display:none;'>
		<tr>
        	<th style='font-size:13px; width:6%'>{{ gettext("Port") | safe }}</th>
        	<th style='font-size:13px; width:34%'>{{ gettext("Tx") | safe }}</th>
        	<th style='font-size:13px; width:13%'>{{ gettext("Tx Error") | safe }}</th>
        	<th style='font-size:13px; width:34%'>{{ gettext("Rx") | safe }}</th>
        	<th style='font-size:13px; width:13%'>{{ gettext("Rx Error") | safe }}</th>
        </tr>
	</table>
	<div id='id_divTotal' style='width:680px; height:200px; overflow-y:auto; display:none;'>
	<table id='id_TotalTable' style='width:680px; display:none;'>
		<tr>
        	<td style='font-size:13px; width:6%'></td>
        	<td style='font-size:13px; width:34%'></td>
        	<td style='font-size:13px; width:13%'></td>
        	<td style='font-size:13px; width:34%'></th>
        	<td style='font-size:13px; width:13%'></td>
        </tr>
	</table>
	</div>

	<table id='id_TxTableHeader' style='width:680px; display:none;'>
		<tr>
        	<th style='font-size:13px; width:6%'>{{ gettext("Port") | safe }}</th>
        	<th style='font-size:13px; width:23.2%'>{{ gettext("Total") | safe }}</th>
        	<th style='font-size:13px; width:23.2%'>{{ gettext("Unicast") | safe }}</th>
        	<th style='font-size:13px; width:18.8%'>{{ gettext("Multicast") | safe }}</th>
        	<th style='font-size:13px; width:18.8%'>{{ gettext("Broadcast") | safe }}</th>
        	<th style='font-size:13px; width:10%'>{{ gettext("Collision") | safe }}</th>
        </tr>
	</table>
	<div id='id_divTx' style='width:680px; height:200px; overflow-y:auto; display:none;'>
	<table id='id_TxTable' style='width:680px; display:none;'>
		<tr>
        	<td style='font-size:13px; width:6%'></td>
        	<td style='font-size:13px; width:23.2%'></td>
        	<td style='font-size:13px; width:23.2%'></td>
        	<td style='font-size:13px; width:18.8%'></td>
        	<td style='font-size:13px; width:18.8%'></td>
        	<td style='font-size:13px; width:10%'></td>
        </tr>
	</table>
	</div>

	<table id='id_RxTableHeader' style='width:680px; display:none;'>
		<tr>
        	<th style='font-size:13px; width:6%'>{{ gettext("Port") | safe }}</th>
        	<th style='font-size:13px; width:23.2%'>{{ gettext("Total") | safe }}</th>
        	<th style='font-size:13px; width:23.2%'>{{ gettext("Unicast") | safe }}</th>
        	<th style='font-size:13px; width:18.8%'>{{ gettext("Multicast") | safe }}</th>
        	<th style='font-size:13px; width:18.8%'>{{ gettext("Broadcast") | safe }}</th>
        	<th style='font-size:13px; width:10%'>{{ gettext("Pause") | safe }}</th>
        </tr>
	</table>
	<div id='id_divRx' style='width:680px; height:200px; overflow-y:auto; display:none;'>
	<table id='id_RxTable' style='width:680px; display:none;'>
		<tr>
        	<td style='font-size:13px; width:6%'></td>
        	<td style='font-size:13px; width:23.2%'></td>
        	<td style='font-size:13px; width:23.2%'></td>
        	<td style='font-size:13px; width:18.8%'></td>
        	<td style='font-size:13px; width:18.8%'></td>
        	<td style='font-size:13px; width:10%'></td>
        </tr>
	</table>
	</div>

	<table id='id_ErrorTableHeader' style='width:680px; display:none;'>
		<tr>
        	<th style='font-size:13px; width:6%'>{{ gettext("Port") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("Late") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("Excessive") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("CRC Error") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("Discard") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("Undersize") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("Fragments") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("Oversize") | safe }}</th>
        	<th style='font-size:13px; width:11.75%'>{{ gettext("Jabber") | safe }}</th>
        </tr>
	</table>
	<div id='id_divError' style='width:680px; height:200px; overflow-y:auto; display:none;'>
	<table id='id_ErrorTable' style='width:680px; display:none;'>
		<tr>
        	<td style='font-size:13px; width:6%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        	<td style='font-size:13px; width:11.75%'></td>
        </tr>
	</table>
	</div>
	
</body>
</html>

