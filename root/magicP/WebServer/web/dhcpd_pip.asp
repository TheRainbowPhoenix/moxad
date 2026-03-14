<html>
<head>
<script language="JavaScript" src=doc.js></script>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
if (!debug) {
	var SRV_DHCP_PIP_type = { enable: 3, port: 4, hostip: 5, dhcp_netmask: 4, dhcp_lease: 4, dhcp_gateway: 5, dhcp_dns1: 5, dhcp_dns2: 5, dhcp_ntp: 5 };

	var SRV_DHCP_PIP = [
	  {enable:'0', port:'1', hostip:'192.168.127.50', dhcp_netmask: '255.255.255.0', dhcp_lease: '10', dhcp_gateway: '192.168.127.254', dhcp_dns1: '192.168.127.11', dhcp_dns2: '192.168.127.12', dhcp_ntp: '192.168.127.13' },
	  {enable:'1', port:'2', hostip:'192.168.127.51', dhcp_netmask: '255.255.255.0', dhcp_lease: '50', dhcp_gateway: '192.168.127.254', dhcp_dns1: '192.168.127.11', dhcp_dns2: '192.168.127.12', dhcp_ntp: '192.168.127.13' },
	  {enable:'1', port:'3', hostip:'192.168.1.12', dhcp_netmask: '255.255.255.0', dhcp_lease: '99', dhcp_gateway: '192.168.127.254', dhcp_dns1: '192.168.127.11', dhcp_dns2: '192.168.127.12', dhcp_ntp: '192.168.127.13' },
	];
}else{
	<%net_Web_show_value('SRV_DHCP_PIP');%>
	var Route_Policy_MAX = <% net_Web_Get_SYS_PORTS(); %>;
}

var ipcnt;
var entryNUM=0;
<!--#include file="spapp_data"-->



var enable0 = [
	{ value:0  , text:Disable_ },	{ value:1  , text:Enable_ }
];

var myForm;
var dhcp_default_lease_time=1440;
function fnInit(row) {
	myForm = document.getElementById('myForm');
	EditRow(row);
	if(SRV_DHCP_PIP.length==0){
		myForm.dhcp_lease.value = dhcp_default_lease_time;	
	}
}

function EditRow(row) {
	fnLoadForm(myForm, SRV_DHCP_PIP[row], SRV_DHCP_PIP_type);
	ChgColor('tri', SRV_DHCP_PIP.length, row);
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
	for(i=0; i<SRV_DHCP_PIP.length; i++)
	{
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_DHCP_PIP.length, 0);		
}

function EditRow1(row) 
{
	var rowidx = row.rowIndex-1;
	fnLoadForm(myForm, SRV_DHCP_PIP[rowidx], SRV_DHCP_PIP_type);
	ChgColor('tri', SRV_DHCP_PIP.length, rowidx);
	entryNUM = rowidx;		
}
function Total_Policy()
{
	/*
	if(SRV_DHCP_PIP.length > Route_Policy_MAX){
		alert('Number of policy is Over');		
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = true;			
			btnU.disabled = true;
		}		
		
	}else if(SRV_DHCP_PIP.length == 512){
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
	*/
	with (document.myForm) {
		btnA.disabled = false;
		btnD.disabled = false;
		btnM.disabled = false;
		btnU.disabled = false;
	}
	document.getElementById("totalpolicy").innerHTML = '('+SRV_DHCP_PIP.length +'/' +Route_Policy_MAX+')';
}
function addRow(i)
{
	table = document.getElementById('show_available_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);

	cell = document.createElement("td");
	cell.width = '40px';

	if(SRV_DHCP_PIP[i].enable==1)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '40px';
	cell.innerHTML = SRV_DHCP_PIP[i].port;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '80px';	
	cell.innerHTML = SRV_DHCP_PIP[i].hostip;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '80px';
	cell.innerHTML = SRV_DHCP_PIP[i].dhcp_netmask;
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.width = '80px';	
	cell.innerHTML = SRV_DHCP_PIP[i].dhcp_lease;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '80px';
	cell.innerHTML = SRV_DHCP_PIP[i].dhcp_gateway;
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.width = '80px';
	cell.innerHTML = SRV_DHCP_PIP[i].dhcp_dns1;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '80px';
	cell.innerHTML = SRV_DHCP_PIP[i].dhcp_dns2;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '80px';
	cell.innerHTML = SRV_DHCP_PIP[i].dhcp_ntp;
	row.appendChild(cell);

	row.style.Color = "black";
	var j=i+1;
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this)};
	row.style.cursor=ptrcursor;
	row.align="center";
} 

