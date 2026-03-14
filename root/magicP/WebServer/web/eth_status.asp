<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(ETH_STATUS)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
if (!debug) {
	var wdata = [
			{ mode:'PPP_OE',name:'PPP1', ip:'63.2.3.85', mac:'00:90:E8:00:02:01', rx_packets:'0', tx_packets:'12', rx_bytes:'0', tx_bytes:'2364', rx_errors:'0', tx_errors:'0'},
			{ mode:'PPP_OE',name:'PPP0', ip:'128.25.3.18', mac:'00:90:E8:00:02:02', rx_packets:'0', tx_packets:'12', rx_bytes:'0', tx_bytes:'2364', rx_errors:'0', tx_errors:'0'},
			{ mode:'DHCP_IP',name:'ETH2', ip:'192.168.3.202', mac:'00:90:E8:00:02:03', rx_packets:'2733', tx_packets:'1820', rx_bytes:'228480', tx_bytes:'569470', rx_errors:'0', tx_errors:'0'}
		];		
	var wdata1 = [
			{server:'192.168.1.91'},
			{server:'192.168.1.97'},
			{server:'168.95.1.1'}
	];
}else{
	var wdata = [		
		<%net_websEthStatus();%>
	];
	var wdata1 = [
		<%net_websDnsList();%>
	];
    var wdata2 = [
        <%net_websBridgeStatus();%>
    ]
    var wdata3 = {//data can be changed depend on situation
			<%net_webledset1();%>	
		};

	<%net_Web_show_value('SRV_IP_CLIENT');%>	
	var NoWAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
	var NoMAC_PORT = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %> ;
	var SWITCH_ROUTER=(parseInt((NoWAN+1)) > parseInt(NoMAC_PORT));		

}
	
<!--#include file="lan_data"-->
var lan_rowT=new Array(IP_Address, Tx_Packets, Tx_Bytes, Tx_Errors, Subnet_Mask, Rx_Packets, Rx_Bytes, Rx_Errors, Status_);
var lan_rowD=new Array("ip", "tx_packets", "tx_bytes", "rx_errors", "mask",  "rx_packets", "rx_bytes", "tx_errors", "status");
var brg_rowT=new Array(IP_Address, Tx_Packets, Tx_Bytes, Tx_Errors, Subnet_Mask, Rx_Packets, Rx_Bytes, Rx_Errors, Status_);
var brg_rowD=new Array("ip", "tx_packets", "tx_bytes", "rx_errors", "mask",  "rx_packets", "rx_bytes", "tx_errors", "status");

function show_lan_if(index){
	var table = document.getElementById("eth_vlan");
	var row, cell;	
	var i, j, k;	

	for(k=0;k<lan_rowT.length/4;k++){	
		row=table.insertRow(table.getElementsByTagName("tr").length);
		row.className = "r5";				
		for(j=k*4 ; j < lan_rowT.length&&j < (k+1)*4; j++){
			cell = document.createElement("td");
			cell.innerHTML = lan_rowT[j];	
			cell.style.cssText ='width:100px'
			row.appendChild(cell);
		}
		
		row=table.insertRow(table.getElementsByTagName("tr").length);
		row.className = "r2";					
		for(j=k*4 ; j < lan_rowD.length&&j < (k+1)*4; j++){
			cell = document.createElement("td");
			cell.innerHTML = wdata[index][lan_rowD[j]];		
			row.appendChild(cell);
		}
		
	}
}


function show_brg_if(){
	var table = document.getElementById("eth_brg");
	var row, cell;	
	var i, j, k;	

	for(k=0;k<lan_rowT.length/4;k++){	
		row=table.insertRow(table.getElementsByTagName("tr").length);
		row.className = "r5";				
		for(j=k*4 ; j < lan_rowT.length&&j < (k+1)*4; j++){
			cell = document.createElement("td");
			cell.innerHTML = brg_rowT[j];	
			cell.style.cssText ='width:100px'
			row.appendChild(cell);
		}
		
		row=table.insertRow(table.getElementsByTagName("tr").length);
		row.className = "r2";					
		for(j=k*4 ; j < brg_rowD.length&&j < (k+1)*4; j++){
			cell = document.createElement("td");
			cell.innerHTML = wdata2[0][brg_rowD[j]];		
			row.appendChild(cell);
		}
		
	}
}




function fn_chg_lan_if(data){
	var table = document.getElementById("eth_vlan");
	var i,row_len;

	row_len=table.getElementsByTagName("tr").length;
	for(i=0;i<row_len;i++){
		table.deleteRow(0);	
	}
	show_lan_if(data.value);
}


