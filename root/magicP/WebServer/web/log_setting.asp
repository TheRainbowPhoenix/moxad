<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = [
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
		<%net_webLog(show_page);%>		
}
wtype = {
	index:4, bootup:4, date:4, time:4, sst:4, event:4
};

var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'fnChgpage(this.value)', option:selpage0 };

function fnChgpage(page) {		
	location.href="log_setting.asp?show_page="+page;
}
function fnInit() {	
	if(wdata[0].index == 0)
		return;
	table = document.getElementById("show_table");	
	for(i = 0; i < wdata.length; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		for(idx in wdata[0]){	
			cell = document.createElement("td");
			cell.innerHTML = wdata[i][idx];		
			row.appendChild(cell);
			row.style.Color = "black";
			row.align="center";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
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
<script language="JavaScript">doc(Event_);</script> 
 <script language="JavaScript">doc(Log_);</script> 
 <script language="JavaScript">doc(Table_);</script>
</h1>

<fieldset>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="static_tmp" id="statictmp" value="" >
<tr>
 <td><script language="JavaScript">fnGenSelect(seliface, ((wdata[0].index-1)/10)+1)</script></td></tr>
<tr> 
<table cellpadding=1 cellspacing=2 id="show_table" style="width:650px">
 <tr align="center" width=500px>
  <th width=50px><script language="JavaScript">doc(Index_)</script></th>
  <th width=50px><script language="JavaScript">doc(Bootup_)</script></th>
  <th width=60px><script language="JavaScript">doc(Date_)</script></th>
  <th width=60px><script language="JavaScript">doc(Time_)</script></th> 
  <th width=150px><script language="JavaScript">doc(SST_)</script></th> 
  <th width=200px><script language="JavaScript">doc(Event_)</script></th> </tr>
</table></tr>

<table align=left border=0>
<tr style="height:50px"></tr>
</table>

<p><table align=left>
 <tr>
  <td><script language="JavaScript">fnbnS('Clear', 'onClick=fnChgpage(-1)')</script></td>
  <td width=15></td></tr>
</table></p>

</form>
</fieldset>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

