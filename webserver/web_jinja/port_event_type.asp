<html>
<head>
<script language="JavaScript" src=doc.js></script>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=common.js></script>
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}
var NORELAY = {{ net_Web_Get_NO_RELAY() | safe }}
//var NORELAY=1;
checkCookie();
if(!debug){
	var SYSPORTS =16;
	var NORELAY =2;
	var SRV_PORT_EVENT={enable0:'0',enable1:'0',enable2:'0',enable3:'0',enable4:'0',enable5:'0',enable6:'0',enable7:'0',enable8:'0',enable9:'0',enable10:'0',enable11:'0',enable12:'0',enable13:'0',enable14:'0',enable15:'0',lon0:'0',lon1:'0',lon2:'0',lon3:'0',lon4:'0',lon5:'0',lon6:'0',lon7:'0',lon8:'0',lon9:'0',lon10:'0',lon11:'0',lon12:'0',lon13:'0',lon14:'0',lon15:'0',loff0:'0',loff1:'0',loff2:'0',loff3:'0',loff4:'0',loff5:'0',loff6:'0',loff7:'0',loff8:'0',loff9:'0',loff10:'0',loff11:'0',loff12:'0',loff13:'0',loff14:'0',loff15:'0',snmptrap0:'0',snmptrap1:'0',snmptrap2:'0',snmptrap3:'0',snmptrap4:'0',snmptrap5:'0',snmptrap6:'0',snmptrap7:'0',snmptrap8:'0',snmptrap9:'0',snmptrap10:'0',snmptrap11:'0',snmptrap12:'0',snmptrap13:'0',snmptrap14:'0',snmptrap15:'0',email0:'0',email1:'0',email2:'0',email3:'0',email4:'0',email5:'0',email6:'0',email7:'0',email8:'0',email9:'0',email10:'0',email11:'0',email12:'0',email13:'0',email14:'0',email15:'0',syslog0:'0',syslog1:'0',syslog2:'0',syslog3:'0',syslog4:'0',syslog5:'0',syslog6:'0',syslog7:'0',syslog8:'0',syslog9:'0',syslog10:'0',syslog11:'0',syslog12:'0',syslog13:'0',syslog14:'0',syslog15:'0',relay10:'0',relay11:'0',relay12:'0',relay13:'0',relay14:'0',relay15:'0',relay16:'0',relay17:'0',relay18:'0',relay19:'0',relay110:'0',relay111:'0',relay112:'0',relay113:'0',relay114:'0',relay115:'0',relay20:'0',relay21:'0',relay22:'0',relay23:'0',relay24:'0',relay25:'0',relay26:'0',relay27:'0',relay28:'0',relay29:'0',relay210:'0',relay211:'0',relay212:'0',relay213:'0',relay214:'0',relay215:'0',severity0:'0',severity1:'0',severity2:'0',severity3:'0',severity4:'0',severity5:'0',severity6:'0',severity7:'0',severity8:'0',severity9:'0',severity10:'0',severity11:'0',severity12:'0',severity13:'0',severity14:'0',severity15:'0',checkall0:'0',checkall1:'0',checkall2:'0',checkall3:'0',checkall4:'0',checkall5:'0',checkall6:'0',checkall7:'0'}
	var SRV_PORT_EVENT_type = {enable0:3,enable1:3,enable2:3,enable3:3,enable4:3,enable5:3,enable6:3,enable7:3,enable8:3,enable9:3,enable10:3,enable11:3,enable12:3,enable13:3,enable14:3,enable15:3,lon0:3,lon1:3,lon2:3,lon3:3,lon4:3,lon5:3,lon6:3,lon7:3,lon8:3,lon9:3,lon10:3,lon11:3,lon12:3,lon13:3,lon14:3,lon15:3,loff0:3,loff1:3,loff2:3,loff3:3,loff4:3,loff5:3,loff6:3,loff7:3,loff8:3,loff9:3,loff10:3,loff11:3,loff12:3,loff13:3,loff14:3,loff15:3,snmptrap0:3,snmptrap1:3,snmptrap2:3,snmptrap3:3,snmptrap4:3,snmptrap5:3,snmptrap6:3,snmptrap7:3,snmptrap8:3,snmptrap9:3,snmptrap10:3,snmptrap11:3,snmptrap12:3,snmptrap13:3,snmptrap14:3,snmptrap15:3,email0:3,email1:3,email2:3,email3:3,email4:3,email5:3,email6:3,email7:3,email8:3,email9:3,email10:3,email11:3,email12:3,email13:3,email14:3,email15:3,syslog0:3,syslog1:3,syslog2:3,syslog3:3,syslog4:3,syslog5:3,syslog6:3,syslog7:3,syslog8:3,syslog9:3,syslog10:3,syslog11:3,syslog12:3,syslog13:3,syslog14:3,syslog15:3,relay10:3,relay11:3,relay12:3,relay13:3,relay14:3,relay15:3,relay16:3,relay17:3,relay18:3,relay19:3,relay110:3,relay111:3,relay112:3,relay113:3,relay114:3,relay115:3,relay20:3,relay21:3,relay22:3,relay23:3,relay24:3,relay25:3,relay26:3,relay27:3,relay28:3,relay29:3,relay210:3,relay211:3,relay212:3,relay213:3,relay214:3,relay215:3,severity0:3,severity1:3,severity2:3,severity3:3,severity4:3,severity5:3,severity6:3,severity7:3,severity8:3,severity9:3,severity10:3,severity11:3,severity12:3,severity13:3,severity14:3,severity15:3,checkall0:3,checkall1:3,checkall2:3,checkall3:3,checkall4:3,checkall5:3,checkall6:3,checkall7:3};
}else{
	{{ net_Web_show_value('SRV_PORT_EVENT') | safe }}
	var port_desc=[{{ net_webPortDesc() | safe }}];
}

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

	for(i=0; i<SYSPORTS; i++){
		if(document.getElementById(id+i).checked == true)
			count++;
	}
	if(count == SYSPORTS)
		document.getElementById(check).checked=true;
	
	else
		document.getElementById(check).checked=false;
}

