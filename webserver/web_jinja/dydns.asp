<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();
if (!debug) {
	var SRV_DDNS =	{
		service:'3', sername:'test1',	usrname:'test', psssward:'test', vpwd:'test',
		key:'', domname:'test.3322.org', wan:'1'//, wild:'0', bkup:'0', mail:'leadfly.com', email:''
	}
	
	var bind1 = [
		{ value:1, text:'WAN 1' },	{ value:2, text:'WAN 2' },
		{ value:3, text:'WAN 3' }
	];
	var forb = 'Force Update';
}else{
	{{ net_Web_show_value('SRV_DDNS') | safe }}			
}
{% include "dydns_data" ignore missing %}



var svrsl = [
		{ value:'0', text:'Disabled', sname:''},
		{ value:'2', text:'freedns.afraid.org', sname:'freedns.afraid.org' },
		{ value:'3', text:'3322.org', sname:'www.3322.org' },
		{ value:'4', text:'DynDns.org', sname:'members.dyndns.org' },
		{ value:'5', text:'NO-IP.com', sname:'dynupdate.no-ip.com' },
		//{ value:'1', text:'TZO.com', sname:'TZO' },
		//{ value:'99', text:'User Defined DDNS Server', sname:'ClusterLookup*.tzo.com' }
	];
//var SRV_DDNS_type1 = { sname:4, svr:2 };
//var SRV_DDNS_type1 = {service:2 };
var nulldata =	{
	usrname:'', psssward:'', vpwd:'',
	key:'', domname:'', wan:'0', wild:'0', bkup:'0', mail:'', email:''
};
var selsvr = { type:'select', name:'service', id:'dydns_type', size:'1', onChange:'svrname(this.value)', option:svrsl };
var vobjs = {};
var vname = ['tr00', 'tr01', 'tr02', 'tr03', 'tr04', 'tr05', 'tr06', 'tr10' ];

var myForm;
function fnInit() {	
	with (document) {
		myForm = getElementById('myForm');		
		for (var i in vname)
			vobjs[vname[i]] = getElementById(vname[i]);		
	}
	
	fnLoadForm(myForm, SRV_DDNS, SRV_DDNS_type);
	//myForm.vpwd.value = myForm.psssward.value;
}

function Activate(form)
{
	var error_return_t = 0;
	if(!isNull(myForm.usrname.value))
		if((isSymbol(myForm.usrname, User_Name)))
			error_return_t = 1;
	if(!isNull(myForm.psssward.value))
		if((isSymbol(myForm.psssward, Password_)))
			error_return_t = 1;
	if(!isNull(myForm.vpwd.value))
		if((isSymbol(myForm.vpwd, Verify_Password)))
			error_return_t = 1;
	if(!isNull(myForm.key.value))
		if((isSymbol(myForm.key, Key_)))
			error_return_t = 1;
	if(!isNull(myForm.domname.value))
		if((isSymbol(myForm.domname, Domain_Name)))
			error_return_t = 1;
	if(myForm.service.value != 0){
	if(myForm.vpwd.value!=myForm.psssward.value){	
		alert(Verify_Password +" error");
		error_return_t = 1;
	}
	}		

	if (error_return_t)
		return;

	form.submit();
}

function svrname(val) {	
	var i;
	for (i in svrsl) {
		if(val=='99'){
			if(svrsl[i].value == val) {
				myForm.sname.value = SRV_DDNS.sname;				
				break;
			}
		}
		else{
			if(svrsl[i].value == val) {
				//myForm.sname.value = svrsl[i].sname;				
				document.getElementById("sname").innerHTML = svrsl[i].sname;
				break;
			}
		}	
	}
	/*if (val == SRV_DDNS.service){
		fnLoadForm(myForm, SRV_DDNS, SRV_DDNS_type);
	}else{
		nulldata.service=val;
		fnLoadForm(myForm, nulldata, SRV_DDNS_type);
	}*/
	
	var i;
	for(i in SRV_DDNS_type){
		if(!document.getElementsByName(i)[0]||i=="service"){
			continue;
		}else{
			if(val == '0'){
				document.getElementsByName(i)[0].disabled = true;
			}else{
				document.getElementsByName(i)[0].disabled = false;			
			}
		}
	}
	
	var tzo = (val == '1');
	vobjs.tr00.style.display = tzo ? 'none' : '';
	vobjs.tr01.style.display = tzo ? 'none' : '';
	vobjs.tr02.style.display = tzo ? 'none' : '';
	vobjs.tr03.style.display = tzo ? 'none' : '';	
	vobjs.tr04.style.display = tzo ? '' : 'none';	
	//vobjs.tr10.style.display = tzo ? '' : 'none';
	vobjs.tr05.className = tzo ? 'r1' : 'r2';
	vobjs.tr06.className = tzo ? 'r2' : 'r1';
}
</script>
</head>

