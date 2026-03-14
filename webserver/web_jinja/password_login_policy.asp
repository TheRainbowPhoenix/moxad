<html>
<head>
<script language="JavaScript" src=doc.js></script>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=common.js></script>
<script language="JavaScript" src=mdata.js></script>
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
<script language="Javascript" src="moxa_common.js"></script>
<script language="JavaScript">
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
checkCookie();

if (!debug) {

}else{
	{{ net_Web_show_value('SRV_PW_POLICY') | safe }}
	{{ net_Web_show_value('SRV_LOGIN_LOCKOUT') | safe }}	
}

<!--
	var passwd_policy_defined = 1;
	var login_lockout_defined = 1;

	function fnInit() {
		var myForm;
		myForm = document.getElementById('password_login_policy_form');

		fnLoadForm(myForm, SRV_PW_POLICY, SRV_PW_POLICY_type);
		fnLoadForm(myForm, pw_complexity, pw_complexity_type);
		fnLoadForm(myForm, SRV_LOGIN_LOCKOUT, SRV_LOGIN_LOCKOUT_type);

		/* diable options if passwd_complexity_enable disabled. */
		var checkboxVal = $("#passwd_complexity_enable").is(':checked');
		if(checkboxVal == true){
			web_enable_DOM_item("#passwd_complexity_digit",true);
			web_enable_DOM_item("#passwd_complexity_alphabet",true);
			web_enable_DOM_item("#passwd_complexity_specialchar",true);
		}else{
			web_enable_DOM_item("#passwd_complexity_digit",false);
			web_enable_DOM_item("#passwd_complexity_alphabet",false);
			web_enable_DOM_item("#passwd_complexity_specialchar",false);
		}	

		document.getElementById("login_lockout_threshold_tmp").value = document.getElementById("login_lockout_threshold").value;
		document.getElementById("login_lockout_time_tmp").value = document.getElementById("login_lockout_time").value;

		/* diable options if login_lockout_enable disabled. */
		var checkboxVal = $("#login_lockout_enable").is(':checked');
		if(checkboxVal == true){
			web_enable_DOM_item("#login_lockout_threshold_tmp",true);
			web_enable_DOM_item("#login_lockout_time_tmp",true);
		}else{
			web_enable_DOM_item("#login_lockout_threshold_tmp",false);
			web_enable_DOM_item("#login_lockout_time_tmp",false);
		}
		
		return;
	}

	$(document).ready(function(){
		fnInit();
		$("body").click(function(){			
			web_cookie_update_touchLasttime();
		});

		$("body").keypress(function(){			
			web_cookie_update_touchLasttime();
		});

		$("input#passwd_min_length").change(function(){			
			var maxlenth = $("input#passwd_min_length").val();

			if((maxlenth<4) || (maxlenth>16) || isNaN(maxlenth) ){
				alert("Minimum Length (4~16)");
				$("input#passwd_min_length").val("4");
			}
		});

		$("input#login_lockout_threshold_tmp").change(function(){			
			var threshold = $("input#login_lockout_threshold_tmp").val();

			if((threshold<1) || (threshold>10) || isNaN(threshold) ){
				alert("Retry Failure Threshold (1~10)");
				$("input#login_lockout_threshold_tmp").val("5");
			}
		});
				
		$("input#login_lockout_time_tmp").change(function(){			
			var lockout_time = $("input#login_lockout_time_tmp").val();

			if((lockout_time<1) || (lockout_time>60) || isNaN(lockout_time) ){
				alert("Lockout Time (min) (1~60)");
				$("input#login_lockout_time_tmp").val("5");
			}
		});

		$("#passwd_complexity_enable").click(function(){			
			var checkboxVal = $("#passwd_complexity_enable").is(':checked');
			if(checkboxVal == true){
				web_enable_DOM_item("#passwd_complexity_digit",true);
				web_enable_DOM_item("#passwd_complexity_alphabet",true);
				web_enable_DOM_item("#passwd_complexity_specialchar",true);
			}else{
				web_enable_DOM_item("#passwd_complexity_digit",false);
				web_enable_DOM_item("#passwd_complexity_alphabet",false);
				web_enable_DOM_item("#passwd_complexity_specialchar",false);
			}
		});

		$("#login_lockout_enable").click(function(){						
			checkboxVal = $("#login_lockout_enable").is(':checked');
			if(checkboxVal == true){
				web_enable_DOM_item("#login_lockout_threshold_tmp",true);
				web_enable_DOM_item("#login_lockout_time_tmp",true);
			}else{
				web_enable_DOM_item("#login_lockout_threshold_tmp",false);
				web_enable_DOM_item("#login_lockout_time_tmp",false);			
			}
		});

		if(passwd_policy_defined==0){
			$('.pwd_policy').hide();
		}

		if(login_lockout_defined==0){		
			$('.login_lockout').hide();
		}
		
		web_account_diff();
		
	});

	function add_new_data(itemPasswdMinLength,itemPasswdComplexityEnable,itemPasswdComplexityDigit
					,itemPasswdComplexityAlphabet,itemPasswdComplexitySpecialchar)
	{
		$("input#passwd_min_length").val(itemPasswdMinLength);
		if(itemPasswdComplexityEnable==1){
			$("input#passwd_complexity_enable").prop("checked",true);
		}else{
			$("input#passwd_complexity_enable").prop("checked",false);
		}
		if(itemPasswdComplexityDigit==1){
			$("input#passwd_complexity_digit").prop("checked",true);
		}else{
			$("input#passwd_complexity_digit").prop("checked",false);
		}		
		if(itemPasswdComplexityAlphabet==1){
			$("input#passwd_complexity_alphabet").prop("checked",true);
		}else{
			$("input#passwd_complexity_alphabet").prop("checked",false);
		}
		if(itemPasswdComplexitySpecialchar==1){
			$("input#passwd_complexity_specialchar").prop("checked",true);
		}else{
			$("input#passwd_complexity_specialchar").prop("checked",false);
		}		

		var checkboxVal = $("#passwd_complexity_enable").is(':checked');
		if(checkboxVal == true){
			web_enable_DOM_item("#passwd_complexity_digit",true);
			web_enable_DOM_item("#passwd_complexity_alphabet",true);
			web_enable_DOM_item("#passwd_complexity_specialchar",true);
		}else{
			web_enable_DOM_item("#passwd_complexity_digit",false);
			web_enable_DOM_item("#passwd_complexity_alphabet",false);
			web_enable_DOM_item("#passwd_complexity_specialchar",false);
		}	
		
	}	

	function responsePasswdPolicyData(xhr) 
	{
		var response = xhr.responseXML;
		
		$(response).find('PasswdPolicy').each(function() {				
			var itemPasswdMinLength=$(this).find('PasswdMinLength').text();
			var itemPasswdComplexityEnable=$(this).find('PasswdComplexityEnable').text();
			var itemPasswdComplexityDigit=$(this).find('PasswdComplexityDigit').text();
			var itemPasswdComplexityAlphabet=$(this).find('PasswdComplexityAlphabet').text();
			var itemPasswdComplexitySpecialchar=$(this).find('PasswdComplexitySpecialchar').text();
							
			add_new_data(itemPasswdMinLength,itemPasswdComplexityEnable,itemPasswdComplexityDigit
					,itemPasswdComplexityAlphabet,itemPasswdComplexitySpecialchar);				
		});	
			
	}

	function add_new_loginlockout_data(itemLoginLockoutEnable,itemLoginLockoutThreshold,itemLoginLockoutTime){
		if(itemLoginLockoutEnable==1){
			$("input#login_lockout_enable").prop("checked",true);
		}else{
			$("input#login_lockout_enable").prop("checked",false);
		}
		$("input#login_lockout_threshold_tmp").val(itemLoginLockoutThreshold);
		$("input#login_lockout_time_tmp").val(itemLoginLockoutTime);


		
		var checkboxVal = $("#login_lockout_enable").is(':checked');
		if(checkboxVal == true){
			web_enable_DOM_item("#login_lockout_threshold_tmp",true);
			web_enable_DOM_item("#login_lockout_time_tmp",true);
		}else{
			web_enable_DOM_item("#login_lockout_threshold_tmp",false);
			web_enable_DOM_item("#login_lockout_time_tmp",false);
		}
	}

	function responseLoginLockoutData(xhr) 
	{
		var response = xhr.responseXML;
		
		$(response).find('LoginLockout').each(function() {				
			var itemLoginLockoutEnable=$(this).find('LoginLockoutEnable').text();
			var itemLoginLockoutThreshold=$(this).find('LoginLockoutThreshold').text();
			var itemLoginLockoutTime=$(this).find('LoginLockoutTime').text();
							
			add_new_loginlockout_data(itemLoginLockoutEnable,itemLoginLockoutThreshold,itemLoginLockoutTime);				
		});	
			
	}

	function translate_checked(obj)
	{
		if(obj.checked)
        	return 1;
		else
			return 0;
	}

	function is_data_ok()
	{	
		var maxlenth = document.getElementById("passwd_min_length").value;
		if((maxlenth<4) || (maxlenth>16) || isNaN(maxlenth) ){
			alert("Minimum Length (4~16)");
			document.getElementById("passwd_min_length").value = 4;
			return 0;
		}

		if(document.getElementById("login_lockout_enable").checked == true){
			var threshold = document.getElementById("login_lockout_threshold_tmp").value;

			if((threshold<1) || (threshold>10) || isNaN(threshold) ){
				alert("Retry Failure Threshold (1~10)");
				document.getElementById("login_lockout_threshold_tmp").value = 5;
				return 0;
			}
				
			var lockout_time = document.getElementById("login_lockout_time_tmp").value;

			if((lockout_time<1) || (lockout_time>60) || isNaN(lockout_time) ){
				alert("Lockout Time (min) (1~60)");
				document.getElementById("login_lockout_time_tmp").value = 5;
				return 0;
			}
		}

		return 1;
	}
	
	function senddata(){
		if(is_data_ok()){
			var i;

			for(i in pw_complexity_type){
				document.getElementById("pw_complexity_tmp").value = document.getElementById("pw_complexity_tmp").value + translate_checked(document.getElementById(i)) + "+";
			}

			document.getElementById("login_lockout_threshold").value = document.getElementById("login_lockout_threshold_tmp").value;
			document.getElementById("login_lockout_time").value = document.getElementById("login_lockout_time_tmp").value;
			
			document.getElementById("password_login_policy_form").submit();	
		}	
	}
