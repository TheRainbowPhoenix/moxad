<html>
<head>

{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
	checkCookie();
	debug = 0;
	if (debug) {
		var SRV_OSPF_DB = [
			{  area_id:'0.0.0.0', lsa_type:'Router', link_id:'10.0.0.228', adv_router:'10.0.0.228', age:'11', route:'1' },
			{  area_id:'-', lsa_type:'AS-external', link_id:'20.1.1.0', adv_router:'10.0.0.228', age:'11', route:'20.1.1.0/24' }   
		];
		
		var selpage0 = [
			{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
		];			
		var seltype=1;
	}
	else {
		
		{{ net_webOSPFDatabase() | safe }}
			
		var seltype=1;
	}



var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'SelectPage(this.value)', option:selpage0 };

function SelectPage(page)
{
	table = document.getElementById("show_table");	
	for(i = table.getElementsByTagName("tr").length-1; i > 0; i--){
		table.deleteRow(i);
	}
	for(i = page*10; i < SRV_OSPF_DB.length && i < page*10+10; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		cell = document.createElement("td");
		cell.innerHTML = i + 1;		
		row.appendChild(cell);
		row.style.Color = "black";
		row.style.backgroundColor = "white";
		row.align="left";
		
		for(idx in SRV_OSPF_DB[0]){	
			cell = document.createElement("td");
			cell.innerHTML = SRV_OSPF_DB[i][idx];		
			row.appendChild(cell);
			//row.style.Color = "black";
			//row.align="center";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
	}	
}

function fnInit() 
{
	if(SRV_OSPF_DB=="") {
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
<h1><script language="JavaScript">doc(OSPF_LSA_TABLE)</script></h1>

<fieldset>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<tr>
 <td width=100px><script language="JavaScript">fnGenSelect(seliface, 0)</script></td>
</tr> 

	<table cellpadding=1 cellspacing=2 id="show_table" style="width:660px">
		<tr>
		<th width="6%"><script language="JavaScript">doc(OSPF_LSA_INDEX)</script></th>
		<th width="15%"><script language="JavaScript">doc(OSPF_LSA_AREA_ID)</script></th>
		<th width="10%" class="s0"><script language="JavaScript">doc(OSPF_LSA_TYPE)</script></th>
		<th width="15%"><script language="JavaScript">doc(OSPF_LSA_LINK_ID)</script></th>
		<th width="15%" class="s0"><script language="JavaScript">doc(OSPF_LSA_ADV_ROUTER)</script></th>
		<th width="10%" class="s0"><script language="JavaScript">doc(OSPF_LSA_AGE_TIME)</script></th>
		<th><script language="JavaScript">doc(OSPF_LSA_ROUTE)</script></th>
		</tr>
  	</table>


</form>
</fieldset>

</body></html>