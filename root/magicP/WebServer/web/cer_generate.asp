<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie();
if (!debug) {
	var SRV_CERREQ = {
		ct:'TW', days:'365', state:'TAP', local:'HT', org:'MOXA', orgunit:'IEI', name:'aries', mailaddr:'aries.wang@moxa.com'
	};
	var SRV_CERGT = [
		{cerday:'365', 	cerpem:'moxa', 	cerorgunit:'IEI', cermailaddr:'iei.net@moxa.com', cerpw:'123456'},
		{cerday:'30', 	cerpem:'iei', 	cerorgunit:'IVN', cermailaddr:'ivn.net@moxa.com', cerpw:'moxaiei'},
		{cerday:'3650', cerpem:'g903',	cerorgunit:'DAC', cermailaddr:'dac.net@moxa.com', cerpw:'moxanet'}
	];
}else{
	<%net_Web_show_value('SRV_CERREQ');%>
	<%net_Web_show_value('SRV_CERGT');%>				
}

var RootCA_EXPORT_="RootCa Export";

var myForm, myForm2;
	
var neSRV_CERREQ=new Array;
var table_idx=0;
var tablefun = new table_show(document.getElementsByName('form2'),"show_available_table" ,SRV_CERGT_type, SRV_CERGT, table_idx, neSRV_CERREQ, Addformat, 0);

var CER_MAX = 10;	

