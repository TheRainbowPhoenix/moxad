<html>
<head>
{{ net_Web_file_include() | safe }}


<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
//var ProjectModel = 1;
//checkMode(0);
//checkCookie();

var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();

if (!debug) {
	var SRV_MODBUS = [
		{enable:'0', ifs0:'1', ifs1:'2',protocol:'1',uid:'1',funccode:'1',addr0:'55',addr1:'',src_ip0:'1.1.1.1',src_ip1:'2.2.2.2',dst_ip0:'3.3.3.3',dst_ip1:'4.4.4.4',target:'1'},
		{enable:'1', ifs0:'0', ifs1:'1',protocol:'2',uid:'2',funccode:'3',addr0:'10',addr1:'999',src_ip0:'1.1.1.1',src_ip1:'2.2.2.2',dst_ip0:'3.3.3.3',dst_ip1:'4.4.4.4',target:'1'}
	];

	var slepem0 = [
		{ value:0, text:"server" },	{ value:1, text:"aries" },	{ value:1, text:"moxa" }
	];	
	var SRV_LAN = {
		ipad:'0.0.0.0', mask:'0.0.0.0'
	};	
	
	var ifs0 = [{ value:0, text:"All"},	{ value:1, text:"WAN1"}, { value:2, text:"WAN2"}, { value:3, text:"LAN"}];
	var ifs1 = [{ value:0, text:"All"},	{ value:1, text:"WAN1"}, { value:2, text:"WAN2"}, { value:3, text:"LAN"}];

}
else{
	var ifs0 = [ {{ net_Web_IFS_WriteInteger_Have_All_Value() | safe }} ];
	var ifs1 = [ {{ net_Web_IFS_WriteInteger_Have_All_Value() | safe }} ]; 
	
	{{ net_Web_show_value('SRV_MODBUS') | safe }}
	{{ net_Web_show_value('SRV_MODBUS_GLOBAL') | safe }} 
}

var protocol = [{ value:0, text:"All"},	{ value:1, text:"TCP"}, { value:2, text:"UDP"}];

var default_data = {
	enable:'0', 
	ifs0:'1', 
	ifs1:'2',
	protocol:'1',
	uid:'1',
	funccode:'1',
	addr0:'10',
	addr1:'999',
	src_ip0:'1.1.1.1',
	src_ip1:'2.2.2.2',
	dst_ip0:'3.3.3.3',
	dst_ip1:'4.4.4.4',
	target:'0'
};


var modbus_type = {
	enable:3, 
	ifs0:2, 
	ifs1:2,
	protocol:2,
	uid:4,
	funccode:4,
	addr0:4,
	addr1:4,
	src_ip0:5,
	src_ip1:5,
	dst_ip0:5,
	dst_ip1:5,
	target:2,
};

var entryNUM=0;

var showentry = {	
	my_idx:4,
	enable:3, 
	ifs0:2, 
	ifs1:2,
	protocol:2,
	src_ip0:5,
	dst_ip0:5,
	uid:4,
	funccode:4,
	addr0:4,
	target:2
	// multi_func:3	// we won't show this in the table list.
};


var function_code_option = [
	{ value:'0',  text:'All' },
	{ value:'1',  text:'Read Coils' },
	{ value:'2',  text:'Read Discrete Inputs' },
	{ value:'3',  text:'Read Holding Registers' },
	{ value:'4',  text:'Read Input Register' },
	{ value:'5',  text:'Write Single Coil' },
	{ value:'6',  text:'Write Single Register' },
	{ value:'7',  text:'Read Exception status' },
	{ value:'8',  text:'Diagnostic' },
	{ value:'11', text:'Get Com event counter' },
	{ value:'12', text:'Get Com Event Log' },
	{ value:'15', text:'Write Multiple Coils' },
	{ value:'16', text:'Write Multiple Registers' },
	{ value:'17', text:'Report Slave ID' },
	{ value:'20', text:'Read File record' },
	{ value:'21', text:'Write File record' },
	{ value:'22', text:'Mask Write Register' },
	{ value:'23', text:'Read/Write Multiple Registers' },
	{ value:'24', text:'Read FIFO queue' },
	{ value:'43', text:'Read device Identification' },
	{ value:'',	  text:'Manual' }
];

var modbus_target = [
	{ value:'1', text:'ACCEPT' },
	{ value:'2', text:'DROP' }
];

