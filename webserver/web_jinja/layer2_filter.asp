<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

checkCookie();
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
var ModelVLAN = {{ net_Web_GetModel_VLAN_WriteValue() | safe }};

if (!debug) {
	var wdata = [
	{idx:1, stat:'1', ifs1:'wan2', ifs2:'wan1', prot:'2', mac1:'F1:F2:F3:F4:F5:F6', mac2:'', targets:'ACCEPT'}
	];
	var CheckConfirm = [ { stat1:1, stat2:1, timer:100 } ];
}
else{
	var wdata = [ {{ net_Web_L2_FILTER_WriteValue() | safe }} ];
	var CheckConfirm = [ {{ net_Web_Confirm_WriteValue() | safe }} ];

}


if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){
	var ifs1 = [ {{ net_Web_Filter_IFS_WriteValue() | safe }} ];
	var ifs2 = [ {{ net_Web_Filter_IFS_WriteValue() | safe }} ];
}
else{
	var ifs1 = [ {{ net_Web_IFS_WriteInteger_Have_All_Value_Layer2() | safe }} ];
	var ifs2 = [ {{ net_Web_IFS_WriteInteger_Have_All_Value_Layer2() | safe }} ];
}

var addb = 'Add';
var modb = 'Modify';
var moveb = 'Move';
var updb = 'Activate';
var delb = 'Delete';
var detectb = 'Policy Check';

var entryNUM=0;
var initEntry;

{% include "cvserver_data" ignore missing %}


var filter_chain = [ {value:'INPUT', text:'INPUT'}, {value:'OUTPUT', text:'OUTPUT'}, {value:'FORWARD', text:'FORWARD'}
]

var filter_io = [ {value:'i', text:'INPUT'}, {value:'o', text:'OUTPUT'}
]

var wtype = { idx:4, stat:3, ifs1:2, ifs2:2, prot:2, prot_number:5 , mac1:7, mac2:7, targets:2 };

var prot = [
	{ value:'1', text:'All' },
	{ value:'2', text:'Manual' },
	{ value:'3', text:'IPv4' },	
	{ value:'4', text:'X25' },	
	{ value:'5', text:'ARP' },
	{ value:'6', text:'Frame Relay ARP' },
	{ value:'7', text:'G8BPQ AX.25 Ethernet Packet' },
	{ value:'8', text:'DEC Assigned proto' },
	{ value:'9', text:'DEC DNA Dump/Load' },
	{ value:'10', text:'DEC DNA Remote Console' },
	{ value:'11', text:'DEC DNA Routing' },
	{ value:'12', text:'DEC LAT' },
	{ value:'13', text:'DEC Diagnostics' },
	{ value:'14', text:'DEC Customer use' },
	{ value:'15', text:'DEC Systems Comms Arch' },
	{ value:'16', text:'Trans Ether Bridging' },
	{ value:'17', text:'Raw Frame Relay' },
	{ value:'18', text:'Appletalk AARP' },
	{ value:'19', text:'Appletalk' },
	{ value:'20', text:'802.1Q Virtual LAN tagged frame' },
	{ value:'21', text:'Novell IPX' },
	{ value:'22', text:'NetBEUI' },
	{ value:'23', text:'IP version 6' },
	{ value:'24', text:'PPP' },
	{ value:'25', text:'MultiProtocol over ATM' },
	{ value:'26', text:'PPPoE discovery messages' },
	{ value:'27', text:'PPPoE session messages' },
	{ value:'28', text:'Frame-based ATM Transport over Etherne' },
	{ value:'29', text:'Loopback' },
];


var targets = [
	{ value:'ACCEPT', text:'ACCEPT' },	{ value:'DROP', text:'DROP' }  
];

var max_total;
var myForm;

function Total_Policy()
{
	document.getElementById("totalcnt").innerHTML = '('+wdata.length +'/' +max_total+')';
}

