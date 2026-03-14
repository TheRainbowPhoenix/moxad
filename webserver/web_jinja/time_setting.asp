<html>
<head>
{{ net_Web_file_include() | safe }}
<!--<title><script language="JavaScript">doc(Date_Time)</script></title>-->

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
var link0 = 'time_setting.asp';
if (debug) {
	{{ net_Web_show_value('SRV_NTP') | safe }}
	{{ net_Web_show_value('SRV_TIMESET') | safe }}
	{{ net_Web_show_value('SRV_DST') | safe }}
		
}else{
	var SRV_NTP ={hour:'10', min:'1', sec:'29', year:'2009', mon:'9', day:'8', smon:0, sweek:0, sday:0, shr:0, 
		emon:0, eweek:0, eday:0, ehr:0, omin:0, sysuptime:'27d0h25m51s', timezone:'49', synenable:'1', timeserver1:'', timeserver2:'', enable:'1'}; 
}
	sysuptime={{ net_webSysuptime() | safe }}

var ctrl0 = [
	{ value:0, text:Read_Write },
	{ value:1, text:Read_Only },
	{ value:2, text:No_Access }
];
var sel_zone = [
	{ value:0, text:Ver_zone_0 },
	{ value:1, text:Ver_zone_1 },
	{ value:2, text:Ver_zone_2 },
	{ value:3, text:Ver_zone_3 },
	{ value:4, text:Ver_zone_4 },
	{ value:5, text:Ver_zone_5 },
	{ value:6, text:Ver_zone_6 },
	{ value:7, text:Ver_zone_7 },
	{ value:8, text:Ver_zone_8 },
	{ value:9, text:Ver_zone_9 },
	{ value:10, text:Ver_zone_10 },
	{ value:11, text:Ver_zone_11 },
	{ value:12, text:Ver_zone_12 },
	{ value:13, text:Ver_zone_13 },
	{ value:14, text:Ver_zone_14 },
	{ value:15, text:Ver_zone_15 },
	{ value:16, text:Ver_zone_16 },
	{ value:17, text:Ver_zone_17 },
	{ value:18, text:Ver_zone_18 },
	{ value:19, text:Ver_zone_19 },
	{ value:20, text:Ver_zone_20 },
	{ value:21, text:Ver_zone_21 },
	{ value:22, text:Ver_zone_22 },
	{ value:23, text:Ver_zone_23 },
	{ value:24, text:Ver_zone_24 },
	{ value:25, text:Ver_zone_25 },
	{ value:26, text:Ver_zone_26 },
	{ value:27, text:Ver_zone_27 },
	{ value:28, text:Ver_zone_28 },
	{ value:29, text:Ver_zone_29 },
	{ value:30, text:Ver_zone_30 },
	{ value:31, text:Ver_zone_31 },
	{ value:32, text:Ver_zone_32 },
	{ value:33, text:Ver_zone_33 },
	{ value:34, text:Ver_zone_34 },
	{ value:35, text:Ver_zone_35 },
	{ value:36, text:Ver_zone_36 },
	{ value:37, text:Ver_zone_37 },
	{ value:38, text:Ver_zone_38 },
	{ value:39, text:Ver_zone_39 },
	{ value:40, text:Ver_zone_40 },
	{ value:41, text:Ver_zone_41 },
	{ value:42, text:Ver_zone_42 },
	{ value:43, text:Ver_zone_43 },
	{ value:44, text:Ver_zone_44 },
	{ value:45, text:Ver_zone_45 },
	{ value:46, text:Ver_zone_46 },
	{ value:47, text:Ver_zone_47 },
	{ value:48, text:Ver_zone_48 },
	{ value:49, text:Ver_zone_49 },
	{ value:50, text:Ver_zone_50 },
	{ value:51, text:Ver_zone_51 },
	{ value:52, text:Ver_zone_52 },
	{ value:53, text:Ver_zone_53 },
	{ value:54, text:Ver_zone_54 },
	{ value:55, text:Ver_zone_55 },
	{ value:56, text:Ver_zone_56 },
	{ value:57, text:Ver_zone_57 },
	{ value:58, text:Ver_zone_58 },
	{ value:59, text:Ver_zone_59 },
	{ value:60, text:Ver_zone_60 },
	{ value:61, text:Ver_zone_61 },
	{ value:62, text:Ver_zone_62 }
];
var sel_month = [	
	{ value:1, text:Ver_month_1},
	{ value:2, text:Ver_month_2},
	{ value:3, text:Ver_month_3},
	{ value:4, text:Ver_month_4},
	{ value:5, text:Ver_month_5},
	{ value:6, text:Ver_month_6},
	{ value:7, text:Ver_month_7},
	{ value:8, text:Ver_month_8},
	{ value:9, text:Ver_month_9},
	{ value:10, text:Ver_month_10},
	{ value:11, text:Ver_month_11},
	{ value:12, text:Ver_month_12},
	{ value:0, text:'--'}
];

