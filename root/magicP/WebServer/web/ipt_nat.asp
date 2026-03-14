<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

checkMode(<% net_Web_GetMode_WriteValue(); %>);
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
var ModelVLAN = <% net_Web_GetModel_VLAN_WriteValue(); %>;
checkCookie();
if (!debug) {
	var wdata = [
		{srv:1, idx:0,  stat:'1', ifs:'wan1', prot:'', ip1:'1.168.168.168', ip2:'192.168.4.252', ip3:'', ip4:'', ip5:'', ip6:'', ip7:'', ip8:'', ip9:'', ip10:'', port1:'', port2:''},
		{srv:3, idx:1,  stat:'1', ifs:'wan1', prot:'', ip1:'', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'10.1.0.168', ip7:'10.1.0.254', ip8:'192.168.127.1', ip9:'192.168.127.50', ip10:'', port1:'', port2:''},
		{srv:2, idx:2,  stat:'1', ifs:'default', prot:'', ip1:'', ip2:'', ip3:'192.168.168.168', ip4:'192.168.168.200', ip5:'', ip6:'', ip7:'', ip8:'', ip9:'', ip10:'', port1:'', port2:''},
		{srv:4, idx:3,  stat:'1', ifs:'wan2', prot:'', ip1:'', ip2:'', ip3:'', ip4:'', ip5:'', ip6:'', ip7:'', ip8:'', ip9:'', ip10:'168.5.2.1', port1:'800', port2:'21'}
	];
	var WanInfo = [{wan_ip:'192.168.1.91', df_wan:0 }, {wan_ip:'192.168.1.97', df_wan:1 }];
	var CheckConfirm = [ { stat1:1, stat2:1, timer:100 } ];
}

else{
	var wdata = [ <% net_Web_IPT_NAT_WriteValue(); %> ];
	var WanInfo = [ <% net_Web_IPT_WANInfo_WriteValue(); %> ];
	if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
		var vlanInfo = [ <% net_Web_NAT_vconf_info_WriteValue(); %> ];
	}
	var CheckConfirm = [ <% net_Web_Confirm_WriteValue(); %> ];
	<%net_Web_show_value('SRV_VCONF');%>
	var NoWAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
	<%net_Web_show_value('SRV_IP_CLIENT');%>

	var one_to_one_ifs_list = [ <% net_Web_nat_show_ifs_table(); %>  ];

	<%net_Web_show_value('SRV_BRG');%>
	<%net_Web_show_value('SRV_ZONE_BRG');%>
}

// net_Web_IPT_WANInfo_WriteValue()
//	net_Web_Confirm_WriteValue();



/*var ifs1 = [ < net_Web_NAT_IFS1_WriteValue(); > ];
var ifs2 = [ < net_Web_NAT_IFS2_WriteValue(); > ];*/
var ifs1 = [ <% net_Web_NAT_IFS_WriteValue(0); %> ];
var ifs2 = [ <% net_Web_NAT_IFS_WriteValue(1); %> ];
var brg_ifs	= [ <% net_Web_NAT_show_brgIfs_WriteValue(); %> ];

var vrrp_binding_tbl = [ <% net_Web_NAT_vrrpBinding_WriteValue(); %> ];

var prot = [
	{ value:'1', text:'TCP' },	
	{ value:'2', text:'UDP' },	
	{ value:'3', text:'TCP & UDP' }
];

var max_total;
if(ProjectModel == MODEL_EDR_G903){
	max_total = 256;
}
else{
	max_total = 128
}

var newb = 'Add';
var moveb = 'Move';

var entryNUM=0;
var initEntry;

<!--#include file="cvserver_data"-->

var wtype = { srv:4, idx:4, stat:3, ifs:2, prot:2, ip1:5, ip2:5, ip3:5, ip4:5, ip5:5, ip6:6, ip7:6, ip8:6, ip9:6, ip10:6, port1:4, port2:4};
var myForm;

var selstate = { type:'select', id:'vrrp_binding', name:'vrrp_binding', size:1, onChange:'', option:vrrp_binding_tbl };

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

function NatLikeCheckFormat(form)
{
	var error=0;

	if(form.name.value != "" && isSymbol_static_route(form.name, Name_)) {
		error=1;
	}
	
	if(form.SrvSel.value=='onetoone'){
		if(!IpAddrNotMcastIsOK(form.ip1, 'LAN/DMZ IP')){
			error=1;
		}
		if(!IpAddrNotMcastIsOK(form.ip2, 'WAN IP')){
			error=1;
		}
	}
	else if(form.SrvSel.value=='ntoone'){
		if(!IpAddrNotMcastIsOK(form.ip3, 'LAN IP (initial)')){
			error=1;
		}
		if(!IpAddrNotMcastIsOK(form.ip4, 'LAN IP (end)')){
			error=1;
		}
		if(!ipRange(form.ip3, form.ip4, 'LAN IP')){
			error=1;
		}
	}
	else if(form.SrvSel.value=='nton'){
		if(!IpAddrNotMcastIsOK(form.ip6, 'LAN IP (initial)')){
			error=1;
		}
		if(!IpAddrNotMcastIsOK(form.ip7, 'LAN IP (end)')){
			error=1;
		}
		if(!ipRange(form.ip6, form.ip7, 'LAN IP')){
			error=1;
		}
		
		if(!IpAddrNotMcastIsOK(form.ip8, 'WAN IP (initial)')){
			error=1;
		}
		if(!IpAddrNotMcastIsOK(form.ip9, 'WAN IP (end)')){
			error=1;
		}
		if(!ipRange(form.ip8, form.ip9, 'WAN IP')){
			error=1;
		}
		if(form.stat.checked==true && IpAddrRangCnt(form.ip8.value, form.ip9.value)>254){
			alert(MsgHead[0]+'WAN IP Range can\'t over 254');
			error=1;
		}
	}
	else{
		if(!isPort(form.port1, 'WAN Port')){
			error=1;
		}
		if(!IpAddrNotMcastIsOK(form.ip10, 'LAN/DMZ IP')){
			error=1;
		}
		if(!isPort(form.port1, 'LAN/DMZ Port')){
			error=1;
		}
	}
	return error;
}

