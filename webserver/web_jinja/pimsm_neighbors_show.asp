<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
<!--
	var per_page_show=10;
	var pim_neighbor_info = [{{ net_Web_show_pim_neighbor_info() | safe }}];
	/*var pim_neighbor_info = [
		{index:'1', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'2', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'3', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'4', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'5', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'6', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'7', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'8', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'9', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'10', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'11', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'12', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'13', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'14', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'15', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'16', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'17', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'18', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'19', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'20', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'21', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'22', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'23', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'},
		{index:'24', address:'3.3.3.2        ', ifname:'wait for modify', lefttime:'       100'}
	];*/
	
	var show_neighbor_info_order={index:0, address:0, ifname:0, lefttime:0};
	var neighbor_show_selpage;
	var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'fnChgpage(this.value)', option:neighbor_show_selpage };
	
	function ShowNeighborInfo(page){
		var i, row, cell, idx, table;
		table = document.getElementById("show_table");	

		if(pim_neighbor_info[0].index == '0')
			return;
		for(i = page*per_page_show; i < (parseInt(page)+1)*per_page_show && i < pim_neighbor_info.length; i++ ){
			row = table.insertRow(table.getElementsByTagName("tr").length);
			for(idx in show_neighbor_info_order){	
				cell = document.createElement("td");
				cell.innerHTML = pim_neighbor_info[i][idx];		
				row.appendChild(cell);
				//row.style.Color = "black";
				row.align="center";
			}
			
			//row.className=((i%2)-1)?"r1":"r2";
		}
	}

	function fnChgpage(page) {	
		var i;
		//location.href="log_setting.asp?show_page="+page;
		var table = document.getElementById("show_table");	
		var rows = table.getElementsByTagName("tr");
		for(i=rows.length-1; i > 0; i--)
		{
			table.deleteRow(i);
		}
		ShowNeighborInfo(page);
	}
	function count_page(){
		var page;
		var table, i, row, new_option, sel;
		page = parseInt(pim_neighbor_info.length/per_page_show)+parseInt(((pim_neighbor_info.length%per_page_show)==0?0:1));		          
		sel = document.getElementById('selpage');   
		for(i=0;i<page;i++){			
			new_option = new Option('Page '+(i+1)+'/'+page, i);
			sel.options.add(new_option);			
		}
	}
	function fnInit(){
		//alert( bsr_info.td_bsr_ip_address);
		document.getElementById('td_bsr_ip_address').innerHTML = bsr_info.td_bsr_ip_address;
		document.getElementById('td_bsr_priority').innerHTML = bsr_info.td_bsr_priority;
		document.getElementById('td_bsr_hash_mask_length').innerHTML = bsr_info.td_bsr_hash_mask_length;
		count_page();
		ShowRpInfo(0);
	}
	function fnInit(){
		count_page();
		ShowNeighborInfo(0);
	}

-->
</script>
</head>

<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(PIM_SM_);doc(' ');doc(Neighbors_);doc(' ');doc(Table_)</script></h1>
<form method="post" name="neighbors_show_form" target="mid">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table style="width:700">
	<tr>
    	<td width="0%"></td>
    	<td width="100%" colspan="2">
	    	<table width="640">
	    	<tr><td>
	    	<script language="JavaScript">fnGenSelect(seliface, ((pim_neighbor_info[0].index-1)/10)+1)</script>
      	    </td></tr>
			</table></td>
	</tr>
	<tr>
		<td width="0%"></td>
    	<td width="100%" colspan="2">
	</tr>
	<tr>
		<td width="0%"></td>
    	<td width="100%" colspan="2">
		<table id="show_table" width="640" >
		<tr>
			<th width="10%" align="left">Index</td>
			<th width="33%" align="left">Neighbor IP</td>
			<th width="40%" align="left">Interface Name</td>
			<th width="17%" align="left">Expire Time</td>
		</tr>
		</table></td>
<input type="hidden" id="total_page" name="total_page" value="1">
<input type="hidden" id="show_page" name="show_page" value="1">

			</td>
	</tr>
</table>
</fieldset>
</form>
</body>
</html>
