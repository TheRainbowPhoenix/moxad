<html>
<head>
{{ net_Web_file_include() | safe }}
<!--<title><script language="JavaScript">doc(Email_Setup_)</script></title>-->

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (debug) {
	{{ net_Web_show_value('SRV_SSMTP') | safe }}		
}
{% include "emalert_data" ignore missing %}


var myForm, td01;
function fnInit() {
	with (document) {
		myForm = getElementById('myForm');
		td01 = getElementById('td01');
	}
	//fnLoadForm(myForm, gdata, gtype);
	fnLoadForm(myForm, SRV_SSMTP, SRV_SSMTP_type);
}


/*function EditRow(row) {
	fnLoadForm(myForm, SRV_SSMTP[row], SRV_SSMTP_type);
}*/

function Activate(form)
{
	var error_return_t = 0;
	if(!isNull(myForm.emsvr.value))
		if(isSymbol(myForm.emsvr, Email_SMTP_Server_Address))
			error_return_t = 1;
	if(!isNull(myForm.smport.value))
		if(!isPort(myForm.smport, Smtp_Port))
			error_return_t = 1;
	if(!isNull(myForm.user.value))
		if(isSymbol(myForm.user, User_Name))
			error_return_t = 1;
	if(!isNull(myForm.sender.value))
		if(isSymbol(myForm.sender, Sender_Address))
			error_return_t = 1;	
	if(!isNull(myForm.recpnt1.value))
		if(isMailAddress(myForm.recpnt1, Recipient_Address1))
			error_return_t = 1;
	if(!isNull(myForm.recpnt2.value))
		if(isMailAddress(myForm.recpnt2, Recipient_Address2))
			error_return_t = 1;
	if(!isNull(myForm.recpnt3.value))
		if(isMailAddress(myForm.recpnt3, Recipient_Address3))
			error_return_t = 1;
	if(!isNull(myForm.recpnt4.value))
		if(isMailAddress(myForm.recpnt4, Recipient_Address4))
			error_return_t = 1;

	if (error_return_t)
		return;

	form.submit();
}

function SendTestMail(form){
	var error_return_t = 0;
	if(!isNull(myForm.emsvr.value))
		if(isSymbol(myForm.emsvr, Email_SMTP_Server_Address))
			error_return_t = 1;
	if(!isPort(myForm.smport, Smtp_Port))
		error_return_t = 1;
	if(!isNull(myForm.user.value))
		if(isSymbol(myForm.user, User_Name))
			error_return_t = 1;
	if(!isNull(myForm.sender.value))
		if(isSymbol(myForm.sender, Sender_Address))
			error_return_t = 1;
	if(!isNull(myForm.recpnt1.value))
		if(isSymbol(myForm.recpnt1, Recipient_Address1))
			error_return_t = 1;
	if(!isNull(myForm.recpnt2.value))
		if(isSymbol(myForm.recpnt2, Recipient_Address2))
			error_return_t = 1;
	if(!isNull(myForm.recpnt3.value))
		if(isSymbol(myForm.recpnt3, Recipient_Address3))
			error_return_t = 1;
	if(!isNull(myForm.recpnt4.value))
		if(isSymbol(myForm.recpnt4, Recipient_Address4))
			error_return_t = 1;

	if (error_return_t)
		return;
	form.action="/goform/net_WebSsmtpSendTestMail";
	form.submit();
}
</script>
</head>
<body  onload=fnInit()>
<h1><script language="JavaScript">doc(Email_Setup_)</script></h1>

<form  id="myForm" method="POST" action="/goform/net_Web_get_value?SRV=SRV_SSMTP">
{{ net_Web_csrf_Token() | safe }}
<fieldset>
<table cellpadding=1 cellspacing=2>
 <tr class=r0>
  <td><script language="JavaScript">doc(Email_Alert_Configuration)</script></td>
  <td id=td01></td></tr>
 <tr>
  <td nowarp><script language="JavaScript">doc(Email_SMTP_Server_Address)</script></td>
  <td><input id=emsvr name="mailhub" size=50 maxlength=50></td></tr>
 <tr>
  <td width=30%><script language="JavaScript">doc(Smtp_Port)</script></td>
  <td><input id=smport name="port" size=5 maxlength=5></td></tr>
 <tr>
  <td width=30%><script language="JavaScript">doc(Account_Name)</script></td>
  <td><input id=user name="AuthUser" size=30 maxlength=30></td></tr>
 <tr>
  <td><script language="JavaScript">doc(Password_)</script></td>
  <td><input type=password id=pass name="AuthPass" size=30 maxlength=30></td></tr> 
 <tr>
  <td><script language="JavaScript">doc(Sender_Address)</script></td>
  <td><input id=sender name="SenderAddr" size=50 maxlength=50></td></tr>
 <tr>
  <td width="200px"><script language="JavaScript">doc(Recipient_Address1)</script></td>
  <td><input id=recpnt1 name="DstAddr0" size=50 maxlength=50></td></tr>
 <tr>
  <td><script language="JavaScript">doc(Recipient_Address2)</script></td>
  <td><input id=recpnt2 name="DstAddr1" size=50 maxlength=50></td></tr>
 <tr>
  <td><script language="JavaScript">doc(Recipient_Address3)</script></td>
  <td><input id=recpnt3 name="DstAddr2" size=50 maxlength=50></td></tr>
 <tr>
  <td><script language="JavaScript">doc(Recipient_Address4)</script></td>
  <td><input id=recpnt4 name="DstAddr3" size=50 maxlength=50></td></tr>
 <tr>
  <script language="JavaScript">hr(2)</script></tr>
</table>
<p><table align=left>
 <tr>
  <td><script language="JavaScript">fnbnB(Submit_, 'onClick=Activate(this.form)')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnB2(Send_Test ,'onClick=SendTestMail(this.form)')</script></td>  
  <td width=150></td></tr>
</table></p>
</fieldset>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>