var ifs_sel;
var seliface = { type:'select', id:'otoifid', name:'otoifid', size:1, onChange:'fnChgShowIfsIP(this.value)', option:ifs_sel };
function set_121_ifs(){
	var sel, new_option, i;	
	sel = document.getElementById('otoifid');   
	for(i=0;i<NoWAN;i++){
		new_option = new Option('WAN'+((NoWAN<=1)?'':(i+1)), (4096+i));
		sel.options.add(new_option);			
	}
	for(i=0;i<SRV_VCONF.length;i++){			
		new_option = new Option(SRV_VCONF[i].ifname, SRV_VCONF[i].vid);
		sel.options.add(new_option);			
	}
	for(i=0;i<brg_ifs.length;i++){			
		new_option = new Option(brg_ifs[i].text, brg_ifs[i].value);
		sel.options.add(new_option);			
	}
}

function fnChgShowIfsIP(val) 
{
	var i;
	var j;
	
	if(val == 4096){
		document.getElementById("wan1").value = WanInfo[0].wan_ip;
	}
	else if(val > 8000){ // bridge
		for(j=0; j<SRV_BRG.length; j++){
			if(SRV_BRG[j].bridge_group_id == val ){
				document.getElementById("wan1").value = SRV_BRG[j].ip;
				return;
			}
		}
		for(j=0; j<SRV_ZONE_BRG.length; j++){
			if(SRV_ZONE_BRG[j].bridge_group_id == val ){
				document.getElementById("wan1").value = SRV_ZONE_BRG[j].ip;
				return;
			}
		}
	}
	else{
		for(i=0; i<SRV_VCONF.length; i++){
			if(val == SRV_VCONF[i].vid ){
				document.getElementById("wan1").value = SRV_VCONF[i].ip;
				break;	
			}
		}	
	}
}

function fnInit(row) {

	myForm = document.getElementById('myForm');
	initEntry=1;
	myForm.wan1.value=WanInfo[0].wan_ip;
	myForm.wan2.value=WanInfo[1].wan_ip;
	
	document.getElementById("wan1").disabled="true";
	document.getElementById("wan2").disabled="true";

	if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
		document.getElementById("vlan").disabled="true";
	}
	
	funcSrvSel(0);
	document.getElementById("SrvSel").selectedIndex=0;
	document.getElementById("ifs2").selectedIndex=0;
	set_121_ifs();
	if(wdata.length > 0)
		EditRow1(row, 0); 
	
	document.getElementById('otoifid').style.width='112px';

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

function IfsSelect(idx, WhatIfs)
{
	var i=0;
	var find = RETURN_FALSE;
	
	for(i=0; i<=WhatIfs.length-1; i++){
		if(wdata[idx].ifs == WhatIfs[i].value ){
			find = RETURN_TRUE;
			break;	
		}
	}
	
	if(find == RETURN_TRUE)
		return i;
	else	// not fine match ifs, we set index 0 in force.
		return 0;
}

function IpSelect(idx, WhatIfs)
{
	var i=0;
	var find=0;
	
	for(i=0; i<WhatIfs.length; i++){
		if(wdata[idx].otoifid == WhatIfs[i].vid ){
			find = RETURN_TRUE;
			break;	
		}
	}

	if(find == RETURN_TRUE)
		return WhatIfs[i].ip;
	else
		return "0.0.0.0"
}

function EditRow1(row, indicate) 
{
//	fnShowProp('aaaaa'+i, row);
	var rowidx;
	var j;
	if(initEntry==1 || indicate==1){
		rowidx = row;
		initEntry = 0;
	}
	else{
		rowidx = row.rowIndex - 1;
	}
	
	fnLoadForm(myForm, wdata[rowidx], wtype);
	ChgColor('tri', wdata.length, rowidx);

	/* set to index 1 to prevent the empty option when vlan's ifs is not exist.*/
	document.getElementById("ifs1").selectedIndex = 0;
	document.getElementById("ifs2").selectedIndex = 0;

	if(wdata.length==0){
		funcSrvSel(0);
		document.getElementById("SrvSel").selectedIndex=0;
		document.getElementById("ifs2").selectedIndex=0;
	}

	entryNUM = rowidx;
	
	if(wdata[rowidx].srv==1){	
		funcSrvSel(0);
		document.getElementById("SrvSel").selectedIndex=0;
		document.getElementById("ifs2").selectedIndex = IfsSelect(rowidx, ifs2);

	}
	else if(wdata[rowidx].srv==2){
		funcSrvSel(1);
		document.getElementById("SrvSel").selectedIndex=1;
		document.getElementById("ifs1").selectedIndex = IfsSelect(rowidx, ifs1);

		funcWAN(document.getElementById("ifs1").selectedIndex);
	
		if(wdata[rowidx].otoifid==4096){
			document.getElementById("wan1").value = WanInfo[0].wan_ip;
		}
		else if(wdata[rowidx].otoifid > 8000){ // bridge
			for(j=0; j<SRV_BRG.length; j++){
				if(SRV_BRG[j].bridge_group_id == wdata[rowidx].otoifid ){
					document.getElementById("wan1").value = SRV_BRG[j].ip;
					break;
				}
			}
			for(j=0; j<SRV_ZONE_BRG.length; j++){
				if(SRV_ZONE_BRG[j].bridge_group_id == wdata[rowidx].otoifid ){
					document.getElementById("wan1").value = SRV_ZONE_BRG[j].ip;
					break;
				}
			}
		}
		else{
			document.getElementById("wan1").value = IpSelect(rowidx, SRV_VCONF);		
		}
	}
	else if(wdata[rowidx].srv==3){
		funcSrvSel(2);
		document.getElementById("SrvSel").selectedIndex=2;
		document.getElementById("ifs2").selectedIndex = IfsSelect(rowidx, ifs2);
	
	}	
	else{
		funcSrvSel(3);
		document.getElementById("SrvSel").selectedIndex=3;
		document.getElementById("ifs2").selectedIndex = IfsSelect(rowidx, ifs2);
		
	}
	document.getElementById("wan1").disabled="true";
	document.getElementById("wan2").disabled="true";

	if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
		document.getElementById("vlan").disabled="true";
	}

}

/*	wdata[i].srv = 	1 -> N-1
 *					2 -> 1-1
 *					3 -> port forwarding
 *
 */

