<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(Multi_IP_Set)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
if (debug) {
	var wdata = [
	//{	idx:'0', stat:1, mipname:'XXXXXXX XXXXXXXXXXXXX XXXXXXXXXXXX', wansle:1, wanip1:'500', wanip2:'1000',
	//	iprot:6, iport1:'500', iport2:'1000' },
	//{	idx:'1', stat:1, mipname:'test2', wansle:2, wanip1:'1500', wanip2:'2000',
	//	iprot:17, iport1:'1000', iport2:'2000' },
	//{	idx:'2', stat:0, mipname:'test3', wansle:1, wanip1:'2500', wanip2:'3000',
	//	iprot:6, iport1:'2000', iport2:'3000' },
	//{	idx:'3', stat:0, mipname:'test3', wansle:1, wanip1:'192.168.127.50', wanip2:'192.168.127.80'}
	{{ net_webMips() | safe }}
	];
	var addb = 'Add';
	var modb = 'Modify';
	var updb = 'Update';
	var delb = 'Delete';
	var ipcnt;
	var entryNUM=0;
}
{% include "spapp_data" ignore missing %}

var wtype = { idx:4, stat:3, mipname:4, wansle:2, wanip1:4, wanip2:4};

var wan_select = [
	{ value:1, text:'WAN 1' },	{ value:2, text:'WAN 2' }
];
var stat0 = [
	{ value:0  , text:Disable_ },	{ value:1  , text:Enable_ }
];

var myForm;
function fnInit(row) {
	myForm = document.getElementById('myForm');
	EditRow(row);
}

function EditRow(row) {
	fnLoadForm(myForm, wdata[row], wtype);
	ChgColor('tri', wdata.length, row);
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
	for(i=0; i<wdata.length; i++)
	{
		addRow(i);		
	}
	Total_IP();
	ChgColor('tri', wdata.length, 0);		
}

function EditRow1(row) 
{
	var rowidx = row.rowIndex;
	fnLoadForm(myForm, wdata[rowidx], wtype);
	ChgColor('tri', wdata.length, rowidx);
	entryNUM = rowidx;
	
	if(wdata[rowidx].wansle==1){
		document.getElementById("wansle").selectedIndex=0;
	}
	else{
		document.getElementById("wansle").selectedIndex=1;
	}
}
function Total_IP()
{
	ipcnt = 0; 
	for(i = 0; i < wdata.length; i++){
		ipcnt += IpAddrRangCnt(wdata[i].wanip1,wdata[i].wanip2);		
	}
	if(ipcnt > 256 || ipcnt < 0){
		alert('Number of ip is Over or Wrong');
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = true;			
			btnU.disabled = true;
		}		
		
	}else if(ipcnt == 256){
		with (document.myForm) {
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = true;
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
	document.getElementById("totalipcnt").innerHTML = ipcnt + ' / 256';
}
function addRow(i)
{
	table = document.getElementById('show_available_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);

	cell = document.createElement("td");
	cell.width = '120px';

	if(wdata[i].stat==1)
		cell.innerHTML = "<IMG src=" + 'images/LED-Green.jpg'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/LED-Red.jpg'+ ">";
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '280px';
	cell.innerHTML = wdata[i].mipname;
	row.appendChild(cell);
	
	cell = document.createElement("td");	
	cell.width = '120px';
	cell.innerHTML = fnGetSelText(wdata[i].wansle, wan_select);
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '280px';	
	cell.innerHTML = wdata[i].wanip1+ '~' +wdata[i].wanip2;
	row.appendChild(cell);		
	
	row.style.Color = "white";
	var j=i+1;
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this)};
	row.style.cursor=ptrcursor;
	row.align="center";
} 