//-->
</script>
</head>
<body>
<form name="password_login_policy_form" id="password_login_policy_form" method="post" action="/goform/net_Web_get_value?SRV=SRV_PW_POLICY&SRV0=SRV_LOGIN_LOCKOUT" target="mid" >
<input type="hidden" name="pw_complexity_tmp" id="pw_complexity_tmp" value="" >
<input type="hidden" name="login_lockout_threshold" id="login_lockout_threshold" value="" >
<input type="hidden" name="login_lockout_time" id="login_lockout_time" value="" >
{{ net_Web_csrf_Token() | safe }}
<h1>Account Password and Login Management</h1>
<fieldset>
	<div style='width:100%;'>
	<table style='width:100%;'>
		<tr>
			<td style='width:25%;'></td>
			<td style='width:25%;'></td>
			<td style='width:30%;'></td>
			<td></td>
		</tr>
		<tr class="pwd_policy"><td colspan="3"><h2>Account Password Policy</h2></td></tr>        
        <tr class="pwd_policy"><td colspan="2">Minimum Length</td><td><input id="passwd_min_length" name="passwd_min_length" type="text" maxlength="2">(4~16)</td></tr>

        <tr class="pwd_policy"><td colspan="3"><input id="passwd_complexity_enable" name="passwd_complexity_enable" type="checkbox">&nbsp;Enable password complexity strength check</td></tr>			
		<tr class="pwd_policy"><td colspan="2" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input id="passwd_complexity_digit" name="passwd_complexity_digit"  type="checkbox"> At least one digit (0~9)</td><td></td></tr>
		<tr class="pwd_policy"><td colspan="2" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input id="passwd_complexity_alphabet" name="passwd_complexity_alphabet"  type="checkbox"> Mixed upper and lower case letters (A~Z, a~z)</td><td></td></tr>
        <tr class="pwd_policy"><td colspan="3" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input id="passwd_complexity_specialchar" name="passwd_complexity_specialchar" type="checkbox"> At least one special character (~!@#$%^&*-_|;:,.<>[]{}())</td></tr>

		<tr class="login_lockout"><td colspan="3"><h2>Account Login Failure Lockout</h2></td></tr>
		<tr class="login_lockout"><td colspan="2"><input id="login_lockout_enable" name="login_lockout_enable" type="checkbox"> Enable</td><td></td></tr>
        <tr class="login_lockout"><td colspan="2">Retry Failure Threshold</td><td><input id="login_lockout_threshold_tmp" name="login_lockout_threshold_tmp">(1~10)</td></tr>
        <tr class="login_lockout"><td colspan="2">Lockout Time (min)</td><td><input id="login_lockout_time_tmp" name="login_lockout_time_tmp">(1~60)</td></tr>       
	</table>
	</div>
	<div style="width:100%; text-align:right; margin-top:25px;" >
		<script language="JavaScript">fnbnB(Submit_, 'onClick=senddata()')</script>
	</div>
</fieldset>
	
</form>
</body>
</html>

