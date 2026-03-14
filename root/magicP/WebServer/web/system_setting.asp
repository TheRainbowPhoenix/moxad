<html>
<head>
<% net_Web_file_include(); %>
<!--<title><script language="JavaScript">doc(system_iden)</script></title>-->
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>

<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = {
		sysname:'Managed Router', location:'Router Location', sysdescr:'MOXA EDR-G903', contact:'', webcfg:'1', timeout:'0'
	};
	var wtype = {sysname:4, location:4, sysdescr:4, contact:4, webcfg:2, timeout:4};
}else{
	<%net_Web_show_value('SRV_SYSINFO');%>;
}



var webconf = [
	/*{ value:0, text:Disable_},*/	{ value:1, text:Http_}, { value:2, text:HTTPS_}
];

var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_SYSINFO, SRV_SYSINFO_type);	
	//document.getElementById('ttimeout').style.display='none';
}
function isSystemSymbol(obj, ObjName){
	var TempObj;
	TempObj=obj.value;
	//var regu = "^[0-9a-zA-Z_@\u0020\u002d\u002e\u002f]+$";
	var regu = "^[0-9a-zA-Z_@!#$%^&*()\.\/\ \-]+$";    
	var re = new RegExp(regu);
	if (re.test( TempObj ) ) {    
		return 0;    
	} 
	else{   
		alert(MsgHead[0]+ObjName+MsgStrs[5]);
		return 1;    
	}
}


function isSymbolMessage(obj, ObjName){
	var TempObj;
	TempObj=obj.value;
	//var regu = "^[0-9a-zA-Z_@\u0020\u002d\u002e\u002f]+$";
	var regu = "^[0-9a-zA-Z_@!#$%^&*()\.\/\ \r\n\-]+$";    
	var re = new RegExp(regu);
	if (re.test( TempObj ) ) {    
		return 0;    
	} 
	else{   
		alert(MsgHead[0]+ObjName+MsgStrs[5]);
		return 1;    
	}
}


function space_check()
{
	var substr, i, name, error_return_t=0;
	var check_string=["sysname", "location", "sysdescr", "contact"];
	var Name_string=[Router_Name, Router_Location, Router_Description, Maintainer_Contact_Info];

	for(name in check_string){
		substr = document.getElementById('myForm')[check_string[name]].value.split(" ");

		if(substr.length > 5) {
	        alert(Name_string[name]+" can only have at most 4 space.");
	        error_return_t = 1;
	    }

	    for(i = 0; i < substr.length; i++) {
	        // Case: continued spaces but not empty
	        if((substr[i].length == 0) && (i != 0)) {
	            alert(Name_string[name]+" cannot have continued spaces.");
	            error_return_t = 1;
	        }
	    }	
	}
	return error_return_t;
	

}


function System_Setting_Check(form) {
	var error_return_t = 0;
	
	
	if((isSystemSymbol(document.getElementById('myForm')["sysname"], Router_Name))) {
		error_return_t = 1;
	}
	if((isSystemSymbol(document.getElementById('myForm')["location"], Router_Location))) {
		error_return_t = 1;
	}
	if(!isNull(document.getElementById('myForm')["sysdescr"].value)) {
		if((isSystemSymbol(document.getElementById('myForm')["sysdescr"], Router_Description))) {
			error_return_t = 1;
		}
	}
	if(!isNull(document.getElementById('myForm')["contact"].value)) {
		if((isSystemSymbol(document.getElementById('myForm')["contact"], Maintainer_Contact_Info))) {
			error_return_t = 1;
		}
	}
	if(!isNull(document.getElementById('myForm')["loginmsg"].value)) {
		if((isSymbolMessage(document.getElementById('myForm')["loginmsg"], Web_LOG_MSG_))) {
			error_return_t = 1;
		}
	}
	if(!isNull(document.getElementById('myForm')["loginfailmsg"].value)) {
		if((isSymbolMessage(document.getElementById('myForm')["loginfailmsg"], Web_LOG_FAIL_MSG_))) {
			error_return_t = 1;
		}
	}
	
	
	
	if(error_return_t || space_check())
		return;

	form.submit();
}
</script>
</head>
<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(system_iden)</script></h1>

<form id=myForm method="POST" action="/goform/net_Web_get_value?SRV=SRV_SYSINFO">
<fieldset>
<% net_Web_csrf_Token(); %>
<input type="hidden" name="webcfg" id="webcfg" />
 <table cellpadding=1 cellspacing=2 style="width:500px">
 <tr>
	<td><label><script language="JavaScript">doc(Router_Name)</script></td>
	<td><input type=text id=r_sysname name=sysname size= 30 maxlength=30></td>
 </tr>
<tr>
	<td><label><script language="JavaScript">doc(Router_Location)</script></td>
	<td><input type=text id=r_location name=location size=30 maxlength=80 ></td>
</tr>
<tr>
	<td><label><script language="JavaScript">doc(Router_Description)</script></td>
	<td><input type=text id=r_sysdescr name=sysdescr size=30 maxlength=30 ></td>
</tr>
<tr>
	<td><label><script language="JavaScript">doc(Maintainer_Contact_Info)</script></td>
	<td><input type=text id=r_contact name=contact size=30 maxlength=30 ></td>
</tr><tr>
	<td><label><script language="JavaScript">doc(Web_LOG_MSG_)</script></td>
	<td><textarea id=r_loginmsg name=loginmsg cols="40" rows="13" maxlength=512 onkeyup="checkmsglen(this)" onblur="this.value = this.value.slice(0,512)"></textarea></td>
</tr>
</tr><tr>
	<td><label><script language="JavaScript">doc(Web_LOG_FAIL_MSG_)</script></td>
	<td><textarea id=r_loginfailmsg name=loginfailmsg cols="40" rows="13" maxlength=512  onkeyup="checkmsglen(this)" onblur="this.value = this.value.slice(0,512)"></textarea></td>
</tr>
<!--<tr id=ttimeout>
	<td><label>Web Auto-logout (s)</td>
	<td><input type=text id=timeout name=r_logout size= 30 maxlength=30 ></td>
</tr>-->
</table>
 <table cellpadding=1 cellspacing=2 style="width:500px">
<tr>	
	<script language="JavaScript">fnbnB(Submit_, 'onClick=System_Setting_Check(this.form)')</script>
</tr>
</table>
</fieldset>
</form>

</body>
</html>
