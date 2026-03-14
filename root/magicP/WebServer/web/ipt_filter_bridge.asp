<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
var ModelVLAN = <% net_Web_GetModel_VLAN_WriteValue(); %>;
checkCookie();

if (!debug) {
	var wdata = [
	{ctl:11100, idx:0,  stat:'0', ifs1:'wan1', ifs2:'wan2', prot:'2', ip1:'1.168.168.168', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'', port1:'25535', port2:'', port3:'', port4:'', port5:'', port6:'', mac:'', targets:'ACCEPT'},
	{ctl:20202, idx:1, 	stat:'1', ifs1:'wan2', ifs2:'wan1', prot:'2', ip1:'', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'', port1:'', port2:'78', port3:'150', port4:'', port5:'10', port6:'11', mac:'F1:F2:F3:F4:F5:F6', targets:'ACCEPT'},
	{ctl:12222, idx:2,  stat:'0', ifs1:'wan1', ifs2:'lan', prot:'3', ip1:'', ip2:'192.168.168.168', ip3:'192.168.138.254', ip4:'', ip5:'10.1.0.1', ip6:'10.1.0.254', port1:'', port2:'21', port3:'80', port4:'', port5:'8', port6:'9', mac:'', targets:'ACCEPT'}
	];
	var CheckConfirm = [ { stat1:1, stat2:1, timer:100 } ];
}
else{
	var wdata = [ <% net_Web_IPT_FILTER_WriteValue(); %> ];
	var malformated_data = <% net_Web_MalFormated_WriteValue(); %>;
	var CheckConfirm = [ <% net_Web_Confirm_WriteValue(); %> ];
}

if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){
	var ifs1 = [ <% net_Web_Filter_IFS_WriteValue(); %> ];
	var ifs2 = [ <% net_Web_Filter_IFS_WriteValue(); %> ];
}
else{
	var ifs1 = [ <% net_Web_IFS_WriteInteger_Have_All_Value(); %> ];
	var ifs2 = [ <% net_Web_IFS_WriteInteger_Have_All_Value(); %> ];
}

var addb = 'Add';
var moveb = 'Move';
var detectb = 'Policy Check';

var entryNUM=0;
var initEntry;

<!--#include file="cvserver_data"-->


var filter_chain = [ {value:'INPUT', text:'INPUT'}, {value:'OUTPUT', text:'OUTPUT'}, {value:'FORWARD', text:'FORWARD'}
]

var filter_io = [ {value:'i', text:'INPUT'}, {value:'o', text:'OUTPUT'}
]

var filter_level = [{value:'0', text:'<0> Emergency'},
					{value:'1', text:'<1> Alert'},
					{value:'2', text:'<2> Critical'},
					{value:'3', text:'<3> Error'},
					{value:'4', text:'<4> Warning'},
					{value:'5', text:'<5> Notice'},
					{value:'6', text:'<6> Informational'},
					{value:'7', text:'<7> Debug'}]

var malformed_level = [ {value:'0', text:'<0> Emergency'},
					{value:'1', text:'<1> Alert'},
					{value:'2', text:'<2> Critical'},
					{value:'3', text:'<3> Error'},
					{value:'4', text:'<4> Warning'},
					{value:'5', text:'<5> Notice'},
					{value:'6', text:'<6> Informational'},
					{value:'7', text:'<7> Debug'}]

var wtype = { ctl:4, idx:4, stat:3, ifs1:2, ifs2:2, prot:2, ip1:5, ip2:5, ip3:5, ip4:5, ip5:5, ip6:5, port1:4, port2:4, port3:4, port4:4, port5:4, port6:4, mac:7, targets:2, logLevel:2, logFlash:3, logSyslog:3, logTrap:3 };

var IDX_ALL		= 0;
var IDX_TCP		= 1;
var IDX_UDP		= 2;
var IDX_ICMP	= 3;

var prot = [
	{ value:'1', text:'All' },
	{ value:'2', text:'TCP' },	
	{ value:'3', text:'UDP' },	
	{ value:'4', text:'ICMP' },
	{ value:'5', text:'EtherNet/IP I/O (TCP)' },
	{ value:'6', text:'EtherNet/IP I/O (UDP)' },
	{ value:'7', text:'EtherNet/IP messaging (TCP)' },
	{ value:'8', text:'EtherNet/IP messaging (UDP)' },
	{ value:'9', text:'FF Annunciation (TCP)' },
	{ value:'10', text:'FF Annunciation (UDP)' },
	{ value:'11', text:'FF Fieldbus Message Specification (TCP)' },
	{ value:'12', text:'FF Fieldbus Message Specification (UDP)' }, 
	{ value:'13', text:'FF System Management (TCP)' }, 
	{ value:'14', text:'FF System Management (UDP)' },
	{ value:'15', text:'FF LAN Redundancy Port (TCP)' },
	{ value:'16', text:'FF LAN Redundancy Port (UDP)' },
	{ value:'17', text:'LonWorks (TCP)' },
	{ value:'18', text:'LonWorks (UDP)' },
	{ value:'19', text:'LonWorks2 (TCP)' },
	{ value:'20', text:'LonWorks2 (UDP)' },
	{ value:'21', text:'Modbus TCP/IP (TCP)' },
	{ value:'22', text:'Modbus TCP/IP (UDP)' },
	{ value:'23', text:'PROFInet RT Unicast (TCP)' },
	{ value:'24', text:'PROFInet RT Unicast (UDP)' },
	{ value:'25', text:'PROFInet RT Multicast (TCP)' },
	{ value:'26', text:'PROFInet RT Multicast (UDP)' },
	{ value:'27', text:'PROFInet Context Manager (TCP)' },
	{ value:'28', text:'PROFInet Context Manager (UDP)' },
	{ value:'29', text:'IEC 60870-5-104 process control over IP (TCP)' },
	{ value:'30', text:'IEC 60870-5-104 process control over IP (UDP)' },
	{ value:'31', text:'IPsec NAT-Traversal (TCP)' },
	{ value:'32', text:'IPsec NAT-Traversal (UDP)' },
	{ value:'33', text:'DNP3 (TCP)' },
	{ value:'34', text:'DNP3 (UDP)' },
	{ value:'35', text:'FTP-data (TCP)' },
	{ value:'36', text:'FTP-data (UDP)' },
	{ value:'37', text:'FTP-control (TCP)' },
	{ value:'38', text:'FTP-control (UDP)' },
	{ value:'39', text:'SSH (TCP)' },
	{ value:'40', text:'SSH (UDP)' },
	{ value:'41', text:'Telnet (TCP)' },
	{ value:'42', text:'Telnet (UDP)' },
	{ value:'43', text:'HTTP (TCP)' },
	{ value:'44', text:'HTTP (UDP)' },
	{ value:'45', text:'IPSec (TCP)' },
	{ value:'46', text:'IPSec (UDP)' },
	{ value:'47', text:'L2TP (TCP)' },
	{ value:'48', text:'L2TP (UDP)' },
	{ value:'49', text:'PPTP (TCP)' },
	{ value:'50', text:'PPTP (UDP)' },
	{ value:'51', text:'RADIUS (TCP)' },
	{ value:'52', text:'RADIUS (UDP)' },
	{ value:'53', text:'RADIUS Accounting (TCP)' },
	{ value:'54', text:'RADIUS Accounting (UDP)' },
	{ value:'55', text:'Ethercat (TCP)' },
	{ value:'56', text:'Ethercat (UDP)' }
];

var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

var targets = [
	{ value:'ACCEPT', text:'ACCEPT' },	{ value:'DROP', text:'DROP' }  
];
var max_total;

function Total_Policy()
{
	document.getElementById("totalcnt").innerHTML = '('+wdata.length +'/' +max_total+')';
}

var myForm;
function fnInit(row) {
	if(ProjectModel == MODEL_EDR_G903){
		max_total = 512;
	}
	else{
		max_total = 256;
	}
	Total_Policy();
	myForm = document.getElementById('myForm');
	if(wdata.length != 0){
		initEntry=1;
		EditRow1(row, 0);
	}
	else{
		initEntry=0;
		funcSel(0);
		document.getElementById("tSel").selectedIndex=0;
		
		document.getElementById("src_port").disabled="true";
		document.getElementById("SrcPortSel").disabled="true";
		document.getElementById("src_port_single_config").disabled="true";
		document.getElementById("src_port_range_config").disabled="true";
		document.getElementById("dst_port").disabled="true";
		document.getElementById("DstPortSel").disabled="true";
		document.getElementById("dst_port_single_config").disabled="true";
		document.getElementById("dst_port_range_config").disabled="true";
	}

	myForm.logEnable.value = malformated_data.logEnable;
	
	myForm.malEnable.value = malformated_data.malEnable;

    myForm.malLogLevel.value = malformated_data.malLogLevel;

	if(malformated_data.malLogFlash == 1)
		document.getElementById("malLogFlash").checked = true;
	else
		document.getElementById("malLogFlash").checked = false;
	
	if(malformated_data.malLogSyslog == 1)
		document.getElementById("malLogSyslog").checked = true;
	else
		document.getElementById("malLogSyslog").checked = false;
	
	if(malformated_data.malLogTrap == 1)
		document.getElementById("malLogTrap").checked = true;
	else
		document.getElementById("malLogTrap").checked = false;
}


function ShowList(name) {

	with (document) {
		for (var i in wdata) {
			write('<tr id=' +name+i+ ' onClick=EditRow(' +i+ ') style="cursor:'+ptrcursor+'">');
			write('<td width=60px>'+ fnGetSelText(wdata[i].ifs, ifs) +'</td>');
			write('<td width=80px>'+ fnGetSelText(wdata[i].filter_io, filter_io) +'</td>');
			write('<td width=60px>'+ fnGetSelText(wdata[i].prot, prot) +'</td>');
			write('<td width=200px>'+ wdata[i].ip1+ '~' +wdata[i].ip2 +'</td>');
			write('<td width=120px>'+ wdata[i].port1+ '~' +wdata[i].port2 +'</td>');
			write('<td width=120px>'+ wdata[i].mac +'</td>');
			write('<td>'+ fnGetSelText(wdata[i].targets, targets) +'</td></tr>');
		}
	}
}

function EditRow(row) 
{
//	alert(row.rowIndex);
	fnLoadForm(myForm, wdata[row], wtype);
	ChgColor('tri', wdata.length, row);	
	
}

function ShowList1(name) {
	
	table = document.getElementById("show_available_table");
	var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0; i<wdata.length; i++)
	{
		addRow(i);		
	}
	ChgColor('tri', wdata.length, 0);		
}

