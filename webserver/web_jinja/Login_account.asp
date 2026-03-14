<HTML>
<HEAD>
<TITLE>Moxa EDR</TITLE>
<meta http-equiv='Set-Cookie' content='sysnotify_support=yes;path=/;'><meta http-equiv='Set-Cookie' content='sysnotify_loginStatus=initial;path=/;'>
<link rel="shortcut icon" href="image/favicon.ico" />
<script language="JavaScript" src="sha256.js"></script>
<script language="Javascript" src="net_web.js"></script>
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
{{ net_Web_file_include() | safe }}
<script type="text/javascript">
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
var ModelNmae = {{ net_Web_GetModelName_WriteValue() | safe }};
{{ net_Web_show_value('SRV_SYSINFO') | safe }};

	if(window != top)
		top.location.href = window.location.href;

	
	NumArray = new Array();
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

	function SetCookie(){	

		var radius_enable = {{ net_Web_Get_Radius_Enable() | safe }};	// radius is not enabled
		
		//document.getElementById("InputPassword").action="/loginHistory.asp"
		document.getElementById("InputPassword").action="/init.asp"
		document.cookie = "";
               
		theName = "NAME";	
		if(document.getElementById("Username").value == ""){
		  theValue = "unknown";
		}else{
		  theValue = document.getElementById("Username").value;
		 }

		expires = null;
		document.cookie = theName + "=" + escape(theValue) + "; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());     

		theName = "PASSWORD";
		expires = null;
		var op = document.InputPassword.Password.value;
		
		if(radius_enable != 1){
			if(op=="")
				op="NULL";
			theValue = sha256( op );
		}
		else{
			if(op=="")
				op="NULL";
			theValue = op;
		}
		document.cookie = theName + "=" + theValue + "; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());        
	}
	function SetModelName()
	{
		document.write(ModelNmae);
	}

	function ClearCookie()
	{					
		theCookieName = "NAME=";
		document.cookie = theCookieName;
		theCookieName = "PASSWORD=";
		document.cookie = theCookieName;
		theCookieName = "AUTHORITY=";
		document.cookie = theCookieName;
	}	

	function showmsg()
	{
		var url=window.location.toString(); 
		var str_value="";
		if(url.indexOf("?")!=-1){
	 	   var ary=url.split("?")[1].split("&");
		    for(var i in ary){
		        str=ary[i].split("=")[0];
		        if (str == "fail") {
		            str_value = decodeURI(ary[i].split("=")[1]);
		        }
		    }
		}
		if(str_value == 1){
			str_value = SRV_SYSINFO.loginfailmsg;
		}else{
			str_value = SRV_SYSINFO.loginmsg;
		}
		str_value = str_value.replace(/\n/g, "<br>")
		document.getElementById("showmsg").innerHTML = str_value;
	}

	function SetDisplayMSG(){
		var theData;
		var DisplayMSG="";

		
		theData = web_cookie_read("sysnotify_support");

		if((theData != null) && (theData == "yes")){
			//document.account_password_form.action="/loginHistory.asp";

			theData = web_cookie_read("sysnotify_loginStatus");

			if( theData == "fail"){
				DisplayMSG="loginFailMSG";
			}else{
				DisplayMSG="loginMSG";
			}

		if(DisplayMSG=="loginMSG"){
				$("#LoginMSG_display_panel").show();
				$("#LoginFailMSG_display_panel").hide();
		}else if(DisplayMSG=="loginFailMSG"){
				
				$("#LoginMSG_display_panel").hide();
				$("#LoginFailMSG_display_panel").show();
		}        
		}
	}

	var LogincsrfTokenValue

	function SetSessionID(){
		var d = new Date();		
		var randN = Math.floor(Math.random() * (0xFFFFF665 - 1)) + 1;

		randN += d.getMilliseconds();

		web_cookie_erase("sessionID");
		web_cookie_create("sessionID",randN);

		LogincsrfTokenValue = randN + (d.getMilliseconds() * 111 );
	}

	function SetXFrameOptions(){
		web_cookie_create("X-Frame-Options","SAMEORIGIN");
	}

	function SetLogincsrfToken(){
		//set login csrf token in login form
		document.InputPassword.LogincsrfToken.value = LogincsrfTokenValue;
		//set login csrf token in cookie
		web_cookie_create("LogincsrfToken",LogincsrfTokenValue);
	}

	$(document).ready(function(){	
        SetDisplayMSG();
        SetSessionID();
				SetXFrameOptions();
				SetLogincsrfToken();
	});

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
	</STYLE>