function enableAll(checkValue,id){
	var i;
    for(i=0;i<SYSPORTS;i++){
	    document.getElementById(id+i).checked=checkValue;
    }
}

function show_event_table(){
	if(NORELAY==2){
	  document.write('<th colspan="5" align="center"><script language="JavaScript">doc(Action_)<\/script><\/th>');
      document.write('<th rowspan=2 align="center"><script language="JavaScript">doc(Severity_)<\/script><\/th><\/tr>');
	  document.write('<tr>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall3 name="checkall3" onclick="enableAll(this.checked,\'snmptrap\')" ><script language="JavaScript">doc(Snmp_Trap_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall4 name="checkall4" onclick="enableAll(this.checked,\'email\')" ><script language="JavaScript">doc(E_Mail)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall5 name="checkall5" onclick="enableAll(this.checked,\'syslog\')" ><script language="JavaScript">doc(Syslog_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall6 name="checkall6" onclick="enableAll(this.checked,\'relay1\')" ><script language="JavaScript">doc(Relay1_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall7 name="checkall7" onclick="enableAll(this.checked,\'relay2\')" ><script language="JavaScript">doc(Relay2_)<\/script><\/th>');
	  document.write('<\/tr><\/table>');
	}else{
	  document.write('<th colspan="4" align="center"><script language="JavaScript">doc(Action_)<\/script><\/th>');
      document.write('<th rowspan=2 align="center"><script language="JavaScript">doc(Severity_)<\/script><\/th><\/tr>');
	  document.write('<tr>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall3 name="checkall3" onclick="enableAll(this.checked,\'snmptrap\')" ><script language="JavaScript">doc(Snmp_Trap_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall4 name="checkall4" onclick="enableAll(this.checked,\'email\')" ><script language="JavaScript">doc(E_Mail)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall5 name="checkall5" onclick="enableAll(this.checked,\'syslog\')" ><script language="JavaScript">doc(Syslog_)<\/script><\/th>');
 	  document.write('<th align="left"><input type="checkbox" id=checkall6 name="checkall6" onclick="enableAll(this.checked,\'relay1\')" ><script language="JavaScript">doc(Relay1_)<\/script><\/th>');
	  document.write('<\/tr><\/table>');	
	}
}	
function Addformat(idx, newdata)
{	
    if(idx<SYSPORTS)
    {	
		newdata[0] = "<input type=checkbox name="+'enable'+idx+" id="+ 'enable'+idx +" "+((parseInt(SRV_PORT_EVENT['enable'+idx])) ? 'checked':'') +" onclick=enableClick('enable','checkall0') >";
		newdata[1] = port_desc[idx].index;
		newdata[2] = "<input type=checkbox name="+'lon'+idx+ " id="+ 'lon'+idx +" " + ((parseInt(SRV_PORT_EVENT['lon'+idx])) ? 'checked':'') +" onclick=enableClick('lon','checkall1') >";
		newdata[3] = "<input type=checkbox name="+'loff'+idx+ " id="+ 'loff'+idx +" " + ((parseInt(SRV_PORT_EVENT['loff'+idx])) ? 'checked':'') +" onclick=enableClick('loff','checkall2') >";
		newdata[4] = "<input type=checkbox name="+'snmptrap'+idx+ " id="+ 'snmptrap'+idx +" " + ((parseInt(SRV_PORT_EVENT['snmptrap'+idx])) ? 'checked':'') +" onclick=enableClick('snmptrap','checkall3') >";
		newdata[5] = "<input type=checkbox name="+'email'+idx+ " id="+ 'email'+idx +" " + ((parseInt(SRV_PORT_EVENT['email'+idx])) ? 'checked':'') +" onclick=enableClick('email','checkall4') >";
		newdata[6] = "<input type=checkbox name="+'syslog'+idx+ " id="+ 'syslog'+idx +" " + ((parseInt(SRV_PORT_EVENT['syslog'+idx])) ? 'checked':'') +" onclick=enableClick('syslog','checkall5') >";
		if(NORELAY == 2){
			newdata[7] = "<input type=checkbox name="+'relay1'+idx+  " id="+ 'relay1'+idx +" " + ((parseInt(SRV_PORT_EVENT['relay1'+idx])) ? 'checked':'') +" onclick=enableClick('relay1','checkall6') >";
			newdata[8] = "<input type=checkbox name="+'relay2'+idx+  " id="+ 'relay2'+idx +" " + ((parseInt(SRV_PORT_EVENT['relay2'+idx])) ? 'checked':'') +" onclick=enableClick('relay2','checkall7') >";
			newdata[9] = iGenSel2Str('severity' + idx,'severity' + idx,severity_sel);
		}else{
			newdata[7] = "<input type=checkbox name="+'relay1'+idx+  " id="+ 'relay1'+idx +" " + ((parseInt(SRV_PORT_EVENT['relay1'+idx])) ? 'checked':'') +" onclick=enableClick('relay1','checkall6') >";
			newdata[8] = iGenSel2Str('severity' + idx,'severity' + idx,severity_sel);			
		
		}
    }
}

