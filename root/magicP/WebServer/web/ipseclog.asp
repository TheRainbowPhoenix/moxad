<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var ipsecLog = [
		{index:'1', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'2', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'3', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'4', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'5', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'6', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'7', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'8', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'9', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'},
		{index:'10', bootup:'0', date:'2009/03/24', time:'01:42:00', sst:'16d17h18m27s', event:'WAN1 link on'}
	];
	
var selpage0 = [
	{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
	];			
}else{
	<%net_ipsecLog(show_page);%>
}

var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'fnChgpage(this.value)', option:ipsecLogPage };

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


function MakeAndGetIPSecLog(){
	file_name = '/MOXA_IPSec_LOG.ini';
	makeRequest("/goform/net_MakeIPSecLogFile", MakeContents ,0);
	
}	


function fnChgpage(page) {		
	if(page==-1&&!window.confirm('Delete VPN log?')){
		return;
	}
	location.href="ipseclog.asp?show_page="+page;
}
function fnInit() {	
	var i;
	if(ipsecLog[0].index == 0)
		return;
	table = document.getElementById("show_table");	
	for(i = 0; i < ipsecLog.length; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		for(idx in ipsecLog[0]){	
			cell = document.createElement("td");
			cell.innerHTML = ipsecLog[i][idx];		
			row.appendChild(cell);
			row.style.Color = "black";
			row.align="center";
		}
	}
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body onLoad=fnInit()>
<h1>
 <script language="JavaScript">doc(IPsec_Error_Log_);</script> 
</h1>

<fieldset>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="static_tmp" id="statictmp" value="" >
<tr>
 <td><script language="JavaScript">fnGenSelect(seliface, ((ipsecLog[0].index-1)/20)+1)</script></td></tr>
<tr> 
<table cellpadding=1 cellspacing=2 id="show_table" style="width:650px">
 <tr align="center" width=500px>
  <th width=50px><script language="JavaScript">doc(Index_)</script></th>
  <th width=60px><script language="JavaScript">doc(Date_)</script></th>
  <th width=60px><script language="JavaScript">doc(Time_)</script></th> 
  <th width=200px><script language="JavaScript">doc(Event_)</script></th> </tr>
</table></tr>

<table align=left border=0>
<tr style="height:50px"></tr>
</table>

<p><table align=left>
 <tr>
  <td><script language="JavaScript">fnbnS(Export_, 'onClick=MakeAndGetIPSecLog()')</script></td>
  <td><script language="JavaScript">fnbnS('Clear', 'onClick=fnChgpage(-1)')</script></td>
 </tr>
</table></p>

</form>
</fieldset>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

