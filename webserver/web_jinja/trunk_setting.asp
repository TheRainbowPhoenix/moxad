<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}		
{{ net_Web_show_value('SRV_PORT_SETTING') | safe }}
{{ net_Web_show_value('SRV_TRUNK_SETTING') | safe }}	 
var port_desc=[{{ net_webPortDesc() | safe }}];

var enablesel=[{ value:0, text:Disable_},	{ value:1, text:Enable_}];
var speedsel = [
	{ value:0, text:AUTO_},	{ value:1, text:FULL_100M_}, { value:2, text:HALF_100M_}, { value:3, text:FULL_10M_}, { value:4, text:HALF_10M_}, { value:5, text:FULL_1G_}
];
var fdxsel = [
	{ value:0, text:Disable_},	{ value:1, text:Enable_}
];
var trunk_all=4;
var trunk_check=new Array;
//var trk=1;
var port_count;
function moveItem(insert) {
	if (insert) {
		table = document.getElementById("show_available_table");
	} else {
		table = document.getElementById("show_trkgrp_table");
    }
	rows = table.getElementsByTagName("tr");
	var i,row;
	var grp = document.getElementById("group"); 
	var trk= grp.options[grp.selectedIndex].value;	
	for(i=1;i<rows.length;i++){
		if(rows.item(i).getElementsByTagName("input").item(0).checked==true){
		var k=rows.item(i).getElementsByTagName("td").item(1).innerHTML-1;
	          if (insert) {				 
		             SRV_TRUNK_SETTING[k].trkgrp=trk;
					 trunk_check[trk]++;
					 trunk_check[0]--;
	          } else {
		             SRV_TRUNK_SETTING[k].trkgrp=0;
					 trunk_check[trk]--;
					 trunk_check[0]++;
			  }
	    }
   }
   ShowList(trk);
   ShowList(0);
}

function SelectRow(grp){
    if(grp==1)
	var selecttable = document.getElementById("show_available_table");
    else
	var selecttable = document.getElementById("show_trkgrp_table");
	
	var selectrows = selecttable.getElementsByTagName("tr");
	for(i=1;i<selectrows.length;i++){
		if(selectrows.item(i).getElementsByTagName("input").item(0).checked==true){
			selectrows.item(i).style.backgroundColor="#99CC00";
		}else{
			selectrows.item(i).style.backgroundColor="#FFFFFF";
		}
	}
}

function addRow(idx,grp) {
	//table = document.getElementById("show_available_table");
	row = table.insertRow(table.getElementsByTagName("tr").length);
	cell = document.createElement("td");
	if(grp==0)
	cell.innerHTML = "<input type=checkbox onclick='SelectRow(1)' >";
	else
	cell.innerHTML = "<input type=checkbox onclick='SelectRow(0)' >";
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.innerHTML =idx+1;
	row.appendChild(cell);
	row.getElementsByTagName("td").item(1).style.display="none";
	
	cell = document.createElement("td");
	cell.innerHTML =port_desc[idx].index;
	row.appendChild(cell);
	cell = document.createElement("td");
	cell.innerHTML = enablesel[SRV_PORT_SETTING['enable'+idx]].text;
	row.appendChild(cell);
	cell = document.createElement("td");
	cell.innerHTML = port_desc[idx].desc;
	row.appendChild(cell);
	cell = document.createElement("td");
	cell.innerHTML = SRV_PORT_SETTING['portname'+idx];
	row.appendChild(cell);
	cell = document.createElement("td");
	cell.innerHTML = speedsel[SRV_PORT_SETTING['speed'+idx]].text;
	row.appendChild(cell);
	cell = document.createElement("td");
	cell.innerHTML = fdxsel[SRV_PORT_SETTING['fdx'+idx]].text;
	row.appendChild(cell);
	row.style.backgroundColor = "white";
	row.className = "r1";
}

function ShowList(trkgrp) {
var i;
    if(trkgrp==0)
	table = document.getElementById("show_available_table");
    else
	{
	//var grp = document.getElementById("group"); 
	//trkrp= grp.options[grp.selectedIndex].value;
	table = document.getElementById("show_trkgrp_table");
	}
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0; i<SYSPORTS; i++)
	{
		if(SRV_TRUNK_SETTING[i].trkgrp==trkgrp)
		{			
		    addRow(i,trkgrp);
        }		
	}
}

