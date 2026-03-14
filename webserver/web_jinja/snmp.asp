<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie();
if (!debug) {
	var SRV_SNMP={version:'0',username:'admin',Community0:'public',Community1:'private',trap_com:'trap',access0:'0',access1:'0',trapmode:'0',authtype:'0',authkey:'',trapaddr0:'0.0.0.0',trapaddr1:'0.0.0.0',trapaddr2:'0.0.0.0'}		
}else{
	{{ net_Web_show_value('SRV_SNMP') | safe }}
}

{% include "snmp_data" ignore missing %}

//var SRV_SNMP_type = { version:2, username:2, Community0:4, access0:2, Community1:4, access1:2, trapaddr0:5, trapaddr1:5, trapaddr2:5, authkey:4, authtype:2 };

var ctrl0= [
	{ value:0, text:Read_Write },
	{ value:1, text:Read_Only },
	{ value:2, text:No_Access },
];

var sel_mode = [
	{ value:0, text:Trap_V1 },
	{ value:1, text:Trap_V2c },
	{ value:2, text:Inform_V2c },
];

var sel_ver = [
	{ value:0, text:Disable_ },
	{ value:3, text:Ver_sel_0 },
	{ value:7, text:Ver_sel_1 },
	{ value:4, text:Ver_sel_2 }
];
var sel_type = [
	{ value:0, text:auth_0 },
	{ value:1, text:auth_1 },
	{ value:2, text:auth_2 }
]

var encrypt_sel = [
	{ value:0, text:'DES' },
	{ value:1, text:'AES' }
]

var user_sel = [
	/*{ value:0, text:Admin_ },
	{ value:1, text:User_ }*/
	{ value:Admin_, text:Admin_ },
	{ value:User_, text:User_ }
]

var myForm;
function fnInit() {
	myForm = document.getElementById('myForm');
	fnLoadForm(myForm, SRV_SNMP, 0);
}

function Activate(form)
{
	var error_return_t = 0;
	if(!isNull(form.Community0.value))
		if(isSymbol(form.Community0, Community_Name + ' 1'))
			error_return_t = 1;
	if(!isNull(form.Community1.value))
		if(isSymbol(form.Community1, Community_Name + ' 2'))
			error_return_t = 1;
	if(!isNull(form.trap_com.value))
		if(isSymbol(form.trap_com, TrapCommunity_Name))
			error_return_t = 1;	
	if(!isNull(form.trapaddr0.value))
		if(isSymbol(form.trapaddr0, Target_IP_Address + ' 1'))
			error_return_t = 1;
	if(!isNull(form.trapaddr1.value))
		if(isSymbol(form.trapaddr1, Target_IP_Address + ' 2'))
			error_return_t = 1;
	if(!isNull(form.trapaddr2.value))
		if(isSymbol(form.trapaddr2, Target_IP_Address + ' 3'))
			error_return_t = 1;

	if(form.user_enable0.checked==true){
		if(isNull(form.auth_key0.value)){
			alert(Enable_+" "+ADMIN_+" "+ Data_Encryption_+" is Null");
			error_return_t = 1;	
		}else{
			if(form.auth_key0.value.length<8){
				alert(Data_Encryption_+" must be at least 8 bytes !!!");
				error_return_t = 1;	
			}

			if(isSymbol(form.auth_key0, ADMIN_+" "+ Data_Encryption_))
				error_return_t = 1;
		}
		
	}
	if(form.user_enable1.checked==true){
		if(isNull(form.auth_key1.value)){
			alert(Enable_+" "+USER_+" "+ Data_Encryption_+" is Null");
			error_return_t = 1;	
		}else{
			if(form.auth_key1.value.length<8){
				alert(Data_Encryption_+" must be at least 8 bytes !!!");
				error_return_t = 1;	
			}

			if(isSymbol(form.auth_key1, USER_+" "+ Data_Encryption_))
				error_return_t = 1;
		}
	}
		
	if (error_return_t){
		return;
	}else{
		if(form.ver_sel.value>=4){
			if(form.authkey_type_sel0.value!=2||form.authkey_type_sel1.value!=2){//no all no-auth
				alert("To access the switch via SNMPv3, your user account must have a valid password (at least 8 characters).");
			}
		}
	}
	var i;
	for(i = 0; i < document.getElementsByTagName("input").length; i ++){
		document.getElementsByTagName("input")[i].disabled = false;						
	}
	for(i = 0; i < document.getElementsByTagName("select").length; i ++){
		document.getElementsByTagName("select")[i].disabled = false;						
	}
	form.submit();
}

function ver_chg(){
	var i;

	for(i = 0; i < document.getElementsByTagName("input").length; i ++){
		document.getElementsByTagName("input")[i].disabled = myForm.ver_sel.value == 0?true:false;						
	}
	for(i = 0; i < document.getElementsByTagName("select").length; i ++){
		document.getElementsByTagName("select")[i].disabled = myForm.ver_sel.value == 0?true:false;						
	}
	
	myForm.authkey_type_sel0.disabled = myForm.ver_sel.value < 4?true:false;
	myForm.auth_key0.disabled = myForm.ver_sel.value < 4?true:false;
	myForm.authkey_type_sel1.disabled = myForm.ver_sel.value < 4?true:false;
	myForm.auth_key1.disabled = myForm.ver_sel.value < 4?true:false;
	myForm.user_enable0.disabled = myForm.ver_sel.value < 4?true:false;
	myForm.user_enable1.disabled = myForm.ver_sel.value < 4?true:false;
	document.getElementById("privtype0").disabled = myForm.ver_sel.value < 4?true:false;
	document.getElementById("privtype1").disabled = myForm.ver_sel.value < 4?true:false;
	
	myForm.ver_sel.disabled =false;
	myForm.btnS.disabled =false;
}	
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(SNMP_)</script></h1>
<form id=myForm method="POST" action="/goform/net_Web_get_value?SRV=SRV_SNMP">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table border=0>
<tr class=r0>
 <td colspan=4><script language="JavaScript">doc(System_Information)</script></td></tr>
