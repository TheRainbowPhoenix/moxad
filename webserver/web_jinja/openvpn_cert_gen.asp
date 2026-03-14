<html>
<head>

{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src="doc.js"></script>
<script language="JavaScript" src="common.js"></script>
<script>
checkCookie();
debug = 0;
if (debug) {
	var SRV_OPENVPN_SERVER_CERT = {
		actType:'0', country:'US', expireTime:'365', stateName:'NY', cityName:'New York', orgName:'MOXA', orgUnit:'IEI', cnName:'EDR810', emailAddr:'mail@domain.com'
	};
	var SRV_CERGT = [
		{cerday:'365', 	cerpem:'moxa', 	cerorgunit:'IEI', cermailaddr:'iei.net@moxa.com', cerpw:'123456'},
		{cerday:'30', 	cerpem:'iei', 	cerorgunit:'IVN', cermailaddr:'ivn.net@moxa.com', cerpw:'moxaiei'},
		{cerday:'3650', cerpem:'g903',	cerorgunit:'DAC', cermailaddr:'dac.net@moxa.com', cerpw:'moxanet'}
	];
    var SRV_OPENVPN_CERT_STATUS=[
        {certName:'RootCA', certSubject:'C=US, ST=NY, L=New York, O=OpenVPN, OU=changeme, CN=EDR/name=EDR' },
        {certName:'Server', certSubject:'C=US, ST=NY, L=New York, O=OpenVPN, OU=changeme, CN=test/name=test' }
    ];

}else{
	{{ net_Web_show_value('SRV_OPENVPN_SERVER_CERT') | safe }}

    {{ net_Web_openvpnShowCert() | safe }}
}

var RootCA_EXPORT="RootCA Export";

var SRV_OPENVPN_SERVER_CERT_type = {
	country:4, days:4, state:4, local:4, org:4, orgUnit:4, name:4, mailaddr:4
};

var myForm1;
    
/*    
var SRV_OPENVPN_SERVER_CERGT_type = {
	cerday:4, cerorgunit:4, cerpem:4,cermailaddr:4, cerpw:4
};
	
    
var myForm2;	
var neSRV_CERREQ=new Array;
    
var table_idx=0;
var tablefun = new table_show(document.getElementsByName('myForm2'), "show_available_table", SRV_OPENVPN_SERVER_CERGT_type, SRV_OPENVPN_SERVER_CERGT, table_idx, neSRV_CERREQ, Addformat, 0);

var CER_MAX = 3;	

function EditRow(row) 
{
	fnLoadForm(myForm2, SRV_CERGT[row], SRV_CERGT_type);
	ChgColor('tri', SRV_CERGT.length, row);	
}


function tabbtn_sel(form, sel)
{	
	if(sel == 0 || sel == 2){
		if(sel == 0){
			table_idx = CER_MAX;
		}else{
			table_idx = tNowrow_Get();
		}
	}
	for(var i in SRV_OPENVPN_SERVER_CERGT_type){
		if((isSymbol(document.getElementById('myForm2')[i], CER_SETTING_)))
		{
			return;
		}
	}
	
	if(sel == 0){		
		Addformat(1, 0);
		tablefun.add();	
	}else if(sel == 1){
		tablefun.del();
	}else if(sel == 2){
		tablefun.mod();
	}	
	Total_CERS();	
}

    
function Addformat(mod, i)
{		
	var k,j;
	j = 0;
	for(k in SRV_OPENVPN_SERVER_CERGT_type){
		if(mod == 0){
			neSRV_CERREQ[j] = SRV_OPENVPN_SERVER_CERGT[i][k];		
		}else{			
			neSRV_CERREQ[j] = myForm2[k].value;
		}
		j++;
	}	
}

function Total_CERS()
{			
	if(SRV_OPENVPN_SERVER_CERGT.length > CER_MAX || SRV_OPENVPN_SERVER_CERGT.length  < 0){		
		//alert('Number is Over or Wrong');
		with(document.myForm2){			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}
    else if(SRV_OPENVPN_SERVER_CERGT.length == CER_MAX){
		with (document.myForm2) {
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}
    else if(SRV_OPENVPN_SERVER_CERGT.length == 0){		
		with (document.myForm2) {		
			btnD.disabled = true;
			btnM.disabled = true;
			btnS.disabled = false;
		}
	}
    else{		
		with (document) {		
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}
	document.getElementById("totalsmcnt").innerHTML = '('+SRV_OPENVPN_SERVER_CERGT.length +'/' +CER_MAX+')';
}


function stopSubmit()
{
	return false;
}


function Activate(form)
{	
	document.getElementById("btnS").disabled="true";
	var i;
	var j;

	for(i = 0 ; i < SRV_OPENVPN_SERVER_CERGT.length ; i++) {	
		for(j in SRV_OPENVPN_SERVER_CERGT_type) {
			 form.SRV_OPENVPN_CERGT_tmp.value = form.SRV_OPENVPN_CERGT_tmp.value + SRV_OPENVPN_SERVER_CERGT[i][j] + "+";		
		}
	}
    
	document.getElementById('myForm2').action="/goform/net_Web_get_value?SRV=SRV_OPENVPN_SERVER_CERGT";	
	document.getElementById('myForm2').submit();	
}

*/
    
    
function Reqcheck(actionType)
{	


    /* alert("Button action type="+actionType); */
    if(actionType == 1) { // 1:Generate certificates
        myForm1.actType.value = actionType;

        /* TODO: checking code here */
        if(myForm1.expireTime.value < 10 || myForm1.expireTime.value > 7300) {
            alert("Certificate expire days should be between 10 and 7300 days !");
            return;
        }
        if(myForm1.country.value=='' || myForm1.stateName.value=='' || myForm1.cityName.value=='' || myForm1.orgName.value==''|| myForm1.cnName.value=='') {
            alert("NULL");
            return; 
        }                               

        
        if(isSymbol(myForm1.country, "Country Name"))   {
            return;
        }
        if(isSymbol(myForm1.stateName, "State Name"))   {
            return;
        }
        if(isSymbol(myForm1.cityName, "Locality Name")) {
            return;
        }
        if(isSymbol(myForm1.orgName, "Organization Name"))  {
            return;
        }
        if(isSymbol(myForm1.cnName, "Server Common Name"))  {
            return;
        }
        
        alert("Notice: Please restart the OpenVPN server after certificates are re-generated");
        
    }
    else if(actionType ==2) { // 2: Remove all certificates
        myForm1.actType.value = actionType;
    }   
    else {
        alert("Invalid action code ");

        return;
    }

	document.getElementById('myForm1').action="/goform/net_Web_get_value?SRV=SRV_OPENVPN_SERVER_CERT";	
	document.getElementById('myForm1').submit();
}

    

var filestate="";
function CheckFileReqContents(http_request) {
		var xmldoc;					
	    if (http_request.readyState == 4) {
			if (http_request.status == 200) {			
				//xmldoc = http_request.responseText;
				//alert(xmldoc);
				xmldoc = http_request.responseXML;			

				filestate = xmldoc.getElementsByTagName("FILESTATE")[0].firstChild.nodeValue;	
			} else {
				filestate="";				
			}
		}
	}

function check_file_stat(filename){
	makeRequest("/xml/net_check_file_xml?filename="+filename+"&page=cer_generate.asp", CheckFileReqContents ,1);
	if(filestate == 0){
		location=file_name;
	}
    else if(filestate == 1){
		alert("File generating......");
	}
    else if(filestate == 2){
		alert("File generat fail......");
	}
}



function GetRootCA()
{
	
	if(SRV_OPENVPN_CERT_STATUS[0].certSubject == "Not present") {
		alert("Root CA certificate is not existed");
		return;
	}
	file_name = '/ca.crt';
	location=file_name;
}	

function MakeContents(http_request) {
	var nm, data;		
    if (http_request.readyState == 4) {
		if (http_request.status == 200) {				
			location=file_name;
		} else {
			//alert('There was a problem with the request.'+http_request.status);
		}
	}
}

function fnInit() 
{	
	myForm1 = document.getElementById('myForm1');	
	    
	fnLoadForm(myForm1, SRV_OPENVPN_SERVER_CERT, SRV_OPENVPN_SERVER_CERT_type);

	//tablefun.show();

	document.getElementById('btnRestart').style.width='130px';
	document.getElementById('btnRestart').style.backgroundImage='url(image/bnlong.png)';
	document.getElementById('btnDelCA').style.width='130px';
	document.getElementById('btnDelCA').style.backgroundImage='url(image/bnlong.png)';

	return;
}

    
// Certificate status list
function addRow(i)
{
    var valueIdx = 0;
    
	table = document.getElementById('show_openvpn_table');
	row = table.insertRow(table.getElementsByTagName("tr").length);

	
	cell = document.createElement("td");
	cell.width = '150px';
	cell.innerHTML = SRV_OPENVPN_CERT_STATUS[i].certName;
	row.appendChild(cell);
    
    cell = document.createElement("td");
	cell.width = '650px';
	cell.innerHTML = SRV_OPENVPN_CERT_STATUS[i].certSubject;
	row.appendChild(cell);

	row.style.Color = "black";

	row.id = 'tri'+i;
	//row.onclick=function(){EditRow1(this)};
	row.style.cursor=ptrcursor;
	row.align="center";
}    
    
function ShowList1(name) 
{
	table = document.getElementById("show_openvpn_table");

	rows = table.getElementsByTagName("tr");

	//re-join the array elements to the table
	for(i=0; i<SRV_OPENVPN_CERT_STATUS.length; i++) {
		addRow(i);		
	}
	
	//ChgColor('tri', SRV_OPENVPN_CERT_STATUS.length, 0);		
}

function UploadPkcs12Cert(form)
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
	
	form.action="/goform/web_ovpnserverCertUpload";	
	form.submit();
	
}

