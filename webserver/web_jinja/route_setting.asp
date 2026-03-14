<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();
if (debug) {
	{{ net_Web_show_value('SRV_SROUTE') | safe }}
}else{
	var SRV_SROUTE = [
	{ idx:'0', enable:1, name:'XXXXXXX ', dest:'192.168.3.50', mask:'255.255.255.0', nexthop:'192.168.127.0', metric:'1'},
	{ idx:'1', enable:1, name:'test2', dest:'10.11.12.50', mask:'255.255.255.0', nexthop:'168.95.2.0', metric:'1'},
	{ idx:'2', enable:0, name:'test3', dest:'140.117.3.37', mask:'255.255.255.0', nexthop:'140.117.168.0', metric:'1'},
	{ idx:'3', enable:0, name:'test4', dest:'192.168.1.18', mask:'255.255.255.255', nexthop:'192.168..5.1', metric:'1'}	
	];
}

var ipcnt;
var entryNUM=0;
{% include "spapp_data" ignore missing %}



var enable0 = [
	{ value:0  , text:Disable_ },	{ value:1  , text:Enable_ }
];

var myForm;
function fnInit(row) {
	myForm = document.getElementById('myForm');
	EditRow(row);
}

function EditRow(row) {
	fnLoadForm(myForm, SRV_SROUTE[row], SRV_SROUTE_type);
	ChgColor('tri', SRV_SROUTE.length, row);
}

function ShowList1(name) {
	table = document.getElementById("show_available_table");
//	var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1 ;i>1;i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0; i<SRV_SROUTE.length; i++)
	{
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_SROUTE.length, 0);		
}

function EditRow1(row) 
{
	var rowidx = row.rowIndex;
	fnLoadForm(myForm, SRV_SROUTE[rowidx], SRV_SROUTE_type);
	ChgColor('tri', SRV_SROUTE.length, rowidx);
	entryNUM = rowidx;		
}

var Route_Policy_MAX = 512;

function Total_Policy()
{
	
	if(SRV_SROUTE.length > Route_Policy_MAX){
		alert('Number of policy is Over');		
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = true;			
			btnU.disabled = true;
		}		
		
	}else if(SRV_SROUTE.length == 512){
		with (document.myForm) {
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnU.disabled = false;
		}
	}else{
		with (document.myForm) {
			btnA.disabled = false;
			btnD.disabled = false;
			btnM.disabled = false;
			btnU.disabled = false;
		}
	}
	document.getElementById("totalpolicy").innerHTML = '('+SRV_SROUTE.length +'/' +Route_Policy_MAX+')';
}
function addRow(i)
{
	table = document.getElementById('show_available_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);

	cell = document.createElement("td");
	cell.width = '50px';

	if(SRV_SROUTE[i].enable==1)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.width = '80px';
	var name_string;
	name_string = SRV_SROUTE[i].name;

	/* transform "<" and ">" into "&lt;" and "&gt;" */
	name_string = name_string.replace("<","&lt;");
	name_string = name_string.replace(">","&gt;");
	
	cell.innerHTML = name_string;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '120px';	
	cell.innerHTML = SRV_SROUTE[i].dest;
	row.appendChild(cell);
	
	cell = document.createElement("td");	
	cell.width = '120px';
	cell.innerHTML = SRV_SROUTE[i].mask;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '120px';	
	cell.innerHTML = SRV_SROUTE[i].nexthop;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '70px';	
	cell.innerHTML = SRV_SROUTE[i].metric;
	row.appendChild(cell);
	
	row.style.Color = "black";
	var j=i+1;
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this)};
	row.style.cursor=ptrcursor;
	row.align="center";
} 

function isSymbol_static_route(obj, ObjName){
	var TempObj;
	TempObj=obj.value;
	//var regu = "^[0-9a-zA-Z_@\u0020\u002d\u002e\u002f]+$";
	//var regu = "^[0-9a-zA-Z_@!#$%^&*()\.\/\ \-]+$";  
	var regu = "^[0-9a-zA-Z><_@!#$%^&*()\.\/\-]+$";   
	var re = new RegExp(regu);
	if (re.test( TempObj ) ) {    
		return 0;    
	} 
	else{   
		alert(MsgHead[0]+ObjName+MsgStrs[5]);
		return 1;    
	}
}

function Add(form)
{
	if((isSymbol_static_route(form.name, Name_))) {
		return;
	}

	if(duplicate_check(Route_Policy_MAX, SRV_SROUTE, "name", form.name.value, Name_  + ' ' + form.name.value + ' '  + "is exist")<0){
	    return;
	}

	//alert("form.dest="+form.dest);
	//alert("form.mask="+form.mask);
	if(form.mask.value=="0.0.0.0")
	{
		form.dest.value = "0.0.0.0";
	}

	if(!(IsIpOK(form.dest, Destination_Address) && NetMaskIsOK(form.mask, Netmask) && IsIpOK(form.nexthop, nexthop_) && isMetric(form.metric, Metric_)))
	{
		return;
	}

	var arrayLen = SRV_SROUTE.length++;		
	SRV_SROUTE[arrayLen]=new Array(0,0,0,0,0,0);
	
	SRV_SROUTE[arrayLen].idx=arrayLen;
	if(form.enable.checked==true)
		SRV_SROUTE[arrayLen].enable=1;
	else
		SRV_SROUTE[arrayLen].enable=0;

	SRV_SROUTE[arrayLen].name = form.name.value;
	SRV_SROUTE[arrayLen].dest = form.dest.value;
	SRV_SROUTE[arrayLen].mask = form.mask.value;
	SRV_SROUTE[arrayLen].nexthop = form.nexthop.value;
	SRV_SROUTE[arrayLen].metric = form.metric.value;
	
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1; i>=0; i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0; i<SRV_SROUTE.length; i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_SROUTE.length, SRV_SROUTE.length-1);	
	entryNUM = arrayLen;
}

