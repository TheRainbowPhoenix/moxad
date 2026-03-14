<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

var rp_election = 0;
var cbsr_priority = 0;
var cbsr_hash_mask_length = 4;
var crp_priority = 0;


var addb = 'Add';
var modb = 'Modify';

var rpelection = [
	{ value:0x00, text:'Bootstrap' },
	{ value:0x01,text:'Static' }
];

if (!debug) {
	var SRV_PIMSMRPS = {
		
	};
}else{
	{{ net_Web_show_value('SRV_PIMSMRPS') | safe }}
	{{ net_Web_show_value('SRV_PIMSMSSMS') | safe }}
}


	//var pimsm_enable = false;
	//var rp_election = 0;
	//var cbsr_priority = 0;
	//var cbsr_hash_mask_length = 4;
	//var crp_priority = 0;

	//var crp_group = new Array(new Array('224.224.0.0', 16), new Array('225.225.0.0', 16), new Array('239.239.239.0', 24));
	//var srp_group = new Array(new Array('192.168.129.252', '224.0.0.0', 8), new Array('192.168.129.253', '225.225.0.0', 16));

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

	function setPIMSMEnable()
	{
		var j;
		if(pimsm_enable == true)
		{
			for(j=0; j < document.getElementsByTagName("input").length; j++)
			{
				document.getElementsByTagName("input")[j].disabled = false;
			}
			document.getElementById("pimsmRPElection").disabled = false;

			document.getElementById('btn_add_crp').disabled = false;
			document.getElementById('btn_modify_crp').disabled = false;
			document.getElementById('btn_delete_crp').disabled = false;
			document.getElementById('btn_add_srp').disabled = false;
			document.getElementById('btn_modify_srp').disabled = false;
			document.getElementById('btn_delete_srp').disabled = false;
		}
		else
		{
			for(j=0; j < document.getElementsByTagName("input").length; j++)
			{
				document.getElementsByTagName("input")[j].disabled = true;
			}
			document.getElementById("pimsmRPElection").disabled = true;

			document.getElementById('btn_add_crp').disabled = true;
			document.getElementById('btn_modify_crp').disabled = true;
			document.getElementById('btn_delete_crp').disabled = true;
			document.getElementById('btn_add_srp').disabled = true;
			document.getElementById('btn_modify_srp').disabled = true;
			document.getElementById('btn_delete_srp').disabled = true;
		}
	}

	function ChangeRpElection()
	{
		switch(document.getElementById('pimsmRPElection').options.selectedIndex)
		{
		case 0:
			// Bootstrap
			document.getElementById('tbl_rp_bootstrap').style.display = '';
			document.getElementById('tbl_rp_static').style.display = 'none';
			break;
		case 1:
		default:
			// Static RP
			document.getElementById('tbl_rp_bootstrap').style.display = 'none';
			document.getElementById('tbl_rp_static').style.display = '';
			break;
		}
	}

	var selectedCrpGroupIndex = -1;
	function ReloadCrpTable()
	{
		var tbl_crp_group_addr = document.getElementById('tbl_crp_group_address');
		// Clean the C-RP group table
		while(tbl_crp_group_addr.rows.length > 1)
		{
			tbl_crp_group_addr.deleteRow(-1);
		}
		// Build the C-RP group table
		for(var i = 0; i < crp_group.length; i++)
		{
			var row_crp = tbl_crp_group_addr.insertRow(tbl_crp_group_addr.rows.length);
			row_crp.style.backgroundColor = 'white';
			//row_crp.className = "r1";
			// Attach the click event
			if(this.isIE)
				row_crp.attachEvent("onclick", SelectCrpGroup);
			else
				row_crp.addEventListener("click", SelectCrpGroup);

			var cell = row_crp.insertCell(0);
			cell.align = 'center';
			//cell.style.width = '360';
			cell.innerHTML = crp_group[i]["g_group_addr"];
			cell = row_crp.insertCell(1);
			cell.align = 'center';
			cell.innerHTML = crp_group[i]["g_group_mask"];
			/*cell = row_crp.insertCell(2);
			cell.innerHTML = '<input type="hidden" id=g_group_addr'+i+' name="g_group_addr'+i+'" value='+crp_group[i][0]+'>';	
			cell = row_crp.insertCell(3);
			cell.innerHTML = '<input type="hidden" id=g_group_mask'+i+' name="g_group_mask'+i+'" value='+crp_group[i][1]+'>';*/
		}

		selectedCrpGroupIndex = -1;

		// Show the add button
		//document.getElementById('btn_add_crp').style.display = '';
		// Hide the delete and modify button
		//document.getElementById('btn_delete_crp').style.display = 'none';
		//document.getElementById('btn_modify_crp').style.display = 'none';

		// Empty the C-RP group address/mask field
		document.getElementById('txt_crp_group_address').value = '';
		document.getElementById('txt_crp_group_mask').value = '';
	}

	var selectedSrpGroupIndex = -1;
	function ReloadSrpTable()
	{
		var tbl_srp_group_addr = document.getElementById('tbl_srp_group_address');
		// Clean the static RP group table
		while(tbl_srp_group_addr.rows.length > 0)
		{
			tbl_srp_group_addr.deleteRow(-1);
		}

		// Build the static RP group table
		for(var i = 0; i < srp_group.length; i++)
		{
			var row_crp = tbl_srp_group_addr.insertRow(tbl_srp_group_addr.rows.length);
			row_crp.style.backgroundColor = 'white';
			row_crp.className = "r1";
			// Attach the click event
			
			if(this.isIE)
				row_crp.attachEvent("onclick", SelectSrpGroup);
			else
				row_crp.addEventListener("click", SelectSrpGroup);

			var cell = row_crp.insertCell(0);
			cell.style.width = '233';
			cell.innerHTML = srp_group[i]["s_group_addr"];
			cell = row_crp.insertCell(1);
			cell.style.width = '233';
			cell.innerHTML = srp_group[i]["s_group_mask"];
			cell = row_crp.insertCell(2);
			cell.style.width = '234';
			cell.innerHTML = srp_group[i]["s_rp_address"];
		}
		selectedSrpGroupIndex = -1;

		// Show the add button
		//document.getElementById('btn_add_srp').style.display = '';
		// Hide the delete and modify button
		//document.getElementById('btn_delete_srp').style.display = 'none';
		//document.getElementById('btn_modify_srp').style.display = 'none';

		// Empty the static RP group address/mask field
		document.getElementById('txt_srp_address').value = '';
		document.getElementById('txt_srp_group_address').value = '';
		document.getElementById('txt_srp_group_mask').value = '';
	}

	function SelectCrpGroup()
	{
		e=window.event?window.event:e; 
		var ObjTd=e.srcElement?e.srcElement:e.target; 
		var ObjTr=ObjTd.parentNode; 
		var y=ObjTr.rowIndex; 
		var x=ObjTd.cellIndex; 

		var index = y;
		var tbl_crp_group_addr = document.getElementById('tbl_crp_group_address');
		if(pimsm_enable == false)
			return;

		// Cancel the previous selected C-RP group index
		if(selectedCrpGroupIndex >= 0)
			tbl_crp_group_addr.rows[selectedCrpGroupIndex].style.backgroundColor = 'white';

		if(selectedCrpGroupIndex == index)
		{
			selectedCrpGroupIndex = -1;

			// Show the add button
			//document.getElementById('btn_add_crp').style.display = '';
			// Hide the delete and modify button
			//document.getElementById('btn_delete_crp').style.display = 'none';
			//document.getElementById('btn_modify_crp').style.display = 'none';

			// Empty the C-RP group address/mask field
			document.getElementById('txt_crp_group_address').value = '';
			document.getElementById('txt_crp_group_mask').value = '';
		}
		else
		{
			// Select the C-RP group index
			selectedCrpGroupIndex = index;
			tbl_crp_group_addr.rows[selectedCrpGroupIndex].style.backgroundColor = '#00ff66';

			// Hide the add button
			//document.getElementById('btn_add_crp').style.display = 'none';
			// Show the delete and modify button
			//document.getElementById('btn_delete_crp').style.display = '';
			//document.getElementById('btn_modify_crp').style.display = '';

			// Load the selected C-RP group address/mask value
			document.getElementById('txt_crp_group_address').value = crp_group[index-1]["g_group_addr"];
			document.getElementById('txt_crp_group_mask').value = crp_group[index-1]["g_group_mask"];
		}
	}

	function SelectSrpGroup()
	{
		e=window.event?window.event:e; 
		var ObjTd=e.srcElement?e.srcElement:e.target; 
		var ObjTr=ObjTd.parentNode; 
		var y=ObjTr.rowIndex; 
		var x=ObjTd.cellIndex; 

		var index = y;
		var tbl_srp_group_addr = document.getElementById('tbl_srp_group_address');

		if(pimsm_enable == false)
			return;

		// Cancel the previous selected static RP group index
		if(selectedSrpGroupIndex >= 0)
			tbl_srp_group_addr.rows[selectedSrpGroupIndex].style.backgroundColor = 'white';

		if(selectedSrpGroupIndex == index)
		{
			selectedSrpGroupIndex = -1;

			// Show the add button
			//document.getElementById('btn_add_srp').style.display = '';
			// Hide the delete and modify button
			//document.getElementById('btn_delete_srp').style.display = 'none';
			//document.getElementById('btn_modify_srp').style.display = 'none';

			// Empty the static RP address/group/mask field
			document.getElementById('txt_srp_address').value = '';
			document.getElementById('txt_srp_group_address').value = '';
			document.getElementById('txt_srp_group_mask').value = '';
		}
		else
		{
			// Select the static RP group index
			selectedSrpGroupIndex = index;
			tbl_srp_group_addr.rows[selectedSrpGroupIndex].style.backgroundColor = '#00ff66';

			// Hide the add button
			//document.getElementById('btn_add_srp').style.display = 'none';
			// Show the delete and modify button
			//document.getElementById('btn_delete_srp').style.display = '';
			//document.getElementById('btn_modify_srp').style.display = '';

			// Load the selected static RP group address/mask value
			document.getElementById('txt_srp_address').value = srp_group[index]["s_rp_address"];
			document.getElementById('txt_srp_group_address').value = srp_group[index]["s_group_addr"];
			document.getElementById('txt_srp_group_mask').value = srp_group[index]["s_group_mask"];
		}
	}

	function CheckSubnetSSM(ip, mask){
		var i;
		var ssm_group_name="ss_group_addr";
		var ssm_mask_name="ss_group_mask";
		
		if(SRV_PIMSMSSMS["ssm_enable"]){
			for(i = 0 ; i < 8 && SRV_PIMSMSSMS[ssm_group_name+i]!="0.0.0.0"; i++)
			{				
				if(fnIp2Net(ip,mask) < fnIp2Net(SRV_PIMSMSSMS[ssm_group_name+i], SRV_PIMSMSSMS[ssm_mask_name+i])){					
					if(fnIp2Net(ip,mask)==fnIp2Net(SRV_PIMSMSSMS[ssm_group_name+i],mask)){												
						return 1;
					}
				}else{
					if(fnIp2Net(ip,SRV_PIMSMSSMS[ssm_mask_name+i])==fnIp2Net(SRV_PIMSMSSMS[ssm_group_name+i],SRV_PIMSMSSMS[ssm_mask_name+i])){
						return 1;
					}
				}
			
			}
			return 0;
		}

	}


	function AddCrpGroup()
	{
		if(crp_group.length >= PIMSM_MAX_CRP_GROUP_NUM) {
			alert("The maximum candidate RP group number is " + PIMSM_MAX_CRP_GROUP_NUM);
			return;
		}
		if(CheckSubnetSSM(document.getElementById('txt_crp_group_address').value, document.getElementById('txt_crp_group_mask').value)){
			alert("The group address is inused in PIM-SSM");
			return;
		}
		// Add the new C-RP group address
		//crp_group.push(new Array(document.getElementById('txt_crp_group_address').value, document.getElementById('txt_crp_group_mask').value));
		crp_group[crp_group.length] = new Array;
		crp_group[crp_group.length-1]["g_group_addr"]=document.getElementById('txt_crp_group_address').value;
		crp_group[crp_group.length-1]["g_group_mask"]=document.getElementById('txt_crp_group_mask').value;
		// Reload the C-RP Table
		ReloadCrpTable();
	}

	function AddSrpGroup()
	{
		if(srp_group.length >= PIMSM_MAX_STATIC_RP_NUM) {
			alert("The maximum static RP group number is " + PIMSM_MAX_STATIC_RP_NUM);
			return;
		}
		if(CheckSubnetSSM(document.getElementById('txt_srp_group_address').value, document.getElementById('txt_srp_group_mask').value)){
			alert("The group address is inused in PIM-SSM");
			return;
		}
		// Add the new static RP group address
		//srp_group.push(new Array(document.getElementById('txt_srp_address').value, document.getElementById('txt_srp_group_address').value, document.getElementById('txt_srp_group_mask').value));
		srp_group[srp_group.length] = new Array;
		srp_group[srp_group.length-1]["s_rp_address"]=document.getElementById('txt_srp_address').value;
		srp_group[srp_group.length-1]["s_group_addr"]=document.getElementById('txt_srp_group_address').value;
		srp_group[srp_group.length-1]["s_group_mask"]=document.getElementById('txt_srp_group_mask').value;
		// Reload the static RP Table
		ReloadSrpTable();
	}

	function ModifyCrpGroup()
	{
		var index = selectedCrpGroupIndex-1;
		if(CheckSubnetSSM(document.getElementById('txt_crp_group_address').value, document.getElementById('txt_crp_group_mask').value)){
			alert("The group address is inused in PIM-SSM");
			return;
		}
		if((index >= 0) && (index < PIMSM_MAX_CRP_GROUP_NUM))
		{
			// Modify it
			crp_group[index]["g_group_addr"] = document.getElementById('txt_crp_group_address').value;
			crp_group[index]["g_group_mask"] = document.getElementById('txt_crp_group_mask').value;

			// Reload the C-RP Table
			ReloadCrpTable();
		}
	}

	function ModifySrpGroup()
	{
		if(CheckSubnetSSM(document.getElementById('txt_srp_group_address').value, document.getElementById('txt_srp_group_mask').value)){
			alert("The group address is inused in PIM-SSM");
			return;
		}
		if((selectedSrpGroupIndex >= 0) && (selectedSrpGroupIndex < srp_group.length))
		{
			// Modify it
			srp_group[selectedSrpGroupIndex]["s_rp_address"] = document.getElementById('txt_srp_address').value;
			srp_group[selectedSrpGroupIndex]["s_group_addr"] = document.getElementById('txt_srp_group_address').value;
			srp_group[selectedSrpGroupIndex]["s_group_mask"] = document.getElementById('txt_srp_group_mask').value;

			// Reload the static RP Table
			ReloadSrpTable();
		}
	}

	function DeleteCrpGroup()
	{
		var index = selectedCrpGroupIndex-1;	
		if((index >= 0) && (index < PIMSM_MAX_CRP_GROUP_NUM))
		{
			// Remove it
			crp_group.splice(index, 1);

			// Reload the C-RP Table
			ReloadCrpTable();
		}
	}

	function DeleteSrpGroup()
	{
		if((selectedSrpGroupIndex >= 0) && (selectedSrpGroupIndex < srp_group.length))
		{
			// Remove it
			srp_group.splice(selectedSrpGroupIndex-1, 1);

			// Reload the static RP Table
			ReloadSrpTable();
		}
	}

	function fnInit()
	{
		var i;
		// Initial the PIM-SM statusz
		document.getElementById('txt_cbsr_priority').value = SRV_PIMSMRPS.cbsr_priority;
		document.getElementById('txt_cbsr_hash_mask').value = SRV_PIMSMRPS.cbsr_mask_len;
		document.getElementById('txt_crp_priority').value = SRV_PIMSMRPS.crp_priority;
		pimsm_enable = 1;

		/*for(i=crp_group.length-1;i>=0;i--){		
			if(crp_group[i]["g_group_addr"]=="0.0.0.0"){
				crp_group.splice(i,1);
			}else{
				break;
			}
		}
		for(i=srp_group.length-1;i>=0;i--){
			if(srp_group[i]["s_rp_address"]=="0.0.0.0"){
				srp_group.splice(i,1);
			}else{
				break;
			}
		}*/
		
		PIMSM_MAX_CRP_GROUP_NUM = crp_group_MAX;
		PIMSM_MAX_STATIC_RP_NUM = srp_group_MAX;
		setPIMSMEnable();
		if(SRV_PIMSMRPS.elec_method == 0)
			document.getElementById('pimsmRPElection').options.selectedIndex = 0;
		else
			document.getElementById('pimsmRPElection').options.selectedIndex = 1;
		ChangeRpElection();
		
		
		/*for(i=0;i<PIMSM_MAX_CRP_GROUP_NUM;i++){
			if(crp_group[i]["g_group_addr"]=="0.0.0.0"){
				break;
			}else{
				crp_group.push(new Array(crp_group[i]["g_group_addr"], crp_group[i]["g_group_mask"]));
			}
		}
		
		for(i=0;i<PIMSM_MAX_STATIC_RP_NUM;i++){
			if(srp_group[i]["s_rp_address"]=="0.0.0.0"){
				break;
			}else{
				srp_group.push(new Array(srp_group[i]["s_rp_address"], srp_group[i]["s_group_addr"], srp_group[i]["s_group_mask"]));	
			}
		}*/		
		ReloadCrpTable();
		ReloadSrpTable();
	}
	
	function active(form)
	{
		var i, j;
		for(i = 0 ; i < crp_group.length ; i++)
		{
			for (j in crp_group[i]){
				form.crp_group_tmp.value = form.crp_group_tmp.value + crp_group[i][j] + "+";	
			}	
		}
		for(i = 0 ; i < srp_group.length ; i++)
		{
			for (j in srp_group[i]){				
				form.srp_group_tmp.value = form.srp_group_tmp.value + srp_group[i][j] + "+";	
			}	
		}
		if(pimsm_enable == true)
		{			
			document.pimsm_rp_setting.action="/goform/net_Web_get_value?SRV=SRV_PIMSMRPS";
			document.pimsm_rp_setting.submit();
		}
	}
	function stopSubmit()
	{
		return false;
	}
   -->
	</script>
	</head>