function UploadCACert(form)
{	
		
	form.action="/goform/web_ovpnserverCertUpload";	
	form.submit();	
}

function RestartServer()
{	
	
	myForm1.ovpnServerId.value = 1;
	myForm1.action="/goform/web_ovpnserverRestart";
	myForm1.submit();
}
</script>
</head>
    
<body onLoad=fnInit()>
<h1>OpenVPN Server Certificate Management</h1>
<fieldset style=width:"730px">

<form id=myForm1 name=myForm1 method="POST">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="actType" id="actType" value="0">
<input type="hidden" name="ovpnServerId" id="ovpnServerId" value="1" >
<table cellpadding=1 cellspacing=2 border=0>
 <tr class=r0>
  <td colspan=4>Server and CA Certificate Generation</td></tr>
 <tr align="left">
  <td width=180px><script language="JavaScript">doc(CER_CT_)</script></td>
  <td width=150px><input type="text" id=country name="country" size=32 maxlength=2></td>
  <td width=150px><script language="JavaScript">doc(CER_DAY_)</script></td>
  <td width=150px><input type="text" id=expireTime name="expireTime" size=32 maxlength=5></td>
 </tr> 
 <tr align="left">
  <td><script language="JavaScript">doc(CER_STATE_)</script></td>
  <td><input type="text" id=stateName name="stateName" size=32 maxlength=64></td>
  <td><script language="JavaScript">doc(CER_LOCAL_)</script></td>  
  <td><input type="text" id=cityName name="cityName" size=32 maxlength=64 ></td>
 </tr> 
 <tr align="left">  
  <td><script language="JavaScript">doc(CER_ORG_)</script></td>  
  <td><input type="text" id=orgName name="orgName" size=32 maxlength=64 ></td>
  <td><script language="JavaScript">doc(CER_ORG_UNIT_)</script></td>  
  <td><input type="text" id=orgUnit name="orgUnit" size=32 maxlength=64 ></td>
 </tr> 
 <tr align="left">  
  <td><script language="JavaScript">doc(CER_COMMON_NAME_)</script></td>  
  <td><input type="text" id=cnName name="cnName" size=32 maxlength=64 ></td>
  <td><script language="JavaScript">doc(CER_MAIL_)</script></td>  
  <td><input type="text" id=emailAddr name="emailAddr" size=32 maxlength=64 ></td>
 </tr>   
 <tr>
 </tr> 