function changeGroup() {

	var grp = document.getElementById("group"); 
	var trk= grp.options[grp.selectedIndex].value;
ShowList(trk);
ShowList(0);
}

function Activate_to_check()
{	
    	var i,j,checked=0;	
	for(i=1;i<= trunk_all;i++)
	{
	    if(trunk_check[i]==1)
		{
		    checked=1;
			break;				
	    }
	}
	if(checked==0)
	{
		for(i = 0 ; i < SRV_TRUNK_SETTING.length ; i++)
		{
            if(SRV_TRUNK_SETTING[i].trkgrp!=0)
            {
			    for(j = 0 ; j < SRV_TRUNK_SETTING.length ; j++)
                {
				    if(SRV_TRUNK_SETTING[i].trkgrp==SRV_TRUNK_SETTING[j].trkgrp )
				    {
				        if(port_desc[i].type!=port_desc[j].type)
				        {
				            checked=2;
						    break;
				        }
				    }
                }
            }
		}
	}
	document.getElementById('trkgrp_setting_table').style.display="none";
	if(checked==1)
	document.getElementById('trkgrp_error_table').style.display="";	
	else if(checked==2)
	document.getElementById('trkgrp_diff_speed_table').style.display="";		
	else
	document.getElementById('trkgrp_check_table').style.display="";
}
function Activate(form)
{	
	var i;	
	for(i = 0 ; i < SRV_TRUNK_SETTING.length ; i++)
	{
		form.trunktmp.value = form.trunktmp.value +  SRV_TRUNK_SETTING[i].trkgrp + "+";			
	}
	//alert(form.trunktmp.value);
	form.action="/goform/net_Web_get_value?SRV=SRV_TRUNK_SETTING";	
	form.submit();	
}
function trunk_check_init()
{
    var i;
    for(i=0;i<= trunk_all;i++)
	    trunk_check[i]=0;
	for(i=0;i< SYSPORTS;i++){
		trunk_check[SRV_TRUNK_SETTING[i].trkgrp]++;
}
}
function stopSubmit()
{
	return false;
}
var myForm;
function fnInit() {
	myForm = document.getElementById('myForm');	
	document.getElementById('trkgrp_check_table').style.display="none";
	document.getElementById('trkgrp_error_table').style.display="none";	
	document.getElementById('trkgrp_diff_speed_table').style.display="none";
	var i;
	port_count=0;
	for(i in SRV_PORT_SETTING){
		if(i.substring(0, 3)=="fdx")
		{
			port_count++;
		}
	}
	trunk_check_init();
	
	//fnLoadForm(myForm, SRV_TRUNK_SETTING, SRV_TRUNK_SETTING_type);
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc("Port Trunking")</script></h1>
<form id=myForm method="post" name="trunk_setting_form"  onSubmit="return stopSubmit()">
	<fieldset>
	<input type="hidden" name="SRV_TRUNK_SETTING_tmp" id=trunktmp value="" >
    {{ net_Web_csrf_Token() | safe }}
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td width="97%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	</font></div></td>
	<!-- table: trkgrp_setting_table--> 
<table width='670' align='left' border='0' id="trkgrp_setting_table">
		<tr><font face='Arial, Helvetica, sans-serif, Marlett'>
			<td width='2%'></td>
			<td width='98%'>
				<table width='700'>
			   		<tr>
		    			<td width='15%'>Trunk Group</td>
		    			<td width='20%'>
		    			<select id='group' onchange='changeGroup()'>
							<option value=1>Trk1</option>
							<option value=2>Trk2</option>
							<option value=3>Trk3</option>
							<option value=4>Trk4</option>
						<td width='65%'></td>
		 			</tr>
				</table></td></font></tr>
		<tr class=r0>
			<td width='2%'></td>
			<td width='98%'>
				<table width='700'>
					<tr><td>Member Ports</td></tr>
				</table></td></tr>
		<tr>
			<td width='2%'></td>
			<td width='98%'>
				<table width='700'>
					<tr bgcolor="#007C60">
						<th width='5%'></th>
						<th width='5%'><script language="JavaScript">doc(Port_)</script></th>
						<th width='10%'><script language="JavaScript">doc(Enable_)</script></th>
						<th width='20%'><script language="JavaScript">doc(Description_)</script></th>
						<th width='20%'><script language="JavaScript">doc(Name_)</script></th>
						<th width='10%'><script language="JavaScript">doc(Speed_)</script></th>
						<th width='20%'><script language="JavaScript">doc(Fdx_)</script></th>
					</tr>
				</table>
				
			</td></tr>
		<tr>
			<td width='2%'></td>
			<td width='98%'>
	<table cellpadding=1 cellspacing=2 id="show_trkgrp_table" style="table-layout:fixed;word-wrap:break-word;">	
		<tr>
 			<td width='5%'></td>
 			<td width='5%'></td>
 			<td width='10%'></td>
  			<td width='20%'></td>
			<td width='20%'></td>
			<td width='10%'></td>
			<td width='20%'></td>		
		</tr>	
		<script language="JavaScript">ShowList(1)</script>
	</table>
				</td></tr>				

        <tr>
		<td width='2%'></td>
		<td width='98%'>
		<table class=tf align=left>
            <td><script language="JavaScript">fnbnB(Up_, 'onClick=moveItem(true)')</script></td>
            <td width='4%'></td>
            <td><script language="JavaScript">fnbnB(Down_ ,'onClick=moveItem(false)')</script></td>
        </table></td></tr>
	
		<tr class=r0>
			<td width='2%'></td>
			<td width='98%'>
				<table width='700'>
					<tr><td>Available Ports</td></tr>
				</table></td></tr>
		<tr>
			<td width='2%'></td>
			<td width='98%'>
				<table width='700'>
					<tr bgcolor="#007C60">
						<th width='5%'></th>
						<th width='5%'><div align="left"><script language="JavaScript">doc(Port_)</script></th>
						<th width='10%'><div align="left"><script language="JavaScript">doc(Enable_)</script></th>
						<th width='20%'><div align="left"><script language="JavaScript">doc(Description_)</script></th>
						<th width='20%'><div align="left"><script language="JavaScript">doc(Name_)</script></th>
						<th width='10%'><div align="left"><script language="JavaScript">doc(Speed_)</script></th>
						<th width='20%'><div align="left"><script language="JavaScript">doc(Fdx_)</script></th>
					</tr>
				</table>
			</td></tr>
		<tr>
            <td width='2%'></td>
			 <td width='98%'>		 
	<table cellpadding=1 cellspacing=2 id="show_available_table" style="table-layout:fixed;word-wrap:break-word;">	
		<tr>
 			<td width='5%'></td>
 			<td width='5%'></td>
 			<td width='10%'></td>
  			<td width='20%'></td>
			<td width='20%'></td>
			<td width='10%'></td>
			<td width='20%'></td>		
		</tr>	
		<script language="JavaScript">ShowList(0)</script>
	</table>
	</td></tr>
        <tr>
	<td width='2%'></td>
	<td width='98%'>
	<table class=tf align=left>
	<td width='2%'></td>
	<td><script language="JavaScript">fnbnS(Submit_, 'onClick=Activate_to_check()')</script></td>
	</table>
       </tr>
	</table>
<!--table: trkgrp_check_table-->
<table width="100%" border="0" align="center" id="trkgrp_check_table">
<tr>
<td width="100%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#ff0000">
<p>Warning !!!</p>
<p>If you want to activate new port trunking settings, the all functions related to the trunking ports will be set to default values !!!</p>
<br>
<br><p>Do you want to activate ?</p></font></div>
</td>
</tr>
<tr>
	<td width='2%'></td>
	<td width='98%'>
	<table class=tf align=left>
	<td width='2%'></td>
	<td><script language="JavaScript">fnbnS(Submit_, 'onClick=Activate(this.form)')</script></td>
	</table>
       </tr>
</div>
</table>
<!--table: trkgrp_error_table-->
<table width="100%" border="0" align="center" id="trkgrp_error_table">
<tr>
<td width="100%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#ff0000">
<p>Warning !!!</p>
<p>Must set at lease 2 ports in one trunk group !!!</p></font></div>
</td></tr>
</table>
<!--table: trkgrp_speed_notsame_table-->
<table width="100%" border="0" align="center" id="trkgrp_diff_speed_table">
<tr>
<td width="100%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#ff0000">
<p>Warning !!!</p>
<p>All ports in a trunking group must be the same speed !!!</p></font></div>
</td></tr>
</table>
<!-- -->  
</fieldset>
</form>
</body>
</html>