var sel_week = [	
	{ value:1, text:Ver_week_1},
	{ value:2, text:Ver_week_2},
	{ value:3, text:Ver_week_3},
	{ value:4, text:Ver_week_4},
	{ value:6, text:Ver_week_6},
	{ value:0, text:'--'}
];

var sel_day = [	
	{ value:1, text:Sun_},
	{ value:2, text:Mon_},
	{ value:3, text:Tue_},
	{ value:4, text:Wed_},
	{ value:5, text:Thu_},
	{ value:6, text:Fri_},
	{ value:7, text:Sat_},
	{ value:0, text:'--'}
];
var sel_hr = [	
	{{ net_webTimeHrSel() | safe }}
];

var sel_min = [	
	{{ net_webTimeMinSel() | safe }}
];
/*
var sel_offset_hr = [	
	{ value:0, text:0},
	{ value:1, text:1},
	{ value:2, text:2},
	{ value:3, text:3},
	{ value:4, text:4},
	{ value:5, text:5},
	{ value:6, text:6},
	{ value:7, text:7},
	{ value:8, text:8},
	{ value:9, text:9},
	{ value:10, text:10},
	{ value:11, text:11},
	{ value:12, text:12}
];
*/
	
var sel_offset_hr = [	
	{ value:0,   text:0},
	{ value:30,  text:0.5},
	{ value:60,  text:1},
	{ value:90,  text:1.5},
	{ value:120, text:2},
	{ value:150, text:2.5},
	{ value:180, text:3},
	{ value:210, text:3.5},
	{ value:240, text:4},
	{ value:270, text:4.5},
	{ value:300, text:5},
	{ value:330, text:5.5},
	{ value:360, text:6},
	{ value:390, text:6.5},
	{ value:420, text:7},
	{ value:450, text:7.5},
	{ value:480, text:8},
	{ value:510, text:8.5},
	{ value:540, text:9},
	{ value:570, text:9.5},
	{ value:600, text:10},
	{ value:630, text:10.5},
	{ value:660, text:11},
	{ value:690, text:11.5},
	{ value:720, text:12}
];


var myForm;
var sysuptime;
var now,year,month,day,hours,minutes,seconds,timeValue,curtime;



function showPCtime(){
now = new Date();
year = now.getFullYear();
month= now.getMonth()+1;
day  = now.getDate();
hours = now.getHours();
minutes = now.getMinutes();
seconds = now.getSeconds();

timeValue = year +"/";
timeValue += ((month < 10) ? "0" : "") + month + "/";
timeValue += ((day < 10) ? "0" : "") + day + " ";
timeValue += ((hours < 10) ? "0" : "") + hours + ":";
timeValue += ((minutes < 10) ? "0" : "") + minutes + ":";
timeValue += ((seconds < 10) ? "0" : "") + seconds + " ";

document.getElementById("pctime").innerHTML = timeValue;
setTimeout("showPCtime()",1000);
}

function curtime_syc(){
curtime = SRV_TIMESET['year'] +"/";
curtime += ((SRV_TIMESET['mon'] < 10) ? "0" : "") + SRV_TIMESET['mon'] + "/";
curtime += ((SRV_TIMESET['day'] < 10) ? "0" : "") + SRV_TIMESET['day'] + " ";
curtime += ((SRV_TIMESET['hour'] < 10) ? "0" : "") + SRV_TIMESET['hour'] + ":";
curtime += ((SRV_TIMESET['min'] < 10) ? "0" : "") + SRV_TIMESET['min'] + ":";
curtime += ((SRV_TIMESET['sec'] < 10) ? "0" : "") + SRV_TIMESET['sec'] + " ";
		document.getElementById("curtime1").innerHTML = curtime;
}