function fnInit() {	
	var i, j, k, length, idx, wan_cnt=0;
	var iface;
	length = wdata[0]; 				
	document.getElementById("eth2").style.display="none";
	document.getElementById("eth1").style.display="none";
	document.getElementById("eth0").style.display="none";
	for(i = 0; i < wdata.length; i++ ){
		iface = 'eth'+ (NoWAN-i>=0?NoWAN-i:i);
		if(SWITCH_ROUTER){
			if(i >= NoWAN){
				break;
			}else{
				if(wdata[i].if_name.substring(0, 3)!="WAN"){
					break;
				}
				if(SRV_IP_CLIENT[i].vid==0){
					document.getElementById(iface).style.display="none";
					continue;
				}else{
					document.getElementById(iface).style.display="";
					wan_cnt++;
				}
			}
		}
		
		document.getElementById(iface).style.width='600';
		idx = 0;		
		for(j in wdata[0]){								
			k = (parseInt(idx/4)+1)*2;			
			if(document.getElementById(iface).getElementsByTagName('tr')[k])
				document.getElementById(iface).getElementsByTagName('tr')[k].getElementsByTagName('td')[idx%4].innerHTML = wdata[i][j];
			idx++;
		}
	}
	idx = 0;		
	for(i = 0; i < wdata1.length; i++ ){						
		for(j in wdata1[0]){
			k = (parseInt(idx/4)+1)*2;		
			document.getElementById("DNS").getElementsByTagName('tr')[k].getElementsByTagName('td')[idx%4].innerHTML = wdata1[i][j];
			idx++;
			if(idx == 4)
				break;
		}
	}
	
	if(SWITCH_ROUTER){
		var newdata=new Array;
		var lanifsel = [];
		var i;
		
        if(wdata3.mode != 'bridge'){
		for(i=wan_cnt; i < wdata.length; i++){
			lanifsel[wdata[i].if_name] = new Array;
			lanifsel[wdata[i].if_name].value=i;
			lanifsel[wdata[i].if_name].text=wdata[i].if_name;
		}
		newdata[0]="LAN&nbsp;&nbsp";
		newdata[0]+=iGenSel4Str('lan', 'lan', lanifsel,"fn_chg_lan_if");
		tableaddRow("show_lan", 0, newdata, "left");
		document.getElementById("show_lan").getElementsByTagName('tr')[0].className="r0"
		
		document.getElementById("eth0").style.display="none";
		document.getElementById("eth_vlan").style.display="";		
		show_lan_if(wan_cnt);		
        }

        if(wdata2.length !=0){
        newdata[0]="Bridge&nbsp;&nbsp";
    	tableaddRow("show_brg", 0, newdata, "left");
    	document.getElementById("show_brg").getElementsByTagName('tr')[0].className="r0"
		
		document.getElementById("eth0").style.display="none";
		document.getElementById("eth_vlan").style.display="";		
		show_brg_if();	
        }




	}else{
		document.getElementById("eth_vlan").style.display="none";		
	}

	if(ProjectModel == MODEL_EDR_G903){
		document.getElementById("eth2").style.display="";
	}
	else{
		document.getElementById("eth2").style.display="none";
	}
	for(i=0;i<SRV_IP_CLIENT.length;i++)
	{
	    if(SRV_IP_CLIENT[i].enable==0)
	    {   k=i+1;
		    document.getElementById('eth'+k).style.display="none";
	    }
	}	
}


function stopSubmit()
{
	return false;
}

function ShowWan2()
{
	if(ProjectModel == MODEL_EDR_G903)
		document.write('2');
}

</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>

<p><table class=tf>
 <tr align=left>
  <td><script language="JavaScript">fnbnB(Update_, 'onClick=location.reload()')</script></td>
  <td width=15></td></tr>
</table></p>

<table cellpadding=1 cellspacing=2 id="eth2" >
<tr class=r0 width=400px>
 <td colspan=4><script language="JavaScript">doc(WAN_)</script>1</td></tr>
 <tr class=r5 align="center">
  <td><script language="JavaScript">doc(Connect_Type)</script></td>
  <td><script language="JavaScript">doc(IP_Address)</script></td>
  <td><script language="JavaScript">doc(Subnet_Mask)</script></td>
  <td><script language="JavaScript">doc(MAC_Address)</script></td>
 </tr> 
 <tr class=r2 align="center">
  <td></td>
  <td></td>
  <td></td>
  <td></td>
<tr class=r5 align="center">
  <td><script language="JavaScript">doc(PPTP_);doc(" ");doc(Enable_);</script></td> 
  <td><script language="JavaScript">doc(PPTP_);doc(" ");doc(IP_Address);</script></td> 
  <td><script language="JavaScript">doc(PPPoE_)</script></td> 
  <td><script language="JavaScript">doc(Status_)</script></td> 
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
 <tr class=r5 align="center">
  <td width=100px><script language="JavaScript">doc(Rx_Packets)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Packets)</script></td> 
  <td width=100px><script language="JavaScript">doc(Rx_Bytes)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Bytes)</script></td> 
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
 <tr class=r5 align="center">
  <td width=100px><script language="JavaScript">doc(Rx_Errors)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Errors)</script></td>
  <td width=100px><script language="JavaScript">doc(Gateway_)</script></td>
  <td width=100px><script language="JavaScript">doc(PPTP_Gateway_)</script></td>
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
</table>

