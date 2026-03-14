<html>
<head>
<% net_Web_file_include(); %>


<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript" src=input.js></script>
<script language="JavaScript">

checkCookie();
<%net_Web_show_value('SRV_CFG_ENC_PW');%>
//<!--
	
	var myForm;
	
	function init(){
		SI.Files.stylizeAll();
		myForm = document.getElementById('CLIConfigPW');	
		if(SRV_CFG_ENC_PW.cfgimport_pw!="0"){
			document.getElementById('cfgimport_pw_en').checked=true;			
		}

		//document.getElementById("fwrtext").readOnly=true; 
		//document.getElementById("configtext").readOnly=true;  		 
 	}

	function GetFirmwareRouter(){
		//document.getElementById("fwrtext").value=document.getElementById("fwrfile").value; 
	}
	function MakeContents(http_request) {
		var nm, data;		
	    if (http_request.readyState == 4) {
			if (http_request.status == 200) {				
				location=file_name;
			} else {
                return ;
				//alert('There was a problem with the request.'+http_request.status);
			}
		}
	}
	var file_name;
	function MakeAndGetCfg(){
		makeRequest("/goform/net_MakeCLIConfigureFile", MakeContents ,0);		
		file_name = '/MOXA_CFG.ini';
	}
	function MakeAndGetLog(){	
		file_name = '/MOXA_All_LOG.tar.gz';
		var link_path = "/goform/net_MakeMoxaLogFile?show_category=0";
		makeRequest(link_path, MakeContents ,0);
	}	

	
	//-->
	var DifferenceSecond = 1;
	var barwidth1 = 1;
	var barwidth2 = 49;

	function clock_post(form){
        var Path = document.getElementById('fwrfile').value;
		form.action="/goform/web_fwUpload";
		document.getElementById('configfile').disabled=true;
		
        if( Path != ""){
	        form.submit();
            clock();
        }   
        else{
            //alert("No firmware");
            return;
        }
    }
    
    function cfgimport_post(form){
        var Path = document.getElementById('configfile').value;
		document.getElementById('fwrfile').disabled=true;
		form.action="/goform/web_cfgImport"
         if( Path != ""){
	        form.submit();
        }else{
            return;
        }
    }

	function cfgcliimport_post(form){
        var Path = document.getElementById('configclifile').value;
         if( Path != ""){
		 	document.getElementById('cfgcliimport').disabled=true;
			document.getElementById("loadingimg").style.visibility = "visible";
	        form.submit();
        }else{
            return;
        }
    }

	function clock()
	{
		table = document.getElementById("bar_table");
		rows = table.getElementsByTagName("tr");
		if(rows.length)
			table.deleteRow(0);
		row = table.insertRow(0);
		row.className="r1";
		row.align="left";
		cell = document.createElement("td");
		cell.width= "20%"
		cell.innerHTML = DifferenceSecond + " %";
		cell.style.backgroundColor = "#FFFFFF";
		row.appendChild(cell);
		cell = document.createElement("td");
		barwidth11 = barwidth1 + "%";
		cell.align="left";
		cell.width= barwidth11;
		cell.style.backgroundColor = "#00FF00";
		row.appendChild(cell);
		cell = document.createElement("td");
		barwidth21 = barwidth2 + "%";
		cell.align="left";
		cell.width= barwidth21;
		cell.style.backgroundColor = "#FFFFFF";
		row.appendChild(cell);
		cell = document.createElement("td");
		cell.width= "30%"
		cell.style.backgroundColor = "#FFFFFF";
		row.appendChild(cell);
		DifferenceSecond = DifferenceSecond + 1;
		if (DifferenceSecond%2)
			if (barwidth1 < 49)
				barwidth1 = barwidth1+1;
		barwidth2 = 50 - barwidth1;
		if (DifferenceSecond < 100)
			setTimeout("clock()",3100)
		else
			location.href=location.reload();
	}
	function send(form){
		if(document.getElementById('cfgimport_pw').value!="" && isSymbol(document.getElementById('cfgimport_pw'), Password_))
		{
			return;
		}
		form.action="/goform/net_Web_get_value?SRV=SRV_CFG_ENC_PW";	
		form.submit();	
	}
