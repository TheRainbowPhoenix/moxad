<html>
<head>

{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script>
checkCookie();
debug = 0;   
if (debug) {
    var SRV_OPENVPN_CLIENT_type;	
    var SRV_OPENVPN_CLIENT=[
     {enable:'1', clientId:'1', serverIP:'180.1.1.1', serverPort:'1194', devType:'0',protoType:'0', compLzo:'1', encCipher:'1', tlsAuth:'0', clientAuth:'0', username:'aaa1', userpasswd:'1234'},
     {enable:'0', clientId:'2', serverIP:'180.1.2.0', serverPort:'1194', devType:'1',protoType:'1', compLzo:'1', encCipher:'2', tlsAuth:'1', clientAuth:'1', username:'bbb1', userpasswd:'1234'}];

}
else {

	{{ net_Web_show_value('SRV_OPENVPN_CLIENT') | safe }}

	var cer_mgmt = [
		{{ net_webCERMgmt() | safe }}		
	];

	var ca_cer = [
		{{ net_webCACERUP() | safe }}
	];
	var ifs_op = [ {{ net_Web_openvpnGetLANIfs() | safe }}  ];
}
    
var clientId0 = [
        { value:1, text:"1" },    { value:2, text:"2" }
]; 
    
var devTyp0 = [
        { value:0, text:"TAP" },    { value:1, text:"TUN" }
        
];
var seldevTyp0 = { type:'select', id:'devType', name:'devType', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:devTyp0 };

var protoTyp0 = [
        { value:0, text:"UDP" },    { value:1, text:"TCP" }
        
];
var selprotoTyp0 = { type:'select', id:'protoType', name:'protoType', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:protoTyp0 };    

var encCipherTyp0 = [
        { value:0, text:"BlowFish CBC" },    { value:1, text:"AES-128 CBC" }, 
        { value:2, text:"AES-256 CBC" }, 	{value:3, text: "AES-192 CBC"},
        { value:4, text:"DES CBC"},	{ value:5, text: "DES-EDE3 CBC"}        
];

var authHashType0 = [
		{ value:0, text:"SHA-1" }, { value:1, text:"MD5" }, { value:2, text:"SHA-256" }
];
    
var clientAuthTyp0 = [
        { value:0, text:"Certificate" },    { value:1, text:"Password" } 
        
];

var CaCertType0 = [
        
];

var CertType0 = [
        
];

var selClientId = { type:'select', id:'clientId', name:'clientId', size:1, style:'width:125px', onChange:'ovpn_settingClientIdChange(this.value)', option:clientId0 };
    
var selencCipherTyp0 = { type:'select', id:'encCipher', name:'encCipher', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:encCipherTyp0 };  
var selAuthHashType0 = { type:'select', id:'authHash', name:'authHash', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:authHashType0 };     
var selClientAuthTyp0 = { type:'select', id:'clientAuth', name:'clientAuth', size:1, style:'width:125px', onChange:'', option:clientAuthTyp0 };  
var selCaCert = { type:'select', id:'selca', name:'selca', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:CaCertType0 };  
var selCert = { type:'select', id:'selpem', name:'selpem', size:1, style:'width:125px', onChange:'fnChgLType(this.value)', option:CertType0 };  

var ifs_selstate = {type:'select', id:'brIfIndex', name:'brIfIndex', size:1, style:'width:125px', option:ifs_op};

var LeditEntryIdx = 1;
var myForm;
    
function fnChgLType(val)
{

    // TODO
    
    return;
}

function fnChgLMode(val)
{

    // TODO
    
    return;
}
 
    
function ovpn_settingAuthTypeChange(authType)
{
        
    /* 
    if(clientAuthTyp0[authType].value == 0) { // Certificate
        document.getElementsByName('setAuthPassword')[0].style.display = 'none'; 
        document.getElementsByName('setAuthCert')[0].style.display = ''; 
    }
    else {
        document.getElementsByName('setAuthPassword')[0].style.display = '';
        document.getElementsByName('setAuthCert')[0].style.display = 'none'; 
    } 
    */
    
    return;
}
 
function ovpn_settingClientIdChange(cid)
{
        
    // TODO
    
    return;
}
    
function EditRow1(row) 
{
	var rowidx = row.rowIndex;
    
    fnLoadForm(myForm, SRV_OPENVPN_CLIENT[rowidx-1], SRV_OPENVPN_CLIENT_type);
    ChgColor('tri', SRV_OPENVPN_CLIENT.length, rowidx-1);
    ovpnSetBrIfs2Index(myForm, rowidx-1);
    LeditEntryIdx = rowidx;
    myForm.clientId.value = rowidx;
    
}    

function addRow(i)
{
    var valueIdx = 0;
    
	table = document.getElementById('show_openvpn_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);

	cell = document.createElement("td");
	cell.width = '50px';

	if(SRV_OPENVPN_CLIENT[i].enable==1)
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
    valueIdx = SRV_OPENVPN_CLIENT[i].devType;
	cell.innerHTML = devTyp0[valueIdx].text;
	row.appendChild(cell);

	cell = document.createElement("td");
	cell.width = '150px';	
	cell.innerHTML = SRV_OPENVPN_CLIENT[i].serverIP+"/"+SRV_OPENVPN_CLIENT[i].serverPort;
	row.appendChild(cell);
	
    cell = document.createElement("td");
	cell.width = '110px';
    valueIdx = SRV_OPENVPN_CLIENT[i].protoType;
	cell.innerHTML = protoTyp0[valueIdx].text;
	row.appendChild(cell);
    
    cell = document.createElement("td");
	cell.width = '150px';
    valueIdx = SRV_OPENVPN_CLIENT[i].encCipher;
    cell.innerHTML = encCipherTyp0[valueIdx].text;
	row.appendChild(cell);
    
	cell = document.createElement("td");
	cell.width = '50px';	
	if(SRV_OPENVPN_CLIENT[i].compLzo==1) {
		cell.innerHTML = "<IMG src=" + 'images/enable_3.gif'+ ">";
	}
	else {
		cell.innerHTML = "<IMG src=" + 'images/disable_3.gif'+ ">";
	}
	row.appendChild(cell);
    
    cell = document.createElement("td");
	cell.width = '100px';
    valueIdx = SRV_OPENVPN_CLIENT[i].clientAuth;	
	cell.innerHTML = clientAuthTyp0[valueIdx].text;
	row.appendChild(cell);

	row.style.Color = "black";

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
    if(!IpAddrIsOK(myForm.serverIP, "Server IP")) {
        return;
    }
    
    if(!isPort(myForm.serverPort, "Server Port")) {
        return;
    }

    // Form value assignment
	if(myForm.enable.checked==true) {
        SRV_OPENVPN_CLIENT[rowIdx-1].enable=1;
    }
	else {        
		SRV_OPENVPN_CLIENT[rowIdx-1].enable=0;
    }

	SRV_OPENVPN_CLIENT[rowIdx-1].serverIP = myForm.serverIP.value;
	SRV_OPENVPN_CLIENT[rowIdx-1].serverPort = myForm.serverPort.value;
	SRV_OPENVPN_CLIENT[rowIdx-1].devType = myForm.devType.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].protoType = myForm.protoType.value;
    element = document.getElementsByName('compLzo');
    SRV_OPENVPN_CLIENT[rowIdx-1].compLzo = GetRadioValue(element);
    SRV_OPENVPN_CLIENT[rowIdx-1].encCipher = myForm.encCipher.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].authHash = myForm.authHash.value;	
    SRV_OPENVPN_CLIENT[rowIdx-1].selca = myForm.selca.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].selpem= myForm.selpem.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].pemkey= find_pem_key(myForm.selpem.value);
    
    SRV_OPENVPN_CLIENT[rowIdx-1].clientAuth = myForm.clientAuth.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].username = myForm.username.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].userpasswd = myForm.userpasswd.value;
    //alert("brIfname =" + fnGetSelText(myForm.brIfIndex.value, ifs_op));
    SRV_OPENVPN_CLIENT[rowIdx-1].brIfname = fnGetSelText(myForm.brIfIndex.value, ifs_op);

	table = document.getElementById("show_openvpn_table");
	rows = table.getElementsByTagName("tr");

    // Delete added the table members
	if(rows.length > 0) {
		for(i=rows.length-1; i > 0; i--) {
			table.deleteRow(i);
		}
	}
	// Re-join the array elements to the table
	for(i=0; i < SRV_OPENVPN_CLIENT.length; i++) {
		addRow(i);		
	}
    
	ChgColor('tri', SRV_OPENVPN_CLIENT.length, rowIdx-1);
    
}  


