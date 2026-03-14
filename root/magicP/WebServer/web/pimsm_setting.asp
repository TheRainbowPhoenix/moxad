<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

	<!--

if (!debug) {
	var SRV_PIMSMS = {
		
	};
}else{
	<%net_Web_show_value('SRV_PIMSMS');%>
	<%net_Web_show_value('SRV_VCONF');%>	
}
var ModelVLAN = <% net_Web_GetModel_VLAN_WriteValue(); %>;
var No_WAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
var MAC_PORTS = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %>;
var newdata=new Array;
var sm_item_name="smif";
var adv_item_name="advance";
var item_idx=0;
var pimsm_enable = false;
var pimsm_spt_switchover_enable = false;
var PROTO_MASK_PIMSM = (1 << 5);
var input_start_index = 3;
var wan = [
		<%net_webLan_Wan_IP();%>
]	

var sptswitch = [
	{ value:0x00, text:'Never' },
	{ value:0x01,text:'Immediate' }
];
var sptselstate = { type:'select', id:'pimsmSPTSwitchover', name:'spt_sw_en', size:1, option:sptswitch};
	//var pimsm_enable = false;
	//var pimsm_spt_switchover_enable = false;

	// Judge the user's browser
	var sAgent = navigator.userAgent.toLowerCase();
	this.isIE = (sAgent.indexOf('msie')!=-1); //IE6.0-7
	this.isFF = (sAgent.indexOf('firefox')!=-1);//firefox
	this.isSa = (sAgent.indexOf('safari')!=-1);//safari
	this.isOp = (sAgent.indexOf('opera')!=-1);//opera
	this.isNN = (sAgent.indexOf('netscape')!=-1);//netscape
	this.isMa = this.isIE;//marthon
	this.isOther = (!this.isIE && !this.isFF && !this.isSa && !this.isOp && !this.isNN && !this.isSa);//unknown Browser

	
	function CheckCookie()
	{
		
	}

	/*function setPIMSMEnable()
	{
		var j;
		if(document.getElementById("pimsmEnableCheckbox").checked)
		{
			for(j=input_start_index;j < document.getElementsByTagName("input").length; j++)
			{
				// Not to enable the "Show Advance Setting" checkbox
				if(document.getElementsByTagName("input")[j].id.indexOf(adv_item_name) != 0)
				{
					document.getElementsByTagName("input")[j].disabled = false;

					// The VLAN interface is enable the PIM-SM
					if(document.getElementsByTagName("input")[j].id.indexOf(sm_item_name) == 0)
					{
						if(document.getElementsByTagName("input")[j].checked)
						{
							// Enable the "Show Advance Setting" checkbox
							document.getElementsByTagName("input")[j + 1].disabled = false;
						}
					}
				}
			}
			document.getElementById("pimsmSPTSwitchover").disabled = false;
		}
		else
		{
			// -1 : image * 1
			for(j=input_start_index;j < document.getElementsByTagName("input").length - 1; j++)
			{
				document.getElementsByTagName("input")[j].disabled = true;
			}
			document.getElementById("pimsmSPTSwitchover").disabled = true;
		}
	}*/

	var selectedVlan = null;

	// Enable/Disable the PIM-SM setting
	function ChangePimsm(vlan)
	{		
		if(document.getElementById(sm_item_name + vlan).checked == false)
		{
			// Disable the PIM-SM setting
			// Disable the advance setting checkbox
			//document.getElementById(adv_item_name + vlan).disabled = true;
		}
		else
		{
			// Enable the PIM-SM setting
			// Enable the advance setting checkbox
			//document.getElementById(adv_item_name + vlan).disabled = false;
		}

		if(selectedVlan != null)
		{
			// Uncheck the advance setting checkbox
			//document.getElementById(adv_item_name + selectedVlan).checked = false;

			// Hide the advance setting table
			document.getElementById('tblAdvanceSetting' + selectedVlan).style.display = 'none';

			// Recover the background color of the selected setting row
			var table = document.getElementById("show_available_table");
			//table.rows[1+vlan].className=(vlan%2 ? "r3" : "r4");
			//document.getElementById('tblSetting' + selectedVlan).bgColor = '#FFFFFF';
		}
	}

	// Show/Hide the PIM-SM advance setting
	function ChangeAdvanceSetting(vlan)
	{
		if(selectedVlan != null)
		{	
			// Hide the previous advance setting table row
			document.getElementById('tblAdvanceSetting' + selectedVlan).style.display = 'none';

			// Recover the background color of the selected setting row
			//document.getElementById('tblSetting' + selectedVlan).bgColor = '#FFFFFF';
			var table = document.getElementById("show_available_table");
			//table.rows[1+selectedVlan].className=(selectedVlan%2 ? "r3" : "r4");

			// Uncheck the previous advance setting table row
			document.getElementById(adv_item_name + selectedVlan).checked = false;
		}

		if(document.getElementById(adv_item_name + vlan).checked == false)
		{
			selectedVlan = null;
		}
		else
		{
			// Show the PIM-SM advance setting table
			document.getElementById('tblAdvanceSetting' + vlan).style.display = '';

			// Set the background color
			var table = document.getElementById("show_available_table");
			//table.rows[1+vlan].className="rh";
			//document.getElementById('tblSetting' + vlan).bgColor = '#00ff66';

			selectedVlan = vlan;
		}
	}


	function Activate(form)
	{
		var dvmrpEnable = 0, pimdmEnable = 0, pimsmEnable = 0;
		var i, vid, idx;
		dvmrpEnable = 0;
		pimdmEnable = 0;
		pimsmEnable = 0;
		/*if (dvmrpEnable & document.getElementById("pimsmEnableCheckbox").checked)
		{
			alert("If you want to enable PIM-SM, please disable DVMRP");
		}
		else if (pimdmEnable & document.getElementById("pimsmEnableCheckbox").checked)
		{
			alert("If you want to enable PIM-SM, please disable PIM-DM");
		}
		else*/
		{
			if(ModelVLAN==RETURN_TRUE){
				for(i=0; i < SRV_VCONF.length+No_WAN; i++){						
					if(No_WAN+1 > MAC_PORTS){				
							if(i < No_WAN){
							if(wan[i].vid==0){
								continue;
							}else{
								vid = wan[i].vid;
							}
						}else{
							vid = SRV_VCONF[i-No_WAN]["vid"];
						}
						
						
						if(document.getElementById(sm_item_name+vid)){							
							if(document.getElementById(sm_item_name+vid).checked==true){					
								if(i < No_WAN){																
									document.getElementById("wan").value= document.getElementsByName(sm_item_name+vid)[0].value;
							}else{
								SRV_VCONF[i-No_WAN]["routing"]|= PROTO_MASK_PIMSM;								
							}
						}else{
							if(i >= (No_WAN)){								
								SRV_VCONF[i-No_WAN]["routing"]&= ~PROTO_MASK_PIMSM;
							}
						}
					}
				}
			}			
			}		
			for( i = 0 ; i < SRV_VCONF.length ; i++)
			{
				for (var k in SRV_VCONF[i]){
					form.vlantmp.value = form.vlantmp.value + SRV_VCONF[i][k] + "+";		
				}					
			}
			idx=0;
			for(i = 0 ; i < SRV_VCONF.length+No_WAN ; i++)
			{
				if(i<No_WAN){
					if(wan[i].vid==0){
						continue;
					}else{
						vid = wan[i].vid;
					}
				}else{
					vid = SRV_VCONF[i-No_WAN]["vid"];
				}
				if(document.getElementById(sm_item_name+vid)){
					for (var j in pimsm_dr_type){
						form.pimsm_dr_tmp.value = form.pimsm_dr_tmp.value + document.getElementsByName(j+vid)[0].value + "+";	
					}					
				}
			}
			document.pimsm_setting.action="/goform/net_Web_get_value?SRV=SRV_VCONF_ROUT_UPDATE&SRV0=SRV_PIMSMS";
			document.pimsm_setting.submit();
		}
	}
	function stopSubmit()
	{
		return false;
	}

	function Addformat(data, newdata)
	{	
		var i;
		for(i=0;pimsm_dr[i];i++){
			if(pimsm_dr[i]["dr_vid"] == data.vid)
				break;
		}
		newdata[0] = '<input type=checkbox id='+sm_item_name+data.vid+' name="'+sm_item_name+data.vid+'" onclick="ChangePimsm('+data.vid+')";>';
		if(i<pimsm_dr.length && pimsm_dr[i]["dr_vid"]!=0){			
			newdata[1] = data.ifname;
			newdata[2] = data.ip;
			newdata[3] = '<input style="width:100%" type=text name=h_interval'+data.vid+' value='+pimsm_dr[i]["h_interval"]+' maxlength=4 size=4>';	
			newdata[4] = '<input style="width:100%" type=text name=dr_priority'+data.vid+' value='+pimsm_dr[i]["dr_priority"]+' maxlength=8 size=8>';	
			newdata[5] = '<input style="width:100%" type=text name=j_p_interval'+data.vid+' value='+pimsm_dr[i]["j_p_interval"]+' maxlength=4 size=4>';	
			newdata[6] = '<input style="width:100%" type="hidden" id=dr_vid name=dr_vid'+data.vid+' value='+data.vid+'>';		
		}else{
			newdata[1] = data.ifname;
			newdata[2] = data.ip;
			newdata[3] = '<input style="width:100%" type=text name=h_interval'+data.vid+' value=30 maxlength=4 size=4>';	
			newdata[4] = '<input style="width:100%" type=text name=dr_priority'+data.vid+' value=0 maxlength=8 size=8>';	
			newdata[5] = '<input style="width:100%" type=text name=j_p_interval'+data.vid+' value=30 maxlength=4 size=4>';	
			newdata[6] = '<input style="width:100%" type="hidden" id=dr_vid name=dr_vid'+data.vid+' value='+data.vid+'>';	
			}
		}


	function PrintWanTable() {
		if(ModelVLAN==RETURN_TRUE){
			var newdata=new Array;
			var wandata=new Array;
			var i;
			item_idx=0;
			
			var name;
			for(i=0;i< No_WAN;i++){
				if(i<No_WAN){
					name='wan';
					if(No_WAN>1){
						name+=i;
					}
				}
				if(wan[i].vid!=0){
					wandata.ifname = name.toUpperCase();
					wandata.ip = wan[i].ipad;
					wandata.vid = wan[i].vid;
					Addformat(wandata, newdata);					
					main_tableaddRow("show_available_table", 0, newdata, "left");
					if(SRV_PIMSMS.wan&1<<item_idx){
						document.getElementById(sm_item_name+wandata.vid).checked=true;
					}
				}
				item_idx++;
			}
			for(i=0; i < SRV_VCONF.length; i++){
				Addformat(SRV_VCONF[i], newdata);
				main_tableaddRow("show_available_table", 0, newdata, "left");
				if(SRV_VCONF[i]["routing"]&PROTO_MASK_PIMSM){
					document.getElementById(sm_item_name+SRV_VCONF[i].vid).checked=true;
				}
				item_idx++;
			}	
			//document.write('<tr align="left">');
					
		}else{
			var i;
			for(i in  SRV_PIMSMS){
				if(!document.getElementById(i)){
					document.write('<td width=30px><input type=checkbox id='+i+' name='+i+'></td>');
					document.write('<td width=40px>'+i.toUpperCase()+'</td>');			
				}
			}
		}
	
	}


	
	function fnInit(){
		// Initial the PIM-SM status
		//document.getElementById('pimsmEnableCheckbox').checked = SRV_PIMSMS.enable==1?true:false;		
		document.getElementById("pimsmSPTSwitchover").options.selectedIndex = SRV_PIMSMS.spt_sw_en;		
		//setPIMSMEnable();
		//showInterface();
		//alert(document.getElementsByName("h_interval1")[0].style);
		PrintWanTable();
	}
	
	-->
	</script>
	</head>

