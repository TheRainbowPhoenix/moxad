<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(IPT_QOS)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
//var Mode2QosBw={{ net_Web_GetMode_WriteValue() | safe }};
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
Mode2QosBw = 0;
if (!debug) {
	var wdata = [{	
		stat1:'1', stat2:'1', stat3:'1', default1:'2', default2:'1', default3:'3',
		bw1:1, bw2:2, bw3:3, bw4:4, bw5:5, bw6:6, bw7:7, bw8:8, bw9:9, bw10:10, 
		bw11:11, bw12:2, bw13:13, bw14:14, bw15:15, bw16:16,  bw17:17, bw18:18, bw19:19, bw20:20,
		bw21:21, bw22:22, bw23:23, bw24:24, bw25:25, bw26:26,  bw27:27, bw28:28, bw29:29, bw30:30 
	}]
}
else{
		var wdata = [ {{ net_Web_IPT_QoS_BW_WriteValue() | safe }} ]
}

//net_Web_IPT_QoS_BW_WriteValue()

var default1 = [
{ value:'0', text:'Priority 0' },
{ value:'1',text:'Priority 1' },
{ value:'2',text:'Priority 2' },
{ value:'3',text:'Priority 3' }
];

var default2 = [
{ value:'0', text:'Priority 0' },
{ value:'1',text:'Priority 1' },
{ value:'2',text:'Priority 2' },
{ value:'3',text:'Priority 3' }
];

var default3 = [
{ value:'0', text:'Priority 0' },
{ value:'1',text:'Priority 1' },
{ value:'2',text:'Priority 2' },
{ value:'3',text:'Priority 3' }
];

var addb = 'Add';
var modb = 'Modify';
var updb = 'Activate';
var delb = 'Delete';

var entryNUM=0;
{% include "emalert_data" ignore missing %}
var wtype = {	stat1:3, stat2:3, stat3:3, default1:2, default2:2, default3:2,
				bw1:4, bw2:4, bw3:4, bw4:4, bw5:4, bw6:4, bw7:4, bw8:4, bw9:4, bw10:4, 
				bw11:4, bw12:4, bw13:4, bw14:4, bw15:4, bw16:4, bw17:4, bw18:4, bw19:4, bw20:4,
				bw21:4, bw22:4, bw23:4, bw24:4, bw25:4, bw26:4, bw27:4, bw28:4, bw29:4, bw30:4
};

var cur_if;
 
var myForm;

function ShowLanPort() {
	if(ProjectModel == MODEL_EDR_G903){
		document.write('<td colspan="10">'+IPT_QOS_DOWN_LEVEL1_CONFIGURATION+'</td>');
	}
	else{
		document.write('<td colspan="10">'+IPT_QOS_DOWN_LEVEL1_ONE_WAN_CONFIGURATION+'</td>');
	}
}

function ShowWanPort() {
	if(ProjectModel == MODEL_EDR_G903){
		document.write('<td colspan="10">'+IPT_QOS_WAN1_UP_LEVEL1_CONFIGURATION+'</td>');
	}
	else{
		document.write('<td colspan="10">'+IPT_QOS_WAN_UP_LEVEL1_CONFIGURATION+'</td>');
	}
}

function fnInit(row) {
	if(Mode2QosBw == 1){
		document.getElementById("tbl_wan1").style.display="none";
		document.getElementById("tbl_wan2").style.display="none";
	}

	if(ProjectModel == MODEL_EDR_G903){
		document.getElementById("tbl_wan2").style.display="";
	}
	else{
		document.getElementById("tbl_wan2").style.display="none";
	}
	
	myForm = document.getElementById('myForm');
	EditRow(row);
}


function EditRow(row) {
	fnLoadForm(myForm, wdata[row], wtype);
	//ChgColor('tri', wdata.length, row);
}

