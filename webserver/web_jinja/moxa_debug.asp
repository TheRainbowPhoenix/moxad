<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();
if (!debug) {
	var SRV_VPNG = {
		enable:'0', natt:'1'	
	};
}else{
	{{ net_Web_show_value('SRV_MOXA_DEBUG') | safe }}		
}


var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];


var actb = 'Active';
var myForm;

var file_name;
function MakeContents(http_request) {
	var nm, data;		
    if (http_request.readyState == 4) {
		if (http_request.status == 200) {				
			location=file_name;
		} else {
            return ;
			//alert('There was a problem with the request.'+http_request.status);
		}
	}
}


function MakeAndGetKernelLog(){
	file_name = '/MOXA_Kernel_LOG.ini';

	/*
		#define MOXA_LOG_ALL		0   
		#define MOXA_LOG_VPN		1
		#define MOXA_LOG_FIREWALL	2
		#define MOXA_LOG_SYSTEM		3	
		#define MOXA_LOG_KERNEL		4	
	*/
	var link_path = "/goform/net_MakeMoxaLogFile?show_category="+4;
	
	makeRequest(link_path, MakeContents ,0);
}	

function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_MOXA_DEBUG, SRV_MOXA_DEBUG_type);
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(MOXA_DEBUG_LOG_)</script></h1>
<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_MOXA_DEBUG">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2 border=0 width=500px>  
 <tr align="left" >
  <td width=180px><script language="JavaScript">doc(Enable_)</script></td>
  <td><input type="checkbox" id=debugenable name="debugenable"></td>
  </tr>

</table>

<p><table align=left>
 <tr>
  <td style="width:400px" align=left><script language="JavaScript">fnbnS(Submit_, '')</script></td>
  <td><script language="JavaScript">fnbnS(Export_, 'onClick=MakeAndGetKernelLog()')</script></td>
  <td width=15></td></tr>
</table></p>
</fieldset>
<input type="hidden" name="debug_tmp" id="debug_tmp" value="">
</form>
</body></html>

