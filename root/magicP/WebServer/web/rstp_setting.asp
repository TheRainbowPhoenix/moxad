<html>
<head>  
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src="mdata.js"></script>
<script type="text/javascript">
	var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
	checkCookie();
	
	debug = 0;
	if (debug) {
		var SRV_RSTP = {bridge_priority_sel:'0', hello_time_text:'2', forward_delay_text:'15', max_age_text:'20'};

		var SRV_RSTP_type = {
			bridge_priority_sel:2, 
			hello_time_text:4, 
			forward_delay_text:4,
			max_age_text:4
		};

		var SRV_RSTP_PORT = [
			{port_enable:'0', edge_port:'0', port_priority:'15', port_cost:'200000', port_status:'0'},
			{port_enable:'1', edge_port:'1', port_priority:'10', port_cost:'200000', port_status:'1'},
			{port_enable:'0', edge_port:'2', port_priority:'5', port_cost:'200000', port_status:'2'}
		];
		
		var SRV_RSTP_PORT_type = {
			port_enable:3, 
			edge_port:2, 
			port_priority:2,
			port_cost:4,
			port_status:2
		};
	}
	else{
		<%net_Web_show_value('SRV_RSTP_PORT');%>	
		<%net_Web_show_value('SRV_RSTP_SETTING');%>	
		<%net_Web_show_value('SRV_TRUNK_SETTING');%>
        <%net_Web_show_value('SRV_PORT_SETTING');%>
		var port_desc=[<%net_webPortDesc();%>];
		var port_status = [ <% net_Web_Port_Status_WriteValue(); %> ];
		var root_bridge =  "<% net_Web_Root_Bridge_WriteValue(); %> ";

		var dep_fastboot_redundant = <% net_Web_getConfig_Redundant_and_Fastbootup_WriteValue(); %>;
	}


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
			//net_webTr2ShowStatus();%>
		];

	}

	var bridge_priority_sel = [
		{ value:'0', text:'0' },	
		{ value:'1', text:'4096' },	
		{ value:'2', text:'8192' },
		{ value:'3', text:'12288' },
		{ value:'4', text:'16384' },
		{ value:'5', text:'20480' },
		{ value:'6', text:'24576' },
		{ value:'7', text:'28672' },
		{ value:'8', text:'32768' },
		{ value:'9', text:'36864' },
		{ value:'10', text:'40960' },
		{ value:'11', text:'45056' },
		{ value:'12', text:'49152' },
		{ value:'13', text:'53248' },
		{ value:'14', text:'57344' },
		{ value:'15', text:'61440' }
	];

	var edge_port_sel = [
		{ value:'0', text:'False' },
		{ value:'1', text:'Force Edge' }
		
	];

	var port_priority_sel = [
		{ value:'0', text:'0' },	
		{ value:'1', text:'16' },	
		{ value:'2', text:'32' },
		{ value:'3', text:'48' },
		{ value:'4', text:'64' },
		{ value:'5', text:'80' },
		{ value:'6', text:'96' },
		{ value:'7', text:'112' },
		{ value:'8', text:'128' },
		{ value:'9', text:'144' },
		{ value:'10', text:'160' },
		{ value:'11', text:'176' },
		{ value:'12', text:'192' },
		{ value:'13', text:'208' },
		{ value:'14', text:'224' },
		{ value:'15', text:'240' }
		
	];

	var port_status_sel = [
		{ value:'0', text:'Link Down' },
		{ value:'1', text:'Blocking' },
		{ value:'2', text:'Listening' },
		{ value:'3', text:'Learning' },
		{ value:'4', text:'Forwarding' },
		{ value:'5', text:'Port Disabled' },
		{ value:'-1', text:'---' }
	];
 	
	var flag;
	var newdata = new Array;
	var myForm;

	var table_idx = 0;

	function touchLasttime(){
					theName = "lasttime";
					expires = null;
					now=new Date( );
					document.cookie =theName + "=" + now.getTime() + "; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());
 
	}
	
	function CheckCookie(){
		
	}
	
	function ConRedunChange(form,flag) {
		if(form.con_redun_sel.options[form.con_redun_sel.selectedIndex].value==1){
				location.href="turboring2_setting.asp";
		}
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
		var i;
		if(theData=="user"){
			for(i=0;i<document.getElementsByTagName("input").length;i++){
				document.getElementsByTagName("input")[i].disabled=true;
				document.getElementsByTagName("input")[i].style.backgroundColor="#F5F5F5";
			}
			for(i=0;i<document.getElementsByTagName("select").length;i++){
				document.getElementsByTagName("select")[i].disabled=true;
				document.getElementsByTagName("select")[i].style.backgroundColor="#F5F5F5";
			}
			for(i=0;i<document.getElementsByTagName("img").length;i++){
				document.getElementsByTagName("img")[i].disabled=true;
				document.getElementsByTagName("img")[i].style.backgroundColor="#F5F5F5";
			}
		}
	}
 
	function sendData(){
		port_rstp_frame.document.getElementById("bp_select").value=document.rstp_setting_form.bridge_priority_sel.options[document.rstp_setting_form.bridge_priority_sel.selectedIndex].value;
		port_rstp_frame.document.getElementById("ht_text").value=document.rstp_setting_form.hello_time_text.value;
		port_rstp_frame.document.getElementById("ma_text").value=document.rstp_setting_form.max_age_text.value;
		port_rstp_frame.document.getElementById("fd_text").value=document.rstp_setting_form.forward_delay_text.value;
 
		port_rstp_frame.document.getElementById("show_form").submit();
	}
 
	function stopSubmit(){
		return false;
	}

	function Addformat(idx, data, newdata){	
		var j;	
		var k;
		var type;
		var name;
		
		if(idx < SRV_RSTP_PORT.length){
			newdata[0] = "";
			
			/* port_number */
			newdata[1] = port_desc[idx].index;	
			//newdata[1] = idx + 1;

			/* port_enable */
			name = "port_enable";
			newdata[2] = "<input type=checkbox name="+name+ ">";	
			
			/* edge_port */
			name = "edge_port";
			newdata[3] = iGenSel2Str(name, name, edge_port_sel);
			
			/* port_priority */
			name = "port_priority";
			newdata[4] = iGenSel2Str(name, name, port_priority_sel);

			/* port_cost */
			name = "port_cost";
			newdata[5] = "<input type=text name="+name+ " id="+name+ " value ="+SRV_RSTP_PORT[idx].port_cost+">";
	
			/* port_status */
			name = "port_satus";
			if(SRV_RSTP_PORT[idx].port_enable < 1)	// disabled
				newdata[6] = "---";
			else{
                /* JustinJZ Huang fix 
                 * If user enable rstp on the disabled port, display "Port Disabled"
                 */
                if(SRV_PORT_SETTING['enable'+idx]==1){
    		        newdata[6] = port_status_sel[port_status[idx]].text;
                }else{
     		        newdata[6] = port_status_sel[5].text;
                }
            }

		}
		
	}

	function tableinit(){
		var newdata=new Array;
		var i, j=0, portid,name,table;	
		for(i=0; i<parseInt(SRV_RSTP_PORT.length); i++){

			if(SRV_TRUNK_SETTING[i].trkgrp == 0){
				Addformat(i, SRV_RSTP_PORT, newdata);
				tableaddRow("show_available_table", 0, newdata, "center");

				if(i < SRV_RSTP_PORT.length){
					document.getElementsByName("port_enable")[j].checked=SRV_RSTP_PORT[i].port_enable==1?true:false;					
					document.getElementsByName("edge_port")[j].selectedIndex=SRV_RSTP_PORT[i].edge_port;
					document.getElementsByName("port_priority")[j].selectedIndex=SRV_RSTP_PORT[i].port_priority;
					j++;
				}

			}
			  
		}

	}	
	
	function fnInit()
	{
		myForm = document.getElementById('rstp_setting_form');
		fnLoadForm(myForm, SRV_RSTP_SETTING, SRV_RSTP_SETTING_type);
		tableinit();

	}

	function Sstap_parameterCheck(forward_delay, max_age, hello_time)
	{
		if ((2*(forward_delay - 1) < max_age) || (max_age < 2*(hello_time + 1))){
			return (-1);
		}
		return (0);
	}

	
	function Activate(form)
	{
		var i,k=0;
		var j=0;
		var allow_to_set_fastbootup = 1;	//	1: allow, 0: deny
		
		myForm = document.getElementById('rstp_setting_form');
		form.SRV_RSTP_SETTING_tmp.value="";
		form.SRV_RSTP_PORT_tmp.value="";

		/* RSTP Parameters valid checking */
		if(form.hello_time_text.value < 1 || form.hello_time_text.value > 2) {
	            alert("BPDU hello time must be in the range from 1 to 2 secs !");
	            return;
	        }
		
		if(form.forward_delay_text.value < 4 || form.forward_delay_text.value > 30) {
	            alert("The BPDU forward delay time must be in the range from 4 to 30 secs !");
	            return;
	        }
	    
		if(form.max_age_text.value < 6 || form.max_age_text.value > 40) {
		    alert("The max age must be in the range from 6 to 40 secs");
		    return;
		}

		for(i=0;i<SRV_RSTP_PORT.length;i++){
			if (document.getElementsByName("port_cost")[i].value < 1 || document.getElementsByName("port_cost")[i].value > 200000000){
				alert("Cost value must be in the range 1 ~ 200000000");
				return;
			}
		}

		if(Sstap_parameterCheck(parseInt(form.forward_delay_text.value), parseInt(form.max_age_text.value), parseInt(form.hello_time_text.value)))
		{
			alert("Invalid Max Age, Forward Delay, Hello Time value !!!\nThe following restrictions are placed on these Bridge parameters:\n(1)2*(Forward Delay - 1.0 seconds) >= Max Age\n(2)Max Age >= 2*(Hello Time + 1.0 seconds)\n");
			return;
		}


		for(i=0;i<SRV_RSTP_PORT.length;i++){
			if(document.getElementsByName("port_enable")[i].checked == true && dep_fastboot_redundant.fastbootup_enable == 1){
				allow_to_set_fastbootup = 0;
				break;
			}
			else{
		
				//alert(i+", "+document.getElementsByName("port_enable")[i].checked);
				if(SRV_TRUNK_SETTING[i].trkgrp == 0){
					//alert(j);
					form.SRV_RSTP_PORT_tmp.value += (document.getElementsByName("port_enable")[j].checked==true?1:0) + "+";
					form.SRV_RSTP_PORT_tmp.value += document.getElementsByName("edge_port")[j].value + "+";
					form.SRV_RSTP_PORT_tmp.value += document.getElementsByName("port_priority")[j].value + "+";
					form.SRV_RSTP_PORT_tmp.value += document.getElementsByName("port_cost")[j].value + "+";
					j++;
					
				}
				else{
					form.SRV_RSTP_PORT_tmp.value += "0" + "+";
					form.SRV_RSTP_PORT_tmp.value += "0" + "+";
					form.SRV_RSTP_PORT_tmp.value += "0" + "+";
					form.SRV_RSTP_PORT_tmp.value += "150000" + "+";
					//alert("default");
				}
			}
		}

		if(allow_to_set_fastbootup == 0){
			alert("Cannot enable \"Fast Bootup\" and \"Redundant Protocols\" at the same time.");
			return;
		}

		//alert(document.getElementsByName("port_cost")[0].value);

		form.SRV_RSTP_SETTING_tmp.value += form.bridge_priority_sel.value + "+";
		form.SRV_RSTP_SETTING_tmp.value += form.hello_time_text.value + "+";
		form.SRV_RSTP_SETTING_tmp.value += form.forward_delay_text.value + "+";
		form.SRV_RSTP_SETTING_tmp.value += form.max_age_text.value + "+";

		form.protocol.value = 1; // 1 is RSTP
		form.action="/goform/net_Web_get_value?SRV=SRV_RSTP_PORT&SRV0=SRV_RSTP_SETTING&SRV1=SRV_RDNDNT_SET";
		form.submit();
		
	}

	function show_root(form)
	{
		document.write(root_bridge);
	}


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
	td
	{
		font-family:Arial, Helvetica, sans-serif, Marlett;
		font-size:8pt;
	}