function addRow(i)
{
	var ifs_name;
	var j;
	
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
	ifs_name = fnGetSelText(wdata[i].otoifid, one_to_one_ifs_list);
	cell.innerHTML = split_string_by_br(ifs_name, 16);
	row.appendChild(cell);

	cell = document.createElement("td");
	if(wdata[i].srv==3)
		cell.innerHTML = fnGetSelText(wdata[i].prot, prot);
	else
		cell.innerHTML = '--';
	row.appendChild(cell);
	
	cell = document.createElement("td");	
	if(wdata[i].srv==1)
		cell.innerHTML = wdata[i].ip1;
	else if(wdata[i].srv==2)
		cell.innerHTML = wdata[i].ip3 + '</br>' + '~' + wdata[i].ip4;
	else if(wdata[i].srv==4)
		cell.innerHTML = wdata[i].ip6 + '</br>' + '~' + wdata[i].ip7;
	else
		cell.innerHTML = wdata[i].ip10;
	row.appendChild(cell);

	cell = document.createElement("td");	
	if(wdata[i].srv==3)	//port forwarding
        cell.innerHTML = wdata[i].port2;
	else
		cell.innerHTML = '--';
	row.appendChild(cell);

	cell = document.createElement("td");	
	if(wdata[i].srv==1)
		cell.innerHTML = wdata[i].ip2;	
	else if(wdata[i].srv==2){
		if(ProjectModel == MODEL_EDR_G903){		
			if(wdata[i].ifs=="default"){
				if(WanInfo[0].df_wan==1)
					cell.innerHTML = WanInfo[0].wan_ip;
				else
					cell.innerHTML = WanInfo[1].wan_ip;
			}
			else if(wdata[i].ifs=="wan1")
				cell.innerHTML = WanInfo[0].wan_ip;
			else
				cell.innerHTML = WanInfo[1].wan_ip;
		}
		else{	// EDR-G902 or EDR-810
			if(wdata[i].otoifid==4096){
				cell.innerHTML = WanInfo[0].wan_ip;
			}
			else if(wdata[i].otoifid > 8000){ // bridge
				for(j=0; j<SRV_BRG.length; j++){
					if(SRV_BRG[j].bridge_group_id == wdata[i].otoifid ){
						cell.innerHTML = SRV_BRG[j].ip;
						break;
					}
				}
				for(j=0; j<SRV_ZONE_BRG.length; j++){
					if(SRV_ZONE_BRG[j].bridge_group_id == wdata[i].otoifid ){
						cell.innerHTML = SRV_ZONE_BRG[j].ip;
						break;
					}
				}
			}
			else{
				cell.innerHTML = IpSelect(i, SRV_VCONF);		
				//cell.innerHTML = "--";		
			}
		}
	}
	else if(wdata[i].srv==4)
		cell.innerHTML = wdata[i].ip8 + '</br>' + '~' + wdata[i].ip9;
	else
		cell.innerHTML = '--';
	
	row.appendChild(cell);

	cell = document.createElement("td");	
	if(wdata[i].srv==3)	//port forwarding
		cell.innerHTML = wdata[i].port1;	// wan port
	else
		cell.innerHTML = '--';
	row.appendChild(cell);
	
	cell = document.createElement("td");	
	cell.innerHTML = fnGetSelText(wdata[i].vrrp_binding, vrrp_binding_tbl);
	row.appendChild(cell);
	
	cell = document.createElement("td");	
	cell.innerHTML = split_string_by_br(wdata[i].name, 45);
	row.appendChild(cell);
	
	row.style.Color = "black";
	var j=i+1;
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this, 0)};
	row.style.cursor=ptrcursor;
	row.align="center";

	document.getElementById("totalpolicy").innerHTML = '('+wdata.length +'/' +max_total+')';

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