function tableinit(){
	var newdata=new Array;
	var i;
	
	for(i=0; i<SYSPORTS; i++){
		    Addformat(i, newdata);
		    tableaddRow("show_available_table", i, newdata, "left");
	}
}



var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	tableinit();
	
	fnLoadForm(myForm, SRV_PORT_EVENT, SRV_PORT_EVENT_type);
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(Port);doc(" ");doc(Event_ );doc(" ");doc(Settings_);</script></h1>
<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_PORT_EVENT">
{{ net_Web_csrf_Token() | safe }}
<fieldset>
<input type="hidden" name="em_hidden" id="em_hidden" value="" >
<table cellpadding=1 cellspacing=2 id="show_available_table" style="width:700px" border=0>
 <tr align="left" >
  <th width="2%" rowspan=2 align="left">
  <script language="JavaScript">doc(Enable_)</script>
  <input type="checkbox" id=checkall0 name="checkall0" onclick="enableAll(this.checked,'enable')">
  </th>
  <th rowspan=2><script language="JavaScript">doc(WAN_Port_)</script></th>
  <th rowspan=2 align="left"><input type="checkbox" id=checkall1 name="checkall1" onclick="enableAll(this.checked,'lon')">
  <script language="JavaScript">doc(Link_);document.write("-");doc(ON_)</script></th>
  <th rowspan=2 align="left"><input type="checkbox" id=checkall2 name="checkall2" onclick="enableAll(this.checked,'loff')">
  <script language="JavaScript">doc(Link_);document.write("-");doc(OFF_)</script></th>
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

