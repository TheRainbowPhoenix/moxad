<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie(); 
checkCookie();
var Mode2Access=<% net_Web_GetMode_WriteValue(); %>;

if (!debug) {
	var wdata = [
		{ stat:'1', stat0:'1', stat1:'0', stat2:'0', stat3:'0', stat4:'0', stat5:'0', stat6:'0', stat7:'0', stat8:'0', stat9:'0', stat10:'0', ip1:'', mask1:'', ip2:'1.1.1.1', mask2:'2.2.2.2', ip3:'', mask3:'', ip4:'', mask4:'', ip5:'', mask5:'', ip6:'', mask6:'', ip7:'', mask7:'', ip8:'', mask8:'', ip9:'', mask9:'', ip10:'', mask10:''}
	]
	var CheckConfirm = [ <% net_Web_Confirm_WriteValue(); %> ];
}
else{
	var wdata = [ <% net_Web_Access_WriteValue(); %> ];
	var CheckConfirm = [ <% net_Web_Confirm_WriteValue(); %> ];
}

var entryNUM=0;
<!--#include file="emalert_data"-->
var wtype = { stat:3, stat0:3, stat1:3, stat2:3, stat3:3, stat4:3, stat5:3, stat6:3, stat7:3, stat8:3, stat9:3, stat10:3, ip1:5, mask1:5, ip2:5, mask2:5, ip3:5, mask3:5, ip4:5, mask4:5, ip5:5, mask5:5, ip6:5, mask6:5, ip7:5, mask7:5, ip8:5, mask8:5, ip9:5, mask9:5, ip10:5, mask10:5, logEnable:2, logLevel:2, logFlash:3, logSyslog:3, logTrap:3};

var log_level = [ {value:'0', text:'<0> Emergency'},
					{value:'1', text:'<1> Alert'},
					{value:'2', text:'<2> Critical'},
					{value:'3', text:'<3> Error'},
					{value:'4', text:'<4> Warning'},
					{value:'5', text:'<5> Notice'},
					{value:'6', text:'<6> Informational'},
					{value:'7', text:'<7> Debug'}]

var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

var cur_if;
 
var myForm;
function fnInit(row) {
	if(Mode2Access == 1)
		document.getElementById("lan_table").style.display="none";
	
	myForm = document.getElementById('myForm');
	EditRow(row);
	SelectRow(wdata[0].stat);
}


function EditRow(row) {

	fnLoadForm(myForm, wdata[row], wtype);
	//ChgColor('tri', wdata.length, row);
}

