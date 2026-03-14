<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(IPT_QOS_UP_LEVEL2_CONFIGURATION_EDRG902)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
var Mode2QosUp={{ net_Web_GetMode_WriteValue() | safe }};
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};

if (!debug) {
	var wdata = [
	{ctl:11100, idx:0,  stat:'0', ifs1:'wan1', prot:'2', ip1:'1.168.168.168', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'', port1:'25535', port2:'', port3:'', port4:'', port5:'', port6:'', mac:'', prio:'0'},
	{ctl:20202, idx:1, 	stat:'1', ifs1:'wan2', prot:'2', ip1:'', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'', port1:'', port2:'78', port3:'150', port4:'', port5:'10', port6:'11', mac:'F1:F2:F3:F4:F5:F6', prio:'1'},
	{ctl:12222, idx:2,  stat:'0', ifs1:'wan1', prot:'3', ip1:'', ip2:'192.168.168.168', ip3:'192.168.138.254', ip4:'', ip5:'10.1.0.1', ip6:'10.1.0.254', port1:'', port2:'21', port3:'80', port4:'', port5:'8', port6:'9', mac:'', prio:'2'}
	]
}
else{
	var wdata = [ {{ net_Web_IPT_QoS_Up_WriteValue() | safe }} ]
}

//net_Web_IPT_QoS_Up_WriteValue()

if(ProjectModel == MODEL_EDR_G903){
	if(Mode2QosUp == 0){	// router mode
		var ifs1 = [
		{ value:'all', text:'All' },
		{ value:'wan1',text:'WAN1' },
		{ value:'wan2',text:'WAN2' }
		];
	}
	else{	// bridge mode
		var ifs1 = [
		{ value:'all', text:'All' },
		{ value:'wan1',text:'WAN1' },
		{ value:'wan2',text:'WAN2' },
		{ value:'lan',text:'LAN' },
		];
	}
}
else{
	if(Mode2QosUp == 0){	// router mode
		var ifs1 = [
		{ value:'wan',text:'WAN' }
		];
	}
	else{	// bridge mode
		var ifs1 = [
		{ value:'all', text:'All' },
		{ value:'wan',text:'WAN' },
		{ value:'lan',text:'LAN' },
		];
	}
}

var addb = 'New/Insert';
var modb = 'Modify';
var moveb = 'Move';
var updb = 'Activate';
var delb = 'Delete';
var detectb = 'Policy Check';

var entryNUM=0;
var initEntry;
var max_total;

{% include "cvserver_data" ignore missing %}


var qos_chain = [ {value:'INPUT', text:'INPUT'}, {value:'OUTPUT', text:'OUTPUT'}, {value:'FORWARD', text:'FORWARD'}
]

var qos_io = [ {value:'i', text:'INPUT'}, {value:'o', text:'OUTPUT'}
]

var wtype = { ctl:4, idx:4, stat:3, ifs1:2, prot:2, ip1:5, ip2:5, ip3:5, ip4:5, ip5:5, ip6:5, port1:4, port2:4, port3:4, port4:4, port5:4, port6:4, mac:7, prio:2 };

var prot = [
	{ value:'1', text:'All' },
	{ value:'2', text:'TCP' },	
	{ value:'3', text:'UDP' },	
	{ value:'4', text:'ICMP' }
];

var prio = [
	{ value:'0', text:'Priority 0' },
	{ value:'1', text:'Priority 1' },
	{ value:'2', text:'Priority 2' },
	{ value:'3', text:'Priority 3' }  
];


function Total_Policy()
{
	document.getElementById("totalcnt").innerHTML = '('+wdata.length +'/' +max_total+')';
}

