<html>
<head>
{{ net_Web_file_include() | safe }}
<script language="JavaScript" src=input.js></script>
<link href="./main_style.css" rel=stylesheet type="text/css"><script language="JavaScript">
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();
//<!--
if (!debug) {
	var wdata = [
		{ cer_lb:'iei', cer_name:'client.pem',cer_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'},
		{ cer_lb:'moxa', cer_name:'moxa.pem',cer_subject:'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'}
	];	
}else{
	var wdata = [
		{{ net_webRemoteCERUP() | safe }}
		];
	{{ net_Web_show_value('SRV_IPSEC') | safe }}
		
}	

var wtype_init = {
	cer_lb:4
};


var wtype = {
	cer_lb:4, cer_name:4, cer_subject:4
};


var addb = 'Add';
var modb = 'Modify';
var updb = 'Activate';
var delb = 'Delete';	

var table_idx=0;
var newdata=new Array;
var tablefun = new table_show(document.getElementsByName('form1'),"show_available_table" ,wtype_init, wdata, table_idx, newdata, Addformat, Entry_Init);

function init(){
	SI.Files.stylizeAll(); 
	//document.getElementById("certext").readOnly=true; 
}

var CER_MAX = 10;
function GetCerRout(mode){
	var filename;	
	filename = document.getElementById('cerfile').value.split("\\")[document.getElementById('cerfile').value.split("\\").length-1];
	if(duplicate_check(-1, wdata, "cer_name", filename, Name_  + ' ' + filename + ' '  + "is exist")<0){
		document.getElementById('btnI').disabled="true";
		return;
	}
	document.getElementById('btnI').disabled="";
	if(mode == 0){
	document.getElementById('cername').innerHTML = '';
	document.getElementById('cersubject').innerHTML = '';
	document.getElementById('cerlb').value= '';	
	//document.getElementById("certext").value=document.getElementById("cerfile").value; 
	ChgColor('tri', wdata.length, CER_MAX+1);	
	}
}
	
function EditRow(row) {
	fnLoadForm(myForm1, wdata[row], wtype_init);
	ChgColor('tri', wdata.length, row);	
	Entry_Init(row);	
}


function Entry_Init(row) {
	if(row >= 0){
		document.getElementById('cername').innerHTML = wdata[row]['cer_name'];
		document.getElementById('cersubject').innerHTML = wdata[row]['cer_subject'];
		//document.getElementById("certext").value=''; 
	}else{
		document.getElementById('cername').innerHTML = '';
		document.getElementById('cersubject').innerHTML = '';
	}
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

	if(sel==1){//delete
		var i;
		for(i=0;i<SRV_IPSEC.length;i++){
			if(SRV_IPSEC[i].enable==1&&SRV_IPSEC[i].ikemode==1){
				if(SRV_IPSEC[i].rselpem==document.getElementById('cername').innerHTML){
					alert(CER_DEL_ERROR_);
					return;
				}
			}
		}
	}
	
	if(sel==1){//delete
		var i;
		for(i=0;i<SRV_IPSEC.length;i++){
			if(SRV_IPSEC[i].enable==1&&SRV_IPSEC[i].ikemode==1){
				if(SRV_IPSEC[i].rselpem==document.getElementById('cername').innerHTML){
					alert(CER_DEL_ERROR_);
					return;
				}
			}
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
	Total_CERS();	
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
	if(wdata.length > CER_MAX || wdata.length  < 0){		
		alert('Number of certifications is Over or Wrong');
		with(document.myForm2){			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}					
	}else if(wdata.length == CER_MAX){
		with (document.myForm2) {
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;			
		}
		with(document.myForm1){	
			btnI.disabled = true;
		}
	}else if(wdata.length == 0){		
		with (document.myForm2) {		
			btnD.disabled = true;
			btnM.disabled = true;
			btnS.disabled = false;			
		}
		with(document.myForm1){	
			btnI.disabled = false;
		}
	}else{		
		with (document.myForm2) {		
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;			
		}
		with(document.myForm1){	
			btnI.disabled = false;
		}
	}
	document.getElementById("totalsmcnt").innerHTML = '('+wdata.length +'/' +CER_MAX+')';
	//document.getElementById("totalsmcnt").innerHTML = wdata.length + ' / 256';
}


function UploadCer(form)
{	
	var i;
	var j;
	
	/*if(document.getElementById("certext").value == ''){
		alert("select the certification")
		return;
	}*/

	form.action="/goform/web_certUpload";	
	form.submit();
	
}

/*function UploadCerKey(form)
{	
	var i;
	var j;

	form.cerkeypem.value = wdata[tNowrow_Get()]['cer_name'];			

	form.action="/goform/web_certKeyUpload";	
	form.submit();
	
}*/


function Activate(form)
{	
	document.getElementById("btnS").disabled="true";
	var i;
	var j;

	for(i = 0 ; i < wdata.length ; i++)
	{	
		document.getElementById('myForm').certmp.value = document.getElementById('myForm').certmp.value + wdata[i]['cer_lb'] + "+" + wdata[i]['cer_name'] + "+";		
	}
	document.getElementById('myForm').action="/goform/net_WebCERTABLEGetValue";	
	document.getElementById('myForm').submit();	
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
<h1><script language="JavaScript">doc(Remote_);doc(' ');doc(CER_);doc(' ');doc(Upload_)</script></h1>
<form id=myForm name=form method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<fieldset>
<input type="hidden" name="cer_tmp" id='certmp' value="" >
</form>
<form id=myForm1 name=form1 method="POST" onSubmit="return stopSubmit()" enctype="multipart/form-data">
{{ net_Web_csrf_Token() | safe }}
<div align="left">
    <table width="100%" align="center" border="0">
     	 <tr class=r0>
     	    <td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
             	<br></font></div></td>
             <td width="23%"><div align="left">
                 <script language="JavaScript">doc(Label_)</script>
                 </div></td>
 	        <td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
             	<input type="text" name="cer_lb" id="cerlb" size="20" maxlength="40">
             	<br></font></div></td>
         	<td width="17%"></td>
         	<td width="25%"></td>
         </tr>
         <tr class=r0>
     	    <td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
             	<br></font></div></td>
             <td width="23%"><div align="left">
                 <script language="JavaScript">doc(Name_)</script>
                 </div></td>
 	        <td width="25%" name="cer_name" id=cername class=r1></td>
         	<td width="17%"></td>
         	<td width="25%"></td>
         </tr>
         <tr class=r0>
     	    <td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
             	<br></font></div></td>
             <td width="23%"><div align="left">
                 <script language="JavaScript">doc(CER_Subject_)</script>
                 </div></td>
 	        <td width="25%" name="cer_subject" id=cersubject class=r1></td>
         	<td width="17%"></td>
         	<td width="25%"></td>
         </tr>
	</table>

    <table width="100%" align="center" border="0"> 
    	 <tr class=r0>
    	    <td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	<br></font></div></td>
            <td width="23%"><div align="left">
                <script language="JavaScript">doc(CER_UP_)</script>
                </div></td>
	        <!--td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	<input type="text" name="router" id="certext" size="20" maxlength="40">
            	<br></font></div></td-->
        	<td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
        	 <!--label class="cabinet"--> 
            		<input name="cer_file" id="cerfile" type="file"  class="file" onchange="GetCerRout(0)" > 
           	<!--/label-->  
        	<br></font></div></td>
        	<td width="42%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	        	<script language="JavaScript">fnbnBID(Import_, 'onClick=UploadCer(this.form)', 'btnI')</script>
        	</font></div></td>
        </tr>
   	</table>
</form>   	
<form id=myForm2 name=form1 method="POST" onSubmit="return stopSubmit()" enctype="multipart/form-data">
{{ net_Web_csrf_Token() | safe }}
<p><table>
 <tr>  
  <td width=400px><script language="JavaScript">fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
  <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=300px><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
  </tr>
</table></p>
<table class=tf align=left border=0>
<tr style="height:50px"></tr>
</table>
</div>


<table cellpadding=1 cellspacing=2>
<tr class=r0>
 <td width=140px><script language="JavaScript">doc(CER_LIST_)</script></td>
 <td id = "totalsmcnt" colspan=4></td></tr>
</table>
<table cellpadding=1 cellspacing=2 id="show_available_table">
<tr></tr>
 <tr align="center">
  <th width=80px><script language="JavaScript">doc(Label_)</script></td>
  <th width=120px><script language="JavaScript">doc(Name_)</script></td>
  <th width=120px><script language="JavaScript">doc(CER_Subject_)</script></td></tr>
</table>
</fieldset>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>       