function Activate(form)
{
	var i, j;

	myForm.SRV_OPENVPN_CLIENT_tmp.value = "";

	for(i=0; i<SRV_OPENVPN_CLIENT.length; i++){
		for(j in SRV_OPENVPN_CLIENT[i]){
			myForm.SRV_OPENVPN_CLIENT_tmp.value = myForm.SRV_OPENVPN_CLIENT_tmp.value + SRV_OPENVPN_CLIENT[i][j] + "+";
		}
	}

	myForm.action="/goform/net_Web_get_value?SRV=SRV_OPENVPN_CLIENT";
	myForm.submit();
     
	return;
}
    
function ShowList1(name) 
{
	table = document.getElementById("show_openvpn_table");

	rows = table.getElementsByTagName("tr");

	//re-join the array elements to the table
	for(i=0; i<SRV_OPENVPN_CLIENT.length; i++) {
		addRow(i);		
	}
	
	ChgColor('tri', SRV_OPENVPN_CLIENT.length, 0);		
}

function ovpnSetBrIfs2Index(form, cidx)
{
	var i;
	
	for(i=0; i<ifs_op.length; i++){		
		if(ifs_op[i].text == SRV_OPENVPN_CLIENT[cidx].brIfname) {
			//alert("index =" + i +"client brIf=" + SRV_OPENVPN_CLIENT[cidx].brIfname);
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

    fnLoadForm(myForm, SRV_OPENVPN_CLIENT[0], SRV_OPENVPN_CLIENT_type);

    ovpnSetBrIfs2Index(myForm, 0);
    myForm.clientId.value = LeditEntryIdx;	// Default from index 1
    
    return;   
}


function UploadCert(form)
{	
	var passwd;
	
	if(document.getElementById("certPasswd").value == ''){
		alert(NULL_+ ' ' + Password_);
		return;
	}
		
	passwd = document.getElementById("certPasswd").value;
	if((isSymbol(passwd, Password_))) {
		return;
	} 
	
	form.ovpnClientId.value = document.getElementById("clientId").value;
	form.action="/goform/web_ovpnCertUpload";	
	form.submit();
	
}

function UploadCACert(form)
{	
		
	form.ovpnClientId.value = document.getElementById("clientId").value;
	form.action="/goform/web_ovpnCertUpload";	
	form.submit();	
}

</script>
</head>

<body onLoad=fnInit()>
<h1>OpenVPN Client Setting</h1>
<fieldset style=width:"800px">
<DIV style="width:800px;">
<form id=myForm name=myForm method="POST" >
<input type="hidden" name="SRV_OPENVPN_CLIENT_tmp" id="SRV_OPENVPN_CLIENT_tmp" value="" >
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=1>
 <tr align="left">
  <td width=180px>Enable</td>
  <td><input type="checkbox" id="enable" value=1></td>
 </tr>
 <tr align="left">
  <td>Client ID</td>
  <td><input type="text" id="clientId" name="clientId" size=5 maxlength=3 readonly> </td>  
 </tr>
 <tr align="left">
  <td>Interface Type</td>
  <td><script language="JavaScript">fnGenSelect(seldevTyp0, '')</script>  </td>
 </tr>
 <tr align="left" id="setDevTypeTap0" name="setDevTypeTap0"> 
  <td>Bridge with LAN</td>
  <td nowrap><script language="JavaScript">fnGenSelect(ifs_selstate, '')</script></td>  
 </tr>    
 <tr align="left">
  <td>Remote Server IP</td>
  <td nowrap><input type="text" id="serverIP" size=15 maxlength=15></td>
 </tr> 
 <tr align="left">
  <td>Port</td>
  <td nowrap><input type="text" id="serverPort" size=10 maxlength=5></td>
 </tr> 
 <tr align="left">
  <td>Protocol</td>
  <td><script language="JavaScript">fnGenSelect(selprotoTyp0, '')</script>  </td>
  
 </tr> 
 
 <tr align="left">
  <td>LZO Compression</td>
  <td nowrap>
  <input type="radio" name="compLzo" value=0 onClick=fnChgLMode(0)> <script language="JavaScript">doc(Disable_)</script>
  <input type="radio" name="compLzo" value=1 onClick=fnChgLMode(1)> <script language="JavaScript">doc(Enable_)</script>
  <input type="hidden" name="compLzo" value=2 onClick=fnChgLMode(2)> </td>
 </tr>  
 <tr align="left"> 
  <td>Encryption Cipher</td>
  <td><script language="JavaScript">fnGenSelect(selencCipherTyp0, '')</script>  </td>
 </tr>
 <tr align="left"> 
  <td>Hash Algorithm</td>
  <td><script language="JavaScript">fnGenSelect(selAuthHashType0, '')</script>  </td>
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
  <td>Authentication Method</td>
  <td><script language="JavaScript">fnGenSelect(selClientAuthTyp0, '')</script>  </td>
 </tr>
 <tr id="setAuthPassword" name="setAuthPassword">   
   <td><script language="JavaScript">doc(User_Name)</script></td>
   <td nowrap><input type="text" id=username name="username" size=30 maxlength=64></td>
   <td><script language="JavaScript">doc(Password_)</script></td>
   <td nowrap><input type="password" id=userpasswd name="userpasswd" size=20 maxlength=32 autocomplete="off"></td>
   <td></td>
 </tr>
 </table>
</form>


<form id=myFormB name=myFormB onSubmit="return stopSubmit()" method="POST">
{{ net_Web_csrf_Token() | safe }}
<p><table align=left border=0>
 <tr>
  <td width=400px><script>fnbnBID(modb, 'onClick=Modify(this.form)', 'btnM')</script></td>
  <td width=300px><script>fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
  <td width=100px></td>
</table></p>
<table align=left border=0>
<tr style="height:50px"></tr>
</table>
</DIV>
</form>



<table width="770px">
 <tr class=r0>
  <td>OpenVPN Client</td>
  <td id = "totalpolicy"></td></tr>
 </table>  
 <table cellpadding=1 cellspacing=2 width="770px" id="show_openvpn_table">   
 <tr align="center">
  <th width=50px  class="s0"><script>doc(Enable_)</script></th>
  <th width=50px class="s0">Client ID</th>
  <th width=110px class="s0">Interface Type</th>     
  <th width=150px class="s0">Remote Server</th>
  <th width=110px class="s0">Protocol</th> 
  <th width=150px class="s0">Encryption Cipher</th>
  <th width=50px  class="s0">LZO Compression</th>
  <th width=100px  class="s0">Authentication Mode</th>
 </tr>

<script language="JavaScript">ShowList1('tri')</script>
</table>
     
</fieldset>
</body></html>
