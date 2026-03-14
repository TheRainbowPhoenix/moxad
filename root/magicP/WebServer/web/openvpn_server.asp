<html>
<head>

<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script>
checkCookie();
debug = 0;   
if (debug) {
	var SRV_OPENVPN_SERVER_type;
    var SRV_OPENVPN_SERVER=[
     {enable:'1', serverId:'1', serverPort:'1194', devType:'1',protoType:'1', compLzo:'1', encCipher:'1', tlsAuth:'1',    duplicateCN:'0',   routeNetwork:'10.1.1.1', routeNetmask:'255.255.255.0', brGwIpAddr:'192.168.200.253', brNetmask:'255.255.255.0', 
    brAddrStart:'192.168.200.1', brAddrEnd:'192.168.200.100', clientToClient:'0', pushDefGw:'0'},
        
     {enable:'0', serverId:'2', serverPort:'1194', devType:'0',protoType:'1', compLzo:'1', encCipher:'2', tlsAuth:'0', duplicateCN:'0', routeNetwork:'20.1.1.1', routeNetmask:'255.255.255.0', brGwIpAddr:'192.168.100.253', brNetmask:'255.255.255.0', 
    brAddrStart:'192.168.100.1', brAddrEnd:'192.168.100.100', clientToClient:'0', pushDefGw:'1'}
    ];

}
else {

    <%net_Web_show_value('SRV_OPENVPN_SERVER');%>

    var cer_mgmt = [
		<%net_webCERMgmt();%>		
	];

	var ca_cer = [
		<%net_webCACERUP();%>
	];

    var ifs_op = [ <% net_Web_openvpnGetLANIfs(); %>  ];
}
    
var ovpnSettingMode = 0;
var ovpnDevType = SRV_OPENVPN_SERVER[0].devType;

var serverId0 = [
        { value:1, text:"1" },    { value:2, text:"2" }
];    
    
var devTyp0 = [
        { value:0, text:"TAP(Bridge)" },    { value:1, text:"TUN(Router)" }
];

var protoTyp0 = [
        { value:0, text:"UDP" },    { value:1, text:"TCP" }
        
];
    
var encCipherType0 = [
        { value:0, text:"BlowFish CBC" },   { value:1, text:"AES-128 CBC" }, 
        { value:2, text:"AES-256 CBC" }, 	{value:3, text: "AES-192 CBC"},
        { value:4, text:"DES CBC"},	{ value:5, text: "DES-EDE3 CBC"}
];

var authHashType0 = [
		{ value:0, text:"SHA-1" }, { value:1, text:"MD5" }, { value:2, text:"SHA-256" }
];
    
var userAuthType0 = [
        { value:1, text:"Password" }
];
    
var CaCertType0 = [
        
];

var CertType0 = [
        
];

    
    
var selServerId = { type:'select', id:'serverId', name:'serverId', size:1, style:'width:125px', onChange:'ovpn_settingServerIdChange(this.value)', option:serverId0 };
    
var seldevTyp0 = { type:'select', id:'devType', name:'devType', size:1, style:'width:125px', onChange:'ovpn_settingDevTypeChange(this.value)', option:devTyp0 };
    
var selprotoTyp0 = { type:'select', id:'protoType', name:'protoType', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:protoTyp0 };    


var selEncCipherType0 = { type:'select', id:'encCipher', name:'encCipher', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:encCipherType0 }; 
var selAuthHashType0 = { type:'select', id:'authHash', name:'authHash', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:authHashType0 }; 
    
var selUserAuthType = { type:'select', id:'userAuth', name:'userAuth', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:userAuthType0 };  
var selCaCert = { type:'select', id:'selca', name:'selca', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:CaCertType0 };  
var selCert = { type:'select', id:'selpem', name:'selpem', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:CertType0 };  
var ifs_selstate = {type:'select', id:'brIfIndex', name:'brIfIndex', size:1, style:'width:125px', option:ifs_op};

var myForm;
var LeditEntryIdx = 1;
    
function fnChgLType(val)
{

    // TODO
    
    return;
}

function ovpn_settingServerIdChange(sid)
{
        
    // TODO
    
    return;
}    
    

