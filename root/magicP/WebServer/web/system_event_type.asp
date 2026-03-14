<html>
<head>
<script language="JavaScript" src=doc.js></script>
<!-- <title><script language="JavaScript">doc(system_);doc(" ");doc(Event_ );doc(" ");doc(Settings_);</script></title>-->

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=common.js></script>
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
var NORELAY = <% net_Web_Get_NO_RELAY(); %>
//var NORELAY=1;
if(!debug){
	var NORELAY=2;
	var SRV_SYSTEM_EVENT_type = {enable0:3,enable1:3,enable2:3,enable3:3,enable4:3,enable5:3,enable6:3,enable7:3,snmptrap0:3,snmptrap1:3,snmptrap2:3,snmptrap3:3,snmptrap4:3,snmptrap5:3,snmptrap6:3,snmptrap7:3,email0:3,email1:3,email2:3,email3:3,email4:3,email5:3,email6:3,email7:3,syslog0:3,syslog1:3,syslog2:3,syslog3:3,syslog4:3,syslog5:3,syslog6:3,syslog7:3,relay10:3,relay11:3,relay12:3,relay13:3,relay14:3,relay15:3,relay16:3,relay17:3,relay20:3,relay21:3,relay22:3,relay23:3,relay24:3,relay25:3,relay26:3,relay27:3,severity0:3,severity1:3,severity2:3,severity3:3,severity4:3,severity5:3,severity6:3,severity7:3,checkall0:3,checkall1:3,checkall2:3,checkall3:3,checkall4:3,checkall5:3};
	var SRV_SYSTEM_EVENT={enable0:'0',enable1:'0',enable2:'0',enable3:'0',enable4:'0',enable5:'0',enable6:'0',enable7:'0',snmptrap0:'0',snmptrap1:'0',snmptrap2:'0',snmptrap3:'0',snmptrap4:'0',snmptrap5:'0',snmptrap6:'0',snmptrap7:'0',email0:'0',email1:'0',email2:'0',email3:'0',email4:'0',email5:'0',email6:'0',email7:'0',syslog0:'0',syslog1:'0',syslog2:'0',syslog3:'0',syslog4:'0',syslog5:'0',syslog6:'0',syslog7:'0',relay10:'0',relay11:'0',relay12:'0',relay13:'0',relay14:'0',relay15:'0',relay16:'0',relay17:'0',relay20:'0',relay21:'0',relay22:'0',relay23:'0',relay24:'0',relay25:'0',relay26:'0',relay27:'0',severity0:'0',severity1:'0',severity2:'0',severity3:'0',severity4:'0',severity5:'0',severity6:'0',severity7:'0',checkall0:'0',checkall1:'0',checkall2:'0',checkall3:'0',checkall4:'0',checkall5:'0'}
}else{
	<%net_Web_show_value('SRV_SYSTEM_EVENT');%>
}
var event_total = [	
	{text:CS_},
	{text:WS_},
	{text:Pow_tran_off1_},
	{text:Pow_tran_off2_},
	{text:Pow_tran_on1_},
	{text:Pow_tran_on2_},
	{text:DIoff_},
	{text:DIon_},
	{text:Conf_Chg},
	{text:Auth_Fail},
	{text:Rdndnt_TopologyChg_},
	{text:MasterMismatch_},
	{text:Coupling_TopologyChg_},
	{text:Fiber_Check_Warning_}
];

var action_sel = [	
	{ value:0, text:Snmp_Trap_ },
	{ value:1, text:E_Mail },
	{ value:2, text:Syslog_ },
	{ value:3, text:Group1_ },
	{ value:4, text:Group2_ },
	{ value:5, text:Group3_ },
	{ value:6, text:Group4_ }
];	

var severity_sel = [
	{ value:0, text:Emerg_ },
	{ value:1, text:Alert_ },
	{ value:2, text:Crit_ },
	{ value:3, text:Err_ },
	{ value:4, text:Warn_ },
	{ value:5, text:Notice_ },
	{ value:6, text:Info_ },
	{ value:7, text:Debug_ }
];	

function enableClick(id,check)
{
	var count=0;
	if(id=='relay1' || id=='relay2'){
		
		for(i=2;i<4;i++){
			if(document.getElementById(id+i).checked == true)
				count++;
		}
		
		if(count == 2){
			document.getElementById(check).checked=true;
		}
		else
			document.getElementById(check).checked=false;

	}else{
	
		for(i=0; i<event_total.length; i++){
			if(document.getElementById(id+i).checked == true)
				count++;
		}
		
		if(count == event_total.length){
			document.getElementById(check).checked=true;
		}
		else
			document.getElementById(check).checked=false;
	}
		
}

function enableAll(checkValue,id){
	var i;
	if(id=='relay1' || id=='relay2'){
		for(i=0;i<event_total.length;i++){
			if(i == 2 || i == 3 || i == 6 || i == 7){
				document.getElementById(id+i).checked=checkValue;
			}
		}	
	}else{	
	    for(i=0;i<event_total.length;i++){
		    document.getElementById(id+i).checked=checkValue;
	    }
	}
}