</table>

    
<p>
<table border=0>
  <tr>
    <td><script language="JavaScript">fnbnBID("Generate", 'onClick=Reqcheck(1)', 'btnSr')</script></td>
     <td></td>
    <td> <script language="JavaScript">fnbnBID("Export CA", 'onClick=GetRootCA()', 'btnCA')</script> </td>
  </tr>
</table></p>    
</form>


<table cellpadding=1 cellspacing=2 border=0>
 <tr class=r0>
  <td colspan=4>Server and CA Certificate Import</td></tr>
</table> 
<form name="file_upload2" id="file_upload2" method="post" enctype="multipart/form-data">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="ovpnServerId" id="ovpnServerId" value="1" >
<input type="hidden" name="ovpnCertType" id="ovpnCertType" value="1" >
<table cellpadding=1 cellspacing=1 width=800px> 
    <tr>
        <td width=180px><div align="left">CA Certificate</div></td>
	    <td width=240px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
          	<input name="rootCACert" id="rootCACert" type="file"  class="file"> 
    	   	<br></font></div></td>
    	<td width=100px></td>
    	<td width=180px></td>
        <td width=100px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	       	<script language="JavaScript">fnbnBID(Import_, 'onClick=UploadCACert(this.form)', 'btnI')</script>
        	</font></div></td>        
    </tr>    
