<html>
<head>
{{ net_Web_file_include() | safe }}
<script language="JavaScript" src=input.js></script>
<link href="./main_style.css" rel=stylesheet type="text/css"><script language="JavaScript">
checkCookie();
var TYPE_ORG=0;
var TYPE_ADD=1;
var TYPE_DEL=2;

if (!debug) {
	var csr_file = [
		{ cer_lb:'iei', cer_name:'client.pem',cer_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'},
		{ cer_lb:'moxa', cer_name:'moxa.pem',cer_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'}
	];	
}else{
	var csr_file = [{{ net_webCSR() | safe }}];
	var key_file = [{{ net_webRSAKEY() | safe }}];
	{{ net_webISCerKeyGEN('SRV_CSR') | safe }}	
}

var keysel = new Array;
var selkeyfile = { type:'select', id:'RSAKey', name:'RSAKey', size:1, onChange:'', option:keysel};

var table_idx=0, wtype_init;
var newdata=new Array;
var tablefun = new table_show(document.getElementsByName('form'),"show_available_table" ,wtype_init, csr_file, table_idx, newdata, Addformat, 0);


var filestate="";
function CheckFileReqContents(http_request) {
	var xmldoc;					
    if (http_request.readyState == 4) {
		if (http_request.status == 200) {			
			//xmldoc = http_request.responseText;
			//alert(xmldoc);
			xmldoc = http_request.responseXML;			
			//alert(xmldoc.getElementsByTagName('eth0').length);
			//alert(xmldoc.getElementsByTagName('eth0')[0].firstChild.nodeValue);
			filestate = xmldoc.getElementsByTagName("FILESTATE")[0].firstChild.nodeValue;	
		} else {
			filestate="";				
		}
		if(filestate==1){
			setTimeout("makeRequest('/xml/net_check_file_xml?SRV=SRV_CSR', CheckFileReqContents ,1);",3000);		
		}else{
			window.location = self.location;
		}
	}
}


function check_gen_stat(filename){
	makeRequest("/xml/net_check_file_xml?SRV=SRV_CSR", CheckFileReqContents ,1);
}





function SelectALL(value){
	var i;
	for(i=0;i<document.getElementsByName("enable").length;i++){
		document.getElementsByName("enable")[i].checked=value;
	}
}


function GetCSR(){
	var file_name="";
	csr_file[nowrow-2].csr_name;
	file_name = '/csr/'+csr_file[nowrow-2].csr_name;
	location=file_name;
}	


function keyoptionadd(phase, idx){
	var key_tmp, i;

	key_tmp = document.getElementById('RSAKey');
	key_tmp.options.length=0; 

	for(i = 0; i < key_file.length; i++){
		key_tmp.options.add(new Option(key_file[i].rsakey_name, key_file[i].rsakey_name+'-'+key_file[i].privateKey)); 
	}
}

function showWait(){
	document.getElementById('gen').style.display="none";	
	document.getElementById('waitgen').style.display="";	
	document.getElementById('genmsg').innerHTML = 'CSR is generating.\nPlease Wait';
	check_gen_stat();
}


function fnInit() {
	if(SRV_CSR==1){
		showWait();
	}
	keyoptionadd();
	tablefun.show();
}

var subjectname = new Array( 'contury', 'location', 'company', 'departmnet', 'CN', 'EA');

function CsrDel(){
	var i, count=0;
	
	for(i=0;i<document.getElementsByName("enable").length;i++){
		if(document.getElementsByName("enable")[i].checked==true){
			if(document.getElementById("csrtmp").value!=""){
				document.getElementById("csrtmp").value+="+";
			}
			document.getElementById("csrtmp").value+=csr_file[i-count].csr_name;
			csr_file.splice(i-count, 1);
			count++;
		}
	}
	tablefun.show();
}

function Addformat(mod, idx)
{	
	var j;	
	var k;
	
	j = 0;
	if(csr_file.length>0){
		newdata[0]="<input type=checkbox name="+'enable'+" id="+'enable'+idx+ " " + " >";;
		for(k in csr_file[0]){
			newdata[j+1] = csr_file[idx][k];	
			j++;
		}	
	}
}



function CsrNameCheck()
{	
	var i;
	var j;

	
	for(i=0; i< subjectname.length;i++){
		if(document.getElementById('myForm')[subjectname[i]].value==''){
			alert(CSR_SUBJECT_NAME_+' Have NULL Item');
			return;	
		}
	}		
	

	for(i=0; i< subjectname.length;i++){
		if((isSymbol(document.getElementById('myForm')[subjectname[i]], CSR_SUBJECT_NAME_)))
		{
			return;
		}
	}

	if(!isNull(document.getElementById('myForm')["SUBNAME"].value)){
		if((isSymbol(document.getElementById('myForm')["SUBNAME"], CER_SUBALT_NAME_)))
		{
			return;
		}
	}
	
	document.getElementById('btnGen').disabled=true;
	document.getElementById('myForm').action="/goform/net_WebCSRGen";	
	document.getElementById('myForm').submit();	
}


function Activate(form)
{	
	document.getElementById('myForm').action="/goform/net_WebCSRDel";	
	document.getElementById('myForm').submit();	
}


</script>
<style type="text/css" title="text/css">
.MOXA-INPUT-STYLIZED label.cabinet
{
width: 76px; 
height: 30px; 
//margin-top:15px;  
background: url(image/browse_button1.gif) 0 0 no-repeat;
display: block;
overflow: hidden;
cursor: pointer;
}
.MOXA-INPUT-STYLIZED label.cabinet input.file
{
position: relative;
height: 100%; 
width: auto; 
opacity: 0; 
-moz-opacity: 0;
filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);
}
</style>
</head>
<body onLoad="fnInit()">
<h1><script language="JavaScript">doc(CSR_)</script></h1>
<form id=myForm name=form method="POST" onSubmit="return stopSubmit()">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="csrtmp" id='csrtmp' value="" >	
<div align="left" id=gen>
 <table width="100%" align="center" border="0">
  <tr class=r0>     	    
   <td width=15%><div align="left"><script language="JavaScript">doc(CSR_PRIVATE_KEY_)</script></div></td>
   <td ><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    <script language="JavaScript">fnGenSelect(selkeyfile, '')</script>
   <br></font></div></td>
  </tr>         
 </table>
	
 <p><table width="100%" border=0 align="center">
  <tr class=r0>
   <td colspan=4><script language="JavaScript">doc(CSR_SUBJECT_NAME_)</script></td>
  </tr>
  <tr align="left">
   <td width=30%><script language="JavaScript">doc(CER_CT_)</script></td>
   <td width=20%><input type="text" id=contury name="contury" size=16 maxlength=2></td>	  
   <td width=30%><script language="JavaScript">doc(CER_LOCAL_)</script></td>  
   <td><input type="text" id=location name="location" size=16 maxlength=16 ></td></tr> 
  <tr align="left">  
   <td><script language="JavaScript">doc(CER_ORG_)</script></td>  
   <td><input type="text" id=company name="company" size=16 maxlength=16></td> 
   <td><script language="JavaScript">doc(CER_ORG_UNIT_)</script></td>  
   <td><input type="text" id=departmnet name="departmnet" size=16 maxlength=16></td></tr> 
  <tr align="left">  
   <td><script language="JavaScript">doc(CER_COMMON_NAME_)</script></td>  
   <td><input type="text" id=CN name="CN" size=16 maxlength=16></td>  
   <td><script language="JavaScript">doc(CER_MAIL_)</script></td>  
   <td><input type="text" id=EA name="EA" size=16 maxlength=32></td></tr>
  <tr align="left" class=r1>  
   <td><script language="JavaScript">doc(CER_SUBALT_NAME_)</script></td>  
   <td><input type="text" id=SUBNAME name="SUBNAME" size=16 maxlength=16></td>  
   <td></td>  
   <td></td></tr>  
 </table></p>
	
 <p><table width="100%" align="center" border="0">
 <tr class=r0>     	    
  <td width="30%"><div align="left"><script language="JavaScript">doc(CSR_)</script></div></td>
  <td width="80%" align=left><script language="JavaScript">fnbnBID(CSR_GENERATE_, 'onClick=CsrNameCheck()', 'btnGen')</script></td>    
 </tr>         
 </table></p>

 <table width="100%" align="center" border="0">
 <tr class=r0>     	    
  <td width=400px align=left><script language="JavaScript">fnbnBID(delb, 'onClick=CsrDel()', 'btnDel')</script>
  							 <script language="JavaScript">fnbnBID(Export_, 'onClick=GetCSR()', 'btnExport')</script></td>
  <td  width=300px><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
 </tr>         
 </table>
 <table cellpadding=1 cellspacing=2>
  <tr class=r0>
   <td width=140px><script language="JavaScript">doc(CER_LIST_)</script></td>
   <td id = "totalsmcnt" colspan=4></td></tr>
 </table>
 <table cellpadding=1 cellspacing=2 id="show_available_table" style="word-break:break-all">
  <tr></tr>
  <tr>
   <th width=50px><input type="checkbox" onClick="SelectALL(this.checked)" id=all name="all"><script language="JavaScript">doc(all_)</script></td>
   <th width=150px><script language="JavaScript">doc(Label_)</script></td>
   <th width=500px><script language="JavaScript">doc(CER_Subject_)</script></td>
  </tr>
 </table>
 </div>
 
 <div id=waitgen style="display:none">
	<table cellpadding=1 cellspacing=2 width=700px>
	<tr class=r0>
	 <td id=genmsg width=140px></td>
	</tr>
	</table>
</div>

	
</form>
</fieldset>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>       