<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(PIM_SM_);doc(' ');doc(Setting_)</script></h1>
<form method="post" name="pimsm_setting" target="mid">
<fieldset>
 <input type="hidden" name="wan" id="wan" value="" >
 <input type="hidden" name="pimsm_dr_tmp" id="pimsm_dr_tmp" value="">
 <input type="hidden" name="SRV_VCONF_ROUT_UPDATE_tmp" id="vlantmp" value="" >
 <% net_Web_csrf_Token(); %>
 <table border="0">  
 	<tr>
 	<td>			
	<table border="0" style="width:700px">
 	 <tr align="left">
 		<td align="left" width="300px">Shortest Path Tree switchover method</td>
 		<td align="left"><script language="JavaScript">fnGenSelect(sptselstate, '')</script></td>
 	 </tr>
 	</table>			
	</td>
	</tr>
 	<tr>
 		<td></td>
 	</tr>
 	<tr>
			<td>
			
			<table border="0" id="show_available_table" style="width:700px">
		     <tr align="left">			
    			<th style="width=6%"><script language="JavaScript">doc(Enable_)</script></th>
    		    <th style="width=22%"><script language="JavaScript">doc(Interface_);doc(' ');doc(Name_)</script></th>
    		    <th style="width=14%"><script language="JavaScript">doc(IP_Address)</script></th>
    			<th style="width=22%"><script language="JavaScript">doc(Hello_Interval_)</script></th>
    			<th style="width=6%"><script language="JavaScript">doc(Dr_Priority_)</script></th>
    			<th style="width=30%"><script language="JavaScript">doc(J_P_Interval_)</script></th>			
		  	 </tr>
		  	</table>			
			</td>
			</tr>
 	<tr>
 		<td></td>
 	</tr>	
 	<tr>
 		<td align="left">
 			<table border="0"><tr><td width="700px" style="text-align:right;">
 				<script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script>				
 			</td></tr></table>
 		</td>
 	</tr>
 </table>
</fieldset>
</form>
</body>
</html>