function time_init(){
	document.getElementById('year1').value = "";
	document.getElementById('mon1').value = "";
	document.getElementById('day1').value = "";
	document.getElementById('hour1').value = "";
	document.getElementById('min1').value = "";
	document.getElementById('sec1').value = "";
}

function Local_Rtime(){
	var user_sel = document.getElementsByName("userenable");
	var radio =document.getElementsByName("timeset");
	//alert((user_sel[1].checked ||user_sel[2].checked));
	if((user_sel[1].checked ||user_sel[2].checked) == 0 ){
		document.getElementById('time_setting_title').style.display="";
		document.getElementById('time_setting_table').style.display="";
		document.getElementById('server_name_table').style.display="none";
		document.getElementById('ntp_title').style.display="none";
		document.getElementById('sntp_title').style.display="none";
		
		document.getElementById('enable').disabled=!true; 
		document.getElementById('timeserver1').disabled=true;
		document.getElementById('timeserver2').disabled=true;
		radio[0].disabled = !true;
		radio[1].disabled = !true;
		Manually_Rtime();
	}
	else{
		document.getElementById('time_setting_title').style.display="none";
		document.getElementById('time_setting_table').style.display="none";
		document.getElementById('server_name_table').style.display="";
		
		if(user_sel[1].checked){
			document.getElementById('enable').disabled=!true;
			document.getElementById('ntp_title').style.display="";
			document.getElementById('sntp_title').style.display="none";
		}else if(user_sel[2].checked){
			//document.getElementById('enable').checked=!true; 
			document.getElementById('enable').disabled=true;
			document.getElementById('ntp_title').style.display="none";
			document.getElementById('sntp_title').style.display="";
		}
		document.getElementById('timeserver1').disabled=!true;
		document.getElementById('timeserver2').disabled=!true;
		radio[0].disabled = true;
		radio[1].disabled = true;
	}
}

function fnInit() {
	SRV_TIMESET['year']=parseInt(SRV_TIMESET['year'], 10)+1900;
	SRV_TIMESET['mon']=parseInt(SRV_TIMESET['mon'], 10)+1;
		
	myForm = document.getElementById('myForm');
	fnLoadForm(myForm, SRV_DST, SRV_DST_type);
	fnLoadForm(myForm, SRV_TIMESET, SRV_TIMESET_type);
	fnLoadForm(myForm, SRV_NTP, SRV_NTP_type);	
	time_init();
	//if(document.getElementById('radio_local').checked){
		document.getElementById('timebyuser').checked=true;
		
	//}
	Manually_Rtime();
	document.getElementById("sysuptime").innerHTML = sysuptime;
	Local_Rtime();
	showPCtime();
	curtime_syc();
}

function fnEnSYN(ensyn){
	myForm.timeserver1.disabled = !ensyn; 
	myForm.timeserver2.disabled = !ensyn; 
}


function Server_check(form){
	var error_server_t = 0;
	if(!isNull(form["timeserver1"].value))
		if (isSymbol(form["timeserver1"], '1st ' + Time_Server_))
			error_server_t = 1;
	if(!isNull(form["timeserver2"].value))
		if (isSymbol(form["timeserver2"], '2nd ' + Time_Server_))
			error_server_t = 1;
		
	if (error_server_t)
	return;
}	

function Time_Check(form){
	var error_return_t = 0;
		if (!IsInRange(form["hour1"], 'Current Time Hour', 0, 23))
			error_return_t = 1;
		if (!IsInRange(form["min1"], 'Current Time Minute', 0, 59))
			error_return_t = 1;
		if (!IsInRange(form["sec1"], 'Current Time Second', 0, 59))
			error_return_t = 1;
		if (!IsInRange(form["year1"], 'Current Date Year', 2000, 2070))
			error_return_t = 1;
		if (!IsInRange(form["mon1"], 'Current Date Month', 1, 12))
			error_return_t = 1;
		if (!IsInRange(form["day1"], 'Current Date Day', 1, 31))
			error_return_t = 1;
		
		if (error_return_t)
			return;
}
function DST_Server_Activate(form){
		form.action="/goform/net_Web_get_value?SRV=SRV_NTP&SRV0=SRV_DST";
}	