</HEAD>

<BODY style="margin:0px" onLoad="document.InputPassword.Username.focus();ClearCookie();showmsg();">
	<TABLE border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
		<TR height="105">
			<TD>
				<TABLE border=0 cellpadding=0 cellspacing=0 width="100%">
					<TD width="325"><IMG src="images/lup_logo1.gif" border=0></TD>
					<TD width="*" background="images/lup_logo2.gif" border=0>&nbsp;</TD>
				</TABLE>
			</TD>
		</TR>		
		<TR height="*">
			<TD>
				<TABLE border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
					<TD width="105" background="images/lleft_logo.gif" border=0>&nbsp;</TD>
					<TD width="*">
						<TABLE border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
							<TR height="33%"><TD width="100%">&nbsp;</TD></TR>
							<TR height="30%">
								<TD width="*">
								<TABLE border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
									<TD width="*">&nbsp;</TD>									
									<TD width="350">
										<FORM name="InputPassword" id="InputPassword" method="POST" onSubmit="return SetCookie();">
											<input type="hidden" name="LogincsrfToken" value=""/>
											<TABLE border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
												<TR>
													<TD colspan="2"><H2>Moxa Industrial Secure Router</H2></TD>
												</TR>
												<TR>
													<TD colspan="2"><H2><script language="JavaScript">SetModelName()</script></H2></TD>
												</TR>
												<TR><TD>&nbsp;</TD></TR>
												<TR>
													<TD>Username : </TD>
													<TD><INPUT type="text" name="Username" id="Username" maxlength="16" size="22"/></TD>
												</TR>
												<TR><TD>&nbsp;</TD></TR>												
												<TR>
													<TD>Password : </TD>
													<TD><INPUT type="password" name="Password" id="Password" maxlength="16" size="22" autocomplete="off"/></TD>
												</TR>
												<TR><TD>&nbsp;</TD></TR>											
												<TR>
													<TD>&nbsp;</TD>
													<TD align=right><INPUT type="Image" value="Login" name="Submit" src="images/llogin.gif"></TD>
												</TR>
												<TR><TD>&nbsp;</TD></TR>
												<TR><TD>&nbsp;</TD></TR>												
											</TABLE>
										</FORM>
									</TD>
									<TD width="*">&nbsp;</TD>
								</TABLE>	
								</TD>
							</TR>
							<TR>
								<TD width="*">
									<TABLE border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">								
										<TD width="*">&nbsp;</TD>		
										<TD width="700" style="word-break:break-all" id=showmsg></script></TD>
										<TD width="*">&nbsp;</TD>				
									</TABLE>
								</TD>
							</TR>
							<TR height="37%"><TD width="100%">
								<img border="0" src="images/goahead.gif" width="155" height="31"></TD></TR>
						</TABLE>
					</TD>
				</TABLE>
			</TD>
		</TR>
		<TR height="50">
			<TD>
				<TABLE border=0 cellpadding=0 cellspacing=0 width="100%">
					<TD width="105"><IMG src="images/ldown_logo1.gif" border=0></TD>
					<TD width="*" background="images/ldown_logo2.gif" border=0>&nbsp;</TD>
				</TABLE>
			</TD>
		</TR>
	</TABLE>		
</BODY>
</HTML>
