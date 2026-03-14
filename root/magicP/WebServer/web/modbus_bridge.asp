<html>
<head>
<% net_Web_file_include(); %>


<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
//var ProjectModel = 1;
//checkMode(0);
//checkCookie();

var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkMode(<% net_Web_GetMode_WriteValue(); %>);
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
	var ifs0 = [ <% net_Web_IFS_WriteInteger_Have_All_Value(); %> ];
	var ifs1 = [ <% net_Web_IFS_WriteInteger_Have_All_Value(); %> ]; 
	
	<%net_Web_show_value('SRV_MODBUS');%>
	<% net_Web_show_value('SRV_MODBUS_GLOBAL'); %> 
}

var protocol = [{ value:0, text:"All"},	{ value:1, text:"TCP"}, { value:2, text:"UDP"}];

var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

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
	multi_func:3,
	modbusType:4,
	modbusBaseOne:3
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
	{ value:'1',  text:'1: 	Read Coils' },
	{ value:'2',  text:'2: 	Read Discrete Inputs' },
	{ value:'3',  text:'3: 	Read Holding Registers' },
	{ value:'4',  text:'4: 	Read Input Register' },
	{ value:'5',  text:'5: 	Write Single Coil' },
	{ value:'6',  text:'6: 	Write Single Register' },
	{ value:'7',  text:'7: 	Read Exception status' },
	{ value:'8',  text:'8: 	Diagnostic' },
	{ value:'11', text:'11:	Get Com event counter' },
	{ value:'12', text:'12:	Get Com Event Log' },
	{ value:'15', text:'15:	Write Multiple Coils' },
	{ value:'16', text:'16:	Write Multiple Registers' },
	{ value:'17', text:'17:	Report Slave ID' },
	{ value:'20', text:'20:	Read File record' },
	{ value:'21', text:'21:	Write File record' },
	{ value:'22', text:'22:	Mask Write Register' },
	{ value:'23', text:'23:	Read/Write Multiple Registers' },
	{ value:'24', text:'24:	Read FIFO queue' },
	{ value:'43', text:'43:	Read device Identification' },
	{ value:'-1',	  text:'Manual' }
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

var modbusType = [
	{ value:'0', text:'--' },
	{ value:'1', text:'Master Query' },
	{ value:'2', text:'Slave Response' }
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
			getElementById('btnMove').disabled = false;
		}				
	}else if(SRV_MODBUS.length == MODBUS_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;
			getElementById('btnMove').disabled = false;
		}
	}else if(SRV_MODBUS.length == 0){			
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = true;
			getElementById('btnU').disabled = false;
			getElementById('btnMove').disabled = true;
		}
	}else{
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;	
			getElementById('btnMove').disabled = false;
		}
	}	
	document.getElementById("totalcercnt").innerHTML = '('+SRV_MODBUS.length +'/' +MODBUS_MAX+')';
}


