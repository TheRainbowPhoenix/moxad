<html>
<head>
<% net_Web_file_include(); %>
<script language="JavaScript" src=input.js></script>
<link href="./main_style.css" rel=stylesheet type="text/css"><script language="JavaScript">
checkCookie();
//<!--
if (!debug) {
	var wdata = [
		{ ca_name:'client.pem',ca_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'},
		{ ca_name:'moxa.pem',ca_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'}
	];	
}else{
	var wdata = [
		<%net_webCACERUP();%>
		];
		
}	




var wtype = {
	ca_name:4, ca_subject:4
};


var addb = 'Add';
var modb = 'Modify';
var updb = 'Activate';
var delb = 'Delete';	

var table_idx=0;
var newdata=new Array;
var tablefun = new table_show(document.getElementsByName('form1'),"show_available_table" ,wtype, wdata, table_idx, newdata, Addformat, Entry_Init);

function init(){
	SI.Files.stylizeAll(); 
	//document.getElementById("certext").readOnly=true; 
}

var CA_MAX = 10;
function GetCerRout(mode){
	var filename;	
	filename = document.getElementById('cerfile').value.split("\\")[document.getElementById('cerfile').value.split("\\").length-1];
	if(duplicate_check(-1, wdata, "ca_name", filename, Name_  + ' ' + filename + ' '  + "is exist")<0){
		//document.getElementById('certext').value="";
		return;
	}
	
	if(mode == 0){
		document.getElementById('caname').innerHTML = '';
	document.getElementById('cersubject').innerHTML = '';
		ChgColor('tri', wdata.length, CA_MAX+1);	
	}
}
	
function EditRow(row) {
	fnLoadForm(myForm1, wdata[row], wtype);
	ChgColor('tri', wdata.length, row);	
	Entry_Init(row);	
}


function Entry_Init(row) {
	if(row >= 0){
		document.getElementById('caname').innerHTML = wdata[row]['ca_name'];
	}else{
		document.getElementById('caname').innerHTML = '';
	}
}



function tabbtn_del(form, sel)
{	
	var fileName="Delete "+document.getElementById('caname').innerHTML+"?";
	if(!window.confirm(fileName)){
					return;
				}
	
	
	document.getElementById('myForm').action="/goform/net_WebCADELETEGetValue?caname="+document.getElementById('caname').innerHTML;	
	document.getElementById('myForm').submit();	
}


function Addformat(mod,i)
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
	if(wdata.length > CA_MAX || wdata.length  < 0){		
		alert('Number of certifications is Over or Wrong');
		with(document.myForm2){			
			btnD.disabled = false;			
		}					
	}else if(wdata.length == CA_MAX){
		with (document.myForm2) {
			btnD.disabled = false;
		}
		with(document.myForm1){	
			btnI.disabled = true;
		}
	}else if(wdata.length == 0){		
		with (document.myForm2) {		
			btnD.disabled = true;
		}
		with(document.myForm1){	
			btnI.disabled = false;
		}
	}else{		
		with (document.myForm2) {		
			btnD.disabled = false;
		}
		with(document.myForm1){	
			btnI.disabled = false;
		}
	}
	document.getElementById("totalsmcnt").innerHTML = '('+wdata.length +'/' +CA_MAX+')';
	//document.getElementById("totalsmcnt").innerHTML = wdata.length + ' / 256';
}


function UploadCer(form)
{	
	var i;
	var j;
	

	form.action="/goform/web_CAUpload";	
	form.submit();
	
}


function fnInit() {	
	init();	
	tablefun.show();
	Total_CERS();
	if(wdata!=''){
	EditRow(0);		
	}
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
<body onLoad="fnInit()">
<h1><script language="JavaScript">doc(CA_CERT_)</script></h1>
<form id=myForm name=form method="POST" onSubmit="return stopSubmit()">	
<fieldset>
<input type="hidden" name="ca_tmp" id='catmp' value="" >
<% net_Web_csrf_Token(); %>
</form>
<form id=myForm1 name=form1 method="POST" onSubmit="return stopSubmit()" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>
<div align="center" style="width:700px">
    <table width="100%" align="center" border="0">
         <tr class=r0>
     	    <td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
             	<br></font></div></td>
             <td width="10%"><div align="left">
                 <script language="JavaScript">doc(Name_)</script>
                 </div></td>
 	        <td name="ca_name" id=caname class=r1></td>
         </tr>        
	</table>

    <table width="100%" align="center" border="0" width=700px> 
    	 <tr class=r0>
    	    <td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	<br></font></div></td>
            <td width="23%"><div align="left">
                <script language="JavaScript">doc(CA_UP_)</script>
                </div></td>
        	<td width="17%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            		<input name="ca_file" id="cerfile" type="file"  class="file" onchange="GetCerRout(0)" > 
        	<br></font></div></td>
        	<td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	        	<script language="JavaScript">fnbnBID(Import_, 'onClick=UploadCer(this.form)', 'btnI')</script>
        	</font></div></td>
        </tr>
   	</table>
</form>   	
<form id=myForm2 name=form1 method="POST" onSubmit="return stopSubmit()" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>	
<p><table class=tf align=center width=700px>
 <tr>  
  <td><script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_del(this.form,1)', 'btnD')</script></td>
  <td></td>  
</table></p>



<table cellpadding=1 cellspacing=2 width=700px>
<tr class=r0>
 <td width=140px><script language="JavaScript">doc(CER_LIST_)</script></td>
 <td id = "totalsmcnt" colspan=4></td></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table">
<tr></tr>
 <tr class=r5 align="center">
  <th width=120px><script language="JavaScript">doc(Name_)</script></th>
  <th width=580px><script language="JavaScript">doc(CER_Subject_)</script></th></tr>
</table>
</fieldset>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>       


