<html>
<head>

<% net_Web_file_include(); %>
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

	<%net_Web_show_value('SRV_OPENVPN_CLIENT');%>
	<% net_Web_openvpnShowClientCert(); %>
}
    
var clientId0 = [
        { value:1, text:"1" },    { value:2, text:"2" }
]; 
    
var devTyp0 = [
        { value:0, text:"TAP" },    { value:1, text:"TUN" }
        
];
var seldevTyp0 = { type:'select', id:'devType', name:'devType', size:1, onChange:'fnChgLType(this.value)', option:devTyp0 };

var protoTyp0 = [
        { value:0, text:"UDP" },    { value:1, text:"TCP" }
        
];
var selprotoTyp0 = { type:'select', id:'protoType', name:'protoType', size:1, onChange:'fnChgLType(this.value)', option:protoTyp0 };    

var encCipherTyp0 = [
        { value:0, text:"BlowFish CBC" },    { value:1, text:"AES-128 CBC" }, 
        { value:2, text:"AES-256 CBC" }, 	{value:3, text: "AES-192 CBC"},
        { value:4, text:"DES CBC"},	{ value:5, text: "DES-EDE3 CBC"}        
];

var authHashType0 = [
		{ value:0, text:"SHA1" }, { value:1, text:"MD5" }
];
    
var clientAuthTyp0 = [
        { value:0, text:"Certificate" },    { value:1, text:"Password" } 
        
];

var selClientId = { type:'select', id:'clientId', name:'clientId', size:1, onChange:'ovpn_settingClientIdChange(this.value)', option:clientId0 };
    
var selencCipherTyp0 = { type:'select', id:'encCipher', name:'encCipher', size:1, onChange:'fnChgLType(this.value)', option:encCipherTyp0 };  
var selAuthHashType0 = { type:'select', id:'authHash', name:'authHash', size:1, onChange:'fnChgLType(this.value)', option:authHashType0 };     
var selClientAuthTyp0 = { type:'select', id:'clientAuth', name:'clientAuth', size:1, onChange:'', option:clientAuthTyp0 };  

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
	cell.width = '150px';	
	cell.innerHTML = SRV_OPENVPN_CLIENT[i].serverIP + "/" +SRV_OPENVPN_CLIENT[i].serverPort;
	row.appendChild(cell);


	cell = document.createElement("td");
	cell.width = '400px';
	cell.innerHTML = "<b>CA subject:</b><br>" + SRV_OPENVPN_CLIENT_CERT[i].cacertSubject + "<br>" + 
		"<b>P12 subject:</b><br>" + SRV_OPENVPN_CLIENT_CERT[i].clcertSubject;
	row.appendChild(cell);
    
	row.style.Color = "black";

	row.id = 'tri'+i;
	row.onclick=function(){EditRow1(this)};
	row.style.cursor=ptrcursor;
	row.align="center";
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
    
    SRV_OPENVPN_CLIENT[rowIdx-1].clientAuth = myForm.clientAuth.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].username = myForm.username.value;
    SRV_OPENVPN_CLIENT[rowIdx-1].userpasswd = myForm.userpasswd.value;
    
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
    
    
function fnInit()
{
  
    myForm = document.getElementById('myForm');

    fnLoadForm(myForm, SRV_OPENVPN_CLIENT[0], SRV_OPENVPN_CLIENT_type);
    myForm.clientId.value = LeditEntryIdx;	// Default from index 1
    
   	document.getElementById('btnRestart').style.width='130px';
	document.getElementById('btnRestart').style.backgroundImage='url(image/bnlong.png)';
	document.getElementById('btnDelCA').style.width='130px';
	document.getElementById('btnDelCA').style.backgroundImage='url(image/bnlong.png)';
    
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
	form.action="/goform/web_ovpnclientCertUpload";	
	form.submit();
	
}

function UploadCACert(form)
{	
		
	form.ovpnClientId.value = document.getElementById("clientId").value;
	form.action="/goform/web_ovpnclientCertUpload";	
	form.submit();	
}


