<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

checkMode(<% net_Web_GetMode_WriteValue(); %>);
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkCookie();

if (!debug) {
	var SRV_MTU_ADJUST_type = {mtu:4,manual:3};
	var SRV_MTU_ADJUST=[
	{mtu:'1500',manual:'1'},
	{mtu:'1501',manual:'1'},
	{mtu:'1502',manual:'0'}];
}
else{

	<%net_Web_show_value('SRV_MTU_ADJUST');%>	
		
}

var ifs_options = [ <% net_Web_IFS_WriteInteger_Have_All_Value(); %> ];
	
var actb = 'Active';
var myForm;

var	BridgeIdx;

function limit_mtu_write()
{
	var i;

	if(BridgeIdx >= 0){	// this function only work on bridge interface, so if bridge is not exist, we don't need to go ahead.
		
		for(i=0 ; i < SRV_MTU_ADJUST.length; i++){
			if(document.getElementById('prp'+BridgeIdx).checked == true){
				document.getElementById('mtu'+BridgeIdx).disabled = "true";
			}
			else{
				document.getElementById('mtu'+BridgeIdx).disabled = "";
			}
		}
	}
}

function fnInit() {
	var i;
	myForm = document.getElementById('myForm');	
	//fnLoadForm(myForm, SRV_MTU_ADJUST, SRV_MTU_ADJUST_type);	

	BridgeIdx = -1;
	for(i=0 ; i < SRV_MTU_ADJUST.length; i++){		
		if(SRV_MTU_ADJUST[i].ifs > 8000){
			BridgeIdx = i;
			break;
		}
	}

	limit_mtu_write();
}

var item_name="mtuadjust";

/*	when click prp's checkbox, disable the mtu input right away.
  */
function clickManual()
{
	var i;

	if(BridgeIdx >= 0){	// this function only work on bridge interface, so if bridge is not exist, we don't need to go ahead.

		/* limit the privilege of writng by checkinp prp is set or not. */
		limit_mtu_write();
		
		for(i=0 ; i < SRV_MTU_ADJUST.length; i++){
			if(document.getElementById('prp'+BridgeIdx).checked == true){
				document.getElementById('mtu'+BridgeIdx).value = 1578;
			}
			else{
				document.getElementById('mtu'+BridgeIdx).value = 1500;
			}
		}
	}
}

function Addformat(idx, data, newdata)
{	
	if(SRV_MTU_ADJUST[idx].ifs > 0){
		newdata[0] = fnGetSelText(SRV_MTU_ADJUST[idx].ifs, ifs_options);
	}
	
	newdata[1] = '<input type=text id='+'mtu'+idx+' name='+'mtu'+idx+' size=10 maxlength=5>';	 
	newdata[2] = '<input type=checkbox id='+'prp'+idx+' name='+'prp'+idx+ ' onclick=clickManual()' + '>';
}

function tableaddRowWithDisplay(tablename, idx, data)
{
	var i, j;
	var cell;
	var row;
		
	table = document.getElementById(tablename);
	row = table.insertRow(table.getElementsByTagName("tr").length);


	for(i=0 ; i < data.length; i++){
		cell = document.createElement("td");
		cell.innerHTML = data[i];	
		row.appendChild(cell);
	}
	
	row.style.Color = "black";
	row.className = "r1";
	row.align="center";

	document.getElementById('mtu'+idx).value = SRV_MTU_ADJUST[idx].mtu;
	
	if(SRV_MTU_ADJUST[idx].prp == 1)
		document.getElementById('prp'+idx).checked = true;
	else
		document.getElementById('prp'+idx).checked = false;

} 

function PrintTable() {
	var newdata=new Array;
	var i;
	document.write('<tr">');
	document.write('<table border="0" id="show_available_table" style="width:250px">');
	document.write('<tr align="center" class="r5">');
	document.write('<td width=60px">'+Interface_+'</td>');
	document.write('<td width=50px">'+MTU_+'</td>');
	document.write('<td>'+PRP_TRAFFIC_+'</td>');
	document.write('</tr>');
	document.write('</table>');
	document.write('<tr align="center">');

	for(i=0; i < SRV_MTU_ADJUST.length; i++){

		if(SRV_MTU_ADJUST[i].ifs > 0){	// bridge mode	
			Addformat(i, SRV_MTU_ADJUST[i], newdata);
			tableaddRowWithDisplay("show_available_table", i, newdata);

			if(SRV_MTU_ADJUST[i].ifs < 8000){
				document.getElementById('prp'+i).disabled = "true";
			}
		}
	}
}

function MtuCheckFormat(form)
{
	var error = 0;
	var ifs_idx;

	var interface_name;
	var vlan_mtu;
	var ifs_mtu;
	
	for(var i=0; i < SRV_MTU_ADJUST.length; i++){
		if(SRV_MTU_ADJUST[i].ifs > 0){
			if(document.getElementById('prp'+i).checked == false){	// check mtu when prp is disabled.
				if(!IsMtuOK(document.getElementById('mtu'+i), fnGetSelText(SRV_MTU_ADJUST[i].ifs, ifs_options))){
					error=1;
				}
			}
		}
	}

	return error;
}

function Activate(form)
{
	if(MtuCheckFormat(form)==1){
		return;
	}
	
	form.SRV_MTU_ADJUST_tmp.value = "";

	for(var i=0; i < SRV_MTU_ADJUST.length; i++){
		if(SRV_MTU_ADJUST[i].ifs > 0){
			SRV_MTU_ADJUST[i].mtu = document.getElementById('mtu'+i).value;

			if(document.getElementById('prp'+i).checked == true)
				SRV_MTU_ADJUST[i].prp = 1;
			else
				SRV_MTU_ADJUST[i].prp = 0;
		}
			
	}
	for(var i = 0 ; i < SRV_MTU_ADJUST.length ; i++){
		for (var k in SRV_MTU_ADJUST[i]){
			form.SRV_MTU_ADJUST_tmp.value = form.SRV_MTU_ADJUST_tmp.value + SRV_MTU_ADJUST[i][k] + "+";		
		}				
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_MTU_ADJUST";	
	form.submit();	
}
function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(MTU_ADJUST_SETTING)</script></h1>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST"  onSubmit="return stopSubmit()" >
<input type="hidden" name="vif" id="vif" value="0" >
<input type="hidden" name="SRV_MTU_ADJUST_tmp" id="SRV_MTU_ADJUST_tmp" value="" >
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0 align=center width=250px>
	<tr align="left">

  <script language="JavaScript">PrintTable()</script>

<td></td>
   </tr> 
</table>

<p><table class=tf align=left>
 <tr>
  <td style="width:600px" align=left><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
  <td width=15></td></tr>
</table></p>

</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