function EditRow1(row, indicate) 
{
	
	var rowidx
//	fnShowProp('aaaaa'+i, row);
	if(initEntry==1 || indicate==1){
		rowidx = row;
		initEntry=0;
	}
	else{
		rowidx = row.rowIndex-1;
	}

	/* to temp malformated. if without this temp, myForm.MailFormed.checked will be set to zero after fnLoadForm.*/
	var logEnable_temp = myForm.logEnable.checked;
	var malEnable_temp = myForm.malEnable.selectedIndex;
	var malLogLevel_temp = myForm.malLogLevel.selectedIndex;
	var malLogFlash_temp = myForm.malLogFlash.checked;
	var malLogSyslog_temp = myForm.malLogSyslog.checked;
	var malLogTrap_temp = myForm.malLogTrap.checked;
	
	fnLoadForm(myForm, wdata[rowidx], wtype);

	myForm.logEnable.checked = logEnable_temp; 
	myForm.malEnable.selectedIndex = malEnable_temp; 
	myForm.malLogLevel.selectedIndex = malLogLevel_temp; 
	myForm.malLogFlash.checked = malLogFlash_temp; 
	myForm.malLogSyslog.checked = malLogSyslog_temp; 
	myForm.malLogTrap.checked = malLogTrap_temp; 
	
/*	
	if(wdata[rowidx].ip3!="")
		document.getElementById("iprange1").value=getiprange(wdata[rowidx].ip2, wdata[rowidx].ip3);
	if(wdata[rowidx].ip6!="")
		document.getElementById("iprange2").value=getiprange(wdata[rowidx].ip5, wdata[rowidx].ip6);
*/
	ChgColor('tri', wdata.length, rowidx);
	entryNUM = rowidx;
	
	if(((wdata[rowidx].ctl-(wdata[rowidx].ctl%10000))/10000)==2){
		funcSel(1);
		document.getElementById("tSel").selectedIndex=1;

		document.getElementById("mac_config_enable_select").selectedIndex=1;
		document.getElementById("mac").disabled="";
	}
	else{
		funcSel(0);
		document.getElementById("tSel").selectedIndex=0;

		if(wdata[rowidx].mac == ""){
			document.getElementById("mac_config_enable_select").selectedIndex=0;
			document.getElementById("mac").disabled="true";
		}
		else{
			document.getElementById("mac_config_enable_select").selectedIndex=1;
			document.getElementById("mac").disabled="";
		}
	}

	if(((wdata[rowidx].ctl%10000-wdata[rowidx].ctl%1000)/1000)==0){
		funcSrcIPSel(0);
		document.getElementById("SrcIPSel").selectedIndex=0;
	}
	else if(((wdata[rowidx].ctl%10000-wdata[rowidx].ctl%1000)/1000)==1){
		funcSrcIPSel(1);
		document.getElementById("SrcIPSel").selectedIndex=1;
	}
	else{
		funcSrcIPSel(2);
		document.getElementById("SrcIPSel").selectedIndex=2;
	}
	
	
	if(((wdata[rowidx].ctl%1000-wdata[rowidx].ctl%100)/100)==0){
		document.getElementById("SrcPortSel").selectedIndex=0;
		funcSrcPortSel(0);
	}
	else if(((wdata[rowidx].ctl%1000-wdata[rowidx].ctl%100)/100)==1){
		document.getElementById("SrcPortSel").selectedIndex=1;
		funcSrcPortSel(1);
	}
	else{	
		document.getElementById("SrcPortSel").selectedIndex=2;
		funcSrcPortSel(2);
	}

	if(((wdata[rowidx].ctl%100-wdata[rowidx].ctl%10)/10)==0){
		funcDstIPSel(0);
		document.getElementById("DstIPSel").selectedIndex=0;
		
	}
	else if(((wdata[rowidx].ctl%100-wdata[rowidx].ctl%10)/10)==1){
		document.getElementById("DstIPSel").selectedIndex=1;
		funcDstIPSel(1);
	}
	else{
		document.getElementById("DstIPSel").selectedIndex=2;
		funcDstIPSel(2);
	}
		
	if((wdata[rowidx].ctl%10)==0){	
		document.getElementById("DstPortSel").selectedIndex=0;
		funcDstPortSel(0);
	}
	else if((wdata[rowidx].ctl%10)==1){	
		document.getElementById("DstPortSel").selectedIndex=1;
		funcDstPortSel(1);
	}
	else{	
		document.getElementById("DstPortSel").selectedIndex=2;
		funcDstPortSel(2);
	}

}

function ipadd(initip, iprange)
{
	//var x = "192.168.127";
	//x += "." + 25;
	var x="";
	var ipclass="";
	var ipnum=0;
	var addedip="";
	var j,k=0;
	for(j=0;j<initip.length; j++){
		if(k==3)
			x += initip.charAt(j);
		else{
			ipclass += initip.charAt(j);
			if(initip.charAt(j)==".")
				k++;
		}
	}
	ipnum=parseInt(x)+parseInt(iprange);
	addedip = ipclass + (parseInt(x)+parseInt(iprange));
	return addedip;
}

function getiprange(ipstart, ipend)
{
	var j, k=0;
	var ipnum1="";
	var ipnum2="";
	var ipscope=0;
	for(j=0;j<ipstart.length; j++){
		if(k==3)
			ipnum1 += ipstart.charAt(j);
		else{
			if(ipstart.charAt(j)==".")
				k++;
		}
	}
	k=0;
	for(j=0;j<ipend.length; j++){
		if(k==3)
			ipnum2 += ipend.charAt(j);
		else{
			if(ipend.charAt(j)==".")
				k++;
		}
	}
	ipscope = parseInt(ipnum2)-parseInt(ipnum1);
//	alert(ipscope);
	return ipscope;
}

function split_string_by_br(string, limit)
{
	var string_split;
	var s = string;

	if(s.length > 0){
		if(limit == 45)
			string_split = s.match(/.{1,45}/g).join('<br>');
		else
			string_split = s.match(/.{1,16}/g).join('<br>');

		return string_split;
	}
	
	return string;
}

function addRow(i)
{
	var ifs_name;
	var protocol_name;
	var log_detail;
	
	table = document.getElementById('show_available_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);
	
	cell = document.createElement("td");
	if(wdata[i].stat==1)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.innerHTML = i+1;
	row.appendChild(cell);

if((ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902) && ModelVLAN == RETURN_TRUE){
		
	cell = document.createElement("td");
	ifs_name = wdata[i].ifs1;
	cell.innerHTML = split_string_by_br(ifs_name, 16);
	row.appendChild(cell);

	cell = document.createElement("td");
	ifs_name = wdata[i].ifs2;
	cell.innerHTML = split_string_by_br(ifs_name, 16);
	row.appendChild(cell);
}
else{
	cell = document.createElement("td");
	ifs_name = fnGetSelText(wdata[i].ifs1, ifs1);
	cell.innerHTML = split_string_by_br(ifs_name, 16);
	row.appendChild(cell);

	cell = document.createElement("td");
	ifs_name = fnGetSelText(wdata[i].ifs2, ifs2);
	cell.innerHTML = split_string_by_br(ifs_name, 16);
	row.appendChild(cell);
}

/*
	cell = document.createElement("td");
	cell.width="60";
	if((wdata[i].ctl/10000)==2)
		cell.innerHTML = "--";
	else
		cell.innerHTML = fnGetSelText(wdata[i].prot, prot);
	row.appendChild(cell);	
*/	
	cell = document.createElement("td");
	protocol_name = fnGetSelText(wdata[i].prot, prot);
	cell.innerHTML = split_string_by_br(protocol_name, 16);
	row.appendChild(cell);	
	
	cell = document.createElement("td");
	if(((wdata[i].ctl-(wdata[i].ctl%10000))/10000)!=2){
		if(((wdata[i].ctl%10000-wdata[i].ctl%1000)/1000)==0)	
			cell.innerHTML = "All";
		else if(((wdata[i].ctl%10000-wdata[i].ctl%1000)/1000)==1)		
			cell.innerHTML = wdata[i].ip1;
		else
			cell.innerHTML = wdata[i].ip2+ '</br>' + '~' +wdata[i].ip3;
	}
	else
		cell.innerHTML = "--";
	row.appendChild(cell);

	cell = document.createElement("td");
	if(((wdata[i].ctl-(wdata[i].ctl%10000))/10000)==2)
		cell.innerHTML = wdata[i].mac;
	else{
		if(wdata[i].mac == ""){
			cell.innerHTML = "--"
		}
		else{
			cell.innerHTML = wdata[i].mac;
		}
	}
	row.appendChild(cell);

	cell = document.createElement("td");
	if(((wdata[i].ctl%1000-wdata[i].ctl%100)/100)==0)
		cell.innerHTML = "All";
	else if(((wdata[i].ctl%1000-wdata[i].ctl%100)/100)==1)		
		cell.innerHTML = wdata[i].port1;	
	else
		cell.innerHTML = wdata[i].port2+ '</br>' + '~' +wdata[i].port3;
	
	row.appendChild(cell);

	cell = document.createElement("td");
	if(((wdata[i].ctl-(wdata[i].ctl%10000))/10000)!=2){
		if(((wdata[i].ctl%100-wdata[i].ctl%10)/10)==0)	
			cell.innerHTML = "All";
		else if(((wdata[i].ctl%100-wdata[i].ctl%10)/10)==1)
			cell.innerHTML = wdata[i].ip4;
		else
			cell.innerHTML = wdata[i].ip5+ '</br>' + '~' +wdata[i].ip6;
	}
	else
		cell.innerHTML = "--";
	row.appendChild(cell);

	cell = document.createElement("td");
	
	if((wdata[i].ctl%10)==0)
		cell.innerHTML = "All";
	else if((wdata[i].ctl%10)==1)
		cell.innerHTML = wdata[i].port4;	
	else 
		cell.innerHTML = wdata[i].port5+ '</br>' + '~' +wdata[i].port6;
	
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].targets, targets );
	row.appendChild(cell);

	cell = document.createElement("td");

	if(wdata[i].logFlash==1 || wdata[i].logSyslog==1 || wdata[i].logTrap==1){
		log_detail = "Enable /<br>"+fnGetSelText(wdata[i].logLevel, filter_level );
	}
	else{
		log_detail = "Disable /<br>"+fnGetSelText(wdata[i].logLevel, filter_level );
	}
	cell.innerHTML = log_detail;
	row.appendChild(cell);

	cell = document.createElement("td");	
	cell.innerHTML = split_string_by_br(wdata[i].name, 45);
	row.appendChild(cell);
	
	row.style.Color = "black";
	var j=i+1;
//	row.onclick=EditRow(i);
//	row.class="r2";
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this, 0)};
	row.style.cursor=ptrcursor;
	row.align="center";
//	fnShowProp('aaaaa'+i, row);

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