function Check121Rules()
{
	var idx;
	var total=0;
	for(idx=0; idx<wdata.length; idx++){
		if(wdata[idx].srv==1 && wdata[idx].stat==1)
			total++;
	}
	return total;
}
function New(form)
{
	/*
	if(Check121Rules()==128 && form.stat.checked==true && document.getElementById("SrvSel").selectedIndex==0){
		alert("1-1 can\'t more than 128 rules");
		return;
	}
	*/

	if(NatLikeCheckFormat(form)==1)
		return;

	var idx=prompt("Add to index ", wdata.length+1);

	if(IndexRangeAndInputRange(idx, wdata, 1, max_total)==-1)
		return;

	
	idx=idx-1;
	
	if(idx!=-1){
		if((wdata.length+1)<=max_total){
			var arrayLen = wdata.length;
			
			wdata[arrayLen]=new Array(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
			for(i=arrayLen-1; i>=idx; i--)
			{	
				wdata[i+1].srv=wdata[i].srv;	
				wdata[i+1].idx=i+1;
				wdata[i+1].stat=wdata[i].stat;
				wdata[i+1].ifs=wdata[i].ifs;
				wdata[i+1].prot=wdata[i].prot;
				wdata[i+1].ip1=wdata[i].ip1;
				wdata[i+1].ip2=wdata[i].ip2;
				wdata[i+1].ip3=wdata[i].ip3;
				wdata[i+1].ip4=wdata[i].ip4;
				wdata[i+1].ip5=wdata[i].ip5;
				wdata[i+1].ip6=wdata[i].ip6;
				wdata[i+1].ip7=wdata[i].ip7;
				wdata[i+1].ip8=wdata[i].ip8;
				wdata[i+1].ip9=wdata[i].ip9;
				wdata[i+1].ip10=wdata[i].ip10;
				wdata[i+1].port1=wdata[i].port1;
				wdata[i+1].port2=wdata[i].port2;
				wdata[i+1].otoifid=wdata[i].otoifid;
				wdata[i+1].vrrp_binding=wdata[i].vrrp_binding;
				wdata[i+1].name=wdata[i].name;
			}

			//wdata[arrayLen].idx=arrayLen;
			wdata[idx].idx=idx;
			
			if(form.stat.checked==true)
				wdata[idx].stat=1;
			else
				wdata[idx].stat=0;

			wdata[idx].prot="";
			wdata[idx].ip1="";
			wdata[idx].ip2="";
			wdata[idx].ip3="";
			wdata[idx].ip4="";
			wdata[idx].ip5="";
			wdata[idx].ip6="";
			wdata[idx].ip7="";
			wdata[idx].ip8="";
			wdata[idx].ip9="";
			wdata[idx].ip10="";
			wdata[idx].port1="";
			wdata[idx].port2="";
			wdata[idx].otoifid="";
			wdata[idx].vrrp_binding="";
			wdata[idx].name="";

			if(document.getElementById("SrvSel").selectedIndex==1)
				wdata[idx].ifs=form.ifs1.value;
			else
				wdata[idx].ifs=form.ifs2.value;
			
			if(document.getElementById("SrvSel").selectedIndex==0){
				wdata[idx].srv = 1;
				wdata[idx].ip1 = form.ip1.value;
				wdata[idx].ip2 = form.ip2.value;
			}
			else if(document.getElementById("SrvSel").selectedIndex==1){
				wdata[idx].srv = 2;
				wdata[idx].ip3 = form.ip3.value;
				wdata[idx].ip4 = form.ip4.value;

				if(ProjectModel == MODEL_EDR_G903){		
					if(form.ifs1.value=="default"){
						if(WanInfo[0].df_wan==1)
							wdata[idx].ip5 = WanInfo[0].wan_ip;
						else
							wdata[idx].ip5 = WanInfo[1].wan_ip;
					}
					else if(form.ifs1.value=="wan1")
						wdata[idx].ip5 = WanInfo[0].wan_ip;
					else
						wdata[idx].ip5 = WanInfo[1].wan_ip;
				}
				else{	// EDR-G902
					if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
						if(wdata[idx].ifs=="WAN" || wdata[idx].ifs=="wan1" || wdata[idx].ifs=="default")
							wdata[idx].ip5 = WanInfo[0].wan_ip;
						else{
							wdata[idx].ip5 = IpSelect(idx, vlanInfo);
							
						}
					}
					else{
						wdata[idx].ip5 = WanInfo[0].wan_ip;
					}
				}		
				
			}
			else if(document.getElementById("SrvSel").selectedIndex==2){
				wdata[idx].srv = 3;
				wdata[idx].prot=form.prot.value;
				wdata[idx].ip10 = form.ip10.value;
				wdata[idx].port1 = form.port1.value;
				wdata[idx].port2 = form.port2.value;
			}
			else{
				wdata[idx].srv = 4;
				wdata[idx].ip6 = form.ip6.value;
				wdata[idx].ip7 = form.ip7.value;
				wdata[idx].ip8 = form.ip8.value;
				wdata[idx].ip9 = form.ip9.value;
			}

			wdata[idx].otoifid= form.otoifid.value;
			wdata[idx].vrrp_binding = form.vrrp_binding.value;
			wdata[idx].name = form.name.value;
			
			table = document.getElementById("show_available_table");
			var row1 = document.getElementById("tri1");
			//fnShowProp('bbbb', row1);
			rows = table.getElementsByTagName("tr");
			//delete added the table members
			if(rows.length > 1)
			{
				for(i=rows.length-1; i>0; i--)
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
			//ChgColor('tri', wdata.length, wdata.length-1);	
			ChgColor('tri', wdata.length, idx);
			entryNUM = idx;
		}
		else
			alert("over"+max_total+"rules");
	}
}

function Move(form)
{
	var idx=prompt("Move to ", entryNUM+1);
	if(MoveIndexRangeAndInputRange(idx, wdata, 1, max_total)==-1)
		return;
	
	idx=idx-1;
	
	var i;
	if(idx > wdata[entryNUM].idx)
	{
		for(i=wdata[entryNUM].idx+1; i<=idx; i++)
		{	
			wdata[i-1].srv=wdata[i].srv;	
			wdata[i-1].idx=i-1;
			wdata[i-1].stat=wdata[i].stat;
			wdata[i-1].ifs=wdata[i].ifs;
			wdata[i-1].prot=wdata[i].prot;
			wdata[i-1].ip1=wdata[i].ip1;
			wdata[i-1].ip2=wdata[i].ip2;
			wdata[i-1].ip3=wdata[i].ip3;
			wdata[i-1].ip4=wdata[i].ip4;
			wdata[i-1].ip5=wdata[i].ip5;
			wdata[i-1].ip6=wdata[i].ip6;
			wdata[i-1].ip7=wdata[i].ip7;
			wdata[i-1].ip8=wdata[i].ip8;
			wdata[i-1].ip9=wdata[i].ip9;
			wdata[i-1].ip10=wdata[i].ip10;
			wdata[i-1].port1=wdata[i].port1;
			wdata[i-1].port2=wdata[i].port2;
			wdata[i-1].otoifid=wdata[i].otoifid;
			wdata[i-1].vrrp_binding=wdata[i].vrrp_binding;
			wdata[i-1].name=wdata[i].name;
		}
		wdata[idx].idx=idx;
	
		if(form.stat.checked==true)
			wdata[idx].stat=1;
		else
			wdata[idx].stat=0;

		wdata[idx].prot="";
		wdata[idx].ip1="";
		wdata[idx].ip2="";
		wdata[idx].ip3="";
		wdata[idx].ip4="";
		wdata[idx].ip5="";
		wdata[idx].ip6="";
		wdata[idx].ip7="";
		wdata[idx].ip8="";
		wdata[idx].ip9="";
		wdata[idx].ip10="";
		wdata[idx].port1="";
		wdata[idx].port2="";
		wdata[idx].otoifid="";
		wdata[idx].vrrp_binding="";
		wdata[idx].name="";

		if(document.getElementById("SrvSel").selectedIndex==1)
			wdata[idx].ifs=form.ifs1.value;
		else
			wdata[idx].ifs=form.ifs2.value;
		
		if(document.getElementById("SrvSel").selectedIndex==0){
			wdata[idx].srv = 1;
			wdata[idx].ip1 = form.ip1.value;
			wdata[idx].ip2 = form.ip2.value;
		}
		else if(document.getElementById("SrvSel").selectedIndex==1){
			wdata[idx].srv = 2;
			wdata[idx].ip3 = form.ip3.value;
			wdata[idx].ip4 = form.ip4.value;

			if(ProjectModel == MODEL_EDR_G903){		
				if(form.ifs1.value=="default"){
					if(WanInfo[0].df_wan==1)
						wdata[idx].ip5 = WanInfo[0].wan_ip;
					else
						wdata[idx].ip5 = WanInfo[1].wan_ip;
				}
				else if(form.ifs1.value=="wan1")
					wdata[idx].ip5 = WanInfo[0].wan_ip;
				else
					wdata[idx].ip5 = WanInfo[1].wan_ip;
			}
			else{	// EDR-G902
				if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
					if(wdata[idx].ifs=="WAN" || wdata[idx].ifs=="wan1" || wdata[idx].ifs=="default")
						wdata[idx].ip5 = WanInfo[0].wan_ip;
					else{
						wdata[idx].ip5 = IpSelect(idx, vlanInfo);
						
					}
				}
				else{
					wdata[idx].ip5 = WanInfo[0].wan_ip;
				}
			}		
			
		}
		else if(document.getElementById("SrvSel").selectedIndex==2){
			wdata[idx].srv = 3;
			wdata[idx].prot = form.prot.value;
			wdata[idx].ip10 = form.ip10.value;
			wdata[idx].port1 = form.port1.value;
			wdata[idx].port2 = form.port2.value;
		}
		else{
			wdata[idx].srv = 4;
			wdata[idx].ip6 = form.ip6.value;
			wdata[idx].ip7 = form.ip7.value;
			wdata[idx].ip8 = form.ip8.value;
			wdata[idx].ip9 = form.ip9.value;
		}

		wdata[idx].otoifid= form.otoifid.value;
		wdata[idx].vrrp_binding = form.vrrp_binding.value;
		wdata[idx].name = form.name.value;
	}
	else
	{
		for(i=wdata[entryNUM].idx-1; i>=idx; i--)
		{	
			wdata[i+1].srv=wdata[i].srv;
			wdata[i+1].idx=i+1;
			wdata[i+1].stat=wdata[i].stat;
			wdata[i+1].ifs=wdata[i].ifs;
			wdata[i+1].prot=wdata[i].prot;
			wdata[i+1].ip1=wdata[i].ip1;
			wdata[i+1].ip2=wdata[i].ip2;
			wdata[i+1].ip3=wdata[i].ip3;
			wdata[i+1].ip4=wdata[i].ip4;
			wdata[i+1].ip5=wdata[i].ip5;
			wdata[i+1].ip6=wdata[i].ip6;
			wdata[i+1].ip7=wdata[i].ip7;
			wdata[i+1].ip8=wdata[i].ip8;
			wdata[i+1].ip9=wdata[i].ip9;
			wdata[i+1].ip10=wdata[i].ip10;
			wdata[i+1].port1=wdata[i].port1;
			wdata[i+1].port2=wdata[i].port2;
			wdata[i+1].otoifid=wdata[i].otoifid;
			wdata[i+1].vrrp_binding=wdata[i].vrrp_binding;
			wdata[i+1].name=wdata[i].name;
		}
		wdata[idx].idx=idx;
	
		if(form.stat.checked==true)
			wdata[idx].stat=1;
		else
			wdata[idx].stat=0;

		wdata[idx].prot="";
		wdata[idx].ip1="";
		wdata[idx].ip2="";
		wdata[idx].ip3="";
		wdata[idx].ip4="";
		wdata[idx].ip5="";
		wdata[idx].ip6="";
		wdata[idx].ip7="";
		wdata[idx].ip8="";
		wdata[idx].ip9="";
		wdata[idx].ip10="";
		wdata[idx].port1="";
		wdata[idx].port2="";
		wdata[idx].otoifid="";
		wdata[idx].vrrp_binding="";
		wdata[idx].name="";

		if(document.getElementById("SrvSel").selectedIndex==1)
			wdata[idx].ifs=form.ifs1.value;
		else
			wdata[idx].ifs=form.ifs2.value;
		
		if(document.getElementById("SrvSel").selectedIndex==0){
			wdata[idx].srv = 1;
			wdata[idx].ip1 = form.ip1.value;
			wdata[idx].ip2 = form.ip2.value;
		}
		else if(document.getElementById("SrvSel").selectedIndex==1){
			wdata[idx].srv = 2;
			wdata[idx].ip3 = form.ip3.value;
			wdata[idx].ip4 = form.ip4.value;

			if(ProjectModel == MODEL_EDR_G903){		
				if(form.ifs1.value=="default"){
					if(WanInfo[0].df_wan==1)
						wdata[idx].ip5 = WanInfo[0].wan_ip;
					else
						wdata[idx].ip5 = WanInfo[1].wan_ip;
				}
				else if(form.ifs1.value=="eth2")
					wdata[idx].ip5 = WanInfo[0].wan_ip;
				else
					wdata[idx].ip5 = WanInfo[1].wan_ip;
			}
			else{	// EDR-G902
				if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
					if(wdata[idx].ifs=="WAN" || wdata[idx].ifs=="wan1" || wdata[idx].ifs=="default")
						wdata[idx].ip5 = WanInfo[0].wan_ip;
					else{
						wdata[idx].ip5 = IpSelect(idx, vlanInfo);
						
					}
				}
				else{
					wdata[idx].ip5 = WanInfo[0].wan_ip;
				}
			}		


			
		}
		else if(document.getElementById("SrvSel").selectedIndex==2){
			wdata[idx].srv = 3;
			wdata[idx].prot = form.prot.value;
			wdata[idx].ip10 = form.ip10.value;
			wdata[idx].port1 = form.port1.value;
			wdata[idx].port2 = form.port2.value;
		}
		else{
			wdata[idx].srv = 4;
			wdata[idx].ip6 = form.ip6.value;
			wdata[idx].ip7 = form.ip7.value;
			wdata[idx].ip8 = form.ip8.value;
			wdata[idx].ip9 = form.ip9.value;
		}

		wdata[idx].otoifid= form.otoifid.value;
		wdata[idx].vrrp_binding = form.vrrp_binding.value;
		wdata[idx].name = form.name.value;
	}
	
	table = document.getElementById("show_available_table");
	var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 1)
	{
		for(i=rows.length-1; i>0; i--)
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
		for(i=rows.length-1; i>0; i--)
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
	ChgColor('tri', wdata.length, entryNUM);	
	EditRow1(entryNUM, 1);
}


