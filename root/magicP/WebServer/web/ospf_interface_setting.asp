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
	<%net_Web_show_value('SRV_VCONF');%>
	<%net_Web_show_value('SRV_IP_CLIENT');%>
	<%net_Web_show_value('SRV_OSPF_A');%>
	<%net_Web_show_value('SRV_OSPF_I');%>
	
	var ifs_op = [ <% net_Web_IFS_WriteIntegerValue(); %>  ];
	<%net_webOSPFIfState();%>
}

var myForm;
var newdata = new Array;

var table_idx = 0;
var tablefun = new table_show(document.getElementsByName('myForm'), "show_available_table", SRV_OSPF_I_type, SRV_OSPF_I, table_idx, newdata, Addformat, 0);

var auth_op = [{value:0, text:OSPF_I_AUTH_NONE}, {value:1, text:OSPF_I_AUTH_SIMPLE}, {value:2, text:OSPF_I_AUTH_MD5}];
var area_op = [{value:0, text:"----------"}];

var ifs_selstate = {type:'select', id:'ifs', name:'ifs', size:1, style:'width:125px', option:ifs_op};
var auth_selstate = {type:'select', id:'auth_type', name:'auth_type', size:1, onChange:'fnAuthTypeSel(this.value)', style:'width:125px', option:auth_op};
var area_selstate = {type:'select', id:'area_id', name:'area_id', size:1, style:'width:125px', option:area_op};

function getIfNameByVID(vid)
{
	var i;

	if(SRV_IP_CLIENT[0].vid == vid){ // WAN
		return "WAN";
	}
	
	for(i=0;i<SRV_VCONF.length;i++){ // LAN
		if(SRV_VCONF[i].vid == vid){
			return SRV_VCONF[i].ifname;
		}
	}
}

function getIPAddrByVID(vid)
{
	var i, addr;

	if(SRV_IP_CLIENT[0].vid == vid){ // WAN
		if(SRV_IP_CLIENT[0].type_ip == 0){
			addr = SRV_IP_CLIENT[0].staticip;
		}else if(SRV_IP_CLIENT[0].type_ip == 1){
			addr = Dynamic_IP;
		}else{
			addr = PPPoE_;
		}
		return addr;
	}

	for(i=0;i<SRV_VCONF.length;i++){
		if(SRV_VCONF[i].vid == vid){
			return SRV_VCONF[i].ip;
		}
	}
}

function getOSPFIfState(idx)
{
	if((idx >= 0) && (idx < if_state.length)){
		return if_state[idx];
	}
	else{
		return "Unknown";
	}
}

function Addformat(mod, i)
{
	var j = 0, k;

	for(k in SRV_OSPF_I_type){

		if(mod == 0){
			newdata[j] = SRV_OSPF_I[i][k];
		}
		else{
			newdata[j] = document.getElementById('myForm')[k].value;
		}

		if(k == "ifs"){

			var vid = newdata[j];
			
			newdata[j] = getIfNameByVID(vid);
			newdata[j+1] = getIPAddrByVID(vid);
			j+=2;

			continue;
		}

		if(k == "area_id"){

			newdata[j+1] = getOSPFIfState(i);
			j+=2;

			continue;
		}

		if(k == "auth_type"){

			newdata[j] = auth_op[newdata[j]].text;
			j++;

			continue;
		}

		j++;
	}
}

function checkValueRange(obj, min, max, msg)
{
	if((isNaN(obj.value) == true) || (obj.value < min) || (obj.value > max)){
		alert(msg);
		return false;
	}

	return true;
}

