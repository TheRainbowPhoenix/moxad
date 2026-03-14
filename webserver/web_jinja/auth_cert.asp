<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">

checkCookie();

if (!debug) {
	var wdata = {sslStart:'2012-12-22', sslEnd:'2012-12-22', sshStart:'2012-12-22'};
	var wtype = {sslStart:4, sslEnd:4, sshStart:4};
}else{
	{{ net_webAuthCert_info() | safe }}

	var cer_mgmt = [
		{{ net_webCERMgmt() | safe }}		
	]

	{{ net_Web_show_value('SRV_AUTH_CERT') | safe }}
}

var CertType0 = [
];

var sslmodeType0 = [
	{ value:0, text:'Auto Generate' },
	{ value:1, text:'Local Certificate Database'}
];

var selCert = { type:'select', id:'selpem', name:'selpem', size:1, style:'width:206px', onChange:'', option:CertType0 };

var myForm;

function fnChgSSL(form) {
	var mode=["true",""];
	document.getElementById('sslGen').disabled=mode[(parseInt(form.value)+1)%2];
	document.getElementById('selpem').disabled=mode[form.value];	
}

var selSSLMode = { type:'select', id:'selsslmode', name:'selsslmode', size:1, style:'width:206px', onChange:'fnChgSSL(this)', option:sslmodeType0 };

function ceroptionadd(){
	var key_tmp, i, flag=0;

	document.getElementById('selsslmode').disabled=true;
	key_tmp = document.getElementById('selpem');
	//key_tmp.options.length=0; 

	for(i = 0; i < cer_mgmt.length; i++){
		if(cer_mgmt[i].key_name==''){
			continue;
		}
		key_tmp.options.add(new Option(cer_mgmt[i].cer_name, cer_mgmt[i].cer_name)); 
		if(flag==0){
			document.getElementById('selsslmode').disabled="";
			flag=1;
		}
	}
}


function find_pem_key(pem_name)
{
	var i;
	for(i=0; i<cer_mgmt.length; i++){
		if(pem_name == cer_mgmt[i].cer_name){
			return cer_mgmt[i].key_name;
		}
	}
	return "";
}


function fnInit() {
	myForm = document.getElementById('myForm');	
	ceroptionadd();
	fnLoadForm(myForm, wdata, wtype);
	fnLoadForm(myForm, SRV_AUTH_CERT, SRV_AUTH_CERT_type);
	fnChgSSL(myForm.selsslmode);
}

function Activate(form){

	var active_flag=0;
	/*if((!form.sslGen.checked) && (!form.sshGen.checked)){
		return;
	}*/

	if(myForm.selsslmode.value==1){
		form.pemkey.value=find_pem_key(form.selpem.value);
		active_flag = 1;
	}else{
		if(form.sslGen.checked){
			form.auth_cert_reGen.value |= 0x1;
			active_flag = 1;
		}
	}

	if(form.sshGen.checked){
		form.auth_cert_reGen.value |= 0x2;
	}

	if(form.auth_cert_reGen.value!=0){
		if(confirm("Re-generating certificate or key will restart the system services within 30-40 seconds. Do you want to continue?")){
			active_flag = 1;
		}
		else{
			form.auth_cert_reGen.value=0;
			return;
		}
	}
	if(active_flag){
		form.action="/goform/net_Web_get_value?SRV=SRV_AUTH_CERT";
		form.submit();
	}
	
}

</script>
</head>
<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(AUTH_CERT)</script></h1>
<fieldset>
<form id=myForm name=myForm method="POST" action="">
  <input type="hidden" name="auth_cert_reGen" id="auth_cert_reGen" value="0">
  <input type="hidden" name="pemkey" id="pemkey" value="">
  {{ net_Web_csrf_Token() | safe }}
  <table cellpadding=1 cellspacing=2 style="width:500px">
    <tr class=r0>
      <td colspan="2"><label><script language="JavaScript">doc(SSL_CERT)</script></td>
    </tr>
    <tr>
      <td width="30%"><label><script language="JavaScript">doc(CER_DATABASE_);</script></td>
      <td width="70%"><script language="JavaScript">iGenSel4('selsslmode','selsslmode',sslmodeType0, 'fnChgSSL')</script></td>
    </tr>
    <tr> 
      <td><script language="JavaScript">doc(CER_FILE_);</script></td>
      <td><script language="JavaScript">fnGenSelect(selCert, '')</script></td>
    </tr>
    <tr>
	  <td width="30%"><label><script language="JavaScript">doc(CREATED_DATE)</script></td>
	  <td width="70%"><input type=text id=sslStart name=sslStart size=30 maxlength=30 disabled></td>
    </tr>
    <tr>
	  <td width="30%"><label><script language="JavaScript">doc(EXPIRED_DATE)</script></td>
	  <td width="70%"><input type=text id=sslEnd name=sslEnd size=30 maxlength=30 disabled></td>
    </tr>
    <tr>
	  <td width="30%"><label><script language="JavaScript">doc(RE_GENERATE);</script></td>
	  <td width="70%"><input type=checkbox id=sslGen name=sslGen></td>
    </tr>
  </table>
  <table cellpadding=1 cellspacing=2 style="width:500px">
    <tr class=r0>
      <td colspan="2"><label><script language="JavaScript">doc(SSH_KEY)</script></td>
    </tr>
    <tr>
	  <td width="30%"><label><script language="JavaScript">doc(CREATED_DATE)</script></td>
	  <td width="70%"><input type=text id=sshStart name=sshStart size=30 maxlength=30 disabled></td>
    </tr>
    <tr>
	  <td width="30%"><label><script language="JavaScript">doc(RE_GENERATE)</script></td>
	  <td width="70%"><input type=checkbox id=sshGen name=sshGen></td>
    </tr>
  </table>
  <table cellpadding=1 cellspacing=2 style="width:500px">
    <tr>	
	  <script language="JavaScript">fnbnB(Submit_, 'onClick=Activate(this.form)')</script>
    </tr>
  </table>

</form>
</fieldset> 
</body>
</html>

