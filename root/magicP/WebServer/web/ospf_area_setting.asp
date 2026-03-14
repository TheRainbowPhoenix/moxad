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
}
else{
	<%net_Web_show_value('SRV_OSPF_A');%>
}

var myForm;
var newdata = new Array;

var table_idx = 0;
var tablefun = new table_show(document.getElementsByName('myForm'), "show_available_table", SRV_OSPF_A_type, SRV_OSPF_A, table_idx, newdata, Addformat, 0);

var area_type_op = [{value:1, text:OSPF_A_NORMAL}, {value:2, text:OSPF_A_STUB}, {value:3, text:OSPF_A_NSSA}];
var selstate = {type:'select', id:'area_type', name:'area_type', size:1, onChange:'fnTypeSel(this.value)', style:'width:125px', option:area_type_op};

function fnTypeSel(sel_value)
{
	if(sel_value == 1){ // Normal
		//document.getElementById('metric').value = 0;
		document.getElementById('metric').value = ' - ';
		document.getElementById('metric').disabled = true;
	}
	else{ // Stub, NSSA
		document.getElementById('metric').disabled = false;
	}
}

function Addformat(mod, i)
{
	var j = 0, k;

	for(k in SRV_OSPF_A_type){

		if(mod == 0){

			if((k == 'metric') && (SRV_OSPF_A[i][k] == 0)){
				SRV_OSPF_A[i][k] = ' - ';
			}
			
			newdata[j] = SRV_OSPF_A[i][k]; 			
		}
		else{
			newdata[j] = document.getElementById('myForm')[k].value;
		}

		if(document.getElementsByName(k)[0].type == "select-one"){
			newdata[j] = area_type_op[newdata[j]-1].text;
		}

		j++;
	}
}

function EditRow(row) 
{
	fnLoadForm(myForm, SRV_OSPF_A[row], SRV_OSPF_A_type);
	ChgColor('tri', SRV_OSPF_A.length, row);
}

function Total_IP()
{
	if(SRV_OSPF_A.length > SRV_OSPF_A_MAX || SRV_OSPF_A.length  < 0){		
		alert('Number of OSPF Area is over or wrong');
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}else if(SRV_OSPF_A.length == SRV_OSPF_A_MAX){
		with(document.myForm){
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}else if(SRV_OSPF_A.length == 0){		
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

	tablefun.show();
	EditRow(0);
	Total_IP();
}

function tabbtn_sel(form, sel)
{
	if((sel == 0) || (sel == 2)){ // add or modify

		if(sel == 0){ // add
			table_idx = SRV_OSPF_A_MAX;
		}
		else{ // modify
			table_idx = tNowrow_Get();
		}
		
		if(duplicate_check(table_idx, SRV_OSPF_A, "area_id", document.getElementById('area_id').value, "Duplicated OSPF Area ID")<0){
			return;
		}

		if(!IsIpOK(form.area_id, OSPF_A_AREAID)){
			return;
		}

		if(form.area_type.value != 1){ // check metric value when stub and NSSA			
			if((isNaN(form.metric.value) == true) || (form.metric.value < 1) || (form.metric.value > 65535)){
				alert("OSPF Area Metric Over Range. (1 - 65535)");
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

function Activate(form)
{
	var i, j;

	form.SRV_OSPF_A_tmp.value = "";

	for(i=0;i<SRV_OSPF_A.length;i++){
		for(j in SRV_OSPF_A[i]){

			if((j == 'metric') && (SRV_OSPF_A[i][j] == ' - ')){
				SRV_OSPF_A[i][j] = 0;
			}

			form.SRV_OSPF_A_tmp.value = form.SRV_OSPF_A_tmp.value + SRV_OSPF_A[i][j] + "+";
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_OSPF_A";	
	form.submit();	
}

function stopSubmit()
{
	return false;
}

</script>
</head>

<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(OSPF_A_SETTING)</script></h1>

<fieldset>
<form id=myForm name=myForm method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_OSPF_A_tmp" id="SRV_OSPF_A_tmp" value="">
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_A_AREAID)</script> </td>
		<td> <input type="text" id=area_id name="area_id" style="width:125px" maxlength=15> </td>
	</tr>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_A_AREATYPE)</script> </td>
		<td> <script language="JavaScript">fnGenSelect(selstate, '')</script> </td>
	</tr>
	<tr height=25px>
		<td width=125px> <script language="JavaScript">doc(OSPF_A_METRIC)</script> </td>
		<td> <input type="text" id=metric name="metric" style="width:125px" maxlength=15> </td>
	</tr>
</table>

<table border=0>
	<tr>
		<td width=400px> <script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script>
						 <script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
						 <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script>
		<td width=300px> <script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script> </td>
	</tr>
</table>
</form>

<table align=left border=0>
	<tr style="height:50px"></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" border=0 style="width:600px">
	<tr> 
		<td colspan=3></td> 
	</tr>
	<tr>
		<th width=200px> <script language="JavaScript">doc(OSPF_A_AREAID)</script> </th>
		<th width=200px> <script language="JavaScript">doc(OSPF_A_AREATYPE)</script> </th>
		<th width=200px> <script language="JavaScript">doc(OSPF_A_METRIC)</script> </th>
	</tr>
</table>
</fieldset>

</body>
</html>
