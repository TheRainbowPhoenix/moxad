<html><head>
{{ net_Web_file_include() | safe }}
<link rel="stylesheet" href="main_style.css" type="text/css" >
<script type="text/javascript">
checkCookie();
<!--
	
	{{ net_Web_show_value('SRV_DDM') | safe }}
	
	var ddmsel = [
		{ value:0, text:Disable_ },	{ value:1, text:Enable_}
	];


	function add_new_data(portName,modelName,wavelength,voltage,temperature,tempWarn,txPower,txPowerWarn,rxPower,rxPowerWarn,className, sfpsn) {

		 var num = document.getElementById("mytable").rows.length;
		 var Tr = document.getElementById("mytable").insertRow(num);

   		 Tr.id='dataTr';	
   		 Tr.className=className;
   		 
		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML=portName;

		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML=modelName;

 		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML=sfpsn;
		 
 		 Td = Tr.insertCell(Tr.cells.length);
 		 Td.innerHTML=wavelength;

 		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML=voltage;
		 
 		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML=temperature;

		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML="<font color=#808080>"+tempWarn+"</font>";

 		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML=txPower;

		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML="<font color=#808080>"+txPowerWarn+"</font>";
		 
 		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML=rxPower;

		 Td = Tr.insertCell(Tr.cells.length);
		 Td.innerHTML="<font color=#808080>"+rxPowerWarn+"</font>";

	}

	function remove_allTabledata() {
	 var num = document.getElementById("mytable").rows.length;

		for(i=2;i<num;i++)
		{
		  document.getElementById("mytable").deleteRow(-1);
		}
	}

	
	/* Create a new XMLHttpRequest object to talk to the Web server */
	var xmlHttp = false;
	
	function creatAJAX(){

		if (window.XMLHttpRequest)
		{
		  xmlHttp=new XMLHttpRequest();
		}
		else
		{
		  xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
		
	}
		

	function getDDMStatus() {
		var url = "./xml/FiberCheck.xml";


		xmlHttp.open("GET", url, true);
		xmlHttp.onreadystatechange = responseDDMStatus;
		xmlHttp.send(null);

	}

	function responseDDMStatus() {
		var portName,modelName,wavelength,voltage,temperature,tempWarn,txPower,txPowerWarn,rxPower,rxPowerWarn, sfpsn;
		

		if(xmlHttp.readyState == 4) {
			if(xmlHttp.status == 200) {
				if(xmlHttp.responseXML != null){
					var response = xmlHttp.responseXML;
	    			var x=response.getElementsByTagName("sfpData");
	    			var i,className;


					remove_allTabledata();


					for (i=0;i<x.length;i++)
					{ 
	   					  if (x[i].getElementsByTagName("portName")[0].hasChildNodes()!=true){
						      portName=" ";
						  } else {
						      portName=x[i].getElementsByTagName("portName")[0].childNodes[0].nodeValue;
						  }
						  if (x[i].getElementsByTagName("modelName")[0].hasChildNodes()!=true){
						      modelName=" ";
						  } else {
	  					      modelName=x[i].getElementsByTagName("modelName")[0].childNodes[0].nodeValue;
	  					  }
	  					  if (x[i].getElementsByTagName("sfpsn")[0].hasChildNodes()!=true){
						      sfpsn=" ";
						  } else {
	  					      sfpsn=x[i].getElementsByTagName("sfpsn")[0].childNodes[0].nodeValue;
	  					  }	  					  
	  					  if (x[i].getElementsByTagName("wavelength")[0].hasChildNodes()!=true){
						      wavelength=" ";
						  } else {
	  					      wavelength=x[i].getElementsByTagName("wavelength")[0].childNodes[0].nodeValue;
	  					  }
	  					  if (x[i].getElementsByTagName("voltage")[0].hasChildNodes()!=true){
						      voltage=" ";
						  } else {
	  					      voltage=x[i].getElementsByTagName("voltage")[0].childNodes[0].nodeValue;
	  					  }	  					  
	  					  if (x[i].getElementsByTagName("temperature")[0].hasChildNodes()!=true){
						      temperature=" ";
						  } else {	  					  
	  					      temperature=x[i].getElementsByTagName("temperature")[0].childNodes[0].nodeValue;
	  					  }
	  					  if(x[i].getElementsByTagName("temperature")[0].getAttribute("warn") == "1")
	  					  {
	  					  	temperature="<font color=#FF0000>"+temperature+"</font>";
	  					  }
	  					  else
	  					  {
	  					    temperature="<font color=#00C000>"+temperature+"</font>";
	  					  }
	  					  if (x[i].getElementsByTagName("tempWarn")[0].hasChildNodes()!=true){
						      tempWarn=" ";
						  } else {
	  					      tempWarn=x[i].getElementsByTagName("tempWarn")[0].childNodes[0].nodeValue;
	  					  }
	  					  if (x[i].getElementsByTagName("txPower")[0].hasChildNodes()!=true){
						      txPower=" ";
						  } else {
	  					      txPower=x[i].getElementsByTagName("txPower")[0].childNodes[0].nodeValue;
	  					  }
	  					  if(x[i].getElementsByTagName("txPower")[0].getAttribute("warn") == "1")
	  					  {
	  					  	txPower="<font color=#FF0000>"+txPower+"</font>";
	  					  }
	  					  else
	  					  {
	  					  	txPower="<font color=#00C000>"+txPower+"</font>";
	  					  }
	  					  if (x[i].getElementsByTagName("txPowerWarn")[0].hasChildNodes()!=true){
						      txPowerWarn=" ";
						  } else {
	  					      txPowerWarn=x[i].getElementsByTagName("txPowerWarn")[0].childNodes[0].nodeValue;
	  					  }
	  					  if (x[i].getElementsByTagName("rxPower")[0].hasChildNodes()!=true){
						      rxPower=" ";
						  } else {	  					  
	  					      rxPower=x[i].getElementsByTagName("rxPower")[0].childNodes[0].nodeValue;
	  					  }
	  					  if(x[i].getElementsByTagName("rxPower")[0].getAttribute("warn") == "1")
	  					  {
	  					  	rxPower="<font color=#FF0000>"+rxPower+"</font>";
	  					  }
	  					  else
	  					  {
	  					  	rxPower="<font color=#00C000>"+rxPower+"</font>";
	  					  }
	  					  if (x[i].getElementsByTagName("rxPowerWarn")[0].hasChildNodes()!=true){
						      rxPowerWarn=" ";
						  }
						  else {    
	  					      rxPowerWarn=x[i].getElementsByTagName("rxPowerWarn")[0].childNodes[0].nodeValue;
                          }
                          if(i%2==1){
                              className="odd";      
                          }else{
                              className="even";
                          }

						  add_new_data(portName,modelName,wavelength,voltage,temperature, tempWarn,txPower, txPowerWarn, rxPower, rxPowerWarn,className, sfpsn);

					  }				

					  setTimeout("getDDMStatus();", 12000);
				}
			}
		}
	}


	var myForm;
	function init(){
		myForm = document.getElementById('myForm');	
		fnLoadForm(myForm, SRV_DDM, SRV_DDM_type);	
		creatAJAX();
		getDDMStatus();	
	}

	function Activate(form)
	{
		form.action="/goform/net_Web_get_value?SRV=SRV_DDM";	
		form.submit();	
	}	

-->
</script>
<style>
table#mytable tr#dataTR td {
	text-align: left;
}
</style>
</head><body onload="init();" >
<form  id=myForm method="post" name="monitor_DDM_form" onclick="touchLasttime()" onkeypress="touchLasttime()" target="mid">
<h1><script language="JavaScript">doc(FIBER_CHECK_)</script></h1>
{{ net_Web_csrf_Token() | safe }}
<fieldset>	
<table width="780">	
	<tr>		
    	<td width="100%">
			<table cellpadding=1 cellspacing=2 style="width:700px">
				<tr class=r0>
			  		<td colspan=4><script language="JavaScript">doc(General_);doc(" ");doc(Settings_);</script></td>
			  	</tr>  
			 	<tr>
			  		<td width="150px"><script language="JavaScript">doc(FIBER_CHECK_);</script></td>  
			  		<td> <script language="JavaScript">iGenSel2('ddmen', 'ddmen', ddmsel)</script></td> 
			  	</tr>
			</table>
			<table align="left" style="width:700px">
				<tr>
					<td><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>		
    	<td width="100%">
			<table id="mytable">
				<tr>
					<th width="5%" rowspan="2" text-align="center"><script language="JavaScript">doc(Port_)</script></th>
					<th width="15%" rowspan="2" text-align="left"><script language="JavaScript">doc(MODEL_NAME_)</script></th>
					<th width="14%" rowspan="2" text-align="center"><script language="JavaScript">doc(SN_)</script></th>
					<th width="13%" rowspan="2" text-align="left"><script language="JavaScript">doc(WAVE_LEN_ );</script>(nm)</th>
					<th width="7%" rowspan="2" text-align="left"><script language="JavaScript">doc(VCC_);</script>V</th>
					<th width="18%" colspan="2" text-align="left"><script language="JavaScript">doc(TEMPERATURE_);</script>&#176;C</th>
					<th width="18%" colspan="2" text-align="left"><script language="JavaScript">doc(TX_POWER_ );</script>(dBm)</th>
					<th width="18%" colspan="2" text-align="left"><script language="JavaScript">doc(RX_POWER_ );</script>(dBm)</th>
				</tr>				
				<tr>
					<th width="9%" text-align="center"><script language="JavaScript">doc(Current_);</script></th>
					<th width="9%" text-align="center"><script language="JavaScript">doc(MAX_);</script></th>
					<th width="8%" text-align="center"><script language="JavaScript">doc(Current_);</script></th>
					<th width="10%" text-align="center"><script language="JavaScript">doc(MAX_MIN_);</script></th>
					<th width="9%" text-align="center"><script language="JavaScript">doc(Current_);</script></th>
					<th width="9%" text-align="center"><script language="JavaScript">doc(MIN_);</script></th>
				</tr>				
			</table>
		</td>
	</tr>
</table>
</fieldset>	
</form>
</body></html>