<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(Dynamic_DNS)</script></h1>
<form id=myForm method="POST" action="/goform/net_Web_get_value?SRV=SRV_DDNS">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2>
 <tr class=r0>
  <td colspan=5><script language="JavaScript">doc(Dynamic_DNS_Service)</script></td></tr>
 <tr class=r1>
  <td width=15%><script language="JavaScript">doc(Service_)</script></td>
  <td><script language="JavaScript">fnGenSelect(selsvr, '')</script></td></tr>
 <tr class=r2 id=tr00>
  <td><script language="JavaScript">doc(Server_Name_)</script></td>
  <!--td><input type="text" id=sname name="dydns_svr" size=32 maxlength=45></td></tr-->
  <td  id=sname></td>  
 <tr class=r1 id=tr01>
  <td><script language="JavaScript">doc(User_Name)</script></td>
  <td><input type="text" name=usrname id="dydns_usrname" size=32 maxlength=45></td></tr>
 <tr class=r2 id=tr02>
 <td><script language="JavaScript">doc(Password_)</script></td>
  <td><input type="password" name=psssward id="dydns_pwd" size=32 maxlength=45 autocomplete="off"></td></tr>
 <tr class=r1 id=tr03>
  <td><script language="JavaScript">doc(Verify_Password)</script></td>
  <td><input type="password" name=vpwd id="dydns_verpwd" size=32 maxlength=45 autocomplete="off"></td></tr>
 <tr class=r2 id=tr04>
  <td><script language="JavaScript">doc(Key_)</script></td>
  <td><input type="text" name=key id="dydns_key" size=32 maxlength=32></td></tr>
 <tr class=r2 id=tr05>
  <td><script language="JavaScript">doc(Domain_Name)</script></td>
  <td><input type="text" name=domname id="dydns_host" size=32 maxlength=45></td></tr>
 <tr class=r1 id=tr06>
  <script language="JavaScript">hr(5)</script></tr>
</table>
<!--<table cellpadding=1 cellspacing=2>
 <tr class=r0>
  <td colspan=2><script language="JavaScript">doc(Additional_Settings)</script></td></tr>
 <tr class=r1>
  <td width=30%><script language="JavaScript">doc(Enable_Wildcard)</script></td>
  <td><input type="checkbox" id=wild name="dydns_wildcard" value=1></td></tr>
 <tr class=r2>
  <td><script language="JavaScript">doc(Enable_Backup_MX)</script></td>
  <td><input type="checkbox" id=bkup name="dydns_backup" value=1></td></tr>
 <tr class=r1>
  <td><script language="JavaScript">doc(Mail_Exchanger)</script></td>
  <td><input type="text" id=mail name="dydns_mail" size=32 maxlength=32></td></tr>
 <tr class=r2 id=tr10>
  <td><script language="JavaScript">doc(E_Mail)</script></td>
  <td><input type="text" id=email name="dydns_email" size=32 maxlength=32></td></tr>
 <tr class=r1>
  <script language="JavaScript">hr(3)</script></tr>
</table>-->
<table cellpadding=1 cellspacing=2>
 <!--<tr class=r0>
  <td colspan=4><script language="JavaScript">doc(WAN_Port_Binding)</script></td></tr>
 <tr class=r1>
  <td width=30%><script language="JavaScript">iGenSel2('dydns_bind', 'bind', bind1)</script></td>
  <!--<td><script language="JavaScript">fnbnS(forb, '')</script></td></tr>-->
</table>
<p><table class=tf align=left>
 <tr>
  <td><script language="JavaScript">fnbnB(Submit_, 'onClick=Activate(this.form)')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnB(Cancel_, 'onClick=location.reload()')</script></td></tr>
</table></p>
</fieldset>
</form>
</body></html>