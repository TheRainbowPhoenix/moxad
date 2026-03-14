<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
	<!--
var pimsm_enable = false;
var pimsm_ssm_enable = false;
var PIMSM_MAX_SSM_GROUP_NUM = 8;
var ssm_group = new Array();

if (!debug) {
	var SRV_PIMSMSSMS = {
		
	};
}else{
	{{ net_Web_show_value('SRV_PIMSMSSMS') | safe }}
	{{ net_Web_show_value('SRV_PIMSMRPS') | safe }}
}


	//var pimsm_enable = false;
	//var pimsm_ssm_enable = false;

	//var ssm_group = new Array(new Array('224.224.0.0', 16), new Array('225.225.0.0', 16), new Array('239.239.239.0', 24));

	// Judge the user's browser
	var sAgent = navigator.userAgent.toLowerCase();
	this.isIE = (sAgent.indexOf('msie')!=-1); //IE6.0-7
	this.isFF = (sAgent.indexOf('firefox')!=-1);//firefox
	this.isSa = (sAgent.indexOf('safari')!=-1);//safari
	this.isOp = (sAgent.indexOf('opera')!=-1);//opera
	this.isNN = (sAgent.indexOf('netscape')!=-1);//netscape
	this.isMa = this.isIE;//marthon
	this.isOther = (!this.isIE && !this.isFF && !this.isSa && !this.isOp && !this.isNN && !this.isSa);//unknown Browser

	function touchLasttime()
	{
							theName = "lasttime";
					expires = null;
					now=new Date( );
					document.cookie =theName + "=" + now.getTime() + "; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());

	}
	function CheckCookie()
	{
		
	}

	function setPIMSMEnable()
	{
		var j;
		if(pimsm_enable == true)
		{
			for(j=0;j < document.getElementsByTagName("input").length; j++)
			{
				document.getElementsByTagName("input")[j].disabled = false;
			}

			document.getElementById('btn_add_ssm').disabled = false;
			document.getElementById('btn_modify_ssm').disabled = false;
			document.getElementById('btn_delete_ssm').disabled = false;
		}
		else
		{
			for(j=0;j < document.getElementsByTagName("input").length; j++)
			{
				document.getElementsByTagName("input")[j].disabled = true;
			}

			document.getElementById('btn_add_ssm').disabled = true;
			document.getElementById('btn_modify_ssm').disabled = true;
			document.getElementById('btn_delete_ssm').disabled = true;
		}
	}

	var selectedSSMGroupIndex = -1;
	function ReloadSSMTable()
	{
		var tbl_ssm_group_addr = document.getElementById('tbl_ssm_group_address');

		// Clean the SSM group table
		while(tbl_ssm_group_addr.rows.length > 0)
		{
			tbl_ssm_group_addr.deleteRow(-1);
		}

		// Build the SSM group table
		for(var i = 0; i < ssm_group.length; i++)
		{
			var row_ssm = tbl_ssm_group_addr.insertRow(tbl_ssm_group_addr.rows.length);
			row_ssm.style.backgroundColor = 'white';
			//row_ssm.className = "r1";
			// Attach the click event
			if(this.isIE)
				row_ssm.attachEvent("onclick", SelectSSMGroup);
			else
				row_ssm.addEventListener("click", SelectSSMGroup);

			var cell = row_ssm.insertCell(0);
			cell.style.width = '350';
			cell.align = 'center';			
			cell.innerHTML = ssm_group[i][0]+'<input type="text" style="display:none;" id=ss_group_addr'+i+' name="ss_group_addr'+i+'" value='+ssm_group[i][0]+'>';
			cell = row_ssm.insertCell(1);
			cell.style.width = '350';
			cell.align = 'center';
			cell.innerHTML = ssm_group[i][1]+'<input type="text" style="display:none;" id=ss_group_mask'+i+' name="ss_group_mask'+i+'" value='+ssm_group[i][1]+'>';
			/*cell = row_ssm.insertCell(2);
			cell.innerHTML = ;	
			cell = row_ssm.insertCell(3);
			cell.innerHTML = ;*/
		}

		selectedSSMGroupIndex = -1;

		// Show the add button
		//document.getElementById('btn_add_ssm').style.display = '';
		// Hide the delete and modify button
		//document.getElementById('btn_delete_ssm').style.display = 'none';
		//document.getElementById('btn_modify_ssm').style.display = 'none';

		// Empty the SSM group address/mask field
		document.getElementById('txt_ssm_group_address').value = '';
		document.getElementById('txt_ssm_group_mask').value = '';
	}

	function SelectSSMGroup()
	{
		e=window.event?window.event:e; 
		var ObjTd=e.srcElement?e.srcElement:e.target; 
		var ObjTr=ObjTd.parentNode; 
		var y=ObjTr.rowIndex; 
		var x=ObjTd.cellIndex; 

		var index = y;
		var tbl_ssm_group_addr = document.getElementById('tbl_ssm_group_address');

		if(pimsm_enable == false)
			return;

		// Cancel the previous selected SSM group index
		if(selectedSSMGroupIndex >= 0)
			tbl_ssm_group_addr.rows[selectedSSMGroupIndex].style.backgroundColor = 'white';

		if(selectedSSMGroupIndex == index)
		{
			selectedSSMGroupIndex = -1;

			// Show the add button
			//document.getElementById('btn_add_ssm').style.display = '';
			// Hide the delete and modify button
			//document.getElementById('btn_delete_ssm').style.display = 'none';
			//document.getElementById('btn_modify_ssm').style.display = 'none';

			// Empty the SSM group address/mask field
			document.getElementById('txt_ssm_group_address').value = '';
			document.getElementById('txt_ssm_group_mask').value = '';
		}
		else
		{
			// Select the SSM group index
			selectedSSMGroupIndex = index;
			tbl_ssm_group_addr.rows[selectedSSMGroupIndex].style.backgroundColor = '#00ff66';

			// Hide the add button
			//document.getElementById('btn_add_ssm').style.display = 'none';
			// Show the delete and modify button
			//document.getElementById('btn_delete_ssm').style.display = '';
			//document.getElementById('btn_modify_ssm').style.display = '';

			// Load the selected SSM group address/mask value
			document.getElementById('txt_ssm_group_address').value = ssm_group[index][0];
			document.getElementById('txt_ssm_group_mask').value = ssm_group[index][1];
		}
	}

	function CheckSubnetRP(ip, mask){
		var i;
		var ssm_group_name="ss_group_addr";
		var ssm_mask_name="ss_group_mask";
		
		if(SRV_PIMSMSSMS["ssm_enable"]){
			for(i = 0 ; i < crp_group.length; i++)
			{				
				if(fnIp2Net(ip,mask) < fnIp2Net(crp_group[i]["g_group_addr"], crp_group[i]["g_group_mask"])){					
					if(fnIp2Net(ip,mask)==fnIp2Net(crp_group[i]["g_group_addr"],mask)){												
						return 1;
					}
				}else{
					if(fnIp2Net(ip,crp_group[i]["g_group_mask"])==fnIp2Net(crp_group[i]["g_group_addr"],crp_group[i]["g_group_mask"])){
						return 1;
					}
				}
			
			}
			
			for(i = 0 ; i < srp_group.length; i++)
			{				
				if(fnIp2Net(ip,mask) < fnIp2Net(srp_group[i]["s_group_addr"], srp_group[i]["s_group_mask"])){					
					if(fnIp2Net(ip,mask)==fnIp2Net(srp_group[i]["s_group_addr"],mask)){												
						return 1;
					}
				}else{
					if(fnIp2Net(ip,srp_group[i]["s_group_mask"])==fnIp2Net(srp_group[i]["s_group_addr"],srp_group[i]["s_group_mask"])){
						return 1;
					}
				}
			
			}
			return 0;
		}

	}

	function AddSSMGroup()
	{
		if(ssm_group.length >= PIMSM_MAX_SSM_GROUP_NUM) {
			alert("The maximum PIMSM SSM group number is " + PIMSM_MAX_SSM_GROUP_NUM);
			return;
		}
		if(CheckSubnetRP(document.getElementById('txt_ssm_group_address').value, document.getElementById('txt_ssm_group_mask').value)){
			alert("The group address is inused in RP Setting");
			return;
		}
		// Add the new SSM group address
		ssm_group.push(new Array(document.getElementById('txt_ssm_group_address').value, document.getElementById('txt_ssm_group_mask').value));

		// Reload the SSM Table
		ReloadSSMTable();
	}

	function ModifySSMGroup()
	{
		if((selectedSSMGroupIndex >= 0) && (selectedSSMGroupIndex < ssm_group.length))
		{
			// Modify it
			ssm_group[selectedSSMGroupIndex][0] = document.getElementById('txt_ssm_group_address').value;
			ssm_group[selectedSSMGroupIndex][1] = document.getElementById('txt_ssm_group_mask').value;

			// Reload the SSM Table
			ReloadSSMTable();
		}
	}

	function DeleteSSMGroup()
	{
		if((selectedSSMGroupIndex >= 0) && (selectedSSMGroupIndex < ssm_group.length))
		{
			// Remove it
			ssm_group.splice(selectedSSMGroupIndex, 1);

			// Reload the SSM Table
			ReloadSSMTable();
		}
	}

	function fnInit()
	{
		var i;

		// Initial the PIM-SM status
		pimsm_ssm_enable = SRV_PIMSMSSMS.ssm_enable;
		pimsm_enable = 1;
		PIMSM_MAX_SSM_GROUP_NUM=0;
		document.getElementById('pimsmSSMEnableCheckbox').checked = pimsm_ssm_enable==0?false:true;		
		for(i in SRV_PIMSMSSMS){
			if(i.substring(0, 13)=="ss_group_mask")
			{			
				if(ipMask2Number(SRV_PIMSMSSMS["ss_group_mask"+PIMSM_MAX_SSM_GROUP_NUM])>=4){					
					ssm_group.push(new Array(SRV_PIMSMSSMS["ss_group_addr"+PIMSM_MAX_SSM_GROUP_NUM], SRV_PIMSMSSMS["ss_group_mask"+PIMSM_MAX_SSM_GROUP_NUM]));
				}
				PIMSM_MAX_SSM_GROUP_NUM++;
			}
		}
		
		setPIMSMEnable();
		ReloadSSMTable();
	}
	function active()
	{
		if(pimsm_enable == true)
		{
			// Build the PIMSM SSM data
			/*for(var i = 0; i < ssm_group.length; i++)
			{
				document.getElementById('ssmData').value += (ssm_group[i][0] + ";");
				document.getElementById('ssmData').value += (ssm_group[i][1] + ";");				
			}*/
			document.pimsm_ssm_setting.action="/goform/net_Web_get_value?SRV=SRV_PIMSMSSMS";
			document.pimsm_ssm_setting.submit();
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
<h1><script language="JavaScript">doc(PIM_SM_);doc(' ');doc(SSM_);doc(' ');doc(Setting_)</script></h1>
<form onClick="touchLasttime()" onkeypress="touchLasttime()" method="post" name="pimsm_ssm_setting">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<table border="0" style="width:700" cellpadding="0" cellspacing="0"><tr><td>	
	<table width="700" align="center" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td colspan="2" align="left"><h2>PIM-SM SSM Range</h2></td>
		</tr>
		<tr align="left">
			<td width="30px"><input type="checkbox" name="ssm_enable" id="pimsmSSMEnableCheckbox"></td>
			<td width="670px"><script language="JavaScript">doc(' ');doc(Enable_)</script></td>			
		</tr>
		<tr>
			<td colspan="2" align="left"><div>
				<table width="700" border="0">					
					<tr align="left">
						<td align="left" width="200">Group address</td>
						<td align="left" width="150"><input type="text" id="txt_ssm_group_address" size="15" maxlength="15"></td>
						<td align="left" width="350"></td>
					</tr>
					<tr align="left">
						<td align="left">Group address mask</td>
						<td align="left"><input type="text" id="txt_ssm_group_mask" size="15" maxlength="15"></td>
						<td align="left"></td>
					</tr>
					<tr>
						<td colspan="3" align="left">
						<table border="0">
						<tr>						
						<td width="400px" style="text-align:left;"><script language="JavaScript">fnbnBID(addb, 'onClick=AddSSMGroup()', 'btn_add_ssm')</script>
						<script language="JavaScript">fnbnBID(modb, 'onClick=ModifySSMGroup()', 'btn_modify_ssm')</script>
						<script language="JavaScript">fnbnBID(delb, 'onClick=DeleteSSMGroup()', 'btn_delete_ssm')</script></td>
						<td width="300px" style="text-align:left;"><script language="JavaScript">fnbnSID(Submit_, 'onClick=active()', 'btnU')</script></td></td>
					</tr>
					<tr>
						<td colspan="3" width="700">					
							<table border="0" width="700">
								<tr align="center">
							  		<th align="center" width="350">Multicast Group address</td>
							  		<th align="center" width="350">Group address mask</td>
							  	</tr>
							</table>
						</td>					
					</tr>
					<tr>
						<td colspan="3">
							<table id="tbl_ssm_group_address" border="0" width="700">
							</table>
						</td>
					</tr>
				</table></div>
			</td>
		</tr>
	</table>
</td></tr></table>
</fieldset>
</form>
</body>
</html>
