<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
if (debug) {
	var gdata = { free:'30', page:'0', back:'1', last:'2'} ;
	var wdata = [		
		<%net_webIPsec_status();%>
	];
	var nexb = 'Next Page';
	var preb = 'Prev Page';
}else{
	var gdata = { free:'30', page:'0', back:'1', last:'2'} ;
	var wdata = [
		{connname:'aries', 	lsubnet:'192.168.127.0', lgw:'192.168.2.111', rgw:'192.168.2.122', rsubnet:'100.100.100.0', phase1:'established', phase2:'established'},
		{connname:'coco', 	lsubnet:'10.10.10.0', lgw:'192.168.2.113', rgw:'192.168.2.114', rsubnet:'11.11.11.0', phase1:'established', phase2:''},
		{connname:'long', 	lsubnet:'20.20.20.0', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'g903', 	lsubnet:'20.20.20.0', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'man', 	lsubnet:'30.30.30.0', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'kkamn', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'dodo', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'cc', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'wang', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'kae', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'gogo', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'moxa', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'IEI', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'di', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'do', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'ivn', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'pp', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'aa', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'dd', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'ee', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'kae', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'gogo', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'moxa', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'IEI', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'di', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'do', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'ivn', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'kae', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'gogo', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'moxa', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'IEI', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'di', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'do', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''},
		{connname:'ivn', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:'established'},
		{connname:'kk', 	lsubnet:'192.168.2.111', lgw:'192.168.2.111', rgw:'192.168.2.111', rsubnet:'192.168.2.111', phase1:'established', phase2:''}
	];
	var nexb = 'Next Page';
	var preb = 'Prev Page';
}
<!--#include file="dhcp_list"-->
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page='+gdata.page+'&back='+gdata.back;
var link0 = 'ipsec_status.asp';

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

function Ipsec_Status_RowEdit(row, data, id_start) {	
	document.getElementById('ipsecnm').value = wdata[id_start + row.rowIndex-1].connname;
	ChgColor('tri', (data.length < id_start+per_page_show)?(data.length-id_start):per_page_show, row.rowIndex-1);
	document.getElementById('ipseconnidx').value = row.rowIndex-1 + id_start;
}

var per_page_show=10
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
		var j, row, cell, i;		
		for (i = page*per_page_show; !(i >= (page + 1)*per_page_show || i >= wdata.length) ; i++) {
			row = table.insertRow(table.getElementsByTagName("tr").length);			
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].connname;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].lsubnet;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].lgw;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].rgw;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].rsubnet;		
			row.appendChild(cell);			
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].phase1;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].phase2;		
			row.appendChild(cell);
			cell = document.createElement("td");
			cell.innerHTML = wdata[i].time;		
			row.appendChild(cell);
			row.className = (i%2 ? 'r1' : 'r2');
			row.align="center";
			row.id = 'tri'+(i-page*per_page_show);
			row.onclick=function(){Ipsec_Status_RowEdit(this, wdata, page*per_page_show)};
			row.style.cursor=ptrcursor;
		}
		if(wdata.length != 0){
			Ipsec_Status_RowEdit(getElementById('tri0'), wdata, page*per_page_show);
		}
	}
}

function Conn_Activate(form ,conn)
{	
	form.ipseconn.value = conn;	
	form.action="/goform/net_WebIPsecStatusGetValue";	
	form.submit();	
}

</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(IPsec_);doc(' ');doc(Status_)</script></h1>
<form onSubmit="return stopSubmit()">
<fieldset>
<input type="hidden" name="ipsec_conn" id="ipseconn" value="" >
<input type="hidden" name="ipsec_conn_idx" id="ipseconnidx" value="" >
<table cellpadding=1 cellspacing=2 border=0 align=center width=700px style="display:none">
 <tr class=r0 >
  <td colspan=8><script language="JavaScript">doc(IPsec_Connections_);doc(' ');doc(Settings_);</script></td></tr>  
 <tr class=r1>
  <td width=50px><script language="JavaScript">doc(Name_)</script></td>
  <td width=100px><input type="text" id=ipsecnm name="ipsec_name" size=17 maxlength=16 readonly></td>
  <td width=80px><script language="JavaScript">fnbnBID(Connected_, 'onClick=Conn_Activate(this.form,1)', 'btnC')</script></td>
  <td width=15px></td>
  <td ><script language="JavaScript">fnbnBID(Disconnected_, 'onClick=Conn_Activate(this.form,0)', 'btnD')</script></td>
  </tr>  
</table>

<DIV style=" height:280px; overflow-y:auto;">
<table cellpadding=2 cellspacing=1 border=0 align=center id="showleasetable">
 <tr align="center">
  <th width=18%><script language="JavaScript">doc(Name_)</script></td>
  <th width=12%><script language="JavaScript">doc(Local_);doc(' ');doc(Subnet_)</script></td>
  <th width=12%><script language="JavaScript">doc(Local_);doc(' ');doc(Gateway_)</script></td>  
  <th width=12%><script language="JavaScript">doc(Remote_);doc(' ');doc(Gateway_)</script></td>
  <th width=12%><script language="JavaScript">doc(Remote_);doc(' ');doc(Subnet_)</script></td>
  <th width=11%><script language="JavaScript">doc(IPsec_Phase_1_)</script></td> 
  <th width=11%><script language="JavaScript">doc(IPsec_Phase_2_)</script></td>
  <th width=12%><script language="JavaScript">doc(Time_)</script></td></tr>
<script language="JavaScript">ShowList('tri')</script>
</table>
</DIV>

<p><table><tr align=right><td>
<table align=left>
 <tr>
  <td><script language="JavaScript">fnbnBID(preb, 'onClick=prepage()', 'btnp')</script></td>
  <td width=15></td>  
  <td><script language="JavaScript">fnbnBID(nexb, 'onClick=nextpage()', 'btnn')</script></td>
  <td width=45></td>
  <td><script language="JavaScript">fnbnB(Refresh_, 'onClick=location.href=link0')</script></td>
  <td width=150></td>
</tr></table></td>
</table></p>
</fieldset>
</form>
</body></html>