<p>
<table cellpadding=1 cellspacing=2 id="eth1" style="width:600px;">
<tr class=r0>
 <td colspan=4><script language="JavaScript">doc(WAN_)</script><script language="JavaScript">ShowWan2()</script></td></tr>
 <tr class=r5 align="center">
  <td><script language="JavaScript">doc(Connect_Type)</script></td>
  <td><script language="JavaScript">doc(IP_Address)</script></td>
  <td><script language="JavaScript">doc(Subnet_Mask)</script></td>
  <td><script language="JavaScript">doc(MAC_Address)</script></td>
 </tr> 
 <tr class=r2 align="center">
  <td></td>
  <td></td>
  <td></td>
  <td></td>
<tr class=r5 align="center">
  <td><script language="JavaScript">doc(PPTP_);doc(" ");doc(Enable_);</script></td> 
  <td><script language="JavaScript">doc(PPTP_);doc(" ");doc(IP_Address);</script></td> 
  <td><script language="JavaScript">doc(PPPoE_)</script></td> 
  <td><script language="JavaScript">doc(Status_)</script></td> 
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
 <tr class=r5 align="center">
  <td width=100px><script language="JavaScript">doc(Rx_Packets)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Packets)</script></td> 
  <td width=100px><script language="JavaScript">doc(Rx_Bytes)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Bytes)</script></td> 
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
 <tr class=r5 align="center">
  <td width=100px><script language="JavaScript">doc(Rx_Errors)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Errors)</script></td>
  <td width=100px><script language="JavaScript">doc(Gateway_)</script></td>
  <td width=100px><script language="JavaScript">doc(PPTP_Gateway_)</script></td>
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
</table>
</p>
<p>
<table cellpadding=1 cellspacing=2 id="eth0" style="width:600px;">
<tr class=r0>
 <td colspan=4><script language="JavaScript">doc(LAN_)</script></td></tr>
 <tr class=r5 align="center">
  <td><script language="JavaScript">doc(Connect_Type)</script></td>
  <td><script language="JavaScript">doc(IP_Address)</script></td>
  <td><script language="JavaScript">doc(Subnet_Mask)</script></td>
  <td><script language="JavaScript">doc(MAC_Address)</script></td>
 </tr> 
 <tr class=r1 align="center">
  <td></td>
  <td></td>
  <td></td>
  <td></td>
<tr class=r5 align="center">
  <td><script language="JavaScript">doc(PPTP_);doc(" ");doc(Enable_);</script></td> 
  <td><script language="JavaScript">doc(PPTP_);doc(" ");doc(IP_Address);</script></td> 
  <td><script language="JavaScript">doc(PPPoE_)</script></td> 
  <td><script language="JavaScript">doc(Status_)</script></td> 
 </tr>  
 <tr class=r1 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
 <tr class=r5 align="center">
  <td width=100px><script language="JavaScript">doc(Rx_Packets)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Packets)</script></td> 
  <td width=100px><script language="JavaScript">doc(Rx_Bytes)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Bytes)</script></td> 
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
 <tr class=r5 align="center">
  <td width=100px><script language="JavaScript">doc(Rx_Errors)</script></td> 
  <td width=100px><script language="JavaScript">doc(Tx_Errors)</script></td>
  <td width=100px><script language="JavaScript">doc(Gateway_)</script></td> 
  <td width=100px><script language="JavaScript">doc(PPTP_Gateway_)</script></td>
 </tr>  
 <tr class=r2 align="center"> 
  <td></td>
  <td></td>
  <td></td>
  <td></td>
 </tr>
</table>
</p>

<p>
<table style="width:600px;" id="show_lan">
</table>
<table cellpadding=1 cellspacing=2 id="eth_vlan" style="width:600px;">
</table>
<p></p>
<table style="width:600px;" id="show_brg">
</table>
<table cellpadding=1 cellspacing=2 id="eth_brg" style="width:600px;">
</table>

</p>
<p>
<table cellpadding=1 cellspacing=2 id="DNS" style="width:600px;">
<tr class=r0>
 <td colspan=4><script language="JavaScript">doc(DNS_Server_List)</script></td></tr>
 <tr class=r5 align="center">
  <td><script language="JavaScript">doc(Server_)</script>1</td>
  <td><script language="JavaScript">doc(Server_)</script>2</td>
  <td><script language="JavaScript">doc(Server_)</script>3</td>
 </tr> 
 <tr class=r1 align="center">
  <td></td>
  <td></td>
  <td></td>
  </tr>
</table> 
</p>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
