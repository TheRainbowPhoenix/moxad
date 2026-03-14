<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(Overview)</script></title>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
if (!debug) {
	var wdata = [
			{ pppoe:'Enable',state:'Connect'},
			{ pppoe:'N/A',state:'Disconnect'},
			{ pppoe:'N/A',state:'Connect'}
		];		
	var wdata1 ={ backup:'Disable',ddns:'Disable',dos:'Enable',calive:'Enable',qos:'Enable'};	
	var wdata2 = [
			{ event:'Wan 2 Disable',time:'2009/10/15, 22:05:10'},	
			{ event:'LAN Disable',time:'2009/10/16,08:18:10'},	
			{ event:'DDNS Enable',time:'2009/10/17, 14:35:40'},	
			{ event:'DHCP Disable',time:'2009/10/17, 16:45:10'},	
			{ event:'Wan 1 Enable',time:'2009/10/19, 10:55:10'},	
			{ event:'Wan 2 Enable',time:'2009/10/19, 22:25:10'},	
			{ event:'Check alive Disable',time:'2009/10/20, 22:05:10'},	
			{ event:'DNS Disable',time:'2009/10/23, 23:18:20'},	
			{ event:'Cold Start Disable',time:'2009/10/25, 18:15:16'},	
			{ event:'Wan 1 IP Change',time:'2009/10/25, 23:17:32'}
		];		
}else{
	var wdata = [		
		<%net_websMainifance();%>
	];
	var wdata1 = <%net_websMainfun();%>;
	var wdata2 = [
		<%net_websMainevent();%>
	];		
	var wdata3 = [
		<%net_websIpset();%>	
	];
	var wdata4 = [
		<%net_websifanceName();%>	
	];
	var wdata5 = {
		<%net_webPortLink();%>	
	};
    var wdata6 =[ 
        <%net_websBridgeifance();%>
    ];

	<%net_Web_show_value('SRV_VCONF');%>	
	<%net_Web_show_value('SRV_IP_CLIENT');%>		
}
	
<!--#include file="lan_data"-->
var NoWAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
var NoMAC_PORT = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %>;
var SWITCH_ROUTER=(parseInt((NoWAN+1)) > parseInt(NoMAC_PORT));


function fnInit() {	
	var i, j, k, idx, length;
	length = wdata[0]; 
	var table;
	var row, cell;
	
	table = document.getElementById("iface");
	if(wdata4.length!=0){
		for(i = 0; i < wdata.length; i++ ){	
			row = table.getElementsByTagName("tr")[2+i];
			for(idx in wdata[0]){	
				cell = document.createElement("td");
				cell.innerHTML = wdata[i][idx];	
				row.appendChild(cell);
				row.style.Color = "black";
			}		
		}
	}else{
		if(SRV_IP_CLIENT[0].vid!="0"){
			for(i = 0; i < wdata.length; i++ ){	
				row = table.getElementsByTagName("tr")[2+i];
				for(idx in wdata[0]){	
					cell = document.createElement("td");
					cell.innerHTML = wdata[i][idx];	
					row.appendChild(cell);
					row.style.Color = "black";
				}		
			}
		}else{
			row = table.getElementsByTagName("tr")[2];
			for(idx in wdata[wdata.length-1]){	
				cell = document.createElement("td");
				cell.innerHTML = wdata[wdata.length-1][idx];	
				row.appendChild(cell);
				row.style.Color = "black";
			}		
		}
		
	}

	table = document.getElementById("revent");	
	for(i = 0; i < wdata2.length; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		for(idx in wdata2[0]){	
			cell = document.createElement("td");
			cell.innerHTML = wdata2[i][idx];
			row.appendChild(cell);
			row.style.Color = "black";
		}
		
		row.className=((i%2)-1)?"r1":"r2";
	}

	if(ProjectModel == MODEL_EDR_G903){
		document.getElementById("wan_2").innerHTML = wdata3[1].wtyp&8?'DMZ':'WAN 2';
	}
	
	
	table = document.getElementById("funstate");
	i = 0;
	for(idx in wdata1){	
		row = table.getElementsByTagName("tr")[1+i];
		i++;
		cell = document.createElement("td");
		cell.innerHTML = wdata1[idx];
		row.appendChild(cell);
		row.style.Color = "black";
	}		

	
}