function Add(form)
{
	//console.log("SRV_DHCP_PIP.length = " + SRV_DHCP_PIP.length);
    table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
    if(rows.length > 10){
        //alert("Full");
        return;
    }
        

	for (i = 0; i < SRV_DHCP_PIP.length; i++) {
		if (SRV_DHCP_PIP[i].port == form.port.value) {
			//console.log("Port " + form.port.value + " exists!");
			return;
		}
	}

	var arrayLen = SRV_DHCP_PIP.length++;		
	SRV_DHCP_PIP[arrayLen]=new Array(0,0,0,0);
	
	SRV_DHCP_PIP[arrayLen].idx=arrayLen;
	if(form.enable.checked==true)
		SRV_DHCP_PIP[arrayLen].enable=1;
	else
		SRV_DHCP_PIP[arrayLen].enable=0;

	SRV_DHCP_PIP[arrayLen].port = form.port.value;
	SRV_DHCP_PIP[arrayLen].hostip = form.hostip.value;
	SRV_DHCP_PIP[arrayLen].dhcp_netmask = form.dhcp_netmask.value;
	SRV_DHCP_PIP[arrayLen].dhcp_lease = form.dhcp_lease.value;
	SRV_DHCP_PIP[arrayLen].dhcp_gateway = form.dhcp_gateway.value;
	SRV_DHCP_PIP[arrayLen].dhcp_dns1 = form.dhcp_dns1.value;
	SRV_DHCP_PIP[arrayLen].dhcp_dns2 = form.dhcp_dns2.value;
	SRV_DHCP_PIP[arrayLen].dhcp_ntp = form.dhcp_ntp.value;

	//table = document.getElementById("show_available_table");
	//rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1; i>=0; i--)
		{
			table.deleteRow(i);
		}
	}
    FieldShow();
	//re-join the array elements to the table
	for(i=0; i<SRV_DHCP_PIP.length; i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_DHCP_PIP.length, SRV_DHCP_PIP.length-1);	
	entryNUM = arrayLen;
}

function Del()
{	
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
	if(entryNUM > rows.length - 1 )
		return;
	SRV_DHCP_PIP.splice(entryNUM,1);		
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1; i>=0; i--)
		{
			table.deleteRow(i);
		}
	}
    FieldShow();

	//re-join the array elements to the table
	for(i=0;i<SRV_DHCP_PIP.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_DHCP_PIP.length, entryNUM);
	rows = table.getElementsByTagName("tr");
    if(entryNUM==0)
        entryNUM=1;
	if(entryNUM > rows.length - 1 )
		return;
    if((rows.length-1)==0)
        return;
	EditRow1(rows[entryNUM]);
}


function Modify(form)
{	
//	if(!(IsIpOK(form.dest, Destination_Address) && NetMaskIsOK(form.mask, Netmask) && IsIpOK(form.nexthop, nexthop_) && isMetric(form.metric, Metric_)))
//	{
//		return;
//	}
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
    if((rows.length-1)==0)
        return;

	if(form.enable.checked==true)
		SRV_DHCP_PIP[entryNUM].enable=1;
	else
		SRV_DHCP_PIP[entryNUM].enable=0;

	SRV_DHCP_PIP[entryNUM].port = form.port.value;
	SRV_DHCP_PIP[entryNUM].hostip = form.hostip.value;
	SRV_DHCP_PIP[entryNUM].dhcp_netmask = form.dhcp_netmask.value;
	SRV_DHCP_PIP[entryNUM].dhcp_lease = form.dhcp_lease.value;
	SRV_DHCP_PIP[entryNUM].dhcp_gateway = form.dhcp_gateway.value;
	SRV_DHCP_PIP[entryNUM].dhcp_dns1 = form.dhcp_dns1.value;
	SRV_DHCP_PIP[entryNUM].dhcp_dns2 = form.dhcp_dns2.value;
	SRV_DHCP_PIP[entryNUM].dhcp_ntp = form.dhcp_ntp.value;
	
	//table = document.getElementById("show_available_table");
	//rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1 ;i>=0;i--)
		{
			table.deleteRow(i);
		}
	}
    FieldShow();
	//re-join the array elements to the table
	for(i=0;i<SRV_DHCP_PIP.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', SRV_DHCP_PIP.length, entryNUM);	
}

function Activate(form)
{	
	var i;
	var j;
	for(i = 0 ; i < SRV_DHCP_PIP.length ; i++)
	{	
		for(j in SRV_DHCP_PIP_type){
			form.SRV_DHCP_PIP_tmp.value = form.SRV_DHCP_PIP_tmp.value + SRV_DHCP_PIP[i][j] + "+";			
		}				
	}
	form.action="/goform/net_Web_get_value?SRV=SRV_DHCP_PIP"
}