<tr> 
 <td colspan=4><table> 
  <tr>
   <td width=120px><script language="JavaScript">doc(Snmp_ver)</script></td>
   <td colspan=3><script language="JavaScript">iGenSel3('version', 'ver_sel', sel_ver, 'ver_chg')</script></td></tr>
  </table></td> 
 </tr>  
 <tr> 
  <td colspan=4><table>
   <tr>
    <td width=120px><script language="JavaScript">doc(ADMIN_);doc(" ");doc(Auth_type)</script></td>
    <td><script language="JavaScript">iGenSel2('authtype0', 'authkey_type_sel0', sel_type)</script></td>
   </tr>
  </table></td> 
 </tr>  
 <tr> 
  <td colspan=4><table>
   <tr> 
    <td style="width:20px"><input type="checkbox" id=user_enable0 name="encenable0"></td>
    <td style="width:210px"><script language="JavaScript">doc(Enable_);doc(" ");doc(ADMIN_);doc(" ");doc(Data_Encryption_);</script></td>
    <td style="width:80px"><script language="JavaScript">doc(Encypt_type)</script></td>
    <td><script language="JavaScript">iGenSel2('privtype0', 'privtype0', encrypt_sel)</script></td>
    <td style="width:120px"><script language="JavaScript">doc(Data_Encryption_);doc(" ");doc(Key_);</script></td>
    <td ><input type="password" id=auth_key0 name="authkey0" size=25 maxlength=31 autocomplete="off"></td>
   </tr> 
  </table></td> 
 </tr>  
 <tr> 
  <td colspan=4><table>
   <tr>
    <td width=120px><script language="JavaScript">doc(USER_);doc(" ");doc(Auth_type)</script></td>
    <td><script language="JavaScript">iGenSel2('authtype1', 'authkey_type_sel1', sel_type)</script></td></tr>   
  </table></td> 
 </tr>      
 <tr> 
  <td colspan=4><table>
   <tr >
    <td style="width:20px"><input type="checkbox" id=user_enable1 name="encenable1"></td>
    <td style="width:210px"><script language="JavaScript">doc(Enable_);doc(" ");doc(USER_);doc(" ");doc(Data_Encryption_);</script></td>
    <td style="width:80px"><script language="JavaScript">doc(Encypt_type)</script></td>
    <td><script language="JavaScript">iGenSel2('privtype1', 'privtype1', encrypt_sel)</script></td>
    <td style="width:120px"><script language="JavaScript">doc(Data_Encryption_);doc(" ");doc(Key_);</script></td>
    <td><input type="password" id=auth_key1 name="authkey1" size=25 maxlength=31 autocomplete="off"></td>
   </tr> 
  </table></td> 
 </tr>  
</table></td> 
<tr>
   <script language="JavaScript">hr(4)</script></tr>
  
<tr> 
 <td colspan=4><table>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(Community_)</script></td></tr>
  <tr>
  <td width=120px><script language="JavaScript">doc(Community_Name)</script> 1</td>
  <td width=200px><input type="text" id=Community_0 name="Community0" size=25 maxlength=31></td>
  <td width=160px nowrap><script language="JavaScript">doc(Access_Control)</script> 1</td> 
  <td><script language="JavaScript">iGenSel2('access0', 'access_0', ctrl0)</script></td></tr>
  <tr>
   <td><script language="JavaScript">doc(Community_Name)</script> 2</td>
   <td><input type="text" id=Community_1 name="Community1" size=25 maxlength=31></td>
   <td><script language="JavaScript">doc(Access_Control)</script> 2</td> 
   <td><script language="JavaScript">iGenSel2('access1', 'access_1', ctrl0)</script></td></tr>
  <tr>
   <td><script language="JavaScript">doc(TrapCommunity_Name)</script></td>
   <td><input type="text" id=trap_com name="trap_com" size=25 maxlength=31></td>
   <td><script language="JavaScript">doc(Trap_Mode)</script></td>
   <td><script language="JavaScript">iGenSel2('trapmode', 'trapmode', sel_mode)</script></td></tr>
 </table></td> 
</tr>
<tr>
   <script language="JavaScript">hr(4)</script></tr>
<tr> 
 <td colspan=4><table>  
  <tr class=r0>
   <td colspan=4><script language="JavaScript">doc(Trap_Targets)</script></td></tr>
  <tr >
   <td nowrap width=120px><script language="JavaScript">doc(Target_IP_Address)</script> 1</td>
   <td colspan=3><input type="text" id=trapaddr_0 name="trapaddr0" size=50 maxlength=50></td></tr>
  <tr >
   <td><script language="JavaScript">doc(Target_IP_Address)</script> 2</td>
   <td colspan=3><input type="text" id=trapaddr_1 name="trapaddr1" size=50 maxlength=50></td></tr>
  <tr >
   <td><script language="JavaScript">doc(Target_IP_Address)</script> 3</td>
   <td colspan=3><input type="text" id=trapaddr_2 name="trapaddr2" size=50 maxlength=50></td></tr>
 </table></td> 
</tr>  
</table>
<p><table align=left>
 <tr>
  <td><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td></tr>
</table></p>
</fieldset>
</form>
</body></html>