</style>
</head>
<body class="main" onload="fnInit()">
<h1><script language="JavaScript">doc(COMMUNICATION_REDUNDANCY)</script></h1>
<form method="post" name="rstp_setting_form" id="rstp_setting_form" onkeypress="touchLasttime()" target="mid">
<fieldset>
<input type="hidden" name="SRV_RSTP_PORT_tmp" id="SRV_RSTP_PORT_tmp" value="" >
<input type="hidden" name="SRV_RSTP_SETTING_tmp" id="SRV_RSTP_SETTING_tmp" value="" >
<input type="hidden" name="protocol" id="protocol" value="1">
<% net_Web_csrf_Token(); %>
<div align="left">
	<table width="700" align="left" border="0">

		<tr class=r0>
			<td width="5%" align="left" border="0"></td>
			<td width="95%" align="left" border="0">Current Status</td>
		</tr>
		<tr>
			<td width="5%" align="left" border="0"><div align="left"><font size="3" face="Arial, Helvetica, sans-serif, Marlett" >
				</font></div></td>
			<td width="95%" align="left" border="0"><div align="left"><font size="3" face="Arial, Helvetica, sans-serif, Marlett" >
    			<table width="100%" align="left" border="0">
        			<tr>
            			<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
            			<td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				Root/Not root</font></div></td>
            			<td width="77%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		    				<font size="2" color="#000000"><b><script language="JavaScript">show_root(rstp_setting_form)</script><b></font></font></div></td>
        			</tr>
    			</table></font></div></td>
		</tr>
		<tr class=r0>
			<td width="5%" align="left" border="0"></td>
			<td width="95%" align="left" border="0">Settings</td>
   		</tr>
   		<tr>
			<td width="5%" align="left" border="0"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				</font></div></td>
			<td width="95%" align="left" border="0"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
				<table width="100%" align="left" border="0">
	     			<tr>
	        			<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
            			<td width="18%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                			</font></div></td>
            			<td width="4%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	            			</font></div></td>
            			<td width="14%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	            			</font></div></td>
	        			<td width="12%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
	        			<td width="24%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                			</font></div></td>
            			<td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	            			</font></div></td>
         			</tr>
					<tr>
            			<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
            			<td width="22%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                			Redundancy Protocol</font></div></td>
            			<td width="75%" colspan="4"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	            			<select name="con_redun_sel" size="1" onchange="ConRedunChange(document.rstp_setting_form,1)">