function Del()
{	
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
	if(entryNUM > rows.length - 1 )
		return;
	SRV_SROUTE.splice(entryNUM,1);		
	
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1; i>=0; i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0;i<SRV_SROUTE.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_SROUTE.length, entryNUM);
	rows = table.getElementsByTagName("tr");
	if(entryNUM > rows.length - 1 )
		return;
	EditRow1(rows[entryNUM]);
}


function Modify(form)
{	
	if((isSymbol_static_route(form.name, Name_))) {
		return;
	}

	if(duplicate_check(entryNUM, SRV_SROUTE, "name", form.name.value, Name_  + ' ' + form.name.value + ' '  + "is exist")<0){
	    return;
	}

	if(form.mask.value=="0.0.0.0")
	{
		form.dest.value = "0.0.0.0";
	}

	if(!(IsIpOK(form.dest, Destination_Address) && NetMaskIsOK(form.mask, Netmask) && IsIpOK(form.nexthop, nexthop_) && isMetric(form.metric, Metric_)))
	{
		return;
	}

	if(form.enable.checked==true)
		SRV_SROUTE[entryNUM].enable=1;
	else
		SRV_SROUTE[entryNUM].enable=0;

	SRV_SROUTE[entryNUM].name = form.name.value;
	SRV_SROUTE[entryNUM].dest = form.dest.value;
	SRV_SROUTE[entryNUM].mask = form.mask.value;
	SRV_SROUTE[entryNUM].nexthop = form.nexthop.value;
	SRV_SROUTE[entryNUM].metric = form.metric.value;
	
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1 ;i>=0;i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0;i<SRV_SROUTE.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_SROUTE.length, entryNUM);	
}

function Activate(form)
{	
	var i;
	var j;
	for(i = 0 ; i < SRV_SROUTE.length ; i++)
	{	
		for(j in SRV_SROUTE_type){
			form.SRV_SROUTE_tmp.value = form.SRV_SROUTE_tmp.value + SRV_SROUTE[i][j] + "+";			
		}				
	}
	form.action="/goform/net_Web_get_value?SRV=SRV_SROUTE"
}

</script>
</head>
<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(Static_Routing)</script></h1>

<fieldset>
<form id=myForm name=myForm method="POST">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="SRV_SROUTE_tmp" id="SRV_SROUTE_tmp" value="" >
<input type="hidden" id=idx name="q_idx">
<DIV style="width:800px;">
<table cellpadding=1 cellspacing=1>
 <tr align="left">
  <td width=150px><script language="JavaScript">doc(Enable_)</script></td>
  <td><input type="checkbox" id=enable name="route_en" value=1></td>
 </tr>
 <tr align="left">
  <td><script language="JavaScript">doc(Name_)</script></td>
  <td><input type="text" id=name name="route_name" size=10 maxlength=10></td>
 </tr>
 <tr align="left">
  <td><script language="JavaScript">doc(Destination_Address)</script></td>
  <td><input type="text" id=dest name="route_dest" size=15 maxlength=15></td>
 </tr> 
 <tr align="left">
  <td><script language="JavaScript">doc(Netmask)</script></td>
  <td><input type="text" id=mask name="route_mask" size=15 maxlength=15></td>
 </tr> 
 <tr align="left">
  <td><script language="JavaScript">doc(nexthop_)</script></td>
  <td nowrap><input type="text" id=nexthop name="next_hop" size=15 maxlength=15></td>
 </tr> 
 <tr align="left"> 
  <td><script language="JavaScript">doc(Metric_)</script></td>
  <td nowrap><input type="text" id=metric name="route_metric" size=5 maxlength=5></td> 

 </tr>
  
</table>

<table border=0>
 <tr>
  <td width=400px><script language="JavaScript">fnbnBID(addb, 'onClick=Add(this.form)', 'btnA')</script>
  				  <script language="JavaScript">fnbnBID(delb, 'onClick=Del(this.form)', 'btnD')</script>
  				  <script language="JavaScript">fnbnBID(modb, 'onClick=Modify(this.form)', 'btnM')</script></td>
  <td width=300px><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
 </tr>
</table>
</form>
</DIV>

<table align=left border=0>
	<tr style="height:50px"></tr>
</table>

<table>
 <tr class=r0>
  <td  width = 120px><script language="JavaScript">doc(Static_Routing)</script></td>
  <td id = "totalpolicy"></td></tr>
 </table>  
<table cellpadding=1 cellspacing=2>   
 <tr>
  <th width=50px><script language="JavaScript">doc(Enable_)</script></th>
  <th width=80px><script language="JavaScript">doc(Name_)</script></th>
  <th width=120px class="s0"><script language="JavaScript">doc(Destination_Address)</script></th>
  <th width=120px><script language="JavaScript">doc(Netmask)</script></th> 
  <th width=120px><script language="JavaScript">doc(nexthop_)</script></th>
  <th width=70px><script language="JavaScript">doc(Metric_)</script></th>
</table>

<DIV style="height:171px; overflow-y:auto;">
<table cellpadding=1 cellspacing=2 id="show_available_table">
<script language="JavaScript">ShowList1('tri')</script>
</table>
</DIV>
</fieldset>

</body></html>