function Time_Server_Activate(form){
		form.action="/goform/net_Web_get_value?SRV=SRV_NTP&SRV0=SRV_DST&SRV1=SRV_TIMESET";
		//form.action="/goform/net_Web_get_value?SRV=SRV_TIMESET&SRV0=SRV_DSTP";
}
function Activate(form){
	var radio_count = 0;
	//alert(isNull(form["hour1"].value)&&isNull(form["min1"].value)&&isNull(form["sec1"].value)&&isNull(form["year1"].value)&&isNull(form["mon1"].value)&&isNull(form["day1"].value));
	Server_check(form);
	
	for (var i=0; i<form.timeset.length; i++)
    {
       if (form.timeset[i].checked)
       {  
       		radio_count++;
       		if(form.timeset[i].value == 1){
						
				if((isNull(form["hour1"].value)&&isNull(form["min1"].value)&&isNull(form["sec1"].value)&&isNull(form["year1"].value)&&isNull(form["mon1"].value)&&isNull(form["day1"].value))== 1){
					DST_Server_Activate(form);
				}else{	
				
					Time_Check(form);

					form["year"].value = parseInt(form["year1"].value, 10)-1900;
					form['mon'].value= parseInt(form["mon1"].value, 10)-1;
					form["day"].value = parseInt(form["day1"].value, 10);
					form['hour'].value= parseInt(form["hour1"].value, 10);
					form['min'].value= parseInt(form["min1"].value, 10);
					form['sec'].value= parseInt(form["sec1"].value, 10);
					
					time_init(form);
					Time_Server_Activate(form);		
				}
       		}
			else if(form.timeset[i].value == 2){ 
					form["year"].value = year-1900;
					form['mon'].value= month-1;
					form["day"].value = day;
					form['hour'].value= hours;
					form['min'].value= minutes;
					form['sec'].value= seconds;
					
					Time_Server_Activate(form);
       		}
			
       	}
	}

	if((document.getElementById('radio_sntp').checked==true)&&(document.getElementById('enable').checked==true)){
		if(confirm("(S)NTP server and SNTP client cannot be enabled at the same time.   Please reconfigure it.  Do you want to continue?")){  
		    DST_Server_Activate(form);
		}
		else{
		    return;
		}
	}
    else if(radio_count == 0){
		DST_Server_Activate(form);
    }
		form.submit();	

}


function Manually_Rtime(){ 
	var check = document.getElementById('radio_local').checked
	document.getElementById('hour1').disabled=!check;
	document.getElementById('min1').disabled=!check;
	document.getElementById('sec1').disabled=!check;
	document.getElementById('year1').disabled=!check;
	document.getElementById('mon1').disabled=!check;
	document.getElementById('day1').disabled=!check;
	document.getElementById('pctime').disabled=check; 
	
}

function PC_Rtime(form){
	var check = form.timeset[1].checked;
	document.getElementById('hour1').disabled=check;
	document.getElementById('min1').disabled=check;
	document.getElementById('sec1').disabled=check;
	document.getElementById('year1').disabled=check;
	document.getElementById('mon1').disabled=check;
	document.getElementById('day1').disabled=check;
	document.getElementById('pctime').disabled=!check;  
}
 
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(Date_Time)</script></h1>

<fieldset>
<form id=myForm method="POST">
{{ net_Web_csrf_Token() | safe }}
<DIV style="width:800px; overflow-y:auto;">

