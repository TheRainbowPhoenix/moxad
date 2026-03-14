<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
{{ net_Web_show_value('SRV_CFG_ENC_PW') | safe }}
//<!--
	function RemoteConfigDownload(form){
		if ( document.tftp_form.tftp_server_ip.value == "" ){
			return;
		}
		if ( document.tftp_form.remote_config.value == "" ){
			return;
		}
		form.action="/goform/RemoteConfigDownloadFunction"
	}

	var checkConfigDownload=0
	function RemoteCliConfigDownload(form){
		if(checkConfigDownload){
			return;
		}else{
			checkConfigDownload=1;
		}
		if ( document.tftp_form.tftp_server_ip.value == "" ){
			return;
		}
		if ( document.tftp_form.remote_cli_config.value == "" ){
			return;
		}
		form.action="/goform/RemoteCliConfigDownloadFunction"
		//document.getElementById('cfgcliimport').disabled=true;
		document.getElementById("loadingimg").style.visibility = "visible";
	}


	function RemoteCliConfigUpload(form){
		if ( document.tftp_form.tftp_server_ip.value == "" ){
			return;
		}		
		if ( document.tftp_form.remote_cli_config.value == "" ){
			return;
		}
		form.action="/goform/RemoteCliConfigUploadFunction"
	}
	function RemoteFirmwareDownload(form){
		//alert("RemoteFirmwareDownload");
		if ( document.tftp_form.tftp_server_ip.value == "" ){
			return;
		}		
		if ( document.tftp_form.remote_firmware.value == "" ){
			return;
		}		
		form.action="/goform/RemoteFirmwareDownloadFunction"			
		clock();
	}

	function RemoteLogUpload(form){
		if ( document.tftp_form.tftp_server_ip.value == "" ){
			return;
		}
		if ( document.tftp_form.remote_log.value == "" ){
			return;
		}
		form.action="/goform/RemoteLogUploadFunction"
	}
	
	function RemoteActivate(form){
		form.action="/goform/RemoteActivateFunction"
	}
	var DifferenceSecond = 1;
	var barwidth1 = 1;
	var barwidth2 = 49;
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
			setTimeout("clock()",3000)
	}

	//-->
	function send(form){
		if(document.getElementById('cfgimport_pw').value!="" && isSymbol(document.getElementById('cfgimport_pw'), Password_))
		{
			return;
		}
		form.action="/goform/net_Web_get_value?SRV=SRV_CFG_ENC_PW";	
		form.submit();	
	}

	function init(){
		var myForm = document.getElementById('tftp_form');	
		if(SRV_CFG_ENC_PW.cfgimport_pw!="0"){
			document.getElementById('cfgimport_pw_en').checked=true;
		}
 	}
</script>

</head>
<body onLoad="init()">

<h1><script language="JavaScript">doc(Upgrade_Software_or_Configuration)</script></h1>
<fieldset>
<form method="post" target="mid" name="tftp_form" id="tftp_form" >
{{ net_Web_csrf_Token() | safe }}
<div align="center">
    <table width="100%" align="center" border="0">
    	  <tr class=r0>              
            <td width="45%"><div align="left">
            <script language="JavaScript">doc(TFTP_IP_)</script>
            </div></td>
            <td width="55%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <input type="text" name="tftp_server_ip" size="20" maxlength="30" value=""><br></font></div></td>
         </tr>
    	 <tr>              
            <td width="45%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <br></font></div></td>
            <td width="55%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <br></font></div></td>
         </tr>         
    	 <tr class=r0>             
            <td width="45%"><div align="left">
            <script language="JavaScript">doc(Configuration_Path_)</script>
            </div></td>
            <td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <input type="text" name="remote_config" size="20" maxlength="63" value=""><br></font></div></td>
            <td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
	            <script language="JavaScript">fnbnS(Download_, 'onClick="RemoteConfigDownload(this.form)"')</script><br></font></div></td>
      	    <td width="25%"></td>                       
        </tr>
        
        <tr>              
            <td width="45%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <br></font></div></td>
            <td width="55%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <br></font></div></td>
         </tr>  
        <tr class=r0>             
            <td width="45%"><div align="left">
            <script language="JavaScript">doc(FW_Path_)</script>
            </div></td>
            <td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <input type="text" name="remote_firmware" size="20" maxlength="63" value=""><br></font></div></td>
            <td width="30%" colspan="2"><div align="left"><font size="1" face="Arial, Helvetica, sans-serif, Marlett"> 
				<script language="JavaScript">fnbnS(Download_, 'onClick="RemoteFirmwareDownload(this.form)"')</script><br></font></div></td>
        </tr>
		<tr>
			<td width="45%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
			<td width="55%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
		</tr>
        <tr class=r0>             
            <td width="45%"><div align="left">
            <script language="JavaScript">doc(Log_Path_)</script>
            </div></td>
            <td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <input type="text" name="remote_log" size="20" maxlength="63" value=""><br></font></div></td>                
            <td width="30%" colspan="2"><div align="left"><font size="1" face="Arial, Helvetica, sans-serif, Marlett">             
		    	<script language="JavaScript">fnbnS(Upload_, 'onClick="RemoteLogUpload(this.form)"')</script><br></font></div></td>
        </tr>

		<tr>
			<td width="45%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
			<td width="55%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
		</tr>
   		
    	<tr class=r0>
            <td colspan=3><div align="left">
             <script language="JavaScript">doc("Text-Based configuration file encryption setting")</script>
            </div></td>	       
        </tr>

		<tr>
			<td width="45%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
			<td width="55%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
		</tr>
		
        <tr class=r1>
            <td width="45%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
             <input type=checkbox id=cfgimport_pw_en name=cfgimport_pw_en disabled>
             <script language="JavaScript">doc(Enable_);doc(Password_)</script>
             <br></font></div></td>	        
        	<td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
         		<input type=text id=cfgimport_pw name=cfgimport_pw size= 20 maxlength=20>
        	<br></font></div></td>
        	<td width="30%"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
        	<script language="JavaScript">fnbnBID(Submit_, 'onClick=send(this.form)', 'btnS')</script></td>
	        <br></font></div></td>	       
        </tr>

        <tr>
			<td width="45%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
			<td width="55%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<br></font></div></td>
		</tr>
		
        <tr class=r0>             
            <td width="45%"><div align="left">
            <script language="JavaScript">doc(Configuration_Path_)</script>
            </div></td>
            <td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                <input type="text" name="remote_cli_config" size="20" maxlength="63" value=""><br></font></div></td>
            <td width="30%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
	            <script language="JavaScript">fnbnSID(Download_, 'onClick="RemoteCliConfigDownload(this.form)"', 'cfgcliimport')</script>
	            <script language="JavaScript">fnbnS(Upload_, 'onClick="RemoteCliConfigUpload(this.form)"')</script><br></font></div></td>                       
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
<div>
<table width="100%" align="left" border="0" id="bar_table" >
<tr class=r0> 
</table>   	
</div>
</fieldset>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body>
</html>       


