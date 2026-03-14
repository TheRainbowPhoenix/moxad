<html>
<head>
<% net_Web_file_include(); %>


<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

checkMode(<% net_Web_GetMode_WriteValue(); %>);
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkCookie();

if (!debug) {
	var SRV_VRRP = [	{VrrpEnable:'1',EntryEnable:'0',ifs:'1',vip:'1.1.1.1',vrid:'1',priority:'100',preempt:'1',TrackIfs:'3'},
					{VrrpEnable:'1',EntryEnable:'0',ifs:'2',vip:'2.2.2.2',vrid:'51',priority:'250',preempt:'0',TrackIfs:'2'} 
	];
}
else{
	<% net_Web_show_value('SRV_VRRP'); %>	
}


if (!debug) {
	var CurrentStatus = [ {ip:'1.1.1.1', status:'Master'}, {ip:'53.5.5.5', status:'Backup'} ];
}
else{
	var CurrentStatus = [ <% net_webVrrpCurrentStatus(); %> ];
	var CurrentIp = [ <% net_webVrrpCurrentIp(); %> ];
}

var vrrp_ifs = [ <% net_Web_Write_vrrpIFS_IntegerValue(); %> ];

if(ProjectModel == MODEL_EDR_G903){
	var vrrp_track_ifs = [ { ifs:'0', vid:'0', text:'--' }, { ifs:'255', vid:'255', text:'WAN1+WAN2' }, <% net_Web_Write_vrrpIFS_IntegerValue(); %> ];
}
else{
	var vrrp_track_ifs = [ { value:'0', text:'--' }, <% net_Web_Write_vrrpIFS_IntegerValue(); %> ];
}

var entryNUM=0;
var initEntry;

<!--#include file="cvserver_data"-->
var wtype = { EntryEnable:3, ifs:2, ip:5, status:2, vip:5, vrid:4, priority:4, preempt:3, TrackIfs:2 };



var myForm;

var max_total;

function fnInit(row) {
	
	max_total = 16

	Total_Policy();
	
	myForm = document.getElementById('myForm');
	initEntry=1;

	if(SRV_VRRP.length > 0)
		EditRow1(row, 0);

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
	for(i=0; i<SRV_VRRP.length; i++)
	{
		addRow(i);		
	}
	ChgColor('tri', SRV_VRRP.length, 0);		
}

function vrrp_if_sel(idx)
{
	var i;
	for(i=0; i<vrrp_ifs.length; i++){
		if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){	
			if(SRV_VRRP[idx].ifs == vrrp_ifs[i].ifs &&  SRV_VRRP[idx].vid == vrrp_ifs[i].vid){
				document.getElementById("vrrp_sel_ifs").selectedIndex = i;
				break;
			}
		}
		else{
			if(SRV_VRRP[idx].ifs == vrrp_ifs[i].value){
				document.getElementById("vrrp_sel_ifs").selectedIndex = i;
				break;
			}
		}
	}

	for(i=0; i<vrrp_track_ifs.length; i++){
		if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){	
			if(SRV_VRRP[idx].TrackIfs0 == vrrp_track_ifs[i].ifs &&  SRV_VRRP[idx].TrackIfsVid0 == vrrp_track_ifs[i].vid){
				document.getElementById("vrrp_sel_track_ifs").selectedIndex = i;
				break;
			}
		}
		else{
			if(SRV_VRRP[idx].TrackIfs == vrrp_track_ifs[i].value){
				document.getElementById("vrrp_sel_track_ifs").selectedIndex = i;
				break;
			}
		}
	}
}

function EditRow1(row, indicate) 
{
//	fnShowProp('aaaaa'+i, row);
	var rowidx;

	if(initEntry==1 || indicate==1){
		rowidx = row;
		initEntry = 0;
	}
	else{
		rowidx = row.rowIndex - 1;
	}
	
	fnLoadForm(myForm, SRV_VRRP[rowidx],  SRV_VRRP_type );
	ChgColor('tri', SRV_VRRP.length, rowidx);

	entryNUM = rowidx;
	
	/* select vrrp ifs / track ifs into correct option. */
	vrrp_if_sel(entryNUM);
}

