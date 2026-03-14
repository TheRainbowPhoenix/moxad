<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=input.js></script>
<script language="JavaScript">
checkCookie();
//<!--
if (!debug) {
	var cer_local = [
		{ cer_lb:'iei', cer_name:'client.pem', cer_pw:'123456',cer_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'},
		{ cer_lb:'moxa', cer_name:'moxa.pem', cer_pw:'password',cer_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'}
	];	
}else{
	var cer_mgmt = [
		<%net_webCERMgmt();%>		
	];
	var csr_file = [<%net_webCSR();%>];
	
	<%net_Web_show_value('SRV_IPSEC');%>
	<%net_Web_show_value('SRV_AUTH_CERT');%>
}	

var wtype_init;


var wtype = {
	cer_lb:4, cer_name:4, cer_pw:4, cer_subject:4
};


var csrsel = new Array;
var selcsrfile = { type:'select', id:'CSRFile', name:'CSRFile', size:1, onChange:'', option:csrsel};

function fnChgMgmtModeType(value){
	if(value == 0){
		document.getElementById('cerimportpw').style.visibility = "hidden";
		document.getElementById('csrfilesel').style.visibility = "hidden";		
		document.getElementById('cermodename').innerHTML = CER_;
	}else if(value == 1){
		document.getElementById('cerimportpw').style.visibility = "hidden";
		document.getElementById('cermodename').innerHTML = CSR_FROM_CSR_;
		document.getElementById('csrfilesel').style.visibility = "visible";		
	}else{
		document.getElementById('cermodename').innerHTML = CSR_FROM_P12_;
		document.getElementById('cerimportpw').style.visibility = "visible";
		document.getElementById('csrfilesel').style.visibility = "hidden";	
	}

}



var mgmttyp0 = [
	{ value:0, text:CER_ },	{ value:1, text:CSR_FROM_CSR_ },	{ value:2, text:CSR_FROM_P12_ }
];
var selmgmtmode = { type:'select', id:'mgmtmode', name:'mgmtmode', size:1, onChange:'fnChgMgmtModeType(this.value)', option:mgmttyp0};

var addb = 'Add';
var modb = 'Modify';
var updb = 'Activate';
var delb = 'Delete';	

var table_idx=0;
var newdata=new Array;
var tablefun = new table_show(document.getElementsByName('form1'),"show_available_table" ,wtype_init, cer_mgmt, table_idx, newdata, Addformat, 0);

function init(){
	SI.Files.stylizeAll(); 
	//document.getElementById("certext").readOnly=true; 
}

var CER_MAX = 10;
function GetCerRout(mode){
	var filename;
	filename = document.getElementById('cerfile').value.split("\\")[document.getElementById('cerfile').value.split("\\").length-1];
	if(duplicate_check(-1, cer_mgmt, "cer_name", filename, CER_MGMT_ISSUED_TO_  + ' ' + filename + ' '  + "is exist")<0){
		document.getElementById('btnI').disabled="true";
		return;
	}
	if(cer_mgmt.length >= CER_MAX){
		document.getElementById('btnI').disabled="true";
	}else{
		document.getElementById('btnI').disabled="";
	}
	
	
	if(mode == 0){
		document.getElementById('cername').value = '';
		//document.getElementById("certext").value=document.getElementById("cerfile").value; 
		document.getElementById("cerpw").value=''; 
		document.getElementById("cerpw").disabled=false;
		ChgColor('tri', cer_mgmt.length, CER_MAX+1);	
	}
}



function DelCer(){
	var i, count=0;
	
	for(i=0;i<document.getElementsByName("enable").length;i++){
		if(document.getElementsByName("enable")[i].checked==true){
			if(document.getElementById("certmp").value!=""){
				document.getElementById("certmp").value+="+";
			}			
			document.getElementById("certmp").value+=cer_mgmt[i-count].cer_name;
			cer_mgmt.splice(i-count, 1);
			count++;
		}
	}
	tablefun.show();
	Total_CERS();
}

function tabbtn_sel(form, sel)
{	
	var i;
	for(i=0;i<SRV_IPSEC.length;i++){
		if(SRV_IPSEC[i].enable==1&&SRV_IPSEC[i].ikemode==1){
			if(SRV_IPSEC[i].lselpem==document.getElementById('cername').innerHTML){
				alert(CER_DEL_ERROR_);
				return;
			}
		}
	}
	
	DelCer();
}


function Addformat(mod, idx)
{	
	var j;	
	var k;
	
	j = 0;
	if(cer_mgmt.length>0){
		newdata[0]="<input type=checkbox name="+'enable'+" id="+'enable'+idx+ " ";
		if(SRV_AUTH_CERT.selpem == cer_mgmt[idx].cer_name){
			newdata[0]+=" disabled";
		}
		newdata[0]+=" >";
		for(k in cer_mgmt[0]){
			if(k=='key_name'){
				continue;
			}
			newdata[j+1] = cer_mgmt[idx][k];	
			j++;
		}
	}
}




function Total_CERS()
{			
	if(cer_mgmt.length > CER_MAX || cer_mgmt.length  < 0){		
		alert('Number of certifications is Over or Wrong');
		with(document.myForm2){			
			btnD.disabled = false;					
			btnS.disabled = true;			
		}				
	}else if(cer_mgmt.length == CER_MAX){
		with (document.myForm2) {
			btnD.disabled = false;
			btnS.disabled = false;			
		}
		with (document.myForm1) {
			btnI.disabled = true;
		}		
	}else if(cer_mgmt.length == 0){		
		with (document.myForm2) {		
			btnD.disabled = true;
			btnS.disabled = false;			
		}
		with (document.myForm1) {
			btnI.disabled = false;
		}
	}else{		
		with (document.myForm2) {		
			btnD.disabled = false;
			btnS.disabled = false;			
		}
		with (document.myForm1) {
			btnI.disabled = false;
		}
	}
	document.getElementById("totalsmcnt").innerHTML = '('+cer_mgmt.length +'/' +CER_MAX+')';
	//document.getElementById("totalsmcnt").innerHTML = cer_mgmt.length + ' / 256';
}


function UploadCer(form)
{	
	var i;
	var j;	

	if(duplicate_check(-1, cer_mgmt, "cer_name", document.getElementById('cername').value, CER_MGMT_ISSUED_TO_  + ' ' + document.getElementById('cername').value + ' '  + "is exist")<0){
		return;
	}
	
	if(document.getElementById("mgmtmode").value==2){
		if(document.getElementById("cerpw").value == ''){
			alert(NULL_+ ' ' + Password_);
			return;
		}
	}

	form.action="/goform/web_CERMGMTUpload";	
	form.submit();
	
}

function SelectALL(value){
	var i;
	for(i=0;i<document.getElementsByName("enable").length;i++){
		if(!document.getElementsByName("enable")[i].disabled){
			document.getElementsByName("enable")[i].checked=value;
		}
	}
}

function Activate(form)
{	
	document.getElementById("btnS").disabled="true";
	var i;
	var j;


	document.getElementById('myForm').action="/goform/net_WebCERMGMTDELETEGetValue";	
	document.getElementById('myForm').submit();	
}

function csroptionadd(){
	var csr_tmp, i;

	csr_tmp = document.getElementById('CSRFile');
	csr_tmp.options.length=0; 

	for(i = 0; i < csr_file.length; i++){
		csr_tmp.options.add(new Option(csr_file[i].csr_name, csr_file[i].csr_name)); 
	}
}



function fnInit() {	
	init();	
	csroptionadd();
	fnChgMgmtModeType(0);
	tablefun.show();
	Total_CERS();
	
}

		
	//-->
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
<body class=main onLoad="fnInit()">
<h1><script language="JavaScript">doc(CER_MGMT_);</script></h1>
<form id=myForm name=form method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="cer_tmp" id='certmp' value="" >
</form>
<fieldset>
<form id=myForm1 name=form1 method="POST" onSubmit="return stopSubmit()" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>	
 <table width="100%" border="0" style="word-break:break-all">
  <tr class=r0>
   <td width=250px><script language="JavaScript">doc(CER_MGMT_IMPORT_)</script></td>
   <td width=450px><script language="JavaScript">fnGenSelect(selmgmtmode, '')</script></td>
  </tr>
 </table>
 
 <table width="100%" border="0" style="word-break:break-all" id='cerlab'>
  <tr class=r0>
   <td width=250px><script language="JavaScript">doc(Label_)</script></td>
   <td width=450px><input type="text" name="cer_name" id="cername" size="20" maxlength="40"></td>
  </tr>
  <tr class=r0 id=csrfilesel>
   <td width=250px><script language="JavaScript">doc(CSR_COMMON_NAME_)</script></td>
   <td width=450px><script language="JavaScript">fnGenSelect(selcsrfile, '')</script></td>
  </tr>
   
 </table>

 <table width="100%" border="0" id='cerimport'> 
  <tr class=r0 id=cerimportpw>
   <td td width=250px><script language="JavaScript">doc(Import_);doc(' ');doc(Password_)</script></td>
   <td td width=250px><input type="text" name="cer_pw" id="cerpw" size="20" maxlength="40"></td>
   <td td width=200px></td>   
  </tr>
  <tr class=r0>
   <td td width=250px id=cermodename></td>
   <td td width=250px><input name="cer_file" id="cerfile" type="file"  class="file" onchange="GetCerRout(0)" ></td>
   <td td width=200px><script language="JavaScript">fnbnBID(Import_, 'onClick=UploadCer(this.form)', 'btnI')</script></td>
  </tr>
 </table>
 
</form>   	

<form id=myForm2 name=form1 method="POST" onSubmit="return stopSubmit()" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>	
<p><table>
 <tr>  
  <td width=400px><script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
  <td  width=300px><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
  </tr>
</table></p>


<table cellpadding=1 cellspacing=2>
<tr class=r0>
 <td width=140px><script language="JavaScript">doc(CER_LIST_)</script></td>
 <td id = "totalsmcnt" colspan=4></td></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" style="word-break:break-all">
<tr></tr>
 <tr>
  <th width=50px align="left"><input type="checkbox" onClick="SelectALL(this.checked)" id=all name="all"><script language="JavaScript">doc(all_)</script></td>
  <th width=120px><script language="JavaScript">doc(Label_)</script></td>
  <th width=200px><script language="JavaScript">doc(CER_MGMT_ISSUED_TO_)</script></td>
  <th width=200px><script language="JavaScript">doc(CER_MGMT_ISSUED_BY_)</script></td>
  <th width=130px><script language="JavaScript">doc(EXPIRED_DATE)</script></td>
 </tr>
</table>

</fieldset>
</form>
</body>
</html>       


