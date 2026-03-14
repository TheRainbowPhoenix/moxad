<html>
<head>
{{ net_Web_file_include() | safe }}


<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = [
		{ stat1:0, stat2:0, stat3:0, stat4:1, stat5:1, stat6:1, stat7:0, stat8:0, stat9:1, stat10:0, stat11:1, stat12:1, port_limit:1, port_burst:4, icmp_limit:1, icmp_burst:500, syn_limit:1, syn_burst:100}
	]
}
else{
	var wdata = [ {{ net_Web_IPT_DoS_WriteValue() | safe }} ]
}

var entryNUM=0;
{% include "emalert_data" ignore missing %}
var wtype = { stat1:3, stat2:3, stat3:3, stat4:3, stat5:3, stat6:3, stat7:3, stat8:3, stat9:3, stat10:3, stat11:3, stat12:3, port_limit:4, port_burst:4, icmp_limit:4, icmp_burst:4, syn_limit:4, syn_burst:4, arp_limit:4, arp_burst:4, logEnable:2, logLevel:2, logFlash:3, logSyslog:3, logTrap:3 };

var filter_level = [{value:'0', text:'<0> Emergency'},
					{value:'1', text:'<1> Alert'},
					{value:'2', text:'<2> Critical'},
					{value:'3', text:'<3> Error'},
					{value:'4', text:'<4> Warning'},
					{value:'5', text:'<5> Notice'},
					{value:'6', text:'<6> Informational'},
					{value:'7', text:'<7> Debug'}];


var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

var cur_if;
 
var myForm;
function fnInit(row) {
	myForm = document.getElementById('myForm');
	EditRow(row);
	if(wdata[0].stat1==true){
		document.getElementById("port_limit").disabled="";
		document.getElementById("port_burst").disabled="";
	}
	else{	
		document.getElementById("port_limit").disabled="true";
		document.getElementById("port_burst").disabled="true";
	}
	if(wdata[0].stat10==true){
		document.getElementById("icmp_limit").disabled="";
		document.getElementById("icmp_burst").disabled="";
	}
	else{	
		document.getElementById("icmp_limit").disabled="true";
		document.getElementById("icmp_burst").disabled="true";
	}
	if(wdata[0].stat11==true){
		document.getElementById("syn_limit").disabled="";
		document.getElementById("syn_burst").disabled="";
	}
	else{	
		document.getElementById("syn_limit").disabled="true";
		document.getElementById("syn_burst").disabled="true";
	}
	if(wdata[0].stat12==true){
		document.getElementById("arp_limit").disabled="";
		document.getElementById("arp_burst").disabled="";
	}
	else{	
		document.getElementById("arp_limit").disabled="true";
		document.getElementById("arp_burst").disabled="true";
	}

}

function EditRow(row) {

	fnLoadForm(myForm, wdata[row], wtype);
	//ChgColor('tri', wdata.length, row);
}

function Activate(form)
{	
	if(DoSLikeCheckFormat(form)==1)
		return;

	document.getElementById("btnU").disabled="true";
	
	wdata[0].stat1=0;
	
	if(form.stat2.checked==true)
		wdata[0].stat2=1;
	else
		wdata[0].stat2=0;
	
	if(form.stat3.checked==true)
		wdata[0].stat3=1;
	else
		wdata[0].stat3=0;

	if(form.stat4.checked==true)
		wdata[0].stat4=1;
	else
		wdata[0].stat4=0;
	
	if(form.stat5.checked==true)
		wdata[0].stat5=1;
	else
		wdata[0].stat5=0;
	
	if(form.stat6.checked==true)
		wdata[0].stat6=1;
	else
		wdata[0].stat6=0;
	
	if(form.stat7.checked==true)
		wdata[0].stat7=1;
	else
		wdata[0].stat7=0;
	
	if(form.stat8.checked==true)
		wdata[0].stat8=1;
	else
		wdata[0].stat8=0;
	
	if(form.stat9.checked==true)
		wdata[0].stat9=1;
	else
	wdata[0].stat9=0;
	
	if(form.stat10.checked==true)
		wdata[0].stat10=1;
	else
		wdata[0].stat10=0;
	
	if(form.stat11.checked==true)
		wdata[0].stat11=1;
	else
		wdata[0].stat11=0;

	if(form.stat12.checked==true)
		wdata[0].stat12=1;
	else
		wdata[0].stat12=0;

	wdata[0].port_limit = 0
	wdata[0].port_burst = 0;
	wdata[0].icmp_limit = form.icmp_limit.value;
	wdata[0].icmp_burst = form.icmp_limit.value;
	wdata[0].syn_limit = form.syn_limit.value;
	wdata[0].syn_burst = form.syn_limit.value;
	wdata[0].arp_limit = form.arp_limit.value;
	wdata[0].arp_burst = form.arp_limit.value;

	wdata[0].logEnable=form.logEnable.value;
	
	wdata[0].logLevel=form.logLevel.value;

	if(form.logFlash.checked==true)
		wdata[0].logFlash=1;
	else
		wdata[0].logFlash=0;
	
	if(form.logSyslog.checked==true)
		wdata[0].logSyslog=1;
	else
		wdata[0].logSyslog=0;

	if(form.logTrap.checked==true)
		wdata[0].logTrap=1;
	else
		wdata[0].logTrap=0;

	form.dosTemp.value = form.dosTemp.value + wdata[0].stat1 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat2 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat3 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat4 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat5 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat6 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat7 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat8 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat9 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat10 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat11 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].stat12 + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].port_limit + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].port_burst + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].icmp_limit + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].icmp_burst + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].syn_limit + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].syn_burst + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].arp_limit + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].arp_burst + "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].logEnable+ "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].logLevel+ "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].logFlash+ "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].logSyslog+ "+";
	form.dosTemp.value = form.dosTemp.value + wdata[0].logTrap+ "+";

	form.submit();	
}