function ShowIfs()
{
	var string;
	if(wdata4.length!=0){
		for(var i=0; i < wdata4.length; i++){
			document.write('<tr class=r1 align="left" id=iface1>');
			string = '<td width=100px>'+wdata4[i].id+'</td>';
			document.write(string);
			string = '<td width=100px>'+wdata4[i].name+'</td></tr>';
			document.write(string);
		}
	}else{
		if(SRV_IP_CLIENT[0].vid!="0"){			
					document.write('<tr class=r1 align="left" id=iface1>');
			string = '<td width=100px>WAN</td>';
					document.write(string);
					string = '<td width=100px>WAN</td></tr>';
					document.write(string);		
		}
        document.write('<tr class=r1 align="left" id=iface1>');
    	string = '<td width=100px>LAN</td>';
	   	document.write(string);
	    string = '<td width=100px>LAN</td></tr>';
    	document.write(string);
        document.write('<tr class=r1 align="left" id=iface1>');
	}
	
/*	if(ProjectModel == MODEL_EDR_G903){
		
		
		document.write('<tr class=r1 align="left" id=iface2>');
		document.write('<td width=100px>Port 2(Opt.)</td>');
		document.write('<td width=100px id=wan_2></td></tr>');
		
		document.write('<tr class=r1 align="left" id=iface3>');
		document.write('<td width=100px>Port 3(LAN)</td>');
		document.write('<td width=100px>LAN</td></tr>');
	}
	else{
		document.write('<tr class=r1 align="left" id=iface1>');
		document.write('<td width=100px>Port 1(WAN)</td>');
		document.write('<td width=100px>WAN</td></tr>');
		
		document.write('<tr class=r1 align="left" id=iface3>');
		document.write('<td width=100px>Port 2(LAN)</td>');
		document.write('<td width=100px>LAN</td></tr>');
	}*/
}

function ShowFunctions()
{
	if(ProjectModel == MODEL_EDR_G903){
		document.write('<tr class=r2 align="left" >');
		document.write('<td >Mode</td></tr>');
		
		document.write('<tr class=r1 align="left" >');
		document.write('<td width=200px>Wan 2 Backup Function</td></tr>');
		
		document.write('<tr class=r2 align="left" >');
		document.write('<td >DDNS</td></tr>');

		document.write('<tr class=r1 align="left" >');
		document.write('<td >DoS</td></tr>');

		document.write('<tr class=r2 align="left" >');
		document.write('<td >WAN Backup</td></tr>');

		document.write('<tr class=r1 align="left" >');
		document.write('<td >QoS</td></tr>');
	}
	else{
		if(!SWITCH_ROUTER){
		document.write('<tr class=r2 align="left" >');
		document.write('<td >Mode</td></tr>');
		}
		
		document.write('<tr class=r2 align="left" >');
		document.write('<td >DDNS</td></tr>');

		document.write('<tr class=r1 align="left" >');
		document.write('<td >DoS</td></tr>');
		if(!SWITCH_ROUTER){
		document.write('<tr class=r1 align="left" >');
		document.write('<td >QoS</td></tr>');
	}
}
}

</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(Overview)</script></h1>
<form id=myForm name=form1 method="GET">
<fieldset>
<table class=tf >
 <tr align=left>
  <td><script language="JavaScript" >fnbnB(Update_, 'onClick=location.reload()')</script></td>
  <td width=15></td></tr>
</table>

<table cellpadding=1 cellspacing=2>
    <tr valign="top">
        <td width=400px>
            <table cellpadding=1 cellspacing=2 id=iface>
                <tr align="center" class=r5>
                    <th id=ethstatus colspan=4 width=400px onclick=location.href="eth_status.asp" onMouseover="this.style.cursor='hand';"><script language="JavaScript">doc(Interface_);doc(" ");doc(Status_);</script>
                    &nbsp;&nbsp;&nbsp;<u><script language="JavaScript">doc(More_);</script></u></td>
                </tr>
                <tr class=r5 align="center">
                    <th width=100px><script language="JavaScript">doc(Interface_)</script></td>
                    <th width=100px><script language="JavaScript">doc(Mode_)</script></td>
                    <th width=100px><script language="JavaScript">doc(PPPoE_)</script></td>
                    <th width=100px><script language="JavaScript">doc(Status_)</script></td>
                </tr>
                <script language="JavaScript">ShowIfs()</script>
            </table>

            <table>
                <td height=65px></td>
            </table>

            <table cellpadding=1 cellspacing=2  id=funstate>
                <tr class=r5 align="center" >
                    <th width=200px><script language="JavaScript">doc(Functions_)</script></td>
                    <th width=200px><script language="JavaScript">doc(Current_);doc(" ");doc(Status_);</script>
                </tr>
                <script language="JavaScript">ShowFunctions()</script>
            </table>

            <table>
                <td height=65px></td>
            </table>

            <table cellpadding=1 cellspacing=2 id=revent class=tf>
                <tr align="center" class=r5>
                    <th id=logsetting colspan=2 width=400px onclick=location.href="show_log.asp?show_page=1&show_range=0&show_level=7&show_category=0" onMouseover="this.style.cursor='hand';"><script language="JavaScript">doc(Recent_log)</script>
                    &nbsp;&nbsp;&nbsp;<u><script language="JavaScript">doc(More_);</script></u></td>
                </tr>
                <tr align="center" class=r5>
                    <th width=300px><script language="JavaScript">doc(Event_)</script></td>
                    <th width=100px><script language="JavaScript">doc(Time_)</script></td>
                </tr>
            </table>
        </td>

        <td>
            <table>
    		    <div style="width:300px; height:750px; float:left;">
			        <iframe id="frm_left_panel" style="width:100%; height:100%;" src="main_page_panel.asp" scrolling="NO" name="panelPage" noresize marginwidth="0" marginheight="0" frameBorder="0"></iframe>
		        </div>
            </table>
        </td>
    </tr>
</table>
<p></p>
</fieldset>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
