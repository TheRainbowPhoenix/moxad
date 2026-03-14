<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
if (!debug) {
	var wdata = [
		{ 	sm_en:'0', sm_gaddr:'1.1.1.1', sm_sip:'2.2.22.2', sm_from:'3', 
			sm_to1:'1', sm_to2:'2', sm_to3:'3',
			sm_to4:'4', sm_to5:'5', sm_to6:'0',
			sm_to7:'0', sm_to8:'0', sm_to9:'0',
			sm_to10:'0', sm_to11:'0', sm_to12:'0',
			sm_to13:'0', sm_to14:'0', sm_to15:'0',
			sm_to16:'0'
		},
		{ 	sm_en:'0', sm_gaddr:'1.1.1.1', sm_sip:'2.2.22.2', sm_from:'3', 
			sm_to1:'5', sm_to2:'4', sm_to3:'1',
			sm_to4:'2', sm_to5:'0', sm_to6:'0',
			sm_to7:'0', sm_to8:'0', sm_to9:'0',
			sm_to10:'0', sm_to11:'0', sm_to12:'0',
			sm_to13:'0', sm_to14:'0', sm_to15:'0',
			sm_to16:'0'
		}
	];	
	var ifs = [ { value:'1',text:'LAN' } , 
		{ value:'2',text:'LAN2' } , { value:'3',text:'LAN3' } , 
		{ value:'4',text:'LAN4' } , { value:'5',text:'LAN5' } , 
		{ value:'6',text:'LAN6' }  ];

}
else{

	var wdata = [ <%net_webSMulticast();%> ];
	
	var ifs = [ <% net_Web_IFS_WriteIntegerValue(); %>  ];
}

var EDR_MAX_IFS = 16;
var EDR_MAX_SMC_ROUTES = 32;

var addb = 'Add';
var modb = 'Modify';
var delb = 'Delete';
	

var wtype = {
	sm_en:3, sm_gaddr:5, sm_sip:5, sm_from:2, 
	sm_to1:3, sm_to2:3, sm_to3:3,
	sm_to4:3, sm_to5:3, sm_to6:3,
	sm_to7:3, sm_to8:3, sm_to9:3,
	sm_to10:3, sm_to11:3, sm_to12:3,
	sm_to13:3, sm_to14:3, sm_to15:3,
	sm_to16:3
};


var newdata=new Array;
var myForm;


var table_idx = 0;
var tablefun = new table_show(document.getElementsByName('smcast_set_form'), "show_available_table" ,wtype, wdata, table_idx, newdata, Addformat, EntryInit);

// Use this function to make the sm_toX synchronous with ifs index
function SMCRoute_wdataResync()
{
	var rowIdx = 0;
	var i;
	var newi;
	var ifIdx = 0, ifValue = 0;
	var ifsMatch = 0, ifsTotalLength = ifs.length;
	var smtoIdx = 0;
	var smtoNew = new Array();


	for(rowIdx = 0; rowIdx < wdata.length; rowIdx++) {
		// Initialize the new
		for(i = 0; i < EDR_MAX_IFS; i++) {
			smtoNew[i] = 0;
		}

		for(i in wdata[rowIdx]){
			
			if(i >= 'sm_to1'){
				
				ifsMatch = 0;
				for(ifIdx = 0; ifIdx < ifsTotalLength; ifIdx++) {
					ifValue = ifs[ifIdx].value;

					// i meant sm_to1~sm_to16					
					if(wdata[rowIdx][i] == ifValue) {
						newi = 'sm_to'+(ifIdx+1);
						//alert("newi = " +newi);						
						smtoNew[ifIdx] = wdata[rowIdx][i];
																		
						ifsMatch = 1;
						break;
					}						
					
				}

				if(wdata[rowIdx][i]!= 0 && !ifsMatch) { // Clear the config related to non-existed Vif
					smtoNew[smtoIdx] = 0;
				} 

				smtoIdx++; 
			}				
				
		}	

		smtoIdx = 0;
		for(i in wdata[rowIdx]) {
			if(i >= 'sm_to1') {
				//alert("sm_to = " + smtoNew[sm_toIdx] + "wdata[]=" + wdata[rowIdx][i]);
				wdata[rowIdx][i] = smtoNew[smtoIdx];

				smtoIdx++;
			}			
		}
	}

	return 0;
}

function fnInit() 
{	
	myForm = document.getElementById('smcast_set_form');	

	SMCRoute_wdataResync();
	tablefun.show();
	Total_IP();
	
	EditRow(0);
	EntryInit(0);
}