<option value=0 selected >RSTP (IEEE 802.1D 2004)</option>
<option value=1 >Turbo Ring V2</option>
</select>

        	       			</font></div></td>
         			</tr>
    	 			<tr>
            			<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
            			<td width="18%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                			Bridge Priority</font></div></td>
            			<td width="18%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
							<script language="JavaScript">iGenSel2('bridge_priority_sel', 'bridge_priority_sel', bridge_priority_sel)</script>

            			<td width="12%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                			Hello Time</font></div></td>
            			<td width="24%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	            			<input type="text" name="hello_time_text" id="hello_time_text" size="1" maxlength="2">
</font></div></td>
	        			<td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
	     			</tr>
	     			<tr>
	        			<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
            			<td width="18%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                			Forwarding Delay</font></div></td>
            			<td width="18%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	            			<input type="text" name="forward_delay_text" id="forward_delay_text" size="1" maxlength="2" >
</font></div></td>
	        			<td width="12%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
                			Max Age</font></div></td>
            			<td width="24%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	            			<input type="text" name="max_age_text" id="max_age_text" size="1" maxlength="2" >
</font></div></td>
	        			<td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            				</font></div></td>
         			</tr>
				</table></font></div></td>
   		</tr>
		<tr>
			<td width="5%">
				<div align="left">
					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"></font>
				</div>
			</td>

			<td width="700">
				<div align="left">
					<table width="700" align="left" border="0" id="show_available_table">
						<tr>
							<th width="3%"></th>
							<th width="10%" bgcolor="#007C60">Port</th>
							<th width="10%" bgcolor="#007C60">Enable RSTP</th>
							<th width="10%" bgcolor="#007C60">Edge Port</th>
							<th width="10%" bgcolor="#007C60">Port Priority</th>
							<th width="10%" bgcolor="#007C60">Path Cost</th>
							<th width="10%" bgcolor="#007C60">Status</th>
						</tr>


					</table>

				</div>
			</td>


		</tr>

		<tr>
			<td width="5%">
				<div align="left">
					<font size="2" face="Arial, Helvetica, sans-serif, Marlett"></font>
				</div>
			</td>
			<td width="95%">
				<script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script>
			</td>
		</tr>


	</table>

</div>
</fieldset>
</form>
</body>
</html>

