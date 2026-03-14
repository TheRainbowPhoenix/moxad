<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkMode(<% net_Web_GetMode_WriteValue(); %>);
var No_WAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
var NoMAC_PORT = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %>;
var SYS_PORTS = <% net_Web_Get_SYS_PORTS(); %>	
var SWITCH_ROUTER=((parseInt(SYS_PORTS) > parseInt(NoMAC_PORT))&& (No_WAN > 0));
var button_disable = 0

checkCookie();
if (!debug) {
	var SRV_IPSEC = [
	{rendip:'192.168.3.202', enable:'0', compress:'1', l2tp:'1', name:'no_vmd', seclevel:2, connifs:'0', startup:'0', any_ip:'0',
	 lnet:'192.168.127.254', lmask:'255.255.255.0', lid:'', rnet:'20.20.20.20', rmask:'255.255.255.0', rid:'',
	 ikemode:'0', psk:'1234567890', lselpem:'1',rselpem:'2', exchg:'0', p1enc:'3', p1ah:'0', p1dh:'0', negotimes:'3', ikelifetime:'180', 
	 rekeyexpiretime:'540', rekeyfuzz:'100', pfs:'0', salifetime:'2800', p2enc:'0', p2ah:'1', 
	 dpdact:'1', dpddelay:'30', dpdtimeout:'120'
	}
	];

	var slepem0 = [
		{ value:0, text:"server" },	{ value:1, text:"aries" },	{ value:1, text:"moxa" }
	];	
	var SRV_LAN = {
		ipad:'0.0.0.0', mask:'0.0.0.0'
	};	

}else{
	<%net_Web_show_value('SRV_IPSEC');%>

	var selpem0 = [];	
	var selpem1 = [];

	var cer_mgmt = [
		<%net_webCERMgmt();%>		
	];	
	
	if(SWITCH_ROUTER){
		var SRV_LAN={lanip:'192.168.127.254',lanmask:'255.255.255.0'};
		<%net_Web_show_value('SRV_VCONF');%>
		SRV_LAN.lanip = SRV_VCONF[0].ip;
		SRV_LAN.lanmask = SRV_VCONF[0].mask;
	}else{
		<%net_Web_show_value('SRV_LAN');%>
	}
	
}

var default_data = {
	 compress:'0', l2tp:'0', connifs:'0', startup:'0', exchg:'0', negotimes:'0', ikelifetime:'1', rekeyexpiretime:'9', rekeyfuzz:'100', 
	 pfs:'0', salifetime:'480',dpdact:'1', dpddelay:'30', dpdtimeout:'120'
};

var simple_data = {
	 p1enc:'0', p1ah:'1', p1dh:'768', p2enc:'0', p2ah:'1'
};

var standard_data = {
	 p1enc:'1', p1ah:'2', p1dh:'1024', p2enc:'1', p2ah:'2'
};

var strong_data = {
	 p1enc:'4', p1ah:'3', p1dh:'2048', p2enc:'4', p2ah:'3'
};

var default_SRV_IPSEC_type = {	
	compress:3, l2tp:3, connifs:2, startup:2, exchg:2, negotimes:4, ikelifetime:4, rekeyexpiretime:4, rekeyfuzz:4, 
	pfs:3, salifetime:4, dpdact:2, dpddelay:4, dpdtimeout:4
};

var level_SRV_IPSEC_type = {	
	p1enc:2, p1ah:2, p1dh:2, p2enc:2, p2ah:2
};
	var ipcnt;
	var entryNUM=0;

var showentry = { enable:0, name:0, rendip:0, lnetstring:0, rnetstring:0};

var authtyp0 = [
	{ value:0, text:IPsec_PSK_ },	{ value:1, text:IPsec_X509_ },	{ value:2, text:IPsec_X509_CA_ }
];

var enctyp0 = [
	{ value:0, text:IPsec_DES_ },	{ value:1, text:IPsec_3DES_ },	{ value:2, text:IPsec_AES_128_ }
,	{ value:3, text:IPsec_AES_192_}, { value:4, text:IPsec_AES_256_ }
];	//for phase 1
var enctyp1 = [
	{ value:0, text:IPsec_DES_ },	{ value:1, text:IPsec_3DES_ },	{ value:2, text:IPsec_AES_128_ }
,	{ value:3, text:IPsec_AES_192_}, { value:4, text:IPsec_AES_256_ }, { value:5, text:NULL_ }
];	//for phase 2


var ahtyp0 = [
	{ value:0, text:Any_}, { value:1, text:IPsec_MD5_},	{ value:2, text:IPsec_SHA_1_}, 	
	{ value:3, text:IPsec_SHA_256_}	
];


var ahtyp1 = [
	{ value:0, text:Any_}, { value:1, text:IPsec_MD5_},	{ value:2, text:IPsec_SHA_1_}
];//if enctyp1 option NULL is selected, the phase 2 ah type have to change this type

var dhtyp0 = [
	{ value:768, text:IPsec_DH1_}, { value:1024, text:IPsec_DH2_}, { value:1536, text:IPsec_DH5_}, { value:2048, text:IPsec_DH14_},
];

var connif0 = [
	{ value:0, text:IPT_LOAD_IF_WAN1},	{ value:1, text:IPT_LOAD_IF_WAN2},	{ value:255, text:IPsec_D_Route_}
];

var dpdtype0 = [
	{ value:0, text:IPsec_DPD_Hold_}, { value:1, text:IPsec_DPD_Restart_}, { value:2, text:IPsec_DPD_Clear_}, { value:3, text:Disable_}
];

var starttype0 = [
	{ value:0, text:IPsec_Auto_Start_},	{ value:1, text:IPsec_Auto_Add_}
];