function DoSLikeCheckFormat(form)
{
	var error=0;
	
	if(!isNumber(form.icmp_limit.value)){
		alert(MsgHead[0]+"ICMP-Death"+MsgStrs[8]) ;
		error=1;
	}
	else{
		if(form.icmp_limit.value>4000 || form.icmp_limit.value<1){
			alert(MsgHead[0]+"ICMP-Death"+MsgStrs[8]) ;
			error=1;
		}
	}

	if(!isNumber(form.syn_limit.value)){
		alert(MsgHead[0]+"SYN-Flood "+MsgStrs[8]) ;
		error=1;
	}
	else{
		if(form.syn_limit.value > 4000 || form.syn_limit.value < 1){
			alert(MsgHead[0]+"SYN-Flood "+MsgStrs[8]) ;
			error=1;
		}
	}

	if(!isNumber(form.arp_limit.value)){
		alert(MsgHead[0]+"ARP-Flood "+MsgStrs[8]) ;
		error=1;
	}
	else{
		if(form.arp_limit.value > 4000 || form.arp_limit.value < 1){
			alert(MsgHead[0]+"ARP-Flood "+MsgStrs[8]) ;
			error=1;
		}
	}
	
	return error;
}

function PortState(CheckStat)
{
	if(CheckStat==true){
		document.getElementById("port_limit").disabled="";
		document.getElementById("port_burst").disabled="";
	}
	else{	
		document.getElementById("port_limit").disabled="true";
		document.getElementById("port_burst").disabled="true";
	}
}

function ICMPState(CheckStat)
{
	if(CheckStat==true){
		document.getElementById("icmp_limit").disabled="";
		document.getElementById("icmp_burst").disabled="";
	}
	else{	
		document.getElementById("icmp_limit").disabled="true";
		document.getElementById("icmp_burst").disabled="true";
	}
}

function SynState(CheckStat)
{
	if(CheckStat==true){
		document.getElementById("syn_limit").disabled="";
		document.getElementById("syn_burst").disabled="";
	}
	else{	
		document.getElementById("syn_limit").disabled="true";
		document.getElementById("syn_burst").disabled="true";
	}
}

function ArpState(CheckStat)
{
	if(CheckStat==true){
		document.getElementById("arp_limit").disabled="";
		document.getElementById("arp_burst").disabled="";
	}
	else{	
		document.getElementById("arp_limit").disabled="true";
		document.getElementById("arp_burst").disabled="true";
	}
}


</script>
</head>
<body onLoad=fnInit(0)>

<h1><script language="JavaScript">doc(IPT_DoS)</script></h1>

<fieldset>


