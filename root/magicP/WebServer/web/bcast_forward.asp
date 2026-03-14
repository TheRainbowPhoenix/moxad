<html>
<head>
<% net_Web_file_include(); %>
<script language="JavaScript" src=mdata.js></script>
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();

if(!debug){
	
}
else{
	<%net_Web_show_value('SRV_BCAST_FWD');%>
	var ifs_op = [ <% net_Web_IFS_WriteIntegerValue(); %>  ];
}

var max_ports = 8;

var myForm;
var newdata = new Array;

var table_idx = 0;
var tablefun = new table_show(document.getElementsByName('myForm'), "show_available_table", bcast_fwd_type, bcast_fwd, table_idx, newdata, Addformat, 0);

var src_if_selstate = {type:'select', id:'src_if', name:'src_if', size:1, style:'width:125px', option:ifs_op};
var dst_if_selstate = {type:'select', id:'dst_if', name:'dst_if', size:1, style:'width:125px', option:ifs_op};

function Addformat(mod, i)
{
	var j = 0, k, m;

	for(k in bcast_fwd_type){

		if(mod == 0){
			newdata[j] = bcast_fwd[i][k];
		}
		else{
			newdata[j] = document.getElementById('myForm')[k].value;
		}

		if((k == "src_if") || (k == "dst_if")){

			for(m=0;m<ifs_op.length;m++){
				if(newdata[j] == ifs_op[m].value){

					newdata[j] = ifs_op[m].text;
					break;
				}
			}
		}

		j++;
	}
}

function EditRow(row) 
{
	fnLoadForm(myForm, bcast_fwd[row], bcast_fwd_type);
	ChgColor('tri', bcast_fwd.length, row);
}

function Total_IP()
{
	if(bcast_fwd.length > bcast_fwd_MAX || bcast_fwd.length  < 0){		
		alert('Number of broadcast forwarding rule is over or wrong');
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}else if(bcast_fwd.length == bcast_fwd_MAX){
		with(document.myForm){
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}else if(bcast_fwd.length == 0){		
		with(document.myForm){		
			btnA.disabled = false;
			btnD.disabled = true;
			btnM.disabled = true;
			btnS.disabled = false;
		}
	}else{		
		with(document.myForm){		
			btnA.disabled = false;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}
}

function fnInit()
{
	myForm = document.getElementById('myForm');

	// init for global enable
	fnLoadForm(myForm, SRV_BCAST_FWD, SRV_BCAST_FWD_type);

	// init for table
	tablefun.show();
	EditRow(0);
	Total_IP();
}

function tabbtn_sel(form, sel)
{
	var port_arr, i;

	if((sel == 0) || (sel == 2)){ // add or modify

		if(sel == 0){ // add
			table_idx = bcast_fwd_MAX;
		}
		else{ // modify
			table_idx = tNowrow_Get();
		}

		if(form.src_if.value == form.dst_if.value){

			alert("Same source and destination interface!");
			return;
		}

		port_arr = form.udp_port.value.split(",");

		if(port_arr.length > max_ports){
			alert("Number of ports must be 1 - " + max_ports);
			return;
		}

		for(i=0;i<port_arr.length;i++){

			port_arr[i] = port_arr[i].replace(/^\s+|\s+$/g, ""); // remove left and right spaces

			if(isNumber(port_arr[i]) == false){
				alert(port_arr[i] + " is not a UDP port number!");
				return;
			}

			if((port_arr[i] < 1) || (port_arr[i] > 65535)){
				alert("UDP port number must be 1 - 65535!");
				return;
			}
		}

		form.udp_port.value = port_arr.join(",");
	}

	if(sel == 0){ // add
		Addformat(1, 0);
		tablefun.add();
	}
	else if(sel == 1){ // delete
		tablefun.del();
	}
	else if(sel == 2){ // modify
		tablefun.mod();
	}

	Total_IP();
}

function Activate(form)
{
	var i, j;

	form.bcast_fwd_tmp.value = "";

	for(i=0;i<bcast_fwd.length;i++){
		for(j in bcast_fwd[i]){

			form.bcast_fwd_tmp.value = form.bcast_fwd_tmp.value + bcast_fwd[i][j] + "+";
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_BCAST_FWD";
	form.submit();	
}

function stopSubmit()
{
	return false;
}

</script>
</head>

<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(BCAST_FWD)</script></h1>

<fieldset>
<form id=myForm name=myForm method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="bcast_fwd_tmp" id="bcast_fwd_tmp" value="">

<table cellpadding=1 cellspacing=2 border=0>
	<tr height=25px>
		<td colspan=2> <input type="checkbox" id=g_enable name="g_enable"> 
			 <script language="JavaScript">doc(BCAST_FWD_ENABLE)</script> </td>
	</tr>
	<tr height=25px>
		<td> <script language="JavaScript">doc(BCAST_FWD_SRC_IF)</script> </td>
		<td> <script language="JavaScript">fnGenSelect(src_if_selstate, '')</script> </td>
	</tr>
	<tr height=25px>
		<td> <script language="JavaScript">doc(BCAST_FWD_DST_IF)</script> </td>
		<td> <script language="JavaScript">fnGenSelect(dst_if_selstate, '')</script> </td>
	</tr>
	<tr height=25px>
		<td> <script language="JavaScript">doc(BCAST_FWD_PORT)</script> </td>
		<td> <input type="text" id=udp_port name="udp_port" style="width:375px" maxlength=224> </td>
	</tr>
	<tr height=25px>
		<td colspan=2> Note: 67,68,520,1701 means it will listen on UDP port 67,68,520,1701 </td>
	</tr>
</table>

<table border=0>
	<tr>
		<td width=400px> <script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script>
						 <Script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
						 <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script> </td>
		<td width=300px> <script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script> </td>
	</tr>
</table>
</form>

<table align=left border=0>
	<tr style="height:50px"></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" border=0>
	<tr> 
		<td colspan=3></td> 
	</tr>
	<tr>
		<th width=25%> <script language="JavaScript">doc(BCAST_FWD_SRC_IF)</script> </th>
		<th width=25%> <script language="JavaScript">doc(BCAST_FWD_DST_IF)</script> </th>
		<th width=50%> <script language="JavaScript">doc(BCAST_FWD_PORT)</script> </th>
	</tr>
</table>

</fieldset>
</body>
</html>