var exchgtype0 = [
	{ value:0, text:IPsec_EX_MAIN_MODE_},	{ value:1, text:IPsec_EX_AGGR_MODE_}
];

var linkiptype0 = [
	{ value:0, text:IPsec_Link_S2S_},	{ value:1, text:IPsec_Link_S2S_Any_}
];

var idtype = [
	{ value:0, text:IP_Address},	{ value:1, text:FQDN_},	{ value:2, text:KEYID_}, { value:3, text:AUTO_ID_}
];


var vobjs = {};
var vname = [ 'pskey', 'certificate0','certificate1','certificate2','certificate3',];
var newdata=new Array;


var selauthtyp = { type:'select', id:'authmode', name:'ikemode', size:1, onChange:'fnChgAuthType(this.value)', option:authtyp0};

var myForm;

function ShowSubnetString(idx)
{	
	var i;
	document.getElementById('lnetstring').value="";
	document.getElementById('rnetstring').value="";
	
	//document.getElementById('lnetstring').value += SRV_IPSEC[idx]['lnet'] + '/' + ipMask2Number(SRV_IPSEC[idx]['lmask'])+ ',';
	for(i=0;i<10;i++){
		if(SRV_IPSEC[idx]['lnet'+i] == "0.0.0.0"){
			continue;
		}
		document.getElementById('lnetstring').value += SRV_IPSEC[idx]['lnet'+i] + '/' + ipMask2Number(SRV_IPSEC[idx]['lmask'+i])+ ',';	
	}

	//document.getElementById('rnetstring').value += SRV_IPSEC[idx]['rnet'] + '/' + ipMask2Number(SRV_IPSEC[idx]['rmask'])+ ',';
	for(i=0;i<10;i++){
		if(SRV_IPSEC[idx]['rnet'+i] == "0.0.0.0"){
			continue;
		}
		document.getElementById('rnetstring').value += SRV_IPSEC[idx]['rnet'+i] + '/' + ipMask2Number(SRV_IPSEC[idx]['rmask'+i])+ ',';	
	}
		
	
}


function fnChgAuthType(val) {
	with (document) {
		vobjs.pskey.style.display 	  	 = (val==0) ? '' : 'none' ;
		vobjs.certificate0.style.display = (val==1||val==2) ? '' : 'none' ;
		vobjs.certificate1.style.display = (val==1||val==2) ? '' : 'none' ;
		vobjs.certificate2.style.display = (val==1) ? '' : 'none' ;
		vobjs.certificate3.style.display = (val==1) ? '' : 'none' ;
	}
}


var table_idx = 0;

var tablefun = new table_set_diff_show(document.getElementsByName('form1'),"show_available_table" ,SRV_IPSEC_type, SRV_IPSEC, table_idx, newdata, Addformat, showentry, entryinit);
var p1ah = new Array;
var p2ah = new Array;
var enc_tmp = new Array;

function ahchange(phase, idx){
	var ah_tmp, i;
	if(enctyp1[enctyp1.length - 1].value - idx != 0){
		if(enctyp1[enctyp1.length - 1].value - enc_tmp[phase] != 0){
			enc_tmp[phase] = idx;
			return;
		}		
	}
	if(phase == 1){		
		ah_tmp = document.getElementById('p1ah');
	}else{
		ah_tmp = document.getElementById('p2ah');
	}
	enc_tmp[phase] = idx;

	ah_tmp.options.length=0; 
	
	if(idx == enctyp1[enctyp1.length - 1].value){
		for(i = 0; i < ahtyp1.length; i++){
			ah_tmp.options.add(new Option(ahtyp1[i].text,ahtyp1[i].value)); 
		}		
	}else{
		for(i = 0; i < ahtyp0.length; i++){
			ah_tmp.options.add(new Option(ahtyp0[i].text,ahtyp0[i].value)); 
	}
}

}
function p1ahchange(idx){
	if(idx == 0){
		document.getElementById('p1dh').disabled=true;
	}else{
		document.getElementById('p1dh').disabled=false;
	}
}

function p2ahchange(idx){
	 ahchange(2,idx);
}

function EditRow(row) {
	fnLoadForm(myForm, SRV_IPSEC[row], SRV_IPSEC_type);
	ChgColor('tri', SRV_IPSEC.length, row);
}

var subnetsname=["lnetstring","rnetstring"];
//var netname=["lnet","rnet"];
//var maskname=["lmask","rmask"];
var netsname=["lnet","rnet"];
var masksname=["lmask","rmask"];




function row_tunnel(row)
{
	var i, loop, idx, count=0, snet=new Array;

	if(row>SRV_IPSEC.length){
		return 0;
	}
	if(SRV_IPSEC[row]['l2tp']=='0'){
		for(loop=0;loop<2;loop++){
			snet[loop]=0;
			idx=0;
			while(SRV_IPSEC_type[netsname[loop]+idx]){
				if(IP2V(SRV_IPSEC[row][netsname[loop]+idx])==0){
					break;
				}
				snet[loop]++;
				idx++;
			}
		}
		if(!snet[0] || !snet[1]){
			snet[0] = 1;
			snet[1] = 1;
		}
	}else{
		snet[0] = 1;
		snet[1] = 1;
	}

	return snet[0]*snet[1];
}


function Total_Tunnel()
{
	var i, count=0;
	for(i=0;i<SRV_IPSEC.length;i++){
		count+=row_tunnel(i);
	}

	return count;
}