function show_event_table(){
	if(NORELAY==2){
	  document.write('<th colspan="5" align="center"><script language="JavaScript">doc(Action_)<\/script><\/th>');
      document.write('<th rowspan=2 align="center"><script language="JavaScript">doc(Severity_)<\/script><\/th><\/tr>');
	  document.write('<tr>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall1 name="checkall1" onclick="enableAll(this.checked,\'snmptrap\')" ><script language="JavaScript">doc(Snmp_Trap_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall2 name="checkall2" onclick="enableAll(this.checked,\'email\')" ><script language="JavaScript">doc(E_Mail)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall3 name="checkall3" onclick="enableAll(this.checked,\'syslog\')" ><script language="JavaScript">doc(Syslog_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall4 name="checkall4" onclick="enableAll(this.checked,\'relay1\')" ><script language="JavaScript">doc(Relay1_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall5 name="checkall5" onclick="enableAll(this.checked,\'relay2\')" ><script language="JavaScript">doc(Relay2_)<\/script><\/th>');
	  document.write('<\/tr><\/table>');
	}else{
	  document.write('<th colspan="4" align="center"><script language="JavaScript">doc(Action_)<\/script><\/th>');
      document.write('<th rowspan=2 align="center"><script language="JavaScript">doc(Severity_)<\/script><\/th><\/tr>');
	  document.write('<tr>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall1 name="checkall1" onclick="enableAll(this.checked,\'snmptrap\')" ><script language="JavaScript">doc(Snmp_Trap_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall2 name="checkall2" onclick="enableAll(this.checked,\'email\')" ><script language="JavaScript">doc(E_Mail)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall3 name="checkall3" onclick="enableAll(this.checked,\'syslog\')" ><script language="JavaScript">doc(Syslog_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall4 name="checkall4" onclick="enableAll(this.checked,\'relay1\')" ><script language="JavaScript">doc(Relay1_)<\/script><\/th>');
	  document.write('<\/tr><\/table>');	
	}
}	
function Addformat(idx, newdata)
{	
    if(idx<event_total.length)
    {	
		newdata[0] = "<input type=checkbox name="+'enable'+idx+ " id="+ 'enable'+idx +" "+((parseInt(SRV_SYSTEM_EVENT['enable'+idx])) ? 'checked':'') +" onclick=enableClick('enable','checkall0') >";
		newdata[1] = event_total[idx].text;	
		newdata[2] = "<input type=checkbox name="+'snmptrap'+idx+ " id="+ 'snmptrap'+idx +" " + ((parseInt(SRV_SYSTEM_EVENT['snmptrap'+idx])) ? 'checked':'') +" onclick=enableClick('snmptrap','checkall1') >";
		if(idx != 13 ){
			newdata[3] = "<input type=checkbox name="+'email'+idx+ " id="+ 'email'+idx +" " + ((parseInt(SRV_SYSTEM_EVENT['email'+idx])) ? 'checked':'') +" onclick=enableClick('email','checkall2') >";
			newdata[4] = "<input type=checkbox name="+'syslog'+idx+ " id="+ 'syslog'+idx +" " + ((parseInt(SRV_SYSTEM_EVENT['syslog'+idx])) ? 'checked':'') +" onclick=enableClick('syslog','checkall3') >";
		}else{
			newdata[3] = "";
			newdata[4] = "";
		}
		if(NORELAY == 2){
			if(idx == 2 ||idx ==3 || idx == 6 || idx == 7){	
			newdata[5] = "<input type=checkbox name="+'relay1'+idx+ " id="+ 'relay1'+idx +" " + ((parseInt(SRV_SYSTEM_EVENT['relay1'+idx])) ? 'checked':'') +" onclick=enableClick('relay1','checkall4') >";
			newdata[6] = "<input type=checkbox name="+'relay2'+idx+ " id="+ 'relay2'+idx +" " + ((parseInt(SRV_SYSTEM_EVENT['relay2'+idx])) ? 'checked':'') +" onclick=enableClick('relay2','checkall5') >";
			}
			else{
			newdata[5] = "";
			newdata[6] = "";
			}	
		newdata[7] = iGenSel2Str('severity' + idx,'severity' + idx,severity_sel);
		}else{
			if(idx == 2 ||idx ==3 || idx == 6 || idx ==7){
			newdata[5] = "<input type=checkbox name="+'relay1'+idx+ " id="+ 'relay1'+idx +" " + ((parseInt(SRV_SYSTEM_EVENT['relay1'+idx])) ? 'checked':'') +" onclick=enableClick('relay1','checkall4') >";
			}
			else{
			newdata[5] = "";
			}	
			newdata[6] = iGenSel2Str('severity' + idx,'severity' + idx,severity_sel);
		}
		
    }
}

function tableinit(){
	var newdata=new Array;
	var i;
	
	for(i=0; i<event_total.length; i++){
		    Addformat(i, newdata);
		    	tableaddRow("show_available_table", i, newdata, "left");
	}
}



var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	tableinit();
	fnLoadForm(myForm, SRV_SYSTEM_EVENT, SRV_SYSTEM_EVENT_type);
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(system_);doc(" ");doc(Event_ );doc(" ");doc(Settings_);</script></h1>

<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_SYSTEM_EVENT">
<% net_Web_csrf_Token(); %>
<fieldset>
<input type="hidden" name="em_hidden" id="em_hidden" value="" >
<table cellpadding=1 cellspacing=2 style="width:750px">
 <tr align="center" >
  <td width="8%" align="center"></td>
  <td width="25%"></td>
  <td width="30%" colspan="6"></td>
  <td width="25%"></td>
  </tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" style="width:700px" border=0>
 <tr align="left">
  <th width="2%" rowspan=2 align="left">
  <script language="JavaScript">doc(Enable_)</script>
  <input type="checkbox" id=checkall0 name="checkall0" onclick="enableAll(this.checked,'enable')">
  </th>
  <th rowspan=2 align="center"><script language="JavaScript">doc(Event_)</script></th>  	
 	  <script language="JavaScript">show_event_table()</script>
<p><table align=left>
 <tr>
  <td><script language="JavaScript">fnbnS(Submit_, '')</script></td>
  <td width=15></td></tr>
</table></p>
</fieldset>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