function tabbtn_sel(form, sel)
{
	if((sel == 0) || (sel == 2)){ // add or modify

		if(sel == 0){ // add
			table_idx = SRV_OSPF_I_MAX;
		}
		else{ // modify
			table_idx = tNowrow_Get();
		}
		
		if(duplicate_check(table_idx, SRV_OSPF_I, "ifs", document.getElementById('ifs').value, "Duplicated OSPF Interface")<0){
			return;
		}

		if(form.area_id.value == 0){
			alert("No OSPF Area ID");
			return;
		}

		if(checkValueRange(form.router_pri, 0, 255, "OSPF Router Priority Over Range. (0 - 255)") == false){
			return;
		}

		if(checkValueRange(form.hello_inter, 1, 65535, "OSPF Hello Interval Over Range. (1 - 65535)") == false){
			return;
		}

		if(checkValueRange(form.dead_inter, 1, 65535, "OSPF Dead Interval Over Range. (1 - 65535)") == false){
			return;
		}

		if(checkValueRange(form.md5_key, 1, 255, "OSPF MD5 Key ID Over Range. (1 - 255)") == false){
			return;
		}

		if(checkValueRange(form.metric, 1, 65535, "OSPF Metric Over Range. (1 - 65535)") == false){
			return;
		}

		if(form.auth_type.value != 0){ // if auth_type = SIMPLE & MD5, check auth_key
			
			if(isSymbol(form.auth_key, OSPF_I_AUTH_KEY)){
				return;
			}
		}
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

function fnAuthTypeSel(sel_value)
{
	if(sel_value == 0){ // None

		document.getElementById('auth_key').value = "";
		document.getElementById('md5_key').value = 1;
		
		document.getElementById('auth_key').disabled = true;
		document.getElementById('md5_key').disabled = true;
	}
	else if(sel_value == 1){ // simple
		
		document.getElementById('md5_key').value = 1;

		document.getElementById('auth_key').disabled = false;
		document.getElementById('md5_key').disabled = true;
	}
	else if(sel_value == 2){ // md5
		
		document.getElementById('auth_key').disabled = false;
		document.getElementById('md5_key').disabled = false;
	}
}

function setDefaultValue(form)
{
	form.area_id.value = 0;
	form.router_pri.value = 1;
	form.hello_inter.value = 10;
	form.dead_inter.value = 40;
	form.metric.value = 1;
}

function setAreaOP()
{
	var i;

	for(i=0;i<SRV_OSPF_A.length;i++){
		var new_op = new Option(SRV_OSPF_A[i].area_id, SRV_OSPF_A[i].area_id);
		document.getElementById("area_id").options.add(new_op);
	}
}

function EditRow(row) 
{
	fnLoadForm(myForm, SRV_OSPF_I[row], SRV_OSPF_I_type);
	ChgColor('tri', SRV_OSPF_I.length, row);
}

function EntryInit(row)
{
	setDefaultValue(myForm);
}

function Total_IP()
{
	if(SRV_OSPF_I.length > SRV_OSPF_I_MAX || SRV_OSPF_I.length  < 0){		
		alert('Number of OSPF Interface is over or wrong');
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}else if(SRV_OSPF_I.length == SRV_OSPF_I_MAX){
		with(document.myForm){
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}else if(SRV_OSPF_I.length == 0){		
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

	setAreaOP();
	
	tablefun.show();
	Total_IP();
	if(SRV_OSPF_I.length==0){
		document.getElementById("metric").value =1;
		document.getElementById("router_pri").value =1;
		document.getElementById("hello_inter").value=10;
		document.getElementById("dead_inter").value=40;
		fnAuthTypeSel(0); 
	}else{
		EditRow(0);
	}
	//EntryInit(0);
}

function Activate(form)
{
	var i, j;

	form.SRV_OSPF_I_tmp.value = "";

	for(i=0;i<SRV_OSPF_I.length;i++){
		for(j in SRV_OSPF_I[i]){

			if(SRV_OSPF_I[i][j] == ''){
				SRV_OSPF_I[i][j] = ' ';
			}

			form.SRV_OSPF_I_tmp.value = form.SRV_OSPF_I_tmp.value + SRV_OSPF_I[i][j] + "+";
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_OSPF_I";	
	form.submit();	
}

</script>
</head>

<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(OSPF_I_SETTING)</script></h1>

<fieldset>
<form id=myForm name=myForm method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_OSPF_I_tmp" id="SRV_OSPF_I_tmp" value="">
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0 style="width:650px">
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_I_IF_NAME)</script> </td>
		<td width=200px> <script language="JavaScript">fnGenSelect(ifs_selstate, '')</script> </td>
	</tr>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_A_AREAID)</script> </td>
		<td width=200px> <script language="JavaScript">fnGenSelect(area_selstate, '')</script> </td>
		<td width=125px> <script language="JavaScript">doc(OSPF_I_AUTH_TYPE)</script> </td>
		<td width=200px> <script language="JavaScript">fnGenSelect(auth_selstate, '')</script> </td>
	</tr>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_I_ROUTER_PRI)</script> </td>
		<td width=200px> <input type="text" id=router_pri name="router_pri" style="width:125px" maxlength=15> </td>
		<td width=125px> <script language="JavaScript">doc(OSPF_I_AUTH_KEY)</script> </td>
		<td width=200px> <input type="text" id=auth_key name="auth_key" style="width:125px" maxlength=8> </td>
	</tr>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_I_HELLO_INTER)</script> (sec) </td>
		<td width=200px> <input type="text" id=hello_inter name="hello_inter" style="width:125px" maxlength=15> </td>
		<td width=125px> <script language="JavaScript">doc(OSPF_I_MD5_KEY)</script> </td>
		<td width=200px> <input type="text" id=md5_key name="md5_key" style="width:125px" maxlength=15> </td>
	</tr>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_I_DEAD_INTER)</script> (sec) </td>
		<td width=200px> <input type="text" id=dead_inter name="dead_inter" style="width:125px" maxlength=15> </td>
		<td width=125px> <script language="JavaScript">doc(OSPF_A_METRIC)</script> </td>
		<td width=200px> <input type="text" id=metric name="metric" style="width:125px" maxlength=15> </td>
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
		<td colspan=11></td> 
	</tr>
	<tr>
		<th width=15% class="s0"> <script language="JavaScript">doc(OSPF_I_IF_NAME)</script> </th>
		<th width=16% class="s0"> <script language="JavaScript">doc(OSPF_I_IP_ADDR)</script> </th>
		<th width=16%> <script language="JavaScript">doc(OSPF_A_AREAID)</script> </th>
		<th width=10%> <script language="JavaScript">doc(OSPF_I_ROLE)</script> </th>
		<th width=5%> <script language="JavaScript">doc(OSPF_I_PRI)</script> </th>
		<th width=5% class="s0"> <script language="JavaScript">doc(OSPF_I_HELLO_INTER)</script> </th>
		<th width=5% class="s0"> <script language="JavaScript">doc(OSPF_I_DEAD_INTER)</script> </th>
		<th width=8% class="s0"> <script language="JavaScript">doc(OSPF_I_AUTH_TYPE)</script> </th>
		<th width=10% class="s0"> <script language="JavaScript">doc(OSPF_I_AUTH_KEY)</script> </th>
		<th width=5% class="s0"> <script language="JavaScript">doc(OSPF_I_MD5_KEY)</script> </th>
		<th width=5%> <script language="JavaScript">doc(OSPF_A_METRIC)</script> </th>
	</tr>
</table>

</fieldset>
</body>
</html>