function New_Setting_Total_Tunnel(row)
{
	var i, loop, idx, count=0, snet=new Array;
	for(loop=0;loop<2;loop++){
		snet[loop]=0;
		idx=0;
		while(SRV_IPSEC_type[netsname[loop]+idx]){
			if(IP2V(document.getElementById(netsname[loop]+idx).value)==0){
				break;
			}
			snet[loop]++;
			idx++;
		}
	}
	count+=snet[0]*snet[1];


	return count+Total_Tunnel()-row_tunnel(row);
	
}

var IPSEC_MAX;
function Total_Connections()
{			
	if(Total_Tunnel() > IPSEC_MAX || Total_Tunnel()  < 0){		
		alert('Number of ip is Over or Wrong');
		with(document){
			getElementById('btnA').disabled = true;			
			getElementById('btnD').disabled = false;			
			getElementById('btnM').disabled = false;			
			getElementById('btnU').disabled = true;
		}				
	}else if(Total_Tunnel() == IPSEC_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnU').disabled = false;
		}
	}else if(Total_Tunnel() == 0){			
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
	document.getElementById("totalcercnt").innerHTML = '('+Total_Tunnel() +'/' +IPSEC_MAX+')';
}

function check_any(idx){
	var i, cnt;
	cnt=0;
	for(var i = 0; i < SRV_IPSEC.length; i++){
		if(i == idx || SRV_IPSEC[i]['enable'] == 0)
			continue;
		if(SRV_IPSEC[i]['any_ip'] == 1){
			return -1;
		}
	}
	return 0;
}

if(ProjectModel == MODEL_EDR_G903){
	var MAX_RUNNING=25;
	var MAX_START_IN_INIT=5;
}
else{
	var MAX_RUNNING=10;
	var MAX_START_IN_INIT=5;
}

function check_ipsecname_firstword(name){
	var regu = "^[0-9]";       
	var re = new RegExp(regu);    
	if (re.test( name ) ) {    
		return 1;    
	}else{
		return 0;
	}
}


function subnetString_set()
{
	var i,idx, string, token, mask;

	for(i=0;i<2;i++){
		string = document.getElementById(subnetsname[i]).value;
		string = string.split(",");
		for(idx=0;idx<string.length;idx++){
			if(string[idx]==""){
				break;
			}
			token = string[idx].split("/");
			if(!isIP(token[0])){
	   			alert("subnet must be ip address:"+token[0]);
				return;
	   		}
			mask = parseInt(token[1]);
			if(mask<8 || mask >32){
	   			alert("netmask must be in 0~32:"+token[1]);
				return;
	   		}
			document.getElementById(netsname[i]+idx).value=token[0];
			document.getElementById(masksname[i]+idx).value=Number2ipMask(token[1]);
		}

		if(string==""){
			idx=0;
		}else{
			idx=string.length;
		}
		for(;idx<10;idx++)
		{
			document.getElementById(netsname[i]+idx).value="0.0.0.0";
			document.getElementById(masksname[i]+idx).value="0.0.0.0";
		}
	}
}



function tabbtn_sel(form, sel)
{
if(button_disable == 0){
   	if(sel == 0 || sel == 2){
   		if(sel == 0){
   			table_idx = IPSEC_MAX;
   		}else{
   			table_idx = tNowrow_Get();
   		}
		subnetString_set();
   		if(!isIP(form.remoteip.value)){
   			alert(IPsec_Remote_GW_+" must be ip address");
			return;
   		}
		if(document.getElementById('idtype').value==0){
			if(document.getElementById('lid').value!=""){
				if(!isIP(document.getElementById('lid').value)){
		   			alert(Local_ +' '+ ID_+" must be ip address");
					return;
		   		}
			}

			if(document.getElementById('rid').value!=""){
				if(!isIP(document.getElementById('rid').value)){
		   			alert(Remote_ +' '+ ID_+" must be ip address");
					return;
		   		}
			}
		}
   		if(check_ipsecname_firstword(document.getElementById("ipsecnm").value)){
   			alert(IPsec_Name_Error);
   			return;
   		}
   		if(document.getElementById('dpddelay').value>3600){
   			alert(Delay_+" must be less 3600");
   		}else if(document.getElementById('dpdtime').value>3600){
   			alert(Timeout_+" must be less 3600");
   		}
    	if(document.getElementById('l2tptunnel').checked==false){
    		if(!((IsIpOK(form.lnet0, Subnet_)) && (IsIpOK(form.rnet0, Subnet_))))
			{
				return;
			}
		}
		
		if(isSymbol(document.getElementById('myForm')["ipsecnm"], Name_))
		{
			return;
		}
	    
		if(!(isNull(document.getElementById('myForm')["pskey"].value))){
		    if(isSymbol(document.getElementById('myForm')["pskey"], IPsec_PSK_))
			{
					return;
			}
		}else{
			alert(IPsec_PSK_ + "can not be null");
			return;
		}
		
	    var stat_cnt=0, startup_cnt=0;
        for(var i = 0; i < SRV_IPSEC.length; i++){
		    if(table_idx == i || SRV_IPSEC[i]['l2tp']==1){
			//continue;
		    }else{
			    if(form.l2tptunnel.checked!=true &&(subnet_mapping_check(i, SRV_IPSEC, "lnet0", "lmask0", form.lnet0.value, form.lmask0.value)) >= 0) {
			    	if((subnet_mapping_check(i, SRV_IPSEC, "rnet0", "rmask0", form.rnet0.value, form.rmask0.value)) >= 0){
				    	if(SRV_IPSEC[i]['connifs'] == form.connif.value && SRV_IPSEC[i]['rendip']==form.remoteip.value){
					    	alert("Subnet duplicate");
						    return;
				    	}				
			    	}
		    	}
	    	}
		    if(document.getElementById('stat').checked==true){
		    	if(SRV_IPSEC[i]['enable']!=0 && i!=table_idx){
		    		stat_cnt++;
			    	if(stat_cnt >= MAX_RUNNING){
			    		alert("Only "+MAX_RUNNING+ " tunnels enable");
			    		return;
			    	}
		    	}   
		    }

   			if(document.getElementById('start_up').value==0){
    			if(SRV_IPSEC[i]['startup']==0 && i!=table_idx&&SRV_IPSEC[i]['enable']==1){
    				startup_cnt++;
    				if(startup_cnt >= MAX_START_IN_INIT){
	    				alert("Only "+MAX_START_IN_INIT+ " Start in initial");
		    			return;
			    	}
		    	}
		    }
    	}
		
	    if(duplicate_check(table_idx, SRV_IPSEC, "name", document.getElementById('myForm')["name"].value, Name_  + ' ' + document.getElementById('myForm')["name"].value + ' '  + "is exist")<0){
		    return;
    	}
		/*if(document.getElementById('myForm')["any_ip"].value==1){
			if(check_any(table_idx) == -1){
				alert("Just can set 1 "+ IPsec_Link_S2S_Any_);
				return;
			}
		}*/
		

		if(New_Setting_Total_Tunnel(table_idx) > IPSEC_MAX){ 
			alert("Max Tunnel Setting is "+IPSEC_MAX);
			return;
		}
			
   	}	
	
    if(sel == 0){		
    	Addformat(1,0);
    	tablefun.add();	
   	}else if(sel == 1){
    	tablefun.del();
    }else if(sel == 2){
   		tablefun.mod();		
   	}
   	Total_Connections();
}
}