function Modify(form)
{	
	split_string_by_br(form.name.value,40);
	/*
	if(Check121Rules()==128 && wdata[entryNUM].srv!=1 && form.stat.checked==true && document.getElementById("SrvSel").selectedIndex==0){
		alert("1-1 can\'t more than 128 rules");
		return;
	}
	*/
	if(NatLikeCheckFormat(form)==1)
		return;

	if(form.stat.checked==true)
		wdata[entryNUM].stat=1;
	else
		wdata[entryNUM].stat=0;

	wdata[entryNUM].prot="";
	wdata[entryNUM].ip1="";
	wdata[entryNUM].ip2="";
	wdata[entryNUM].ip3="";
	wdata[entryNUM].ip4="";
	wdata[entryNUM].ip5="";
	wdata[entryNUM].ip6="";
	wdata[entryNUM].ip7="";
	wdata[entryNUM].ip8="";
	wdata[entryNUM].ip9="";
	wdata[entryNUM].ip10="";
	wdata[entryNUM].port1="";
	wdata[entryNUM].port2="";
	wdata[entryNUM].otoifid="";
	wdata[entryNUM].vrrp_binding="";
	wdata[entryNUM].name="";

	if(document.getElementById("SrvSel").selectedIndex==1)
		wdata[entryNUM].ifs=form.ifs1.value;
	else
		wdata[entryNUM].ifs=form.ifs2.value;

	if(document.getElementById("SrvSel").selectedIndex==0){
		wdata[entryNUM].srv = 1;
		wdata[entryNUM].ip1 = form.ip1.value;
		wdata[entryNUM].ip2 = form.ip2.value;
	}
	else if(document.getElementById("SrvSel").selectedIndex==1){
		wdata[entryNUM].srv = 2;
		wdata[entryNUM].ip3 = form.ip3.value;
		wdata[entryNUM].ip4 = form.ip4.value;

		if(ProjectModel == MODEL_EDR_G903){		
			if(form.ifs1.value=="default"){
				if(WanInfo[0].df_wan==1)
					wdata[entryNUM].ip5 = WanInfo[0].wan_ip;
				else
					wdata[entryNUM].ip5 = WanInfo[1].wan_ip;
			}
			else if(form.ifs1.value=="wan1")
				wdata[entryNUM].ip5 = WanInfo[0].wan_ip;
			else
				wdata[entryNUM].ip5 = WanInfo[1].wan_ip;
		}
		else{	// EDR-G902
			if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
				if(wdata[entryNUM].ifs=="WAN" || wdata[entryNUM].ifs=="wan1" || wdata[entryNUM].ifs=="default")
					wdata[entryNUM].ip5 = WanInfo[0].wan_ip;
				else{
					wdata[entryNUM].ip5 = IpSelect(entryNUM, vlanInfo);
					
				}
			}
			else{
				wdata[entryNUM].ip5 = WanInfo[0].wan_ip;
			}
		}		


		
	}
	else if(document.getElementById("SrvSel").selectedIndex==2){
		wdata[entryNUM].srv = 3;
		wdata[entryNUM].prot = form.prot.value;
		wdata[entryNUM].ip10 = form.ip10.value;
		wdata[entryNUM].port1 = form.port1.value;
		wdata[entryNUM].port2 = form.port2.value;
	}
	else{
		wdata[entryNUM].srv = 4;
		wdata[entryNUM].ip6 = form.ip6.value;
		wdata[entryNUM].ip7 = form.ip7.value;
		wdata[entryNUM].ip8 = form.ip8.value;
		wdata[entryNUM].ip9 = form.ip9.value;
	}

	wdata[entryNUM].otoifid= form.otoifid.value;
	wdata[entryNUM].vrrp_binding = form.vrrp_binding.value;
	wdata[entryNUM].name = form.name.value;
	
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
		if((ProjectModel == MODEL_EDR_G902 && ModelVLAN == RETURN_FALSE))
			wdata[i].ifs = "wan1";
		else if(ProjectModel != MODEL_EDR_G903 && ProjectModel != MODEL_EDR_G902)
			wdata[i].ifs = 0;
		
		form.natTemp.value = form.natTemp.value + wdata[i].srv + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].stat + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ifs + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].prot + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip1 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip2 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip3 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip4 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip5 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip6 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip7 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip8 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip9 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].ip10 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].port1 + "+";
		form.natTemp.value = form.natTemp.value + wdata[i].port2 + "+";	
		form.natTemp.value = form.natTemp.value + wdata[i].otoifid + "+";	
		form.natTemp.value = form.natTemp.value + wdata[i].vrrp_binding + "+";	
		form.natTemp.value = form.natTemp.value + wdata[i].name + "+";	
	}
	form.natTemp.value = form.natTemp.value + CheckConfirm[0].stat2 + "+";

	form.action="/goform/net_WebNATGetValue";
	form.submit();
}

