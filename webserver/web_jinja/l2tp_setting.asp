<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(L2tp_Settings_)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();
if (!debug) {
	var SRV_L2TPD = [
		{enable:'0', lip:'10.10.10.1', oiplo:'10.10.10.2', oiphi:'10.10.10.254',username:'aries', userpw:'123456'},
		{enable:'0', lip:'10.10.10.1', oiplo:'10.10.10.2', oiphi:'10.10.10.254',username:'aries', userpw:'123456'}
	];
}else{
	
	{{ net_Web_show_value('SRV_L2TPD') | safe }}
	
}


/*var SRV_L2TPD_type = {
	enable:2, lip:5, oiplo:5, oiphi:5, username:4, userpw:4
};*/

var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

var myForm;	
function Activate(form)
{	
	document.getElementById("btnU").disabled="true";
	var i;
	var j;
	form.l2tptmp.value="";

	for(i = 0 ; i < SRV_L2TPD.length ; i++)
	{	
		if(!(SerIpRangeCheck(document.getElementsByName('form1')[i]["oiplo"].value,document.getElementsByName('form1')[i]["oiphi"].value, 256)))
		{
			document.getElementById("btnU").disabled="";
			return;
		}
		for (var j in SRV_L2TPD_type){
			form.l2tptmp.value = form.l2tptmp.value + myForm[i][j].value + "+";	
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_L2TPD";	
	form.submit();	
}

var actb = 'Active';
var myForm;
var selstate = { type:'select', id:'enable', name:'enable', size:1, option:wtyp0 };
	
{% include "lan_data" ignore missing %}
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page=0&back=0&';

function fnInit() {	
	myForm = document.getElementsByName('form1');	
	for(var i = 0 ; i < SRV_L2TPD.length ; i++)
	{			
		fnLoadForm(myForm[i], SRV_L2TPD[i], SRV_L2TPD_type);	
	}
	
	if(ProjectModel == MODEL_EDR_G903){
		document.getElementById("wan1_pw").style.display="none";
		document.getElementById("wan2_pw").style.display="";
		document.getElementById("myForm1").style.display="";
	}
	else{
		document.getElementById("wan1_pw").style.display="";
		document.getElementById("wan2_pw").style.display="none";
		document.getElementById("myForm1").style.display="none";
	}
}

function PrintIfsDoc(if_idx) {	
	document.write('<td width=200px colspan=5>'+L2TP_SERVER_SETTING_+' (');
	if(if_idx == 1){
		if(ProjectModel == MODEL_EDR_G903){
			document.write(WAN1_);
		}
		else{
			document.write(WAN_);
		}
	}else{
		document.write(WAN2_);
	}
	document.write(')'+'</td>');
}


function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2 border=0 align=center width=500px>
 <tr class=r0 >
 <script language="JavaScript">PrintIfsDoc(1)</script>
 </tr>    
 <tr class=r1 align="left">
  <td width=120px><script language="JavaScript">doc(L2tp_STATE_)</script></td>
  <td><script language="JavaScript">fnGenSelect(selstate, '')</script></td>
  <td></td>
 </tr>  
 <tr class=r2 align="left">
  <td><script language="JavaScript">doc(L2tp_L_IP_)</script></td>
  <td><input type="text" id=lip name="lip" size=15 maxlength=15></td>
  <td></td></tr>
 <tr class=r1 align="left">  
  <td><script language="JavaScript">doc(Offered_IP_Range)</script></td>  
  <td><input type="text" id=oiplo name="oiplo" size=15 maxlength=15 >~
  <input type="text" id=oiphi name="oiphi" size=15 maxlength=15 ></td>
  <td></td></tr>   
</table>
<DIV style="display:none" id="wan1_pw">
<table cellpadding=1 cellspacing=2 border=0 align=center width=500px>
 <tr class=r0 >
  <td colspan=5><script language="JavaScript">doc(LOGIN_U_P_)</script></td></tr>    
 <tr class=r2 align="left">
  <td width=80px><script language="JavaScript">doc(User_Name)</script></td>
  <td width=120px><input type="text" id=u_name name="username" size=15 maxlength=15></td>
  <td width=80px><script language="JavaScript">doc(Password_)</script></td>
  <td><input type="text" id=u_pw name="userpw" size=15 maxlength=15></td></tr>
</table>
</DIV>
</form>
<form id=myForm1 name=form1 method="POST" action="/goform/net_Webl2tpedGetValue">
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2 border=0 align=center width=500px>
 <tr class=r0 >
 <td colspan=5><script language="JavaScript">PrintIfsDoc(2)</script></td></tr>    
 <tr class=r1 align="left">
  <td width=100px><script language="JavaScript">doc(L2tp_STATE_)</script></td>
  <td width=100px><script language="JavaScript">fnGenSelect(selstate, '')</script></td>
 </tr>  
 <tr class=r2 align="left">
  <td><script language="JavaScript">doc(L2tp_L_IP_)</script></td>
  <td><input type="text" id=lip name="lip" size=15 maxlength=15></td></tr>
 <tr class=r1 align="left">  
  <td><script language="JavaScript">doc(Offered_IP_Range)</script></td>  
  <td><input type="text" id=oiplo name="oiplo" size=15 maxlength=15 >~
  <input type="text" id=oiphi name="oiphi" size=15 maxlength=15 ></td></tr> 
</table>
 <p></p>
<DIV style="display:none" id="wan2_pw">
<table cellpadding=1 cellspacing=2 border=0 align=left width=500px>
 <tr class=r0 >
  <td colspan=5><script language="JavaScript">doc(LOGIN_U_P_)</script></td></tr>    
 <tr class=r2 align="left">
  <td width=80px><script language="JavaScript">doc(User_Name)</script></td>
  <td width=120px><input type="text" id=u_name name="username" size=15 maxlength=15></td>
  <td width=80px><script language="JavaScript">doc(Password_)</script></td>
  <td></td>
  <td><input type="text" id=u_pw name="userpw" size=15 maxlength=15></td></tr>
</table>
</DIV>
</form>

<form id=myForm2 name=form1 method="POST">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="SRV_L2TPD_tmp" id="l2tptmp" value="" >
<p><table class=tf align=left>
 <tr>
   <td><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
  <td width=15></td></tr>
</table></p>

</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