function fnEnAnyIP(anyipen) {
	var dpd_tmp, i;

	dpd_tmp = document.getElementById('dpdact');	
	dpd_tmp.options.length=0; 	
	if(anyipen){
		for(i = 0; i < dpdtype0.length; i++){
			if(dpdtype0[i].text == IPsec_DPD_Restart_){
				continue;
			}
			dpd_tmp.options.add(new Option(dpdtype0[i].text,dpdtype0[i].value)); 
		}		
	}else{		
		for(i = 0; i < dpdtype0.length; i++){
			if(dpdtype0[i].text == IPsec_DPD_Clear_){
				continue;
			}
			dpd_tmp.options.add(new Option(dpdtype0[i].text,dpdtype0[i].value)); 
		}
	}
	
	if(SRV_IPSEC!=""){
		for (i=0; i < dpd_tmp.options.length; i++){
			if (dpd_tmp.options[i].value == SRV_IPSEC[tNowrow_Get()]['dpdact']){
				dpd_tmp.selectedIndex = i;
				break;
			}
		}
	}else{
		i = dpd_tmp.options.length;
	}

	if(i == dpd_tmp.options.length){
		dpd_tmp.selectedIndex = 1;//default restart
	}
	
	
	with (myForm) {
		
		if(SRV_IPSEC!=""){
			if(tNowrow_Get()>=0){
				remoteip.value=anyipen?"0.0.0.0":SRV_IPSEC[tNowrow_Get()]['rendip'];		
			}
		}
		remoteip.disabled = anyipen?true:false;		
		startup.disabled = anyipen?true:false;
		if(anyipen == true){
			startup.value=1;
		}		
	}	
}


function DataNullInitl(){	
	document.getElementsByName('mdoe_sel')[0].checked=1;
	//myForm.secleve2.checked=true;
	document.getElementById('lnetstring').value="";
	document.getElementById('rnetstring').value="";
	settingmodechg(false);
}

function entryinit(idx)
{		
	if(idx >= 0){		
		settingmodechg(SRV_IPSEC[idx]['seclevel']==0?true:false);//o for advance mode
		ShowSubnetString(idx);
	}else{
		DataNullInitl();
	}
	/*if(idx >= 0){	
		if(SRV_IPSEC[idx]['rendip']=="0.0.0.0"){
			document.getElementById('anyip').selectedIndex=1;
		}else{
			document.getElementById('anyip').selectedIndex=0;
		}
		if(document.getElementById('anyip').onchange){
			document.getElementById('anyip').onchange();
		}
	}*/
}

function Addformat(mod,i)
{	
	var i, j;
	var k;
	var type;
	for(k in SRV_IPSEC_type){
		if(!document.getElementsByName(k)[0]){
			continue;
		}
		type = document.getElementsByName(k)[0].type;
		if(type == "checkbox"){
			if(mod==0){
				if(SRV_IPSEC[i][k]==1)
					newdata[k]="<IMG src=" + 'images/enable_3.gif'+ ">";
				else
					newdata[k]= "<IMG src=" + 'images/disable_3.gif'+ ">";
			}else{
				if(document.getElementById('myForm')[k].checked==true)
					newdata[k]="<IMG src=" + 'images/enable_3.gif'+ ">";
				else
					newdata[k]= "<IMG src=" + 'images/disable_3.gif'+ ">";
			}	
			j++;	
			continue;	
		}
			
		if(mod==0){
			/*if(k == 'rendip'){
				if(SRV_IPSEC[i]['any_ip'] == 1){
					SRV_IPSEC[i][k]='0.0.0.0';
				}
			}*/
			newdata[k] = SRV_IPSEC[i][k];			
		}else{
			//alert(k);
			newdata[k] = document.getElementById('myForm')[k].value;
			/*if(k == 'rendip'){ 
				if(document.getElementById('myForm')['any_ip'].checked==true){
					document.getElementById('myForm')[k].value='0.0.0.0';
				}				
			}*/
			//if(k == 'seclevel'){
			if(type == "radio"){
				newdata[k] = GetRadioValue(document.getElementsByName(k));				
			}						
		}		
	}
	for(i=0;i<2;i++){
		newdata[subnetsname[i]]="";
		for(idx=0;idx<10;idx++)
		{
			if(newdata[netsname[i]+idx]=="0.0.0.0"){
				break;
			}
			if(idx!=0){
				newdata[subnetsname[i]] += ",\n";
			}
			newdata[subnetsname[i]] += newdata[netsname[i]+idx] + '/' + ipMask2Number(newdata[masksname[i]+idx]);
		}
	}
}

