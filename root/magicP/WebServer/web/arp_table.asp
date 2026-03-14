<html>
<head>  
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode(<% net_Web_GetMode_WriteValue(); %>);
if (!debug) {
	var SRV_ARP_TABLE = [
		{ip_addr:'192.168.127.50', mac_addr:'ac:f1:df:79:28:7b', interface:'LAN'},
		{ip_addr:'192.168.127.50', mac_addr:'ac:f1:df:79:28:7b', interface:'LAN'},
		{ip_addr:'192.168.127.50', mac_addr:'ac:f1:df:79:28:7b', interface:'LAN'},
		{ip_addr:'1.1.1.1', mac_addr:'ac:f1:df:79:28:7b', interface:'WAN'},
		{ip_addr:'1.1.1.2', mac_addr:'ac:f1:df:79:28:7b', interface:'WAN'},
		{ip_addr:'1.1.1.3', mac_addr:'ac:f1:df:79:28:7b', interface:'WAN'}
	];
}
else{
	<%net_WebARPTable();%>

}

var select_page = [];
var sel_page = { type:'select', id:'select_page_list', name:'select_page_list', size:1, onChange:'ShowTable2(this.value)', option:select_page };


function show_page_select()
{
    var i, idx, name, page;
	document.getElementById("select_page_list").options.length=0; 

	if(SRV_ARP_TABLE.length==0){
		page=1;
	}else{
		page = parseInt((SRV_ARP_TABLE.length-1)/10) + 1;
	}
	

    for(i = 0; i < page ; i++)
    {
        idx=i+1;
        name='Page '+idx+'/'+page;
	    var varItem = new Option(name,i);
	    document.getElementById("select_page_list").options.add(varItem); 
	}
}
//
function addrow(add_i)
{
 	var idx;
	row = table.insertRow(table.getElementsByTagName("tr").length);
	cell = document.createElement("td");
	cell.innerHTML = add_i + 1;		
	row.appendChild(cell);
	row.style.Color = "black";
	row.style.backgroundColor = "white";
	row.align="center";
	for(idx in SRV_ARP_TABLE[0])
	{
		cell = document.createElement("td");
		cell.innerHTML = SRV_ARP_TABLE[add_i][idx];
		row.appendChild(cell);
	}
}

function ShowTable(page)
{
	var i, page_item=0, total_item=SRV_ARP_TABLE.length;
	table = document.getElementById("show_arp_table");
	for(i = table.getElementsByTagName("tr").length-1; i > 0; i--)
	{
		table.deleteRow(i);
	}
    for(i=parseInt(page)*10; i < SRV_ARP_TABLE.length && i < (parseInt(page)+1)*10; i++)
    {
		addrow(i);
		row.className=((i%2)-1)?"r1":"r2";
    }
}

function ShowTable2(page)
{
	ShowTable(page);
}


function stopSubmit()
{
	return false;
}

function fnInit() 
{
	show_page_select();
	if(SRV_ARP_TABLE==""){
		return;
	}	
	
	ShowTable(0,0);
}
</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(arp_table);</script></h1>
<fieldset>
<!--<form id=myForm method="post" name="age_time_form" action="/goform/net_Web_get_value?SRV=SRV_AGE_TIME">-->
<table style="width:650px" border="0">
 <tr>
  <td style="width:650px" bgcolor='blue'><td>
 </tr>
</table>

<table style="width:650px">
<tr align="left" >
 <td><script language="JavaScript">fnGenSelect(sel_page, 0)</script></td>
</tr> 
</table>
<table cellpadding=1 cellspacing=2 id="show_arp_table" style="width:650px">
 <tr align="center" width=620px>
  <th width=50px ><script language="JavaScript">doc(Index_)</script></th>
  <th width=170px ><script language="JavaScript">doc(IP_Address)</script></th>
  <th width=170px ><script language="JavaScript">doc(MAC_Address)</script></th>
  <th width=170px><script language="JavaScript">doc(Interface_)</script></th>
 </tr>
</table>
</fieldset>
</body>
</html>
