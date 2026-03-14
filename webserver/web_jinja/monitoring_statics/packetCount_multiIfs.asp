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
		
							// Total
							row = showTable.insertRow(showTable.rows.length);

							cell = document.createElement('td');
							name = port_info.getAttribute('name');
							cell.style.fontSize = "13px";
							cell.style.wordBreak = "break-all";
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
						
					}
						
				}
			}
			
		}

		http_request.open('GET', '../xml/GetIfStatisticsData?func='+func+'&type='+type, false);
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
						
					}
						
				}
			}
			
		}

		http_request.open('GET', '../xml/GetIfStatisticsData?func='+func+'&type='+type, false);		
		http_request.send(null);
		
	}
	
	function webInit()
	{	
		func = Request.QueryString("func");
		type = Request.QueryString("type");

		var showTableHeader, showDiv;
		
		showTable = document.getElementById('id_TotalTable');
		showTable.style.display = "";
		showTableHeader = document.getElementById('id_TotalTableHeader');
		showTableHeader.style.display = "";
		showDiv = document.getElementById('id_divTotal');
		showDiv.style.display = "";
	

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
        	<th style='font-size:13px; width:14%'>Interface</th>
        	<th style='font-size:13px; width:30%'>Tx</th>
        	<th style='font-size:13px; width:13%'>Tx Error</th>
        	<th style='font-size:13px; width:30%'>Rx</th>
        	<th style='font-size:13px; width:13%'>Rx Error</th>
        </tr>
	</table>
	<div id='id_divTotal' style='width:680px; height:200px; overflow-y:auto; display:none;'>
	<table id='id_TotalTable' style='width:680px; display:none;'>
		<tr>
        	<td style='font-size:13px; width:14%; word-break: break-all; word-wrap:break-word;'></td>
        	<td style='font-size:13px; width:30%'></td>
        	<td style='font-size:13px; width:13%'></td>
        	<td style='font-size:13px; width:30%'></th>
        	<td style='font-size:13px; width:13%'></td>
        </tr>
	</table>
	</div>
	
</body>
</html>