var find_table_name_by_var_option = [
	{ table_name:ifs0, variable:'ifs0' },	
	{ table_name:ifs1, variable:'ifs1' },	
	{ table_name:modbus_target, variable:'target' }
];


var newdata = new Array;
var myForm;

var table_idx = 0;

function mobus_edit_option_selet(row)
{
	var isMenual = 1;	// 0: no 
						// 1: yes
	/* function code */

	document.getElementById("funccode").style.display="";
						
	if(SRV_MODBUS.length != 0){

		for (var i in function_code_option){
			if(function_code_option[i].value == SRV_MODBUS[row].funccode){
				document.getElementById("function_code_option").selectedIndex = i;
				funcFunctionCodeSel(i);
				isMenual = 0;	// not menual
				break;
			}
		}
		
		/* is menual. */
		if(isMenual == 1)
			document.getElementById("function_code_option").selectedIndex = 20;

		/* address all, single, or range.  */
		if(SRV_MODBUS[row].addr1 != ""){	// range
			document.getElementById("AddrSel").selectedIndex = 2;
			funcAddrSel(2);
		}
		else{	// all or single
			if(SRV_MODBUS[row].addr0 == ""){	// all
				document.getElementById("AddrSel").selectedIndex = 0;
				funcAddrSel(0);
			}
			else{	// single
				document.getElementById("AddrSel").selectedIndex = 1;
				funcAddrSel(1);
			}
		}

		/* src_ip all, single, or range.  */
		if(SRV_MODBUS[row].src_ip1 != "0.0.0.0"){	// range
			document.getElementById("SrcIPSel").selectedIndex = 2;
			funcSrcIPSel(2);
		}
		else{	// all or single
			if(SRV_MODBUS[row].src_ip0 == "0.0.0.0"){	// all
				document.getElementById("SrcIPSel").selectedIndex = 0;
				funcSrcIPSel(0);
			}
			else{	// single
				document.getElementById("SrcIPSel").selectedIndex = 1;
				funcSrcIPSel(1);
			}
		}

		/* dst_ip all, single, or range.  */
		if(SRV_MODBUS[row].dst_ip1 != "0.0.0.0"){	// range
			document.getElementById("DstIPSel").selectedIndex = 2;
			funcDstIPSel(2);
		}
		else{	// all or single
			if(SRV_MODBUS[row].dst_ip0 == "0.0.0.0"){	// all
				document.getElementById("DstIPSel").selectedIndex = 0;
				funcDstIPSel(0);
			}
			else{	// single
				document.getElementById("DstIPSel").selectedIndex = 1;
				funcDstIPSel(1);
			}
		}
	}
}


var tablefun = new table_set_diff_show(document.getElementsByName('form1'),"show_available_table" ,modbus_type, SRV_MODBUS, table_idx, newdata, Addformat, showentry, mobus_edit_option_selet);


function modbus_EditRow(row) {
	fnLoadForm(myForm, SRV_MODBUS[row], modbus_type);
	ChgColor('tri', SRV_MODBUS.length, row);
	mobus_edit_option_selet(row);
}


var MODBUS_MAX = 64;

function mobus_Total_policy()
{			
	if(SRV_MODBUS.length > MODBUS_MAX || SRV_MODBUS.length  < 0){		
		alert('Number of ip is Over or Wrong');
		with(document){
			getElementById('btnA').disabled = true;			
			getElementById('btnD').disabled = false;			
			getElementById('btnM').disabled = false;			
			getElementById('btnU').disabled = true;
		}				
	}else if(SRV_MODBUS.length == MODBUS_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;
		}
	}else if(SRV_MODBUS.length == 0){			
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = true;
			getElementById('btnU').disabled = false;
		}
	}else{
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;	
		}
	}	
	document.getElementById("totalcercnt").innerHTML = '('+SRV_MODBUS.length +'/' +MODBUS_MAX+')';
}


