<html>
<head>
<script language="JavaScript" src=doc.js></script>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
if (debug) {
	var gdata = { free:'30', page:'0', back:'1', last:'2'} ;
	var wdata = [		
		<%net_webDhcp_List();%>
	];
	var nexb = 'Next Page';
	var preb = 'Prev Page';
}else{
	var gdata = { free:'30', page:'0', back:'1', last:'2'} ;
	var wdata = [
		{TD00:'Ted1', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted2', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted3', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted4', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted5', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted6', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted3', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted4', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted5', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted6', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted7', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },
		{TD00:'Ted8', TD01:'00-0E-A6-09-7A-9E', TD02:'192.168.9.89', TD03:'2', TD04:'3', TD05:'32m:36s' },
		{TD00:'ETHAN', TD01:'00-00-E2-6A-F7-88', TD02:'192.168.9.88', TD03:'2', TD04:'3', TD05:'43m:26s' },		
		{TD00:'cnn-nb', TD01:'00-02-3F-1A-70-00', TD02:'192.168.9.87', TD03:'2', TD04:'3', TD05:'40m:47s' }
	];
	var nexb = 'Next Page';
	var preb = 'Prev Page';
}
<!--#include file="dhcp_list"-->
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page='+gdata.page+'&back='+gdata.back;
var link0 = 'dhcpd_leases_table.asp';

var stat0 = [
	{ value:0, text:Error_ },
	{ value:1, text:Bootptab_ },
	{ value:2, text:Dynamic_ },
	{ value:3, text:Static_ },
	{ value:4, text:Reserved_ }
];

var stat1 = [
	{ value:0, text:Released_ },
	{ value:1, text:Bootped_ },
	{ value:2, text:Offer_Pending },
	{ value:3, text:Leased_ }
];

var page=0;
function prepage(){
	if(page > 0){
		page--;
	}else{
		return;
	}
	ShowList();
	BtnCheck();
}

function nextpage(){
	if(wdata.length > page*10+10){
		page++;
	}else{
		return;
	}
	
	ShowList();
	BtnCheck();
}

var gtype = { page:4, back:4 };

var myForm;
function fnInit() {
	BtnCheck();
}

function BtnCheck() {
	with (document) {
		myForm = getElementById('myForm');
		getElementById('btnp').disabled = (page==0);
		getElementById('btnn').disabled = !(wdata.length > page*10+10);
	}
}
function ShowList(name) {

	var table = document.getElementById("showleasetable");
	var rows = table.getElementsByTagName("tr");
	var i;
	//delete added the table members
	if(rows.length > 2)
	{
		for(i=rows.length-1; i > 1; i--)
		{
			table.deleteRow(i);
		}
	}
	
	with (document) {
		var j, row, cell;		
		for (var i in wdata) {			
			if(i < page*10)
				continue;
			if(i >= page*10+10 || i > wdata.length)
				break;	
			row = table.insertRow(table.getElementsByTagName("tr").length);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].TD00;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].TD01;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].TD02;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].TD05;		
			row.appendChild(cell);

			//row.className = (i%2 ? 'r1' : 'r2');
			row.align="center";
		}
	}
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(DHCP_Leased_List)</script></h1>
<fieldset>
<table cellpadding=1 cellspacing=2 id = "showleasetable">
 <tr align="center">
  <th width=25%><script language="JavaScript">doc(Name_)</script></td>
  <th width=25%><script language="JavaScript">doc(MAC_Address)</script></td>
  <th width=16%><script language="JavaScript">doc(IP_Address)</script></td>
 <!-- <td width=10%><script language="JavaScript">doc(Type_)</script></td>
  <td width=11%><script language="JavaScript">doc(Status_)</script></td> -->
  <th width=34%><script language="JavaScript">doc(Time_Left)</script></td></tr>
<script language="JavaScript">ShowList('tri')</script>
</table>
<form id=myForm method="POST" action="dhcplist.cgi">
<% net_Web_csrf_Token(); %>
<input type="hidden" id=page name="page">
<input type="hidden" id=back name="back">

<table align=left>
 <tr>
  <td width=400px><script language="JavaScript">fnbnBID(preb, 'onClick=prepage()', 'btnp')</script>
  <script language="JavaScript">fnbnBID(nexb, 'onClick=nextpage()', 'btnn')</script></td>
  <td width=300px><script language="JavaScript">fnbnB(Refresh_, 'onClick=location.href=link0')</script></td>
</tr></table>
<!--  <td><script language="JavaScript">fnbnB(Go_Back, 'onClick=history.go(-gdata.back)')</script></tr>-->

</form>
</fieldset>
</body></html>