function QoSBwCheckFormat(form)
{
	var error=0;

	if(form.stat1.checked==true){
		if(	!IsMinBwLessThanTotol(form.bw3, form.bw4, 'Downstream ', 'Priority 0 ', 'MIN. BW', 'MAX. BW') ||
			!IsMinBwLessThanTotol(form.bw5, form.bw6, 'Downstream ', 'Priority 1 ', 'MIN. BW', 'MAX. BW') ||
			!IsMinBwLessThanTotol(form.bw7, form.bw8, 'Downstream ', 'Priority 2 ', 'MIN. BW', 'MAX. BW') ||
			!IsMinBwLessThanTotol(form.bw9, form.bw10, 'Downstream ', 'Priority 3 ', 'MIN. BW', 'MAX. BW')
		){
			
			error=1;
		}

		if(	!IsMinBwLessThanTotol(form.bw4, form.bw2, 'Downstream ', 'Priority 0 ', 'MAX. BW', 'Total BW') ||
			!IsMinBwLessThanTotol(form.bw6, form.bw2, 'Downstream ', 'Priority 1 ', 'MAX. BW', 'Total BW') ||
			!IsMinBwLessThanTotol(form.bw8, form.bw2, 'Downstream ', 'Priority 2 ', 'MAX. BW', 'Total BW') ||
			!IsMinBwLessThanTotol(form.bw10, form.bw2, 'Downstream ', 'Priority 3 ', 'MAX. BW', 'Total BW')
		){
			
			error=1;
		}

		if(	!IsMinBwNatual(form.bw3, 'Downstream ', 'Priority 0 ', 'MIN. BW ') ||
			!IsMinBwNatual(form.bw5, 'Downstream ', 'Priority 1 ', 'MIN. BW ') ||
			!IsMinBwNatual(form.bw7, 'Downstream ', 'Priority 2 ', 'MIN. BW ') ||
			!IsMinBwNatual(form.bw9, 'Downstream ', 'Priority 3 ', 'MIN. BW ')
			
		){
			error=1;
		}

		if( parseInt(form.bw3.value) + parseInt(form.bw5.value) + parseInt(form.bw7.value) + parseInt(form.bw9.value) > parseInt(form.bw2.value)){
			alert(MsgHead[0]+'Downstream'+MsgStrs[14]);
			error=1;
		}
	}

	if(form.stat2.checked==true){
		if(	!IsMinBwLessThanTotol(form.bw13, form.bw14, 'Upstream(WAN1) ', 'Priority 0 ', 'MIN. BW', 'MAX. BW') ||
			!IsMinBwLessThanTotol(form.bw15, form.bw16, 'Upstream(WAN1) ', 'Priority 1 ', 'MIN. BW', 'MAX. BW') ||
			!IsMinBwLessThanTotol(form.bw17, form.bw18, 'Upstream(WAN1) ', 'Priority 2 ', 'MIN. BW', 'MAX. BW') ||
			!IsMinBwLessThanTotol(form.bw19, form.bw20, 'Upstream(WAN1) ', 'Priority 3 ', 'MIN. BW', 'MAX. BW')
		){
			
			error=1;
		}

		if(	!IsMinBwLessThanTotol(form.bw14, form.bw12, 'Upstream(WAN1) ', 'Priority 0 ', 'MAX. BW', 'Total BW') ||
			!IsMinBwLessThanTotol(form.bw16, form.bw12, 'Upstream(WAN1) ', 'Priority 1 ', 'MAX. BW', 'Total BW') ||
			!IsMinBwLessThanTotol(form.bw18, form.bw12, 'Upstream(WAN1) ', 'Priority 2 ', 'MAX. BW', 'Total BW') ||
			!IsMinBwLessThanTotol(form.bw20, form.bw12, 'Upstream(WAN1) ', 'Priority 3 ', 'MAX. BW', 'Total BW')
		){
			
			error=1;
		}

		if(	!IsMinBwNatual(form.bw13, 'Upstream(WAN1) ', 'Priority 0 ', 'MIN. BW ') ||
			!IsMinBwNatual(form.bw15, 'Upstream(WAN1) ', 'Priority 1 ', 'MIN. BW ') ||
			!IsMinBwNatual(form.bw17, 'Upstream(WAN1) ', 'Priority 2 ', 'MIN. BW ') ||
			!IsMinBwNatual(form.bw19, 'Upstream(WAN1) ', 'Priority 3 ', 'MIN. BW ')
			
		){
			error=1;
		}
		
		if( parseInt(form.bw13.value) + parseInt(form.bw15.value) + parseInt(form.bw17.value) + parseInt(form.bw19.value) > parseInt(form.bw12.value)){
			alert(MsgHead[0]+'Upstream(WAN1)'+MsgStrs[14]);
			error=1;
		}
	}
	
	if(ProjectModel == MODEL_EDR_G903){
		if(form.stat3.checked==true){
			if(	!IsMinBwLessThanTotol(form.bw23, form.bw24, 'Upstream(WAN2) ', 'Priority 0 ', 'MIN. BW', 'MAX. BW') ||
				!IsMinBwLessThanTotol(form.bw25, form.bw26, 'Upstream(WAN2) ', 'Priority 1 ', 'MIN. BW', 'MAX. BW') ||
				!IsMinBwLessThanTotol(form.bw27, form.bw28, 'Upstream(WAN2) ', 'Priority 2 ', 'MIN. BW', 'MAX. BW') ||
				!IsMinBwLessThanTotol(form.bw29, form.bw30, 'Upstream(WAN2) ', 'Priority 3 ', 'MIN. BW', 'MAX. BW')
			){
				
				error=1;
			}

			if(	!IsMinBwLessThanTotol(form.bw24, form.bw22, 'UpStream(WAN2) ', 'Priority 0 ', 'MAX. BW', 'Total BW') ||
				!IsMinBwLessThanTotol(form.bw26, form.bw22, 'UpStream(WAN2) ', 'Priority 1 ', 'MAX. BW', 'Total BW') ||
				!IsMinBwLessThanTotol(form.bw28, form.bw22, 'UpStream(WAN2) ', 'Priority 2 ', 'MAX. BW', 'Total BW') ||
				!IsMinBwLessThanTotol(form.bw30, form.bw22, 'UpStream(WAN2) ', 'Priority 3 ', 'MAX. BW', 'Total BW')
			){
				
				error=1;
			}

			if(	!IsMinBwNatual(form.bw23, 'Upstream(WAN2) ', 'Priority 0 ', 'MIN. BW ') ||
				!IsMinBwNatual(form.bw25, 'Upstream(WAN2) ', 'Priority 1 ', 'MIN. BW ') ||
				!IsMinBwNatual(form.bw27, 'Upstream(WAN2) ', 'Priority 2 ', 'MIN. BW ') ||
				!IsMinBwNatual(form.bw29, 'Upstream(WAN2) ', 'Priority 3 ', 'MIN. BW ')
				
			){
				error=1;
			}

			if( parseInt(form.bw23.value) + parseInt(form.bw25.value) + parseInt(form.bw27.value) + parseInt(form.bw29.value) > parseInt(form.bw22.value)){
				alert(MsgHead[0]+'Upstream(WAN2)'+MsgStrs[14]);
				error=1;
			}
		}
	}

	if(ProjectModel == MODEL_EDR_G903){
		if(!isNumber(form.bw2.value) || !isNumber(form.bw3.value) || !isNumber(form.bw4.value)
		|| !isNumber(form.bw5.value) || !isNumber(form.bw6.value) || !isNumber(form.bw7.value)
		|| !isNumber(form.bw8.value) || !isNumber(form.bw9.value) || !isNumber(form.bw10.value)
		|| !isNumber(form.bw12.value) || !isNumber(form.bw13.value) || !isNumber(form.bw14.value)
		|| !isNumber(form.bw15.value) || !isNumber(form.bw16.value) || !isNumber(form.bw17.value)
		|| !isNumber(form.bw18.value) || !isNumber(form.bw19.value) || !isNumber(form.bw20.value)
		|| !isNumber(form.bw22.value) || !isNumber(form.bw23.value) || !isNumber(form.bw24.value)
		|| !isNumber(form.bw25.value) || !isNumber(form.bw26.value) || !isNumber(form.bw27.value)
		|| !isNumber(form.bw28.value) || !isNumber(form.bw29.value) || !isNumber(form.bw30.value)) {
			alert(MsgHead[0]+'Stream'+MsgStrs[7]);
			error=1;
		}
	}
	else{
		if(!isNumber(form.bw2.value) || !isNumber(form.bw3.value) || !isNumber(form.bw4.value)
		|| !isNumber(form.bw5.value) || !isNumber(form.bw6.value) || !isNumber(form.bw7.value)
		|| !isNumber(form.bw8.value) || !isNumber(form.bw9.value) || !isNumber(form.bw10.value)
		|| !isNumber(form.bw12.value) || !isNumber(form.bw13.value) || !isNumber(form.bw14.value)
		|| !isNumber(form.bw15.value) || !isNumber(form.bw16.value) || !isNumber(form.bw17.value)
		|| !isNumber(form.bw18.value) || !isNumber(form.bw19.value) || !isNumber(form.bw20.value)) {
			alert(MsgHead[0]+'Stream'+MsgStrs[7]);
			error=1;
		}
	}
	return error;
}


