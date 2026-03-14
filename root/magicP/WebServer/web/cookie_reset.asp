<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<script type="text/javascript">

function GetCookie(name) 
{
	var arr = document.cookie.match(new RegExp("(^| )"+name+"=([^;]*)(;|$)"));
	if(arr != null) { 
		return unescape(arr[2]); 
	}
	else {
		return null;
	}
} 

function DelCookie()
{
	var exp = new Date();
	
	exp.setTime(exp.getTime() - 1);
	var cval=GetCookie('NAME');
	
	if(cval!=null) {
		document.cookie = "NAME=' ';";
		document.cookie = "PASSWORD=' ';";
		document.cookie = "AUTHORITY=' ';";	
	}
	
	return;
} 

</script>
</head>
<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="DelCookie(); ">
<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
<p>All new settings are now active !!!</p>
</font></body>
</html>
