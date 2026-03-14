<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
	checkCookie();
	debug = 0;
	if (debug) {
		var SRV_MCROUTE_TABLE = [
			{ group:'192.168.127.1', source:'100.100.100.254', inbif:'wan1', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'192.168.1.254', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'},
			{ group:'100.100.100.100', source:'100.100.100.254', inbif:'wan2', packets:'15', bytes:'150', wrong:'0', outbifs:'wan1'}
		];
		
		var selpage0 = [
			{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
		];			
		var seltype=1;
	}
	else {
		
		<%net_webMcRouteShow();%>

		var seltype=1;
	}



var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'SelectPage(this.value)', option:selpage0 };

function SelectPage(page)
{
	table = document.getElementById("show_table");	
	for(i = table.getElementsByTagName("tr").length-1; i > 0; i--){
		table.deleteRow(i);
	}
	for(i = page*10; i < SRV_MCROUTE_TABLE.length && i < page*10+10; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		cell = document.createElement("td");
		cell.innerHTML = i + 1;		
		row.appendChild(cell);
		row.style.Color = "black";
		row.style.backgroundColor = "white";
		row.align="left";
		
		for(idx in SRV_MCROUTE_TABLE[0]){	
			cell = document.createElement("td");
			cell.innerHTML = SRV_MCROUTE_TABLE[i][idx];		
			row.appendChild(cell);
			//row.style.Color = "black";
			//row.align="center";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
	}	
}

function fnInit() 
{
	if(SRV_MCROUTE_TABLE=="") {
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
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(MCRoute_Table_);</script></h1>

<fieldset>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<tr>
 <td width=100px><script language="JavaScript">fnGenSelect(seliface, 0)</script></td>
</tr> 
<table cellpadding=1 cellspacing=2 id="show_table" style="width:630px">
 <tr align="center" width=630px>
  <th width=50px><script language="JavaScript">doc(Index_)</script></th>
  <th width=80px class="s0"><script language="JavaScript">doc(SMCRoute_Group_Addr)</script></th>
  <th width=80px class="s0"><script language="JavaScript">doc(SMCRoute_Source_Addr)</script></th>
  <th width=80px class="s0"><script language="JavaScript">doc(Inbound_ + " " + Interface_)</script></th> 
  <th width=60px><script language="JavaScript">doc(Packets_)</script></th>   
  <th width=80px><script language="JavaScript">doc(Bytes_)</script></th> 
  <th width=200px><script language="JavaScript">doc(Outbound_ +" "+ Interface_ + "(s)")</script></th>
  </tr>
</table>

</form>
</fieldset>

</body>
</html>

