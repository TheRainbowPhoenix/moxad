<html>
<head>
{{ net_Web_file_include() | safe }}


<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
var ModelVLAN = {{ net_Web_GetModel_VLAN_WriteValue() | safe }};

if (!debug) {
	var wdata = [
	{ctl:11100, idx:0,  stat:'1', ifs1:'wan1', ifs2:'wan2', prot:'2', ip1:'1.168.168.168', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'', port1:'25535', port2:'', port3:'', port4:'', port5:'', port6:'', mac:'', targets:'ACCEPT'},
	{ctl:20202, idx:1, 	stat:'1', ifs1:'wan2', ifs2:'wan1', prot:'2', ip1:'', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'', port1:'', port2:'78', port3:'150', port4:'', port5:'10', port6:'11', mac:'F1:F2:F3:F4:F5:F6', targets:'ACCEPT'},
	{ctl:12222, idx:2,  stat:'0', ifs1:'all', ifs2:'all', prot:'3', ip1:'', ip2:'192.168.168.168', ip3:'192.168.138.254', ip4:'', ip5:'10.1.0.1', ip6:'10.1.0.254', port1:'', port2:'21', port3:'80', port4:'', port5:'8', port6:'9', mac:'', targets:'ACCEPT'}
	];
	var CheckConfirm = [ { stat1:1, stat2:1, timer:100 } ];
}
else{
	var wdata = [ {{ net_Web_IPT_FILTER_WriteValue() | safe }} ];
	var CheckConfirm = [ {{ net_Web_Confirm_WriteValue() | safe }} ];
}

//

if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){
	var ifs1 = [ {{ net_Web_Filter_IFS_WriteValue() | safe }} ];
	var ifs2 = [ {{ net_Web_Filter_IFS_WriteValue() | safe }} ];
}
else{
	var ifs1 = [ {{ net_Web_IFS_WriteInteger_Have_All_Value() | safe }} ];
	var ifs2 = [ {{ net_Web_IFS_WriteInteger_Have_All_Value() | safe }} ];
}



var addb = 'Show';

var entryNUM=0;
var initEntry;

{% include "cvserver_data" ignore missing %}


var filter_chain = [ {value:'INPUT', text:'INPUT'}, {value:'OUTPUT', text:'OUTPUT'}, {value:'FORWARD', text:'FORWARD'}
]

var filter_io = [ {value:'i', text:'INPUT'}, {value:'o', text:'OUTPUT'}
]

var wtype = { ctl:4, idx:4, stat:3, ifs1:2, ifs2:2, prot:2, ip1:5, ip2:5, ip3:5, ip4:5, ip5:5, ip6:5, port1:4, port2:4, port3:4, port4:4, port5:4, port6:4, mac:7, targets:2 };

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
	{ value:'21', text:'Modbus tcp/ip (TCP)' },
	{ value:'22', text:'Modbus tcp/ip (UDP)' },
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
	{ value:'33', text:'DNP (TCP)' },
	{ value:'34', text:'DNP (UDP)' },
	{ value:'35', text:'FTP-Default Data (TCP)' },
	{ value:'36', text:'FTP-Default Data (UDP)' },
	{ value:'37', text:'FTP-Control (TCP)' },
	{ value:'38', text:'FTP-Control (UDP)' },
	{ value:'39', text:'SSH (TCP)' },
	{ value:'40', text:'SSH (UDP)' },
	{ value:'41', text:'Telnet (TCP)' },
	{ value:'42', text:'Telnet (UDP)' },
	{ value:'43', text:'HTTP (TCP)' },
	{ value:'44', text:'HTTP (UDP)' },
	{ value:'45', text:'PKT-KRB-IPSec (TCP)' },
	{ value:'46', text:'PKT-KRB-IPSec (UDP)' },
	{ value:'47', text:'L2TP (TCP)' },
	{ value:'48', text:'L2TP (UDP)' },
	{ value:'49', text:'PPTP (TCP)' },
	{ value:'50', text:'PPTP (UDP)' },
	{ value:'51', text:'RADIUS (TCP)' },
	{ value:'52', text:'RADIUS (UDP)' },
	{ value:'53', text:'RADIUS Accounting (TCP)' },
	{ value:'54', text:'RADIUS Accounting (UDP)' }
];

var targets = [
	{ value:'ACCEPT', text:'ACCEPT' },	{ value:'DROP', text:'DROP' }  
];

var myForm;
var max_total;