function Activate(form)
{		
	if(QoSBwCheckFormat(form)==1)
		return;
	
	document.getElementById("btnU").disabled="true";
	
	if(form.stat1.checked==true)
		wdata[0].stat1=1;
	else
		wdata[0].stat1=0;

	if(form.stat2.checked==true)
		wdata[0].stat2=1;
	else
		wdata[0].stat2=0;

	if(ProjectModel == MODEL_EDR_G903){
		if(form.stat3.checked==true)
			wdata[0].stat3=1;
		else
			wdata[0].stat3=0;
	}

	wdata[0].default1=form.default1.value;
	wdata[0].default2=form.default2.value;

	if(ProjectModel == MODEL_EDR_G903){
		wdata[0].default3=form.default3.value;
	}
	
	wdata[0].bw1 = form.bw2.value;
	wdata[0].bw2 = form.bw2.value;
	wdata[0].bw3 = form.bw3.value;
	wdata[0].bw4 = form.bw4.value;
	wdata[0].bw5 = form.bw5.value;
	wdata[0].bw6 = form.bw6.value;
	wdata[0].bw7 = form.bw7.value;
	wdata[0].bw8 = form.bw8.value;
	wdata[0].bw9 = form.bw9.value;
	wdata[0].bw10 = form.bw10.value;
	wdata[0].bw11 = form.bw12.value;
	wdata[0].bw12 = form.bw12.value;
	wdata[0].bw13 = form.bw13.value;
	wdata[0].bw14 = form.bw14.value;
	wdata[0].bw15 = form.bw15.value;
	wdata[0].bw16 = form.bw16.value;
	wdata[0].bw17 = form.bw17.value;
	wdata[0].bw18 = form.bw18.value;
	wdata[0].bw19 = form.bw19.value;
	wdata[0].bw20 = form.bw20.value;

	if(ProjectModel == MODEL_EDR_G903){
		wdata[0].bw21 = form.bw22.value;
		wdata[0].bw22 = form.bw22.value;
		wdata[0].bw23 = form.bw23.value;
		wdata[0].bw24 = form.bw24.value;
		wdata[0].bw25 = form.bw25.value;
		wdata[0].bw26 = form.bw26.value;
		wdata[0].bw27 = form.bw27.value;
		wdata[0].bw28 = form.bw28.value;
		wdata[0].bw29 = form.bw29.value;
		wdata[0].bw30 = form.bw30.value;
	}

	form.qosTemp.value = form.qosTemp.value + wdata[0].stat1 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].stat2 + "+";
	if(ProjectModel == MODEL_EDR_G903){
		form.qosTemp.value = form.qosTemp.value + wdata[0].stat3 + "+";
	}
	form.qosTemp.value = form.qosTemp.value + wdata[0].default1 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].default2 + "+";
	if(ProjectModel == MODEL_EDR_G903){
		form.qosTemp.value = form.qosTemp.value + wdata[0].default3 + "+";
	}
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw1 + "+";	
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw2 + "+";	
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw3 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw4 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw5 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw6 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw7 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw8 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw9 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw10 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw11 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw12 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw13 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw14 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw15 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw16 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw17 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw18 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw19 + "+";
	form.qosTemp.value = form.qosTemp.value + wdata[0].bw20 + "+";
	if(ProjectModel == MODEL_EDR_G903){
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw21 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw22 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw23 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw24 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw25 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw26 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw27 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw28 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw29 + "+";
		form.qosTemp.value = form.qosTemp.value + wdata[0].bw30 + "+";
	}

	form.submit();	
}