<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(PIM_SM_);doc(' ');doc(RP_);doc(' ');doc(Setting_)</script></h1>
<form method="post" name="pimsm_rp_setting">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="crp_group_tmp" id="crp_group_tmp" value="">
<input type="hidden" name="srp_group_tmp" id="srp_group_tmp" value="">
<table border="0" style="width:700px"><tr><td>
	<table class=intable border="0">
		<tr align="left">
			<td width="250" align="left"><h2>PIM-SM RP Election</h2></td>
			<td width="450" align="left"></td>
		</tr>
		<tr align="left">
			<td align="left">PIM-SM RP election method</td>
			<td align="left"><script language="JavaScript">iGenSel3('elec_method', 'pimsmRPElection', rpelection, "ChangeRpElection")</script></td>
		</tr>
		<tr align="left">
			<td colspan="2" align="left">
				<table class=intable id="tbl_rp_static" style="display: none">					
					</tr>					
					<tr >
						<td align="left">Group address</td>
						<td align="left"><input type="text" id="txt_srp_group_address" size="15" maxlength="15"></td>
					</tr>
					<tr >
						<td align="left">Group address mask</td>
						<td align="left"><input type="text" id="txt_srp_group_mask" size="15" maxlength="15"></td>
					</tr>
					<tr >
						<td width="250" align="left">RP address</td>
						<td width="450" align="left"><input type="text" id="txt_srp_address" size="15" maxlength="15"></td>
					</tr>
					<tr><td colspan="2" align="left">
						<table border="0">
						<tr>
						<td width="400px" style="text-align:center;"><script language="JavaScript">fnbnBID(addb, 'onClick=AddSrpGroup()', 'btn_add_srp')</script>
						<script language="JavaScript">fnbnBID(modb, 'onClick=ModifySrpGroup()', 'btn_modify_srp')</script>
						<script language="JavaScript">fnbnBID(delb, 'onClick=DeleteSrpGroup()', 'btn_delete_srp')</script></td>
						<td width="300px" style="text-align:right;"><script language="JavaScript">fnbnSID(Submit_, 'onClick=active((this.form))','btnU')</script></td>
						</tr>
						</table>
						</td>												
					</tr>
					<tr align="center">
						<td colspan="2"><table><tr>						
						<th width="233">Group Address</td>
						<th width="233">Group Address Mask</td>
						<th width="234">RP Address</td>
						</tr></table>
						</td>
					</tr>
					<tr>
						<td colspan="2">
							<table id="tbl_srp_group_address" border="0">
							</table>
						</td>
					</tr>
				</table>
				<table class=intable id="tbl_rp_bootstrap" border="0">
					<tr>
						<td align="left" width="250">Candidate BSR priority</td>
						<td align="left" width="450"><input type="text" name="cbsr_priority" id="txt_cbsr_priority" size="1" maxlength="3">
						0 is the lowest</td>
					</tr>
					<tr>
						<td align="left">Candidate BSR hash mask length</td>
						<td align="left"><input type="text" name="cbsr_mask_len" id="txt_cbsr_hash_mask" size="1" maxlength="2"></td>
					</tr>
					<tr>
						<td align="left">Candidate RP priority</td>
						<td align="left"><input type="text" size="1" name="crp_priority" id="txt_crp_priority" maxlength="3">
						0 is the highest</td>
					</tr>
					<tr>
						<td></td>
					</tr>
					<tr>
						<td colspan=2 width="250" align="left"><h2>Group Setting</h2></td>
					</tr>
					<tr>
						<td align="left">Group address</td>
						<td align="left"><input type="text" id="txt_crp_group_address" size="15" maxlength="15"></td>
					</tr>
					<tr>
						<td align="left">Group address mask</td>
						<td align="left"><input type="text" id="txt_crp_group_mask" size="15" maxlength="15"></td>
					</tr>
					<tr>
						<td colspan="2" align="left">
						<table border="0">
						<tr>
						<td width="400px"><script language="JavaScript">fnbnBID(addb, 'onClick=AddCrpGroup()', 'btn_add_crp')</script>
						<script language="JavaScript">fnbnBID(modb, 'onClick=ModifyCrpGroup()', 'btn_modify_crp')</script>
						<script language="JavaScript">fnbnBID(delb, 'onClick=DeleteCrpGroup()', 'btn_delete_crp')</script></td>
						<td width="300px"><script language="JavaScript">fnbnSID(Submit_, 'onClick=active((this.form))','btnU')</script></td>
						</tr>
						</table>
						</td>
					</tr>					
					<tr>
						<td colspan="2"><!--div style="height:80px;overflow:auto;"-->
							<table id="tbl_crp_group_address" border="0">
							<tr align="center">
								<th width="350px">Multicast Group address</td>
								<th width="350px">Group address mask</td>
							</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</td></tr></table>
</fieldset>
<input type="hidden" name="crpData" value="" id="crpData">
<input type="hidden" name="srpData" value="" id="srpData">
</form>
</body>
</html>