function FilterLikeCheckFormat(form)
{
	var error=0;
	
	if(form.name.value != "" && isSymbol_static_route(form.name, Name_)) {
		error=1;
	}
		
	if(form.tSel.value=='ipfilter'){
		if(form.SrcIPSel.value=='single'){
			if(!IpAddrIsOK_allow0and255(form.ip1, 'Source IP')){
				error=1;
			}
		}
		else if(form.SrcIPSel.value=='range'){
			if(!IpAddrIsOK_allow0and255(form.ip2, 'Source IP Range (initial)')){
				error=1;
			}
			if(!IpAddrIsOK_allow0and255(form.ip3, 'Source IP Range (end)')){
				error=1;
			}
			if(!ipRange(form.ip2, form.ip3, 'Source')){
				error=1;
			}
		}
		
		if(form.DstIPSel.value=='single'){
			if(!IpAddrIsOK_allow0and255(form.ip4, 'Destination IP')){
				error=1;
			}
		}
		else if(form.DstIPSel.value=='range'){
			if(!IpAddrIsOK_allow0and255(form.ip5, 'Destination IP Range (initial)')){
				error=1;
			}
			if(!IpAddrIsOK_allow0and255(form.ip6, 'Destination IP Range (end)')){
				error=1;
			}
			if(!ipRange(form.ip5, form.ip6, 'Destination')){
				error=1;
			}
		}
	}
	else{
		if(!MacAddrIsOK(form.mac, 'Source MAC Address')){
			error=1;
		}
	}
	if(form.prot.value==2 || form.prot.value==3){
		if(form.SrcPortSel.value=='single'){
			if(!isPort(form.port1, 'Source Port')){
				error=1;
			}
		}
		else if(form.SrcPortSel.value=='range'){
			if(!isPort(form.port2, 'Source Port Range (initial)')){
				error=1;
			}
			if(!isPort(form.port3, 'Source Port Range (end)')){
				error=1;
			}
			if(!portRange(form.port2, form.port3, 'Source')){
				error=1;
			}
		}
		if(form.DstPortSel.value=='single'){
			if(!isPort(form.port4, 'Destination Port')){
				error=1;
			}
		}
		else if(form.DstPortSel.value=='range'){
			if(!isPort(form.port5, 'Destination Port (initial)')){
				error=1;
			}
			if(!isPort(form.port6, 'Destination Port (end)')){
				error=1;
			}
			if(!portRange(form.port5, form.port6, 'Destination')){
				error=1;
			}
		}
	}
	return error;
}

