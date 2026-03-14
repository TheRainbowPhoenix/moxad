ï»¿<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<script language="JavaScript" src=mdata.js></script>
<script type="text/javascript">
<!--

	

	var stype;
	function resetCnt(stype){	
		//document.monitor_port_form.action="/goform/ResetStatisticCnt?m_type="+stype;		
		//document.monitor_port_form.submit();
		//alert("reset CNT!!! need to fix!!!");
		location.href=location.reload();		
	}


	function showNewPage(form){
		var port,PKTtype;
		var dest;

		port=document.getElementById("port_select").value;
		PKTtype=document.getElementById("packet_select").value;
	
		dest="monitor.asp?"+ "show_port=" + port + "&" + "show_type=" + PKTtype;	
	
		location.href=dest;

	}


	function init(){

		//alert("123");
	}
    /*
	function show_title(tt){
		document.getElementsByTagName("h2")[0].innerHTML=tt;
	}

*/
		
//-->
</script>
</head>


<body onLoad="init()" >
<h1>Monitor System : Total Packets</h1>

<form method="post" name="monitor_port_form" target="mid">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table width="700" border="0">
<tr><td>
</td></tr>
<tr><td>
<div align="left">        
    <table width="700" border="0">        
    	<tr>
    		<td width="2%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    		</div></font></td>
    		<td width="15%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			{{ ShowMonitorPortSelect(show_port,show_type) | safe }}
    		</font></div></td> 
    		<td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			{{ ShowMonitorPacketSelect(show_port,show_type) | safe }}
    		</font></div></td>
    		<td width="63%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    			<!--input name="ResetSubmit" src="reset_button.gif" onclick="resetCnt(1)" onmouseover="document.body.style.cursor='hand'" onmouseout="document.body.style.cursor='default'" type="image"-->
    		</font></div></td>    		
    	</tr>
    	<tr> 
          
            <td colspan="4">
				<APPLET codebase="./" archive="ShowSwitchGraph.jar" code="ShowSwitchGraph.class" name="YC" width="690" height="160"> 
					{{ ShowMonitorShowGraphParameters(show_port,show_type) | safe }}
				</APPLET>           	
         	</td>
      	</tr>
		<tr><td colspan="4">      	
			<table style="width:700px" border="0">
			<tr>
				<td style="width:500px"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">[Format] Total Packets + Packets in previous 5 sec. interval</font></div></td>
				<td style="width:186px"><div align="right"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">update interval of 5 sec</font></div></td>
				<td style="width:14px"></td>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">  
			<table style="width:700px" border="0">
			<tr>
				<th style="width:60px"><div align="left"><font size="2" color="#ffffff" face="Arial, Helvetica, sans-serif, Marlett">Port</font></div></th>
				<th style="width:313px"><div align="left"><font size="2" color="#ffffff" face="Arial, Helvetica, sans-serif, Marlett">Tx</font></div></th>
				<th style="width:313px"><div align="left"><font size="2" color="#ffffff" face="Arial, Helvetica, sans-serif, Marlett">Rx</font></div></th>
				<th style="width:14px"></th>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		        <DIV style="OVERFLOW: auto; OVERFLOW-X: hidden;  HEIGHT: 160; WIDTH: 700; "><table width="680" border="0">

			    <td colspan="4"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
			</td>
					{{ ShowMonitorShowStaticParameters(show_port,show_type) | safe }}
		        </table></DIV></td>
		</tr>
   	</table>     		        
</div>   		
</td></tr>
</table>
</fieldset>
</form>
</body>
</html>