function fnInit(row) {

	if(ProjectModel == MODEL_EDR_G903){
		max_total = 256;
	}
	else{
		max_total = 256
	}
	Total_Policy();
	
	myForm = document.getElementById('myForm');
	if(wdata.length != 0){
		initEntry=1;
		EditRow1(row);
	}
	else{
		initEntry=0;
		document.getElementById("prot_number").disabled="true";	
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

	/* src mac's selection */
	if(wdata[entryNUM].mac1 == "00:00:00:00:00:00"){
		document.getElementById("src_mac_sel").selectedIndex = 0;
		func_src_mac_sel(0);
	}
	else{
		document.getElementById("src_mac_sel").selectedIndex = 1;
		func_src_mac_sel(1);
	}

	/* dst mac's selection */
	if(wdata[entryNUM].mac2 == "00:00:00:00:00:00"){
		document.getElementById("dst_mac_sel").selectedIndex = 0;
		func_dst_mac_sel(0);
	}
	else{
		document.getElementById("dst_mac_sel").selectedIndex = 1;
		func_dst_mac_sel(1);
	}
}

function addRow(i)
{
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
	
	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].ifs1, ifs1);
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].ifs2, ifs2);
	row.appendChild(cell);

	cell = document.createElement("td");
	if(wdata[i].prot == 2)
		cell.innerHTML = wdata[i].prot_number;
	else
		cell.innerHTML = fnGetSelText(wdata[i].prot, prot);
	row.appendChild(cell);	

		
	cell = document.createElement("td");
	if(wdata[i].mac1 == "00:00:00:00:00:00"){
		cell.innerHTML = "All";
	}
	else{
		cell.innerHTML = wdata[i].mac1;
	}
	row.appendChild(cell);

	cell = document.createElement("td");
	if(wdata[i].mac2 == "00:00:00:00:00:00"){
		cell.innerHTML = "All";
	}
	else{
		cell.innerHTML = wdata[i].mac2;
	}
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].targets, targets );
	row.appendChild(cell);
	
	row.style.Color = "black";
	var j=i+1;
//	row.onclick=EditRow(i);
//	row.class="r2";
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this)};
	row.style.cursor=ptrcursor;
	row.align="center";
//	fnShowProp('aaaaa'+i, row);

} 

