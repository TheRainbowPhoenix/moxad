<html>
<head>  
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
  
<script language="JavaScript" src="mdata.js"></script>
<script type="text/javascript">
<!--
	checkCookie();
	var coupling_mode = [ 	{ value:1, text:TR2_COUPLING_DUAL_HOMING },
							{ value:2, text:TR2_COUPLING_BACKUP },
							{ value:3, text:TR2_COUPLING_PRIMARY } ];
	var port_list = [ {{ net_webGetPortList() | safe }} ];

	debug = 0;
	if (debug) {
		var SRV_TR2SET_type;
		
		var SRV_TR2SET = {
			tr2_enabled:"1",
			ring1:"1", ring1_master:1, ring1_port1:"1", ring1_port2:"2",
			ring2:"0", ring2_master:0, ring2_port1:"3", ring2_port2:"4",
			coupling_enabled:"0", coupling:1, coupling_1st:"7", coupling_2nd:"8"
		};
	}
	else{
		{{ net_Web_show_value("SRV_TR2SET") | safe }}	
		var dep_fastboot_redundant = {{ net_Web_getConfig_Redundant_and_Fastbootup_WriteValue() | safe }};
	}

	debug = 0;
	if (debug) {
		var wdata = [
			{ringid:'1', status:'Break', master:'Master', masterId:'00:90:e8:11:11:11',port1Status:"<b>Up,Blocked</b>", port2Status:"<b>Up,Blocked</b>",
				tcCount:'7', timeSinceTc:'0 days 2 hours 56 mins 52 secs'},
			{ringid:'2', status:'Disabled', master:'--', masterId:'00:00:00:00:00:00',port1Status:'--', port2Status:'--',
				tcCount:'0', timeSinceTc:' '},
			{coupling_mode:"Dual Homing", coupling_port1:"Forwarding", coupling_port2:"Down"},	
		];	
	}
	else{
		var wdata = [		
			{{ net_webTr2ShowStatus() | safe }}
		];

	}

	function ConRedunChange(form) {
		if(form.con_redun_sel.options[form.con_redun_sel.selectedIndex].value==0){
			location.href="rstp_setting.asp";
		}

	}

	function touchLasttime()
	{
		
	}

	function AccountDiff(){
		CheckCookie();
		theData = "";
		theName = "AccountName508=";
		theCookie = document.cookie+";";
		start = theCookie.indexOf(theName);
		if(start != -1){
			end=theCookie.indexOf(";",start);
			theData = unescape(theCookie.substring(start+theName.length,end));
		}

		couplingstatus();
		couplingchange();
		ringchange();

		var i;
		if( (theData=="user") || (document.turboring_setting_form.isforceTurboRing.value==1) )

		{
			for(i=0;i<document.getElementsByTagName("input").length;i++){
				document.getElementsByTagName("input")[i].disabled=true;
			}
			for(i=0;i<document.getElementsByTagName("select").length;i++){
				document.getElementsByTagName("select")[i].disabled=true;
				document.getElementsByTagName("select")[i].style.backgroundColor="#F5F5F5";
			}
		}
	}


	function ringchange() {
		var ring1 = document.turboring_setting_form.ring1;
		var ring1_master = document.turboring_setting_form.ring1_master;
		var ring1_port1 = document.turboring_setting_form.ring1_port1;
		var ring1_port2 = document.turboring_setting_form.ring1_port2;

		var ring2 = document.turboring_setting_form.ring2;
		var ring2_master = document.turboring_setting_form.ring2_master;
		var ring2_port1 = document.turboring_setting_form.ring2_port1;
		var ring2_port2 = document.turboring_setting_form.ring2_port2;

		var coupling_enabled = document.turboring_setting_form.coupling_enabled;
		var coupling = document.turboring_setting_form.coupling;
		var coupling_1st = document.turboring_setting_form.coupling_1st;
		var coupling_2nd = document.turboring_setting_form.coupling_2nd;

		if(ring1.checked && ring2.checked)
		{
			coupling_enabled.disabled=true;
			coupling.disabled=true;
			coupling_1st.disabled=true;
			coupling_2nd.disabled=true;
		}

		if(ring1.checked && coupling_enabled.checked)
		{
			ring2.disabled=true;
			ring2_master.disabled=true;
			ring2_port1.disabled=true;
			ring2_port2.disabled=true;
		}

		if(ring2.checked && coupling_enabled.checked)
		{
			ring1.disabled=true;
			ring1_master.disabled=true;
			ring1_port1.disabled=true;
			ring1_port2.disabled=true;
		}

		if(!ring1.checked)
		{
			ring2.disabled=false;
			ring2_master.disabled=false;
			ring2_port1.disabled=false;
			ring2_port2.disabled=false;
			coupling_enabled.disabled=false;
			coupling.disabled=false;
			coupling_1st.disabled=false;
			coupling_2nd.disabled=false;
		}

		if(!ring2.checked)
		{
			ring1.disabled=false;
			ring1_master.disabled=false;
			ring1_port1.disabled=false;
			ring1_port2.disabled=false;
			coupling_enabled.disabled=false;
			coupling.disabled=false;
			coupling_1st.disabled=false;
			coupling_2nd.disabled=false;
		}

		if(!coupling_enabled.checked)
		{
			ring1.disabled=false;
			ring1_master.disabled=false;
			ring1_port1.disabled=false;
			ring1_port2.disabled=false;
			ring2.disabled=false;
			ring2_master.disabled=false;
			ring2_port1.disabled=false;
			ring2_port2.disabled=false;
		}

		if(ring1.checked)
		{
			ring1_master.disabled=false;
			ring1_port1.disabled=false;
			ring1_port2.disabled=false;
		}
		else
		{
			ring1_master.disabled=true;
			ring1_port1.disabled=true;
			ring1_port2.disabled=true;
		}

		if(ring2.checked)
		{
			ring2_master.disabled=false;
			ring2_port1.disabled=false;
			ring2_port2.disabled=false;
		}
		else
		{
			ring2_master.disabled=true;
			ring2_port1.disabled=true;
			ring2_port2.disabled=true;
		}

		if(coupling_enabled.checked)
		{
			coupling.disabled=false;
			coupling_1st.disabled=false;
			coupling_2nd.disabled=false;
		}
		else
		{
			coupling.disabled=true;
			coupling_1st.disabled=true;
			coupling_2nd.disabled=true;
		}
	}


	var coupling_port2 = null;
	function couplingchange() {

		var coupling = document.turboring_setting_form.coupling;
		
		if(coupling.options[coupling.selectedIndex].value==1)
		{
			document.getElementById("coupling_text1").innerHTML='Primary Port';
			document.getElementById("coupling_text2").innerHTML='Backup Port';
			if(coupling_port2!=null)
				document.getElementById("coupling_port2").innerHTML=coupling_port2;
		}
		else
		{
			document.getElementById("coupling_text1").innerHTML='Coupling Port';
			document.getElementById("coupling_text2").innerHTML="";
			if(document.getElementById("coupling_port2").innerHTML.match("hidden") == null)
				coupling_port2 = document.getElementById("coupling_port2").innerHTML;
			document.getElementById("coupling_port2").innerHTML="<input type=hidden name=coupling_2nd>";
		}
	}

	function couplingstatus() {

		var coupling = document.turboring_setting_form.coupling;

		if(coupling.options[coupling.selectedIndex].value==1)
		{
			document.getElementById("coupling_status1").innerHTML='Primary Port';
		}
		else
		{
			document.getElementById("coupling_status2").innerHTML="";
			document.getElementById("coupling_status3").innerHTML="";
		}
	}

	function isConfigConflict(form) {
		var ring1 = document.turboring_setting_form.ring1;
		var ring1_master = document.turboring_setting_form.ring1_master;
		var ring1_port1 = document.turboring_setting_form.ring1_port1.value;
		var ring1_port2 = document.turboring_setting_form.ring1_port2.value;

		var ring2 = document.turboring_setting_form.ring2;
		var ring2_master = document.turboring_setting_form.ring2_master;
		var ring2_port1 = document.turboring_setting_form.ring2_port1.value;
		var ring2_port2 = document.turboring_setting_form.ring2_port2.value;

		var coupling_enabled = document.turboring_setting_form.coupling_enabled;
		var coupling = document.turboring_setting_form.coupling;
		var coupling_mode = coupling.options[coupling.selectedIndex].value;
		var coupling_1st = document.turboring_setting_form.coupling_1st.value;
		var coupling_2nd = document.turboring_setting_form.coupling_2nd.value;

		var error = 0;

		// Check if there is ring enabled conflict
		if(coupling_enabled.checked) {
			if( (coupling_mode==2 || coupling_mode==3) && !ring1.checked && !ring2.checked) {
				alert("Please enable one Ring in Ring Coupling mode!!!");
				return true;
			}
		}
		else {
			if(!ring1.checked && !ring2.checked) {
				alert("Please select at least one Ring!!!");
				return true;
			}
		}
		
		// ring1, ring2, coupling ports conflict checking
		if(ring1.checked) { 
			if(ring1_port1 == ring1_port2) {
				error++;
			}
	
			if(ring2.checked) {
				if(ring2_port1 == ring2_port2) {
					error++;
				}
				
				if((ring2_port1 == ring1_port1) || (ring2_port1 == ring1_port2)) {
					error++;
				}
					
				if((ring2_port2 == ring1_port1) || (ring2_port2 == ring1_port2)) {
					error++;
				}
			}

			if(coupling_enabled.checked) {
				if(ring1_port1 == coupling_1st) {
					error++;
				}

				if(ring1_port2 == coupling_1st) {
					error++;
				}

				if(coupling_mode == 1) { // Dual Homing
					if(coupling_1st == coupling_2nd) {
						error++;
					}
					
					if(ring1_port1 == coupling_2nd) {
						error++;
					}

					if(ring1_port2 == coupling_2nd) {
						error++;
					}
				}
			}
		}
		else if(ring2.checked) {
			if(ring2_port1 == ring2_port2) {
				error++;
			}

			if(coupling_enabled.checked) {
				if(ring2_port1 == coupling_1st) {
					error++;
				}

				if(ring2_port2 == coupling_1st) {
					error++;
				}

				if(coupling_mode == 1) { // Dual Homing
					if(coupling_1st == coupling_2nd) {
						error++;
					}
					
					if(ring2_port1 == coupling_2nd) {
						error++;
					}

					if(ring2_port2 == coupling_2nd) {
						error++;
					}
				}
			}
		}
		else if(coupling_enabled.checked && coupling_mode == 1) {
			if(coupling_1st == coupling_2nd) {
				error++;
			}
		}

		if(error > 0) {
			alert("Port settting is conflict");
			return true;
		}

		return false;
	}

	function Activate(form)
	{	
		var i;
		var j;
		var myForm = document.getElementById('turboring_setting_form');	

		if((document.turboring_setting_form.ring1.checked || document.turboring_setting_form.checked || document.turboring_setting_form.coupling_enabled) && dep_fastboot_redundant.fastbootup_enable == 1){
			alert("Cannot enable \"Fast Bootup\" and \"Redundant Protocols\" at the same time.");
			return 0;
		}

		if(isConfigConflict(myForm)) {
			return 0;
		}
		else {
			myForm.protocol.value = 3; // 3: RDNDNT_TR2
			form.submit();
		}
	}

	function fnInit() 
	{	
		var coupling_enabled = document.turboring_setting_form.coupling_enabled;

		myForm = document.getElementById('turboring_setting_form');	
		fnLoadForm(myForm, SRV_TR2SET, SRV_TR2SET_type);

		if(SRV_TR2SET.coupling == 0) {
			coupling_enabled.checked = false;
		}
		else {
			coupling_enabled.checked = true;
		}

		couplingstatus();
		couplingchange();
		ringchange();
	}