function fnGet_vrrpIfsSelText(ifs, vid, sobj) {
	for (var j in sobj)
		if (sobj[j].ifs == ifs && sobj[j].vid == vid)
			return sobj[j].text;
}

function addRow(i)
{
	var j;
	
	table = document.getElementById('show_available_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);

	cell = document.createElement("td");

	if(SRV_VRRP[i].EntryEnable==1)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.innerHTML = i+1;
	row.appendChild(cell);

	cell = document.createElement("td");
	if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){	
		cell.innerHTML = fnGet_vrrpIfsSelText(SRV_VRRP[i].ifs, SRV_VRRP[i].vid, vrrp_ifs);
	}
	else{
		cell.innerHTML = fnGetSelText(SRV_VRRP[i].ifs, vrrp_ifs);
	}
	row.appendChild(cell);

	cell = document.createElement("td");	
	for(j=0; j<CurrentIp.length; j++){
		if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){
			if(CurrentIp[j].ifs == SRV_VRRP[i].ifs && CurrentIp[j].vid == SRV_VRRP[i].vid)
				break;
		}
		else{
			if(CurrentIp[j].ifs == SRV_VRRP[i].ifs)
				break;
		}
	}
	if( j<CurrentIp.length ){
		cell.innerHTML = CurrentIp[j].ip;	
	}
	else{
		cell.innerHTML = "0.0.0.0";
	}
	row.appendChild(cell);

	cell = document.createElement("td");	

	if(i+1 > CurrentStatus.length)
		cell.innerHTML = "INIT";	
	else
	cell.innerHTML = CurrentStatus[i].status;	
	row.appendChild(cell);

	cell = document.createElement("td");	
	cell.innerHTML = SRV_VRRP[i].vip;	
	row.appendChild(cell);

	cell = document.createElement("td");	
	cell.innerHTML = SRV_VRRP[i].vrid;
	row.appendChild(cell);

	cell = document.createElement("td");	
	cell.innerHTML = SRV_VRRP[i].priority;
	row.appendChild(cell);

	cell = document.createElement("td");
	if(SRV_VRRP[i].preempt==1)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);

	cell = document.createElement("td");
	if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){	
		if(SRV_VRRP[i].TrackIfs0 > 0)
			cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
		else
			cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	}
	else{
	if(SRV_VRRP[i].TrackIfs > 0)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	}
	
	row.appendChild(cell);
		
	cell = document.createElement("td");
	if(SRV_VRRP[i].pingTrackIP != "" && SRV_VRRP[i].pingTrackIP != "0.0.0.0")
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);	

	
	row.style.Color = "black";
	var j=i+1;
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this, 0)};
	row.style.cursor=ptrcursor;
	row.align="center";

} 
function Check121Rules()
{
	var idx;
	var total=0;
	for(idx=0; idx<SRV_VRRP.length; idx++){
		if(SRV_VRRP[idx].srv==1 && SRV_VRRP[idx].stat==1)
			total++;
	}
	return total;
}


