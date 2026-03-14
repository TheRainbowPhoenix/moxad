<html>
<head>

<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src="doc.js"></script>
<script language="JavaScript" src="common.js"></script>
<script>
checkCookie();
debug = 0;
var file_name;

 
function GetClientConfig(){
	file_name = '/ovpnclient.ovpn';
	//check_file_stat(file_name);
	//alert(filestate);
	location=file_name;
}	
    	

function fnInit() 
{	
		
	return;
}

    
</script>
</head>
    
<body onLoad=fnInit()>
<h1>OpenVPN Server to User Configuration</h1>
<fieldset style=width:"700px">

<form id=myForm1 name=myForm1 method="POST" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>
<p>
<table border=0 width=700px>
  <tr>
    <td width=100px><script language="JavaScript">fnbnBID2("User Config File Export", 'onClick=GetClientConfig()', 'btnC')</script></td>
    <td></td>
  </tr>
</table></p>    

<table border=0>
<tr style="height:50px"></tr>
</table>    
    

</form>
</fieldset>
</body>
</html>