function Addformat(mod,i)
{	
	var j;	
	var k;
	var type;

	//for(k in showentry){
	if(SRV_MODBUS.length != 0){
		for(k in modbus_type){

			
			//alert("k="+k);
			//alert(document.getElementsByName(k)[0].type);
			//alert("document.getElementsByName("+k+")[0].type = "+document.getElementsByName(k)[0].type);

			type = document.getElementsByName(k)[0].type;
			
			//alert("k="+k+", type="+type+", mod="+mod+", i="+i);
			
			if(type == "checkbox"){
				if(mod == 0){
					if(SRV_MODBUS[i][k] == 1)
						newdata[k]="<IMG src=" + 'images/enable_3.gif'+ ">";
					else
						newdata[k]= "<IMG src=" + 'images/disable_3.gif'+ ">";
				}
				else{
					if(document.getElementById('myForm')[k].checked == true)
						newdata[k]="<IMG src=" + 'images/enable_3.gif'+ ">";
					else
						newdata[k]="<IMG src=" + 'images/disable_3.gif'+ ">";
				}	
				j++;	
				continue;	
			}
			else if(type == "select-one"){
		
				if(k == 'target'){
					newdata[k] = fnGetSelText(SRV_MODBUS[i][k], modbus_target);
				}
				else if(k == 'ifs0'){
                    if(SRV_MODBUS[i][k] == 0){
                        SRV_MODBUS[i][k] = parseInt(0x7fffffff);
                    }
					newdata[k] = fnGetSelText(SRV_MODBUS[i][k], ifs0);
				}
				else if(k == 'ifs1'){
                    if(SRV_MODBUS[i][k] == 0){
                        SRV_MODBUS[i][k] = parseInt(0x7fffffff);
                    }

					newdata[k] = fnGetSelText(SRV_MODBUS[i][k], ifs1);
				}
				else if(k == 'protocol'){
					newdata[k] = fnGetSelText(SRV_MODBUS[i][k], protocol);
				}
				continue;
			}
			else{
				if(k == 'funccode'){
					//newdata[k] = fnGetSelText(SRV_MODBUS[i][k], function_code_option);
					if(fnGetSelText(SRV_MODBUS[i][k], function_code_option))
						newdata[k] = fnGetSelText(SRV_MODBUS[i][k], function_code_option);
					else{
						newdata[k] = SRV_MODBUS[i][k];
					}
						//newdata[k] = function_code_option[1].text;
					continue;
				}
			}
				
			if(mod == 0){
				/*
				if(k == "idx"){
					alert(k);
					newdata[k] = i+1;
				}
				*/
				if(k == "addr0" || k == "addr1"){
					if(k == "addr0"){
						if(SRV_MODBUS[i]["addr0"] == "" || SRV_MODBUS[i]["addr0"] == ""){
							newdata[k] = "--";
						}
						else{
							if(SRV_MODBUS[i]["addr1"] == "" || SRV_MODBUS[i]["addr1"] == ""){
								newdata[k] = SRV_MODBUS[i]["addr0"];
							}
							else{
								newdata[k] = SRV_MODBUS[i]["addr0"] + "~" + SRV_MODBUS[i]["addr1"];	
							}
						}
					}
				}
				else if(k == "src_ip0" || k == "src_ip1"){
					if(k == "src_ip0"){
						if(SRV_MODBUS[i]["src_ip0"] == "" || SRV_MODBUS[i]["src_ip0"] == " " || SRV_MODBUS[i]["src_ip0"] == "0.0.0.0"){
							newdata[k] = "--";
						}
						else{
							if(SRV_MODBUS[i]["src_ip1"] == "" || SRV_MODBUS[i]["src_ip1"] == " " || SRV_MODBUS[i]["src_ip1"] == "0.0.0.0"){
								newdata[k] = SRV_MODBUS[i]["src_ip0"];
							}
							else{
								newdata[k] = SRV_MODBUS[i]["src_ip0"] + "~" + SRV_MODBUS[i]["src_ip1"];	
							}
						}
					}
				}
				else if(k == "dst_ip0" || k == "dst_ip1"){
					if(k == "dst_ip0"){
						if(SRV_MODBUS[i]["dst_ip0"] == "" || SRV_MODBUS[i]["dst_ip0"] == " " || SRV_MODBUS[i]["dst_ip0"] == "0.0.0.0"){
							newdata[k] = "--";
						}
						else{
							if(SRV_MODBUS[i]["dst_ip1"] == "" || SRV_MODBUS[i]["dst_ip1"] == " " || SRV_MODBUS[i]["dst_ip1"] == "0.0.0.0"){
								newdata[k] = SRV_MODBUS[i]["dst_ip0"];
							}
							else{
								newdata[k] = SRV_MODBUS[i]["dst_ip0"] + "~" + SRV_MODBUS[i]["dst_ip1"];	
							}
						}
					}
				}
				else{
					newdata[k] = SRV_MODBUS[i][k];	
				}	
			}
			else{
				newdata[k] = document.getElementById('myForm')[k].value;

				if(type == "radio"){
					newdata[k] = GetRadioValue(document.getElementsByName(k));				
				}						
			}	

			
		}
	}
	//alert("newdata.length  "+newdata.length);
}