function Addformat(mod,i)
{	
	var j;	
	var k;
	var type;

	if(SRV_MODBUS.length != 0){
		for(k in modbus_type){
			/*	we don't show this in table list.
			 *	it has been shown in the upper field like global setting.
			 */
			if(k == "multi_func" || k == "modbusType" || k == "modbusBaseOne"){
				//alert(k);
				continue;
			}
			
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


function Activate(form)
{	
	if(!isPort(form.service_port, 'Modbus Service Port')){
		return;
	}

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
	

		
	form.SRV_MODBUS_GLOBAL_tmp.value = form.SRV_MODBUS_GLOBAL_tmp.value + form.drop_multi_func_enable.value + "+";

	//alert(form.SRV_MODBUS_tmp.value);
	//alert(SRV_MODBUS[0]["multi_func"]);
	//alert(SRV_MODBUS[1]["multi_func"]);

	form.action="/goform/net_Web_get_value?SRV=SRV_MODBUS_GLOBAL&SRV0=SRV_MODBUS";
	form.submit();	
}

/* set the first entry as the editrow for filling the field. */
function FieldInit(){
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

	if(SRV_MODBUS_GLOBAL.drop_multi_func_enable == 1)
		document.getElementById("drop_multi_func_enable").checked = true;
	else
		document.getElementById("drop_multi_func_enable").checked = false;

	myForm.malEnable.value = SRV_MODBUS_GLOBAL.malEnable;

	myForm.service_port.value = SRV_MODBUS_GLOBAL.service_port;
	
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

function funcEnableAddr(enable)
{
	if(enable > 0){
		document.getElementById("addr0").disabled="";
		document.getElementById("addr1").disabled="";
		document.getElementById("modbusBaseOne").disabled="";
	}
	else{
		document.getElementById("addr0").disabled="true";
		document.getElementById("addr1").disabled="true";
		document.getElementById("modbusBaseOne").disabled="true";
	}
}

function funcCommandTypeSel(modbusTypeIdx)
{
	/* set formulate of function code and address. */
	var function_code = document.getElementById("funccode").value;

	if(	function_code == 1 	|| function_code == 2	|| function_code == 3	||
		function_code == 4 	|| function_code == 5 	|| function_code == 6 	||
		function_code == 15	|| function_code == 16	|| function_code == -1){
		if(document.getElementById("modbusType").selectedIndex == 1){
			/* enable address setting. */
			document.getElementById("AddrSel").disabled = "";
			funcEnableAddr(1);
		}
		else{
			/* disable address setting. */
			funcEnableAddr(0);
			
			/* set address selection to all. */
			document.getElementById("AddrSel").selectedIndex = 0;
			document.getElementById("AddrSel").disabled = "true";
			funcAddrSel(0);
		}
	}
	else{
		/* disable address setting. */
		funcEnableAddr(0);
		
		/* set address selection to all. */
		document.getElementById("AddrSel").selectedIndex = 0;
		document.getElementById("AddrSel").disabled = "true";
		funcAddrSel(0);
	}
}

function funcFunctionCodeSel(protNUM)
{

	if(protNUM != (function_code_option.length - 1)){	// 20
		//document.getElementById("funccode").disabled = true;
		document.getElementById("funccode").style.display="none";
		document.getElementById("funccode").value = function_code_option[protNUM].value;
	}
	else{	// manual
		//document.getElementById("funccode").disabled="";
		document.getElementById("funccode").style.display="";

		/* open address and plc address for user setting. */
		funcEnableAddr(1);
	}

	/* set formulate of function code and address. */
	funcCommandTypeSel(document.getElementById("modbusType").selectedIndex);
	
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
			getElementById('btnMove').disabled = false;
		}				
	}else if(SRV_MODBUS.length == MODBUS_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;
			getElementById('btnMove').disabled = false;
		}
	}else if(SRV_MODBUS.length == 0){			
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = true;
			getElementById('btnU').disabled = false;
			getElementById('btnMove').disabled = true;
		}
	}else{
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;	
			getElementById('btnMove').disabled = false;	
		}
	}	
	document.getElementById("totalcercnt").innerHTML = '('+SRV_MODBUS.length +'/' +MODBUS_MAX+')';
}
	

function Ifs_Vid_modify(row_idx)
{	
	SRV_MODBUS[row_idx]['ifs0'] = ifs0[document.getElementById("ifs0").selectedIndex].ifs;
	SRV_MODBUS[row_idx]['vid0'] = ifs0[document.getElementById("ifs0").selectedIndex].vid;
	SRV_MODBUS[row_idx]['ifs1'] = ifs1[document.getElementById("ifs1").selectedIndex].ifs;
	SRV_MODBUS[row_idx]['vid1'] = ifs1[document.getElementById("ifs1").selectedIndex].vid;
}