function funcSrvSel(num)
{	

	if(num==0){	// 1-1 NAT
		document.getElementById("one_to_one_config").style.display="";
		document.getElementById("n_to_one_config").style.display="none";
		document.getElementById("n_to_n_config").style.display="none";
		document.getElementById("napt_config").style.display="none";
		if(ProjectModel == MODEL_EDR_G903){
			document.getElementById("tbl_ifs1").style.display="none";
			document.getElementById("tbl_ifs2").style.display="";
		}
		else{	// EDR-G902
			if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
				document.getElementById("tbl_ifs1").style.display="none";
				document.getElementById("tbl_ifs2").style.display="";
			}
			else{
				document.getElementById("tbl_ifs1").style.display="none";
				document.getElementById("tbl_ifs2").style.display="none";
			}		
		}

		/* now only 1-1 NAT can be used to NAT redundancy with VRRP. */
		document.getElementById("vrrp_binding").disabled="";
	}
	else if(num==1){		// N-1 NAT
		document.getElementById("one_to_one_config").style.display="none";
		document.getElementById("n_to_one_config").style.display="";
		document.getElementById("n_to_n_config").style.display="none";
		document.getElementById("napt_config").style.display="none";
		if(ProjectModel == MODEL_EDR_G903){
			document.getElementById("tbl_ifs1").style.display="";
			document.getElementById("tbl_ifs2").style.display="none";
		}
		else{	// EDR-G902
			if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
				document.getElementById("tbl_ifs1").style.display="";
				document.getElementById("tbl_ifs2").style.display="none";
			}
			else{
				document.getElementById("tbl_ifs1").style.display="none";
				document.getElementById("tbl_ifs2").style.display="none";
			}		
		}

		/* now only 1-1 NAT can be used to NAT redundancy with VRRP. */
		document.getElementById("vrrp_binding").disabled = "true";
		document.getElementById("vrrp_binding").selectedIndex = 0;
	}
	else if(num==2){	// port forward
		document.getElementById("one_to_one_config").style.display="none";
		document.getElementById("n_to_one_config").style.display="none";
		document.getElementById("n_to_n_config").style.display="none";
		document.getElementById("napt_config").style.display="";
		if(ProjectModel == MODEL_EDR_G903){
			document.getElementById("tbl_ifs1").style.display="none";
			document.getElementById("tbl_ifs2").style.display="";
		}
		else{	// EDR-G902
			if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
				document.getElementById("tbl_ifs1").style.display="none";
				document.getElementById("tbl_ifs2").style.display="";
			}
			else{
				document.getElementById("tbl_ifs1").style.display="none";
				document.getElementById("tbl_ifs2").style.display="none";
			}
			
		}

		/* now only 1-1 NAT can be used to NAT redundancy with VRRP. */
		document.getElementById("vrrp_binding").disabled = "true";
		document.getElementById("vrrp_binding").selectedIndex = 0;
	}
	else{	// N-N NAT
		document.getElementById("one_to_one_config").style.display="none";
		document.getElementById("n_to_one_config").style.display="none";
		document.getElementById("n_to_n_config").style.display="";
		document.getElementById("napt_config").style.display="none";
		if(ProjectModel == MODEL_EDR_G903){
			document.getElementById("tbl_ifs1").style.display="none";
			document.getElementById("tbl_ifs2").style.display="";
		}
		else{	// EDR-G902
			if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
				document.getElementById("tbl_ifs1").style.display="none";
				document.getElementById("tbl_ifs2").style.display="";
			}
			else{
				document.getElementById("tbl_ifs1").style.display="none";
				document.getElementById("tbl_ifs2").style.display="none";
			}	
		}

		/* now only 1-1 NAT can be used to NAT redundancy with VRRP. */
		document.getElementById("vrrp_binding").disabled = "true";
		document.getElementById("vrrp_binding").selectedIndex = 0;
	}
}