var myForm;
function fnInit(row) {
	//if(Mode2QosUp == 1)
	//	document.getElementById("ifs_table").style.display="none";
	if(ProjectModel == MODEL_EDR_G903){
		max_total = 256;
	}
	else{
		max_total = 64
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

	if(ProjectModel == MODEL_EDR_G903){
		document.getElementById("ifs_table").style.display="";
	}
	else{
		if(Mode2QosUp == 0)	// router mode
			document.getElementById("ifs_table").style.display="none";
		else	// bridge mode
			document.getElementById("ifs_table").style.display="";
	}

}


function ShowList(name) {

	with (document) {
		for (var i in wdata) {
			write('<tr id=' +name+i+ ' onClick=EditRow(' +i+ ') style="cursor:'+ptrcursor+'">');
			write('<td width=60px>'+ fnGetSelText(wdata[i].ifs, ifs) +'</td>');
			write('<td width=80px>'+ fnGetSelText(wdata[i].qos_io, qos_io) +'</td>');
			write('<td width=60px>'+ fnGetSelText(wdata[i].prot, prot) +'</td>');
			write('<td width=200px>'+ wdata[i].ip1+ '~' +wdata[i].ip2 +'</td>');
			write('<td width=120px>'+ wdata[i].port1+ '~' +wdata[i].port2 +'</td>');
			write('<td width=120px>'+ wdata[i].mac +'</td>');
			write('<td>'+ fnGetSelText(wdata[i].prio, prio) +'</td></tr>');
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
	
	fnLoadForm(myForm, wdata[rowidx], wtype);
/*	
	if(wdata[rowidx].ip3!="")
		document.getElementById("iprangeth2").value=getiprange(wdata[rowidx].ip2, wdata[rowidx].ip3);
	if(wdata[rowidx].ip6!="")
		document.getElementById("iprangeth1").value=getiprange(wdata[rowidx].ip5, wdata[rowidx].ip6);
*/
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
	cell.width="45";
	cell.innerHTML = i+1;
	row.appendChild(cell);
	
	if(ProjectModel == MODEL_EDR_G903){
		cell = document.createElement("td");
		cell.width="60";
		cell.innerHTML = fnGetSelText(wdata[i].ifs1, ifs1);
		row.appendChild(cell);
	}
	else{	// EDR-G902
		if(Mode2QosUp == 1){	// bridge mode
			cell = document.createElement("td");
			cell.width="60";
			cell.innerHTML = fnGetSelText(wdata[i].ifs1, ifs1);
			row.appendChild(cell);
		}
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
	cell.width="60";
	cell.innerHTML = fnGetSelText(wdata[i].prot, prot);
	row.appendChild(cell);	
	
	cell = document.createElement("td");
	cell.width="120";
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
	cell.width="60";
	
	if(((wdata[i].ctl%1000-wdata[i].ctl%100)/100)==0)
		cell.innerHTML = "All";
	else if(((wdata[i].ctl%1000-wdata[i].ctl%100)/100)==1)		
		cell.innerHTML = wdata[i].port1;	
	else
		cell.innerHTML = wdata[i].port2+ '</br>' + '~' +wdata[i].port3;
	
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width="120";
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
	cell.width="60";
	
	if((wdata[i].ctl%10)==0)
		cell.innerHTML = "All";
	else if((wdata[i].ctl%10)==1)
		cell.innerHTML = wdata[i].port4;	
	else 
		cell.innerHTML = wdata[i].port5+ '</br>' + '~' +wdata[i].port6;
	
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.width="120";
	if(((wdata[i].ctl-(wdata[i].ctl%10000))/10000)==2)
		cell.innerHTML = wdata[i].mac;
	else
		cell.innerHTML = "--"
	row.appendChild(cell);


	
	cell = document.createElement("td");
	cell.innerHTML = fnGetSelText(wdata[i].prio, prio );
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

function Add(form)
{
	if(QoSLikeCheckFormat(form)==1)
		return;

	var idx=prompt("Add / Insert before ", wdata.length+1);
	if(IndexRange(idx, wdata)==-1)
		return;	
	
	idx=idx-1;
	
	if(idx!=-1){
		if((wdata.length+1)<=max_total){
			var arrayLen = wdata.length;
			wdata[arrayLen] = new Array(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
			
			for(i=arrayLen-1; i>=idx; i--)
			{
				wdata[i+1].ctl=wdata[i].ctl;
				wdata[i+1].idx=i+1;
				wdata[i+1].stat=wdata[i].stat;
				wdata[i+1].ifs1=wdata[i].ifs1;
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
				wdata[i+1].prio=wdata[i].prio;
			}
			
			
			wdata[idx].idx=arrayLen;
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
				//wdata[idx].ip6 = ipadd(wdata[arrayLen].ip5, form.iprangeth1.value);
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
				//wdata[idx].ip3 = ipadd(wdata[arrayLen].ip2, form.iprangeth2.value);
				wdata[idx].ip3 = form.ip3.value;
			}
			else{}

			if(document.getElementById("tSel").selectedIndex==1){
				form.mac.value=mac_format(form.mac.value);
				wdata[idx].mac=form.mac.value;
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
			wdata[idx].prot=form.prot.value;
			wdata[idx].ifs1=form.ifs1.value;
			wdata[idx].prio=form.prio.value;
			
			
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
	if(QoSLikeCheckFormat(form)==1)
		return;

	var idx=prompt("Moving Policy ID : "+(entryNUM+1)+"; enter policy ID to move before.", entryNUM+1);
	if(MoveIndexRange(idx, wdata)==-1)
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
			wdata[i-1].prio=wdata[i].prio;
			
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
			wdata[i+1].prio=wdata[i].prio;
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
			//wdata[idx].ip6 = ipadd(wdata[arrayLen].ip5, form.iprangeth1.value);
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
			//wdata[idx].ip3 = ipadd(wdata[idx].ip2, form.iprangeth2.value);
			wdata[idx].ip3 = form.ip3.value;
		}
		else{}
	}

	if(document.getElementById("tSel").selectedIndex==1){
		form.mac.value=mac_format(form.mac.value);
		wdata[idx].mac=form.mac.value;
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
	
	wdata[idx].ifs1=form.ifs1.value;
	wdata[idx].prot=form.prot.value;
	wdata[idx].prio=form.prio.value;


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
	if(QoSLikeCheckFormat(form)==1)
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
		//wdata[entryNUM].ip6 = ipadd(wdata[entryNUM].ip5, form.iprangeth1.value);
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
		//wdata[entryNUM].ip3 = ipadd(wdata[entryNUM].ip2, form.iprangeth2.value);
		wdata[entryNUM].ip3 = form.ip3.value;
	}
	else{}

	if(document.getElementById("tSel").selectedIndex==1){
		form.mac.value=mac_format(form.mac.value);
		wdata[entryNUM].mac=form.mac.value;
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
	wdata[entryNUM].prot=form.prot.value;
	wdata[entryNUM].ifs1=form.ifs1.value;
	wdata[entryNUM].prio=form.prio.value;
	

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
		//wdata[i].ifs1 = "wan";
		
		form.qosTemp.value = form.qosTemp.value + wdata[i].ctl + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[i].stat + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[i].ifs1 + "+";			
		form.qosTemp.value = form.qosTemp.value + wdata[i].prot + "+";
		
		form.qosTemp.value = form.qosTemp.value + wdata[i].ip1 + "+";	
		form.qosTemp.value = form.qosTemp.value + wdata[i].ip2 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[i].ip3 + "+";	
		form.qosTemp.value = form.qosTemp.value + wdata[i].ip4 + "+";	
		form.qosTemp.value = form.qosTemp.value + wdata[i].ip5 + "+";	
		form.qosTemp.value = form.qosTemp.value + wdata[i].ip6 + "+";

		form.qosTemp.value = form.qosTemp.value + wdata[i].port1 + "+";	
		form.qosTemp.value = form.qosTemp.value + wdata[i].port2 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[i].port3 + "+";	
		form.qosTemp.value = form.qosTemp.value + wdata[i].port4 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[i].port5 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[i].port6 + "+";

		form.qosTemp.value = form.qosTemp.value + wdata[i].mac + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[i].prio + "+";	
	}
	form.action="/goform/net_WebQoSUpGetValue";
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
		document.getElementById("dst_port_single_config").disabled="";
		document.getElementById("dst_port_range_config").disabled="";
	}
	else{
		document.getElementById("src_port").disabled="true";
		document.getElementById("SrcPortSel").disabled="true";
		document.getElementById("src_port_single_config").disabled="true";
		document.getElementById("src_port_range_config").disabled="true";
		document.getElementById("dst_port").disabled="true";
		document.getElementById("DstPortSel").disabled="true";
		document.getElementById("dst_port_single_config").disabled="true";
		document.getElementById("dst_port_range_config").disabled="true";
	}
}

function funcSel(num)
{	
	if(num==0){	// ip mode
		document.getElementById("mac_config_table").style.display="none";
		document.getElementById("ip_config_tableth2").style.display="";
		document.getElementById("ip_config_tableth1").style.display="";
	}
	else{	// mac mode
		document.getElementById("mac_config_table").style.display="";
		document.getElementById("ip_config_tableth2").style.display="none";
		document.getElementById("ip_config_tableth1").style.display="none";
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


function ShowIfsField()
{	
	if(ProjectModel == MODEL_EDR_G903)
		document.write('<td width="60px"></td>');
	else{	// EDR-G902
		if(Mode2QosUp == 1)	// bridge mode
			document.write('<td width="60px"></td>');
	}
}

function PrintIfsTable()
{	
	if(ProjectModel == MODEL_EDR_G903)
		document.write('<td width="60px">'+OUTPUT_IFS+'</td>');
	else{	// EDR-G902
		if(Mode2QosUp == 1)	// bridge mode
			document.write('<td width="60px">'+OUTPUT_IFS+'</td>');
	}
}

function PrintDocDiv()
{	
	if(ProjectModel == MODEL_EDR_G903)
		document.write('<DIV style="width:860px">');
	else{
		if(Mode2QosUp == 0)	// router mode
			document.write('<DIV style="width:800px">');
		else	// bridge mode
			document.write('<DIV style="width:860px">');
	}
}

function PrintContextDiv()
{	
	if(ProjectModel == MODEL_EDR_G903)
		document.write('<DIV style="width:860px; height:171px; overflow-y:auto;">');
	else{
		if(Mode2QosUp == 0)	// router mode
			document.write('<DIV style="width:800px; height:171px; overflow-y:auto;">');
		else	// bridge mode
			document.write('<DIV style="width:860px; height:171px; overflow-y:auto;">');
	}
}


function Compare(r1, r2, t)	
{	
	/*	temp[0]	ip/mac	*/
	if((r1.ctl-(r1.ctl%10000))==(r2.ctl-(r2.ctl%10000))){
		t[0]=2;
	}
	else{
		t[0]=0;
	}
	
	//	temp[1]	protocol
	if(r1.prot=="all"){
		if(r2.prot=="all")
			t[1]=2;
		else
			t[1]=3;
	}
	else{
		if(r2.prot=="all")
			t[1]=1;
		else{
			if(r1.prot==r2.prot)
				t[1]=2;
			else
				t[1]=0;
		}
	}
	
	//	temp[2]	src ifs
	if(r1.ifs1=="all"){
		if(r2.ifs1=="all")
			t[2]=2;
		else
			t[2]=3;
	}
	else{
		if(r2.ifs1=="all")
			t[2]=1;
		else{
			if(r1.ifs1==r2.ifs1)
				t[2]=2;
			else
				t[2]=0;
		}
	}	

	//	temp[3]	src ip
	if(((r1.ctl%10000-r1.ctl%1000)/1000)==0){	// all
		if(((r2.ctl%10000-r2.ctl%1000)/1000)==0)
			t[3]=2;
		else
			t[3]=3;
	}

	else if(((r1.ctl%10000-r1.ctl%1000)/1000)==1){	// r1 single
		if(((r2.ctl%10000-r2.ctl%1000)/1000)==0){	//r2 all
			t[3]=1;
		}
		
		else if(((r2.ctl%10000-r2.ctl%1000)/1000)==1){	//r2 single
			if(IP2V(r1.ip1)==IP2V(r2.ip1))
				t[3]=2;
			else
				t[3]=0;
		}
	
		else{	//r2 range
			if(IP2V(r1.ip1)>=IP2V(r2.ip2) && IP2V(r1.ip1)<=IP2V(r2.ip3))
				t[3]=1;
			else
				t[3]=0;
		}				
	}
	else{	//r1 range
		if(((r2.ctl%10000-r2.ctl%1000)/1000)==0){	//r2 all
			t[3]=1;
		}
		else if(((r2.ctl%10000-r2.ctl%1000)/1000)==1){	//r2 single
			if(IP2V(r1.ip2)<=IP2V(r2.ip1) && IP2V(r2.ip1)<=IP2V(r1.ip3))
				t[3]=3;
			else
				t[3]=0;
		}
		else{ //r2 range
			if(IP2V(r1.ip2)==IP2V(r2.ip2) && IP2V(r1.ip3)==IP2V(r2.ip3))
				t[3]=2;
			else if(IP2V(r1.ip3)>=IP2V(r2.ip2) || IP2V(r1.ip2)<=IP2V(r2.ip3))
				t[3]=3;
			else
				t[3]=0;
		}
	}

	//	temp[4]	src port
	if(((r1.ctl%1000-r1.ctl%100)/100)==0){	// all
		if(((r2.ctl%1000-r2.ctl%100)/100)==0)
			t[4]=2;
		else
			t[4]=3;
	}

	else if(((r1.ctl%1000-r1.ctl%100)/100)==1){	// r1 single
		if(((r2.ctl%1000-r2.ctl%100)/100)==0){	//r2 all
			t[4]=1;
		}
		
		else if(((r2.ctl%1000-r2.ctl%100)/100)==1){	//r2 single
			if(r1.port1==r2.port1)
				t[4]=2;
			else
				t[4]=0;
		}
	
		else{	//r2 range
			if(r1.port1>=r2.port2 && r1.port1<=r2.port3)
				t[4]=1;
			else
				t[4]=0;
		}				
	}
	else{	//r1 range
		if(r1.port2==r2.port2 && r1.port3==r2.port3)
			t[4]=2;
		else if(r1.port3>=r2.port2)
			t[4]=3;
		else
			t[4]=0;
		
	}	
	
	//	temp[6]	dst ip
	if(((r1.ctl%100-r1.ctl%10)/10)==0){	// all
		if(((r2.ctl%100-r2.ctl%10)/10)==0)
			t[6]=2;
		else
			t[6]=3;
	}

	else if(((r1.ctl%100-r1.ctl%10)/10)==1){	// r1 single
		if(((r2.ctl%100-r2.ctl%10)/10)==0){	//r2 all
			t[6]=1;
		}
		
		else if(((r2.ctl%100-r2.ctl%10)/10)==1){	//r2 single
			if(IP2V(r1.ip4)==IP2V(r2.ip4))
				t[6]=2;
			else
				t[6]=0;
		}
	
		else{	//r2 range
			if(IP2V(r1.ip4)>=IP2V(r2.ip5) && IP2V(r1.ip4)<=IP2V(r2.ip6))
				t[6]=1;
			else
				t[6]=0;
		}				
	}
	else{	//r1 range
		if(((r2.ctl%100-r2.ctl%10)/10)==0){	//r2 all
			t[6]=1;
		}
		else if(((r2.ctl%100-r2.ctl%10)/10)==1){	//r2 single
			if(IP2V(r1.ip5)<=IP2V(r2.ip4) && IP2V(r2.ip4)<=IP2V(r1.ip6))
				t[6]=3;
			else
				t[6]=0;
		}
		else{ //r2 range
			if(IP2V(r1.ip5)==IP2V(r2.ip5) && IP2V(r1.ip6)==IP2V(r2.ip6))
				t[6]=2;
			else if(IP2V(r1.ip6)>=IP2V(r2.ip5) || IP2V(r1.ip5)<=IP2V(r2.ip6))
				t[6]=3;
			else
				t[6]=0;
		}
	}

	//	temp[7]	dst port
	if((r1.ctl%10)==0){	// all
		if((r2.ctl%10)==0)
			t[7]=2;
		else
			t[7]=3;
	}

	else if((r1.ctl%10)==1){	// r1 single
		if((r2.ctl%10)==0){	//r2 all
			t[7]=1;
		}
		
		else if((r2.ctl%10)==1){	//r2 single
			if(r1.port4==r2.port4)
				t[7]=2;
			else
				t[7]=0;
		}
	
		else{	//r2 range
			if(r1.port4>=r2.port5 && r1.port4<=r2.port6)
				t[7]=1;
			else
				t[7]=0;
		}				
	}
	else{	//r1 range
		if(r1.port5==r2.port5 && r1.port6==r2.port6)
			t[7]=2;
		else if(r1.port6>=r2.port5)
			t[7]=3;
		else
			t[7]=0;		
	}
	
	//	temp[8]	mac addr
	if((r1.ctl/10000)==2 && (r2.ctl/10000)==2){
		if(r1.mac==r1.mac)
			t[8]=2;
		else
			t[8]=0;
	}
}

function Detect()
{
	temp=new Array(-1,-1,-1,-1,-1,-1,-1,-1,-1);
	var total=0;
	for(i=0; i<wdata.length-1; i++){
		for(j=i+1; j<wdata.length; j++){
			if(wdata[i].stat==1 && wdata[j].stat==1){
				for(k=0; k<9; k++)
					temp[k]=-1;
				Compare(wdata[i], wdata[j], temp);
				/*
				alert("src ip="+temp[3]);
				alert("src port="+temp[4]);
				alert("dst ip="+temp[6]);
				alert("dst port="+temp[7]);
				*/
				total=1;
				total=total*(temp[3]);
				total=total*(temp[4]);
				total=total*(temp[6]);
				total=total*(temp[7]);
				if(temp[0]!=0 && total!=0){
					if((wdata[i].ctl-(wdata[i].ctl%10000))==10000 && (wdata[j].ctl-(wdata[j].ctl%10000))==10000){	// ip mode
						if(temp[1]!=0 && temp[2]!=0 && temp[5]!=0){	// the same protocol
							total=1;
							total=total*(temp[3]-1);
							total=total*(temp[4]-1);
							total=total*(temp[6]-1);
							total=total*(temp[7]-1);
							/*
							alert("ip/mac="+temp[0]);
							alert("protocol="+temp[1]);
							alert("src ifs="+temp[2]);
							alert("src ip="+temp[3]);
							alert("src port="+temp[4]);
							alert("dst ifs="+temp[5]);
							alert("dst ip="+temp[6]);
							alert("dst port="+temp[7]);
							alert("mac="+temp[8]);
							*/
							if(total!=0){
								/*
								alert("ip/mac="+temp[0]);
								alert("protocol="+temp[1]);
								alert("src ifs="+temp[2]);
								alert("src ip="+temp[3]);
								alert("src port="+temp[4]);
								alert("dst ifs="+temp[5]);
								alert("dst ip="+temp[6]);
								alert("dst port="+temp[7]);
								alert("mac="+temp[8]);
								*/
								if(wdata[i].prio==wdata[j].prio){
									alert("rule["+(j+1)+"] is included in rule["+(i+1)+"]");
								}
								else{
									alert("rule["+(j+1)+"] is masked by rule["+(i+1)+"]");
								}
							}
							else{
								/*
								alert("ip/mac="+temp[0]);
								alert("protocol="+temp[1]);
								alert("src ifs="+temp[2]);
								alert("src ip="+temp[3]);
								alert("src port="+temp[4]);
								alert("dst ifs="+temp[5]);
								alert("dst ip="+temp[6]);
								alert("dst port="+temp[7]);
								alert("mac="+temp[8]);
								*/
								total=1;
								total=total*(temp[3]-3);
								total=total*(temp[4]-3);
								total=total*(temp[6]-3);
								total=total*(temp[7]-3);
								
								if(total==0 && wdata[i].prio!=wdata[j].prio){
									alert("rule["+(j+1)+"] is cross conflict with rule["+(i+1)+"]");
								}
							}
						}
					}
					else if((wdata[i].ctl-(wdata[i].ctl%10000))==20000 && (wdata[j].ctl-(wdata[j].ctl%10000))==20000){	// mac mode
						if(temp[8]==2)
							alert("rule["+(i+1)+"] and rule["+(j+1)+"] had mac redundent");
					}
					else;
				}
	
			}
		}
	}
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
					if(wdata[i].prio==wdata[j].prio){
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
					if(total==0 && wdata[i].prio!=wdata[j].prio){
						alert("rule["+j+"] is cross conflict with rule["+i+"]");
					}
				}	
			}
*/
</script>
</head>
<body class=main onLoad=fnInit(0)>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[2].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[2])</script>
<script language="JavaScript">mainh()</script>	

<form name="qwe" id="myForm" method="POST" onSubmit="return stopSubmit()">
	{{ net_Web_csrf_Token() | safe }}
	<input type="hidden" name="qosTemp" id="qosTemp" value="" />
	<input type="hidden" id="idx" name="ipt_qos_idx" value="" /> 
	<input type="hidden" id="ctl" name="ipt_qos_ctl" value="" /> 

	<DIV style="height:180px;">
		<table cellpadding="1" cellspacing="3" style="width:900px;">
			<tr class="r2">
				<td style="width:300px;" align="left" valign="top">
					<table cellpadding="1" cellspacing="3" style="width:300px;">
						<tr class="r2">
							<td style="width:50px;" align="left" valign="top">
								<script language="JavaScript">doc(IPT_FILTER_ENABLE)</script><br/>
							</td>
							<td style="width:150x;" align="left" valign="top">
								<input type="checkbox" id="stat" name="ipt_qos_enable">
							</td>
						</tr>
						<tr class="r2" id="ifs_table">
							<td style="width:50px;" align="left" valign="top">
								<script language="JavaScript">doc(IPT_FILTER_IP_TO)</script>
							</td>
							<td style="width:150px;" align="left" valign="top">	    
								<script language="JavaScript">iGenSel2('ipt_qos_ifs1', 'ifs1', ifs1)</script>						
							</td>
						</tr>
						<tr class="r2">
							<td style="width:50px;" align="left" valign="top">
								<script language="JavaScript">doc(Protocol)</script>    
							</td>
							<td style="width:150px;" align="left" valign="top">
								<script language="JavaScript">iGenSel3('ipt_qos_prot', 'prot', prot, 'funcProtSel')</script>
							</td>
						</tr>
						
						<tr class="r2">
							<td style="width:50px;" align="left" valign="top">
								<script language="JavaScript">doc(IPT_SERVICE)</script>
							</td>
							<td style="width:150px;" align="left" valign="top">
								<select size=1 name="tSel" id="tSel" onchange="funcSel(this.selectedIndex);" >
									<option value="ipqos">By IP</option>
									<option value="macqos">By MAC</option>
								</select>
							</td>
						</tr>

						<tr class="r2">
							<td style="width:100px;" align="left" valign="top">
								<script language="JavaScript">doc(IPT_QOS_PRIO)</script>
							</td>
							<td style="width:600px;" align="left" valign="top">  	
								<script language="JavaScript">iGenSel2('prio', 'prio', prio)</script>
							</td>
						</tr>
						
					</table>	
				<td>
				<td style="width:600px;" align="left" valign="up">	
					
					<table cellpadding="1" cellspacing="3" style="width:600px;" id="mac_config_table" style="display:none">
						<tr class="r2">
							<td style="width:100px;" align="left" valign="center">
								<script language="JavaScript">doc(IPT_MAC)</script></br>
							</td>
							<td style="width:600px;" align="left" valign="center">  	    
						      		<input type="text" id=mac name="ipt_qos_haddr" size=17 maxlength=17>   
				          		</td>
						</tr>
					</table>

					<table cellpadding="1" cellspacing="3" style="width:600px;" id="ip_config_tableth2">
						<tr class="r2">
							<td style="width:100px;" align="left" valign="center">
								<script language="JavaScript">doc(SRC_IP)</script>
							</td>
							<td style="width:600px;" align="left" valign="center">
								<table>
									<tr class="r2">
										<td style="width:30px;" align="left" valign="center">
											<select size=1 name="SrcIPSel" id="SrcIPSel" onchange="funcSrcIPSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td>
										<td id="src_ip_all_config" align="left" valign="center">  				
							   			</td>
										<td id="src_ip_single_config" align="left" valign="center" style="display:none">  				
								  			
								  			<input type="text" id=ip1 name="ipt_qos_ip_start" size=15 maxlength=15>
									   	</td>
									   	<td id="src_ip_range_config" align="left" valign="center" style="display:none">  				
								  			<input type="text" id=ip2 name="ipt_qos_ip_start1" size=15 maxlength=15>
								  			~
									       	<input type="text" id=ip3 name="ipt_qos_ip_end1" size=15 maxlength=15> 
									   	</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table cellpadding="1" cellspacing="3" style="width:600px;" id="port_config_tableth2">
						<tr class="r2">
							<td style="width:100px;" id="src_port" align="left" valign="center">
								<script language="JavaScript">doc(SRC_PORT)</script>
							</td>
							<td style="width:600px;" align="left" valign="center">
								<table>
									<tr class="r2">
										<td style="width:30px;" align="left" valign="center">
											<select size=1 name="SrcPortSel" id="SrcPortSel" onchange="funcSrcPortSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td>
										<td id="src_port_all_config" align="left" valign="center" >
								        </td>
								        <td id="src_port_single_config" align="left" valign="center" style="display:none">       	  	
								            <input type="text" id=port1 name="ipt_qos_port_start" size=5 maxlength=5> 
								        </td>
								        <td id="src_port_range_config" align="left" valign="center"  style="display:none">     	  	
								            <input type="text" id=port2 name="ipt_qos_port_start1" size=5 maxlength=5> 
								            ~                
								            <input type="text" id=port3 name="ipt_qos_port_end1" size=5 maxlength=5>
								        </td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table cellpadding="1" cellspacing="3" style="width:600px;" id="ip_config_tableth1">
						<tr class="r2">
							<td style="width:100px;" align="left" valign="center">
								<script language="JavaScript">doc(DST_IP)</script>
							</td>
							<td style="width:600px;" align="left" valign="center">
								<table>
									<tr class="r2">
										<td style="width:30px;" align="left" valign="center">
											<select size=1 name="DstIPSel" id="DstIPSel" onchange="funcDstIPSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td> 
										<td id="dst_ip_all_config" align="left" valign="center" >  				
									   	</td>
										<td id="dst_ip_single_config" align="left" valign="center" style="display:none">  				
								  			
								  			<input type="text" id=ip4 name="dst_ipt_qos_ip_start" size=15 maxlength=15>
									   	</td>
									   	<td id="dst_ip_range_config" align="left" valign="center" style="display:none">  				
								  			
								  			<input type="text" id=ip5 name="dst_ipt_qos_ip_start1" size=15 maxlength=15>
								  			~
									       	<input type="text" id=ip6 name="dst_ipt_qos_ip_end1" size=15 maxlength=15> 
									   	</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<table cellpadding="1" cellspacing="3" style="width:600px;" id="port_config_tableth1">
						<tr class="r2">
							<td style="width:100px;" id="dst_port" align="left" valign="center">
								<script language="JavaScript">doc(DST_PORT)</script>
							</td>
							<td style="width:600px;" align="left" valign="center">
								<table>
									<tr class="r2">
										<td  style="width:30px;" align="left" valign="center">
											<select size=1 name="DstPortSel" id="DstPortSel" onchange="funcDstPortSel(this.selectedIndex)">	
												<option value="all">All</option>
												<option value="single">Single</option>
												<option value="range">Range</option>
											</select>
										</td>
										<td id="dst_port_all_config" align="left" valign="center">
								        </td>
								        <td id="dst_port_single_config" align="left" valign="center" style="display:none">
							           	  	
								            <input type="text" id=port4 name="dst_ipt_qos_port_start" size=5 maxlength=5> 
								        </td>
								        <td id="dst_port_range_config" align="left" valign="center" style="display:none">     	  	
								            <input type="text" id=port5 name="dst_ipt_qos_port_start1" size=5 maxlength=5> 
								            ~                
								            <input type="text" id=port6 name="dst_ipt_qos_port_end1" size=5 maxlength=5>
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

<DIV style="height:30px">
	<table class="tf" align="left" valign="up">
    	<tr>
        	<td><script language="JavaScript">fnbnB(addb, 'onClick=Add(myForm)')</script></td>
        	<td width="15px"></td>
        	<td><script language="JavaScript">fnbnB(moveb, 'onClick=Move(myForm)')</script></td>
          	<td width="15"></td>
          	<td><script language="JavaScript">fnbnB(modb, 'onClick=Modify(myForm)')</script></td>
          	<td width="15px"></td>
          	<td><script language="JavaScript">fnbnB(delb, 'onClick=Del(myForm)')</script></td>
		</tr>
	</table>
</DIV>
<br>
<hr>
<br>

<table cellpadding=1 cellspacing=2 style="width:200px;">	
	<tr class="r0">
			<td colspan="8">
				<script language="JavaScript">doc(IPT_QOS_LIST)</script>
			</td>
			<td id = "totalcnt" align="left"></td>
	</tr>
</table>

<script language="JavaScript">PrintDocDiv()</script>
	<table cellpadding=1 cellspacing=2>	
		<tr class="r5" align="center">
 			<td width="50px"><script language="JavaScript">doc(IPT_FILTER_ENABLE)</script></td>
 			<td width="45px"><script language="JavaScript">doc(IPT_FILTER_INDEX)</script></td>
			<script language="JavaScript">PrintIfsTable()</script>
			<td width="100px"><script language="JavaScript">doc(Protocol)</script></td>
			<td width="120px"><script language="JavaScript">doc(SRC_IP)</script></td>
			<td width="60px"><script language="JavaScript">doc(SRC_PORT)</script></td>
			<td width="120px"><script language="JavaScript">doc(DST_IP)</script></td>
			<td width="60px"><script language="JavaScript">doc(DST_PORT)</script></td>
			<td width="120px"><script language="JavaScript">doc(IPT_MAC)</script></td>
			<td ><script language="JavaScript">doc(IPT_QOS_PRIO)</script></td>
		</tr>
	</table>
</DIV>
<br>

<script language="JavaScript">PrintContextDiv()</script>
	<table cellpadding=1 cellspacing=2 id="show_available_table" >	
		<tr align="center" >
 			<td width="50px"></td>
 			<td width="45px"></td>
  			<script language="JavaScript">ShowIfsField()</script>
			<td width="100px"></td>
			<td width="120px"></td>
			<td width="60px"></td>
			<td width="120px"></td>
			<td width="60px"></td>
			<td width="120px"></td>
			<td></td>		
		</tr>	
		<script language="JavaScript">ShowList1('tri')</script>
	</table>
</DIV>
<DIV style="height:30px">
	<table class="tf" align="left" valign="top">
    	<tr>      	
          	<td><script language="JavaScript">fnbnBID(updb, 'onClick=Activate(myForm)', 'btnU')</script></td>
		</tr>
	</table>
</DIV>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