function ovpn_settingDevTypeChange(devType)
{
        
    if(devTyp0[devType].value == 0) { // TAP
        document.getElementsByName('setDevTypeTun')[0].style.display = 'none';
        document.getElementsByName('setDevTypeTun1')[0].style.display = 'none'; 
        document.getElementsByName('setDevTypeTap0')[0].style.display = '';
        document.getElementsByName('setDevTypeTap1')[0].style.display = '';
        document.getElementsByName('setDevTypeTap2')[0].style.display = ''; 
        document.getElementsByName('setDevTypeTap3')[0].style.display = '';  
        document.getElementsByName('duplicateCN')[0].disabled = false;
        document.getElementsByName('duplicateCN')[1].disabled = false;
    }
    else {
        document.getElementsByName('setDevTypeTun')[0].style.display = '';
        document.getElementsByName('setDevTypeTun1')[0].style.display = ''; 
        document.getElementsByName('setDevTypeTap0')[0].style.display = 'none';
        document.getElementsByName('setDevTypeTap1')[0].style.display = 'none';
        document.getElementsByName('setDevTypeTap2')[0].style.display = 'none'; 
        document.getElementsByName('setDevTypeTap3')[0].style.display = 'none';
        document.getElementsByName('duplicateCN')[0].disabled = true;
        document.getElementsByName('duplicateCN')[1].disabled = true;
        document.getElementsByName('duplicateCN')[0].checked = true;
    }
    
    return;
}
    
function ovpn_settingModeChange()
{
    var inputElements = document.getElementsByName('advSettingBox');
    var i;
    
    if(document.getElementsByName('advSettingBox')[0].checked) {
        //alert("Mode click" );
        ovpnSettingMode = 1; // Advanced
    }
    else {
        ovpnSettingMode = 0; // Basic
    }

    for(i = 0; i < document.getElementsByName('setmodechg').length; i++){
		  document.getElementsByName('setmodechg')[i].style.display=(!ovpnSettingMode)?'none':'';
	}    
    
    return;   
}

function fnChgDhcpProxyMode(dhcpProxyMode)
{
    if(dhcpProxyMode==1) {
        document.getElementById("brGwIpAddr").disabled = true;
        document.getElementById("brNetmask").disabled = true;
        document.getElementById("brAddrStart").disabled = true;
        document.getElementById("brAddrEnd").disabled = true;

        document.getElementById("brGwIpAddr").value = "0.0.0.0";
        document.getElementById("brNetmask").value = "0.0.0.0";
        document.getElementById("brAddrStart").value = "0.0.0.0";
        document.getElementById("brAddrEnd").value = "0.0.0.0";
        
    }
    else {
        document.getElementById("brGwIpAddr").disabled = false;
        document.getElementById("brNetmask").disabled = false;
        document.getElementById("brAddrStart").disabled = false;
        document.getElementById("brAddrEnd").disabled = false;
    }
    
    return;
}

function EditRow1(row) 
{
	var rowidx = row.rowIndex;
    
    fnLoadForm(myForm, SRV_OPENVPN_SERVER[rowidx-1], SRV_OPENVPN_SERVER_type);
    ChgColor('tri', SRV_OPENVPN_SERVER.length, rowidx-1);
    LeditEntryIdx = rowidx;	
    myForm.serverId.value = rowidx;
} 
    