function funcWAN(index)
{
	if(index < 0){
		return;
	}
	if(ModelVLAN == RETURN_TRUE && (ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902)){
		if(index==0){
			document.getElementById("tbl_wan1").style.display="";
			document.getElementById("tbl_wan2").style.display="none";
			document.getElementById("tbl_vlan").style.display="none";
		}
		else{
			myForm.vlan.value=vlanInfo[index-1].vlan_ip;
			document.getElementById("tbl_wan1").style.display="none";
			document.getElementById("tbl_wan2").style.display="none";
			document.getElementById("tbl_vlan").style.display="";
		}
	}
	else{
		if(index==0){
			if(WanInfo[0].df_wan==1){
				document.getElementById("tbl_wan1").style.display="";
				document.getElementById("tbl_wan2").style.display="none";
			}
			else{
				document.getElementById("tbl_wan1").style.display="none";
				document.getElementById("tbl_wan2").style.display="";	
			}
			
		}
		else if(index==1){
			document.getElementById("tbl_wan1").style.display="";
			document.getElementById("tbl_wan2").style.display="none";
		}
		else{
			document.getElementById("tbl_wan1").style.display="none";
			document.getElementById("tbl_wan2").style.display="";
		}
	}

	
}

function ShowIfsField()
{	
	if(ProjectModel == MODEL_EDR_G903)
		document.write('<td width="125px"></td>');
	else{	// EDR-G902
		if(ModelVLAN == RETURN_TRUE)
			document.write('<td width="125px"></td>');
	}
}

function PrintIfsTable()
{	
	if(ProjectModel == MODEL_EDR_G903)
		document.write('<td width="125px">'+OUT_SIDE_INTERFACE_+'</td>');
	else{	// EDR-G902
		document.write('<th class="s0" width="125px">'+OUT_SIDE_INTERFACE_+'</td>');
	}
}

function PrintDocDiv()
{	
	document.write('<DIV style="width:1065">');
}

function PrintContextDiv()
{	
	if(ProjectModel == MODEL_EDR_G903)
		document.write('<DIV style="width:1055px; height:171px; overflow-y:auto;">');
	else{	// EDR-G902
		if(ModelVLAN == RETURN_TRUE)
			document.write('<DIV style="width:1055px; height:171px; overflow-y:auto;">');
		else
			document.write('<DIV style="width:995px; height:171px; overflow-y:auto;">');
	}
}

</script>
</head>
<body onLoad=fnInit(0)>

<h1><script language="JavaScript">doc(IPT_NAT)</script></h1>
<fieldset>