function EditRow(row) 
{
	fnLoadForm(myForm, wdata[row], wtype);
	ChgColor('tri', wdata.length, row);
}

function EntryInit(row) 
{
	//alert("row="+row + ",sip="+wdata[row].sm_sip);
	
	if(wdata.length > 0 && row >= 0){
		if(wdata[row].sm_sip == "ANY") {
			document.getElementById("sip_sel").value=1;
			document.getElementById("sm_sip").disabled=1;
			document.getElementById("sm_sip").value="ANY";			
		}
		else {
			document.getElementById("sip_sel").value=0;
			document.getElementById("sm_sip").disabled=0;
			document.getElementById("sm_sip").value= wdata[row].sm_sip;
		}
	}

	return 0;
}

function Total_IP()
{			
	if(wdata.length > EDR_MAX_SMC_ROUTES || wdata.length  < 0){		
		alert('Number of static multicast route is over or wrong');
		with(document.smcast_set_form){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}else if(wdata.length == EDR_MAX_SMC_ROUTES){
		with (document.smcast_set_form) {
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}else if(wdata.length == 0){		
		with (document.smcast_set_form) {		
			btnA.disabled = false;
			btnD.disabled = true;
			btnM.disabled = true;
			btnS.disabled = false;
		}
	}else{		
		with (document.smcast_set_form) {		
			btnA.disabled = false;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}
	document.getElementById("totalsmcnt").innerHTML = '('+wdata.length +'/' +EDR_MAX_SMC_ROUTES+')';
	//document.getElementById("totalsmcnt").innerHTML = wdata.length + ' / 256';
}

function IPToNumber(s)
{
	var arr = s.split(".");
	var n = 0
	for (var i = 0; i < 4; i++)
	{
		n = n * 256
		n += parseInt(arr[i],10)

	}
	
	return n;
}

function IpAddrIsMcast(Obj, ObjName) 
{
	var iv = Obj.value.split('.');
	var min = IPToNumber("224.0.0.0");
	var max = IPToNumber("239.255.255.255");
	var ipNum;
	var isValid = 0;
	
	if (iv.length != 4) {
		alert("Error: "+ObjName+" is invalid.");
		return 0;
	}

	if(!IsIpOK(Obj, ObjName)) {
		return 0;
	}
	
	ipNum = IPToNumber(Obj.value);
	isValid = (ipNum != 0 && (ipNum > min && ipNum <= max));

	if (!isValid) {
		alert("Error: "+ObjName+" is not valid multicast address.");
		return 0;
	}
	
	return 1;
}

function SMCRoute_modify(row_idx)
{
	var i = 1;
	var j = 0;
	
	for(i in wdata[row_idx]){
	
		if(i >= 'sm_to1'){
			//alert('sm_to'+(j+1));	
			if(document.getElementById(i).checked == true){ // i meant sm_to1~sm_to16
				//alert('i ='+ i + ', j =' + j + 'length =' + ifs.length + ifs[j].value);
				if(j < ifs.length) { // Check to avoid abnormal case
					wdata[row_idx][i] = ifs[j].value;
				}
				//alert(row_idx + ', ' + i + ', '+wdata[row_idx][i]);
			}
			else {
				wdata[row_idx][i] = 0;
			}
			j++;
		}
		
	}

	//alert(wdata[row_idx][4+1]);
	//alert(nowrow-2);
}

function SMCRoute_checkSetting(form, action, row_idx)
{
	var rv = 0;
	var i = 0;
	var j = 0;
	var fromIntf = document.getElementById('sm_from').value;
	var outIntfNum = 0;
	var groupAddr = form.sm_gaddr.value;
	var sourceAddr = form.sm_sip.value;

	//alert("wdata length ="+ wdata.length+ ", row_idx="+ row_idx + ",(gaddr, sip)=" + groupAddr  + sourceAddr);
	for(i = 0; i < wdata.length; i++) {
		//alert('(gaddr, sip)= '+ wdata[i].sm_gaddr + wdata[i].sm_sip);
		if(action == 2) { // Modify
			if(i == row_idx) { // skip the same row
				continue;
			}
		}
		
		if((groupAddr == wdata[i].sm_gaddr) && (sourceAddr == wdata[i].sm_sip)) { 
			alert("Route exists, please edit the existing route.");
			return -1;
		}
	}
	
	//alert('sm_from intf= '+ fromIntf);	
	for(j = 1; j <= ifs.length; j++) {
		if(document.getElementById('sm_to'+j).checked == true){
			outIntfNum++;
			//alert("sm_to intf="+ifs[j-1].value);
			if(ifs[j-1].value == fromIntf) { // Outbound intf is equal to Inbound intf
				alert("The inbound interface should not be in the list of outbound interfaces.");
				rv = -2;
				
				break;
			}			
		}
	}

	if(outIntfNum <= 0) {
		alert("Missing outbound interface !");
		rv = -3;
	}

	return rv;
}

function tabbtn_sel(form, sel)
{	
	if(sel == 0 || sel == 2){ // Add or Modified	
		
		if(!IpAddrIsMcast(form.sm_gaddr, SMCRoute_Group_Addr)) {
			return;
		}
		
		if(form.sm_sip.value != 'ANY') {
			if(!(IpAddrIsOK(form.sm_sip,SMCRoute_Source_Addr))) {
				return;
			}
		}	

		if(SMCRoute_checkSetting(form, sel, nowrow-2) < 0) {
			return;
		}		
	}
	
	if(sel == 0){ // Add
		tablefun.add();	

		/* modify sm_to1~16 value by ifs vid, and reload table list */
		SMCRoute_modify(nowrow - 2);	// //nowrow is get from common.js 
		tablefun.reload();	
		ChgColor('tri', tablefun.data.length, tablefun.data.length-1);	
		//nowrow = (tablefun.data.length-1+2);
	}
	else if(sel == 1){ // Delete
		tablefun.del();
	}
	else if(sel == 2){ // Modify
		tablefun.mod();
		/* modify sm_to1~16 value by ifs vid, and reload table list */
		SMCRoute_modify(nowrow - 2);	// //nowrow is get from common.js 
		tablefun.reload();

		ChgColor('tri', tablefun.data.length, nowrow-2);
	}
	Total_IP();	
}

function funcSipSel(sel_index)
{	

	if(sel_index == 0) { // Specify source
		document.getElementById("sm_sip").disabled=0;
		document.getElementById("sm_sip").style.display="";
		document.getElementById("sm_sip").value="";
	}
	else if(sel_index == 1) { // ANY 
		document.getElementById("sm_sip").disabled=1;
		document.getElementById("sm_sip").value="ANY";
	}

	return 0;
}

function Addformat(mod,i)
{	
	var j;	
	var k;
	var idx;
	var vlan_number;
	var ifs_idx;
	var firstOutIntf = 1;
	
	j = 0;
	for(k in wtype){				
		
		if(k == 'sm_en'){
			if(wdata[i][k]==1)
				newdata[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
			else
				newdata[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
				
			j++;	
			continue;	
		}
						
		
		if(k == 'sm_from'){
			for(ifs_idx=0; ifs_idx<ifs.length; ifs_idx++){
				if(wdata[i][k] == ifs[ifs_idx].value)
					newdata[j] = ifs[ifs_idx].text;
					
			}

			
			//newdata[j] = ifs[wdata[i][k]].text;
			j++;
			newdata[j] = '';
			continue;
		}

		if(k >= 'sm_to1'){				
			if(wdata[i][k] != 0){
				if(!firstOutIntf) { // Use comma to separate
					newdata[j]+=', ';
				}
				
				for(ifs_idx=0; ifs_idx<ifs.length; ifs_idx++){					
					if(wdata[i][k] == ifs[ifs_idx].value) {
						newdata[j] += ifs[ifs_idx].text;
						firstOutIntf = 0;
					}						
				}
				
				//newdata[j] += ifs[wdata[i][k]-1].text;
			}
			continue;
		}
		
		newdata[j] = wdata[i][k];
		j++;
		newdata[j] = '';		
	}	
}


function Activate(form)
{	
	var i;
	var j;

	form.smtmp.value = "";
	
	for(i = 0 ; i < wdata.length ; i++)
	{	
		for (var j in wdata[i]){
			form.smtmp.value = form.smtmp.value + wdata[i][j] + "+";		
		}
	}

	form.action="/goform/net_WebSMCASTGetValue";	
	form.submit();	
}



function stopSubmit()
{
	return false;
}

var IFS_PER_ROW = 4;
function SMCRoute_showOutboundIfs(form)
{	
	var i, j;
	var col_span = 0;

	document.write('<table cellpadding=1 cellspacing=2 border=0 align="left" style="width:550px;">');

	document.write('<tr class="r2">');
	document.write('<td style="width:150px;">');
	document.write(SMCRoute_Outbound);
	document.write('</td>');
	
	//alert(ifs.length);
	for(i = 0 ; i < ifs.length ; i++){
		if(i%IFS_PER_ROW == 0 && i != 0){
			document.write('<tr class="r2" align="left">');
			document.write('<td style="width:150px;"></td>');

		}

		document.write('<td style="width:20px;">');
		//alert('<input type="checkbox" id=sm_to'+i+'name="sm_to'+i+'">');
		document.write('<input type="checkbox" id=sm_to'+(i+1)+' name="sm_to'+(i+1)+'">');
		document.write('</td>');
		document.write('<td style="width:60px;">'+ ifs[i].text + '</td>');
			
		if(i%IFS_PER_ROW == (IFS_PER_ROW-1)){
			document.write('<td colspan="1"></td></tr>'); // colspan for auto adjust column width
		}
	}


	for(i = ifs.length ; i < EDR_MAX_IFS ; i++){
		if(i%IFS_PER_ROW == 0){ // next row
			document.write('<tr class="r2">');
			document.write('<td style="width:150px;"></td>');
		}
		
		document.write('<td style="display:none; width=20px;">');
		document.write('<input type="checkbox" id=sm_to'+(i+1)+' name="sm_to'+(i+1)+'">');
		document.write('</td>');
		

		if(i%IFS_PER_ROW == (IFS_PER_ROW-1)){
			col_span = IFS_PER_ROW - (i % IFS_PER_ROW) + 1;
			document.write('<td colspan='+ col_span + '> </td>'); // colspan for auto adjust column width
			document.write('</tr>');
		}
	}

	
/*	
	document.write('<td style="width:10px;" align="left" >'+WAN1_+'</td>');
	document.write('<td style="width:10px;" align="left"><input type="checkbox" id=smwan1 name="sm_wan1"></td>');
*/
	
	//document.write('</tr>');
	
	document.write('</table>');
}
 



</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(SMCRoute)</script></h1>
<fieldset>
<form id="smcast_set_form" name="smcast_set_form" method="POST" onSubmit="return stopSubmit()">

<input type="hidden" name="sm_tmp" id="smtmp" value="" >
<% net_Web_csrf_Token(); %>
<DIV style="height:200px;">
<table cellpadding=1 cellspacing=2 border=0 width=400px>
 <tr align="left">
  <td width=150px><script language="JavaScript">doc(Enable_)</script></td>
  <td><input type="checkbox" id="sm_en" name="sm_en"></td> </tr>
 <tr align="left">
  <td width=150px><script language="JavaScript">doc(SMCRoute_Group_Addr)</script></td>
  <td><input type="text" id="sm_gaddr" name="sm_gaddr" style="width: 120px" size=15 maxlength=15></td></tr>
 <tr align="left">  
  <td width=150px><script language="JavaScript">doc(SMCRoute_Source_Addr)</script></td> 
  <td><select size=1 name="sip_sel" id="sip_sel" style="width: 120px" onchange="funcSipSel(this.selectedIndex);">	
		<option value="0">Specify Source</option>
		<option value="1">ANY</option>
	</select>&nbsp;&nbsp;<input type="text" id="sm_sip" name="sm_sip" size=15 maxlength=15></td></tr>
 <tr align="left">   
  <td width=150px><script language="JavaScript">doc(SMCRoute_Inbound)</script></td>
  <td><script language="JavaScript">iGenSel2('sm_from', 'sm_from', ifs)</script></td></tr>   
</table>

<script language="JavaScript">SMCRoute_showOutboundIfs()</script>
</DIV>

</form>

<p><table class=tf>
<tr>
  <td width="400px" style="text-align:left;">
	  <script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(smcast_set_form,0)', 'btnA')</script>
	  <script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(smcast_set_form,1)', 'btnD')</script>
	  <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(smcast_set_form,2)', 'btnM')</script>
  </td>
  <td width="300px" style="text-align:left;">
  	<script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(smcast_set_form)', 'btnS')</script>
  </td>  
 
</tr>
</table></p>


<table cellpadding=1 cellspacing=2>
<tr class=r0>
 <td width=200px><script language="JavaScript">doc(SMCRoute_List)</script></td>
 <td id = "totalsmcnt" colspan=5></td></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" >
<tr><td colspan=5> </td></tr>
 <tr align="center">
  <th width=100px><script language="JavaScript">doc(Enable_)</script></th>
  <th width=150px><script language="JavaScript">doc(SMCRoute_Group_Addr)</script></th>
  <th width=150px><script language="JavaScript">doc(SMCRoute_Source_Addr)</script></th>
  <th width=150px><script language="JavaScript">doc(SMCRoute_Inbound)</script></th> 
  <th width=350px><script language="JavaScript">doc(SMCRoute_Outbound)</script></th></tr>
</table>

</fieldset>
</body></html>