function addRow(i)
{
    var valueIdx = 0;
    var networkStr;
    
	table = document.getElementById('show_openvpn_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);

	cell = document.createElement("td");
	cell.width = '50px';

	if(SRV_OPENVPN_SERVER[i].enable==1)
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	else
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.width = '50px';
	cell.innerHTML = i+1;
	row.appendChild(cell);
    
    cell = document.createElement("td");
	cell.width = '110px';
    valueIdx = SRV_OPENVPN_SERVER[i].devType;
	cell.innerHTML = devTyp0[valueIdx].text;
	row.appendChild(cell);
    
    cell = document.createElement("td");
	cell.width = '110px';
    valueIdx = SRV_OPENVPN_SERVER[i].protoType;
	cell.innerHTML = protoTyp0[valueIdx].text;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '50px';	
	cell.innerHTML = SRV_OPENVPN_SERVER[i].serverPort;
	row.appendChild(cell);
    
    cell = document.createElement("td");
	cell.width = '140px';	
	valueIdx = SRV_OPENVPN_SERVER[i].encCipher;
    cell.innerHTML = encCipherType0[valueIdx].text;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '80px';	
	valueIdx = SRV_OPENVPN_SERVER[i].authHash;
    cell.innerHTML = authHashType0[valueIdx].text;
	row.appendChild(cell);
	
	cell = document.createElement("td");
	cell.width = '80px';	
	if(SRV_OPENVPN_SERVER[i].compLzo==1) {
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	}
	else {
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	}
	row.appendChild(cell);
	
    /* cell = document.createElement("td");	
	cell.width = '155px';
    networkStr = SRV_OPENVPN_SERVER[i].routeNetwork+"/"+SRV_OPENVPN_SERVER[i].routeNetmask;
	cell.innerHTML = networkStr;
	row.appendChild(cell);
	*/
	
	row.style.Color = "black";
	var j=i+1;
	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this)};
	row.style.cursor=ptrcursor;
	row.align="center";
} 

function find_pem_key(pem_name)
{
	var i;
	for(i=0; i<cer_mgmt.length; i++){
		if(pem_name == cer_mgmt[i].cer_name){
			return cer_mgmt[i].key_name;
		}
	}
	return "";
}


function Modify(form)
{	
	var table;
    var rowIdx = LeditEntryIdx;
    var element;
    
    // TODO: add value checking here
    if(!isPort(form.serverPort, "Port")) {
        return;
    }
    
    if(form.devType.value == 1) { // TUN
        if(!(IpAddrIsOK_allow0and255(form.routeNetwork, "Network")) || !(NetMaskIsOK(form.routeNetmask, "Netmask"))) {
		  return;
        }

        if(GetRadioValue(form.clientToClient)==1 && GetRadioValue(form.duplicateCN)==1) {
        	alert("Duplicate user name can not be enabled when Client-to-Client is enabled!");
			return;
        }
    }
    else { // TAP
        if(GetRadioValue(form.dhcpProxy)==0) { // DHCP Proxy disabled
            if(!(IpAddrIsOK(form.brGwIpAddr, "Gateway IP"))) {
                return;
            }
            if(!(NetMaskIsOK(form.brNetmask, "Netmask"))) {
                return;
            } 
            if(!(IpAddrIsOK(form.brAddrStart, "IP Pool Start")) || !(IpAddrIsOK(form.brAddrEnd, "IP Pool End"))) {
                return;
            } 
 
            if(!(SerIpRangeCheck(form.brAddrStart.value, form.brAddrEnd.value, 256)))	{
                return;
            }
        }
    }

    // Form value assignment
	if(form.enable.checked==true) {
        SRV_OPENVPN_SERVER[rowIdx-1].enable=1;
    }
	else {        
		SRV_OPENVPN_SERVER[rowIdx-1].enable=0;
    }

	SRV_OPENVPN_SERVER[rowIdx-1].serverPort = form.serverPort.value;
	SRV_OPENVPN_SERVER[rowIdx-1].devType = form.devType.value;
    SRV_OPENVPN_SERVER[rowIdx-1].protoType = form.protoType.value;
    element = document.getElementsByName('compLzo');
    SRV_OPENVPN_SERVER[rowIdx-1].compLzo = GetRadioValue(element);
    element = document.getElementsByName('keepalive');
    SRV_OPENVPN_SERVER[rowIdx-1].keepalive = GetRadioValue(element);
   	SRV_OPENVPN_SERVER[rowIdx-1].encCipher = form.encCipher.value;
   	SRV_OPENVPN_SERVER[rowIdx-1].authHash = form.authHash.value;
   	
	SRV_OPENVPN_SERVER[rowIdx-1].userAuth = form.userAuth.value;
	SRV_OPENVPN_SERVER[rowIdx-1].selca = form.selca.value;
	SRV_OPENVPN_SERVER[rowIdx-1].selpem = form.selpem.value;
	SRV_OPENVPN_SERVER[rowIdx-1].pemkey = find_pem_key(form.selpem.value);
	
	element = document.getElementsByName('clientToClient');
	SRV_OPENVPN_SERVER[rowIdx-1].clientToClient = GetRadioValue(element);
	element = document.getElementsByName('duplicateCN');
	SRV_OPENVPN_SERVER[rowIdx-1].duplicateCN = GetRadioValue(element);
	element = document.getElementsByName('pushDefGw');
	SRV_OPENVPN_SERVER[rowIdx-1].pushDefGw = GetRadioValue(element);
	
    SRV_OPENVPN_SERVER[rowIdx-1].routeNetwork = form.routeNetwork.value;
    SRV_OPENVPN_SERVER[rowIdx-1].routeNetmask = form.routeNetmask.value;
    SRV_OPENVPN_SERVER[rowIdx-1].localNetwork = form.localNetwork.value;
    SRV_OPENVPN_SERVER[rowIdx-1].localNetmask = form.localNetmask.value;

	//alert("brIfname =" + fnGetSelText(form.brIfIndex.value, ifs_op));
	SRV_OPENVPN_SERVER[rowIdx-1].brIfname = fnGetSelText(form.brIfIndex.value, ifs_op);
    SRV_OPENVPN_SERVER[rowIdx-1].brGwIpAddr = form.brGwIpAddr.value;
    SRV_OPENVPN_SERVER[rowIdx-1].brNetmask = form.brNetmask.value;
    SRV_OPENVPN_SERVER[rowIdx-1].brAddrStart = form.brAddrStart.value;
    SRV_OPENVPN_SERVER[rowIdx-1].brAddrEnd = form.brAddrEnd.value;
    
	table = document.getElementById("show_openvpn_table");
	rows = table.getElementsByTagName("tr");

    // Delete added the table members
	if(rows.length > 0) {
		for(i=rows.length-1; i > 0; i--) {
			table.deleteRow(i);
		}
	}
	// Re-join the array elements to the table
	for(i=0; i < SRV_OPENVPN_SERVER.length; i++) {
		addRow(i);		
	}
    
    //TotalPolicy()
	ChgColor('tri', SRV_OPENVPN_SERVER.length, rowIdx-1);
    
}  