function Activate(form)
{	
	/* stat_temp is used to save the enabling of each acceiable ip. */
	var stat_temp=[0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

	if(AccessLikeCheckFormat(form)==1)
		return;
	
	document.getElementById("btnU").disabled = "true";

	if(form.stat.checked==true)
		wdata[0].stat=1;
	else
		wdata[0].stat=0;

	if(form.stat0.checked==true)
		wdata[0].stat0=1;
	else
		wdata[0].stat0=0;

	if(form.stat1.checked==true)
		wdata[0].stat1=1;
	else
		wdata[0].stat1=0;
	stat_temp[0] = wdata[0].stat1;

	if(form.stat2.checked==true)
		wdata[0].stat2=1;
	else
		wdata[0].stat2=0;
	stat_temp[1] = wdata[0].stat2;

	if(form.stat3.checked==true)
		wdata[0].stat3=1;
	else
		wdata[0].stat3=0;
	stat_temp[2] = wdata[0].stat3;

	if(form.stat4.checked==true)
		wdata[0].stat4=1;
	else
		wdata[0].stat4=0;
	stat_temp[3] = wdata[0].stat4;
	
	if(form.stat5.checked==true)
		wdata[0].stat5=1;
	else
		wdata[0].stat5=0;
	stat_temp[4] = wdata[0].stat5;

	if(form.stat6.checked==true)
		wdata[0].stat6=1;
	else
		wdata[0].stat6=0;
	stat_temp[5] = wdata[0].stat6;
	
	if(form.stat7.checked==true)
		wdata[0].stat7=1;
	else
		wdata[0].stat7=0;
	stat_temp[6] = wdata[0].stat7;

	if(form.stat8.checked==true)
		wdata[0].stat8=1;
	else
		wdata[0].stat8=0;
	stat_temp[7] = wdata[0].stat8;

	if(form.stat9.checked==true)
		wdata[0].stat9=1;
	else
		wdata[0].stat9=0;
	stat_temp[8] = wdata[0].stat9;

	if(form.stat10.checked==true)
		wdata[0].stat10=1;
	else
		wdata[0].stat10=0;
	stat_temp[9] = wdata[0].stat10;

	/* when accessible ip is enabled and ignoring lan*/
	if(form.stat.checked == true && form.stat0.checked == false){
		var i;
		var total_enabled = 0;

		/* to check if there is at least one is enabled in 10 entries of accessible ip */
		for(i=0; i<10; i++){
			if(stat_temp[i] > 0)
				total_enabled++;
		}

		/* if there is none allowed ip can access the EDR, we do double confirm to check user's will. */
		if(total_enabled == 0){
			var YesIDo = confirm("Warning: Local SERIAL CONSOLE will be THE ONLY access to this unit");

			if(YesIDo != true){
				document.getElementById("btnU").disabled = "";
				return;
			}
		}

		
	}
	
	wdata[0].ip1 = form.ip1.value;
	wdata[0].ip2 = form.ip2.value;
	wdata[0].ip3 = form.ip3.value;
	wdata[0].ip4 = form.ip4.value;
	wdata[0].ip5 = form.ip5.value;
	wdata[0].ip6 = form.ip6.value;
	wdata[0].ip7 = form.ip7.value;
	wdata[0].ip8 = form.ip8.value;
	wdata[0].ip9 = form.ip9.value;
	wdata[0].ip10 = form.ip10.value;
	wdata[0].mask1 = form.mask1.value;
	wdata[0].mask2 = form.mask2.value;
	wdata[0].mask3 = form.mask3.value;
	wdata[0].mask4 = form.mask4.value;
	wdata[0].mask5 = form.mask5.value;
	wdata[0].mask6 = form.mask6.value;
	wdata[0].mask7 = form.mask7.value;
	wdata[0].mask8 = form.mask8.value;
	wdata[0].mask9 = form.mask9.value;
	wdata[0].mask10 = form.mask10.value;

	wdata[0].logEnable=form.logEnable.value;
	wdata[0].logLevel=form.logLevel.value;

	form.ipTemp.value = form.ipTemp.value + wdata[0].stat + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat0 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat1 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat2 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat3 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat4 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat5 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat6 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat7 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat8 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat9 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].stat10 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip1 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask1 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip2 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask2 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip3 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask3 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip4 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask4 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip5 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask5 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip6 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask6 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip7 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask7 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip8 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask8 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip9 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask9 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].ip10 + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].mask10 + "+";
	form.ipTemp.value = form.ipTemp.value + CheckConfirm[0].stat3 + "+";

	form.ipTemp.value = form.ipTemp.value + wdata[0].logEnable + "+";
	form.ipTemp.value = form.ipTemp.value + wdata[0].logLevel + "+";

	if(form.logFlash.checked == true )
		form.ipTemp.value = form.ipTemp.value + "1" + "+";
	else
		form.ipTemp.value = form.ipTemp.value + "0" + "+";

	if(form.logSyslog.checked == true )
		form.ipTemp.value = form.ipTemp.value + "1" + "+";
	else
		form.ipTemp.value = form.ipTemp.value + "0" + "+";

	if(form.logTrap.checked == true )
		form.ipTemp.value = form.ipTemp.value + "1" + "+";
	else
		form.ipTemp.value = form.ipTemp.value + "0" + "+";

	form.submit();
}