function Add(form)
{
	if(Layer2FilterCheckFormat(form)==1)
		return;
	
	var idx=prompt("Add / Insert before ", wdata.length+1);

	if(IndexRange(idx, wdata)==-1)
		return;
	
	idx=idx-1;

	
	
	if(idx!=-1){
		if((wdata.length+1)<=max_total){
			var arrayLen = wdata.length;

			wdata[arrayLen]=new Array(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
			
			for(i=arrayLen-1; i>=idx; i--)
			{
				wdata[i+1].idx=i+1;
				wdata[i+1].stat=wdata[i].stat;
				wdata[i+1].ifs1=wdata[i].ifs1;
				wdata[i+1].ifs2=wdata[i].ifs2;
				wdata[i+1].prot=wdata[i].prot;
				wdata[i+1].prot_number=wdata[i].prot_number;
				wdata[i+1].mac1=wdata[i].mac1;
				wdata[i+1].mac2=wdata[i].mac2;
				wdata[i+1].targets=wdata[i].targets;
			}
			
			
			wdata[idx].idx=arrayLen;
			if(form.stat.checked==true)
				wdata[idx].stat=1;
			else
				wdata[idx].stat=0;

			/* src mac */
			if(document.getElementById("src_mac_sel").selectedIndex == 0){
				form.mac1.value = "00:00:00:00:00:00";
			}
			else{
				form.mac1.value=mac_format(form.mac1.value);
			}
			wdata[[idx]].mac1 = form.mac1.value;

			/* dst mac */
			if(document.getElementById("dst_mac_sel").selectedIndex == 0){
				form.mac2.value = "00:00:00:00:00:00";
			}
			else{
				form.mac2.value=mac_format(form.mac2.value);
			}
			wdata[[idx]].mac2 = form.mac2.value;

			wdata[idx].prot=form.prot.value;
			wdata[idx].prot_number=form.prot_number.value;
			wdata[idx].ifs1=form.ifs1.value;
			wdata[idx].ifs2=form.ifs2.value;
			wdata[idx].targets=form.targets.value;
			
			
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
		else
			alert("over"+max_total+"rules");
	}
	Total_Policy();
}

function Move(form)
{

	var idx=prompt("Moving Policy ID : "+(entryNUM+1)+"; enter policy ID to move before.", entryNUM+1);

	if(MoveIndexRange(idx, wdata)==-1)
		return;
	
	idx=idx-1;
	
	var i;
	
	if(idx > wdata[entryNUM].idx)
	{
		for(i=wdata[entryNUM].idx+1; i<=idx; i++)
		{			
			wdata[i-1].idx=i-1;
			wdata[i-1].stat=wdata[i].stat;
			wdata[i-1].ifs1=wdata[i].ifs1;
			wdata[i-1].ifs2=wdata[i].ifs2;
			wdata[i-1].prot=wdata[i].prot;
			wdata[i-1].prot_number=wdata[i].prot_number;
			wdata[i-1].mac1=wdata[i].mac1;
			wdata[i-1].mac2=wdata[i].mac2;
			wdata[i-1].targets=wdata[i].targets;
			
		}
	}
	else
	{	
		for(i=wdata[entryNUM].idx-1; i>=idx; i--)
		{
			wdata[i+1].idx=i+1;
			wdata[i+1].stat=wdata[i].stat;
			wdata[i+1].ifs1=wdata[i].ifs1;
			wdata[i+1].ifs2=wdata[i].ifs2;
			wdata[i+1].prot=wdata[i].prot;
			wdata[i+1].prot_number=wdata[i].prot_number;
			wdata[i+1].mac1=wdata[i].mac1;
			wdata[i+1].mac2=wdata[i].mac2;
			wdata[i+1].targets=wdata[i].targets;
		}
	}

	wdata[idx].idx=idx;
	if(form.stat.checked==true)
		wdata[idx].stat=1;
	else
		wdata[idx].stat=0;
	
	wdata[idx].prot=form.prot.value;
	wdata[idx].prot_number=form.prot_number.value;
	wdata[idx].mac1=form.mac1.value;
	wdata[idx].mac2=form.mac2.value;
	wdata[idx].ifs1=form.ifs1.value;
	wdata[idx].ifs2=form.ifs2.value;
	wdata[idx].targets=form.targets.value;


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
	//re-join the array elements to the table
	for(i=0;i<wdata.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	ChgColor('tri', wdata.length, entryNUM);	
}

function Modify(form)
{	
	if(Layer2FilterCheckFormat(form)==1)
		return;
	
	if(form.stat.checked==true)
		wdata[entryNUM].stat=1;
	else
		wdata[entryNUM].stat=0;
	
	wdata[entryNUM].mac1="";
	wdata[entryNUM].mac2="";
	wdata[entryNUM].prot=form.prot.value;
	wdata[entryNUM].prot_number=form.prot_number.value;

	/* src mac */
	if(document.getElementById("src_mac_sel").selectedIndex == 0){
		form.mac1.value = "00:00:00:00:00:00";
	}
	else{
		form.mac1.value=mac_format(form.mac1.value);
	}
	wdata[entryNUM].mac1 = form.mac1.value;

	/* dst mac */
	if(document.getElementById("dst_mac_sel").selectedIndex == 0){
		form.mac2.value = "00:00:00:00:00:00";
	}
	else{
		form.mac2.value=mac_format(form.mac2.value);
	}
	wdata[entryNUM].mac2=form.mac2.value;
	
	wdata[entryNUM].ifs1=form.ifs1.value;
	wdata[entryNUM].ifs2=form.ifs2.value;
	wdata[entryNUM].targets=form.targets.value;
	

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
		form.l2Temp.value = form.l2Temp.value + wdata[i].stat + "+";
		form.l2Temp.value = form.l2Temp.value + wdata[i].ifs1 + "+";	
		form.l2Temp.value = form.l2Temp.value + wdata[i].ifs2 + "+";		
		form.l2Temp.value = form.l2Temp.value + wdata[i].prot + "+";
		form.l2Temp.value = form.l2Temp.value + wdata[i].prot_number + "+";
		form.l2Temp.value = form.iptTemp.value + wdata[i].mac1 + "+";
		form.l2Temp.value = form.iptTemp.value + wdata[i].mac2 + "+";
		form.l2Temp.value = form.iptTemp.value + wdata[i].targets + "+";	
	}
	form.l2Temp.value = form.l2Temp.value + CheckConfirm[0].stat4 + "+";

	form.action="/goform/net_WebL2FilterGetValue";
	form.submit();
}

function funcProtSel(protNUM)
{
	if(protNUM==1){
		document.getElementById("prot_number").disabled="";
	}
	else{
		document.getElementById("prot_number").disabled="true";

		if(protNUM==0){
			document.getElementById("prot_number").value="";
		}
		if(protNUM==2){
			document.getElementById("prot_number").value="0x0800";
		}
		else if(protNUM==3){
			document.getElementById("prot_number").value="0x0805";
		}
		else if(protNUM==4){
			document.getElementById("prot_number").value="0x0806";
		}
		else if(protNUM==5){
			document.getElementById("prot_number").value="0x0808";
		}
		else if(protNUM==6){
			document.getElementById("prot_number").value="0x08FF";
		}
		else if(protNUM==7){
			document.getElementById("prot_number").value="0x6000";
		}
		else if(protNUM==8){
			document.getElementById("prot_number").value="0x6001";
		}
		else if(protNUM==9){
			document.getElementById("prot_number").value="0x6002";
		}
		else if(protNUM==10){
			document.getElementById("prot_number").value="0x6003";
		}
		else if(protNUM==11){
			document.getElementById("prot_number").value="0x6004";
		}
		else if(protNUM==12){
			document.getElementById("prot_number").value="0x6005";
		}
		else if(protNUM==13){
			document.getElementById("prot_number").value="0x6006";
		}
		else if(protNUM==14){
			document.getElementById("prot_number").value="0x6007";
		}
		else if(protNUM==15){
			document.getElementById("prot_number").value="0x6558";
		}
		else if(protNUM==16){
			document.getElementById("prot_number").value="0x6559";
		}
		else if(protNUM==17){
			document.getElementById("prot_number").value="0x80F3";
		}
		else if(protNUM==18){
			document.getElementById("prot_number").value="0x809B";
		}
		else if(protNUM==19){
			document.getElementById("prot_number").value="0x8100";
		}
		else if(protNUM==20){
			document.getElementById("prot_number").value="0x8137";
		}
		else if(protNUM==21){
			document.getElementById("prot_number").value="0x8191";
		}
		else if(protNUM==22){
			document.getElementById("prot_number").value="0x86DD";
		}
		else if(protNUM==23){
			document.getElementById("prot_number").value="0x880B";
		}
		else if(protNUM==24){
			document.getElementById("prot_number").value="0x884C";
		}
		else if(protNUM==25){
			document.getElementById("prot_number").value="0x8863";
		}
		else if(protNUM==26){
			document.getElementById("prot_number").value="0x8864";
		}
		else if(protNUM==27){
			document.getElementById("prot_number").value="0x8884";
		}
		else if(protNUM==28){
			document.getElementById("prot_number").value="0x9000";
		}
	}
}

function Layer2FilterCheckFormat(form)
{
	var error=0;
	
	if(!MacAddrIsOK_Except_Muilticast_Broadcast(form.mac1, 'Source MAC Address')){
		error=1;
	}

	if(document.getElementById("src_mac_sel").selectedIndex == 1 && !MacAddrIsNotNull(form.mac1)){
		error=1;
	}
	
	if(!MacAddrIsOK_Except_Muilticast_Broadcast(form.mac2, 'Destination MAC Address')){
		error=1;
	}

	if(document.getElementById("dst_mac_sel").selectedIndex == 1 && !MacAddrIsNotNull(form.mac2)){
		error=1;
	}
	
	return error;
}

function func_src_mac_sel(idx)
{
	if(idx == 0){	/* all */
		document.getElementById("mac1").style.display="none";
	}
	else {	/* single */
		document.getElementById("mac1").style.display="";
	}
}

function func_dst_mac_sel(idx)
{
	if(idx == 0){	/* all */
		document.getElementById("mac2").style.display="none";
	}
	else {	/* single */
		document.getElementById("mac2").style.display="";
	}
}

</script>
</head>
<body class=main onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(LAYER2_FILTER)</script></h1>
<fieldset>

<form name="qwe" id="myForm" method="POST" onSubmit="return stopSubmit()">
	{{ net_Web_csrf_Token() | safe }}
	<input type="hidden" name="l2Temp" id="iptTemp" value="" />
	<input type="hidden" id="idx" name="ipt_filter_idx" value="" /> 

	<DIV style="height:180px;">
		<table cellpadding="1" cellspacing="3" style="width:1100px;">
			<tr class="r2">
				<td style="width:350px;" align="left" valign="up">
					<table cellpadding="1" cellspacing="3" style="width:450px;">
						<tr class="r2">
							<td style="width:50px;">
								<script language="JavaScript">doc(IPT_FILTER_ENABLE)</script><br/>
							</td>
							<td style="width:150x;" align="left" valign="center">
								<input type="checkbox" id="stat" name="ipt_filter_enable">
							</td>
						</tr>
						<tr class="r2">
							<td style="width:50px;" align="left" valign="center">
								<script language="JavaScript">doc(IPT_FILTER_INTERFACE)</script>
							</td>
							<td style="width:150px;" align="left" valign="center">	
								<table>
									<tr class="r2">
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
						<tr class="r2">
							<td style="width:50px;" align="left" valign="center">
                                <script language="JavaScript">doc(PROT_NUM)</script>    
                                <!--<script language="JavaScript">doc(LAYER2_PROTOCOL)</script>-->
							</td>
							<td style="width:150px;" align="left" valign="center">
								<script language="JavaScript">iGenSel3('ipt_filter_prot', 'prot', prot, 'funcProtSel')</script>
							</td>
						</tr>
						<tr class="r2">
							<td style="width:50px;" align="left" valign="center">
								<!--<script language="JavaScript">doc(PROT_NUM)</script>-->
							</td>
							<td style="width:150px;" align="left" valign="center">
								 <input type="text" id=prot_number name="prot_number" size=10 maxlength=10> 
							</td>
						</tr>
						
					</table>	
				<td>
				<td style="width:650px;" align="left" valign="up">	
					<table cellpadding="1" cellspacing="3" style="width:650px;" id="tatget_table">
						<tr class="r2">
							<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">doc(Targets)</script>
							</td>
							<td align="left" valign="center">  	
								<script language="JavaScript">iGenSel2('ipt_filter_targets', 'targets', targets)</script>
							</td>
						</tr>
					</table>
					<table cellpadding="1" cellspacing="3" style="width:650px;" id="mac_config_table">
						<tr class="r2">
							<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">doc(SRC_MAC)</script></br>
							</td>
							<td style="width:100px;" align="left" valign="center">
								<select style="width:90px;" size=1 name="src_mac_sel" id="src_mac_sel" onchange="func_src_mac_sel(this.selectedIndex)">	
									<option value="all">All</option>
									<option value="single">Single</option>
								</select>
							</td>
							<td align="left" valign="center">  	    
						      		<input type="text" id=mac1 name="ipt_filter_haddr" size=17 maxlength=17>   
				          		</td>
						</tr>
						<tr class="r2">
							<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">doc(DST_MAC)</script></br>
							</td>
							<td style="width:100px;" align="left" valign="center">
								<select style="width:90px;" size=1 name="dst_mac_sel" id="dst_mac_sel" onchange="func_dst_mac_sel(this.selectedIndex)">	
									<option value="all">All</option>
									<option value="single">Single</option>
								</select>
							</td>
							<td align="left" valign="center">  	    
						      		<input type="text" id=mac2 name="ipt_filter_haddr2" size=17 maxlength=17>   
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
		<td width="400px" style="text-align:left;">
            <script language="JavaScript">fnbnB(addb, 'onClick=Add(myForm)')</script>
    		<script language="JavaScript">fnbnB(modb, 'onClick=Modify(myForm)')</script>
	      	<script language="JavaScript">fnbnB(delb, 'onClick=Del(myForm)')</script>
    		<script language="JavaScript">fnbnB(moveb, 'onClick=Move(myForm)')</script></td>
	  	<td width="300px" style="text-align:left;">
	      	<script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(myForm)', 'btnU')</script>
	  	    <!--<script language="JavaScript">fnbnB(detectb, 'onClick=Detect(myForm)')</script>-->
	  	</td>	
	</tr>
</table></p>


<div style="height:50px">
<table class=tf align=left border=12>
<tr ></tr>
</table>
</div>

<div style="width:1305px">
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
		<tr  align="center">
 			<th class = "s0" width="50px" ><script language="JavaScript">doc(IPT_FILTER_ENABLE)</script></th>
 			<th class = "s0" width="45px" ><script language="JavaScript">doc(IPT_FILTER_INDEX)</script></th>
  			<th class = "s0" width="240px" ><script language="JavaScript">doc(INPUT_IFS)</script></th>
			<th class = "s0" width="240px" ><script language="JavaScript">doc(OUTPUT_IFS)</script></th>
			<th class = "s0" width="250px"><script language="JavaScript">doc(Protocol)</script></th>
			<th class = "s0" width="120px"><script language="JavaScript">doc(SRC_MAC)</script></th>
			<th class = "s0" width="120px"><script language="JavaScript">doc(DST_MAC)</script></th>
			<th class = "s0" width="80px" ><script language="JavaScript">doc(Targets)</script></th>
		</tr>
	</table>
</div>

<div style="width:1305px; overflow-y:auto;">
	<table cellpadding=1 cellspacing=2 id="show_available_table" >	
		<tr align="center" >
 			<td width="50px"></td>
 			<td width="45px"></td>
  			<td width="240px"></td>
			<td width="240px"></td>
			<td width="250px"></td>
			<td width="120px"></td>
			<td width="120px"></td>
			<td width="80px"></td>	
            </tr>	
		<script language="JavaScript">ShowList1('tri')</script>
	</table>
</div>
</fieldset>
</body>
</html>

