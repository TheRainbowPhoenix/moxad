<html>
<head>
{{ net_Web_file_include() | safe }}
<script language="JavaScript" src=mdata.js></script>
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript">

checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();

if(!debug){
	
}
else{
	{{ net_Web_show_value('SRV_OSPF_G') | safe }}
	{{ net_webOSPFRouterID() | safe }}
}

var myForm;

function fnInit()
{
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_OSPF_G, SRV_OSPF_G_type);
}

function show_cur_router_id()
{
	doc(cur_router_id);
}

function activate(form)
{
	if(!IsIpOK(form.router_id, OSPF_G_ROUTER_ID)){
		return;
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_OSPF_G";
	form.submit();
}

</script>
</head>

<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(OSPF_G_SETTING)</script></h1>

<fieldset>
<form id=myForm name=myForm method="POST">
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2 border=0>
	<tr height=25px>
		<td width=150px> <input type="checkbox" id=g_enable name="g_enable"> 
			 <script language="JavaScript">doc(OSPF_G_ENABLE)</script> </td>
		<td> </td>
	</tr>
	<tr height=25px>
		<td width=150px> <script language="JavaScript">doc(OSPF_G_CUR_ROUTER_ID)</script> </td>
		<td> <script language="JavaScript">show_cur_router_id()</script> </td>
	</tr>
	<tr height=25px>
		<td width=150px> <script language="JavaScript">doc(OSPF_G_ROUTER_ID)</script> </td>
		<td> <input type="text" id=router_id name="router_id" size=15 maxlength=15> </td>
	</tr>
	<tr height=25px>
		<td width=150px> <script language="JavaScript">doc(OSPF_G_DISTRIBUTE)</script> </td>
		<td> <input type="checkbox" id=distribute_c name="distribute_c">
			 <script language="JavaScript">doc(OSPF_G_DISTRIBUTE_C)</script>
			 <input type="checkbox" id=distribute_s name="distribute_s">
			 <script language="JavaScript">doc(OSPF_G_DISTRIBUTE_S)</script>
			 <input type="checkbox" id=distribute_r name="distribute_r">
			 <script language="JavaScript">doc(OSPF_G_DISTRIBUTE_R)</script>
		</td>
	</tr>
</table>

<table border=0>
	<tr>
  		<td> <script language="JavaScript">fnbnSID(Submit_, 'onClick=activate(this.form)', 'btnS')</script> </td>
	</tr>
</table>
</form>
</fieldset>

</body>
</html>