<form name="qwe" id="myForm" method="POST" action="/goform/net_WebDoSGetValue">
	{{ net_Web_csrf_Token() | safe }}
	<input type="hidden" name="dosTemp" id="dosTemp" value="" />
	<input type="hidden" name="stat1" id="stat1" value="" />
	<input type="hidden" name="port_limit" id="port_limit" value="" />
	<input type="hidden" name="port_burst" id="port_burst" value="" />
	<input type="hidden" name="icmp_burst" id="icmp_burst" value="" />
	<input type="hidden" name="syn_burst" id="syn_burst" value="" />
	<input type="hidden" name="arp_burst" id="arp_burst" value="" />

	<DIV style="height:300px;">
		<table cellpadding="1" cellspacing="3" style="width:500px;">
			
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat2" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_NULL_SCAN)</script>
				</td>
				
			</tr>
			
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat3" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_XMAS_SCAN)</script>
				</td>
			</tr>
			
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat4" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_NMAP_XMAS_SCAN)</script>
				</td>
			</tr>
			
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat5" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_SYN_FIN_SCAN)</script>
				</td>
			</tr>
			
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat6" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_FIN_SCAN)</script>
				</td>
			</tr>
			
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat7" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_NMAPID_SCAN)</script>
				</td>
			</tr>
			
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat8" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_SYN_RST_SCAN)</script>
				</td>
			</tr>
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat9" name="stat">
				</td>
				<td style="width:100x;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_NEW_WITHOUT_SYN)</script>
				</td>
			</tr>
		</table>		
		<table cellpadding="1" cellspacing="3" style="width:300px;">
			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat10" name="stat" onclick="ICMPState(this.checked)">
				</td>
				<td style="width:100px;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_ICMP)</script>
				</td>
				<td style="width:30px;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_LIMIT)</script>
				</td>
				<td  align="left" valign="center">  
		            <input type="text" id=icmp_limit name="icmp_limit" size=5 maxlength=5>(pkt/s)
		        </td>
		        
			</tr>

			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat11" name="stat" onclick="SynState(this.checked)">
				</td>
				<td style="width:100px;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_SYN)</script>
				</td>
				<td style="width:30px;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_LIMIT)</script>
				</td>
				<td  align="left" valign="center">  
		            <input type="text" id=syn_limit name="syn_limit" size=5 maxlength=5>(pkt/s)
		        </td>        
			</tr>	

			<tr>
				<td style="width:25px;">
					<input type="checkbox" id="stat12" name="stat" onclick="ArpState(this.checked)">
				</td>
				<td style="width:100px;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_ARP)</script>
				</td>
				<td style="width:30px;" align="left" valign="center">
					<script language="JavaScript">doc(IPT_DoS_LIMIT)</script>
				</td>
				<td  align="left" valign="center">  
		            <input type="text" id=arp_limit name="arp_limit" size=5 maxlength=5>(pkt/s)
		        </td>
		        
			</tr>
		</table>	
	</div>
	<table align="left">
		<tr>
			<td>
				<table style="width:300px;" align="left">
					<tr class=r0>
						 <td colspan=2><script language="JavaScript">doc(DOS_LOG_ENABLE_)</script></td>
					</tr>	
				</table>
			<td>
		</tr>
		<tr>
			<td>
				<table>
					<tr>
						<td style="width:70px;">
								<script language="JavaScript">doc(LOG_ENABLE_)</script><br/>
							</td>
						<td style="width:120px;" align="left" valign="center">
								<script language="JavaScript">iGenSel2('logEnable', 'logEnable', wtyp0)</script>
							</td>
						<td style="width:10px;">
							<script language="JavaScript">doc(Severity_)</script><br/>
						</td>
						<td style="width:150px;" align="left" valign="center">
							<script language="JavaScript">iGenSel2('ipt_dos_logLevel', 'logLevel', filter_level)</script>
						</td>
						<td style="width:10px;">
							<script language="JavaScript">doc(MOXA_FLASH_)</script><br/>
						</td>
						<td style="width:40px;" align="left" valign="center">
							<input type="checkbox" id="logFlash" name="ipt_dos_logFlash">
						</td>
						<td style="width:10px;">
							<script language="JavaScript">doc(SYSLOG_SERVER_)</script><br/>
						</td>
						<td style="width:40px;" align="left" valign="center">
							<input type="checkbox" id="logSyslog" name="ipt_dos_logSyslog">
						</td>
						<td style="width:70px;">
							<script language="JavaScript">doc(SNMP_TRAP_)</script><br/>
						</td>
						<td style="width:40px;" align="left" valign="center">
							<input type="checkbox" id="logTrap" name="ipt_dos_logTrap">
						</td>
					</tr>
				</table>	
			</td>
		</tr>
	</table>	
</form>





</br>
</br>
</br>
</br>
</br>
</br>

<DIV>
	<table class="tf" align="left" valign="up">
    	<tr>
          	<td width="400px" style="text-align:left;"><script language="JavaScript">fnbnBID(APPLY_, 'onClick=Activate(myForm)', 'btnU')</script></td>
		</tr>
	</table>
</DIV>

</fieldset>

</body></html>