<table cellpadding=1 cellspacing=2>
  <tr >  
  <td ><input type="hidden" name="hour"  id=hour size="2" maxlength="2">
  	  <input type="hidden" name="min" id=min size="2" maxlength="2">
      <input type="hidden" name="sec" id=sec size="2" maxlength="2">
      <input type="hidden" name="year"	id=year size="4" maxlength="4" > 
      <input type="hidden" name="mon"	id=mon size="2" maxlength="2" >
	  <input type="hidden" name="day"	id=day size="2" maxlength="2" ></td>
  </tr>         
   <tr >  
  <td width=205px><script language="JavaScript">doc(System_Up_Time_)</script></td>
  <td id=sysuptime></td>
  </tr>  
  <tr >  
  <td width=205px><script language="JavaScript">doc(Current_Time)</script></td>
  <td id=curtime1></td>
  </tr>
 </table> 
<table cellpadding=1 cellspacing=2>  
   <tr >  
  <td width=200px><script language="JavaScript">doc(Clock_Source)</script></td>
  <td width=3px><input type="radio" name="userenable" id="radio_local" value="0" onClick="Local_Rtime()"></td>
  <td width=10px><script language="JavaScript">doc(Local_)</script></td>	
  <td width=3px><input type="radio" name="userenable" id="radio_ntp" value="1" onClick="Local_Rtime()"></td>
  <td width=10px><script language="JavaScript">doc(NTP)</script></td>
   <td width=3px><input type="radio" name="userenable" id="radio_sntp" value="2" onClick="Local_Rtime()"></td>
  <td ><script language="JavaScript">doc(SNTP)</script></td>
  </tr>
</table>

<table cellpadding=1 cellspacing=2 id="ntp_title"> 
<tr  height="10">  
  <td></td></tr>
<tr class=r0>
  <td colspan=2><script language="JavaScript">doc(NTP_Client_Set)</script></td>
</tr>
 </table> 
 <table cellpadding=1 cellspacing=2 id="sntp_title"> 
<tr  height="10">  
  <td></td></tr>
<tr class=r0>
  <td colspan=2><script language="JavaScript">doc(SNTP_Client_Set)</script></td>
</tr>
 </table> 
<table cellpadding=1 cellspacing=2 id="server_name_table"> 
 <tr >  
  <td width=200px><script language="JavaScript">doc(Time_Serverip1_)</script></td>
  <td><input type="text" name="timeserver1" id=timeserver1 size="30" maxlength="30"></td>
 </tr>
 <tr> 
  <td width=200px><script language="JavaScript">doc(Time_Serverip2_)</script></td>
  <td><input type="text" name="timeserver2" id=timeserver2 size="30" maxlength="30"></td>
 </tr>
    <tr height="10">  
  <td></td></tr>
</table>

<table cellpadding=1 cellspacing=2 id="time_setting_title"> 
<tr height="10">  
  <td></td></tr>
<tr class=r0>
  <td colspan=2><script language="JavaScript">doc(Time_Set)</script></td>
</tr>
 </table>
<table cellpadding=1 cellspacing=2 id="time_setting_table"> 
<td colspan=2>
  <table>
  <tr>
  <td width=3px><input type="radio" name="timeset" id="timebyuser" value="1" onClick="Manually_Rtime()"></td>
  <td ><script language="JavaScript">doc(Manually_Time)</script></td>
  </tr>
  </table>
 </td>
	 <tr>
	  <td width=40px></td>
	  <td width=157px><script language="JavaScript">doc(Date_)</script>(YYYY/MM/DD)</td>
	  <td ><input type="text" name="year1"	id=year1 size="4" maxlength="4" > <b>&nbsp;/&nbsp;</b>
	      <input type="text" name="mon1"	id=mon1 size="4" maxlength="4" > <b>&nbsp;/&nbsp;</b>
		  <input type="text" name="day1"	id=day1 size="4" maxlength="4" >(ex: 2002/11/13)</td>
	</tr> 
	  <tr>  
	  <td width=40px></td>
	  <td ><script language="JavaScript">doc(Time_)</script>(HH:MM:SS)</td>
	  <td ><input type="text" name="hour1"  id=hour1 size="4" maxlength="4"> <b>&nbsp;:&nbsp;</b></script>
	  	  <input type="text" name="min1" id=min1 size="4" maxlength="4"> <b>&nbsp;:&nbsp;</b></script>
	      <input type="text" name="sec1" id=sec1 size="4" maxlength="4">(ex: 04:00:04)</script></td>
	  </tr>  