function AccessLikeCheckFormat(form)
{
	var error=0;
	
	// ip 1 & mask 1
	if(form.stat1.checked==false){
		if(!isNull(form.ip1.value)){
			if(!IsIpOK(form.ip1, "IP 1"))
				error=1;
		}
		if(!isNull(form.mask1.value)){
			if(!NetMaskIsOK(form.mask1, "MASK 1"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip1, "IP 1") || !NetMaskIsOK(form.mask1, "MASK 1"))
			error=1;
	}

	// ip 2 & mask 2
	if(form.stat2.checked==false){
		if(!isNull(form.ip2.value)){
			if(!IsIpOK(form.ip2, "IP 2"))
				error=1;
		}
		if(!isNull(form.mask2.value)){
			if(!NetMaskIsOK(form.mask2, "MASK 2"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip2, "IP 2") || !NetMaskIsOK(form.mask2, "MASK 2"))
			error=1;
	}

	// ip 3 & mask 3
	if(form.stat3.checked==false){
		if(!isNull(form.ip3.value)){
			if(!IsIpOK(form.ip3, "IP 3"))
				error=1;
		}
		if(!isNull(form.mask3.value)){
			if(!NetMaskIsOK(form.mask3, "MASK 3"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip3, "IP 3") || !NetMaskIsOK(form.mask3, "MASK 3"))
			error=1;
	}

	// ip 4 & mask 4
	if(form.stat4.checked==false){
		if(!isNull(form.ip4.value)){
			if(!IsIpOK(form.ip4, "IP 4"))
				error=1;
		}
		if(!isNull(form.mask4.value)){
			if(!NetMaskIsOK(form.mask4, "MASK 4"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip4, "IP 4") || !NetMaskIsOK(form.mask4, "MASK 4"))
			error=1;
	}

	// ip 5 & mask 5
	if(form.stat5.checked==false){
		if(!isNull(form.ip5.value)){
			if(!IsIpOK(form.ip5, "IP 5"))
				error=1;
		}
		if(!isNull(form.mask5.value)){
			if(!NetMaskIsOK(form.mask5, "MASK 5"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip5, "IP 5") || !NetMaskIsOK(form.mask5, "MASK 5"))
			error=1;
	}

	// ip 6 & mask 6
	if(form.stat6.checked==false){
		if(!isNull(form.ip6.value)){
			if(!IsIpOK(form.ip6, "IP 6"))
				error=1;
		}
		if(!isNull(form.mask6.value)){
			if(!NetMaskIsOK(form.mask6, "MASK 6"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip6, "IP 6") || !NetMaskIsOK(form.mask6, "MASK 6"))
			error=1;
	}

	// ip 7 & mask 7
	if(form.stat7.checked==false){
		if(!isNull(form.ip7.value)){
			if(!IsIpOK(form.ip7, "IP 7"))
				error=1;
		}
		if(!isNull(form.mask7.value)){
			if(!NetMaskIsOK(form.mask7, "MASK 7"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip7, "IP 7") || !NetMaskIsOK(form.mask7, "MASK 7"))
			error=1;
	}

	// ip 8 & mask 8
	if(form.stat8.checked==false){
		if(!isNull(form.ip8.value)){
			if(!IsIpOK(form.ip8, "IP 8"))
				error=1;
		}
		if(!isNull(form.mask8.value)){
			if(!NetMaskIsOK(form.mask8, "MASK 8"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip8, "IP 8") || !NetMaskIsOK(form.mask8, "MASK 8"))
			error=1;
	}

	// ip 9 & mask 9
	if(form.stat9.checked==false){
		if(!isNull(form.ip9.value)){
			if(!IsIpOK(form.ip9, "IP 9"))
				error=1;
		}
		if(!isNull(form.mask9.value)){
			if(!NetMaskIsOK(form.mask9, "MASK 9"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip9, "IP 9") || !NetMaskIsOK(form.mask9, "MASK 9"))
			error=1;
	}

	// ip 10 & mask 10
	if(form.stat10.checked==false){
		if(!isNull(form.ip10.value)){
			if(!IsIpOK(form.ip10, "IP 10"))
				error=1;
		}
		if(!isNull(form.mask10.value)){
			if(!NetMaskIsOK(form.mask10, "MASK 10"))
				error=1;
		}
	}
	else{
		if(!IsIpOK(form.ip10, "IP 10") || !NetMaskIsOK(form.mask10, "MASK 10"))
			error=1;
	}
	
	return error;
}

function SelectRow(EnableStat)
{
	if(EnableStat==true){
		document.getElementById("stat0").disabled="";
		document.getElementById("stat1").disabled="";
		document.getElementById("stat2").disabled="";
		document.getElementById("stat3").disabled="";
		document.getElementById("stat4").disabled="";
		document.getElementById("stat5").disabled="";
		document.getElementById("stat6").disabled="";
		document.getElementById("stat7").disabled="";
		document.getElementById("stat8").disabled="";
		document.getElementById("stat9").disabled="";
		document.getElementById("stat10").disabled="";
		document.getElementById("ip1").disabled="";
		document.getElementById("ip2").disabled="";
		document.getElementById("ip3").disabled="";
		document.getElementById("ip4").disabled="";
		document.getElementById("ip5").disabled="";
		document.getElementById("ip6").disabled="";
		document.getElementById("ip7").disabled="";
		document.getElementById("ip8").disabled="";
		document.getElementById("ip9").disabled="";
		document.getElementById("ip10").disabled="";
		document.getElementById("mask1").disabled="";
		document.getElementById("mask2").disabled="";
		document.getElementById("mask3").disabled="";
		document.getElementById("mask4").disabled="";
		document.getElementById("mask5").disabled="";
		document.getElementById("mask6").disabled="";
		document.getElementById("mask7").disabled="";
		document.getElementById("mask8").disabled="";
		document.getElementById("mask9").disabled="";
		document.getElementById("mask10").disabled="";
	}
	else{
		document.getElementById("stat0").disabled="true";
		document.getElementById("stat1").disabled="true";
		document.getElementById("stat2").disabled="true";
		document.getElementById("stat3").disabled="true";
		document.getElementById("stat4").disabled="true";
		document.getElementById("stat5").disabled="true";
		document.getElementById("stat6").disabled="true";
		document.getElementById("stat7").disabled="true";
		document.getElementById("stat8").disabled="true";
		document.getElementById("stat9").disabled="true";
		document.getElementById("stat10").disabled="true";
		document.getElementById("ip1").disabled="true";
		document.getElementById("ip2").disabled="true";
		document.getElementById("ip3").disabled="true";
		document.getElementById("ip4").disabled="true";
		document.getElementById("ip5").disabled="true";
		document.getElementById("ip6").disabled="true";
		document.getElementById("ip7").disabled="true";
		document.getElementById("ip8").disabled="true";
		document.getElementById("ip9").disabled="true";
		document.getElementById("ip10").disabled="true";
		document.getElementById("mask1").disabled="true";
		document.getElementById("mask2").disabled="true";
		document.getElementById("mask3").disabled="true";
		document.getElementById("mask4").disabled="true";
		document.getElementById("mask5").disabled="true";
		document.getElementById("mask6").disabled="true";
		document.getElementById("mask7").disabled="true";
		document.getElementById("mask8").disabled="true";
		document.getElementById("mask9").disabled="true";
		document.getElementById("mask10").disabled="true";
	}
}

</script>
<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(ACCESSSIBLE_SETTING)</script></h1>
<fieldset>
<form name="qwe" id="myForm" method="POST" action="/goform/net_WebAccessGetValue">
<% net_Web_csrf_Token(); %>	
<input type="hidden" name="ipTemp" id="ipTemp" value="" />

<div align="center">
	<table width="100%" align="center" border="0">
		<tr >			
			<td><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<table width="100%" align="center" border="0"> 
    				<tr > 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat" name="enable_checkbox" onClick="SelectRow(this.checked)" >
            					</font>
							</div>
            			</td>
            			<td width="90%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<script language="JavaScript">doc(ACCESSSIBLE_ENABLE_DESCRIBE)</script>
            					</font>
							</div>
            			</td>           	
        			</tr>  
        		</table>
			</td>            	
			<td width="20%">
				<div align="left">
					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            		</font>
            	</div>
            </td>            	
		</tr>
		<tr >			
        	<td><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<table width="100%" align="center" border="0" id="lan_table"> 
    				<tr > 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat0" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="70%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<script language="JavaScript">doc(ACCESSSIBLE_LAN)</script>
            					</font>
							</div>
            			</td>
            			<td width="40%">
            				
						</td>            	
            			<td width="40%">
          
						</td>
        			</tr>  
        		</table>
    			<table width="100%" align="center" border="0"> 
    		
    				<tr class="r0"> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<script language="JavaScript">doc(Enable_)</script>
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<script language="JavaScript">doc(Index_)</script>
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<script language="JavaScript">doc(IP_Address)</script>
            					</font>
							</div>
            			</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
									<script language="JavaScript">doc(Netmask)</script>
								</font>
							</div>
						</td>
        			</tr>
        		</table>

        		<table width="100%" align="center" border="0">
        		
    				<tr > 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat1" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						1
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip1" name="ip_text1" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask1" name="netmask_text1" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>  

					<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat2" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						2
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip2" name="ip_text2" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask2" name="netmask_text2" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>  

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat3" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						3
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip3" name="ip_text3" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask3" name="netmask_text3" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>  

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat4" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						4
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip4" name="ip_text4" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask4" name="netmask_text4" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>  

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat5" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						5
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip5" name="ip_text5" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask5" name="netmask_text5" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr> 

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat6" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						6
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip6" name="ip_text6" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask6" name="netmask_text6" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat7" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						7
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip7" name="ip_text7" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask7" name="netmask_text7" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr> 

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat8" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						8
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip8" name="ip_text8" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask8" name="netmask_text8" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>  

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat9" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						9
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip9" name="ip_text9" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask9" name="netmask_text9" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>  

        			<tr> 
    					<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="checkbox" id="stat10" name="enable_checkbox" >
            					</font>
							</div>
            			</td>
            			<td width="10%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						10
            					</font>
							</div>
            			</td>
            			<td width="25%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            						<input type="text" id="ip10" name="ip_text10" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>            	
            			<td width="55%">
            				<div align="left">
            					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
									<input type="text" id="mask10" name="netmask_text10" size="15" maxlength="15" value="">
								</font>
							</div>
						</td>
        			</tr>  
        			             	
   				</table>
   			</font>
   		</div>
   	</td>
	<td width="20%">
		<div align="left">
			<font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            </font>
        </div>
    </td>
	</tr>	
</table> 
</br>
<table align="left">
	<tr>
		<td>
			<table style="width:300px;" align="left">
				<tr class=r0>
					 <td colspan=2><script language="JavaScript">doc(TRUST_ACCESS_LOG_ENABLE_)</script></td>
				</tr>	
			</table>
		<td>
	</tr>
	<tr>
		<td>
			<table width="700px" align="left" border="0">
				<tr align="left">			
			    
					<td style="width:70px;">
						<script language="JavaScript">doc(LOG_ENABLE_)</script><br/>
					</td>
					<td style="width:100px;" align="left" valign="center">
						<script language="JavaScript">iGenSel2('logEnable', 'logEnable', wtyp0)</script>
					</td>
					<td style="width:10px;">
						<script language="JavaScript">doc(Severity_)</script><br/>
					</td>
					<td style="width:150px;" align="left" valign="center">
						<script language="JavaScript">iGenSel2('logLevel', 'logLevel', log_level)</script>
					</td>
					<td style="width:10px;">
						<script language="JavaScript">doc(MOXA_FLASH_)</script><br/>
					</td>
					<td style="width:40px;" align="left" valign="center">
						<input type="checkbox" id="logFlash" name="logFlash">
					</td>
					<td style="width:10px;">
						<script language="JavaScript">doc(SYSLOG_SERVER_)</script><br/>
					</td>
					<td style="width:40px;" align="left" valign="center">
						<input type="checkbox" id="logSyslog" name="logSyslog">
					</td>
					<td style="width:70px;">
						<script language="JavaScript">doc(SNMP_TRAP_)</script><br/>
					</td>
					<td style="width:40px;" align="left" valign="center">
						<input type="checkbox" id="logTrap" name="logTrap">
					</td>
			  
				</tr>
			</table>
		</td>
	</tr>
</table>	

</div> 
</form> 

</br>
</br>
</br>
</br>
</br>
</br>

<table align="left" border="0">
	<tr>
      	<td><script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(myForm)', 'btnU')</script></td>
	</tr>
</table>

</fieldset>
</body></html>


