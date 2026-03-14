<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
	checkCookie();
	debug = 0;
	if (debug) {
		var pim_mrt_info = [
			{ group:'192.168.127.1', source:'192.168.127.1',inbif:'wan1', outbifs:'wan1'},			
		];
		
		var selpage0 = [
			{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
		];			
	}
	else {
		<%net_Web_show_pim_mrt_info();%>
	}


var per_page_show=10;
var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'SelectPage(this.value)', option:selpage0 };

function SelectPage(page)
{
	var i, table, row, cell, idx, ifidx;
	table = document.getElementById("show_table");	
	for(i = table.getElementsByTagName("tr").length-1; i > 0; i--){
		table.deleteRow(i);
	}
	for(i = page*per_page_show; i < pim_mrt_info.length && i < page*per_page_show+per_page_show; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		cell = document.createElement("td");
		cell.innerHTML = i + 1;		
		row.appendChild(cell);
		row.style.Color = "black";
		row.style.backgroundColor = "white";
		row.align="left";
		
		for(idx in pim_mrt_info[0]){	
			cell = document.createElement("td");
			if(idx == "inbif"){				
				if(map_ifname[pim_mrt_info[i][idx]])
					cell.innerHTML = map_ifname[pim_mrt_info[i][idx]];
			}else if(idx == "outbifs" || idx == "prunedifs" || idx == "joinedifs"|| idx == "assertedifs"){
				for(ifidx=0;ifidx < map_ifname[0].length; ifidx++){
					if(parseInt(pim_mrt_info[i][idx]) & 1<<ifidx){
						cell.innerHTML += map_ifname[ifidx]; 
					}
				}
			}else{
				cell.innerHTML = pim_mrt_info[i][idx];		
			}
			
			row.appendChild(cell);
			//row.style.Color = "black";
			//row.align="center";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
	}	
}

function count_page(){
		var page;
		var table, i, row, new_option, sel;
		page = parseInt(pim_mrt_info.length/per_page_show)+parseInt(((pim_mrt_info.length%per_page_show)==0?0:1));		          
		sel = document.getElementById('selpage');   
		for(i=0;i<page;i++){			
			new_option = new Option('Page '+(i+1)+'/'+page, i);
			sel.options.add(new_option);			
		}
	}
function fnInit() 
{
	if(pim_mrt_info=="") {
		return;
	}
	
	SelectPage(0);	
	count_page();
	return 0;
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(PIM_SM_+" "+ Routing_+" "+Table_);</script></h1>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<tr>
 <td width=100px><script language="JavaScript">fnGenSelect(seliface, 0)</script></td>
</tr> 
<table cellpadding=1 cellspacing=2 id="show_table" style="width:630px">
 <tr class=r5 align="center" width=630px>
  <th width=50px><script language="JavaScript">doc(Index_)</script></th>
  <th width=80px><script language="JavaScript">doc(SMCRoute_Group_Addr)</script></th>
  <th width=80px><script language="JavaScript">doc(SMCRoute_Source_Addr)</script></th>
  <th width=80px><script language="JavaScript">doc(Inbound_ + " " + Interface_)</script></th>   
  <th width=200px><script language="JavaScript">doc(Outbound_ +" "+ Interface_ + "(s)")</script></th>
  <th width=200px><script language="JavaScript">doc(PRUNED_ +" "+ Interface_ + "(s)")</script></th>
  <th width=200px><script language="JavaScript">doc(JOINED_ +" "+ Interface_ + "(s)")</script></th>  
  <th width=200px><script language="JavaScript">doc(ASSERTED_ +" "+ Interface_ + "(s)")</script></th>
  </tr>
</table>

</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>

