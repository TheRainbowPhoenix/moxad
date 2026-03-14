<html> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta http-equiv="Cache-Control" content="no-cache">
<style type="text/css">
body {
	font-family: Arial, Helvetica, sans-serif, Marlett;
	font-size: 0.8em;
	background-color: #CCE6E6; /* Light-blue background */
	color: #000000; /* Black word */
	margin-top: 10;
	margin-left: 12;
}

h1 {
	font-size: 1.5em;
	color: #007C60; /* Green title */
	font-style: bold;
	text-align: left;
}

fieldset {
	position: relative;
	top: 10%;
	left: 10%;
	border-style: none; /* Not show border */
}

label {
	float: left;
	clear: left;
	width: 15em;
}

div.pb {
	padding-bottom: 0.5em;
}

.submit input {
	position: relative;
	left: 15%;
}
.style1 {
	color: #000099;
	font-weight: bold;
}
</style>
<meta http-equiv="Content-Script-Type" content="text/javascript">
</head>

<body >
<form name="ssmtp" method="post"  action="/goform/net_WebSSMTPGetValue" target="mid" >
<h1>SSMTP Identification</h1>
<fieldset>
<% net_Web_csrf_Token(); %>
<table width="410" border="1">
  <tr>
    <td width="140"><div align="center" class="style1">root</div></td>
    <td width="254"><input type="text" name="root" size="30" maxlength="30" > 
<script> document.ssmtp.root.value=""; </script>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="center" class="style1">mailhub</div></td>
    <td><input type="text" name="mailhub" size="30" maxlength="30" > 
<script> document.ssmtp.mailhub.value=""; </script>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="center" class="style1">hostname</div></td>
    <td><input type="text" name="hostname" size="30" maxlength="30" > 
<script> document.ssmtp.hostname.value=""; </script>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="center" class="style1">auth</div></td>
    <td><input type="text" name="auth" size="30" maxlength="30" > 
<script> document.ssmtp.auth.value=""; </script>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="center" class="style1">AuthUser</div></td>
    <td><input type="text" name="authuser" size="30" maxlength="30" > 
<script> document.ssmtp.authuser.value=""; </script>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="center" class="style1">AuthPass</div></td>
    <td><input type="text" name="authpass" size="30" maxlength="30" > 
<script> document.ssmtp.authpass.value=""; </script>&nbsp;</td>
  </tr>
  <tr>
    <td><div align="center" class="style1">DstAddr</div></td>
    <td><input type="text" name="dstaddr" size="30" maxlength="30" > 
<script> document.ssmtp.dstaddr.value=""; </script>&nbsp;</td>
  </tr>
</table>
<div>
	<label></label>
	<input type="image" name="SystemSubmit" src="images/active.gif">
</div>
</fieldset>
</form>
</body>
</html>