function Add(form)
{
	if(FilterLikeCheckFormat(form)==1)
		return;

	
	var idx=prompt("Add to index ", wdata.length+1);

	if(IndexRangeAndInputRange(idx, wdata, 1, 256)==-1)
		return;
		
	idx=idx-1;
	
	if(idx!=-1){
		if((wdata.length+1)<=max_total){
			var arrayLen = wdata.length;

			wdata[arrayLen]=new Array;

			for(i=arrayLen-1; i>=idx; i--)
			{
				wdata[i+1].ctl=wdata[i].ctl;
				wdata[i+1].idx=i+1;
				wdata[i+1].stat=wdata[i].stat;
				wdata[i+1].ifs1=wdata[i].ifs1;
				wdata[i+1].ifs2=wdata[i].ifs2;
				wdata[i+1].prot=wdata[i].prot;
				wdata[i+1].ip1=wdata[i].ip1;
				wdata[i+1].ip2=wdata[i].ip2;
				wdata[i+1].ip3=wdata[i].ip3;
				wdata[i+1].ip4=wdata[i].ip4;
				wdata[i+1].ip5=wdata[i].ip5;
				wdata[i+1].ip6=wdata[i].ip6;
				wdata[i+1].port1=wdata[i].port1;
				wdata[i+1].port2=wdata[i].port2;
				wdata[i+1].port3=wdata[i].port3;
				wdata[i+1].port4=wdata[i].port4;
				wdata[i+1].port5=wdata[i].port5;
				wdata[i+1].port6=wdata[i].port6;
				wdata[i+1].mac=wdata[i].mac;
				wdata[i+1].targets=wdata[i].targets;
				wdata[i+1].logLevel=wdata[i].logLevel;
				wdata[i+1].logFlash=wdata[i].logFlash;
				wdata[i+1].logSyslog=wdata[i].logSyslog;
				wdata[i+1].logTrap=wdata[i].logTrap;
				wdata[i+1].name=wdata[i].name;
			}
			
			//wdata[idx].idx = arrayLen-1;
			wdata[idx].idx = idx;
			
			if(form.stat.checked==true)
				wdata[idx].stat=1;
			else
				wdata[idx].stat=0;

			wdata[idx].ctl=0;
			wdata[idx].mac="";
			wdata[idx].prot=form.prot.value;
			wdata[idx].ip1="";
			wdata[idx].ip2=""; 	
			wdata[idx].ip3="";
			wdata[idx].ip4="";
			wdata[idx].ip5="";
			wdata[idx].ip6="";
			wdata[idx].port1="";
			wdata[idx].port2="";
			wdata[idx].port3="";
			wdata[idx].port4="";
			wdata[idx].port5="";
			wdata[idx].port6="";


			if(document.getElementById("prot").selectedIndex==0 || document.getElementById("prot").selectedIndex==3){
			}
			else{
				if(document.getElementById("DstPortSel").selectedIndex==1){
				wdata[idx].ctl += 1;
				wdata[idx].port4 = form.port4.value;
				}
				else if(document.getElementById("DstPortSel").selectedIndex==2){
					wdata[idx].ctl += 2;
					wdata[idx].port5 = form.port5.value;
					wdata[idx].port6 = form.port6.value;
				}
				else{}
			}
				
			

			if(document.getElementById("DstIPSel").selectedIndex==1){
				wdata[idx].ctl += 10;
				wdata[idx].ip4 = form.ip4.value;
			}
			else if(document.getElementById("DstIPSel").selectedIndex==2){
				wdata[idx].ctl += 20;
				wdata[idx].ip5 = form.ip5.value;
				//wdata[idx].ip6 = ipadd(wdata[arrayLen].ip5, form.iprange2.value);
				wdata[idx].ip6 = form.ip6.value;
			}
			else{}

			if(document.getElementById("prot").selectedIndex==0 || document.getElementById("prot").selectedIndex==3){
			}
			else{
				if(document.getElementById("SrcPortSel").selectedIndex==1){
					wdata[idx].ctl += 100;
					wdata[idx].port1 = form.port1.value;
				}
				else if(document.getElementById("SrcPortSel").selectedIndex==2){
					wdata[idx].ctl += 200;
					wdata[idx].port2 = form.port2.value;
					wdata[idx].port3 = form.port3.value;
				}
				else{}
			}

			if(document.getElementById("SrcIPSel").selectedIndex==1){
				wdata[idx].ctl += 1000;
				wdata[idx].ip1 = form.ip1.value;
			}
			else if(document.getElementById("SrcIPSel").selectedIndex==2){
				wdata[idx].ctl += 2000;
				wdata[idx].ip2 = form.ip2.value;
				//wdata[idx].ip3 = ipadd(wdata[arrayLen].ip2, form.iprange1.value);
				wdata[idx].ip3 = form.ip3.value;
			}
			else{}

			if(document.getElementById("tSel").selectedIndex==1){
				wdata[idx].ctl+=20000;
				wdata[idx].ip1="";
				wdata[idx].ip2="";
				wdata[idx].ip3="";
				wdata[idx].ip4="";
				wdata[idx].ip5="";
				wdata[idx].ip6="";
			}
			else{
				wdata[idx].ctl += 10000;
			}

			form.mac.value=mac_format(form.mac.value);
			wdata[idx].mac=form.mac.value;
				
			wdata[idx].prot=form.prot.value;
			wdata[idx].ifs1=form.ifs1.value;
			wdata[idx].ifs2=form.ifs2.value;
			wdata[idx].targets=form.targets.value;

			wdata[idx].logLevel=form.logLevel.value;

			if(form.logFlash.checked==true)
				wdata[idx].logFlash=1;
			else
				wdata[idx].logFlash=0;
			
			if(form.logSyslog.checked==true)
				wdata[idx].logSyslog=1;
			else
				wdata[idx].logSyslog=0;

			if(form.logTrap.checked==true)
				wdata[idx].logTrap=1;
			else
				wdata[idx].logTrap=0;

			wdata[idx].name = form.name.value;
			
			table = document.getElementById("show_available_table");
			var row1 = document.getElementById("tri1");
			//fnShowProp('bbbb', row1);
			rows = table.getElementsByTagName("tr");
			//delete added the table members
			if(rows.length > 1)
			{
				for(i=rows.length-1 ;i>0;i--)
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
			ChgColor('tri', wdata.length, idx);	
			entryNUM = idx;
		}
		else{
			alert("over"+max_total+"rules");
		}
	}
	Total_Policy();
}

function Move(form)
{
	if(FilterLikeCheckFormat(form)==1)
		return;

	var idx=prompt("Move to index : ", entryNUM+1);

	if(MoveIndexRangeAndInputRange(idx, wdata, 1, 256)==-1)
		return;
	
	idx=idx-1;
	
	var i;

	if(idx > wdata[entryNUM].idx)
	{
		for(i=wdata[entryNUM].idx+1; i<=idx; i++)
		{	
			wdata[i-1].ctl=wdata[i].ctl;		
			wdata[i-1].idx=i-1;
			wdata[i-1].stat=wdata[i].stat;
			wdata[i-1].ifs1=wdata[i].ifs1;
			wdata[i-1].ifs2=wdata[i].ifs2;
			wdata[i-1].prot=wdata[i].prot;
			wdata[i-1].ip1=wdata[i].ip1;
			wdata[i-1].ip2=wdata[i].ip2;
			wdata[i-1].ip3=wdata[i].ip3;
			wdata[i-1].ip4=wdata[i].ip4;
			wdata[i-1].ip5=wdata[i].ip5;
			wdata[i-1].ip6=wdata[i].ip6;
			wdata[i-1].port1=wdata[i].port1;
			wdata[i-1].port2=wdata[i].port2;
			wdata[i-1].port3=wdata[i].port3;
			wdata[i-1].port4=wdata[i].port4;
			wdata[i-1].port5=wdata[i].port5;
			wdata[i-1].port6=wdata[i].port6;
			wdata[i-1].mac=wdata[i].mac;
			wdata[i-1].targets=wdata[i].targets;
			wdata[i-1].logLevel=wdata[i].logLevel;
			wdata[i-1].logFlash=wdata[i].logFlash;
			wdata[i-1].logSyslog=wdata[i].logSyslog;
			wdata[i-1].logTrap=wdata[i].logTrap;
			wdata[i-1].name=wdata[i].name;
		}
	}
	else
	{	
		for(i=wdata[entryNUM].idx-1; i>=idx; i--)
		{
			wdata[i+1].ctl=wdata[i].ctl;
			wdata[i+1].idx=i+1;
			wdata[i+1].stat=wdata[i].stat;
			wdata[i+1].ifs1=wdata[i].ifs1;
			wdata[i+1].ifs2=wdata[i].ifs2;
			wdata[i+1].prot=wdata[i].prot;
			wdata[i+1].ip1=wdata[i].ip1;
			wdata[i+1].ip2=wdata[i].ip2;
			wdata[i+1].ip3=wdata[i].ip3;
			wdata[i+1].ip4=wdata[i].ip4;
			wdata[i+1].ip5=wdata[i].ip5;
			wdata[i+1].ip6=wdata[i].ip6;
			wdata[i+1].port1=wdata[i].port1;
			wdata[i+1].port2=wdata[i].port2;
			wdata[i+1].port3=wdata[i].port3;
			wdata[i+1].port4=wdata[i].port4;
			wdata[i+1].port5=wdata[i].port5;
			wdata[i+1].port6=wdata[i].port6;
			wdata[i+1].mac=wdata[i].mac;
			wdata[i+1].targets=wdata[i].targets;
			wdata[i+1].logLevel=wdata[i].logLevel;
			wdata[i+1].logFlash=wdata[i].logFlash;
			wdata[i+1].logSyslog=wdata[i].logSyslog;
			wdata[i+1].logTrap=wdata[i].logTrap;
			wdata[i+1].name=wdata[i].name;
		}
	}

	wdata[idx].idx=idx;
	if(form.stat.checked==true)
		wdata[idx].stat=1;
	else
		wdata[idx].stat=0;

	wdata[idx].ctl=0;
	wdata[idx].mac="";
	wdata[idx].prot=form.prot.value;
	wdata[idx].ip1="";
	wdata[idx].ip2=""; 	
	wdata[idx].ip3="";
	wdata[idx].ip4="";
	wdata[idx].ip5="";
	wdata[idx].ip6="";
	wdata[idx].port1="";
	wdata[idx].port2="";
	wdata[idx].port3="";
	wdata[idx].port4="";
	wdata[idx].port5="";
	wdata[idx].port6="";

	if(document.getElementById("prot").selectedIndex==0 || document.getElementById("prot").selectedIndex==3){
	}
	else{
		if(document.getElementById("DstPortSel").selectedIndex==1){
		wdata[idx].ctl += 1;
		wdata[idx].port4 = form.port4.value;
		}
		else if(document.getElementById("DstPortSel").selectedIndex==2){
			wdata[idx].ctl += 2;
			wdata[idx].port5 = form.port5.value;
			wdata[idx].port6 = form.port6.value;
		}
		else{}
	}
		
	
	if(document.getElementById("tSel").selectedIndex==0){
		if(document.getElementById("DstIPSel").selectedIndex==1){
			wdata[idx].ctl += 10;
			wdata[idx].ip4 = form.ip4.value;
		}
		else if(document.getElementById("DstIPSel").selectedIndex==2){
			wdata[idx].ctl += 20;
			wdata[idx].ip5 = form.ip5.value;
			//wdata[idx].ip6 = ipadd(wdata[arrayLen].ip5, form.iprange2.value);
			wdata[idx].ip6 = form.ip6.value;
		}
		else{}
	}

	if(document.getElementById("prot").selectedIndex==0 || document.getElementById("prot").selectedIndex==3){
	}
	else{
		if(document.getElementById("SrcPortSel").selectedIndex==1){
			wdata[idx].ctl += 100;
			wdata[idx].port1 = form.port1.value;
		}
		else if(document.getElementById("SrcPortSel").selectedIndex==2){
			wdata[idx].ctl += 200;
			wdata[idx].port2 = form.port2.value;
			wdata[idx].port3 = form.port3.value;
		}
		else{}
	}

	if(document.getElementById("tSel").selectedIndex==0){
		if(document.getElementById("SrcIPSel").selectedIndex==1){
			wdata[idx].ctl += 1000;
			wdata[idx].ip1 = form.ip1.value;
		}
		else if(document.getElementById("SrcIPSel").selectedIndex==2){
			wdata[idx].ctl += 2000;
			wdata[idx].ip2 = form.ip2.value;
			//wdata[idx].ip3 = ipadd(wdata[idx].ip2, form.iprange1.value);
			wdata[idx].ip3 = form.ip3.value;
		}
		else{}
	}

	if(document.getElementById("tSel").selectedIndex==1){
		wdata[idx].ctl+=20000;
		wdata[idx].ip1="";
		wdata[idx].ip2="";
		wdata[idx].ip3="";
		wdata[idx].ip4="";
		wdata[idx].ip5="";
		wdata[idx].ip6="";
	}
	else{
		wdata[idx].ctl += 10000;
	}

	form.mac.value=mac_format(form.mac.value);
	wdata[idx].mac=form.mac.value;
	
	wdata[idx].ifs1=form.ifs1.value;
	wdata[idx].ifs2=form.ifs2.value;
	wdata[idx].prot=form.prot.value;
	wdata[idx].targets=form.targets.value;

	wdata[idx].logLevel=form.logLevel.value;

	if(form.logFlash.checked==true)
		wdata[idx].logFlash=1;
	else
		wdata[idx].logFlash=0;


	if(form.logSyslog.checked==true)
		wdata[idx].logSyslog=1;
	else
		wdata[idx].logSyslog=0;


	if(form.logTrap.checked==true)
		wdata[idx].logTrap=1;
	else
		wdata[idx].logTrap=0;

	wdata[idx].name = form.name.value;

	table = document.getElementById("show_available_table");
	var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
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
	ChgColor('tri', wdata.length, idx);	
	
	entryNUM = idx;
}

function Del()
{
	table = document.getElementById("show_available_table");
	var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	
	
	wdata.splice(entryNUM,1);
		
	table = document.getElementById("show_available_table");
	//var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
		{
			table.deleteRow(i);
		}
	}

	for(i=entryNUM; i<wdata.length; i++){
		wdata[i].idx = wdata[i].idx	- 1;
	}
	
	//re-join the array elements to the table
	for(i=0;i<wdata.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	if(wdata.length==0){
		return;
	}else if(entryNUM > wdata.length-1){
		entryNUM = wdata.length-1;
	}
	ChgColor('tri', wdata.length, entryNUM);
	EditRow1(entryNUM, 1);
}

function Modify(form)
{	
	if(FilterLikeCheckFormat(form)==1)
		return;
	
	if(form.stat.checked==true)
		wdata[entryNUM].stat=1;
	else
		wdata[entryNUM].stat=0;

	wdata[entryNUM].ctl=0;
	wdata[entryNUM].mac="";
	wdata[entryNUM].prot=form.prot.value;
	wdata[entryNUM].ip1="";
	wdata[entryNUM].ip2="";
	wdata[entryNUM].ip3="";
	wdata[entryNUM].ip4="";
	wdata[entryNUM].ip5="";
	wdata[entryNUM].ip6="";
	wdata[entryNUM].port1="";
	wdata[entryNUM].port2="";
	wdata[entryNUM].port3="";
	wdata[entryNUM].port4="";
	wdata[entryNUM].port5="";
	wdata[entryNUM].port6="";

	if(document.getElementById("prot").selectedIndex==0 || document.getElementById("prot").selectedIndex==3){
	}
	else{	
		if(document.getElementById("DstPortSel").selectedIndex==1){	
			wdata[entryNUM].ctl += 1;
			wdata[entryNUM].port4 = form.port4.value;
		}
		else if(document.getElementById("DstPortSel").selectedIndex==2){	
			wdata[entryNUM].ctl += 2;
			wdata[entryNUM].port5 = form.port5.value;
			wdata[entryNUM].port6 = form.port6.value;
		}
		else{}
	}
	
	
	

	if(document.getElementById("DstIPSel").selectedIndex==1){
		wdata[entryNUM].ctl += 10;
		wdata[entryNUM].ip4 = form.ip4.value;
	}
	else if(document.getElementById("DstIPSel").selectedIndex==2){
		wdata[entryNUM].ctl += 20;
		wdata[entryNUM].ip5 = form.ip5.value;
		//wdata[entryNUM].ip6 = ipadd(wdata[entryNUM].ip5, form.iprange2.value);
		wdata[entryNUM].ip6 = form.ip6.value;
	}
	else{}

	if(document.getElementById("prot").selectedIndex==0 || document.getElementById("prot").selectedIndex==3){
	}
	else{
		if(document.getElementById("SrcPortSel").selectedIndex==1){
			wdata[entryNUM].ctl += 100;
			wdata[entryNUM].port1 = form.port1.value;
		}
		else if(document.getElementById("SrcPortSel").selectedIndex==2){
			wdata[entryNUM].ctl += 200;
			wdata[entryNUM].port2 = form.port2.value;
			wdata[entryNUM].port3 = form.port3.value;
		}
		else{}
	}

	if(document.getElementById("SrcIPSel").selectedIndex==1){
		wdata[entryNUM].ctl += 1000;
		wdata[entryNUM].ip1 = form.ip1.value;
	}
	else if(document.getElementById("SrcIPSel").selectedIndex==2){
		wdata[entryNUM].ctl += 2000;
		wdata[entryNUM].ip2 = form.ip2.value;
		//wdata[entryNUM].ip3 = ipadd(wdata[entryNUM].ip2, form.iprange1.value);
		wdata[entryNUM].ip3 = form.ip3.value;
	}
	else{}

	if(document.getElementById("tSel").selectedIndex==1){
		form.mac.value=mac_format(form.mac.value);
		wdata[entryNUM].ctl += 20000;
		wdata[entryNUM].ip1="";
		wdata[entryNUM].ip2="";
		wdata[entryNUM].ip3="";
		wdata[entryNUM].ip4="";
		wdata[entryNUM].ip5="";
		wdata[entryNUM].ip6="";
	}
	else{
		wdata[entryNUM].ctl += 10000;
	}

	if(document.getElementById("mac_config_enable_select").selectedIndex==1){
		wdata[entryNUM].mac=form.mac.value;
	}
	
	wdata[entryNUM].prot=form.prot.value;
	wdata[entryNUM].ifs1=form.ifs1.value;
	wdata[entryNUM].ifs2=form.ifs2.value;
	wdata[entryNUM].targets=form.targets.value;

	wdata[entryNUM].logLevel=form.logLevel.value;

	if(form.logFlash.checked==true)
		wdata[entryNUM].logFlash=1;
	else
		wdata[entryNUM].logFlash=0;
	
	if(form.logSyslog.checked==true)
		wdata[entryNUM].logSyslog=1;
	else
		wdata[entryNUM].logSyslog=0;

	if(form.logTrap.checked==true)
		wdata[entryNUM].logTrap=1;
	else
		wdata[entryNUM].logTrap=0;

	wdata[entryNUM].name=form.name.value;

	table = document.getElementById("show_available_table");
	var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
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
	ChgColor('tri', wdata.length, entryNUM);
}

function Activate(form)
{	
	document.getElementById("btnU").disabled="true";
	
	var i;
	var j;

	for(i = 0 ; i < wdata.length ; i++)
	{	
		form.iptTemp.value = form.iptTemp.value + wdata[i].ctl + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].stat + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].ifs1 + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].ifs2 + "+";		
		form.iptTemp.value = form.iptTemp.value + wdata[i].prot + "+";
		
		form.iptTemp.value = form.iptTemp.value + wdata[i].ip1 + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].ip2 + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].ip3 + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].ip4 + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].ip5 + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].ip6 + "+";

		form.iptTemp.value = form.iptTemp.value + wdata[i].port1 + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].port2 + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].port3 + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].port4 + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].port5 + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].port6 + "+";

		form.iptTemp.value = form.iptTemp.value + wdata[i].mac + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].targets + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].logLevel + "+";	
		form.iptTemp.value = form.iptTemp.value + wdata[i].logFlash + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].logSyslog + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].logTrap + "+";
		form.iptTemp.value = form.iptTemp.value + wdata[i].name + "+";
	}
	form.iptTemp.value = form.iptTemp.value + CheckConfirm[0].stat1 + "+";

	form.iptTemp.value = form.iptTemp.value + myForm.logEnable.value + "+";
	
	form.iptTemp.value = form.iptTemp.value + myForm.malEnable.value + "+";	

	form.iptTemp.value = form.iptTemp.value + myForm.malLogLevel.value + "+";	

	if(form.malLogFlash.checked == true )
		form.iptTemp.value = form.iptTemp.value + "1" + "+";
	else
		form.iptTemp.value = form.iptTemp.value + "0" + "+";
	
	if(form.malLogSyslog.checked == true )
		form.iptTemp.value = form.iptTemp.value + "1" + "+";
	else
		form.iptTemp.value = form.iptTemp.value + "0" + "+";

	if(form.malLogTrap.checked == true )
		form.iptTemp.value = form.iptTemp.value + "1" + "+";
	else
		form.iptTemp.value = form.iptTemp.value + "0" + "+";
	
	form.action="/goform/net_WebIPTGetValue";
	form.submit();
}