<td colspan=4>
  <table>
  <tr>
  <td width=3px><input type="radio" name="timeset" value="2" onClick="PC_Rtime(this.form)"></td>
  <td width=175px><script language="JavaScript">doc(Sync_PC)</script></td>
  <td name="pctime" id=pctime></td>
  </tr>
  </table>
 </td>
    <tr height="10">  
  <td></td></tr>
</table>

<table cellpadding=1 cellspacing=2>
<tr class=r0>
  <td colspan=2><script language="JavaScript">doc(NTP_Server_Set)</script></td>
</tr>
  <tr> 
  <td width=200px>NTP/SNTP Server</td>
  <td><input type="checkbox" name="enable" id=enable size="30" maxlength="30"><script language="JavaScript">doc(Enable_)</script></td>
  </tr>
    <tr height="10">  
  <td></td></tr>
</table>

<table cellpadding=1 cellspacing=2>
 <tr class=r0>
  <td colspan=3><script language="JavaScript">doc(Time_Zone_Setting)</script></td></tr>       		
 <tr>
  <td width=200px><script language="JavaScript">doc(Time_Zone_)</script></td>                        
  <td><script language="JavaScript">iGenSel2('timezone', 'timezone', sel_zone)</script></td></tr>
   <tr height="10">  
  <td></td></tr>
</table>
<table cellpadding=1 cellspacing=2>
 <tr class=r0>
  <td width=176px><script language="JavaScript">doc(DSTIME)</script></td>
  <td width=100px><script language="JavaScript">doc(Month)</script></td>
  <td width=100px><script language="JavaScript">doc(Week)</script></td>
  <td width=100px><script language="JavaScript">doc(Day)</script></td>
  <td width=100px><script language="JavaScript">doc(Hour)</script></td>
  <td width=100px><script language="JavaScript">doc(Min)</script></td></tr>
 <tr>
  <td><script language="JavaScript">doc(Start_Date)</script></td>
  <td><script language="JavaScript">iGenSel2('smon', 'smon', sel_month)</script></td> 
  <td><script language="JavaScript">iGenSel2('sweek', 'sweek', sel_week)</script></td> 
  <td><script language="JavaScript">iGenSel2('sday', 'sday', sel_day)</script></td>
  <td><script language="JavaScript">iGenSel2('shr', 'shr', sel_hr)</script></td>
  <td><script language="JavaScript">iGenSel2('smin', 'smin', sel_min)</script></td></tr> 
 <tr>
  <td><script language="JavaScript">doc(End_Date)</script></td>
  <td><script language="JavaScript">iGenSel2('emon', 'emon', sel_month)</script> </td>
  <td><script language="JavaScript">iGenSel2('eweek', 'eweek', sel_week)</script> </td>
  <td><script language="JavaScript">iGenSel2('eday', 'eday', sel_day)</script> </td>
  <td><script language="JavaScript">iGenSel2('ehr', 'ehr', sel_hr)</script></td>
  <td><script language="JavaScript">iGenSel2('emin', 'emin', sel_min)</script></td></tr>

 <tr>
  <td><script language="JavaScript">doc(Offset_hr)</script></td> 
  <td><script language="JavaScript">iGenSel2('omin', 'omin', sel_offset_hr)</script></td></tr>
</table> 


<table cellpadding=1 cellspacing=2 >
  <tr height="15">  
  <td></td></tr>
        		
 <tr>
  <td></td></tr>
 <!--<tr> 
  <td width="10%"></td>
  <td width="26%"><script language="JavaScript">doc(Time_Server_Query_Period_)</script></td> 
  <td width="64%"><input type="text" name="update_period" id=updateper size="4" maxlength="4">sec</td></tr>-->
</table>  
<p><table>
 <tr>	
  <td align=left><script language="JavaScript">fnbnB(Submit_, 'onClick=Activate(this.form)')</script></td>
  <td><script language="JavaScript" align=right>fnbnB(Refresh_, 'onClick=location.href=link0')</script></td>
  </tr>
</table> 
</fieldset>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