</script>
</head>
<body class=main onLoad=fnInit(0)>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[2].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[2])</script>
<script language="JavaScript">mainh()</script>

<form name="qwe" id="myForm" method="POST" action="/goform/net_WebQoSBWGetValue">
	{{ net_Web_csrf_Token() | safe }}	
	<input type="hidden" name="qosTemp" id="qosTemp" value="" />
	<input type="hidden" name="bw1" id="bw1" value="" />
	<input type="hidden" name="bw11" id="bw11" value="" />
	<input type="hidden" name="bw21" id="bw21" value="" />
		
	<table cellpadding="1" cellspacing="3" style="width:700px;">
		<tr class="r0">
    		<script language="JavaScript">ShowLanPort()</script>
   		</tr>
		<tr>
		  <td colspan=3>
		   <table><tr class="r2">
			<td style="width:200px;">
				<script language="JavaScript">doc(IPT_QOS_ENABLE)</script>
			</td>
			<td style="width:200px;" align="left" valign="center">
				<input type="checkbox" id="stat1" name="qos_down_enable">
			</td>		
			<td style="width:250px;">
				<script language="JavaScript">doc(IPT_QOS_LEVEL1_MAX)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<input type="text" id=bw2 name="bw2" size=15 maxlength=15> (KByte/s)
	   		</td>		
			<td style="width:250px;">
				<script language="JavaScript">doc(IPT_QOS_DEFAULT_PRIO)</script>
			</td>
			<td style="width:480px;" align="left" valign="center">
				<script language="JavaScript">iGenSel2('default1', 'default1', default1)</script>
			</td>
			</tr></table>
		  </td>	
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO0)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
	   			<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw3 name="bw3" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw4 name="bw4" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>			
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO1)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw5 name="bw5" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw6 name="bw6" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO2)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw7 name="bw7" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw8 name="bw8" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO3)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw9 name="bw9" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw10 name="bw10" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
	</table>



	<table cellpadding="1" cellspacing="3" style="width:700px;" id="tbl_wan1">
		<tr class="r0">
    		<script language="JavaScript">ShowWanPort()</script>
   		</tr>
   		<tr>
   		 <td colspan=3>
   		 <table>
   		  <tr class="r2">		  
			<td style="width:200px;">
				<script language="JavaScript">doc(IPT_QOS_ENABLE)</script>
			</td>
			<td style="width:200px;" align="left" valign="center">
				<input type="checkbox" id="stat2" name="qos_up_enable">
			</td>		
			<td style="width:250px;">
				<script language="JavaScript">doc(IPT_QOS_LEVEL1_MAX)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<input type="text" id=bw12 name="bw12" size=15 maxlength=15> (KByte/s)
	   		</td>		
			<td style="width:250px;">
				<script language="JavaScript">doc(IPT_QOS_DEFAULT_PRIO)</script>
			</td>
			<td style="width:480px;" align="left" valign="center">
				<script language="JavaScript">iGenSel2('default2', 'default2', default2)</script>
			</td>
		   </tr></table>
		  </td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO0)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw13 name="bw13" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw14 name="bw14" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO1)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw15 name="bw15" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw16 name="bw16" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO2)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw17 name="bw17" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw18 name="bw18" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO3)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw19 name="bw19" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw20 name="bw20" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
	</table>

	<table cellpadding="1" cellspacing="3" style="width:700px;" id="tbl_wan2" >
		<tr class="r0">
    		<td colspan="10"><script language="JavaScript">doc(IPT_QOS_WAN2_UP_LEVEL1_CONFIGURATION)</script></td>
   		</tr>
   		<tr class="r2">
			<td td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_ENABLE)</script>
			</td>
			<td style="width:480px;" align="left" valign="center">
				<input type="checkbox" id="stat3" name="qos_up_enable">
			</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_LEVEL1_MAX)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<input type="text" id=bw22 name="bw22" size=15 maxlength=15> (KByte/s)
	   		</td>
		</tr>
		<tr class="r2">
			<td td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_DEFAULT_PRIO)</script>
			</td>
			<td style="width:480px;" align="left" valign="center">
				<script language="JavaScript">iGenSel2('default3', 'default3', default3)</script>
			</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO0)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw23 name="bw23" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw24 name="bw24" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO1)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw25 name="bw25" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw26 name="bw26" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO2)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   						
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw27 name="bw27" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw28 name="bw28" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
		<tr class="r2">
			<td style="width:120px;">
				<script language="JavaScript">doc(IPT_QOS_PRIO3)</script>
	   		</td>
	   		<td style="width:480px;" align="left" valign="center">  
  				<table>
	   				<tr class="r2">
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MIN)</script>
	   					</td>
	   					<td style="width:200px;" align="left" valign="center">
	   						<input type="text" id=bw29 name="bw29" size=15 maxlength=15> (KByte/s)
	   					</td>
	   					<td style="width:50px;" align="left" valign="center">
	   						<script language="JavaScript">doc(IPT_QOS_MAX)</script>
	   					</td>
	   					<td align="left" valign="center">
	   						<input type="text" id=bw30 name="bw30" size=15 maxlength=15> (KByte/s)
	   					</td>	
	   				</tr>
	   			</table>
	   		</td>
		</tr>
	</table>
	

  	<table class="tf" align="left" valign="center">
    	<tr>
          	<td><script language="JavaScript">fnbnBID(updb, 'onClick=Activate(this.form)', 'btnU')</script></td>
		</tr>
	</table>
    
</form>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