function FieldShow(){

	table = document.getElementById('show_available_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);
  
    cell = document.createElement("th");
	cell.width = '45px';
    cell.className='s0';

	cell.innerHTML = "Enable";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '110px';
    cell.className="s0";

	cell.innerHTML = "Port";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '110px';
    cell.className="s0";

	cell.innerHTML = "Static IP";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '110px';
    cell.className="s0";

	cell.innerHTML = "Netmask";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '85px';
    cell.className="s0";

	cell.innerHTML = "Lease Time";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '110px';
    cell.className="s0";

	cell.innerHTML = "Default Gateway";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '110px';
    cell.className="s0";

	cell.innerHTML = "DNS Server 1";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '110px';
    cell.className="s0";

	cell.innerHTML = "DNS Server 2";
	row.appendChild(cell);

    cell = document.createElement("th");
	cell.width = '110px';
    cell.className="s0";

	cell.innerHTML = "NTP Server";
	row.appendChild(cell);




	row.align="center";


}

</script>
</head>
<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(Port_Based_IP_Assignment)</script></h1>
<fieldset style="width:900px">
<form id=myForm name=myForm method="POST">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="SRV_DHCP_PIP_tmp" id="SRV_DHCP_PIP_tmp" value="" >
<input type="hidden" id=idx name="q_idx">
<DIV style="width:900px;">
<table cellpadding=1 cellspacing=1>
 <tr align="left">
  <td width=40px><script language="JavaScript">doc(Enable_)</script></td>
  <td><input type="checkbox" id="enable" value=1></td>
 </tr>
 <tr align="left">
  <td><script>doc(Port)</script></td>
  <td><input type="text" id="port" size=10 maxlength=10></td>
 </tr>
 <tr align="left">
  <td><script>doc(Static_IP)</script></td>
  <td><input type="text" id="hostip" size=15 maxlength=15></td>
 </tr> 
 <tr align="left">
  <td><script language="JavaScript">doc(Netmask)</script></td>
  <td><input type="text" id="dhcp_netmask" size=15 maxlength=15></td>
 </tr> 
 <tr align="left">
  <td><script language="JavaScript">doc(Lease_Time)</script></td>
  <td nowrap><input type="text" id="dhcp_lease" size="5" maxlength="5">&nbsp;(minutes)</td>
 </tr> 
 <tr align="left"> 
  <td><script language="JavaScript">doc(Default_Gateway)</script></td>
  <td nowrap><input type="text" id="dhcp_gateway" size="15" maxlength="15"></td> 
 </tr>
 <tr align="left"> 
  <td><script language="JavaScript">doc(DNS_Server_1)</script></td>
  <td nowrap><input type="text" id="dhcp_dns1" size="15" maxlength="15"></td> 
  <td><script language="JavaScript">doc(DNS_Server_2)</script></td>
  <td nowrap><input type="text" id="dhcp_dns2" size="15" maxlength="15"></td> 
 </tr>
 <tr align="left"> 
  <td><script language="JavaScript">doc(NTP_Server)</script></td>
  <td nowrap><input type="text" id="dhcp_ntp" size="15" maxlength="15"></td> 
 </tr>
</table>

<p><table align=left border=0>
 <tr>
  <td width="400px" style="text-align:left;"><script>fnbnBID(addb, 'onClick=Add(this.form)', 'btnA')</script>
  <script>fnbnBID(delb, 'onClick=Del(this.form)', 'btnD')</script>
  <script>fnbnBID(modb, 'onClick=Modify(this.form)', 'btnM')</script></td>
  <td width="300px" style="text-align:left;"><script>fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
  <td width="150px"></td>
</table></p>
<table align=left border=0>
<tr style="height:50px"></tr>
</table>
</form>
</DIV>
<table>
 <tr class=r0>
  <td  width = "200px"><script language="JavaScript">doc(Static_IP_Pool)</script></td>
  <td id = "totalpolicy"></td></tr>
 </table>  
<table cellpadding=1 cellspacing=2 width="900px" id="show_available_table">   
 <tr align="center">
  <th width=45px  class="s0"><script>doc(Enable_)</script></th>
  <th width=110px class="s0"><script>doc(Port)</script></th>
  <th width=110px class="s0"><script>doc(Static_IP)</script></th>
  <th width=110px class="s0"><script>doc(Netmask)</script></th> 
  <th width=85px  class="s0"><script>doc(Lease_Time)</script></th>
  <th width=110px class="s0"><script>doc(Default_Gateway)</script></th>
  <th width=110px class="s0"><script>doc(DNS_Server_1)</script></th>
  <th width=110px class="s0"><script>doc(DNS_Server_2)</script></th>
  <th width=110px class="s0"><script>doc(NTP_Server)</script></th>
 </tr>
<script>ShowList1('tri')</script>

</table>

</fieldset>
</body></html>