function funcProtSel(protNUM)
{
	if(protNUM==1 || protNUM==2){
		document.getElementById("src_port").disabled="";
		document.getElementById("SrcPortSel").disabled="";
		document.getElementById("src_port_single_config").disabled="";
		document.getElementById("src_port_range_config").disabled="";
		document.getElementById("dst_port").disabled="";
		document.getElementById("DstPortSel").disabled="";
		document.getElementById("port4").disabled="";	// single dst port
		document.getElementById("dst_port_range_config").disabled="";
	}
	else{
		document.getElementById("port1").value="";
		document.getElementById("port2").value="";
		document.getElementById("port3").value="";
		document.getElementById("port4").value="";
		document.getElementById("port5").value="";
		document.getElementById("port6").value="";
		document.getElementById("src_port").disabled="true";
		document.getElementById("SrcPortSel").selectedIndex=0;
		document.getElementById("SrcPortSel").disabled="true";
		document.getElementById("src_port_single_config").disabled="true";
		document.getElementById("src_port_range_config").disabled="true";
		document.getElementById("dst_port").disabled="true";
		document.getElementById("DstPortSel").selectedIndex=1;
		document.getElementById("DstPortSel").disabled="true";
		document.getElementById("port4").disabled="true";	// single dst port
		document.getElementById("dst_port_range_config").disabled="true";
		funcDstPortSel(1);
		funcSrcPortSel(0);
		
		if(protNUM==0 || protNUM==3){
			funcDstPortSel(0);
			document.getElementById("DstPortSel").selectedIndex=0;
			document.getElementById("port4").value="";
		}
		else if(protNUM==4 || protNUM==5){
			document.getElementById("port4").value=2222;
		}
		
		else if(protNUM==6 || protNUM==7){
			document.getElementById("port4").value=44818;
		}
		
		else if(protNUM==8 || protNUM==9){
			document.getElementById("port4").value=1089;
		}
		
		else if(protNUM==10 || protNUM==11){
			document.getElementById("port4").value=1090;
		}
		
		else if(protNUM==12 || protNUM==13){
			document.getElementById("port4").value=1091;
		}
		
		else if(protNUM==14 || protNUM==15){
			document.getElementById("port4").value=3622;
		}
		
		else if(protNUM==16 || protNUM==17){
			document.getElementById("port4").value=2540;
		}
		
		else if(protNUM==18 || protNUM==19){
			document.getElementById("port4").value=2541;
		}
		
		else if(protNUM==20 || protNUM==21){
			document.getElementById("port4").value=502;
		}
		else if(protNUM==22 || protNUM==23){
			document.getElementById("port4").value=34962;
		}

		else if(protNUM==24 || protNUM==25){
			document.getElementById("port4").value=34963;
		}
		
		else if(protNUM==26 || protNUM==27){
			document.getElementById("port4").value=34964;
		}
		else if(protNUM==28 || protNUM==29){
			document.getElementById("port4").value=2404;
		}
		else if(protNUM==30 || protNUM==31){
			document.getElementById("port4").value=4500;
		}
		else if(protNUM==32 || protNUM==33){
			document.getElementById("port4").value=20000;
		}
		
		else if(protNUM==34 || protNUM==35){
			document.getElementById("port4").value=20;
		}
		else if(protNUM==36 || protNUM==37){
			document.getElementById("port4").value=21;
		}
		else if(protNUM==38 || protNUM==39){
			document.getElementById("port4").value=22;
		}
		
		else if(protNUM==40 || protNUM==41){
			document.getElementById("port4").value=23;
		}
		else if(protNUM==42 || protNUM==43){
			document.getElementById("port4").value=80;
		}
		
		else if(protNUM==44 || protNUM==45){
			document.getElementById("port4").value=1293;
		}
		else if(protNUM==46 || protNUM==47){
			document.getElementById("port4").value=1701;
		}
		else if(protNUM==48 || protNUM==49){
			document.getElementById("port4").value=1723;
		}
		
		else if(protNUM==50 || protNUM==51){
			document.getElementById("port4").value=1812;
		}
		
		else if(protNUM==52 || protNUM==53){
			document.getElementById("port4").value=1813;
		}
		else if(protNUM==54 || protNUM==55){
			document.getElementById("port4").value=34980;
		}
	}
}

function funcSel(num)
{	
	if(num==0){	// ip mode
		document.getElementById("ip_config_table1").style.display="";
		document.getElementById("ip_config_table2").style.display="";

		
		document.getElementById("mac_config_enable_select").disabled="";


		if(document.getElementById("mac").value == "" || document.getElementById("mac").value == "00:00:00:00:00:00" || document.getElementById("mac").value == "00-00-00-00-00-00"){
			document.getElementById("mac_config_enable_select").selectedIndex = 0;
			document.getElementById("mac").disabled="true";
		}
		else{
			document.getElementById("mac_config_enable_select").selectedIndex = 1;
			document.getElementById("mac").disabled="";
		}
		
		//alert("funcSel");
		//funcMacEnble_Sel(0);
	}
	else{	// mac mode
		document.getElementById("ip_config_table1").style.display="none";
		document.getElementById("ip_config_table2").style.display="none";

		document.getElementById("mac_config_enable_select").disabled="true";
		document.getElementById("mac_config_enable_select").selectedIndex = 1;
		funcMacEnble_Sel(1);	
	}
}

function funcMacEnble_Sel(num)
{	
	
	if(num==0){	// disable mac config
		document.getElementById("mac").disabled="true";
	}
	else{	// Enable mac config
		document.getElementById("mac").disabled="";
	}
}

function funcSrcIPSel(src_ipNUM)
{
	if(src_ipNUM==0){
		document.getElementById("src_ip_all_config").style.display="";
		document.getElementById("src_ip_single_config").style.display="none";
		document.getElementById("src_ip_range_config").style.display="none";
	}
	else if(src_ipNUM==1){
		document.getElementById("src_ip_all_config").style.display="none";
		document.getElementById("src_ip_single_config").style.display="";
		document.getElementById("src_ip_range_config").style.display="none";
	}
	else {
		document.getElementById("src_ip_all_config").style.display="none";
		document.getElementById("src_ip_single_config").style.display="none";
		document.getElementById("src_ip_range_config").style.display="";
	}
}

function funcSrcPortSel(src_portNUM)
{
	if(src_portNUM==0){
		document.getElementById("src_port_all_config").style.display="";
		document.getElementById("src_port_single_config").style.display="none";
		document.getElementById("src_port_range_config").style.display="none";
		
	}
	else if(src_portNUM==1){
		document.getElementById("src_port_all_config").style.display="none";
		document.getElementById("src_port_single_config").style.display="";
		document.getElementById("src_port_range_config").style.display="none";
		

	}
	else {
		document.getElementById("src_port_all_config").style.display="none";
		document.getElementById("src_port_single_config").style.display="none";
		document.getElementById("src_port_range_config").style.display="";

	}
}

function funcDstIPSel(dst_ipNUM)
{
	if(dst_ipNUM==0){
		document.getElementById("dst_ip_all_config").style.display="";
		document.getElementById("dst_ip_single_config").style.display="none";
		document.getElementById("dst_ip_range_config").style.display="none";
	}
	else if(dst_ipNUM==1){
		document.getElementById("dst_ip_all_config").style.display="none";
		document.getElementById("dst_ip_single_config").style.display="";
		document.getElementById("dst_ip_range_config").style.display="none";
	}
	else {
		document.getElementById("dst_ip_all_config").style.display="none";
		document.getElementById("dst_ip_single_config").style.display="none";
		document.getElementById("dst_ip_range_config").style.display="";
	}
}

function funcDstPortSel(dst_portNUM)
{
	if(dst_portNUM==0){
		document.getElementById("dst_port_all_config").style.display="";
		document.getElementById("dst_port_single_config").style.display="none";
		document.getElementById("dst_port_range_config").style.display="none";
	}
	else if(dst_portNUM==1){
		document.getElementById("dst_port_all_config").style.display="none";
		document.getElementById("dst_port_single_config").style.display="";
		document.getElementById("dst_port_range_config").style.display="none";
	}
	else {
		document.getElementById("dst_port_all_config").style.display="none";
		document.getElementById("dst_port_single_config").style.display="none";
		document.getElementById("dst_port_range_config").style.display="";
	}
} 

var	CMP_MUTEX				= 0;
var CMP_R1_INCLUDED_IN_R2	= 1;
var CMP_EQUAL				= 2;
var CMP_R1_CONTAIN_R2		= 3;
var CMP_R1_COSS_R2			= 4;

