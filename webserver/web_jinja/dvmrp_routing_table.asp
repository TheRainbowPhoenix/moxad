<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
	checkCookie();
	debug = 1;
	if (!debug) {
		var dvmrp_mrt_info = [
			{ origin:'192.168.127.1', nexthop:'192.168.127.254', inbif:'wan1', vid:'3', cost:'1', expire:'240'}		
		];
		
		var selpage0 = [
			{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
		];			
		var seltype=1;
	}
	else {
		
		{{ net_Web_show_dvmrp_mrt_info() | safe }}

		var seltype=1;
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
	for(i = page*per_page_show; i < dvmrp_mrt_info.length && i < page*per_page_show+per_page_show; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		cell = document.createElement("td");
		cell.innerHTML = i + 1;		
		row.appendChild(cell);
		row.style.Color = "black";
		row.style.backgroundColor = "white";
		row.align="left";
		
		for(idx in dvmrp_mrt_info[0]){	
			cell = document.createElement("td");
			
			cell.innerHTML = dvmrp_mrt_info[i][idx];		
		
			
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
		page = parseInt(dvmrp_mrt_info.length/per_page_show)+parseInt(((dvmrp_mrt_info.length%per_page_show)==0?0:1));		          
		sel = document.getElementById('selpage');   
		for(i=0;i<page;i++){			
			new_option = new Option('Page '+(i+1)+'/'+page, i);
			sel.options.add(new_option);			
		}
	}
function fnInit() 
{
	if(dvmrp_mrt_info=="") {
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
<h1><script language="JavaScript">doc(DVMRP_+" "+ Routing_+" "+Table_);</script></h1>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<tr>
 <td width=100px><script language="JavaScript">fnGenSelect(seliface, 0)</script></td>
</tr> 
<table cellpadding=1 cellspacing=2 id="show_table" style="width:630px">
 <tr class=r5 align="center" width=630px>
  <th width=50px class="s0"><script language="JavaScript">doc(Index_)</script></th>
  <th width=100px class="s0"><script language="JavaScript">doc(DVMRP_ORIGIN_)</script></th>
  <th width=100px class="s0"><script language="JavaScript">doc(DVMRP_NEXT_HOP_)</script></th>
  <th width=80px class="s0"><script language="JavaScript">doc(OSPF_I_IF_NAME)</script></th>   
  <th width=50px class="s0"><script language="JavaScript">doc(VID_)</script></th>
  <th width=50px class="s0"><script language="JavaScript">doc(DVMRP_COST_)</script></th>
  <th width=100px class="s0"><script language="JavaScript">doc(DVMRP_EXPIRE_TIME_)</script></th>  
  </tr>
</table>

</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>