var time_of_Act = 0;
function Activate(form)
{	
    
    time_of_Act++;
	document.getElementById("btnU").disabled="true";
	var i;
	var j;
    form.SRV_IPSEC_tmp.value = "";

	var myForm = document.getElementById('myForm');	
	var netwk1, netwk2;
	var same = 0;	

	for(i = 0 ; i < SRV_IPSEC.length ; i++)
	{
		for (var j in SRV_IPSEC[i]){
			//if(j == 'lid' || j == 'rid' ){
				if(SRV_IPSEC[i][j] == ''){
					SRV_IPSEC[i][j]=' ';
				}
			//}
			form.SRV_IPSEC_tmp.value = form.SRV_IPSEC_tmp.value + SRV_IPSEC[i][j] + "+";	
		}
	}
    
    button_disable = 1;

	form.action="/goform/net_Web_get_value?SRV=SRV_IPSEC";	
	form.submit();	
}

	
function Advance(mode)
{
	document.getElementById('advance0').style.display=(!mode)?'none':'';
	document.getElementById('advance1').style.display=(!mode)?'none':'';
	document.getElementById('advance2').style.display=(!mode)?'none':'';	
	document.getElementById('advance3').style.display=(!mode)?'none':'';	
	document.getElementById('advanceid0').style.display=(!mode)?'none':'';	
	//document.getElementById('advanceid1').style.display=(!mode)?'none':'';			
	document.getElementById('p1dhdispay0').style.display=(!mode)?'none':'';	
	document.getElementById('p1dhdispay1').style.display=(!mode)?'none':'';	
	document.getElementById('exchg0').style.display=(!mode)?'none':'';	
	document.getElementById('exchg1').style.display=(!mode)?'none':'';
	document.getElementById('p1secdispay').style.display=(!mode)?'none':'';		
	document.getElementById('phase2table').style.display=(!mode)?'none':'';	
	//document.getElementById('ipcomp0').style.display=(!mode)?'none':'';		
	//document.getElementById('ipcomp1').style.display=(!mode)?'none':'';		

	var table = document.getElementById("securitylevel");
	var rows = table.getElementsByTagName("tr");
	var i;
	if(rows.length > 2)
	{
		for(i=rows.length-1; i > 1; i--)
		{
			table.deleteRow(i);
		}
	}
	myForm = document.getElementById('myForm');	
	if(mode == false){
		document.getElementsByName('lid').value="";
		document.getElementsByName('rid').value="";
		mode = GetRadioValue(document.getElementsByName('seclevel'))			
		if(mode < 4){		
			fnLoadForm(myForm, default_data, default_SRV_IPSEC_type);					
			if(mode == 1){
				fnLoadForm(myForm, simple_data, level_SRV_IPSEC_type);		
			}else if(mode == 2){
				fnLoadForm(myForm, standard_data, level_SRV_IPSEC_type);		
			}else if(mode == 3){
				fnLoadForm(myForm, strong_data, level_SRV_IPSEC_type);		
			}			
		}		
	}
		
}
	

function settingmodechg(mode)
{
	var i;	
	for(i = 0; i < document.getElementsByName('setmodechg').length; i++){
		document.getElementsByName('setmodechg')[i].style.display=(!mode)?'none':'';
	}
	document.getElementById('securitylevel').style.display=(mode)?'none':'';			
	document.getElementById('authmode').disabled=(!mode)?true:false;		
	if(mode == false){
		document.getElementById('authmode').value=0;	
		fnChgAuthType(mode);
		//myForm.lnet0.value=SRV_LAN.lanip;
		//myForm.lmask0.value=SRV_LAN.lanmask;
		document.getElementById('lnetstring').value = SRV_LAN.lanip + '/' + ipMask2Number(SRV_LAN.lanmask);			
		L2TPMode(false);	
		document.getElementsByName('mdoe_sel')[0].checked=1;		
		if(tNowrow_Get()>=0&&SRV_IPSEC!=""){
			if(SRV_IPSEC[tNowrow_Get()]['seclevel'] == 0){
				document.getElementsByName('seclevel')[1].checked=true;
			}else{
				document.getElementsByName('seclevel')[SRV_IPSEC[tNowrow_Get()]['seclevel']-1].checked=true;
			}
		}else{
			document.getElementsByName('seclevel')[1].checked=true;
		}
	}else{
		if(tNowrow_Get()>=0&&SRV_IPSEC!=""){
			fnLoadForm(myForm, SRV_IPSEC[tNowrow_Get()], SRV_IPSEC_type);
		}				

		myForm['mdoe_sel'][1].checked=1;
		if(SRV_IPSEC!=""){
			L2TPMode(SRV_IPSEC[tNowrow_Get()]['l2tp']==0?false:true);	
		}else{
			L2TPMode(false);	
		}
		document.getElementsByName('mdoe_sel')[1].checked=1;		
		myForm.secleve4.checked=true;
	}		
	Advance(mode);		
}




	
function L2TPMode(mode){
	document.getElementById('subnet').style.display=(mode)?'none':'';		
	document.getElementById('anyip').disabled=(mode)?true:false;		
	document.getElementById('ipcomp1').disabled=(mode)?true:false;		
	document.getElementById('ipcomp1').checked=false;
	if(tNowrow_Get()>=0&&SRV_IPSEC!=""){
		document.getElementById('anyip').value=(mode)?1:SRV_IPSEC[tNowrow_Get()]['rendip']=='0.0.0.0'?1:0;		
		if(!mode){
			document.getElementById('ipcomp1').checked = SRV_IPSEC[tNowrow_Get()]['compress']==1?true:false;
		}
	}else{
		document.getElementById('anyip').value=(mode)?1:0;		
	}
	if(document.getElementById('anyip').onchange){
		document.getElementById('anyip').onchange();
	}
	if(mode){
		document.getElementById('lnetstring').value="";
		document.getElementById('rnetstring').value="";
	}
}


