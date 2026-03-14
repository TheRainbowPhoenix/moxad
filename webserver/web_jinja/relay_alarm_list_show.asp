<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
var NORELAY = {{ net_Web_Get_NO_RELAY() | safe }}
if (!debug) {
	var NORELAY =2;
	var wdata = {
		override1:'0', override2:'0'
	};
	var wdata1 = [
		{index:'1', event:'Port1 link on', relay:1},
		{index:'2', event:'Port2 link off', relay:2},
		{index:'3', event:'Power Input 1 On->Off ! ', relay:1},
		{index:'4', event:'Power Input 2 On->Off ! ', relay:2}
	];				
}else{
	var wdata = {{ net_websSysRelay() | safe }};
	var wdata1 = [		
		{{ net_webRelayListPage() | safe }}
	];	
}
wtype1 = {
	index:4, event:4, relay:4
};
var wtype = {
	override1:3,override2:3,pwfail1:3
};

function show_Relayaco(){
	document.write('<tr>');
	document.write('<td><input type="checkbox" id= override1' + ' name="override1" >');				
	document.write('<b><script language="JavaScript">doc(Relay1_);doc(" ");doc(Aco);<\/script><\/b><\/td>');
	document.write('</tr>');
	if(NORELAY == 2){
	document.write('<tr>');
	document.write('<td><input type="checkbox" id= override2' + ' name="override2" >');				
	document.write('<b><script language="JavaScript">doc(Relay2_);doc(" ");doc(Aco);<\/script><\/b><\/td>');
	document.write('</tr>');
	}
}	

var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	
	
	if(wdata1.length == 0){
		fnLoadForm(myForm, wdata, wtype);
		return;
	}
	table = document.getElementById("show_table");	
	for(i = 0; i < wdata1.length; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		for(idx in wdata1[0]){	
			cell = document.createElement("td");
			cell.innerHTML = wdata1[i][idx];		
			row.appendChild(cell);
			row.style.Color = "black";
			row.align="center";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
	}
	fnLoadForm(myForm, wdata, wtype);
}

function stopSubmit()
{
	return false;
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">

<h1><script language="JavaScript">doc(Relay_Warning_);</script></h1>

<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<form id=myForm name=form1 method="POST" action="/goform/net_WebRelayEvent">
{{ net_Web_csrf_Token() | safe }}
<fieldset>
<table cellpadding=1 cellspacing=2 style="width:60%">
<input type="hidden" id="pwfail1" name="pwfail1" value="1" />
	<script language="JavaScript">show_Relayaco()</script>
  <tr height="60">
   <td><script language="JavaScript">fnbnS(Submit_, '')</script></td>
  </tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_table" style="width:750px" border=0>
 <tr align="center" width=200px>
  <th width=250px><script language="JavaScript">doc(Index_)</script></th>
  <th width=250px><script language="JavaScript">doc(Event_)</script></th>
  <th width=250px><script language="JavaScript">doc(Relay_)</script></th> </tr>
</table>
</fieldset>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