function ClearCerts(actionType)
{	

	//alert("Button action type="+actionType);
	if(actionType == 9 || actionType == 10) { // 9:Remove CA certificates, 10:Remove all certificates
		myForm.ovpnCertType.value = actionType;
	}	
	else {
		alert("Invalid action code ");

		return;
	}

	myForm.ovpnClientId.value = document.getElementById("clientId").value;
	myForm.action="/goform/web_ovpnCertClean";
	myForm.submit();
}

function RestartClient()
{	
	var clientId = document.getElementById("clientId").value;
	
	if(clientId > 0 && clientId <=2 ) { 
		myForm.ovpnClientId.value = clientId;
	}	
	else {
		alert("Invalid client ID, restart stopped ");

		return;
	}
	
	myForm.action="/goform/web_ovpnclientRestart";
	myForm.submit();
}
</script>
</head>

<body onLoad=fnInit()>
<h1>OpenVPN Client Certificate</h1>
<fieldset style=width:"700px">
<form id=myForm name=myForm method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="ovpnClientId" id="ovpnClientId" value="1" >
<input type="hidden" name="ovpnCertType" id="ovpnCertType" value="0">
<table cellpadding=1 cellspacing=1>

 <tr align="left">
  <td width=180px>Client ID</td>
  <td width=240px><input type="text" id="clientId" name="clientId" size=5 maxlength=3 readonly> </td>  
  <td width=100px></td>
  <td width=180px></td>
 </tr>
 
 </table>
</form>

<form name="file_upload2" id="file_upload2" method="post" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="ovpnClientId" id="ovpnClientId" value="1" >
<input type="hidden" name="ovpnCertType" id="ovpnCertType" value="1" >
<table cellpadding=1 cellspacing=1 width=800px> 
    <tr>
        <td width=180px><div align="left">CA Certificate</div></td>
	    <td width=240px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
          	<input name="rootCACert" id="rootCACert" type="file"  class="file">     	   	<br></font></div></td>
    	<td width=100px></td>
    	<td width=180px></td>
        <td width=100px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	       	<script language="JavaScript">fnbnBID(Import_, 'onClick=UploadCACert(this.form)', 'btnI')</script>
        	</font></div></td>        
    </tr>    
</table>
 </form>
 
<form name="file_upload" id="file_upload" method="post" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="ovpnClientId" id="ovpnClientId" value="1" >
<input type="hidden" name="ovpnCertType" id="ovpnCertType" value="0" >
<table cellpadding=1 cellspacing=1 width=800px> 
    <tr>
        <td width=180px><div align="left">Client Certificate (PKCS12)</div></td>
	    <td width=240px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
          	<input name="clientCert" id="clientCert" type="file"  class="file"> <br></font></div></td>
    	<td width=100px><div align="left">Cert Password</div></td>
        <td width=180px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		    <input type="password" name="certPasswd" id="certPasswd" size="20" maxlength="32" autocomplete="off">
        	<br></font></div></td>
        <td width=100px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	       	<script language="JavaScript">fnbnBID(Import_, 'onClick=UploadCert(this.form)', 'btnI')</script>
        	</font></div></td>
    </tr>
    
</table>
 </form>

<p>
<table border=0>
  <tr>
    <td width=100px>
     <script language="JavaScript">fnbnBID("Remove client certs", 'onClick=ClearCerts(10)', 'btnDelCA')</script></td> 
    <td></td>
    <td width=100px>
     <script language="JavaScript">fnbnBID("Restart Client", 'onClick=RestartClient()', 'btnRestart')</script></td> 
    <td></td>
  </tr>
</table></p> 

<table align=left border=0>
<tr style="height:50px"></tr>
</table>


<table width="650px">
 <tr class=r0>
  <td>OpenVPN Client</td>
  <td id = "totalpolicy"></td></tr>
 </table>  
 <table cellpadding=1 cellspacing=2 width="650px" id="show_openvpn_table">   
 <tr align="center">
  <th width=50px  class="s0"><script>doc(Enable_)</script></th>
  <th width=50px class="s0">Client Id</th>
  <th width=150px class="s0">Remote Server</th>
  <th width=400px  class="s0">Certificate Subject</th>
 </tr>

<script language="JavaScript">ShowList1('tri')</script>
</table>
     
</fieldset>
</body></html>