function Add(form)
{
	if(!(IpAddrIsOK(form.wanip1,'wan_ip_1')&& IpAddrIsOK(form.wanip2,'wan_ip_2')))
	{
		return;
	}
	var arrayLen = wdata.length++;		
	wdata[arrayLen]=new Array(0,0,0,0,0,0);
	
	wdata[arrayLen].idx=arrayLen;
	if(form.stat.checked==true)
		wdata[arrayLen].stat=1;
	else
		wdata[arrayLen].stat=0;

	wdata[arrayLen].mipname = form.mipname.value;
	wdata[arrayLen].wansle = form.wansle.selectedIndex + 1;
	wdata[arrayLen].wanip1 = form.wanip1.value;
	wdata[arrayLen].wanip2 = form.wanip2.value;
	
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
	for(i=0; i<wdata.length; i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_IP();
	ChgColor('tri', wdata.length, wdata.length-1);	
	entryNUM = arrayLen;
}

function Del()
{	
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
	if(entryNUM > rows.length - 1 )
		return;
	wdata.splice(entryNUM,1);		
	
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1; i>=0; i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0;i<wdata.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_IP();
	ChgColor('tri', wdata.length, entryNUM);
	rows = table.getElementsByTagName("tr");
	if(entryNUM > rows.length - 1 )
		return;
	EditRow1(rows[entryNUM]);
}


function Modify(form)
{	
	if(form.stat.checked==true)
		wdata[entryNUM].stat=1;
	else
		wdata[entryNUM].stat=0;

	wdata[entryNUM].mipname = form.mipname.value;
	wdata[entryNUM].wansle = form.wansle.selectedIndex + 1;
	wdata[entryNUM].wanip1 = form.wanip1.value;
	wdata[entryNUM].wanip2 = form.wanip2.value;
	
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
	for(i=0;i<wdata.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_IP();
	ChgColor('tri', wdata.length, entryNUM);	
}

function Activate(form)
{	
	var i;
	var j;
	for(i = 0 ; i < wdata.length ; i++)
	{	
		//alert(wdata[i].stat);
		form.multiiptmp.value = form.multiiptmp.value + wdata[i].stat + "+";
		form.multiiptmp.value = form.multiiptmp.value + wdata[i].mipname + "+";
		form.multiiptmp.value = form.multiiptmp.value + wdata[i].wansle + "+";
		form.multiiptmp.value = form.multiiptmp.value + wdata[i].wanip1 + "+";			
		form.multiiptmp.value = form.multiiptmp.value + wdata[i].wanip2 + "+";			
	}
}

</script>
</head>
<body class=main onLoad=fnInit(0)>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[2].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[2])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=myForm method="POST" action="/goform/net_WebMIPSGetValue">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="multi_ip_tmp" id="multiiptmp" value="" >
<input type="hidden" id=idx name="q_idx">
<DIV style="width:800px;">
<table cellpadding=1 cellspacing=1>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(Multi_IP_Config)</script></td></tr>
 <tr class=r2 align=center>
  <td><script language="JavaScript">doc(Enable_)</script></td>
  <td><script language="JavaScript">doc(Name_)</script></td>
  <td><script language="JavaScript">doc(WAN_)</script></td>
  <td><script language="JavaScript">doc(WAN_IP_Addr_)</script> Range</td>
  <td><script language="JavaScript">doc(Total_)</script> IP count</td>
 <tr class=r1 align="center">
  <td><input type="checkbox" id=stat name="m_ip_en" value=1></td>
  <td><input type="text" id=mipname name="m_ip_name" size=10 maxlength=10 onChange="fnChgUniq(this, wdata)"></td>
  <td><script language="JavaScript">iGenSel2('wan_sel', 'wansle', wan_select)</script></td>
  <td nowrap><input type="text" id=wanip1 name="wan_ip_1" size=15 maxlength=15> ~
      <input type="text" id=wanip2 name="wan_ip_2" size=15 maxlength=15></td>
  <td id = "totalipcnt"></td>    
</table>

<p><table class=tf align=center>
 <tr>
  <td><script language="JavaScript">fnbnBID(addb, 'onClick=Add(this.form)', 'btnA')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnBID(delb, 'onClick=Del(this.form)', 'btnD')</script></td>
  <td width="15"></td>
  <td><script language="JavaScript">fnbnBID(modb, 'onClick=Modify(this.form)', 'btnM')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnSID(updb, 'onClick=Activate(this.form)', 'btnU')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnB(Cancel_, 'onClick=location.reload()')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnB(Go_Back, 'onClick=history.go(-1)')</script></tr>
</table></p>
</form>

<table cellpadding=1 cellspacing=2>
 <tr class=r0>
  <td colspan=6><script language="JavaScript">doc(Multi_IP_List)</script></td></tr>
 <tr class=r5 align="center">
  <td width=120px><script language="JavaScript">doc(Enable_)</script></td>
  <td width=280px><script language="JavaScript">doc(Name_)</script></td>
  <td width=120px><script language="JavaScript">doc(WAN_)</script></td>
  <td width=280px><script language="JavaScript">doc(WAN_IP_Addr_)</script> Range</td> 
</table>
</DIV>
<DIV style="width:800px; height:171px; overflow-y:auto;">
<table cellpadding=1 cellspacing=2 id="show_available_table">
<script language="JavaScript">ShowList1('tri')</script>
</table>
</DIV>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>