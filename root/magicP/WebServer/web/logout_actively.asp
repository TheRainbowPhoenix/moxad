<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<meta http-equiv="Content-Style-Type" content="text/css">
<link rel="stylesheet" href="main_style.css">
<script type="text/javascript">
	function BackMainPage(){
		window.top.location.href="/";
	}
	
	function CheckCookie(){
		theName = "lasttime";
		expires = null;
		now=new Date( );
		document.cookie =theName + "=0; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());
		setTimeout("BackMainPage()", 0);
	}

	function LogoutAction(){
		CheckCookie();
		document.getElementById("logout").submit();
	}
</script>
</head>

<body onLoad="LogoutAction()">
<form name="logout" id="logout" method="post" action="/goform/logout">
	<input type = "hidden" name = "logout_action_value" value = "1"></input>
</form>
</body>
</html>