function getProtoValueIdx(protocol)
{
	var i;
	var proto_value = 0;
	
	for(i = 0 ; i < prot.length ; i++){
		if(protocol == prot[i].value){
			//alert("protocol="+protocol+" prot["+i+"].value="+prot[i].value);
			if(i > IDX_ICMP){	// not all/tcp/udp/icmp
				if((i%2) == 0){
					proto_value = IDX_TCP;
				}
				else{
					proto_value = IDX_UDP;
				}
			}
			else{	// all/tcp/udp/icmp
				proto_value = i;
			}
			break;
		}
		
	}

	return proto_value;
}

function Compare(r1, r2, t)	
{	
	/*	temp[0]	ip/mac	*/
	if((r1.ctl-(r1.ctl%10000))==(r2.ctl-(r2.ctl%10000))){
		t[0] = CMP_EQUAL;
	}
	else{
		t[0] = CMP_MUTEX;
	}
	
	//	temp[1]	protocol	
	if(getProtoValueIdx(r1.prot) == IDX_ALL){
		if(getProtoValueIdx(r2.prot) == IDX_ALL)
			t[1] = CMP_EQUAL;
		else
			t[1] = CMP_R1_CONTAIN_R2;
	}
	else{
		if(getProtoValueIdx(r2.prot) == IDX_ALL)
			t[1] = CMP_R1_INCLUDED_IN_R2;
		else{
			if(getProtoValueIdx(r1.prot) == getProtoValueIdx(r2.prot))
				t[1] = CMP_EQUAL;
			else
				t[1] = CMP_MUTEX;
		}
	}
	
	//	temp[2]	src ifs
	if(r1.ifs1 == ifs1[0].value){
		if(r2.ifs1 == ifs1[0].value)
			t[2] = CMP_EQUAL;
		else
			t[2] = CMP_R1_CONTAIN_R2;
	}
	else{
		if(r2.ifs1 == ifs1[0].value)
			t[2] = CMP_R1_INCLUDED_IN_R2;
		else{
			if(r1.ifs1 == r2.ifs1)
				t[2] = CMP_EQUAL;
			else
				t[2] = CMP_MUTEX;
		}
	}	

	//	temp[3]	src ip
	if(((r1.ctl%10000-r1.ctl%1000)/1000)==0){	// all
		if(((r2.ctl%10000-r2.ctl%1000)/1000)==0)
			t[3] = CMP_EQUAL;
		else
			t[3] = CMP_R1_CONTAIN_R2;
	}

	else if(((r1.ctl%10000-r1.ctl%1000)/1000)==1){	// r1 single
		if(((r2.ctl%10000-r2.ctl%1000)/1000)==0){	//r2 all
			t[3] = CMP_R1_INCLUDED_IN_R2;
		}
		
		else if(((r2.ctl%10000-r2.ctl%1000)/1000)==1){	//r2 single
			if(IP2V(r1.ip1)==IP2V(r2.ip1))
				t[3] = CMP_EQUAL;
			else
				t[3] = CMP_MUTEX;
		}
	
		else{	//r2 range
			if(IP2V(r1.ip1)>=IP2V(r2.ip2) && IP2V(r1.ip1)<=IP2V(r2.ip3))
				t[3] = CMP_R1_INCLUDED_IN_R2;
			else
				t[3] = CMP_MUTEX;
		}				
	}
	else{	//r1 range
		if(((r2.ctl%10000-r2.ctl%1000)/1000)==0){	//r2 all
			t[3] = CMP_R1_INCLUDED_IN_R2;
		}
		else if(((r2.ctl%10000-r2.ctl%1000)/1000)==1){	//r2 single
			if(IP2V(r1.ip2)<=IP2V(r2.ip1) && IP2V(r2.ip1)<=IP2V(r1.ip3))
				t[3] = CMP_R1_CONTAIN_R2;
			else
				t[3] = CMP_MUTEX;
		}
		else{ //r2 range, ip2: range start, ip3: range end
			if(IP2V(r1.ip2)==IP2V(r2.ip2) && IP2V(r1.ip3)==IP2V(r2.ip3))
				t[3] = CMP_EQUAL;
			else if(IP2V(r1.ip2) <= IP2V(r2.ip2) && IP2V(r1.ip3) >= IP2V(r2.ip3))
				t[3] = CMP_R1_CONTAIN_R2;
            else if(IP2V(r1.ip2) >= IP2V(r2.ip2) && IP2V(r1.ip3) <= IP2V(r2.ip3))
                t[3] = CMP_R1_INCLUDED_IN_R2;
            else if(IP2V(r1.ip3) < IP2V(r2.ip2) || IP2V(r1.ip2) > IP2V(r2.ip3))
                t[3] = CMP_MUTEX;
			else
				t[3] = CMP_R1_COSS_R2;
		}
	}

	//	temp[4]	src port
	if(((r1.ctl%1000-r1.ctl%100)/100)==0){	// all
		if(((r2.ctl%1000-r2.ctl%100)/100)==0)
			t[4] = CMP_EQUAL;
		else
			t[4] = CMP_R1_CONTAIN_R2;
	}

	else if(((r1.ctl%1000-r1.ctl%100)/100)==1){	// r1 single
		if(((r2.ctl%1000-r2.ctl%100)/100)==0){	//r2 all
			t[4] = CMP_R1_INCLUDED_IN_R2;
		}
		
		else if(((r2.ctl%1000-r2.ctl%100)/100)==1){	//r2 single
			if(parseInt(r1.port1, 10) == parseInt(r2.port1, 10))
				t[4] = CMP_EQUAL;
			else
				t[4] = CMP_MUTEX;
		}
	
		else{	//r2 range
			if(parseInt(r1.port1, 10) >= parseInt(r2.port2, 10) && parseInt(r1.port1, 10) <= parseInt(r2.port3, 10))
				t[4] = CMP_R1_INCLUDED_IN_R2;
			else
				t[4] = CMP_MUTEX;
		}				
	}
	else{	//r1 range, port2: range start, port3: range end

		if(((r2.ctl%1000-r2.ctl%100)/100) == 0){	//r2 all
			t[4] = CMP_R1_INCLUDED_IN_R2;
		}
		else if(((r2.ctl%1000-r2.ctl%100)/100)==1){	//r2 single
			if(parseInt(r2.port1, 10) >= parseInt(r1.port2, 10) && parseInt(r2.port1, 10) <= parseInt(r1.port3, 10)){
				t[4] = CMP_R1_CONTAIN_R2;
			}
			else{
				t[4] = CMP_MUTEX;
			}	
		}
		else{ //r2 range, port5: range start, port5: range end
			
			if(parseInt(r1.port2, 10) == parseInt(r2.port2, 10) && parseInt(r1.port3, 10) == parseInt(r2.port3, 10)){
				t[4] = CMP_EQUAL;
			}
			else if(parseInt(r1.port2, 10) <= parseInt(r2.port2, 10) && parseInt(r1.port3, 10) >= parseInt(r2.port3, 10)){
				t[4] = CMP_R1_CONTAIN_R2;
			}
			else if(parseInt(r1.port2, 10) >= parseInt(r2.port2, 10) && parseInt(r1.port3, 10) <= parseInt(r2.port3, 10)){
				t[4] = CMP_R1_INCLUDED_IN_R2;
			}
            else if(parseInt(r1.port3, 10) < parseInt(r2.port2, 10) || parseInt(r1.port2, 10) > parseInt(r2.port3, 10)){
                t[4] = CMP_MUTEX;
            }
			else{
				t[4] = CMP_R1_COSS_R2;
			}
		}
		
	}

	//	temp[5]	dst ifs
	if(r1.ifs2 == ifs1[0].value){
		if(r2.ifs2 == ifs1[0].value)
			t[5] = CMP_EQUAL;
		else
			t[5] = CMP_R1_CONTAIN_R2;
	}
	else{
		if(r2.ifs2 == ifs1[0].value)
			t[5] = CMP_R1_INCLUDED_IN_R2;
		else{
			if(r1.ifs2 == r2.ifs2)
				t[5] = CMP_EQUAL;
			else
				t[5] = CMP_MUTEX;
		}
	}	
	
	//	temp[6]	dst ip
	if(((r1.ctl%100-r1.ctl%10)/10)==0){	// all
		if(((r2.ctl%100-r2.ctl%10)/10)==0)
			t[6] = CMP_EQUAL;
		else
			t[6] = CMP_R1_CONTAIN_R2;
	}

	else if(((r1.ctl%100-r1.ctl%10)/10)==1){	// r1 single
		if(((r2.ctl%100-r2.ctl%10)/10)==0){	//r2 all
			t[6] = CMP_R1_INCLUDED_IN_R2;
		}
		
		else if(((r2.ctl%100-r2.ctl%10)/10)==1){	//r2 single
			if(IP2V(r1.ip4)==IP2V(r2.ip4))
				t[6] = CMP_EQUAL;
			else
				t[6] = CMP_MUTEX;
		}
	
		else{	//r2 range, ip4: range start, ip5: range end
			if(IP2V(r1.ip4)>=IP2V(r2.ip5) && IP2V(r1.ip4)<=IP2V(r2.ip6))
				t[6] = CMP_R1_INCLUDED_IN_R2;
			else
				t[6] = CMP_MUTEX;
		}				
	}
	else{	//r1 range
		if(((r2.ctl%100-r2.ctl%10)/10)==0){	//r2 all
			t[6] = CMP_R1_INCLUDED_IN_R2;
		}
		else if(((r2.ctl%100-r2.ctl%10)/10)==1){	//r2 single
			if(IP2V(r1.ip5)<=IP2V(r2.ip4) && IP2V(r2.ip4)<=IP2V(r1.ip6))
				t[6] = CMP_R1_CONTAIN_R2;
			else
				t[6] = CMP_MUTEX;
		}
		else{ //r2 range, ip5: range start, ip6: range end
			if(IP2V(r1.ip5)==IP2V(r2.ip5) && IP2V(r1.ip6)==IP2V(r2.ip6))
				t[6] = CMP_EQUAL;
            else if(IP2V(r1.ip5)>=IP2V(r2.ip5) && IP2V(r1.ip6)<=IP2V(r2.ip6))
                t[6] = CMP_R1_INCLUDED_IN_R2
			else if(IP2V(r1.ip5)<=IP2V(r2.ip5) && IP2V(r1.ip6)>=IP2V(r2.ip6))
				t[6] = CMP_R1_CONTAIN_R2;
            else if(IP2V(r1.ip6)<IP2V(r2.ip5) || IP2V(r1.ip5)>IP2V(r2.ip6))
                t[6] = CMP_MUTEX;
			else
				t[6] = CMP_R1_COSS_R2;
		}
	}

	/*	temp[7]: dst port */
	if((r1.ctl%10)==0){	// all
		if((r2.ctl%10)==0)
			t[7] = CMP_EQUAL;
		else
			t[7] = CMP_R1_CONTAIN_R2;
	}
	else if((r1.ctl%10)==1){	// r1 single
		if((r2.ctl%10)==0){	//r2 all
			t[7] = CMP_R1_INCLUDED_IN_R2;
		}
		
		else if((r2.ctl%10)==1){	//r2 single
			if(parseInt(r1.port4, 10) == parseInt(r2.port4, 10))
				t[7] = CMP_EQUAL;
			else
				t[7] = CMP_MUTEX;
		}
	
		else{	//r2 range, port5: range start, port6: range end
			if(parseInt(r1.port4, 10) >= parseInt(r2.port5, 10) && parseInt(r1.port4, 10) <= parseInt(r2.port6, 10))
				t[7] = CMP_R1_INCLUDED_IN_R2;
			else
				t[7] = CMP_MUTEX;
		}				
	}
	else{	//r1 range
		if((r2.ctl%10) == 0){	//r2 all
			t[7] = CMP_R1_INCLUDED_IN_R2;
		}
		else if((r2.ctl%10)==1){	//r2 single
			if(parseInt(r2.port4, 10) >= parseInt(r1.port5, 10) && parseInt(r2.port4, 10) <= parseInt(r1.port6, 10)){
				t[7] = CMP_R1_CONTAIN_R2;
			}
			else{
				t[7] = CMP_MUTEX;
			}	
		}
		else{ //r2 range, port5: range start, port5: range end
			
			if(parseInt(r1.port5, 10) == parseInt(r2.port5, 10) && parseInt(r1.port6, 10) == parseInt(r2.port6, 10)){
				t[7] = CMP_EQUAL;
			}
			else if(parseInt(r1.port5, 10) <= parseInt(r2.port5, 10) && parseInt(r1.port6, 10) >= parseInt(r2.port6, 10)){
				t[7] = CMP_R1_CONTAIN_R2;
			}
			else if(parseInt(r1.port5, 10) >= parseInt(r2.port5, 10) && parseInt(r1.port6, 10) <= parseInt(r2.port6, 10)){
				t[7] = CMP_R1_INCLUDED_IN_R2;
			}
            else if(parseInt(r1.port6, 10) < parseInt(r2.port5, 10) || parseInt(r1.port5, 10) > parseInt(r2.port6, 10)){
                t[7] = CMP_MUTEX;
            }
			else{
				t[7] = CMP_R1_COSS_R2;
			}
		}
	}
	
	//	temp[8]	mac addr
	if((r1.ctl/10000)==2 && (r2.ctl/10000)==2){
		if(r1.mac==r2.mac)
			t[8] = CMP_EQUAL;
		else
			t[8] = CMP_MUTEX;
	}
}

