<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var SRV_ROUTING_TABLE = [
		{type:'Connect', dest:'192.168.127.1', nhop:'100.100.100.254', ifname:'wan1', metric:'15'},
		{type:'RIP', dest:'192.168.1.254', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Static', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Static', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Connect', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Connect', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Connect', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'RIP', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Kernel', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Kernel', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Kernel', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Kernel', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Kernel', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'},
		{type:'Kernel', dest:'100.100.100.100', nhop:'100.100.100.254', ifname:'wan2', metric:'15'}
	];
	
var selpage0 = [
	{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
];			
var seltype=1;
}else{
	<%net_Web_show_value('SRV_ROUTING_TABLE');%>				
	var selpage0 = [
	];
	var seltype=<%net_webRTType();%>;
}
var prototype = [
	{ value:'A', text:'All' }, { value:'C', text:'Connected' }, { value:'S', text:'Static' },
	{ value:'R', text:'RIP' }, { value:'O', text:'OSPF' }
];	
/*SRV_ROUTING_TABLE_type = {
	index:4, type:4, dest:4, nhop:4, ifname:4, metric:4
};*/

var seliface = { type:'select', id:'selpage', name:'sel_page', size:1, onChange:'SelectPage(this.value)', option:selpage0 };
var selproto = { type:'select', id:'protocol', name:'sel_proto', size:1, onChange:'SelectProto(this.value)', option:prototype };

function SelectPage(page){
	table = document.getElementById("show_table");	
	for(i = table.getElementsByTagName("tr").length-1; i > 0; i--){
		table.deleteRow(i);
	}
	for(i = page*10; i < SRV_ROUTING_TABLE.length && i < page*10+10; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		cell = document.createElement("td");
		cell.innerHTML = i + 1;		
		row.appendChild(cell);
		row.style.Color = "black";
		row.style.backgroundColor = "white";
		row.align="center";
		for(idx in SRV_ROUTING_TABLE[0]){	
			cell = document.createElement("td");
			cell.innerHTML = SRV_ROUTING_TABLE[i][idx];		
			row.appendChild(cell);
			//row.style.Color = "black";
			//row.align="center";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
	}	
}

function SelectProto(form){			
	var i;
	i=document.getElementById('protocol').value;
	location.href="routing_table.asp?r_type="+i;	
}
	
function fnInit() {
	var i;
	var RTABLE_LIST_PERPAGE = 10;

	document.getElementById('protocol').value=seltype;
	if(SRV_ROUTING_TABLE==""){
		document.getElementById('selpage').options.add(new Option("Page 1/1", 1)); 
		return;
	}else{
		for(i=0;i<Math.floor (((SRV_ROUTING_TABLE.length-1)/RTABLE_LIST_PERPAGE))+1;i++){
			document.getElementById('selpage').options.add(new Option("Page "+parseInt(i+1)+"/"+ parseInt(Math.floor (((SRV_ROUTING_TABLE.length-1)/RTABLE_LIST_PERPAGE))+1), i)); 
		} 
	}
	
	SelectPage(0);	
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(Routing_);doc(' ');doc(Table_);</script></h1>

<fieldset>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<tr>
 <td width=100px><script language="JavaScript">fnGenSelect(seliface, 0)</script></td>
 <td><script language="JavaScript">fnGenSelect(selproto, 0)</script></td></tr>
<tr> 
<table cellpadding=1 cellspacing=2 id="show_table" style="width:650px">
 <tr align="center" width=500px>
  <th width=50px><script language="JavaScript">doc(Index_)</script></th>
  <th width=80px><script language="JavaScript">doc(Type_)</script></th>
  <th width=120px class="s0"><script language="JavaScript">doc(Destination_Address)</script></th>
  <th width=120px><script language="JavaScript">doc(nexthop_)</script></th> 
  <th width=120px><script language="JavaScript">doc(Interface_);doc(' ');doc(Name_)</script></th>   
  <th width=80px><script language="JavaScript">doc(Metric_)</script></th> </tr>
</table></tr>

</form>
</fieldset>

</body></html>