function EditRow(row) {
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
	for(var i in SRV_CERGT_type){
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
	for(k in SRV_CERGT_type){
		if(mod == 0){
			neSRV_CERREQ[j] = SRV_CERGT[i][k];		
		}else{			
			neSRV_CERREQ[j] = myForm2[k].value;
		}
		j++;
	}	
}

function Total_CERS()
{			
	if(SRV_CERGT.length > CER_MAX || SRV_CERGT.length  < 0){		
		alert('Number of Certificate is Over or Wrong');
		with(myForm2){			
			btnA.disabled = true;
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}else if(SRV_CERGT.length == CER_MAX){
		with (myForm2) {
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}else if(SRV_CERGT.length == 0){		
		with (myForm2) {		
			btnD.disabled = true;
			btnM.disabled = true;
			btnS.disabled = false;
		}
	}else{		
		with (myForm2) {
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}
	document.getElementById("totalsmcnt").innerHTML = '('+SRV_CERGT.length +'/' +CER_MAX+')';
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

	for(i = 0 ; i < SRV_CERGT.length ; i++)
	{	
		for(j in SRV_CERGT_type){
			 form.SRV_CERGT_tmp.value = form.SRV_CERGT_tmp.value + SRV_CERGT[i][j] + "+";		
		}
	}
	document.getElementById('myForm2').action="/goform/net_Web_get_value?SRV=SRV_CERGT";	
	document.getElementById('myForm2').submit();	
}

function Reqcheck(form)
{	
	var i;
	var j;
	with (document.getElementById('myForm')) {
		if(c_t.value==''||state_name.value==''||cer_org.value==''||cer_name.value==''){
			alert('NULL');
			return;	
		}								
	}
	for(i in SRV_CERREQ_type){
		if((isSymbol(document.getElementById('myForm')[i], CER_C_REQ_)))
		{
			return;
		}
	}

	document.getElementById('myForm').action="/goform/net_Web_get_value?SRV=SRV_CERREQ";	
	document.getElementById('myForm').submit();	
}

function fnInit() {	
	myForm = document.getElementById('myForm');	
	myForm2 = document.getElementById('myForm2');
	fnLoadForm(myForm, SRV_CERREQ, SRV_CERREQ_type);
	tablefun.show();
	Total_CERS();
	EditRow(0);
}

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
		}
	}

function check_file_stat(filename){
	makeRequest("/xml/net_check_file_xml?filename="+filename+"&page=cer_generate.asp", CheckFileReqContents ,1);
	if(filestate == 0){
		location=file_name;
	}else if(filestate == 1){
		alert("file generating......");
	}else if(filestate == 2){
		alert("file generat fail......");
	}
}

function GetCert(){
	file_name = '/'+SRV_CERGT[tNowrow_Get()]['cerpem']+'.crt';
	check_file_stat(file_name);
	//alert(filestate);
	//location=file_name;
}	
function GetP12(){
	file_name = '/'+SRV_CERGT[tNowrow_Get()]['cerpem']+'.p12';
	check_file_stat(file_name);
	//alert(filestate);
	//location=file_name;
}

function GetRootCA(){
	file_name = '/cacert.crt';
	check_file_stat('/cacert.crt');
	//location=file_name;
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




</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(CER_G_)</script></h1>
<fieldset>
<table><tr><td>
<form id=myForm name=form1 method="POST">
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0 align=left>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(CER_C_REQ_)</script></td></tr>  
 <tr align="left">
  <td width=180px><script language="JavaScript">doc(CER_CT_)</script></td>
  <td width=160px><input type="text" id=c_t name="ct" size=20 maxlength=2></td>
  <td width=180px><script language="JavaScript">doc(CER_DAY_)</script></td>
  <td><input type="text" id=day_s name="days" size=20 maxlength=5></td></tr> 
 <tr align="left">
  <td><script language="JavaScript">doc(CER_STATE_)</script></td>
  <td><input type="text" id=state_name name="state" size=20 maxlength=64></td>
  <td><script language="JavaScript">doc(CER_LOCAL_)</script></td>  
  <td><input type="text" id=local_name name="local" size=20 maxlength=64 ></tr> 
 <tr align="left">  
  <td><script language="JavaScript">doc(CER_ORG_)</script></td>  
  <td><input type="text" id=cer_org name="org" size=20 maxlength=64 >
  <td><script language="JavaScript">doc(CER_ORG_UNIT_)</script></td>  
  <td><input type="text" id=org_unit name="orgunit" size=20 maxlength=64 ></tr> 
 <tr align="left">  
  <td><script language="JavaScript">doc(CER_COMMON_NAME_)</script></td>  
  <td><input type="text" id=cer_name name="name" size=20 maxlength=64 >
  <td><script language="JavaScript">doc(CER_MAIL_)</script></td>  
  <td><input type="text" id=mail_addr name="mailaddr" size=20 maxlength=64 ></tr>    
</table>
<table cellpadding=1 cellspacing=2 border=0 align=left>
 <tr>
  <td width=140px align=left><script language="JavaScript">fnbnBID(Submit_, 'onClick=Reqcheck()', 'btnSr')</script></td>
  <td ><script language="JavaScript">fnbnBID2(RootCA_EXPORT_, 'onClick=GetRootCA()', 'btnCA');</script></td>  
 </tr>
</table>
</form>
</td></tr>
<tr><td>

<form id=myForm2 name=form2 method="POST">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="SRV_CERGT_tmp" id='certmp' value="" >
<table>
<tr><td>
<table cellpadding=1 cellspacing=2 border=0 align=left>  
 <tr class=r0 >
  <td colspan=4><script language="JavaScript">doc(CER_SETTING_)</script></td></tr>  
 <tr align="left">  
  <td width=180px><script language="JavaScript">doc(CER_DAY_)</script></td>  
  <td width=160px><input type="text" id=cerday name="cerday" size=20 maxlength=5 >
  <td width=180px><script language="JavaScript">doc(CER_ORG_UNIT_)</script></td>  
  <td><input type="text" id=cerorgunit name="cerorgunit" size=20 maxlength=64 ></td></tr>   
 <tr align="left">  
  <td><script language="JavaScript">doc(CER_COMMON_NAME_)</script></td>  
  <td><input type="text" id=cerpem name="cerpem" size=20 maxlength=64 >
  <td><script language="JavaScript">doc(CER_MAIL_)</script></td>  
  <td><input type="text" id=cermailaddr name="cermailaddr" size=20 maxlength=64 ></td></tr>  
 <tr align="left">  
  <td ><script language="JavaScript">doc(CER_PW_)</script></td>  
  <td ><input type="text" id=cerpw name="cerpw" size=20 maxlength=32 ></tr>  
</table> 
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2 border=0 align=left>
 <tr>  
  <td width=140px><script language="JavaScript">fnbnBID2(P12_EXPORT, 'onClick=GetP12()', 'btnK')</script></td> 
  <td width=200px><script language="JavaScript">fnbnBID2(CER_EXPORT, 'onClick=GetCert()', 'btnC')</script></td>  
  <td></td></tr> 
</table>
</td></tr>
<tr><td>
<table align=left cellpadding=1 cellspacing=2 border=0>
 <tr>
  <td width=300px><script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script>
  <script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
  <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=45></td>
  <td width=400px><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
  </tr>
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2>
<tr class=r0>
 <td width=140px><script language="JavaScript">doc(CER_LIST_)</script></td>
 <td id = "totalsmcnt" colspan=5></td></tr>
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2 border=0 id="show_available_table">
<tr></tr>
 <tr align=center>
  <th width=150px><script language="JavaScript">doc(CER_DAY_)</script></td>
  <th width=200px><script language="JavaScript">doc(CER_ORG_UNIT_)</script></td>
  <th width=150px><script language="JavaScript">doc(CER_COMMON_NAME_)</script></td>
  <th width=220px><script language="JavaScript">doc(CER_MAIL_)</script></td>
  <th><script language="JavaScript">doc(CER_PW_)</script></td></tr>
</table>
</td></tr>
</table>
</form>
</td></tr></table>
</fieldset>
</body></html>