function Modify(form)
{	
	var selet_option;

	if(VrrpCheckFormat(form)==1)
		return;

	if(form.EntryEnable.checked==true)
		SRV_VRRP[entryNUM].EntryEnable=1;
	else
		SRV_VRRP[entryNUM].EntryEnable=0;

	if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){	
		selet_option = document.getElementById("vrrp_sel_ifs").selectedIndex;
		SRV_VRRP[entryNUM].ifs = vrrp_ifs[selet_option].ifs;
		SRV_VRRP[entryNUM].vid = vrrp_ifs[selet_option].vid;
	}
	else{
		SRV_VRRP[entryNUM].ifs = form.vrrp_sel_ifs.value;
	}
	
	SRV_VRRP[entryNUM].vip = form.vip.value;
	SRV_VRRP[entryNUM].vrid = form.vrid.value;
	SRV_VRRP[entryNUM].priority = form.priority.value;
	SRV_VRRP[entryNUM].preemptDelay = form.preemptDelay.value;
	
	SRV_VRRP[entryNUM].pingTrackIP = form.pingTrackIP.value;
	SRV_VRRP[entryNUM].pingTrackInterval = form.pingTrackInterval.value;
	SRV_VRRP[entryNUM].pingTrackTimeout = form.pingTrackTimeout.value;
	SRV_VRRP[entryNUM].pingTrackSuccess = form.pingTrackSuccess.value;
	SRV_VRRP[entryNUM].pingTrackFailure = form.pingTrackFailure.value;
	
	SRV_VRRP[entryNUM].advInt = form.advInt.value;
	
	if(form.preempt.checked==true)
		SRV_VRRP[entryNUM].preempt=1;
	else
		SRV_VRRP[entryNUM].preempt=0;

	SRV_VRRP[entryNUM].TrackIfs = 0;
	if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){
		selet_option = document.getElementById("vrrp_sel_track_ifs").selectedIndex;
		SRV_VRRP[entryNUM].TrackIfs0 = vrrp_track_ifs[selet_option].ifs;
		SRV_VRRP[entryNUM].TrackIfsVid0 = vrrp_track_ifs[selet_option].vid;
	}
	else {
		SRV_VRRP[entryNUM].TrackIfs = form.TrackIfs.value;
	}
	
	table = document.getElementById("show_available_table");
	var row1 = document.getElementById("tri1");
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
	for(i=0;i<SRV_VRRP.length;i++)
	{
		addRow(i);		
	}
	ChgColor('tri', SRV_VRRP.length, entryNUM);	
}

var max_total;

function Total_Policy()
{
	document.getElementById("totalcnt").innerHTML = '('+SRV_VRRP.length +'/' +max_total+')';
}

function Add(form)
{
	var selet_option;
	
	if(VrrpCheckFormat(form)==1)
		return;
	
	var idx = SRV_VRRP.length;
	
	if(idx!=-1){
		
		if((SRV_VRRP.length+1) <= max_total){

			SRV_VRRP[idx] = new Array(0,0,0,0,0,0,0,0,0,0,0);			
	
			if(form.EntryEnable.checked == true)
				SRV_VRRP[idx].EntryEnable = 1;
			else
				SRV_VRRP[idx].EntryEnable = 0;
		 
			if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){	
				selet_option = document.getElementById("vrrp_sel_ifs").selectedIndex;
				SRV_VRRP[idx].ifs = vrrp_ifs[selet_option].ifs;
				SRV_VRRP[idx].vid = vrrp_ifs[selet_option].vid;
			}
			else{	
				SRV_VRRP[idx].ifs = form.vrrp_sel_ifs.value;
			}
			
			SRV_VRRP[idx].vip = form.vip.value;
			SRV_VRRP[idx].vrid = form.vrid.value;
			SRV_VRRP[idx].priority = form.priority.value;
			SRV_VRRP[idx].preemptDelay = form.preemptDelay.value;

			SRV_VRRP[idx].pingTrackIP = form.pingTrackIP.value;
			SRV_VRRP[idx].pingTrackInterval = form.pingTrackInterval.value;
			SRV_VRRP[idx].pingTrackTimeout = form.pingTrackTimeout.value;
			SRV_VRRP[idx].pingTrackSuccess = form.pingTrackSuccess.value;
			SRV_VRRP[idx].pingTrackFailure = form.pingTrackFailure.value;

			SRV_VRRP[idx].advInt = form.advInt.value;
					
			if(form.preempt.checked==true)
				SRV_VRRP[idx].preempt=1;
			else
				SRV_VRRP[idx].preempt=0;

			if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){
				selet_option = document.getElementById("vrrp_sel_track_ifs").selectedIndex;
				SRV_VRRP[idx].TrackIfs0 = vrrp_track_ifs[selet_option].ifs;
				SRV_VRRP[idx].TrackIfsVid0 = vrrp_track_ifs[selet_option].vid;
		 	}
			else {
				SRV_VRRP[idx].TrackIfs = form.TrackIfs.value;
			}
						
			table = document.getElementById("show_available_table");
			var row1 = document.getElementById("tri1");
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
			for(i=0;i<SRV_VRRP.length;i++)
			{
				//alert('A'+i);
				addRow(i);		
			}
			ChgColor('tri', SRV_VRRP.length, idx);	
			entryNUM = idx;
		}
		else{
			alert("over "+max_total+" rules");
		}
	}
	Total_Policy();
}
	

