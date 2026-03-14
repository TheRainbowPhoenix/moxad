<html>
<head>
<title></title>
<link rel="shortcut icon" href="image/favicon.ico" />
<script language="JavaScript" src="md5.js"></script>
<script language="Javascript" src="net_web.js"></script>
<script language="Javascript" src="moxa_common.js"></script>
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
<script language="JavaScript" src="md5.js"></script>
{{ net_Web_file_include() | safe }}
<script type="text/javascript">

<!--
	NumArray1 = new Array();
	NumArray2 = new Array();
	NumArray3 = new Array();

	$(document).ready(function(){		
		getPasswdPolicyData();
		authCheck();
		
		$("body").click(function(){			
			web_cookie_update_touchLasttime();
		});

		$("body").keypress(function(){			
			web_cookie_update_touchLasttime();
		});

		$("#id_inputNewPasswd").keyup(function(){			
			passwdHint();
		});

		web_account_diff();
	});
	function authCheck(){
		var theData = web_cookie_read("NAME");
		if(theData=="admin"){
			auth_warning.style.display = "none";
		}
		else{
			show_apply.style.display = "none";
		}
	}
	function StrToHex(str)
	{
		var i = 0;
		var ret = 0;
		table = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f");
		for (i = 0; i < 16; ++i) {
			if (str.charAt(0) == table[i])
				ret = i*16;
		}
		for (i = 0; i < 16; ++i) {
			if (str.charAt(1) == table[i])
				ret += i;
		}
		return ret;
	}

	function DecToHexStr(d)
	{
		table = new Array("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f");
		var ret = "";
		var i = d/16;
		for (var j = 0; j <= i; ++j)
			var c = table[j];
		ret += c;

		i = d%16;
		for (var j = 0; j < 16; ++j) {
			if (j == i) {
				var c = table[j];
				break;
			}
		}
		ret += c;
		return ret;
	}
	function sendCalsOperation()
	{
	
		var ascii="01234567890123456789012345678901" +
		          " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ"+
				  "[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~";

		var pw_tbl1 = new Array();
		var pw_tbl2 = new Array();
		var pw_tbl3 = new Array();
		var authority;
		//authority = "admin";
		authority = 0;
		var chall = Math.round(Math.random()*10000);
		document.account_password_modified_form.chall.value = chall;

		var op = document.getElementById("id_inputOldPasswd").value;
		// old_length
		document.account_password_modified_form.old_length.value = op.length;
		var tmp1 = MD5(op + authority + chall);

		for (var i = 0; i < 16; ++i) {
			var OneByte1 = tmp1.charAt(i*2) + tmp1.charAt(i*2+1);
			NumArray1[i] = StrToHex(OneByte1);
		}

		for (var i = 1; i <= 3; ++i) {
			if (op.length <= i*16)
				break;
		}

		NumArray1.length = i*16;

		for (var j = 1; j < i; ++j) {
			for (var k = 0; k < 16; ++k)
				NumArray1[k+j*16] = NumArray1[k];
		}

		for(var i=0; i< NumArray1.length; i++)
			pw_tbl1[i] = ascii.lastIndexOf( op.charAt(i));
		pw_tbl1.length = i;
		var uv1 = "";
		for (var i = 0; i < NumArray1.length; ++i) {
		 	var ch1 = NumArray1[i] ^ pw_tbl1[i];
		 	var chh1 = DecToHexStr(ch1);
			uv1 += chh1;
		}
		// old_passwd
		document.account_password_modified_form.old_passwd.value = uv1;


		for (i = 0; i < 16; ++i) {
			var OneByte2 = tmp1.charAt(i*2) + tmp1.charAt(i*2+1);
			NumArray2[i] = StrToHex(OneByte2);
		}
		var np = document.getElementById("id_inputNewPasswd").value;
		var tmp2 = MD5(np + authority + chall);
		// new_length
		document.account_password_modified_form.new_length.value = np.length;

		for (i = 1; i <= 3; ++i) {
			if (np.length <= i*16)
				break;
		}
		NumArray2.length = i*16;

		for (j = 1; j < i; ++j) {
			for (k = 0; k < 16; ++k)
				NumArray2[k+j*16] = NumArray2[k];
		}
		for(i=0; i< NumArray2.length; i++)
			pw_tbl2[i] = ascii.lastIndexOf( np.charAt(i));
		pw_tbl2.length = i;
		var uv2 = "";
		for (i = 0; i < NumArray2.length; ++i) {
		 	var ch2 = NumArray2[i] ^ pw_tbl2[i];
		 	var chh2 = DecToHexStr(ch2);
			uv2 += chh2;
		}
		// new_passwd
		document.account_password_modified_form.new_passwd.value = uv2;


		for (i = 0; i < 16; ++i) {
			var OneByte3 = tmp1.charAt(i*2) + tmp1.charAt(i*2+1);
			NumArray3[i] = StrToHex(OneByte3);
		}
		var rp = document.getElementById("id_inputConfirmPasswd").value;
		var tmp3 = MD5(rp + authority + chall);
		// re_length
		document.account_password_modified_form.re_length.value = rp.length;

		for (i = 1; i <= 3; ++i) {
			if (rp.length <= i*16)
				break;
		}
		NumArray3.length = i*16;

		for (j = 1; j < i; ++j) {
			for (k = 0; k < 16; ++k)
				NumArray3[k+j*16] = NumArray3[k];
		}
		for(i=0; i< NumArray3.length; i++)
			pw_tbl3[i] = ascii.lastIndexOf( rp.charAt(i));
		pw_tbl3.length = i;
		var uv3 = "";
		for (i = 0; i < NumArray3.length; ++i) {
		 	var ch3 = NumArray3[i] ^ pw_tbl3[i];
		 	var chh3 = DecToHexStr(ch3);
			uv3 += chh3;
		}
		// re_passwd
		document.account_password_modified_form.re_passwd.value = uv3;

		document.account_password_modified_form.action="/goform/AccountPasswdUpdate";
		document.account_password_modified_form.submit();
			
	}

	function getPasswdPolicyData() 
	{	
		$.ajax({
			url:'./xml/passwdPolicy.xml',
			dataType:'xml',
			cache:false,
			complete: function (xhr,status){
				if(status=="success"){
					responsePasswdPolicyData(xhr);
				}
			}			
		});
	}

	var itemPasswdMinLength;
	var itemPasswdComplexityEnable;
	var itemPasswdComplexityDigit;
	var itemPasswdComplexityAlphabet;
	var itemPasswdComplexitySpecialchar;
	
	function responsePasswdPolicyData(xhr) 
	{
		var response = xhr.responseXML;
		
		$(response).find('PasswdPolicy').each(function() {				
			itemPasswdMinLength=$(this).find('PasswdMinLength').text();
			itemPasswdComplexityEnable=$(this).find('PasswdComplexityEnable').text();
			itemPasswdComplexityDigit=$(this).find('PasswdComplexityDigit').text();
			itemPasswdComplexityAlphabet=$(this).find('PasswdComplexityAlphabet').text();
			itemPasswdComplexitySpecialchar=$(this).find('PasswdComplexitySpecialchar').text();					
		});			
	}
	
	function passwdHint()
	{
		var new_passwd = document.getElementById("id_inputNewPasswd");
		var passwd_hint = document.getElementById("id_td_password_hint");
		var checkNumber = /(?=.*[0-9]).{1,}/;
		var checkUpLetter = /(?=.*[A-Z]).{1,}/;
		var checkLoLetter = /(?=.*[a-z]).{1,}/;
		var checkSpecialchar = /(?=.*[\-\+\?\*\$\[\]\^\.\(\)\|`!@#%&_=:;,/~]).{1,}/;
		
		if(new_passwd.value.length < itemPasswdMinLength) {
			passwd_hint.innerHTML = " Minimum length of password is "+itemPasswdMinLength;
		}else if ((itemPasswdComplexityEnable==1) && (itemPasswdComplexityDigit==1) && (!checkNumber.test(new_passwd.value))){
			passwd_hint.innerHTML=" At Least One digit (0~9)";
		}else if ((itemPasswdComplexityEnable==1) && (itemPasswdComplexityAlphabet==1) && ((!checkUpLetter.test(new_passwd.value)) || (!checkLoLetter.test(new_passwd.value)))){
			passwd_hint.innerHTML=" Mixed Upper and lower case letters (A~Z, a~z)";
		}else if((itemPasswdComplexityEnable==1) && (itemPasswdComplexitySpecialchar==1) && (!checkSpecialchar.test(new_passwd.value))){
			passwd_hint.innerHTML=" At Least One Special character (~!@#$%^&*-_|;:,.<>[]{}())";
		}else{
			passwd_hint.innerHTML = "";
		}
	}
		

//-->
</script>
<STYLE>
	input {
		font-family: Verdana;
		font-size: 9pt;
		color: #000000;
	}
	body {
		font-family: Verdana;
		font-size: 10pt;
		background-color: #e5e5e5;
	}
	h2 {
		font-family: Verdana;
		font-size: 12pt;
		color: #0a51a1;
		background-color: #e5e5e5;
	}
	input.button {
	    font-family: "Swiss 721 BT";
	    font-size: 13px;
	    font-weight: bold;
	    color: rgb(255, 255, 255);   
	    background-color: rgb(0, 124, 100);
	    width:79px; 
	    height:25px; 
	    background-image:url("image/bn0.png"); 
	    background-repeat:no-repeat;
	    border-style:none; 
	    cursor:pointer;
	    text-align: center; 
	}
</STYLE>
</head>
<body style="margin:0px" >
<form method="post" name="account_password_modified_form" id="account_password_modified_form" >
{{ net_Web_csrf_Token() | safe }}
<div>
<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
		<tr height="105">
			<td>
				<table border=0 cellpadding=0 cellspacing=0 width="100%">
					<td width="325"><IMG src="images/lup_logo1.gif" border=0></td>
					<td width="*" background="images/lup_logo2.gif" border=0>&nbsp;</td>
				</table>
			</td>
		</tr>		
		<tr height="*">
			<td>
				<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
					<td width="105" background="images/lleft_logo.gif" border=0>&nbsp;</td>
					<td width="*">
						<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
							<tr height="33%"><td width="100%">&nbsp;</td></tr>
							<tr height="30%">
								<td width="*">
								<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
									<tr>
									<td width="*">&nbsp;</td>									
									<td width="600">
											<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
												<tr>
													<td colspan="3"><h2>Moxa Industrial Ethernet Router</h2></td>
												</tr>
												<tr>
													<td colspan="3"><font color="#FF0000">Please modify password to meet the security level.</font></td>
												</tr>
												<tr>
													<td colspan="3" name="auth_warning" id="auth_warning"><font color="#FF0000">Please contact your administrator.</font></td>
												</tr>
												
												<tr><td colspan="3">&nbsp;</td></tr>
												<tr>
													<td width="210">Old Password : </td>
													<td width="150"><input type="password" name="id_inputOldPasswd" id="id_inputOldPasswd"  maxlength="16" autocomplete="off"></td>
													<td width="240" ></td>													
												</tr>
												<tr><td>&nbsp;</td></tr>
												<tr>
													<td width="210">New Password : </td>
													<td width="150"><input type="password" name="id_inputNewPasswd" id="id_inputNewPasswd"  maxlength="16" autocomplete="off"></td>
													<td width="240" style="font-size:0.8em;" id="id_td_password_hint"></td>													
												</tr>
												<tr><td>&nbsp;</td></tr>												
												<tr>
													<td width="210">Confirm New Password : </td>
													<td width="150"><input type="password" name="id_inputConfirmPasswd" id="id_inputConfirmPasswd"  maxlength="16" autocomplete="off"></td>
													<td width="240"></td>
												</tr>
												<tr><td colspan="3">&nbsp;</td></tr>											
												<tr>
													<td width="100">&nbsp;</td>
													<td colspan="3" name="show_apply" id="show_apply"><input type="button" class="button" id="id_applyAccountChange" value="Apply" onClick="sendCalsOperation();" ></td>
													<td width="240"></td>
												</tr>
												<tr><td colspan="3">&nbsp;</td></tr>
												<tr><td colspan="3">&nbsp;</td></tr>												
											</table>
									</td>
									<td width="*">&nbsp;</td>
									</tr>
								</table>	
								</td>
							</tr>
							<tr height="37%"><td width="100%">
								<img border="0" src="images/goahead.gif" width="155" height="31"></td></tr>
						</table>
					</td>
				</table>
			</td>
		</tr>
		<tr height="50">
			<td>
				<table border=0 cellpadding=0 cellspacing=0 width="100%">
					<td width="105"><IMG src="images/ldown_logo1.gif" border=0></td>
					<td width="*" background="images/ldown_logo2.gif" border=0>&nbsp;</td>
				</table>
			</td>
		</tr>
	</table>
	</div>
	<div  style="display:none;">
		<input name="old_passwd" value="">
		<input name="new_passwd" value="">
		<input name="re_passwd" value="">
		<input name="old_length" value="">
		<input name="new_length" value="">
		<input name="re_length" value="">
		<input name="chall" value="0">
	</div>
</form>
</body>
</html>