function Total_Policy()
{
	document.getElementById("totalcnt").innerHTML = '('+wdata.length +'/' +max_total+')';
}

function fnInit(row) {	
	
	if(ProjectModel == MODEL_EDR_G903){
		max_total = 512;
	}
	else{
		max_total = 256
	}
	
	Total_Policy();
	
	myForm = document.getElementById('myForm');
	initEntry=1;
	ShowList1('tri');

}

function ShowList1(name) {
	
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");

	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
		{
			table.deleteRow(i);
		}
	}

	for(i=0;i<wdata.length;i++)
	{
		addRow(i);		
	}	
}

function EditRow1(row) 
{
	
	var rowidx
//	fnShowProp('aaaaa'+i, row);
	if(initEntry==1){
		rowidx = row;
		initEntry=0;
	}
	else{
		rowidx = row.rowIndex-1;
	}
	
	fnLoadForm(myForm, wdata[rowidx], wtype);

	ChgColor('tri', wdata.length, rowidx);
	entryNUM = rowidx;
	
	if(((wdata[rowidx].ctl-(wdata[rowidx].ctl%10000))/10000)==2){
		funcSel(1);
		document.getElementById("tSel").selectedIndex=1;
	}
	else{
		funcSel(0);
		document.getElementById("tSel").selectedIndex=0;
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





function addRow(i)
{
	table = document.getElementById('show_available_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);
	//row.style.fontSize=12;
	row.className="r2";
	cell = document.createElement("td");
	if(wdata[i].stat==1)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.innerHTML = i+1;
	row.appendChild(cell);

if(ModelVLAN == RETURN_TRUE){
	if((ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902) && ModelVLAN == RETURN_TRUE){
		cell = document.createElement("td");
		cell.innerHTML = wdata[i].ifs1;
		row.appendChild(cell);

		cell = document.createElement("td");
		cell.innerHTML = wdata[i].ifs2;
		row.appendChild(cell);
	}
	else{
		cell = document.createElement("td");
		cell.innerHTML = fnGetSelText(wdata[i].ifs1, ifs1);
		row.appendChild(cell);

		cell = document.createElement("td");
		cell.innerHTML = fnGetSelText(wdata[i].ifs2, ifs2);
		row.appendChild(cell);
	}
	
	
}
else{
	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].ifs1, ifs1);
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].ifs2, ifs2);
	row.appendChild(cell);
}
	
/*
	cell = document.createElement("td");
	if((wdata[i].ctl/10000)==2)
		cell.innerHTML = "--";
	else
		cell.innerHTML = fnGetSelText(wdata[i].prot, prot);
	row.appendChild(cell);	
*/	
	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].prot, prot);
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
	if(((wdata[i].ctl-(wdata[i].ctl%10000))/10000)==2)
		cell.innerHTML = wdata[i].mac;
	else
		cell.innerHTML = "--"
	row.appendChild(cell);


	
	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].targets, targets );
	row.appendChild(cell);
	
	
	
	row.style.Color = "black";
	var j=i+1;
//	row.onclick=EditRow(i);
	
	row.id = 'tri'+i;
	row.onclick=function(){};
	row.style.cursor=ptrcursor;
	row.align="center";
//	fnShowProp('aaaaa'+i, row);

} 

function Show(form)
{	
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");

	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
		{
			table.deleteRow(i);
		}
	}

	for(i=0;i<wdata.length;i++)
	{
		if(document.getElementById("ifs1").value==wdata[i].ifs1 || document.getElementById("ifs1").value=="all"){
			if(document.getElementById("ifs2").value==wdata[i].ifs2 || document.getElementById("ifs2").value=="all")
				addRow(i);		
		}	
	}

}


</script>
</head>
<body onLoad=fnInit(0)>

<h1><script language="JavaScript">doc(IPT_Filter_OVERVIEW)</script></h1>
<fieldset>