</table>
 </form>
 
<form name="file_upload" id="file_upload" method="post" enctype="multipart/form-data">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="ovpnServerId" id="ovpnServerId" value="1" >
<input type="hidden" name="ovpnCertType" id="ovpnCertType" value="0" >
<table cellpadding=1 cellspacing=1 width=800px> 
    <tr>
        <td width=180px><div align="left">Server Certificate (PKCS12)</div></td>
	    <td width=240px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
          	<input name="serverCert" id="serverCert" type="file"  class="file"> 
    	   	<br></font></div></td>
    	<td width=100px><div align="left">Cert Password</div></td>
        <td width=180px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
        	<input type="password" name="certPasswd" id="certPasswd" size="20" maxlength="32" autocomplete="off">
        	<br></font></div></td>
        <td width=100px><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	       	<script language="JavaScript">fnbnBID(Import_, 'onClick=UploadPkcs12Cert(this.form)', 'btnI')</script>
        	</font></div></td>
    </tr>
    
</table>
 </form>

<p>
<table border=0>
  <tr>
    <td width=100px>
     <script language="JavaScript">fnbnBID("Remove all certs", 'onClick=Reqcheck(2)', 'btnDelCA')</script></td> 
    <td></td>
    <td width=100px>
     <script language="JavaScript">fnbnBID("Restart Server", 'onClick=RestartServer()', 'btnRestart')</script></td> 
    <td></td>
  </tr>
</table></p>  

<p>
<table cellpadding=1 cellspacing=2 width="800px">
 <tr class=r0>
  <td width=200px>Certificate Status</td>
  <td id="totalpolicy" colspan=2></td></tr>
</table>  

<table cellpadding=1 cellspacing=2 id="show_openvpn_table" style="width:800px">
 <tr> 
  <td colspan=3></td> 
 </tr>
 <tr align="center">
  <th width=150px class="s0">Name</th>  
  <th width=650px class="s0">Subject</th>  
 </tr> 

<script language="JavaScript">ShowList1('tri')</script>
</table> </p>   


</fieldset>
</body>
</html>
