<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(PW)</script></title>


<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript" src="md5.js"></script>
<script language="Javascript" src="net_web.js"></script>

<script language="JavaScript">
checkCookie();

// net_Web_PW_WriteValue(); 
// net_Web_User_PW_WriteValue(); 

var updb = 'Activate';


var user = [
{ value:'admin',text:'Admin' },
{ value:'user',text:'User' }
];

var entryNUM=0;
{% include "emalert_data" ignore missing %}

 
var myForm;
function fnInit(row) {
	myForm = document.getElementById('myForm');
}

function SetCookie(myform)
{						
	
	var theName = myform.user.value + ":" + "EDR=";		

	// get chall by sychronize javascript request
	var http_req = net_inithttpreq();
	http_req.open( "GET", "/webNonce", false );
	http_req.send( null );
	var chall = http_req.responseText;

	var op1 = myform.old_pw.value;
	if (op1=="")
		op1="NULL";
	var theValue1 = MD5( op1 );

	var op2 = myform.new_pw.value;
	if(op2=="")
		op2="NULL";
	var theValue2 = op2;
	
	var expires = null;
	
	document.cookie1 = theName + escape(theValue1);
	document.cookie2 = theName + escape(theValue2); 

	document.qwe.new_pw.value="";
	document.qwe.check_pw.value="";

	myform.pwTemp.value = myform.pwTemp.value + document.cookie1 + "+";	
	myform.pwTemp.value = myform.pwTemp.value + document.cookie2 + "+";	

	myform.submit();
}

function Activate(form)
{
	if(PasswordLikeCheckFormat(form)==1)
		return;
	
	var op = form.old_pw.value;
	var opw;
/*
	if(document.getElementById("user").selectedIndex==0)
		opw=admin_old;
	else
		opw=user_old;
*/	
	if (op=="")
		op="NULL";		

//	if(MD5(op)==opw){
		var check=confirm("Sure to change the password ?");
		if(check==true){
			if(form.new_pw.value != form.check_pw.value){
				alert("check password again !");
			}
			else{
				alert("check password ok !");
				SetCookie(form)
			}
		}
//	}
//	else
//		alert("error old password !");
	
}


</script>
</head>
<body class=main onLoad=fnInit(0)>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[2].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[2])</script>
<script language="JavaScript">mainh()</script>	

<form name="qwe" id="myForm" method="POST" action="/goform/net_WebNewPWGetValue">
	{{ net_Web_csrf_Token() | safe }}
	<input type="hidden" name="pwTemp" id="pwTemp" value="" />
	
	<DIV style="height:100px;">
		<table cellpadding="1" cellspacing="3" style="width:700px;">

			<tr class="r2">
				<td style="width:100px;">
					
				</td>
				<td style="width:600x;" align="left" valign="center">
					<script language="JavaScript">iGenSel2('user', 'user', user)</script>
				</td>
			</tr>
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Old_PW)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="password" id=old_pw name="old_pw" size=16 maxlength=16 autocomplete="off">
		        </td>
			</tr>
			
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(New_PW)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="password" id=new_pw name="new_pw" size=16 maxlength=16 autocomplete="off">
		        </td>
			</tr>
			<tr class="r2">
				<td style="width:100px;">
					<script language="JavaScript">doc(Check_PW)</script>
				</td>
				<td style="width:600px;" align="left" valign="center">  
		            <input type="password" id=check_pw name="check_pw" size=16 maxlength=16 autocomplete="off">
		        </td>
			</tr>
		</table>
	</DIV>  
</form>

<DIV style="height:30px">
	<table class="tf" align="left" valign="up">
    	<tr>
          	<td><script language="JavaScript">fnbnB(updb, 'onClick=Activate(myForm)')</script></td>
		</tr>
	</table>
</DIV>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>


