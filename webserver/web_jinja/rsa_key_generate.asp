<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = [
		{ rsakey_name:'client.pem',rsakey_len:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'},
		{ rsakey_name:'moxa.pem',rsakey_len:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'}
	];
}else{
	var wdata = [
		{{ net_webRSAKEY() | safe }}
	];
	{{ net_webISCerKeyGEN('SRV_RSAKEYGT') | safe }}	
}

var keylen = [
	{ value:1024, text:'1024 bit'},	{ value:2048, text:'2048 bit' }
];


var wtype = {
	rsakey_name:4, privateKey:2
};
	
var selkeylen = { type:'select', id:'privateKey', name:'privateKey', size:1, onChange:'', option:keylen};

var addb = 'Add';
var modb = 'Modify';
var updb = 'Activate';
var delb = 'Delete';	
var genb = 'Generate';	

var table_idx=0;
var newdata=new Array;


function Entry_Init(row) {
	if(row >= 0){
		document.getElementById('rsakeyname').value = wdata[row]['rsakey_name'];
		document.getElementById('privateKey').value = wdata[row]['privateKey'];
	}else{
		document.getElementById('rsakeyname').value = '';
		document.getElementById('privateKey').value = 1024;
	}
}

var tablefun = new table_show(document.getElementsByName('form1'),"show_available_table" ,wtype, wdata, table_idx, newdata, Addformat, Entry_Init);

var RSAKEY_MAX = 10;

function EditRow(row) {
	fnLoadForm(myForm2, wdata[row], wtype);
	ChgColor('tri', wdata.length, row);	
	Entry_Init(row);	
}


function CheckFileReqContents(http_request) {
	var filestate="";
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
			setTimeout("makeRequest('/xml/net_check_file_xml?SRV=SRV_RSAKEYGT', CheckFileReqContents ,1);",3000);		
		}else{
			location.reload();
		}
	}
}

function check_gen_stat(filename){
	makeRequest("/xml/net_check_file_xml?SRV=SRV_RSAKEYGT", CheckFileReqContents ,1);
}

function showWait(){
	document.getElementById('keygen').style.display="none";	
	document.getElementById('waitkeygen').style.display="";	
	document.getElementById('keygenmsg').innerHTML = 'Key Pair is generating.\nPlease Wait';
	check_gen_stat();
}

function tabbtn_gen(form, sel)
{	
	//var fileName="Delete "+document.getElementById('rsakeyname').innerHTML+"?";
	//document.getElementById('myForm').action="/goform/net_WebRSAKEYGen?rsakeyname="+document.getElementById('rsakeyname').innerHTML;	
	/*if(!isNull(document.getElementById("rsakeyname").value)) {
		if(isSymbol(document.getElementById("rsakeyname"), Name_)) {
			return;
		}
	}else{
		return;
	}*/
	if(isSymbol(document.getElementById('myForm').rsakeyname, Name_)){
			return;
	}
	document.getElementById('myForm').action="/goform/net_WebRSAKEYGen";	
	document.getElementById('myForm').submit();	
}
	

function tabbtn_add(form, sel)
		{
	document.getElementById("rsakeyname").value="";	
	document.getElementById("privateKey").value=1024;	
	document.getElementById('rsakeyname').disabled="";
	document.getElementById('btnG').disabled="";	
	}
	
function tabbtn_del(form, sel)
{	
	var fileName="Delete "+document.getElementById('rsakeyname').value+"?";
	if(!window.confirm(fileName)){
		return;
	}	
	
	
	//document.getElementById('myForm').action="/goform/net_WebRSAKEYDel?rsakeyname="+document.getElementById('rsakeyname').innerHTML;	
	document.getElementById('myForm').action="/goform/net_WebRSAKEYDel?rsakeyname="+document.getElementById('rsakeyname').value;		
	document.getElementById('myForm').submit();	
}


function Addformat(mod, i)
{		
	var j;	
	var k;
	var idx;
	
	j = 0;
	for(k in wtype){										
		newdata[j] = wdata[i][k];		
		j++;
	}	
}




function Total_CERS()
{			
	if(wdata.length > RSAKEY_MAX || wdata.length  < 0){		
		alert('Number of certifications is Over or Wrong');
		document.getElementById('btnD').disabled = false;									
	}else if(wdata.length == RSAKEY_MAX){
			document.getElementById('btnD').disabled = false;		
			document.getElementById('btnA').disabled = true;				
	}else if(wdata.length == 0){		
			document.getElementById('btnD').disabled = true;		
			document.getElementById('btnA').disabled = false;		
	}else{		
			document.getElementById('btnD').disabled = false;		
			document.getElementById('btnA').disabled = false;	
}
	document.getElementById("totalkeycnt").innerHTML = '('+wdata.length +'/' +RSAKEY_MAX+')';
}


function fnInit() {
	if(SRV_RSAKEYGT==1){
		showWait();
	}
	tablefun.show();
	if(wdata.length==0){		
		document.getElementById('btnD').disabled=true;	
	}
	document.getElementById('rsakeyname').disabled=true;	
	document.getElementById('btnG').disabled=true;
	Total_CERS();
	if(wdata.length!=0){
		EditRow(0);
	}
}

function stopSubmit()
{
	return false;
}




</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(RSA_KEY_GEN_)</script></h1>
<fieldset>
<table><tr><td>
<form id=myForm name=form method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<div id=keygen align="center" style="width:700px">
    <table width="100%" align="center" border="0">
         <tr class=r0>
             <td width="10%"><div align="left">
                 <script language="JavaScript">doc(Name_)</script>
                 </div></td>
 	        <td width="30%"> <input type="text" id=rsakeyname name="rsakey_name" size=32 maxlength=64 ></td>
         </tr>        
         <tr class=r0>
            <td width=10%><div align="left">
                 <script language="JavaScript">doc(RSA_KEY_PAIR_LEN_)</script>
                 </div></td>
 	        <td ><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
             	<script language="JavaScript">fnGenSelect(selkeylen, '')</script>
             	<br></font></div></td>
            <td></td> 	
         </tr>    
	</table>
</form>   	

<form id=myForm2 name=form1 method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<p><table class=tf align=center width=700px>
 <tr>  
  <td width=400px>
    <script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_add(this.form,1)', 'btnA')</script>
    <script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_del(this.form,1)', 'btnD')</script>    
    <script language="JavaScript">fnbnBID(genb, 'onClick=tabbtn_gen(this.form,1)', 'btnG')</script>
  </td>
 </tr>
</table></p>

<table cellpadding=1 cellspacing=2 width=700px>
<tr class=r0>
 <td width=140px><script language="JavaScript">doc(KEY_LIST_)</script></td>
 <td id = "totalkeycnt" colspan=4></td></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table">
<tr></tr>
 <tr class=r5 align="center">
  <th width=600px><script language="JavaScript">doc(Name_)</script></th>
  <th width=100px><script language="JavaScript">doc(RSA_KEY_PAIR_LEN_)</script></th></tr>
</table>
</div>
<div id=waitkeygen style="display:none">
	<table cellpadding=1 cellspacing=2 width=700px>
	<tr class=r0>
	 <td id=keygenmsg></td>
	</tr>
	</table>
</div>

</form>
</td></tr></table>
</fieldset>
</body></html>