<form name="qwe" id="myForm" method="POST" onSubmit="return stopSubmit()">
	<% net_Web_csrf_Token(); %>
	<input type="hidden" name="natTemp" id="natTemp" value="" />
	<input type="hidden" id="srv" name="ipt_nat_srv" value="" />
	<input type="hidden" id="idx" name="ipt_nat_idx" value="" />
	<input type="hidden" id="ip5" name="ip5" value="" />	
	<input type="hidden" id="ifs" name="ifs" value="" />
	<DIV style="height:180px">
		<table style="width:1050px;">
			<tr class="r2">
				<td style="width:103px;" align="left">&nbsp;<script language="JavaScript">doc(NAME_)</script></td>
				<td align="left">
					<input type="text" name="name" id="name" size=64 maxlength=64>
				</td>
			</tr>
		</table>
		<table style="width:1050px;">
			<tr class="r2">
				<td style="width:280px;" align="left" valign="top">
					<table style="width:280px;">
						<tr class="r2">
							<td style="width:100px;">
								<script language="JavaScript">doc(IPT_NAT_ENABLE)</script><br/>
							</td>
							<td style="width:180x;" align="left" valign="top">
								<input type="checkbox" id="stat" name="ipt_nat_enable">
							</td>
						</tr>
						<tr class="r2">
							<td style="width:100px;">
								<script language="JavaScript">doc(IPT_NAT_MODE)</script><br/>
							</td>
							<td style="width:180x;" align="left" valign="top">
							
								<select size=1 name="SrvSel" id="SrvSel" onchange="funcSrvSel(this.selectedIndex);">	
									<option value="onetoone">1-1</option>
									<option value="ntoone">N-1</option>
									<option value="natp">Port Forward</option>
								</select>
							</td>
						</tr>
						<tr class="r2">
							<td style="width:100px;">
								<script language="JavaScript">doc(NAT_VRRP_BINDING)</script><br/>
							</td>
							<td style="width:180x;" align="left" valign="top">
								<script language="JavaScript">fnGenSelect(selstate, '')</script>
							</td>
						</tr>			
					</table>
				</td>
				<td style="width:550px;" align="left" valign="up">
					<table style="width:567px;" id="show_ifs_table" name="show_ifs_table">
						<tr id="tbl_ifs1" >
							<td style="width:117px;">
								<script language="JavaScript">doc(OUT_SIDE_INTERFACE_)</script><br/>
							</td>
							<td style="width:450x;" align="left" valign="top">
								<script language="JavaScript">iGenSel3('ipt_filter_ifs1', 'ifs1', ifs1, 'funcWAN')</script>
							</td>
						</tr>
						<tr id="tbl_ifs2" style="display:none">
							<td style="width:117px;">
								<script language="JavaScript">doc(OUT_SIDE_INTERFACE_)</script><br/>
							</td>
							<td style="width:450x;" align="left" valign="top">
								<script language="JavaScript">iGenSel2('ipt_filter_ifs2', 'ifs2', ifs2)</script>
							</td>
						</tr>
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(OUT_SIDE_INTERFACE_)</script>
							</td>
							<td style="width:450x;" align="left" valign="center">
								<script language="JavaScript">fnGenSelect(seliface, 0)</script>		
							</td>	
						</tr>	
					</table>
					<table style="width:567px;" id="one_to_one_config" >	
						<tr class="r2">	
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(GLOBAL_IP_)</script>	
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=ip2 name="ip2" size=15 maxlength=15>		
							</td>
						</tr>
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(LOCAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=ip1 name="ip1" size=15 maxlength=15>	
							</td>
						</tr>					
					</table>
					
					<table style="width:567px;" id="n_to_one_config" style="display:none">
						<tr class="r2" id="tbl_wan1">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(GLOBAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=wan1 name="wan1" size=15 maxlength=15>
							</td>
						</tr>
						<tr class="r2" id="tbl_wan2" style="display:none">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(GLOBAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=wan2 name="wan2" size=15 maxlength=15>
							</td>
						</tr>
						<tr class="r2" id="tbl_vlan" style="display:none">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(GLOBAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=vlan name="vlan" size=15 maxlength=15>
							</td>
						</tr>
						<tr class="r2" >
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(LOCAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=ip3 name="ip3" size=15 maxlength=15>
								~
					            <input type="text" id=ip4 name="ip4" size=15 maxlength=15>
							</td>
						</tr>
					</table>

					<table style="width:567px;" id="n_to_n_config" >
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(LOCAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=ip6 name="ip6" size=15 maxlength=15>	
								~
					            <input type="text" id=ip7 name="ip7" size=15 maxlength=15>
							</td>
						</tr>
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(GLOBAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=ip8 name="ip8" size=15 maxlength=15>		
								~
					            <input type="text" id=ip9 name="ip9" size=15 maxlength=15>
							</td>
						</tr>
					</table>
					
					<table style="width:567px;" id="napt_config" style="display:none">
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(GLOBAL_PORT_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=port1 name="ipt_nat_napt_port1" size=15 maxlength=5>
							</td>
						</tr>
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(LOCAL_PORT_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=port2 name="ipt_nat_napt_port2" size=15 maxlength=5>
							</td>
						</tr>
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(LOCAL_IP_)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<input type="text" id=ip10 name="ip10" size=15 maxlength=15>
							</td>
						</tr>
						<tr class="r2">
							<td style="width:117px;" align="left" valign="center">
								<script language="JavaScript">doc(Protocol)</script>
							</td>
							<td style="width:450px;" align="left" valign="center">
								<script language="JavaScript">iGenSel2('ipt_prot_prot', 'prot', prot)</script>
							</td>
						</tr>
					</table>
					
				</td>
				<td style="width:550px;" align="left" valign="up">
				</td>
			</tr>
		</table>
	</DIV>
</form>
	
	

  	<table class="tf" align="left" valign="up">
    	<tr>
    		<td width="400px" style="text-align:left;"><script language="JavaScript">fnbnB(newb, 'onClick=New(myForm)')</script>
          	<script language="JavaScript">fnbnB(modb, 'onClick=Modify(myForm)')</script>
          	<script language="JavaScript">fnbnB(delb, 'onClick=Del(myForm)')</script>  	
        	<script language="JavaScript">fnbnB(moveb, 'onClick=Move(myForm)')</script></td>
        	<td width="300px" style="text-align:left;"><script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(myForm)', 'btnU')</script></td>
		</tr>
	</table>


<DIV style="height:50px">
<table class=tf align=left border=12>
<tr ></tr>
</table>
</DIV>

<table style="width:150px;">	
	<tr class="r0">
			<td colspan="8">
				<script language="JavaScript">doc(Iptables_NAT_List)</script>
			</td>
			<td id = "totalpolicy" align="left"></td>
	</tr>
</table>

<script language="JavaScript">PrintDocDiv()</script>
	<table id="show_available_table" >	
		<tr align="center">
 			<th class="s0" width="50px"><script language="JavaScript">doc(IPT_FILTER_ENABLE)</script></td>
 			<th class="s0" width="45px"><script language="JavaScript">doc(IPT_FILTER_INDEX)</script></td>
			<script language="JavaScript">PrintIfsTable()</script>
  			<th class="s0" width="80px"><script language="JavaScript">doc(Protocol)</script></td>
			<th class="s0" width="110px"><script language="JavaScript">doc(LOCAL_IP_);</script><br><script language="JavaScript">doc('('); doc(IPT_HOST_IP);doc(')');</script></td>
			<th class="s0" width="50px"><script language="JavaScript">doc(LOCAL_PORT_)</script></td>
			<th class="s0" width="110px"><script language="JavaScript">doc(GLOBAL_IP_);</script><br><script language="JavaScript">doc('(');doc(IPT_INTERFACE_IP);doc(')');</script></td>
			<th class="s0" width="50px"><script language="JavaScript">doc(GLOBAL_PORT_)</script></td>
			<th class="s0" width="50px"><script language="JavaScript">doc(NAT_VRRP_BINDING)</script></td>
			<th class="s0" width="350px"><script language="JavaScript">doc(NAME_)</script></td>
		</tr>
			<script language="JavaScript">ShowList1('tri')</script>
	</table>
</DIV>


</fieldset>
</body></html>