function Del()
{
	table = document.getElementById("show_available_table");
	var row1 = document.getElementById("tri1");
	//fnShowProp('bbbb', row1);
	rows = table.getElementsByTagName("tr");
	
	
	SRV_VRRP.splice(entryNUM,1);
		
	table = document.getElementById("show_available_table");
	rows = table.getElementsByTagName("tr");
	
	//delete added the table members
	if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
		{
			table.deleteRow(i);
		}
	}

	for(i=entryNUM; i<SRV_VRRP.length; i++){
		SRV_VRRP[i].idx = SRV_VRRP[i].idx	- 1;
	}
	
	//re-join the array elements to the table
	for(i=0;i<SRV_VRRP.length;i++)
	{
		//alert('A'+i);
		addRow(i);		
	}
	Total_Policy();
	if(SRV_VRRP.length==0){
		return;
	}else if(entryNUM > SRV_VRRP.length-1){
		entryNUM = SRV_VRRP.length-1;
	}
	ChgColor('tri', SRV_VRRP.length, entryNUM);	
	EditRow1(entryNUM, 1);
}

function Activate(form)
{	
	document.getElementById("btnU").disabled="true";

	var i;
	var j;

	for(i = 0 ; i < SRV_VRRP.length ; i++)
	{	
		for (var j in SRV_VRRP_type){
			if(SRV_VRRP[i][j] == '' && SRV_VRRP[i][j] != 0){
				SRV_VRRP[i][j]='';
			}
			form.SRV_VRRP_tmp.value = form.SRV_VRRP_tmp.value + SRV_VRRP[i][j] + "+";	
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_VRRP";
	form.submit();
}

function VrrpCheckFormat(form)
{
	var error=0;

	if(!IpAddrNotMcastIsOK(form.vip, 'Virtual IP')){
		error=1;
	}
	
	if(!isNumber(form.vrid.value)){
		alert(MsgHead[0]+"Virtual Router ID"+MsgStrs[12]) ;
		error=1;
	}
	else{
		if(form.vrid.value<1 || form.vrid.value>255){
			alert(MsgHead[0]+"Virtual Router ID number must be 1~255") ;
			error=1;
		}
	}

	if(!isNumber(form.priority.value)){
		alert(MsgHead[0]+"Priority"+MsgStrs[16]) ;
		error=1;
	}
	else{
		if(form.priority.value<1 || form.priority.value>254){
			alert(MsgHead[0]+"Priority"+MsgStrs[16]) ;
			error=1;
		}
	}

	if(!isNumber(form.preemptDelay.value)){
		alert(MsgHead[0]+"Preempt Delay"+MsgStrs[16]);
		error=1;
	}
	else{
		if(form.preemptDelay.value<10 || form.preemptDelay.value>300){
			alert(MsgHead[0]+"Preempt Delay must be 10~300");
			error=1;
		}
	}
	
	if(!isNumber(form.advInt.value)){
		alert(MsgHead[0]+"Advertisement Interval"+MsgStrs[16]) ;
		error=1;
	}
	else{
		if(form.advInt.value<1 || form.advInt.value>30){
			alert(MsgHead[0]+"Advertisement Interval number must be 1~30") ;
			error=1;
		}
	}

	if(!isNull(form.pingTrackIP.value)){
		if(!IsIpOK(form.pingTrackIP, 'Ping Track IP')){
			error=1;
		}
		else{
			if(!isNumber(form.pingTrackInterval.value)){
				alert(MsgHead[0]+"Interval"+MsgStrs[16]) ;
				error=1;
			}
			else{
				if(form.pingTrackInterval.value<1 || form.pingTrackInterval.value>100){
					alert(MsgHead[0]+"Interval number must be 1~100") ;
					error=1;
				}
			}

			if(!isNumber(form.pingTrackTimeout.value)){
				alert(MsgHead[0]+"Timeout"+MsgStrs[16]) ;
				error=1;
			}
			else{
				if(form.pingTrackTimeout.value<1 || form.pingTrackTimeout.value>100){
					alert(MsgHead[0]+"Timeout number must be 1~100") ;
					error=1;
				}
			}

			if(!isNumber(form.pingTrackSuccess.value)){
				alert(MsgHead[0]+"Success Count"+MsgStrs[16]) ;
				error=1;
			}
			else{
				if(form.pingTrackSuccess.value<1 || form.pingTrackSuccess.value>100){
					alert(MsgHead[0]+"Success Count number must be 1~100") ;
					error=1;
				}
			}

			if(!isNumber(form.pingTrackFailure.value)){
				alert(MsgHead[0]+"Failure Count"+MsgStrs[16]) ;
				error=1;
			}
			else{
				if(form.pingTrackFailure.value<1 || form.pingTrackFailure.value>100){
					alert(MsgHead[0]+"Failure Count number must be 1~100") ;
					error=1;
				}
			}
		}
	}

	return error;
}

</script>
</head>
<body onLoad=fnInit(0)>

<h1><script language="JavaScript">doc(VRRP_SETTING)</script></h1>

<fieldset>

<form name="qwe" id="myForm" method="POST" onSubmit="return stopSubmit()">
	<input type="hidden" name="vrrpTemp" id="vrrpTemp" value="" />
	<input type="hidden" name="SRV_VRRP_tmp" id="SRV_VRRP_tmp" value="" >
	<% net_Web_csrf_Token(); %>
	<DIV >
	
	<table cellpadding="1" cellspacing="3" style="width:750px;">
		<tr class="r0">
  			<td style="width:250px;" align="left"><script language="JavaScript">doc(VRRP_IFS_SETTING_ENTRY)</script></td>
		</tr>
	</table>
		
	<table width="890" align="left">
		<tr>
			<td width="190"><script language="JavaScript">doc(IPT_NAT_ENABLE)</script></td>
			<td width="150"><input type="checkbox" id="EntryEnable" name="EntryEnable"></td>
			<td width="528">&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(IPT_FILTER_INTERFACE)</script></td>
			<td><script language="JavaScript">iGenSel2('vrrp_sel_ifs', 'vrrp_sel_ifs', vrrp_ifs)</script></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(VRRP_VIP)</script></td>
			<td><input type="text" id=vip name="vip" value="0.0.0.0" size=15 maxlength=15></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(VRRP_VRID)</script></td>
			<td><input type="text" id=vrid name="vrid" value=1 size=5 maxlength=5> (1~255)</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(VRRP_PRIORITY)</script></td>
			<td><input type="text" id=priority name="priority" value=100 size=5 maxlength=5> (1~254)</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(VRRP_PREEMPT)</script></td>
			<td><input type="checkbox" id="preempt" name="preempt"></td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(VRRP_PREEMPT_DELAY_)</script></td>
			<td><input type="text" id=preemptDelay name="preemptDelay" value=120 size=5 maxlength=3> (10~300)</td>
			<td>&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(ADV_INTERVAL_)</script></td>
			<td><input type="text" id=advInt name="advInt" value=1 size=5 maxlength=5> (1~30)</td>
			<td>&nbsp;</td>
		</tr>
	</table>

	<br>

	<table cellpadding="1" cellspacing="3" style="width:750px;">
		<tr class="r0">
  			<td style="width:250px;" align="left"><script language="JavaScript">doc(VRRP_TRACKING_)</script></td>
		</tr>
	</table>
	
	<table width="890" align="left">
		<tr>
			<td width="190"><script language="JavaScript">doc(VRRP_TRACK_IFS)</script></td>
			<td width="150"><script language="JavaScript">iGenSel2('TrackIfs', 'TrackIfs', vrrp_track_ifs)</script></td>
			<td width="528">&nbsp;</td>
		</tr>
		<tr>
			<td><script language="JavaScript">doc(PING_TRACK_)</script></td>
			<td><script language="JavaScript">doc(TARGET_IP_)</script></td>
			<td><input type="text" id=pingTrackIP name="pingTrackIP" value="0.0.0.0" size=15 maxlength=15> Leave empty or 0.0.0.0 to disable.</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><script language="JavaScript">doc(INTERVAL_)</script></td>
			<td><input type="text" id=pingTrackInterval name="pingTrackInterval" value=1 size=5 maxlength=5> (1~100)</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><script language="JavaScript">doc(TIMEOUT_)</script></td>
			<td><input type="text" id=pingTrackTimeout name="pingTrackTimeout" value=3 size=5 maxlength=5> (1~100)</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><script language="JavaScript">doc(SUCCESS_COUNT_)</script></td>
			<td><input type="text" id=pingTrackRcv name="pingTrackSuccess" value=3 size=5 maxlength=5> (1~100)</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><script language="JavaScript">doc(FAILURE_COUNT_)</script></td>
			<td><input type="text" id=pingTrackLost name="pingTrackFailure" value=3 size=5 maxlength=5> (1~100)</td>
		</tr>
	</table>	

	<p>&nbsp;</p>
	 
	</DIV>

</form>
	
		
<DIV id="OnclickModify" >
  	<table class="tf" align="left" valign="up">
    	<tr>
    		<td width="400px" style="text-align:left;"><script language="JavaScript">fnbnB(addb, 'onClick=Add(myForm)')</script>
          	<script language="JavaScript">fnbnB(modb, 'onClick=Modify(myForm)')</script>
          	<script language="JavaScript">fnbnB(delb, 'onClick=Del(myForm)')</script>
			<td width="300px" style="text-align:left;"><script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(myForm)', 'btnU')</script></td>
		</tr>
	</table>
</DIV>

<DIV style="height:50px">
<table class=tf align=left border=12>
<tr ></tr>
</table>
</DIV>

<DIV style="width:888px;">
<table>
	<tr class="r0">
			<td colspan="8">
  			<table><tr class="r0" >
				<td width="200px"><script language="JavaScript">doc(VRRP_LIST)</script></td>
				<td id = "totalcnt" colspan="6"></td>
				<td></td>
				</tr></table>  				  				
			</td>
	</tr>
	<tr class="r5">
		<th class="s0" width="45" rowspan="2" align="center">Enable</td>
		<th class="s0" width="40" rowspan="2" align="center">Index</td>
		<th class="s0" width="225" rowspan="2" align="center">Interface</td>
		<th class="s0" width="110" rowspan="2" align="center">IP</td>
		<th class="s0" width="50" rowspan="2" align="center">Status</td>
		<th class="s0" width="110" rowspan="2" align="center">VIP</td>
		<th class="s0" width="40" rowspan="2" align="center">VRID</td>
		<th class="s0" width="40" rowspan="2" align="center">Prio.</td>
		<th class="s0" width="70" rowspan="2" align="center">Preemption</td>
		<th class="s0" colspan="2" align="center">Tracking</td>
	</tr>
	<tr class="r5">
		<th class="s0" width="55" align="center">Interface</td>
		<th class="s0" width="55" align="center">Ping</td>
	</tr>
</table>
</DIV>

<DIV style="width:888px; overflow-y:auto;">
	<table id="show_available_table" >	
		<tr align="center">
 			<td width="45"></td>
 			<td width="40"></td>
 			<td width="225"></td>
 			<td width="110"></td>
  			<td width="50"></td>
			<td width="110"></td>
			<td width="40"></td>
			<td width="40"></td>
			<td width="70"></td>
			<td width="55"></td>
			<td width="55"></td>	
		</tr>	
		<script language="JavaScript">ShowList1('tri')</script>
	</table>
</DIV>

</fieldset>
</body></html>