function idchange(typevalue){
	if(typevalue==3){
		document.getElementById("lid").value="";
		document.getElementById("rid").value="";
		document.getElementById("lid").disabled=true;
		document.getElementById("rid").disabled=true;
	}else{
		document.getElementById("lid").disabled=false;
		document.getElementById("rid").disabled=false;
	}
}


function subnetadd()
{
	var subnetdata=new Array;
	var idx=0, loop;

	for(loop=0; loop < 2; loop++){
		idx=0;
		while(SRV_IPSEC_type[netsname[loop]+idx]){
			subnetdata[0] = "<input type=\"text\" id="+netsname[loop]+idx+" name=\""+netsname[loop]+idx+"\" size=15 maxlength=15 >"
			subnetdata[1] = "<input type=\"text\" id="+masksname[loop]+idx+" name=\""+masksname[loop]+idx+"\" size=15 maxlength=15 ></td>";
			idx++;
			tableaddRow("hiddensubnet", 0, subnetdata, "center");
		}
	}	
}

function ceroptionadd(){
	var key_tmp, i;

	key_tmp = document.getElementById('x509peml');
	key_tmp.options.length=0; 



	for(i = 0; i < cer_mgmt.length; i++){
		if(cer_mgmt[i].key_name==''){
			continue;
		}
		key_tmp.options.add(new Option(cer_mgmt[i].cer_name, cer_mgmt[i].cer_name)); 
	}
	key_tmp = document.getElementById('x509pemr');
	key_tmp.options.length=0; 

	for(i = 0; i < cer_mgmt.length; i++){
		key_tmp.options.add(new Option(cer_mgmt[i].cer_name, cer_mgmt[i].cer_name)); 
	}

}


function fnInit() {
	if(ProjectModel == MODEL_EDR_G903){
		IPSEC_MAX = 25;
	}else{
		IPSEC_MAX = 10;
	}
	with (document) {		
		for (var i in vname){
			vobjs[vname[i]] = getElementById(vname[i]);
		}	
	}
	ceroptionadd();
	subnetadd();
	myForm = document.getElementById('myForm');
	fnChgAuthType(0);		
	tablefun.show();
	Total_Connections();	
	EditRow(0);
	entryinit(SRV_IPSEC!=""?0:-1);

	//if(ProjectModel == MODEL_EDR_G902)
	if(No_WAN<=1)
	{
		document.getElementById("ifs_setting").style.display="none";
		document.getElementById("ifs_doc").style.display="none";
		document.getElementById("start_mode").style.width="129px";	
	}
}


