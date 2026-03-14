<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
<!--
	var per_page_show=10;
	var bsr_info ={{ net_Web_show_pim_bsr() | safe }};
	var rp_info =[{{ net_Web_show_rp_info() | safe }}];
	/*var rp_info =[
		{index:'1', address:'192.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'2', address:'2.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'3', address:'392.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'4', address:'4.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'5', address:'592.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'6', address:'6.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'7', address:'792.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'8', address:'8.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'9', address:'992.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'10', address:'10.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'11', address:'1192.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'12', address:'123.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'13', address:'13192.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'14', address:'143.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'15', address:'15192.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'16', address:'163.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'17', address:'17192.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'18', address:'183.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'19', address:'192.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'20', address:'203.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'},
		{index:'21', address:'2192.168.127.254', group_address:'224.1.1.128', group_mask_len:'32', priority:'255', hold_time:'60'},
 		{index:'22', address:'223.3.3.2', group_address:'224.1.1.128', group_mask_len:'32', priority:'100', hold_time:'60'}		
	];*/
	var rp_show_selpage = [
		//{ value:0, text:'Page 1/1' }
	];
	var show_rp_info_order={address:0, group_address:0, priority:0, hold_time:0};
/*	var rp_info = [		
		{index:'1', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
	];*/
	var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'fnChgpage(this.value)', option:rp_show_selpage };
		
	function ShowRpInfo(page){
		var i, row, cell, idx, table;
		table = document.getElementById("show_table");	
		for(i = page*per_page_show; i < (parseInt(page)+1)*per_page_show && i < rp_info.length; i++ ){
			row = table.insertRow(table.getElementsByTagName("tr").length);
			for(idx in show_rp_info_order){	
				cell = document.createElement("td");
				cell.innerHTML = rp_info[i][idx];		
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
		ShowRpInfo(page);
	}
	function count_page(){
		var page;
		var table, i, row, new_option, sel;
		page = parseInt(rp_info.length/per_page_show)+parseInt(((rp_info.length%per_page_show)==0?0:1));		          
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
		if(rp_info[0]["index"]!=0){
			ShowRpInfo(0);
		}
	}

-->
</script>
</style>
</head>

<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(PIM_SM_);doc(' ');doc(RP_);doc(' ');doc(Set_);doc(' ');doc(Table_)</script></h1>
<form method="post" name="neighbors_show_form" target="mid">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table style="width:700">
	<tr>
	 	<td><table>
	 		<tr>
	 		<td width=200px><script language="JavaScript">doc(BSR_);doc(' ');doc(IP_Address);</script></td>
	 		<td id="td_bsr_ip_address"></td>
	 		</tr>
	 		<tr>
	 		<td><script language="JavaScript">doc(BSR_);doc(' ');doc(Priority_);</script></td>
	 		<td id="td_bsr_priority"></td>
	 		</tr>
	 		<tr>
	 		<td><script language="JavaScript">doc(BSR_);doc(' ');doc(HASH_MASK_LEN_);</script></td>
	 		<td id="td_bsr_hash_mask_length"></td>
			</tr>
		</table></td>
	</tr>
	<tr>
	 	<td><table border=0 cellpadding="0" cellspacing="0">
	 		<tr>
		 	 <td><script language="JavaScript">fnGenSelect(seliface, ((rp_info[0].index-1)/10)+1)</script></td>
		 	</tr>
		 	<tr><td>
			<table id="show_table" style="width:700px">
			 <tr align="center" width=500px>			  
			  <th width=250px><script language="JavaScript">doc(RP_);doc(' ');doc(IP_Address);</script></th>
			  <th width=250px><script language="JavaScript">doc(Group_);doc(' ');doc(PREFIX_);</script></th>
			  <th width=100px><script language="JavaScript">doc(Priority_)</script></th>
			  <th width=100px><script language="JavaScript">doc(HOLD_TIME_)</script></th> 
			 </tr>
			</table></td></tr>			 
			</td></tr>
		</table></td>
	</tr>
</table>
</fieldset>
</form>
</body>
</html>