<form name="qwe" id="myForm" method="POST" action="/goform/net_WebIPTGetValue">
	{{ net_Web_csrf_Token() | safe }}
	<input type="hidden" name="iptTemp" id="iptTemp" value="" />
	<input type="hidden" id="idx" name="idx" value="" /> 
	<input type="hidden" id="ctl" name="ctl" value="" /> 
	<input type="hidden" id="stat" name="stat" value="" /> 
	<input type="hidden" id="prot" name="prot" value="" />
	<input type="hidden" id="ip1" name="ip1" value="" /> 
	<input type="hidden" id="ip2" name="ip2" value="" />
	<input type="hidden" id="ip3" name="ip3" value="" />
	<input type="hidden" id="ip4" name="ip4" value="" />
	<input type="hidden" id="ip5" name="ip5" value="" />
	<input type="hidden" id="ip6" name="ip6" value="" />
	<input type="hidden" id="port1" name="port1" value="" />
	<input type="hidden" id="port2" name="port2" value="" />
	<input type="hidden" id="port3" name="port3" value="" />
	<input type="hidden" id="port4" name="port4" value="" />
	<input type="hidden" id="port5" name="port5" value="" />
	<input type="hidden" id="port6" name="port6" value="" />
	<input type="hidden" id="mac" name="mac" value="" />
	<input type="hidden" id="targets" name="targets" value="" />

	<DIV >
		<table cellpadding="1" cellspacing="3" style="width:900px;">
			<tr>
				<td style="width:300px;" align="left" valign="up">
					<table cellpadding="1" cellspacing="3" style="width:300px;">
						<tr>
							<td style="width:50px;" align="left" valign="center">
								<script language="JavaScript">doc(IPT_FILTER_INTERFACE)</script>
							</td>
							<td style="width:150px;" align="left" valign="center">	
								<table>
									<tr>
										<td style="width:25px;" align="left" valign="center">
									    	<script language="JavaScript">doc(IPT_FILTER_IP_FROM)</script>
									    </td>
									    <td style="width:50px;" align="left" valign="center">
									    	<script language="JavaScript">iGenSel2('ipt_filter_ifs1', 'ifs1', ifs1)</script>
									    </td>
									    <td style="width:25px;" align="left" valign="center">
									      	<script language="JavaScript">doc(IPT_FILTER_IP_TO)</script>
										 </td>
									    <td align="left" valign="center">
									      	<script language="JavaScript">iGenSel2('ipt_filter_ifs2', 'ifs2', ifs2)</script>
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

<DIV>
	<table class="tf" align="left" valign="up">
    	<tr>
        	<td width="400px" style="text-align:left;"><script language="JavaScript">fnbnB(addb, 'onClick=Show(myForm)')</script></td>
		</tr>
	</table>
</DIV>

<DIV style="height:50px">
<table class=tf align=left border=12>
<tr ></tr>
</table>
</DIV>

<DIV style="width:1600px;">
	<table cellpadding=1 cellspacing=2>	
		<tr class="r0">
  			<td colspan="8">
  				<table><tr class="r0" >
  				<td width="70px"><script language="JavaScript">doc(Iptables_Filter_List)</script></td>
  				<td id = "totalcnt" colspan="6"></td>
  				<td></td>
  				</tr></table>  	
  			</td>
		</tr>
		<tr align="center">
 			<th class="s0" width="50px"><script language="JavaScript">doc(IPT_FILTER_ENABLE)</script></td>
 			<th class="s0" width="45px"><script language="JavaScript">doc(IPT_FILTER_INDEX)</script></td>
  			<th class="s0" width="240px"><script language="JavaScript">doc(INPUT_IFS)</script></td>
			<th class="s0" width="240px"><script language="JavaScript">doc(OUTPUT_IFS)</script></td>
			<th class="s0" width="100px"><script language="JavaScript">doc(Protocol)</script></td>
			<th class="s0" width="120px"><script language="JavaScript">doc(SRC_IP)</script></td>
			<th class="s0" width="70px"><script language="JavaScript">doc(SRC_PORT)</script></td>
			<th class="s0" width="120px"><script language="JavaScript">doc(DST_IP)</script></td>
			<th class="s0" width="70px"><script language="JavaScript">doc(DST_PORT)</script></td>
			<th class="s0" width="120px"><script language="JavaScript">doc(IPT_MAC)</script></td>
			<th class="s0" width="80px"><script language="JavaScript">doc(Targets)</script></td>
		</tr>
	</table>
</DIV>
			
<DIV style="width:1600px; overflow-y:auto;">
	<table cellpadding=1 cellspacing=2 id="show_available_table" >	
		<tr align="center" >
 			<td width="50px"></td>
 			<td width="45px"></td>
  			<td width="240px"></td>
			<td width="240px"></td>
			<td width="100px"></td>
			<td width="120px"></td>
			<td width="70px"></td>
			<td width="120px"></td>
			<td width="70px"></td>
			<td width="120px"></td>
			<td width="80px"></td>	
		</tr>	
		<script language="JavaScript">ShowList1('tri')</script>
	</table>
</DIV>

</fieldset>
</body></html>

