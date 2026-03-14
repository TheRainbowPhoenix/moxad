<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(VLAN_SETTING)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
if (!debug) {
	var wdata0 = {
		enable:'1', vid:'0', ip:'192.168.45.1',mask:'255.255.255.0'		
	};	
	var wtype0 = {
		enable:3, vid:4, ip:5, mask:5 
	};
}else{	
	<%net_Web_show_value('SRV_VLAN');%>	
	<%net_Web_show_value('SRV_TRUNK_SETTING');%>		
}


/*var iftyp0 = [
	{ value:0, text:Static_IP },	{ value:1, text:Dynamic_IP },
	{ value:4, text:PPPoE_ }
];*/

var newdata0=new Array;
var myForm;
var table_index, table_idx=0;				

var port_sel = [{ value:0, text:'------' }, { value:1, text:'Tagged' }, { value:2, text:'Untagged' }];
var tablefun=new table_show(document.getElementsByName('form1'),"show_available_table" ,SRV_VLAN_type, SRV_VLAN, table_idx, newdata0, Addformat, 0);
var first_if;
var port_count;
var trk_count=0;
var trk_group=new Array;
var VLAN_MAX = 16;
var port_name="port";
var trk_name="trk";
function Total_IP()
{
	if(SRV_VLAN.length > VLAN_MAX || SRV_VLAN.length  < 1){		
		alert('Number of ip is Over or Wrong');
		with(document){
			getElementById('btnA').disabled = false;			
			getElementById('btnD').disabled = false;			
			getElementById('btnM').disabled = false;			
			getElementById('btnS').disabled = true;
		}				
	}else if(SRV_VLAN.length == VLAN_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else if(SRV_VLAN.length == 1){		
		with (document) {		
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else{		
		with (document) {		
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}	
	document.getElementById("totalipcnt").innerHTML = VLAN_IF_List + ' ('+SRV_VLAN.length +'/' +VLAN_MAX+')';
}

function set_trk_grup(){
	var i;
	trk_group[0]=new Array;
	trk_group[1]=new Array;
	for(i=0;i<port_count;i++){
		if(SRV_TRUNK_SETTING[i]["trkgrp"]>trk_count){
			trk_count = SRV_TRUNK_SETTING[i]["trkgrp"];
		}
		if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0){
			trk_group[0][trk_name+(SRV_TRUNK_SETTING[i]["trkgrp"]-1)]=i;
			trk_group[1][trk_name+(SRV_TRUNK_SETTING[i]["trkgrp"]-1)]|=1<<i;			
		}
	}
}

function trk_member_change(idx,index){
	var i, name;
	for(i=0; i<trk_count; i++){
		name = trk_name+i;
		if(trk_group[0][name]==index){
			document.getElementById('myForm')[name].value =idx.value;
		}
	}
}


function set_trk_member_vlaus(idx){
	var i,j, name,name2, value;

	name=idx.name;
	value=idx.selectedIndex;
	for(i=0;i<port_count;i++){
		if(trk_group[1][name]&(1<<i)){
			name2=port_name+i;			
			document.getElementById('myForm')[name2].value = value;
		}	
	}	
}

function show_Port_sel(){
	var i, j, value;
	port_count=0;
	for(i in SRV_VLAN_type){
		if(i.substring(0, 4)==port_name){			
			port_count++;
		}
	}
	set_trk_grup();
	value = parseInt(port_count)+parseInt(trk_count);

	document.write('<table cellpadding=0 cellspacing=0 border=0 width=600>');

	document.write('<tr class=r1>');
	for(i=0,j=0; i < value; i++){
		if(i<port_count){
			if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0){
				document.write('<input type="hidden" name='+port_name+i+' id='+port_name+i+' onchange="trk_member_change(this,'+i+')"'+' value="" >');
				continue;
			}else{
				document.write('<td><nobr><b>PORT '+(i+1)+'</b></nobr><td>');
				iGenSel2(port_name+i, port_name+i, port_sel);
			}
		}else{
			if(!trk_group[0][trk_name+(i-port_count)])
				continue;
			document.write('<td><nobr><b>trk '+(i-port_count+1)+'</b></nobr><td> ');
			iGenSel2(trk_name+(i-port_count), trk_name+(i-port_count) + ' onchange="set_trk_member_vlaus(this)"', port_sel);
		}
		document.write('</td>');
		if(j%5==4)
			document.write('</tr><tr class=r1>');
		j++;
	}
	document.write('</tr>'); 
	document.write('</table>');

}

function show_Port_table(){
	var i,value;
	value = parseInt(port_count)+parseInt(trk_count);
	for(i=0; i < value; i++){
		if(i<port_count){
			if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0){
				continue;
			}else{
				document.write('<td width=80px align="center">'+(i+1)+'</td>');		
			}
		}else{
			if(!trk_group[0][trk_name+(i-port_count)])
				continue;
			document.write('<td width=80px align="center">trk'+(i-port_count+1)+'</td>');		
		}
	}
	document.getElementById("table_port").colSpan=port_count;
	document.getElementById("table_port").style.width=port_count*80;
	document.getElementById("table_port").style.textAlign="center";

}

function tabbtn_sel(form, sel)
{	
	if(sel == 0 || sel == 2){
		if(sel == 0){
			table_idx = VLAN_MAX;
		}else{
			table_idx = tNowrow_Get();
		}
	}
	var now_row= tNowrow_Get();
	if(document.getElementById("vlanid").value > 4094||document.getElementById("vlanid").value < 1){
		alert(V_ID_+"must between 1 ~ 4094");
		return;	
	}
	if(sel == 0){		
		Addformat(1,0);
		tablefun.add();	
	}else if(sel == 1){
		if(now_row == 0)
			return;
		tablefun.del();
	}else if(sel == 2){
		tablefun.mod();
	}
	Total_IP();	
}

function Addformat(mod,i)
{	
	var j=0, str, i, trk_idx;	
	var k;
	j = 0;

	for(k in SRV_VLAN_type){		
		if(document.getElementsByName(k)[0].type=="hidden")
			continue;
		if(mod==0){
			newdata0[j] = SRV_VLAN[i][k]; 			
		}else{
			newdata0[j] = document.getElementById('myForm')[k].value;
		}
		if(document.getElementsByName(k)[0].type=="select-one"){
			var tmp=document.getElementsByName(k)[0];
			var idx;
			for(idx = 0; idx< tmp.length; idx++){
				if(tmp.options[idx].value==newdata0[j]){
					if(tmp.options[idx].value==1){
						newdata0[j]="T";
					}else if(tmp.options[idx].value==2){
						newdata0[j]="U";
					}else{
						newdata0[j]=tmp.options[idx].text;
					}
					
					break;
				}
			}
		}
		
		j++;
	}

	for(trk_idx=0; trk_idx<trk_count; trk_idx++){
		k=trk_name+trk_idx;
		if(!trk_group[0][trk_name+(trk_idx)])
			continue;
		if(mod==0){
			newdata0[j] = SRV_VLAN[i][port_name+trk_group[0][k]];
		}else{
			newdata0[j] = document.getElementById('myForm')[k].value;
		}
		if(document.getElementsByName(k)[0].type=="select-one"){
			var tmp=document.getElementsByName(k)[0];
			var idx;
			for(idx = 0; idx< tmp.length; idx++){				
				if(tmp.options[idx].value==newdata0[j]){
					if(tmp.options[idx].value==1){
						newdata0[j]="T";
					}else if(tmp.options[idx].value==2){
						newdata0[j]="U";
					}else{
						newdata0[j]=tmp.options[idx].text;
					}				
					break;				
				}
			}
		}
		j++;
	}
	
}


function Activate(form)
{	
	var i,j,k;

	form.vlantmp.value="";
	for(j = 0 ; j < SRV_VLAN.length ; j++)
	{
		for (var k in SRV_VLAN[j]){
			form.vlantmp.value = form.vlantmp.value + SRV_VLAN[j][k] + "+";		
		}
	}		

	form.action="/goform/net_Web_get_value?SRV=SRV_VLAN";	
	form.submit();	
}
var if_data=new Array;
function fnInit() {	
	var i;
	
	myForm = document.getElementById('myForm');		
	tablefun.show();
	if(SRV_VLAN[0]){
		fnLoadForm(myForm, SRV_VLAN[0], SRV_VLAN_type);			
	}
	Total_IP();
}
var chflag=0xff;

function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_VLAN_tmp" id="vlantmp" value="" >
<input type="hidden" name="name" id="v_name" value="" >
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border =0>
<tr><td>
<table align=left cellpadding=1 cellspacing=1 border=0 width=600px>
 <tr class=r0>
  <td width=150px colspan=2><script language="JavaScript">doc(VLAN_SETTING)</script></td></tr>
 <tr class=r2 align="left">
  <td width=50px><nobr><b><script language="JavaScript">doc(V_ID_)</script></b></nobr></td>
  <td width=600px><input type="text" id=vlanid name="vlanid" size=4 maxlength=4></td>
  </tr>
 <tr class=r2 align="left"> 
  <td colspan=2><DIV><script language="JavaScript">show_Port_sel()</script></DIV></td></tr>
</table>
</td></tr>
<tr><td>
<table align=left border=0>
 <tr>
  <td width=50px><script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script></td>
  <td width=70px><script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script></td>
  <td width=120px><script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td></tr>
 <tr>
  <script language="JavaScript">color_line("blue",4)</script>
 </tr>
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2 id="lan_table" border=0>
<tr>
</tr>
<tr>
</tr>
<tr><td>
<table cellpadding=1 cellspacing=2 border=0>
<tr class=r0>
 <td id = "totalipcnt" colspan=3></td>
 <td></td></tr>
 <table cellpadding=1 cellspacing=2 id="show_available_table" border=0>
  <tr class=r5>
   <td width=80px rowspan=2 align="center"><script language="JavaScript">doc(V_ID_)</script></td>
  	<td class=r5 width=120px id = "table_port" align="center"><script language="JavaScript">doc(Port_)</script></td>
  	<tr class=r5>
 	  <script language="JavaScript">show_Port_table()</script>
 	</tr>
   </td>
  </tr>
 </table>
</table>
</td></tr>
<table>
</form>
</body></html>