/*
else if(j == "addr0" || j == "addr1"){
			//alert("this.newdata["+j+"]="+this.newdata[j]+", this.newdata["+j+1+"]="+this.newdata[j++]);
			
		}
*/

function Activate(form)
{	
	document.getElementById("btnU").disabled="true";
	var i;
	var j;

	var myForm = document.getElementById('myForm');	
	var netwk1, netwk2;
	var same = 0;	
	
	for(i = 0 ; i < SRV_MODBUS.length ; i++)
	{	
		for (var j in SRV_MODBUS[i]){
			if(SRV_MODBUS[i][j] == '' && SRV_MODBUS[i][j] != 0){
				SRV_MODBUS[i][j]='';
			}
			form.SRV_MODBUS_tmp.value = form.SRV_MODBUS_tmp.value + SRV_MODBUS[i][j] + "+";	
		}
	}
	
	//alert(form.SRV_MODBUS_tmp.value);
	//alert(SRV_MODBUS[0]["multi_func"]);
	//alert(SRV_MODBUS[1]["multi_func"]);
	form.action="/goform/net_Web_get_value?SRV=SRV_MODBUS";	
	form.submit();	
}

/* set the first entry as the editrow for filling the field. */
function FieldInit(){
	document.getElementById("global_multi_func").checked = false;
	document.getElementById("stat").checked = false;
	document.getElementById("uid").value = 0;
	document.getElementById("funccode").value = 0;
	document.getElementById("protocol").value = 0;
	document.getElementById("target").value = 1;

	document.getElementById("funccode").style.display="none";
}

function fnInit() {

	myForm = document.getElementById('myForm');
	tablefun.show();
	mobus_Total_policy();	

	/* set the first entry as the editrow for filling the field. */
	FieldInit();

	if(SRV_MODBUS.length > 0){
		modbus_EditRow(0);
	}

}


function stopSubmit()
{
	return false;
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
		document.getElementById("src_ip_single_config").style.display="";
		document.getElementById("src_ip_range_config").style.display="";
	}
}

function funcDstIPSel(src_ipNUM)
{
	if(src_ipNUM==0){
		document.getElementById("dst_ip_all_config").style.display="";
		document.getElementById("dst_ip_single_config").style.display="none";
		document.getElementById("dst_ip_range_config").style.display="none";
	}
	else if(src_ipNUM==1){
		document.getElementById("dst_ip_all_config").style.display="none";
		document.getElementById("dst_ip_single_config").style.display="";
		document.getElementById("dst_ip_range_config").style.display="none";
	}
	else {
		document.getElementById("dst_ip_all_config").style.display="none";
		document.getElementById("dst_ip_single_config").style.display="";
		document.getElementById("dst_ip_range_config").style.display="";
	}
}

function funcAddrSel(dst_portNUM)
{
	if(dst_portNUM==0){
		document.getElementById("addr_all_config").style.display="";
		document.getElementById("addr_single_config").style.display="none";
		document.getElementById("addr_range_config").style.display="none";
	}
	else if(dst_portNUM==1){
		document.getElementById("addr_all_config").style.display="none";
		document.getElementById("addr_single_config").style.display="";
		document.getElementById("addr_range_config").style.display="none";
	}
	else {
		document.getElementById("addr_all_config").style.display="none";
		document.getElementById("addr_single_config").style.display="";
		document.getElementById("addr_range_config").style.display="";
	}
} 

function funcFunctionCodeSel(protNUM)
{

	//alert(protNUM + '; ' + function_code_option.length);
	if(protNUM != (function_code_option.length - 1)){	// 20
		//document.getElementById("funccode").disabled = true;
		document.getElementById("funccode").style.display="none";
		document.getElementById("funccode").value = function_code_option[protNUM].value;
	}
	else{	// manual
		//document.getElementById("funccode").disabled="";
		document.getElementById("funccode").style.display="";
	}
		

}

