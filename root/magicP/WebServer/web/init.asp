<html>
<head>
	<title></title>
<script language="JavaScript" src="md5.js"></script>
<script language="JavaScript" src="sha256.js"></script>
<% net_Web_file_include(); %>
<script type="text/javascript">
	var authority="<% net_Web_login_init_info(); %>";	
	function getCookie(name) {
 		var temp_name = name + "=";
 		var ca = document.cookie.split(';');
 		for (var i = 0; i < ca.length; i++) {
 			var c = ca[i];
 			while (c.charAt(0) == ' ') c = c.substring(1, c.length);
			if (c.indexOf(temp_name) == 0) return c.substring(temp_name.length, c.length);
 		}
 		return null;
	}

	function SetAuthorityCookie(){
		var password=0;
		var radius_enable = <% net_Web_Get_Radius_Enable(); %>;
		
		//alert(authority);
		if(authority == ""){
			return false;
		}
		theName = "AUTHORITY";			
		theValue = authority;
		expires = null;
		document.cookie = theName + "=" + escape(theValue) + "; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());

		
		if(radius_enable){
			password=getCookie("PASSWORD");
			theName = "PASSWORD";
			expires = null;
			theValue=sha256( password );
			document.cookie = theName + "=" + escape(theValue) + "; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());
		}
		
		location.replace=location.replace("loginHistory.asp");
	}

</script>
</head>
<BODY onLoad="SetAuthorityCookie();">
</BODY>
</html>
