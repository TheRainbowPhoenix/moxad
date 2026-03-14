<html>
<head>  
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
if (!debug) 
{
	var SRV_TRUNK_SETTING = [{trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'},
    {trkgrp:'0'}];

    var SRV_SMCAST_MAC_SETTING_type = {haddr:4,port_join0:4,port_join1:4,port_join2:4,port_join3:4,port_join4:4,port_join5:4,port_join6:4,port_join7:4,port_join8:4,port_join9:4};
    var SRV_SMCAST_MAC_SETTING=[{haddr:'01:00:5e:aa:00:dd',port_join0:'1',port_join1:'0',port_join2:'0',port_join3:'0',port_join4:'0',port_join5:'1',port_join6:'0',port_join7:'0',port_join8:'0',port_join9:'0'},
    {haddr:'01:00:5e:aa:dc:dd',port_join0:'1',port_join1:'0',port_join2:'0',port_join3:'0',port_join4:'0',port_join5:'1',port_join6:'0',port_join7:'1',port_join8:'1',port_join9:'0'}];
}
else
{
    {{ net_Web_show_value('SRV_TRUNK_SETTING') | safe }}
    {{ net_Web_show_value('SRV_SMCAST_MAC_SETTING') | safe }}
}

var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}
var SYSTRUNKS = {{ net_Web_Get_SYS_TRUNKS() | safe }}
var port_desc=[{{ net_webPortDesc() | safe }}];
var trunk_check=new Array;
var newdata0=new Array;
var table_idx=0;
var tablefun=new table_show(document.getElementsByName('form1'),"show_available_table" ,SRV_SMCAST_MAC_SETTING_type, SRV_SMCAST_MAC_SETTING, table_idx, newdata0, Addformat, 0);
var port_name="port_join";
var trk_name="trk";
var addb = "Add";
var MAC_MAX = {{ net_Web_Get_MAX_SMCAST() | safe }}
function Total_IP()
{
	if(SRV_SMCAST_MAC_SETTING.length > MAC_MAX || SRV_SMCAST_MAC_SETTING.length  < 0){		
		alert('Number of MAC is Over or Wrong');
		with(document){
			getElementById('btnA').disabled = true;			
			getElementById('btnD').disabled = false;			
			getElementById('btnM').disabled = false;			
			getElementById('btnS').disabled = true;
		}				
	}else if(SRV_SMCAST_MAC_SETTING.length == MAC_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else if(SRV_SMCAST_MAC_SETTING.length == 0){		
		with (document) {		
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = true;
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
	document.getElementById("totalipcnt").innerHTML = '('+SRV_SMCAST_MAC_SETTING.length +'/' +MAC_MAX+')';
}
function Addformat(mod,i)
{	
	var j=0, str, i, trk_idx;	
	var k;
	j = 0;

	for(k in SRV_SMCAST_MAC_SETTING_type)
	{
		if(document.getElementsByName(k)[0].type=="hidden")
			continue;
		if(mod==0)
		{
			newdata0[j] = SRV_SMCAST_MAC_SETTING[i][k]; 			
		}
		else
		{
			newdata0[j] = document.getElementById('myForm')[k].value;
		}
		if(document.getElementsByName(k)[0].type=="checkbox")
		{
		    if(newdata0[j]==1)
		    newdata0[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
			else
			newdata0[j]="<IMG src=" + 'images/disable_3.gif'+ ">";						
		}		
		j++;
	}
	//for trunk
	/*for(trk_idx=0; trk_idx<4; trk_idx++)
	{
	    var trk=trk_idx+1;
		k=trk_name+trk;
		if(document.getElementsByName(k)[0].type=="hidden")
			continue;
		if(mod==0)
		{
			//newdata0[j] = SRV_SMCAST_MAC_SETTING[i][port_name+trk_group[0][k]];
		}
		else
		{
			newdata0[j] = document.getElementById('myForm')[k].value;
		}
		if(document.getElementsByName(k)[0].type=="checkbox")
		{
			var tmp=document.getElementsByName(k)[0];
			var idx;			
			if(newdata0[j]==1)
			{
				 newdata0[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
			}
		    else
			{
				newdata0[j]="<IMG src=" + 'images/disable_3.gif'+ ">";
			}				
				
		}
		j++;
	}*/
}

function smcast_format(mac_addr){	
	var j = 0;
	var str = mac_addr.toLowerCase();
	mac_addr = '';
    if(str.substring(0,2)=="00")
    { 
	    alert("Not a right mac address format");
		return 0;
    }
	
	var check_str=str.substring(1,2);	
	if (parseInt(check_str)% 2 == 0) { 
		alert("Not a right mac address format");
		return 0;
	}
   
	for(var i = 0; i < str.length; i++){	
		if(!(str.charCodeAt(i) >= 48 && str.charCodeAt(i) <= 57)){
			if(!(str.charCodeAt(i) >= 97 && str.charCodeAt(i) <= 102)){	
				if(str.substring(i,i+1)!=':')
				{
					alert("Not a right mac address format");
					return 0;
				}
				continue;	
			}
		}
		
		if((j+1)%3 == 0 && j > 0){
			mac_addr= mac_addr + ':';
			j++;
		}		
		mac_addr = mac_addr + str.substring(i,i+1);
		j++;
		//alert(mac_addr);
	}
	return mac_addr;
}

function tabbtn_sel(form, sel)
{	
	if(sel == 0 || sel == 2){
		if(sel == 0){
			table_idx = MAC_MAX;
		}else{
			table_idx = tNowrow_Get();
		}
	}
	var k,port_checked=0;
	var now_row= tNowrow_Get();
	var tmp_mac=smcast_format(document.getElementById('myForm')["haddr"].value);
    if(tmp_mac<=0)return;
    else 	document.getElementById('myForm')["haddr"].value = tmp_mac;
	
	if(sel!=1)//check mac address duplicat
	{
		if(duplicate_check(table_idx, SRV_SMCAST_MAC_SETTING, "haddr", document.getElementById('myForm')["haddr"].value, smcast_mac_setting  + ' ' + document.getElementById('myForm')["haddr"].value + ' '  + "is already existed")<0)
			return;
	}
	if(sel!=1)
	{
		for(k in SRV_SMCAST_MAC_SETTING_type){
			if(document.getElementsByName(k)[0].type=="checkbox"){
				if(document.getElementById('myForm')[k].checked)
					port_checked=1;
			}
		}
		if(!port_checked){
			alert("The new multicast mac must have one member port at least");
			return 0;
		}

	}
	if(sel == 0){		
		Addformat(1,0);
		tablefun.add();	
	}else if(sel == 1){
		//if(now_row == 0)
			//return;
		tablefun.del();
	}else if(sel == 2){
		tablefun.mod();
	}
	//Total_IP();	
}

function trunk_check_init()
{
    var i;
    for(i=0;i<=SYSTRUNKS;i++)
	    trunk_check[i]=0;
	for(i=0;i< SYSPORTS;i++)
		trunk_check[SRV_TRUNK_SETTING[i].trkgrp]++;	
	//for(i=0;i< 5;i++)
		//alert(trunk_check[i]);
}
function show_Port_check()
{
	var i,line_cnt=0;
	trunk_check_init();
	document.write('<table cellpadding=1 cellspacing=1 border=0>');
	document.write('<tr>');	
	for(i=0; i < SYSPORTS+SYSTRUNKS; i++)
	{
		if(i<SYSPORTS)
		{
	        idx=i+1;				
            if(SRV_TRUNK_SETTING[i].trkgrp==0)
            {	
			    document.write('<td class=r1 >');				
				document.write('<input type=checkbox name=port_join'+i+' id=port_join'+i+' >');
	            document.write('Port '+port_desc[i].index+'</td>');
				line_cnt++;
			}
			else 
			{
				document.write('<input type=hidden name=port_join'+i+' id=port_join'+i+' value=0>');				
		    }
		}
		else
		{
			idx=i+1;					
            if(trunk_check[i-SYSPORTS+1]!=0)
            {
			    idx=idx-SYSPORTS;
                document.write('<td class=r1>');			
				//document.write('<input type=checkbox name=trk'+idx+' id=trk'+idx+'>');
				document.write('<input type=checkbox name=port_join'+i+' id=port_join'+i+'>');

		        document.write('Trk '+idx+'</td>');
				line_cnt++;
			}
		    else
            {	
			    idx=idx-SYSPORTS;			
				//document.write('<input type=hidden name=trk'+idx+' id=trk'+idx+' value=0>');
				document.write('<input type=hidden name=port_join'+i+' id=port_join'+i+' value=0>');
			}
		}
		
		if(line_cnt%5==0)
		{
			document.write('</tr>');	
			document.write('<tr>');	
		}

	}
	document.write('</tr>');	
	document.write('</table>');
}
function show_Port_table(){
	var i,value;
	//value = parseInt(SYSPORTS)+4;//trunk+all=4
	for(i=0; i < SYSPORTS+SYSTRUNKS; i++){
		if(i<SYSPORTS)
		{
			if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0){
				continue;
			}else{
				document.write('<th width=80px align="center">'+port_desc[i].index+'</th>');		
			}
		}
		else
		{
		    if(trunk_check[i-SYSPORTS+1]!=0)
			document.write('<th width=80px align="center">trk'+(i-SYSPORTS+1)+'</th>');		
		}
	}
	document.getElementById("table_port").colSpan=SYSPORTS;
	document.getElementById("table_port").style.width=SYSPORTS*80;
	document.getElementById("table_port").style.textAlign="center";

}
function Activate(form)
{	
	var i,j,k,idx;
    for(i=0;i<SYSPORTS;i++)
	{
	   if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0)
       {
	       for(j = 0 ; j < SRV_SMCAST_MAC_SETTING.length ; j++)
		   {   
		       idx= parseInt(SRV_TRUNK_SETTING[i]["trkgrp"])+SYSPORTS-1;
			   //alert(idx);
			   //alert(port_name+i);
			   SRV_SMCAST_MAC_SETTING[j][port_name+i]=SRV_SMCAST_MAC_SETTING[j][port_name+idx];
           }
	   }	   
	}
	form.smcasttmp.value="";
	for(j = 0 ; j < SRV_SMCAST_MAC_SETTING.length ; j++)
	{
		for (var k in SRV_SMCAST_MAC_SETTING[j]){
			form.smcasttmp.value = form.smcasttmp.value + SRV_SMCAST_MAC_SETTING[j][k] + "+";		
		}
	}		
//alert(form.smcasttmp.value);
	form.action="/goform/net_Web_get_value?SRV=SRV_SMCAST_MAC_SETTING";	
	form.submit();	
}
var myForm;
function fnInit() 
{
	myForm = document.getElementById('myForm');	
		tablefun.show();
	
	if(SRV_SMCAST_MAC_SETTING[0]){
        fnLoadForm(myForm, SRV_SMCAST_MAC_SETTING[0], SRV_SMCAST_MAC_SETTING_type);		
	}
	Total_IP();
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc(smcast_mac_setting);</script></h1>
<form id=myForm method="post" name=form1 onSubmit="return stopSubmit()">
<fieldset>
<input type="hidden" name="SRV_SMCAST_MAC_SETTING_tmp" id="smcasttmp" value="" >
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=1 width="100%" border=0>
 <tr class=r0>
  <td width="80%"><script language="JavaScript">doc("Add New Static Multicast MAC Address to the List")</script></td>
 </tr>
 <tr>
  <td width="80%"><script language="JavaScript">doc("01:00:5E:XX:XX:XX in here is IP multicast MAC address, please activate IGMP Snooping for automatic classification")</script></td>
  
 </tr>
</table>


<table cellpadding=1 cellspacing=1 width="400" border=0>
 <tr>
  <td width="100"><script language="JavaScript">doc("MAC Address")</script></td>
  <td width="300" align="left"><input type="text" id="haddr" name="haddr" size=20 maxlength=17 ></td>  
 </tr>
</table>

<table cellpadding=1 cellspacing=1 width="100%" border=0>
 <tr>
  <td width="100"><script language="JavaScript">doc("Join Port")</script></td>
  <td ><script language="JavaScript">show_Port_check()</script></td>  
 </tr>
</table>

<table border=0>
 <tr>
  <td width=50px><script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script></td>
  <td width=70px><script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script></td>
  <td width=120px><script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
 </tr> 
</table>

<table cellpadding=1 cellspacing=2 border=0>
<tr class=r0>
  <td width=300px><script language="JavaScript">doc("Current Static Multicast MAC Address List")</script></td>
  <td id = "totalipcnt"></td>
 </tr>
</table>


<table cellpadding=1 cellspacing=2 id="show_available_table" border=0>
 <tr >
  <th width=150px rowspan=2 align="center"><script language="JavaScript">doc("MAC Address")</script></th>
   <th width=120px id = "table_port" align="center"><script language="JavaScript">doc(Port_)</script></th>
 </tr>
   <tr>
    <script language="JavaScript">show_Port_table()</script>
   </tr>

</table>
</fieldset>
</form>
</body>
</html>