function Total_Connections()
{			
	if(SRV_MODBUS.length > MODBUS_MAX || SRV_MODBUS.length  < 0){		
		alert('Number of ip is Over or Wrong');
		with(document){
			getElementById('btnA').disabled = true;			
			getElementById('btnD').disabled = false;			
			getElementById('btnM').disabled = false;			
			getElementById('btnU').disabled = true;
		}				
	}else if(SRV_MODBUS.length == MODBUS_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;
		}
	}else if(SRV_MODBUS.length == 0){			
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = true;
			getElementById('btnU').disabled = false;
		}
	}else{
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;	
		}
	}	
	document.getElementById("totalcercnt").innerHTML = '('+SRV_MODBUS.length +'/' +MODBUS_MAX+')';
}	

function tabbtn_sel(form, sel)
{	

	if(sel == 0 || sel ==2){	// 0:add, 2:modify
		/* address: clean unuse filed data. */
		if(document.getElementById("AddrSel").selectedIndex == 0){	// all	
			document.getElementById("addr0").value = "";
			document.getElementById("addr1").value = "";
		}
		else if(document.getElementById("AddrSel").selectedIndex == 1){	// single	
			document.getElementById("addr1").value = "";
		}

		/* src_ip: clean unuse filed data. */
		if(document.getElementById("SrcIPSel").selectedIndex == 0){	// all	
			document.getElementById("src_ip0").value = "0.0.0.0";
			document.getElementById("src_ip1").value = "0.0.0.0";
		}
		else if(document.getElementById("SrcIPSel").selectedIndex == 1){	// single	
			document.getElementById("src_ip1").value = "0.0.0.0";
		}

		/* dst_ip: clean unuse filed data. */
		if(document.getElementById("DstIPSel").selectedIndex == 0){	// all	
			document.getElementById("dst_ip0").value = "0.0.0.0";
			document.getElementById("dst_ip1").value = "0.0.0.0";
		}
		else if(document.getElementById("DstIPSel").selectedIndex == 1){	// single	
			document.getElementById("dst_ip1").value = "0.0.0.0";
		}
	}

	
	if(sel == 0){		
		Addformat(1,0);
		tablefun.add();	
		
		modbus_EditRow(0);
	}
	else if(sel == 1){
		tablefun.del();
		if(SRV_MODBUS.length == 0){
			/* set the first entry as the editrow for filling the field. */
			FieldInit();
		}		
	}
	else if(sel == 2){
		//alert(document.getElementById("stat").checked);
		//alert(document.getElementById("multi_func").checked);
		tablefun.mod();	
		
	}
	Total_Connections();	
}

</script>
</head>
<body onLoad = fnInit()>
<h1><script language="JavaScript">doc(MODBUS_);doc(' ');doc(Setting_)</script></h1>
<fieldset>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_MODBUS_tmp" id="SRV_MODBUS_tmp" value="" >
<input type="hidden" name="idx" id="idx">
<input type="hidden" name="multi_func" id="multi_func">
{{ net_Web_csrf_Token() | safe }}

<DIV style="height:30px">

<table cellpadding=1 cellspacing=2 border=0 align=left width=300px> 
	<tr class=r0 >
		<td colspan=8>
			<script language="JavaScript">doc(Global_Parameters)</script>
		</td>
	</tr> 
</table>
</DIV>

<DIV style="height:30px">
<table cellpadding=2 cellspacing=5 border=0 align=left style="width:900px;"> 
	<tr align="left">
		<td width=200px>
			<script language="JavaScript">doc(MODBUS_MULTI_FUNC_CODE)</script>
		</td>  
		<td>
			<input type="checkbox" id=global_multi_func name="global_multi_func">
		</td>
		<td></td>
	</tr> 
</table>
</DIV>

<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left width=300px> 
	<tr class=r0 >
		<td colspan=8>
			<script language="JavaScript">doc(MODBUS_POLICY_SET_)</script>
		</td>
	</tr> 
</table>
</DIV>

