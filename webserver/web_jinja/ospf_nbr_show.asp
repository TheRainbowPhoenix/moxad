<html>
<head>

{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
	checkCookie();
	debug = 0;
	if (debug) {
		var SRV_OSPF_NEIGHBOR = [
			{ neighbor_rid:'10.0.0.228', priority:'1', state:'Full/DR', neighbor_ip:'10.0.0.228', interface:'eth0.3010:10.0.0.254' }  
		];
		
		var selpage0 = [
			{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
		];			
		var seltype=1;
	}
	else {
		
		{{ net_webOSPFNeighborTable() | safe }}

		var seltype=1;
	}



var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'SelectPage(this.value)', option:selpage0 };

function SelectPage(page)
{
	table = document.getElementById("show_table");	
	for(i = table.getElementsByTagName("tr").length-1; i > 0; i--){
		table.deleteRow(i);
	}
	for(i = page*10; i < SRV_OSPF_NEIGHBOR.length && i < page*10+10; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		cell = document.createElement("td");
		cell.innerHTML = i + 1;		
		row.appendChild(cell);
		row.style.Color = "black";
		row.style.backgroundColor = "white";
		row.align="left";
		
		for(idx in SRV_OSPF_NEIGHBOR[0]){	
			cell = document.createElement("td");
			cell.innerHTML = SRV_OSPF_NEIGHBOR[i][idx];		
			row.appendChild(cell);
			//row.style.Color = "black";
			//row.align="center";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
	}	
}

function fnInit() 
{
	if(SRV_OSPF_NEIGHBOR=="") {
		return;
	}
	
	SelectPage(0);	

	return 0;
}

function stopSubmit()
{
	return false;
}
</script>
</head>

<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(OSPF_NBR_TABLE)</script></h1>

<fieldset>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<tr>
 <td width=100px><script language="JavaScript">fnGenSelect(seliface, 0)</script></td>
</tr> 

	<table cellpadding=1 cellspacing=2 id="show_table" style="width:660px">
	<tr>
	<th width="6%"><script language="JavaScript">doc(OSPF_NBR_INDEX)</script></th>
	<th width="18%" class="s0"><script language="JavaScript">doc(OSPF_NBR_ID)</script></th>
	<th width="6%"><script language="JavaScript">doc(OSPF_NBR_PRIORITY)</script></th>
	<th width="25%"><script language="JavaScript">doc(OSPF_NBR_STATE)</script></th>
	<th width="18%" class="s0"><script language="JavaScript">doc(OSPF_NBR_IP)</script></th>
    <th><script language="JavaScript">doc(OSPF_NBR_IF_NAME)</script></th>
	</tr>
  	</table>

</form>
</fieldset>

</body></html>