//-->
</script>
<style type="text/css">
	.title1
	{
		font-family:Arial, Helvetica, sans-serif, Marlett;
		font-size:16pt;
		font-weight: bold;
		color:#007C60;
	}
	.title2
	{
		font-family:Arial, Helvetica, sans-serif, Marlett;
		font-size:12pt;
		font-weight: bold;
		color:#FF9900;
	}
	.blue
	{
		font-family:Arial, Helvetica, sans-serif, Marlett;
		font-size:8pt;
		color:#0000FF;
	}
	
</style>
</head>

<body class="main" onload="fnInit()">
<h1><script language="JavaScript">doc(TR2_REDUNDANCY)</script></h1>  
<form method="post" action="/goform/net_Web_get_value?SRV=SRV_TR2SET&SRV0=SRV_RDNDNT_SET" onkeypress="touchLasttime()" target="mid" name="turboring_setting_form" id="turboring_setting_form">
<fieldset>
<input type="hidden" name="tr2_tmp" id="tr2_tmp" value="">
<input type="hidden" name="protocol" id="protocol" value="3">
{{ net_Web_csrf_Token() | safe }}
<table width="670" cellspacing=0>
<tr class=r0>
	<td><script language="JavaScript">doc(TR2_TR2_STATUS)</script></td>