<table>
	<tr>
		<td>
			<table cellpadding=1 cellspacing=2 border=0 align=left style="width:120px;">
				<tr>
					<td style="width:400px;" align="left" valign="center">	
						<table cellpadding="1" cellspacing="3" style="width:250px;"> 
						 	<tr align="left">   
						  		<td width=10px>
						   			<script language="JavaScript">doc(Enable_)</script>
						  		</td>
						  		<td >
						   			<input type="checkbox" id=stat name="enable">
						  		</td>  
						 	</tr>
						 </table>
					 </td>
					 <td style="width:400px;" align="left" valign="center">
					 	<table cellpadding="1" cellspacing="3" style="width:430px;"> 
						 	<tr align="left">   
						  		<td style="width:80px;" align="left" valign="center">
									<script language="JavaScript">doc(Targets)</script>
								</td>
								<td align="left" valign="center">  	
									<script language="JavaScript">iGenSel2('target', 'target', modbus_target)</script>
								</td> 
						 	</tr>
						 </table>
					 </td>
				 </tr>
			</table>
		</td>
	</tr>
	<tr>
		<td>

			<table cellpadding=1 cellspacing=2 border=0 align=left style="width:120px;"> 
				<tr>
					<td style="width:400px;" align="left" valign="center">	
						<table cellpadding="1" cellspacing="3" style="width:250px;"> 
							<tr align="left">
								<td width=10px id="ifs_doc"><script language="JavaScript">doc(MODBUS_IFS_FROM)</script></td>
								<td width=50px id="ifs_setting"><script language="JavaScript">iGenSel2('ifs0', 'ifs0', ifs0)</script></td>
								<td width=10px id="ifs_doc"><script language="JavaScript">doc(MODBUS_IFS_TO)</script></td>
								<td id="ifs_setting"><script language="JavaScript">iGenSel2('ifs1', 'ifs1', ifs1)</script></td>
							</tr> 
						</table>
					</td>
					<td style="width:400px;" align="left" valign="center">	
						<table cellpadding="1" cellspacing="3" style="width:430px;"> 
							<tr>
								<td style="width:80px;" align="left" valign="center">
									<script language="JavaScript">doc(SRC_IP)</script>
								</td>
								<td style="width:30px;" align="left" valign="center">
									<select size=1 name="SrcIPSel" id="SrcIPSel" onChange="funcSrcIPSel(this.selectedIndex)">	
										<option value="all">All</option>
										<option value="single">Single</option>
										<option value="range">Range</option>
									</select>
								</td>
								<td id="src_ip_all_config" align="left" valign="center">  				
					   			</td>
								<td id="src_ip_single_config" align="left" valign="center" style="display:none">  				
						  			
						  			<input type="text" id=src_ip0 name="src_ip0" size=15 maxlength=15>
							   	</td>
							   	<td id="src_ip_range_config" align="left" valign="center" style="display:none">  				
									~
									&nbsp;
									&nbsp;
							       	<input type="text" id=src_ip1 name="src_ip1" size=15 maxlength=15></td> 
							   	</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>	
	</tr>
	<tr>
		<td>
			<table cellpadding=1 cellspacing=2 border=0 align=left style="width:120px;">
				<tr>
					<td style="width:400px;" align="left" valign="center">	
						<table cellpadding="1" cellspacing="3" style="width:250px;"> 
							<tr align="left" id=setmodechg name=setmodechg>
								<td width=50px id="ifs_doc">
									<script language="JavaScript">doc(PROTOCOL)</script>
								</td>
								<td id="ifs_setting">
									<script language="JavaScript">iGenSel2('protocol', 'protocol', protocol)</script>
								</td>
							</tr>
						</table>
					</td>
					<td style="width:400px;" align="left" valign="center">	
						<table cellpadding="1" cellspacing="3" style="width:430px;"> 
							<tr>
								<td style="width:80px;" align="left" valign="center">
									<script language="JavaScript">doc(DST_IP)</script>
								</td>
								<td style="width:30px;" align="left" valign="center">
									<select size=1 name="DstIPSel" id="DstIPSel" onChange="funcDstIPSel(this.selectedIndex)">	
										<option value="all">All</option>
										<option value="single">Single</option>
										<option value="range">Range</option>
									</select>
								</td>
								<td id="dst_ip_all_config" align="left" valign="center">  				
					   			</td>
								<td id="dst_ip_single_config" align="left" valign="center" style="display:none">  				
						  			
						  			<input type="text" id=dst_ip0 name="dst_ip0" size=15 maxlength=15>
							   	</td>
							   	<td id="dst_ip_range_config" align="left" valign="center" style="display:none">  				
									~
									&nbsp;
									&nbsp;
									<input type="text" id=dst_ip1 name="dst_ip1" size=15 maxlength=15></td>
							   	</td>
							</tr>
						</table>
					</td>	
				</tr>
			</table>
		</td>	
	</tr>
	<tr>
		<td>

			<table cellpadding=2 cellspacing=5 border=0 align=left style="width:900px;"> 
				<tr align="left">
					<td width=50px>
						<script language="JavaScript">doc(UID)</script>
					</td>  
					<td id=advanceid0>
						<input type="text" id=uid name="uid" size=3 maxlength=3 >
						<script language="JavaScript">doc(MODBUS_UID_IGNORE)</script>
					</td>
					<td></td></tr> 
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table cellpadding=2 cellspacing=5 border=0 align=left style="width:900px;"> 
				<tr align="left">   
					<td width=90px>
						<script language="JavaScript">doc(FUNCTION_CODE)</script>
					</td>  
					<td width=100px>
						<script language="JavaScript">iGenSel3('function_code_option', 'function_code_option', function_code_option, 'funcFunctionCodeSel')</script>
					</td>
					<td id=advanceid0>
						<input type="text" id="funccode" name="funccode" size=5 maxlength=5 >
					</td>
					<td></td>
				</tr> 
			</table>
		</td>
	</tr>
	<tr>
		<td>
			<table cellpadding="2" cellspacing="5" border=0 align=left style="width:400px;">
				<tr>
					<td style="width:10px;" align="left" valign="center">
						<script language="JavaScript">doc(MODBUS_ADDRESS)</script>
					</td>
					<td style="width:250px;" align="left" valign="center">
						<table>
							<tr>
								<td  style="width:30px;" align="left" valign="center">
									<select size=1 name="AddrSel" id="AddrSel" onChange="funcAddrSel(this.selectedIndex)">	
										<option value="all">All</option>
										<option value="single">Single</option>
										<option value="range">Range</option>
									</select>
								</td>
								<td id="addr_all_config" align="left" valign="center">
						        </td>
						        <td id="addr_single_config" align="left" valign="center" style="display:none">  	
						            <input type="text" id=addr0 name="addr0" size=5 maxlength=5> 
						        </td>
						        <td id="addr_range_config" align="left" valign="center" style="display:none">     	  	               
									~
									&nbsp;
									&nbsp;
						           <input type="text" id=addr1 name="addr1" size=5 maxlength=5></td>
						        
						        </td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>	
	</tr>	