function Activate(form)
{
	var i, j;

	form.SRV_OPENVPN_SERVER_tmp.value = "";

	for(i=0; i<SRV_OPENVPN_SERVER.length; i++){
		for(j in SRV_OPENVPN_SERVER[i]){
			form.SRV_OPENVPN_SERVER_tmp.value = form.SRV_OPENVPN_SERVER_tmp.value + SRV_OPENVPN_SERVER[i][j] + "+";
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_OPENVPN_SERVER";
	form.submit();	
}
    
function ShowList1(name) 
{
	table = document.getElementById("show_openvpn_table");

	rows = table.getElementsByTagName("tr");

	//re-join the array elements to the table
	for(i=0; i<SRV_OPENVPN_SERVER.length; i++)
	{
		addRow(i);		
	}
	
	ChgColor('tri', SRV_OPENVPN_SERVER.length, 0);		
}   

function ovpnSetBrIfs2Index(form)
{
	var i;
	
	for(i=0; i<ifs_op.length; i++){		
		if(ifs_op[i].text == SRV_OPENVPN_SERVER[0].brIfname) {
			//alert("index =" + i +"server brIf=" + SRV_OPENVPN_SERVER[0].brIfname);
			form.brIfIndex.options[i].selected = true;
			
		}
	}
	
	return;
}
    
function ceroptionadd(){
	var key_tmp, i;

	key_tmp = document.getElementById('selca');
	key_tmp.options.length=0; 
	
	for(i = 0; i < ca_cer.length; i++){
		key_tmp.options.add(new Option(ca_cer[i].ca_name, ca_cer[i].ca_name)); 
	}

	key_tmp = document.getElementById('selpem');
	key_tmp.options.length=0; 

	for(i = 0; i < cer_mgmt.length; i++){
		if(cer_mgmt[i].key_name==''){
			continue;
		}
		key_tmp.options.add(new Option(cer_mgmt[i].cer_name, cer_mgmt[i].cer_name)); 
	}
}


    
function fnInit()
{  
    myForm = document.getElementById('myForm');
    ceroptionadd();

    fnLoadForm(myForm, SRV_OPENVPN_SERVER[0], SRV_OPENVPN_SERVER_type);
    
    ovpnSetBrIfs2Index(myForm);
    ovpn_settingDevTypeChange(ovpnDevType);

    if(document.getElementById("brGwIpAddr").value == '0.0.0.0'  || (document.getElementById("brNetmask").value == '0.0.0.0') ) { // FIXME
        myForm.dhcpProxy[1].checked = true;
        fnChgDhcpProxyMode(1);
    }
    else {
        myForm.dhcpProxy[0].checked = true;
        fnChgDhcpProxyMode(0);
    }

    myForm.serverId.value = LeditEntryIdx;
        
    return;   
}
</script>
</head>

<body onLoad=fnInit()>
<h1>OpenVPN Server Setting</h1>
<fieldset style=width:"900px">
<form id=myForm name=myForm method="POST">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="SRV_OPENVPN_SERVER_tmp" id="SRV_OPENVPN_SERVER_tmp" value="" >
<DIV style="width:900px;">
<table cellpadding=1 cellspacing=1>
 <tr align="left">
  <td width=200px>Enable</td>
  <td><input type="checkbox" id="enable" value=1></td>
 </tr>
 <tr align="left">
  <td>Server ID</td>
  <td><input type="text" id="serverId" name="serverId" size=5 maxlength=3 readonly> </td>  
 </tr> 
 <tr align="left">
  <td>Interface Type</td>
  <td><script language="JavaScript">fnGenSelect(seldevTyp0, '')</script>  </td>
 </tr>
 <tr align="left" id="setDevTypeTun" name="setDevTypeTun"> 
  <td>Network</td>
  <td nowrap><input type="text" id="routeNetwork" size="15" maxlength="15"></td> 
  <td>Netmask</td>
  <td nowrap><input type="text" id="routeNetmask" size="15" maxlength="15" disabled></td> 
 </tr>
 <tr align="left" id="setDevTypeTun1" name="setDevTypeTun1"> 
  <td>Push Network</td>
  <td nowrap><input type="text" id="localNetwork" size="15" maxlength="15"></td> 
  <td>Netmask</td>
  <td nowrap><input type="text" id="localNetmask" size="15" maxlength="15"></td> 
 </tr>
 
 <tr align="left" id="setDevTypeTap0" name="setDevTypeTap0"> 
  <td>Bridge with LAN</td>
  <td nowrap><script language="JavaScript">fnGenSelect(ifs_selstate, '')</script></td>  
 </tr>
 <tr align="left" id="setDevTypeTap1" name="setDevTypeTap1">
  <td>DHCP Proxy</td>
  <td nowrap><input type="radio" id="dhcpProxy" name="dhcpProxy" value=0 onClick=fnChgDhcpProxyMode(0)> <script language="JavaScript">doc(Disable_)  </script>
  <input type="radio" id="dhcpProxy" name="dhcpProxy" value=1 onClick=fnChgDhcpProxyMode(1)> <script language="JavaScript">doc(Enable_)</script>
  </td>   
 </tr>
 <tr align="left" id="setDevTypeTap2" name="setDevTypeTap2">
  <td>External Gateway IP</td>
  <td nowrap><input type="text" id="brGwIpAddr" size="15" maxlength="15"></td>
  <td>Netmask</td>     
  <td nowrap><input type="text" id="brNetmask" size="15" maxlength="15"></td>
 </tr>
 <tr align="left" id="setDevTypeTap3" name="setDevTypeTap3"> 
  <td>IP Pool Range</td>
  <td nowrap><input type="text" id="brAddrStart" size="15" maxlength="15"></td> 
  <td>~</td>
  <td nowrap><input type="text" id="brAddrEnd" size="15" maxlength="15"></td>    
 </tr>
 
    
 <tr align="left">
  <td>Protocol</td>
  <td><script language="JavaScript">fnGenSelect(selprotoTyp0, '')</script>  </td>
 </tr> 
 <tr align="left">
  <td>Port</td>
  <td><input type="text" id="serverPort" size=15 maxlength=15></td>
 </tr> 
  
 <tr align="left"> 
  <td>Encryption Algorithm</td>
  <td><script language="JavaScript">fnGenSelect(selEncCipherType0, '')</script>  </td>
 </tr>
 <tr align="left"> 
  <td>Hash Algorithm</td>
  <td><script language="JavaScript">fnGenSelect(selAuthHashType0, '')</script>  </td>
 </tr>
 <tr align="left">
  <td>LZO Compression</td>
  <td nowrap>
  <input type="radio" name="compLzo" value=0> <script language="JavaScript">doc(Disable_)</script>
  <input type="radio" name="compLzo" value=1> <script language="JavaScript">doc(Enable_)</script>
  </td>
 </tr>

 <tr align="left"> 
  <td><script language="JavaScript">doc(CA_);doc(' ');doc(CER_);</script></td>
  <td><script language="JavaScript">fnGenSelect(selCaCert, '')</script>  </td>
 </tr>

 <tr align="left"> 
  <td><script language="JavaScript">doc(CER_);</script></td>
  <td><script language="JavaScript">fnGenSelect(selCert, '')</script>  </td>
 </tr>

 <tr align="left"> 
  <td>User Authentication</td>
  <td><script language="JavaScript">fnGenSelect(selUserAuthType, '')</script>  </td>
 </tr>
   
 <tr id="setmodechg" name="setmodechg">
  <td>Keepalive</td>
  <td nowrap>
   <input type="radio" name="keepalive" value=0> <script language="JavaScript">doc(Disable_)</script>
   <input type="radio" name="keepalive" value=1> <script language="JavaScript">doc(Enable_)</script>
  </td>  
  <td id=TDden></td>
  </td></tr>
 <tr id="setmodechg" name="setmodechg">
  <td>Redirect Default Gateway</td>
  <td nowrap>
  <input type="radio" id=pushDefGw name="pushDefGw" value=0> <script language="JavaScript">doc(Disable_)</script>
  <input type="radio" id=pushDefGw name="pushDefGw" value=1> <script language="JavaScript">doc(Enable_)</script>
  </td>
  <td id=TDden></td>
  </td></tr>
 <tr id="setmodechg" name="setmodechg">
  <td>Allow Client to Client</td>
  <td nowrap>
  <input type="radio" name="clientToClient" value=0> <script language="JavaScript">doc(Disable_)</script>
  <input type="radio" name="clientToClient" value=1> <script language="JavaScript">doc(Enable_)</script> </td>
  <td id=TDden></td>
  </td></tr> 
 <tr id="setmodechg" name="setmodechg">
  <td>Allow Duplicate User Name</td>
  <td nowrap>
  <input type="radio" id=duplicateCN name="duplicateCN" value=0> <script language="JavaScript">doc(Disable_)</script>
  <input type="radio" id=duplicateCN name="duplicateCN" value=1> <script language="JavaScript">doc(Enable_)</script> </td>
  <td id=TDden></td>
  </td></tr>  
</table>

<p><table align=left border=0>
 <tr>
  <td width=400px><script>fnbnBID(modb, 'onClick=Modify(this.form)', 'btnM')</script></td>
  <td width=300px><script>fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
     <td width="100px"></td></tr>
</table></p>

<table align=left border=0>
<tr style="height:50px"></tr>
</table>
</DIV>
</form>

<table cellpadding=1 cellspacing=2 width="800px">
 <tr class=r0>
  <td width=200px>OpenVPN Server</td>
  <td id="totalpolicy" colspan=5></td></tr>
</table> 

<table cellpadding=1 cellspacing=2 width="660px" id="show_openvpn_table">   
 <tr align="center">
  <th width=50px  class="s0"><script>doc(Enable_)</script></th>
  <th width=50px class="s0">Server ID</th>
  <th width=110px class="s0">Interface Type</th>
  <th width=110px class="s0">Protocol</th> 
  <th width=40px class="s0">Port</th>
  <th width=140px class="s0">Encryption</th>
  <th width=80px class="s0">Hash</th>
  <th width=80px  class="s0">LZO Compression</th>  
 </tr>

<script language="JavaScript">ShowList1('tri')</script>
</table>

</fieldset>
</body></html>