function stopSubmit()
{
	return false;
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(IPsec_);doc(' ');doc(Setting_)</script></h1>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<fieldset>
<input type="hidden" name="SRV_IPSEC_tmp" id="SRV_IPSEC_tmp" value="" >
<input type="hidden" name="lnhop" id="lnhop" value="" >
<input type="hidden" name="rnhop" id="rnhop" value="" >
<% net_Web_csrf_Token(); %>
<DIV style=" height:360px; overflow-y:auto; width:700px">

<table cellpadding=1 cellspacing=2 border=0 width=680px id=setmode> 
 <tr class=r0 >
  <td width = 150px><script language="JavaScript">doc(Setting_)</script></td>
  <td width = 150px><input type="radio" id=modesel name="mdoe_sel" onClick=settingmodechg(false) value=0 > 
  	<script language="JavaScript">doc(QUICK_+' '+Setting_);</script>
</td>
  <td ><input type="radio" id=modesel name="mdoe_sel" onClick=settingmodechg(true) value=1 > <script language="JavaScript">doc(ADVANCED_);doc(' ');doc(Setting_);</script></td></tr>
</table>

<table cellpadding=1 cellspacing=2 border=0  width=680px>
<tr class=r0 >
  <td colspan=8><script language="JavaScript">doc(IPsec_Tunnel_Set_)</script></td></tr>  
 <tr align="left">   
  <td width=40px><script language="JavaScript">doc(Enable_)</script></td>
  <td width=39px><input type="checkbox" id=stat name="enable"></td>  
  <td width=40px><script language="JavaScript">doc(Name_);doc("&nbsp;&nbsp;");</script></td>
  <td width=135px><input type="text" id=ipsecnm name="name" size=10 maxlength=16></td>      
  <td width=100px id=setmodechg name=setmodechg><script language="JavaScript">doc(IPsec_L2TP_TUNNEL_)</script></td>
  <td id=setmodechg name=setmodechg><input type="checkbox" id=l2tptunnel name="l2tp" onClick=L2TPMode(this.checked)></td>      
  <td style="display:none"><script language="JavaScript">doc(IPsec_Compress)</script></td>
  <td style="display:none"><input type="checkbox" id=ipcomp1 name="compress"></td>    
  <td></td>    
  <!--td width=60px id=setmodechg name=setmodechg><input type="checkbox" id=l2tptunnel name="l2tp" onClick=L2TPMode(this.checked)></td>      
  <td width=40px id=ipcomp0><script language="JavaScript">doc(IPsec_Compress)</script></td>
  <td ><input type="checkbox" id=ipcomp1 name="compress"></td-->    
  </tr>    
</table>

<table cellpadding=1 cellspacing=2 border=0 width=680px> 
 <tr>
  <td width=129px align="left"><script language="JavaScript">doc(IPsec_Conn_Type_)</script></td>  
  <!--td width=90px><script language="JavaScript">doc(IPsec_rendip_Any_);doc("&nbsp;&nbsp;");</script></td-->
  <td width=135px align="left"><script language="JavaScript">iGenSel3('any_ip', 'anyip', linkiptype0, "fnEnAnyIP")</script></td>  
  <td width=135px align="left"><script language="JavaScript">doc(IPsec_Remote_GW_)</script></td>  
  <td><input type="text" id=remoteip name="rendip" size=15 maxlength=40></td>  
  </tr>  
</table>

<table cellpadding=1 cellspacing=2 border=0 width=680px>
 <tr align="left" id=setmodechg name=setmodechg>
  <td width=120px id="ifs_doc"><script language="JavaScript">doc(IPsec_Conn_IF_)</script></td>
  <td width=135px id="ifs_setting"><script language="JavaScript">iGenSel2('connifs', 'connif', connif0)</script></td>
  <td width=122px id="start_mode"><script language="JavaScript">doc(IPsec_Startup_)</script></td>
  <td><script language="JavaScript">iGenSel2('startup', 'start_up', starttype0)</script></td>  
 </tr>
</table>

<table cellpadding=1 cellspacing=2 border=0 width=680px id=subnet> 
 <tr align="left" id=setmodechg name=setmodechg>   
  <td width=68px><script language="JavaScript">doc(Local_)</script></td>  
  <td width=60px><script language="JavaScript">doc(NETWORK_)</script></td>  
  <td colspan="5"><input type="text" id=lnetstring name="lnetstring" size=50 maxlength=200 ></td>
 </tr>    
 <tr align="left">  
  <td><script language="JavaScript">doc(Remote_)</script></td>  
  <td><script language="JavaScript">doc(NETWORK_)</script></td>  
  <td colspan="5"><input type="text" id=rnetstring name="rnetstring" size=50 maxlength=200 ></td>
 </tr> 
 <tr align="left" id=advanceid0>
  <td><script language="JavaScript">doc(Identity_)</script></td>
  <td><script language="JavaScript">doc(Type_)</script></td>  
  <td><script language="JavaScript">iGenSel3('idtype', 'idtype', idtype, "idchange")</script></td>
  <td><script language="JavaScript">doc(Local_);doc(' ');doc(ID_)</script></td> 
  <td><input type="text" id=lid name="lid" size=15 maxlength=60 ></td>
  <td><script language="JavaScript">doc(Remote_);doc(' ');doc(ID_)</script></td>  
  <td><input type="text" id=rid name="rid" size=15 maxlength=60 ></td>
 </tr> 
</table>

<table cellpadding=1 cellspacing=2 border=0 width=680px id=hiddensubnet style="display:none"> 
</table>

<table cellpadding=1 cellspacing=2 border=0 width=680px id=securitylevel>
 <tr class=r0 >
  <td colspan=4><script language="JavaScript">doc(IPsec_Sec_Set_)</script></td></tr>  
 <tr align="left">   
  <td width = 360px colspan=4>
  <input type="radio" id=seclevel name="seclevel" onClick=Advance(0) value=1 > <script language="JavaScript">doc(SIMPLE_)</script>
  <input type="radio" id=secleve2 name="seclevel" onClick=Advance(0) value=2 > <script language="JavaScript">doc(STANDARD_)</script>
  <input type="radio" id=secleve3 name="seclevel" onClick=Advance(0) value=3 > <script language="JavaScript">doc(STRONG_)</script> </td>
  <td style="display:none"><input type="radio" id=secleve4 name="seclevel" value=0 ></td>
</table>

<table cellpadding=1 cellspacing=2 border=0 width=680px>
 <tr class=r0 >
  <td colspan=7 id=setmodechg name=setmodechg><script language="JavaScript">doc(IPsec_Phase_1_)</script></td></tr>  
 <tr align="left">   
  <td width=129px id=exchg0><script language="JavaScript">doc(IPsec_IKE_MODE_)</script></td>
  <td id=exchg1><script language="JavaScript">iGenSel2('exchg', 'exchg', exchgtype0)</script></td></tr>
</table>
<table cellpadding=1 cellspacing=2 border=0 width=680px>
 <tr align="left">   
  <td width=129px><script language="JavaScript">doc(IPsec_Auth_Mode_)</script></td>
  <td width=135px><script language="JavaScript">fnGenSelect(selauthtyp, '')</script></td>
  <td id=pskey colspan=2><input type="text" id=pskey name="psk" size=20 maxlength=64 ></td>
  <td width=60px id=certificate0 ><script language="JavaScript">doc(Local_)</script></td>
  <td id=certificate1 ><script language="JavaScript">iGenSel2('lselpem', 'x509peml', selpem0)</script></td>
  <td width=60px id=certificate2 ><script language="JavaScript">doc(Remote_)</script></td>
  <td id=certificate3 ><script language="JavaScript">iGenSel2('rselpem', 'x509pemr', selpem1)</script></td></tr> 
</table>
<table cellpadding=1 cellspacing=2 border=0 width=680px>  
 <tr align="left" id=p1secdispay>  
  <td width=129px><script language="JavaScript">doc(IPsec_ENCRP_ALG_)</script></td>  
  <td width=135px><script language="JavaScript">iGenSel3('p1enc', 'p1enc', enctyp0, '')</script></td>
  <td width=150px><script language="JavaScript">doc(IPsec_Hash_ALG_)</script></td>
  <td><script language="JavaScript">iGenSel3('p1ah', 'p1ah', ahtyp0, 'p1ahchange')</script></td></tr>
 <tr align="left">   
  <td width=129px id=p1dhdispay0><script language="JavaScript">doc(IPsec_DHGP_)</script></td>
  <td width=135px id=p1dhdispay1><script language="JavaScript">iGenSel2('p1dh', 'p1dh', dhtyp0)</script></td></tr>  
 <tr display='none' align="left" id=advance0>  
  <td width=129px><script language="JavaScript">doc(IPsec_Nego_Times_)</script></td>  
  <td width=135px><input type="text" id=nego name="negotimes" size=5 maxlength=5><script language="JavaScript">doc('(');doc(IPsec_Nego_Times_0_);doc(')');</script></td>
  <td width=150px><script language="JavaScript">doc(IPsec_IKE_Life_Time_)</script></td>
  <td><input type="text" id=iketime name="ikelifetime" size=5 maxlength=5 ><script language="JavaScript">doc(' ');doc(hour_)</script></td></tr>  
 <tr  align="left" id=advance1 display='none'>
  <td><script language="JavaScript">doc(IPsec_Rekey_Expire_Time_)</script></td>  
  <td><input type="text" id=rekeytime name="rekeyexpiretime" size=5 maxlength=3 ><script language="JavaScript">doc(' ');doc(min_)</script></td>
  <td><script language="JavaScript">doc(IPsec_Rekey_Fuzz_Percent_)</script></td>
  <td><input type="text" id=rekeyfuzz name="rekeyfuzz" size=5 maxlength=3 ><script language="JavaScript">doc(' ');doc('%');</script></td></tr>
</table>

<table cellpadding=1 cellspacing=2 border=0 width=680px id=phase2table>
 <tr class=r0 >
  <td colspan=5><script language="JavaScript">doc(IPsec_Phase_2_)</script></td></tr>  
 <tr align="left" id=advance2>   
  <td width=129px><script language="JavaScript">doc(IPsec_SA_LIFE_TIME_)</script></td>  
  <td td width=135px><input type="text" id=satime name="salifetime" size=5 maxlength=5><script language="JavaScript">doc(' ');doc(min_)</script></td>
  <td width=150px><script language="JavaScript">doc(IPsec_SA_PFS_)</script></td>
  <td><input type="checkbox" id=pfs name="pfs">&nbsp<script language="JavaScript">iGenSel2('p2dh', 'p2dh', dhtyp0)</script></td></tr> 
 <tr align="left">  
  <td><script language="JavaScript">doc(IPsec_ENCRP_ALG_)</script></td>  
  <td><script language="JavaScript">iGenSel3('p2enc', 'p2enc', enctyp1 , 'p2ahchange')</script></td>
  <td><script language="JavaScript">doc(IPsec_Hash_ALG_)</script></td>
  <td><script language="JavaScript">iGenSel2('p2ah', 'p2ah', ahtyp0)</script></td></tr> 
</table>
<table cellpadding=1 cellspacing=2 border=0 width=680px id=advance3>
 <tr class=r0 >
  <td colspan=5><script language="JavaScript">doc(IPsec_DPD_)</script></td></tr>  
 <tr align="left"> 
  <td width=40px><script language="JavaScript">doc(Action_)</script></td>  
  <td width=100px><script language="JavaScript">iGenSel2('dpdact', 'dpdact', dpdtype0)</script></td>	
  <td width=90px><script language="JavaScript">doc(IPsec_Retry_Interval_)</script></td>
  <td width=140px><input type="text" id=dpddelay name="dpddelay" size=5 maxlength=5><script language="JavaScript">doc(' ');doc(seconds_)</script></td>
  <td width=130px><script language="JavaScript">doc(IPsec_Confidence_Interval_)</script></td>  
  <td><input type="text" id=dpdtime name="dpdtimeout" size=5 maxlength=5><script language="JavaScript">doc(' ');doc(seconds_)</script></td></tr> 
</table>
</DIV>
<table>

<tr><td>
<p><table align=left>
 <tr>
  <td width=400><script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script>
  <script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
  <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=300><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
  <td width=15></td>
  <!--td><script language="JavaScript">fnbnSID(adv, 'onClick=Advance(this.form)', 'btnAdv')</script></td>
  <td width=15></td--></tr>
</table></p>
</td></tr>

<tr><td>
<table cellpadding=1 cellspacing=2>
<tr class=r0>
 <td width=140px><script language="JavaScript">doc(IPsec_Connections_)</script></td>
 <td id = "totalcercnt" colspan=5></td></tr>
</table>
</td></tr>

<table align=left>
<tr></tr>
</table>

<tr><td>
<table cellpadding=1 cellspacing=2 id="show_available_table">
<tr></tr>
 <tr >
  <th width= 10%><script language="JavaScript">doc(Enable_)</script></td>
  <th width= 15%><script language="JavaScript">doc(Name_)</script></td>
  <th width= 25%><script language="JavaScript">doc(IPsec_Remote_GW_)</script></td>
  <th width= 25%><script language="JavaScript">doc(Local_)</script>&nbsp
                 <script language="JavaScript">doc(Subnet_)</script></td> 
  <th width= 25%><script language="JavaScript">doc(Remote_)</script>&nbsp
                 <script language="JavaScript">doc(Subnet_)</script></td></tr>
</table>
</td></tr>

</table> 
</fieldset>
</form>
</body></html>
