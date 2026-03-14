<html>
<head>
<% net_Web_file_include(); %>
<script language="JavaScript" src=mdata.js></script>
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();

if(!debug){
	
	var SRV_OSPF_A_MAX = 64;
	var SRV_OSPF_A_type = {area_id:5, area_type:4, metric:4};
	var SRV_OSPF_A = [{area_id:'0.0.0.1', area_type:'0', metric:'5'}, {area_id:'0.0.0.2', area_type:'1', metric:'10'}, {area_id:'0.0.0.3', area_type:'0', metric:'15'}];

	var SRV_OSPF_V_MAX = 64;
	var SRV_OSPF_V_type = {transit_id:5, neighbor_id:5};
	var SRV_OSPF_V = [{transit_id:'10.10.10.10', neighbor_id:'20.20.20.20'}, {transit_id:'5.5.5.5', neighbor_id:'15.15.15.15'}];
}
else{
	<%net_Web_show_value('SRV_OSPF_A');%>
	<%net_Web_show_value('SRV_OSPF_V');%>
}

var myForm;
var newdata = new Array;

var table_idx = 0;
var tablefun = new table_show(document.getElementsByName('myForm'), "show_available_table", SRV_OSPF_V_type, SRV_OSPF_V, table_idx, newdata, Addformat, 0);

var transit_id_op = [{value:0, text:"----------"}];
var selstate = {type:'select', id:'transit_id', name:'transit_id', size:1, style:'width:125px', option:transit_id_op};

function setTransitIdOp()
{
	var i;

	for(i=0;i<SRV_OSPF_A.length;i++){
		if((SRV_OSPF_A[i].area_id != '0.0.0.0') && (SRV_OSPF_A[i].area_type == 1)){
		
			var new_op = new Option(SRV_OSPF_A[i].area_id, SRV_OSPF_A[i].area_id);
			document.getElementById("transit_id").options.add(new_op);
		}
	}
}

function Addformat(mod, i)
{
	var j = 0, k;

	for(k in SRV_OSPF_V_type){

		if(mod == 0){
			newdata[j] = SRV_OSPF_V[i][k]; 			
		}
		else{
			newdata[j] = document.getElementById('myForm')[k].value;
		}

		j++;
	}
}

function EditRow(row) 
{
	fnLoadForm(myForm, SRV_OSPF_V[row], SRV_OSPF_V_type);
	ChgColor('tri', SRV_OSPF_V.length, row);
}

function Total_IP()
{
	if(SRV_OSPF_V.length > SRV_OSPF_V_MAX || SRV_OSPF_V.length  < 0){		
		alert('Number of OSPF virtual link is over or wrong');
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}else if(SRV_OSPF_V.length == SRV_OSPF_V_MAX){
		with(document.myForm){
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}else if(SRV_OSPF_V.length == 0){		
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

	setTransitIdOp();

	tablefun.show();
	EditRow(0);
	Total_IP();
}

function tabbtn_sel(form, sel)
{
	if((sel == 0) || (sel == 2)){ // add or modify

		if(sel == 0){ // add
			table_idx = SRV_OSPF_V_MAX;
		}
		else{ // modify
			table_idx = tNowrow_Get();
		}
		
		if(duplicate_check(table_idx, SRV_OSPF_V, "transit_id", document.getElementById('transit_id').value, "Duplicated OSPF Transit Area ID")<0){
			return;
		}

		if(form.transit_id.value == 0){
			alert("No OSPF Transit Area ID");
			return;
		}

		if(!IsIpOK(form.neighbor_id, OSPF_V_NEIGHBOR_ID)){
			return;
		}

		if(form.neighbor_id.value == '0.0.0.0'){
			alert("Invalid Neighbor Router ID");
			return;
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

function Activate(form)
{
	var i, j;

	form.SRV_OSPF_V_tmp.value = "";

	for(i=0;i<SRV_OSPF_V.length;i++){
		for(j in SRV_OSPF_V[i]){

			form.SRV_OSPF_V_tmp.value = form.SRV_OSPF_V_tmp.value + SRV_OSPF_V[i][j] + "+";
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_OSPF_V";	
	form.submit();
}

function stopSubmit()
{
	return false;
}

</script>
</head>

<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(OSPF_V_SETTING)</script></h1>

<fieldset>
<form id=myForm name=myForm method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_OSPF_V_tmp" id="SRV_OSPF_V_tmp" value="">
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_V_TRANSIT_ID)</script> </td>
		<td> <script language="JavaScript">fnGenSelect(selstate, '')</script> </td>
	</tr>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_V_NEIGHBOR_ID)</script> </td>
		<td> <input type="text" id=neighbor_id name="neighbor_id" style="width:125px" maxlength=15> </td>
	</tr>
</table>

<table border=0>
	<tr>
		<td width=400px> <script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script>
						 <script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
						 <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script> </td>
		<td width=300px> <script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script> </td>
	</tr>
</table>
</form>

<table align=left border=0>
	<tr style="height:50px"></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" border=0 style="width:600px">
	<tr> 
		<td colspan=2></td> 
	</tr>
	<tr>
		<th width=200px> <script language="JavaScript">doc(OSPF_V_TRANSIT_ID)</script> </th>
		<th width=200px> <script language="JavaScript">doc(OSPF_V_NEIGHBOR_ID)</script> </th>
	</tr>
</table>

</fieldset>
</body>
</html>