</tr>
<tr>
	<td>
		<table cellspacing=1>
		<tr>
			<td>
				<table cellspacing=0>
				<tr>
					<td><b>Now Active</b></td>
					<td>{{ net_webShowRedundantProtocol() | safe }}</td>
					<td></td>
				</tr>
				<tr>
					<td><b>Ring 1</b></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_STATUS)</script></td>
					<td><b><script language="JavaScript">doc(wdata[0].status);</script></b></td>
					<td></td>
				</tr>
                         <tr>
					<td><script language="JavaScript">doc(TR2_MASTER_SLAVE)</script></td>
					<td><b><script language="JavaScript">doc(wdata[0].master);</script></b></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_MASTER_ID)</script></td>
					<td><b><script language="JavaScript">doc(wdata[0].masterId);</script></b></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_1ST_PORT_STATUS)</script></td>
					<td><b><script language="JavaScript">doc(wdata[0].port1Status);</script></b></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_2ND_PORT_STATUS)</script></td>
					<td><b><script language="JavaScript">doc(wdata[0].port2Status);</script></b></td>
					<td></td>
				</tr>
				</table>
			</td>

			<td>
				<table cellspacing=0>
				<tr>
					<td>&nbsp;</td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td><b>Ring 2</b></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_STATUS)</script></td>
					<td><b><script language="JavaScript">doc(wdata[1].status);</script></b></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_MASTER_SLAVE)</script></td>
					<td><b><script language="JavaScript">doc(wdata[1].master);</script></b></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_MASTER_ID)</script></td>
					<td><b><script language="JavaScript">doc(wdata[1].masterId);</script></b></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_1ST_PORT_STATUS)</script></td>
					<td><b><script language="JavaScript">doc(wdata[1].port1Status);</script></b></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_2ND_PORT_STATUS)</script></td>
					<td><script language="JavaScript">doc(wdata[1].port2Status);</script></td>
					<td></td>
				</tr>
				</table>
			</td>
		</tr>

		<tr>
			<td colspan=1>
				<table cellspacing=0>
				<tr>
					<td><b><script language="JavaScript">doc(TR2_COUPLING)</script></b></td>
					<td></td>
					<td></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_COUPLING_MODE)</script></td>
					<td><b><script language="JavaScript">doc(wdata[2].coupling_mode);</script></b></td>
					<td></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td><script language="JavaScript">doc(TR2_COUPLING_PORT_STATUS)</script></td>
					<td><span id=coupling_status1><script language="JavaScript">doc(TR2_COUPLING_COUPLE_PORT)</script></span> </td>
					<td><b><script language="JavaScript">doc(wdata[2].coupling_port1);</script></b></td>
					<td><span id=coupling_status2><script language="JavaScript">doc(TR2_COUPLING_BACKUP_PORT)</script></span> </td>
					<td><span id=coupling_status3><b><script language="JavaScript">doc(wdata[2].coupling_port2);</script></b><span></td>
				</tr>
				</table>
			</td>
		</tr>
		</table>
	</td>
