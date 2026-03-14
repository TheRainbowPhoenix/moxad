<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = {
		RadiusEnable:'0', 
		RadiusServer1:'aaa.bb.cc', 
		RadiusServer2:'abc.def.ghi', 
		RadiusSecret1:'1234', 
		RadiusSecret2:'5678'
	};
}else{
		{{ net_Web_show_value('SRV_RADIUS') | safe }}		
}


var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

var wtyp0__RadiusAuthType = [
	{ value:0, text:'PAP' }, { value:1, text:'CHAP' }
];

//var actb = 'Active';
var myForm;
var selstate = { type:'select', id:'RadiusEnable', name:'RadiusEnable', size:1, option:wtyp0 };
var selstate_RadiusAuthType = { type:'select', id:'RadiusAuthType', name:'RadiusAuthType', size:1, option:wtyp0__RadiusAuthType };
	
function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_RADIUS, SRV_RADIUS_type);	
}

function Activate(form){
	var error_return_t = 0;

	if(form.RadiusServer1.value!="")
		if(!IpAddrIsOK(form.RadiusServer1, RADIUS_SERVER1_))
			error_return_t = 1;
	if(form.RadiusServer2.value!="")
		if(!IpAddrIsOK(form.RadiusServer2, RADIUS_SERVER2_))
			error_return_t = 1;
	if(form.RadiusPort1.value!="")
		if(!isPort(form.RadiusPort1, RADIUS_PORT1_))
			error_return_t = 1;
	if(form.RadiusPort2.value!="")
		if(!isPort(form.RadiusPort2, RADIUS_PORT2_))
			error_return_t = 1;
	
	if (error_return_t)
		return;
	
	form.action="/goform/net_WebRadius_GetValue";
	form.submit();

}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(RADIUS_SETTING_)</script></h1>
<form id=myForm name=form1 method="POST">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2 border=0 height=50px>
 <tr class=r0 >
 </tr>  
 <tr class=r0 align="left">
  <td width=180px><script language="JavaScript">doc(RADIUS_STATE_)</script></td>
  <td width=100px><script language="JavaScript">fnGenSelect(selstate, '')</script></td>
  <td width=50px><script language="JavaScript">doc(Type_)</script></td>
  <td><script language="JavaScript">fnGenSelect(selstate_RadiusAuthType, '')</script></td>
  </tr>     
</table>  

<table cellpadding=1 cellspacing=2 border=0 style="width:850px;">  

  	<tr align="left">
  		<td width=120px align="left">
  			<script language="JavaScript">doc(RADIUS_SERVER1_)</script>
  		</td>
		<td width=15px align="left"> 
			<input type="text" id=RadiusServer1 name="RadiusServer1" size=15 maxlength=32> 
		</td>
		<td width=120px align="left">
  			<script language="JavaScript">doc(RADIUS_PORT1_)</script>
  		</td>
		<td width=10px align="left"> 
			<input type="text" id=RadiusPort1 name="RadiusPort1" size=8 maxlength=8> 
		</td>
		<td width=120px align="left">
  			<script language="JavaScript">doc(RADIUS_SECRET1_)</script>
  		</td>
   		<td width=15px align="left"> 
			<input type="text" id=RadiusSecret1 name="RadiusSecret1" size=15 maxlength=15> 
   		</td> 
	</tr>     
</table>  

<table cellpadding=1 cellspacing=2 border=0 style="width:850px;">  

  	<tr align="left">
  		<td width=120px align="left">
  			<script language="JavaScript">doc(RADIUS_SERVER2_)</script>
  		</td>
		<td width=15px align="left"> 
			<input type="text" id=RadiusServer2 name="RadiusServer2" size=15 maxlength=32> 
		</td> 		
		<td width=120px align="left">
  			<script language="JavaScript">doc(RADIUS_PORT2_)</script>
  		</td>
		<td width=10px align="left"> 
			<input type="text" id=RadiusPort2 name="RadiusPort2" size=8 maxlength=8> 
		</td>
		<td width=120px align="left">
  			<script language="JavaScript">doc(RADIUS_SECRET2_)</script>
  		</td>
   		<td width=15px align="left"> 
			<input type="text" id=RadiusSecret2 name="RadiusSecret2" size=15 maxlength=15> 
   		</td> 
	</tr>     
</table> 


<p><table align=left>
 <tr>
  <td style="width:600px" align=left><script language="JavaScript">fnbnS(Submit_, 'onClick=Activate(this.form)')</script></td>
  <td width=15></td></tr>
</table></p>
</fieldset>
</form>
</body></html>