function summation(temp, minus)
{
	return (temp[1]-minus)*(temp[2]-minus)*(temp[3]-minus)*(temp[4]-minus)*(temp[5]-minus)*(temp[6]-minus)*(temp[7]-minus);
}

function Detect()
{
	var conflict = 0;
	temp=new Array(-1,-1,-1,-1,-1,-1,-1,-1,-1);
	var total=0;
	for(i=0; i<wdata.length-1; i++){
		for(j=i+1; j<wdata.length; j++){
			if(wdata[i].stat==1 && wdata[j].stat==1){
				for(k=0; k<9; k++)
					temp[k]=-1;
				Compare(wdata[i], wdata[j], temp);
				
				//alert("ip/mac="+temp[0]);
				//alert("protocol="+temp[1]);
				//alert("src ifs="+temp[2]);
				//alert("src ip="+temp[3]);
				//alert("src port="+temp[4]);
				//alert("dst ifs="+temp[5]);
				//alert("dst ip="+temp[6]);
				//alert("dst port="+temp[7]);
				//alert("mac="+temp[8]);
				
				if(temp[0]!=0 && summation(temp, 0)!=0){	/* there must be something(ip/port) is overlapping between r1 and r2. */
					if((wdata[i].ctl-(wdata[i].ctl%10000))==10000 && (wdata[j].ctl-(wdata[j].ctl%10000))==10000){	// ip mode
						if(summation(temp, CMP_R1_COSS_R2) == 0 || summation(temp, CMP_R1_INCLUDED_IN_R2) == 0 ){	// the specific variable 

							if(summation(temp, CMP_R1_COSS_R2) == 0 || (summation(temp, CMP_R1_INCLUDED_IN_R2) == 0 && summation(temp, CMP_R1_CONTAIN_R2) == 0)){	
								if(wdata[i].targets != wdata[j].targets){
									alert("rule["+(j+1)+"] is cross conflict with rule["+(i+1)+"]");
									conflict++;
								}
							}
						}			
						else{	/* no r1's variable is included in r2's */

							if(wdata[i].targets == wdata[j].targets){
								alert("rule["+(j+1)+"] is included in rule["+(i+1)+"]");
								conflict++;
							}
							else{
								alert("rule["+(j+1)+"] is masked by rule["+(i+1)+"]");
								conflict++;
							}
						}			
					}
					else if((wdata[i].ctl-(wdata[i].ctl%10000))==20000 && (wdata[j].ctl-(wdata[j].ctl%10000))==20000){	// mac mode
						if(temp[8]==2){
							alert("rule["+(i+1)+"] and rule["+(j+1)+"] had mac redundent");
							conflict++;
						}
					}
					else;
				}
	
			}
		}
	}
	if(conflict == 0)
		alert("check ok !!");	
}

/*				for(k=0; k<9; k++){
				total=total+temp[k];
			}
			if(total!=0){
				total=0;
				for(k=0; k<9; k++){
					total=total+(temp[k]-1);
				}
				if(total!=0){
					if(wdata[i].targets==wdata[j].targets){
						alert("rule["+j+"] is included in rule["+i+"]");
					}
					else{
						alert("rule["+j+"] is masked by rule["+i+"]");
					}
				}
				else{
					total=0;
					for(k=0; k<9; k++){
						total=total+(temp[k]-3);
					}
					if(total==0 && wdata[i].targets!=wdata[j].targets){
						alert("rule["+j+"] is cross conflict with rule["+i+"]");
					}
				}	
			}
*/

</script>
</head>

<body onLoad=fnInit(0)>

<h1><script language="JavaScript">doc(IPT_Filter)</script></h1>

<fieldset>