</tr>

<tr style="height:50px"></tr>

<tr class=r0>
	<td><script language="JavaScript">doc(TR2_TR2_SETTING)</script></td>
</tr>
<tr>
	<td>
		<table cellspacing=0>
		<tr>
			<td>
				<table cellspacing=0>
				<tr>
					<td nowrap><script language="JavaScript">doc(TR2_REDUNDANCY_PROTO)</script></td>
					{{ net_webTr2totcsel() | safe }}
				</tr>
				<tr>
					<td><input type="checkbox" name="ring1" onclick="ringchange()"><script language="JavaScript">doc(TR2_ENABLE_RING1)</script>
					</td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td nowrap> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="ring1_master"><script language="JavaScript">doc(TR2_SET_AS_MASTER)</script></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td nowrap> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<script language="JavaScript">doc(TR2_REDUNDANT_PORTS)</script></td>
					<td><script language="JavaScript">doc(TR2_1ST_RING_PORT)</script></td>
					<td><script language="JavaScript">iGenSel3('ring1_port1', 'ring1_port1', port_list, '')</script>
						
						</td>
				</tr>
				<tr>
					<td></td>
					<td><script language="JavaScript">doc(TR2_2ND_RING_PORT)</script></td>
					<td><script language="JavaScript">iGenSel3('ring1_port2', 'ring1_port2', port_list, '')</script>
						
					</td>
				</tr>
				</table>
			</td>
			<td>
				<table cellspacing=0>
				<tr>
					<td>&nbsp;</td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td><input type="checkbox" name="ring2" onclick="ringchange()"><script language="JavaScript">doc(TR2_ENABLE_RING2)</script></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="checkbox" name="ring2_master"><script language="JavaScript">doc(TR2_SET_AS_MASTER)</script></td>
					<td></td>
					<td></td>
				</tr>
				<tr>
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<script language="JavaScript">doc(TR2_REDUNDANT_PORTS)</script></td>
					<td><script language="JavaScript">doc(TR2_1ST_RING_PORT)</script></td>
					<td><script language="JavaScript">iGenSel3('ring2_port1', 'ring2_port1', port_list, '')</script>
							
					</td>
				</tr>
				<tr>
					<td></td>
					<td><script language="JavaScript">doc(TR2_2ND_RING_PORT)</script></td>
					<td><script language="JavaScript">iGenSel3('ring2_port2', 'ring2_port2', port_list, '')</script>
						
					</td>
				</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan=1>
			<table cellspacing=0>
			<tr>
				<td><input type="checkbox" name="coupling_enabled" onclick="ringchange()"><script language="JavaScript">doc(TR2_ENABLE_RING_COUPLING)</script>
				</td>
				<td></td>
				<td></td>
				<td></td>
			</tr>
			<tr>
				<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<script language="JavaScript">doc(TR2_COUPLING_MODE)</script></td>
				<td colspan=3><script language="JavaScript">iGenSel3('coupling', 'coupling', coupling_mode, "couplingchange")</script>
				</td>
			</tr>
			<tr>
				<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<span id=coupling_text1><script language="JavaScript">doc(TR2_PRIMARY_PORT)</script></span></td>
				<td><script language="JavaScript">iGenSel3('coupling_1st', 'coupling_1st', port_list, '')</script>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				</td>
				<td><span id=coupling_text2><script language="JavaScript">doc(TR2_BACKUP_PORT)</script></td>
				<td><span id=coupling_port2><script language="JavaScript">iGenSel3('coupling_2nd', 'coupling_2nd', port_list, '')</script>						
      	        	</span>
				</td>
			</tr>
			</table>
			</td>
		</tr>
		</table>
	</td>
</tr>
</table>
<br>
<table width="670" >
	<tr>
		<td align="center" border="0" ><script language="JavaScript">fnbnB(Submit_, 'onClick=Activate(this.form)')</script></td>
	</tr>
</table>
</fieldset>
</form>
</body>
</html>