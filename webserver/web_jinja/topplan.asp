<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Cache-Control" content="no-cache">
</head>

<body bgcolor="#FF9900">
<form method="post" name="UpFirmwareFile_form" target="mid" action="htmldemo/goform/LocalFirmwareOpenFunction" enctype="multipart/form-data">
{{ net_Web_csrf_Token() | safe }}
<table>
<tr>
	<td width="100%">
	<br><br><br><br><br><br><br><br><br><br><br><br>
	</td>
	<td width="100%">
<SCRIPT Language="JavaScript">		
		theData = "";
		theName = "AccountName508=";
		theCookie = document.cookie+";";
		start = theCookie.indexOf(theName);
		if(start != -1){
			end=theCookie.indexOf(";",start);
			theData = unescape(theCookie.substring(start+theName.length,end));
		}
		var i;
		if(theData=="admin"){
			document.write("<input type='file' name='binary'>");		
			document.write("</td><td width='100%'>");		
			document.write("<input type='submit' name='UpFirmwareSumbit'>");
		
		}
	


</SCRIPT>
		
	</td>		
</tr>
</table>
</form>
<form method="post" name="UpConfigFile_form" target="mid" action="htmldemo/goform/LocalConfigOpenFunction" enctype="multipart/form-data">
{{ net_Web_csrf_Token() | safe }}
<table>
<tr>
	<td width="100%">
	<br><br><br><br><br><br>
	</td>
	<td width="100%">
		<SCRIPT Language="JavaScript">		
		theData = "";
		theName = "AccountName508=";
		theCookie = document.cookie+";";
		start = theCookie.indexOf(theName);
		if(start != -1){
			end=theCookie.indexOf(";",start);
			theData = unescape(theCookie.substring(start+theName.length,end));
		}
		var i;
		if(theData=="admin"){
			document.write("<input type='file' name='binary'>");		
			document.write("</td><td width='100%'>");		
			document.write("<input type='submit' name='UpConfigSumbit'>");
		
		}
	
		</SCRIPT>>
			
	</td>		
</tr>
</table>
</form>
</body>
</html>