</table>




<table class=tf align=left>
 <tr>
  <td width="400px" style="text-align:left;"><script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script>
  <script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
  <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width="300px" style="text-align:left;"><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>

  <!--td><script language="JavaScript">fnbnSID(adv, 'onClick=Advance(this.form)', 'btnAdv')</script></td>
  <td width=15></td--></tr>
</table>


<DIV style="height:50px">
<table class=tf align=left border=12>
<tr ></tr>
</table>
</DIV>

<table cellpadding=1 cellspacing=2>
	<tr class=r0>
	 <td width=140px><script language="JavaScript">doc(MODBUS_LIST)</script></td>
	 <td id = "totalcercnt" colspan=5></td></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table">
<tr></tr>

 <tr align="center">
  <th class="s0" width= 5%><script language="JavaScript">doc(IPT_FILTER_INDEX)</script></td>
  <th class="s0" width= 5%><script language="JavaScript">doc(Enable_)</script></td>
  <th class="s0" width= 5%><script language="JavaScript">doc(INPUT_IFS)</script></td>
  <th class="s0" width= 5%><script language="JavaScript">doc(OUTPUT_IFS)</script>&nbsp
  <th class="s0" width= 5%><script language="JavaScript">doc(Protocol)</script>&nbsp
  <th class="s0" width= 15%><script language="JavaScript">doc(SRC_IP)</script>&nbsp
  <th class="s0" width= 15%><script language="JavaScript">doc(DST_IP)</script>&nbsp
  <th class="s0" width= 5%><script language="JavaScript">doc(UID)</script>&nbsp
  <th class="s0" width= 5%><script language="JavaScript">doc(FUNCTION_CODE)</script>&nbsp
  <th class="s0" width= 20%><script language="JavaScript">doc(MODBUS_ADDRESS)</script>&nbsp
  <th class="s0" width= 15%><script language="JavaScript">doc(Targets)</script>&nbsp
</table>


</form>
</fieldset>
</body></html>