</script>
<style type="text/css" title="text/css">
.MOXA-INPUT-STYLIZED label.cabinet
{
width: 100px; 
height: 22px; margin-top:15px;  
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
<body onLoad="init()">
<h1><script language="JavaScript">doc(Upgrade_Software_or_Configuration)</script></h1>
<fieldset>
<form>
<div align="center">    
    <table width="100%" align="center" border="0">        
        <tr class=r0>
            <td width="40%"><div align="left">
            <script language="JavaScript">doc(Export_Log_File_)</script></div></td>
	        <td width="60%" colspan="3"><div align="left">
	        	<script language="JavaScript">fnbnB(Export_, "onMouseover=\"document.body.style.cursor='hand'\" onMouseout=\"document.body.style.cursor='default'\"  onClick=\"MakeAndGetLog() \" ")</script>
	        </div></td>
        </tr>
   	</table>
</div>
</form>

<form name="file_upload" id="file_upload" method="post" enctype="multipart/form-data">
<% net_Web_csrf_Token(); %>
<div align="center">
    <table width="100%" align="center" border="0">
    	 <tr class=r0>
            <td width="40%"><div align="left">
                <script language="JavaScript">doc(Upgrade_Firmware)</script>
                </div></td>
        	<td width="30%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            		<input name="binary" id="fwrfile" type="file"  class="file" onchange="GetFirmwareRouter()" > 
        	</font></div></td>
        	<td width="30%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	        	<script language="JavaScript">fnbnB(Submit_, 'onClick=clock_post(this.form)')</script>
        	</font></div></td>
        </tr>
   	</table>
   	<table width="100%" align="center" border="0">
    	 <tr class=r0>
            <td width="40%"><div align="left">
             <script language="JavaScript">doc(Upload_Configure_Data_)</script>
             </div></td>
	        <td width="30%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	<input name="binary" id="configfile" type="file"  class="file"> 
	        </font></div></td>
        	<td width="30%"><div align="left">
         		<!--<script language="JavaScript">fnbnSID(Submit_, '', 'cfgimport')</script>-->
          		<script language="JavaScript">fnbnBID(Submit_, 'onClick = cfgimport_post(this.form)','cfgimport')</script>
        	</div></td>
        </tr>
   	</table>
</div>
</form>
<form id="CLIConfigPW" method="post" action="/goform/web_cfgImport">
<% net_Web_csrf_Token(); %>
<div align="center">
	<p></p>
</div>
<div align="center">
    <table width="100%" align="center" border="0">
    	<tr class=r0>
            <td width="15%" colspan=3><div align="left">
             <script language="JavaScript">doc("Text-Based configuration file encryption setting")</script>
            </div></td>	       
        </tr>
   	</table>
</div>


<div align="center">
    <table width="100%" align="center" border="0">
        <tr class=r1>
            <td width="40%"><div align="left">
             <input type=checkbox id=cfgimport_pw_en name=cfgimport_pw_en disabled>
             <script language="JavaScript">doc(Enable_);doc(Password_)</script>
             </div></td>	        
        	<td width="30%"><div align="left">
         		<input type=text id=cfgimport_pw name=cfgimport_pw size= 30 maxlength=30>
        	</div></td>
        	<td width="30%"><script language="JavaScript">fnbnBID(Submit_, 'onClick=send(this.form)', 'btnS')</script></td>
	        </font></div></td>	       
        </tr>
   	</table>
</div>
</form>
<form name="UpCLIConfig" method="post" action="/goform/web_cfgImport" enctype="multipart/form-data">
	<input type="hidden" name="clicfgimport" id="clicfgimport" value="1">
	<% net_Web_csrf_Token(); %>
<div align="center">
    <table width="100%" align="center" border="0">	   
    	 <tr class=r0>
            <td width="40%"><div align="left">
             <script language="JavaScript">doc(Import_CLI_CONF_FILE_)</script>
             </div></td>
	        <td width="30%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            	<input name="binary" id="configclifile" type="file"  class="file"> 
	        </font></div></td>
        	<td width="30%"><div align="left">
         		<!--<script language="JavaScript">fnbnSID(Submit_, '', 'cfgimport')</script>-->
          		<script language="JavaScript">fnbnBID(Submit_, 'onClick = cfgcliimport_post(this.form)','cfgcliimport')</script>
        	</div></td>
         </tr>
   	</table>
   	<table width="100%" align="center" border="0">
    	 <tr class=r0>
            <td width="40%"><div align="left">
			<script language="JavaScript">doc(Export_CLI_CONF_FILE_)</script>
            </div></td>
	         <td width="60%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	         	<script language="JavaScript">fnbnB(Export_, "onMouseover=\"document.body.style.cursor='hand'\" onMouseout=\"document.body.style.cursor='default'\"  onClick=\"MakeAndGetCfg() \" ")</script>
	         </font></div></td>
        </tr>
    </table>
    <table width="100%" align="center" border="0" style="visibility:hidden" id="loadingimg" >
    	 <tr class=r1>
            <td width="40%"><div align="left">			
            </div></td>
	         <td width="60%" colspan="3"><div align="left">
	          <img style="POSITION:relative;" src="image/ajax-loader.gif"></img>
	         </div></td>
        </tr>
    </table>
</div>
</form>

<div align="center">
<table width="100%" align="center" border="0" id="bar_table" >
</table>
</div>
</fieldset>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>       