function tabbtn_sel(form, sel)
{	
	if(sel == 0 || sel ==2){	// 0:add, 2:modify
		/* address: clean unuse filed data. */
		if(document.getElementById("modbusType").value == 0 || document.getElementById("modbusType").value == 2){
			document.getElementById("addr0").value = "";
			document.getElementById("addr1").value = "";
			form.modbusBaseOne.checked = false;
		}
		else {	// Master Query
			var function_code = document.getElementById("funccode").value;
			
			/* check addr valus. */

			if(document.getElementById("AddrSel").selectedIndex == 2){	// range
				if(form.modbusBaseOne.checked == true){
					if(form.addr0.value < 1 || form.addr0.value > 65535 || form.addr1.value < 1 || form.addr1.value > 65535){
						alert(MODBUS_ADDRESS + " must be between 1 and 65535 when PLC Address (Base 1) is checked");
						return;
					}
				}
				else{
					if(form.addr0.value < 0 || form.addr0.value > 65535 || form.addr1.value < 0 || form.addr1.value > 65535){
		   				alert(MODBUS_ADDRESS + " must be between 0 and 65535");
						return;
					}
	   			}
			}
			else if(document.getElementById("AddrSel").selectedIndex == 1){	// single
				if(form.modbusBaseOne.checked == true){
					if(form.addr0.value < 1 || form.addr0.value > 65535){
						alert(MODBUS_ADDRESS + " must be between 1 and 65535 when PLC Address (Base 1) is checked");
						return;
					}
				}
				else{
					if(form.addr0.value < 0 || form.addr0.value > 65535){
		   				alert(MODBUS_ADDRESS + " must be between 0 and 65535");
						return;
					}
	   			}
			}

			
			
			if(document.getElementById("AddrSel").selectedIndex == 0){	
				document.getElementById("addr0").value = "";
				document.getElementById("addr1").value = "";
			}
			else if(document.getElementById("AddrSel").selectedIndex == 1){	
				document.getElementById("addr1").value = "";
			}
			else{
				/* check address range. */
				if(form.addr0.value > form.addr1.value){
					alert("Address range is wrong.");
					return;
				}
			}
		}

		/* src_ip: clean unuse filed data. */
		if(document.getElementById("SrcIPSel").selectedIndex == 0){	// all	
			document.getElementById("src_ip0").value = "0.0.0.0";
			document.getElementById("src_ip1").value = "0.0.0.0";
		}
		else{
			if(!IpAddrIsOK(form.src_ip0, 'Source') ){
				return;
			}

			if(document.getElementById("SrcIPSel").selectedIndex == 1){	// single
				document.getElementById("src_ip1").value = "0.0.0.0";
			}
			
			else{	// range
				if(!IpAddrIsOK(form.src_ip1, 'Source')){
					return;
				}
				
				if(!ipRange(form.src_ip0, form.src_ip1, 'Source')){	
					return;
				}
			}
		}

		/* dst_ip: clean unuse filed data. */
		if(document.getElementById("DstIPSel").selectedIndex == 0){	// all	
			document.getElementById("dst_ip0").value = "0.0.0.0";
			document.getElementById("dst_ip1").value = "0.0.0.0";
		}
		else{
			if(!IpAddrIsOK(form.dst_ip0, 'Destination') ){
				return;
			}

			if(document.getElementById("DstIPSel").selectedIndex == 1){	// single
				document.getElementById("dst_ip1").value = "0.0.0.0";
			}
			
			else{	// range
				if(!IpAddrIsOK(form.dst_ip1, 'Destination')){
					return;
				}
				
				if(!ipRange(form.dst_ip0, form.dst_ip1, 'Destination')){	
					return;
				}
			}
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
		tablefun.mod();	
	}
	
	Total_Connections();	
}

function Move(form)
{

	entryNUM = nowrow-2;
	
	var idx = prompt("Moving Policy ID : "+(entryNUM+1)+"; enter policy ID to move before.", entryNUM+1);

	if(MoveIndexRange(idx, SRV_MODBUS)==-1)
		return;
	
	idx=idx-1;
	
	var i, j;

	if(idx > entryNUM)
	{
		for(i = entryNUM+1; i<=idx; i++){
			for(j in SRV_MODBUS[i]){
				//alert("SRV_MODBUS[" + i + "]["+j+"]="+SRV_MODBUS[i][j]);
				SRV_MODBUS[i-1][j] = SRV_MODBUS[i][j];
			}
		}
		
	}
	else
	{	
		for(i=entryNUM-1; i>=idx; i--){
			for(j in SRV_MODBUS[i]){
				//alert("SRV_MODBUS[" + i + "]["+j+"]="+SRV_MODBUS[i][j]);
				SRV_MODBUS[i+1][j] = SRV_MODBUS[i][j];
			}
		}
		
	}

	/* for tablefun.mod() to edit SRV_MODBUS in correct index.*/
	nowrow = idx + 2;
	
	tablefun.mod();	

	//Ifs_Vid_modify(nowrow-2);	// //nowrow is get from common.js 

	/* 	because tablefun.mod(); will do addformat, we can't correct the ifs and vid in time,
	 *	so we have to tablefun.reload(); to re-do the addformat.
	 */
	tablefun.reload();

	ChgColor('tri', tablefun.data.length, nowrow-2);
}


</script>
</head>
<body onLoad = fnInit()>
<h1><script language="JavaScript">doc(MODBUS_);doc(' ');doc(Setting_)</script></h1>
<fieldset>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_MODBUS_tmp" id="SRV_MODBUS_tmp" value="" >
<input type="hidden" name="SRV_MODBUS_GLOBAL_tmp" id="SRV_MODBUS_GLOBAL_tmp" value="" >
<input type="hidden" name="idx" id="idx">
<input type="hidden" name="multi_func" id="multi_func">
<% net_Web_csrf_Token(); %>



<table cellpadding=1 cellspacing=2 border=0 align=left width=300px> 
	<tr class=r0 >
		<td colspan=8>
			<script language="JavaScript">doc(Global_Parameters)</script>
		</td>
	</tr> 
</table>

<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:900px;"> 
	<tr align="left">
		<td width=200px>
			&nbsp;
			<script language="JavaScript">doc(MODBUS_MULTI_FUNC_CODE)</script>
		</td>  
		<td>
			<input type="checkbox" id=drop_multi_func_enable name="drop_multi_func_enable">
		</td>
		<td></td>
	</tr> 
	<tr align="left">
		<td width=200px>
			&nbsp;
			<script language="JavaScript">doc(MODBUS_DROP_MALFORMED_PKT_)</script>
		</td>  
		<td>
			<script language="JavaScript">iGenSel2_with_width('malEnable', 'malEnable', wtyp0, 130)</script>
		</td>
		<td></td>
	</tr> 
	<tr align="left">
		<td width=200px>
			&nbsp;
			<script language="JavaScript">doc(MODBUS_MODBUS_SERVICE_PORT_)</script>
		</td>  
		<td>
			<input type="text" id=service_port name="service_port" size=5 maxlength=5> 
		</td>
		<td></td>
	</tr> 
</table>
</DIV>

<table cellpadding=1 cellspacing=2 border=0 align=left width=300px> 
	<tr class=r0 >
		<td colspan=8>
			<script language="JavaScript">doc(MODBUS_POLICY_SET_)</script>
		</td>
	</tr> 
</table>

<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:900px;">
	<tr>
		<td align="left" valign="center">
			<table >
				<tr align="left">
					<td align="left" style="width:400px;">	
						<table > 
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
					 <td align="left" valign="center">
					 	<table > 
						 	<tr align="left">   
						  		<td style="width:100px;" align="left" valign="center">
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
</table>
</DIV>

<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:900px;">
	<tr>
		<td align="left" valign="center">

			<table > 
				<tr align="left">
					<td align="left" style="width:400px;">	
						<table > 
							<tr align="left">
								<td width=10px id="ifs_doc"><script language="JavaScript">doc(MODBUS_IFS_FROM)</script></td>
								<td width=50px id="ifs_setting"><script language="JavaScript">iGenSel2('ifs0', 'ifs0', ifs0)</script></td>
								<td width=10px id="ifs_doc"><script language="JavaScript">doc(MODBUS_IFS_TO)</script></td>
								<td id="ifs_setting"><script language="JavaScript">iGenSel2('ifs1', 'ifs1', ifs1)</script></td>
							</tr> 
						</table>
					</td>
					<td align="left" valign="center">	
						<table > 
							<tr>
								<td style="width:100px;" align="left" valign="center">
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
							       	<input type="text" id=src_ip1 name="src_ip1" size=15 maxlength=15></td> 
							   	</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>	
	</tr>
</table>
</DIV>

<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:900px;">
	<tr>
		<td align="left" valign="center">
			<table >
				<tr>
					<td style="width:400px;" align="left" valign="center">	
						<table > 
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
					<td align="left" valign="center">	
						<table > 
							<tr>
								<td style="width:100px;" align="left" valign="center">
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
									<input type="text" id=dst_ip1 name="dst_ip1" size=15 maxlength=15></td>
							   	</td>
							</tr>
						</table>
					</td>	
				</tr>
			</table>
		</td>	
	</tr>
</table>
</DIV>

<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:900px;">
	<tr align="left">
		<td width=60px>
			&nbsp;
			<script language="JavaScript">doc(UID)</script>
		</td>  
		<td id=advanceid0>
			<input type="text" id=uid name="uid" size=3 maxlength=3 >
			<script language="JavaScript">doc(MODBUS_UID_IGNORE)</script>
		</td>
		<td></td></tr> 
</table>
</DIV>

<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:900px;"> 
	<tr><td><table>
	<tr align="left">   
		<td width=120px>
			&nbsp;
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
	</table></td></tr>
</table>
</DIV>



<DIV style="height:30px">
<table cellpadding=1 cellspacing=2 border=0 align=left style="width:900px;"> 
	<tr><td><table>
	<tr align="left">   
		<td width=120px>
			&nbsp;
			<script language="JavaScript">doc(MODBUS_COMMAND_TPYE_)</script>
		</td>  
		<td >
			<script language="JavaScript">iGenSel3('modbusType', 'modbusType', modbusType, 'funcCommandTypeSel')</script>
		</td>
	</tr> 
	</table></td></tr>
</table>
</DIV>

<DIV style="height:30px">
<table border=0 align=left style="width:900px;"> 
	<tr align="left">
		<td width=120px>
			&nbsp;
			<script language="JavaScript">doc(MODBUS_ADDRESS)</script>
		</td>
		<td width=280px>
			<table>
				<tr>
					<td style="width:30px;" align="left" valign="center">
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
				       <input type="text" id=addr1 name="addr1" size=5 maxlength=5></td>
				    
				    </td>
				</tr>
			</table>
		</td>
		
		<td width=140px>
			<script language="JavaScript">doc(MODBUS_PLC_ADDR_ONE_BASE_)</script>
		</td>  
		<td>
			<input type="checkbox" id=modbusBaseOne name="modbusBaseOne">
		</td>
	</tr>
</table>
</DIV>


</DIV>
<table>
<tr><td>
<p><table class=tf align=left>
 <tr>
  <td ><script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnBID("Move", 'onClick=Move(this.form)', 'btnMove')</script></td>
  <td width=30></td>
  <td><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
  <td width=15></td>
  <!--td><script language="JavaScript">fnbnSID(adv, 'onClick=Advance(this.form)', 'btnAdv')</script></td>
  <td width=15></td--></tr>
</table></p>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2>
	<tr class=r0>
	 <td width=140px><script language="JavaScript">doc(MODBUS_LIST)</script></td>
	 <td id = "totalcercnt" colspan=5></td></tr>
</table>
</td></tr>
<tr><td>
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
</td></tr>
</table> 

</form>
</fieldset>
</body></html>