<form name="qwe" id="myForm" method="POST" onSubmit="return stopSubmit()">
	<% net_Web_csrf_Token(); %>
	<input type="hidden" name="iptTemp" id="iptTemp" value="" />
	<input type="hidden" id="idx" name="ipt_filter_idx" value="" /> 
	<input type="hidden" id="ctl" name="ipt_filter_ctl" value="" /> 
	

	<DIV style="height:450px">
		<table  style="width:300px;">
			<tr class=r0>
				 <td colspan=2><script language="JavaScript">doc(Global_Parameters)</script></td>
			</tr>	
		</table>
		<table><tr><td><table><tr><td>
			<table  style="width:800px;">
				<tr>
					<td style="width:119px;" align="left">
						<script language="JavaScript">doc(FIREWALL_EVENT_LOG_)</script><br/>
					</td>
					<td style="width:150px;" align="left">
						<script language="JavaScript">iGenSel2_with_width('logEnable', 'logEnable', wtyp0, 130)</script>
					</td>
					<td style="width:60px;" align="left"></td>
					<td style="width:150px;" align="left"></td>
					<td style="width:10px;" align="left"></td>
					<td style="width:36px;" align="left"></td>
					<td style="width:10px;" align="left"></td>
					<td style="width:36px;" align="left"></td>
					<td style="width:10px;" align="left"></td>
					<td style="width:36px;" align="left"></td>
					
				</tr>
				<tr>
					<td>
						<script language="JavaScript">doc(IPT_FILTER_MALFORMED_PACKETS_)</script>
					</td>
					<td>
						<script language="JavaScript">iGenSel2_with_width('malEnable', 'malEnable', wtyp0, 130)</script>
					</td>
					<td >
						<script language="JavaScript">doc(Severity_)</script><br/>
					</td>
					<td>
						<script language="JavaScript">iGenSel2_with_width('ipt_malformed_logLevel', 'malLogLevel', malformed_level, 130)</script>
					</td>
					<td>
						<script language="JavaScript">doc(MOXA_FLASH_)</script><br/>
					</td>
					<td>
						<input type="checkbox" id="malLogFlash" name="ipt_malformed_logFlash">
					</td>
					<td>
						<script language="JavaScript">doc(SYSLOG_SERVER_)</script><br/>
					</td>
					<td>
						<input type="checkbox" id="malLogSyslog" name="ipt_malformed_logSyslog">
					</td>
					<td>
						<script language="JavaScript">doc(SNMP_TRAP_)</script><br/>
					</td>
					<td>
						<input type="checkbox" id="malLogTrap" name="ipt_malformed_logTrap">
					</td>
				</tr>
			</table>	
		</td></tr></table></td></tr></table>
	
	
		</br>

		<table   style="width:300px;">
			<tr class=r0>
				 <td colspan=2><script language="JavaScript">doc(IPT_FILTER_POLICY_SETTING)</script></td>
			</tr>	
		</table>

		
		<table   style="width:1200px;">
			<tr>
				<td style="width:600px;" align="left" valign="top">
					<table style="width:600px;">
						<tr>
							<td>
								<table>
									<tr>
										<td style="width:120px;"  align="left">
											<script language="JavaScript">doc(NAME_)</script><br/>
										</td>
										<td align="left">
											<input type="text" name="name" id="name" size=53 maxlength=64>
										</td>
									</tr>
								</table>	
							<td>	
						</tr>
						<tr>
							<td>
								<table>
									<tr>
										<td style="width:120px;">
											<script language="JavaScript">doc(IPT_FILTER_ENABLE)</script><br/>
										</td>
										<td style="width:150x;" align="left" valign="center">
											<input type="checkbox" id="stat" name="ipt_filter_enable">
										</td>
									</tr>
								</table>	
							<td>	
						</tr>
						<tr>
							<td>
								<table>
									<tr>
										<td style="width:120px;">
											<script language="JavaScript">doc(Severity_)</script><br/>
										</td>
										<td style="width:148px;" align="left" valign="center">
											<script language="JavaScript">iGenSel2_with_width('ipt_filter_logLevel', 'logLevel', filter_level, 130)</script>
										</td>
										<td style="width:10px;">
											<script language="JavaScript">doc(MOXA_FLASH_)</script><br/>
										</td>
										<td style="width:36px;" align="left" valign="center">
											<input type="checkbox" id="logFlash" name="ipt_filter_logFlash">
										</td>
										<td style="width:10px;">
											<script language="JavaScript">doc(SYSLOG_SERVER_)</script><br/>
										</td>
										<td style="width:36px;" align="left" valign="center">
											<input type="checkbox" id="logSyslog" name="ipt_filter_logSyslog">
										</td>
										<td style="width:70px;">
											<script language="JavaScript">doc(SNMP_TRAP_)</script><br/>
										</td>
										<td align="left" valign="center">
											<input type="checkbox" id="logTrap" name="ipt_filter_logTrap">
										</td>
									</tr>
								</table>	
							<td>	
						</tr>
						<tr>
							<td>
								<table>
									<tr>
										<td style="width:60px;" align="left" valign="center">
											<script language="JavaScript">doc(IPT_FILTER_INTERFACE)</script>
										</td>
										<td style="width:56;" align="left" valign="center">			
											<script language="JavaScript">doc(IPT_FILTER_IP_FROM)</script>
										</td>
										<td>
											<script language="JavaScript">iGenSel2_with_width('ipt_filter_ifs1', 'ifs1', ifs1, 403)</script>
										</td>
									</tr>
									<tr>
										<td></td>
										<td align="left" valign="center">	
											<script language="JavaScript">doc(IPT_FILTER_IP_TO)</script>
										</td>
										<td>
											<script language="JavaScript">iGenSel2_with_width('ipt_filter_ifs2', 'ifs2', ifs2, 403)</script>
										</td>
									</tr>
								</table>	
							<td>	
						</tr>
						<tr>
							<td>
								<table>
									<tr>
										<td style="width:120px;" align="left" valign="center">
											<script language="JavaScript">doc(IPT_FILTER_PROTOCOL)</script>    
										</td>
										<td align="left" valign="center">
											<script language="JavaScript">iGenSel3_with_width('ipt_filter_prot', 'prot', prot, 'funcProtSel', 403)</script>
										</td>
									</tr>
								</table>	
							<td>	
						</tr>
						
						<tr>
							<td>
								<table>
									<tr>
										<td style="width:120px;" align="left">
											<script language="JavaScript">doc(FILTER_MODE_)</script>
										</td>
										<td align="left">
											<select style="width:403px;" size=1 name="tSel" id="tSel" onchange="funcSel(this.selectedIndex);" >
												<option value="ipfilter">IP Address Filter</option>
												<option value="macfilter">Source MAC Filter</option>
											</select>
										</td>
									</tr>
								</table>	
							<td>	
						</tr>
					</table>	
				<td>
				<td style="width:600px;" align="left" valign="top">	
					<table   style="width:600px;" id="tatget_table">
						<tr>
							<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">doc(Targets)</script>
							</td>
							<td align="left" valign="center">  
								<table>
									<tr>
										<td align="left" valign="center">
											<script language="JavaScript">iGenSel2_with_width('ipt_filter_targets', 'targets', targets, 90)</script>
										</td>
									</tr>
								</table>	
							</td>
						</tr>
					</table>
					<table   style="width:600px;" id="ip_config_table1">
						<tr>
							<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">doc(SRC_IP)</script>
							</td>
							<td align="left" valign="center">
								<table>
									<tr>
										<td style="width:100px;" align="left" valign="center">
											<select style="width:90px;" size=1 name="SrcIPSel" id="SrcIPSel" onchange="funcSrcIPSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td>
										<td id="src_ip_all_config" align="left" valign="center">  				
							   			</td>
										<td id="src_ip_single_config" align="left" valign="center" style="display:none">  				
								  			
								  			<input type="text" id=ip1 name="ipt_filter_ip_start" size=17 maxlength=17>
									   	</td>
									   	<td id="src_ip_range_config" align="left" valign="center" style="display:none">  				
								  			<input type="text" id=ip2 name="ipt_filter_ip_start1" size=17 maxlength=17>
								  			~
									       	<input type="text" id=ip3 name="ipt_filter_ip_end1" size=17 maxlength=17> 
									   	</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table   style="width:600px;" id="mac_config_table">
						<tr>
							<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">doc(SOURCE_IP_MAC_BINDING_)</script></br>
							</td>
							<td align="left" valign="center">
								<table>
									<tr>
										<td style="width:100px;" id="mac_config_enable" align="left" valign="center">
											<select style="width:90px;" size=1 name="mac_config_enable_select" id="mac_config_enable_select" onchange="funcMacEnble_Sel(this.selectedIndex);" >
												<option value=0>Disable</option>
												<option value=1>Enable</option>
											</select>
										</td>
										<td align="left" valign="center">  	    
								      		<input type="text" id=mac name="ipt_filter_haddr" size=17 maxlength=17>   
						          		</td>
									<tr>
								</table>	
							</td>		
						</tr>
					</table>
					<table   style="width:600px;" id="port_config_table1">
						<tr>
							<td style="width:120px;" id="src_port" align="left" valign="center">
								<script language="JavaScript">doc(SRC_PORT)</script>
							</td>
							<td align="left" valign="center">
								<table>
									<tr>
										<td style="width:100px;" align="left" valign="center">
											<select style="width:90px;" size=1 name="SrcPortSel" id="SrcPortSel" onchange="funcSrcPortSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td>
										<td id="src_port_all_config" align="left" valign="center" >
								        </td>
								        <td id="src_port_single_config" align="left" valign="center" style="display:none">       	  	
								            <input type="text" id=port1 name="ipt_filter_port_start" size=17 maxlength=17> 
								        </td>
								        <td id="src_port_range_config" align="left" valign="center"  style="display:none">     	  	
								            <input type="text" id=port2 name="ipt_filter_port_start1" size=17 maxlength=17> 
								            ~                
								            <input type="text" id=port3 name="ipt_filter_port_end1" size=17 maxlength=17>
								        </td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table   style="width:600px;" id="ip_config_table2">
						<tr>
							<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">doc(DST_IP)</script>
							</td>
							<td align="left" valign="center">
								<table>
									<tr>
										<td style="width:100px;" align="left" valign="center">
											<select style="width:90px;" size=1 name="DstIPSel" id="DstIPSel" onchange="funcDstIPSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td> 
										<td id="dst_ip_all_config" align="left" valign="center" >  				
									   	</td>
										<td id="dst_ip_single_config" align="left" valign="center" style="display:none">  				
								  			
								  			<input type="text" id=ip4 name="dst_ipt_filter_ip_start" size=17 maxlength=17>
									   	</td>
									   	<td id="dst_ip_range_config" align="left" valign="center" style="display:none">  				
								  			
								  			<input type="text" id=ip5 name="dst_ipt_filter_ip_start1" size=17 maxlength=17>
								  			~
									       	<input type="text" id=ip6 name="dst_ipt_filter_ip_end1" size=17 maxlength=17> 
									   	</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table   style="width:600px;" id="port_config_table2">
						<tr>
							<td style="width:120px;" id="dst_port" align="left" valign="center">
								<script language="JavaScript">doc(DST_PORT)</script>
							</td>
							<td align="left" valign="center">
								<table>
									<tr>
										<td  style="width:100px;" align="left" valign="center">
											<select style="width:90px;" size=1 name="DstPortSel" id="DstPortSel" onchange="funcDstPortSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td>
										<td id="dst_port_all_config" align="left" valign="center">
								        </td>
								        <td id="dst_port_single_config" align="left" valign="center" style="display:none">
							           	  	
								            <input type="text" id=port4 name="dst_ipt_filter_port_start" size=17 maxlength=17> 
								        </td>
								        <td id="dst_port_range_config" align="left" valign="center" style="display:none">     	  	
								            <input type="text" id=port5 name="dst_ipt_filter_port_start1" size=17 maxlength=17> 
								            ~                
								            <input type="text" id=port6 name="dst_ipt_filter_port_end1" size=17 maxlength=17>
								        </td>
									</tr>
								</table>
							</td>
						</tr>
					</table>			
				<td>
			</tr>
		</table>
	</DIV>

</form>


<p><table class="tf" align="left" valign="up">
	<tr>
		<td width="400px" style="text-align:left;"><script language="JavaScript">fnbnB(addb, 'onClick=Add(myForm)')</script>
		
		<script language="JavaScript">fnbnB(modb, 'onClick=Modify(myForm)')</script>
	  	<script language="JavaScript">fnbnB(delb, 'onClick=Del(myForm)')</script>
		<script language="JavaScript">fnbnB(moveb, 'onClick=Move(myForm)')</script></td>
	  	<td width="300px" style="text-align:left;">
	  	<script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(myForm)', 'btnU')</script>
	  	<script language="JavaScript">fnbnB_with_width(detectb, 'onClick=Detect(myForm)', 100)</script>
	  	</td>	
	</tr>
</table></p>


<DIV style="height:50px">
<table class=tf align=left border=12>
<tr ></tr>
</table>
</DIV>

<DIV style="width:1950px">
	<table cellpadding=1 cellspacing=2>	
		<tr>
  			<td colspan="8">
	  			<table><tr class=r0>
  				<td width="70px"><script language="JavaScript">doc(Iptables_Filter_List)</script></td>
  				<td id = "totalcnt" colspan="6"></td>
  				<td></td>
  				</tr></table>  				  				
  			</td>
		</tr>
		<tr align="center">
 			<th class="s0" width="50px"><script language="JavaScript">doc(IPT_FILTER_ENABLE)</script></td>
 			<th class="s0" width="45px"><script language="JavaScript">doc(IPT_FILTER_INDEX)</script></td>
  			<th class="s0" width="125px"><script language="JavaScript">doc(INPUT_IFS)</script></td>
			<th class="s0" width="125px"><script language="JavaScript">doc(OUTPUT_IFS)</script></td>
			<th class="s0" width="125px"><script language="JavaScript">doc(Protocol)</script></td>
			<th class="s0" width="110px"><script language="JavaScript">doc(SRC_IP)</script></td>
			<th class="s0" width="120px"><script language="JavaScript">doc(IPT_MAC)</script></td>
			<th class="s0" width="80px"><script language="JavaScript">doc(SRC_PORT)</script></td>
			<th class="s0" width="110px"><script language="JavaScript">doc(DST_IP)</script></td>
			<th class="s0" width="80px"><script language="JavaScript">doc(DST_PORT)</script></td>
			<th class="s0" width="80px"><script language="JavaScript">doc(Targets)</script></td>
			<th class="s0" width="110px">Event Log /<br><script language="JavaScript">doc(Severity_)</script></td>
			<th class="s0" width="350px"><script language="JavaScript">doc(NAME_)</script></td>
		</tr>
	</table>
</DIV>

<DIV style="width:1950px; overflow-y:auto;">
	<table cellpadding=1 cellspacing=2 id="show_available_table" >	
		<tr align="center" >
 			<td width="50px"></td>
 			<td width="45px"></td>
  			<td width="125px"></td>
			<td width="125px"></td>
			<td width="125px"></td>
			<td width="110px"></td>
			<td width="120px"></td>
			<td width="80px"></td>
			<td width="110px"></td>
			<td width="80px"></td>
			<td width="80px"></td>
			<td width="110px"></td>
			<td width="350px"></td>
		</tr>	
		<script language="JavaScript">ShowList1('tri')</script>
	</table>
</DIV>

</fieldset>


</body></html>
