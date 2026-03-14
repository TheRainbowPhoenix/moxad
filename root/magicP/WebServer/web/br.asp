<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>

<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();

if (!debug) {
    var SRV_BRG = { ip:'192.168.1.1', mask:'255.255.255.0' };
}else{
	<%net_Web_show_value('SRV_BRG');%>
    <%net_Web_show_value('SRV_VCONF');%>
    <%net_Web_show_value('SRV_VPLAN');%>
	<%net_Web_show_value('SRV_VLAN');%>
	<%net_Web_show_value('SRV_IP_CLIENT');%>
	<%net_Web_show_value('SRV_TRUNK_SETTING');%>
	<%net_Web_show_value('SRV_ZONE_BRG');%>
	Ipset = [<%net_websIpset();%>]
}

var LanForm;
var newdata = new Array;
var table_idx = 0;
var tablefun = new table_show(document.getElementsByName('LanForm'), "show_available_table", SRV_BRG_type, SRV_BRG, table_idx, newdata, Brg_Addformat, check_brgMember_and_setLimitation);
var zone_brg_tablefun = new table_show(document.getElementsByName('LanForm'), "show_available_table", SRV_ZONE_BRG_type, SRV_ZONE_BRG, table_idx, newdata, Brg_Addformat, check_brgMember_and_setLimitation);
var DSYS_PORT =10;

var PORT_BASE = 0;
var ZONE_BASE = 1;

var COPER_PORT = 8;

var PORT_BASE_PVID_BASE = 4040;

var brg_type_name = [
	{ value:0, text:'Port-Base' },
    { value:1, text:'Zone-Base'}
];

var selstate = { type:'select', id:'brg_type', name:'brg_type', size:1, onChange:'fnChgLType(this.value)', option:brg_type_name };

var vid_count,port_count=0, trk_count=0;

var is_allPort_inZoneBrg;

/******************************************************************
 *	Purpose:	re load form if document.getElementById("brg_type").value has been change
 * 	Inputs: 	brg_type_value - document.getElementById("brg_type").value: bridge type
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/20
 ******************************************************************/
function fnReloadForm_byChg_brg_type(brg_type_value)
{
	LanForm = document.getElementById('LanForm');

	/* port-base bridge */
	if(brg_type_value == PORT_BASE){
	    fnLoadForm(LanForm, SRV_BRG[0], SRV_BRG_type);

		if(check_brg_port()){
	        document.getElementById("goose").disabled = true;
	    }
	    ChgColor('tri', SRV_BRG.length, 0);
	}
	/* zone-base bridge */
	else{
	    fnLoadForm(LanForm, SRV_ZONE_BRG[0], SRV_ZONE_BRG_type);
	    ChgColor('tri', SRV_ZONE_BRG.length, 0);
	}

	/* enable the checkbox of those bridge members that are involved in bridge. */
	check_brgMember_and_setLimitation(0);
}

function fnChgLType(val) {
	/* port-base bridge */
	if(val == 0){
		document.getElementById("port_base_member").style.display="";
		document.getElementById("zone_base_member").style.display="none";
	}
	/* zone-base bridge */
	else{
		document.getElementById("port_base_member").style.display="none";
		document.getElementById("zone_base_member").style.display="";
	}

	/* reload form because of using different config. SRV_BRG or SRV_ZONE_BRG. */
	fnReloadForm_byChg_brg_type(val);

	/* open checkbox of googe if available.*/
	Brg_open_goose();
}

/******************************************************************
 *	Purpose:	when fnInit, show to the exact config field by bridge type.
 *				without Brg_open_goose();
 * 	Inputs: 	val - selection value.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/25
 ******************************************************************/
function fnChgLType_fnInit(val) {
	/* port-base bridge */
	if(val == 0){
		document.getElementById("port_base_member").style.display="";
		document.getElementById("zone_base_member").style.display="none";
	}
	/* zone-base bridge */
	else{
		document.getElementById("port_base_member").style.display="none";
		document.getElementById("zone_base_member").style.display="";
	}

	/* reload form because of using different config. SRV_BRG or SRV_ZONE_BRG. */
	fnReloadForm_byChg_brg_type(val);
}

function Brg_fnChgIface(value) {
	if(if_data.length<=1)
		return;
	if(value == ""&&chflag==0xff){
		value = 0;
	}else if(value == ""){
		value=chflag;
	}
	table_index.value=value;
	if(chflag == value){
		return;
	}else{
		chflag = value;
	}
	if(table_index.value){
		tablefun.show();
		//VConf_Total_IP();
		//fnLoadForm(LanForm, if_data[value][0], SRV_VCONF_type);
	}else{
		table_index.value=value;
	}
	if(value == 0){
		document.getElementById("vlan_interface").disabled=true;
	}


}

/******************************************************************
 *	Purpose:	select to the correct options of bridge type when fnInit.
 *	Input:		N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/20
 ******************************************************************/
function select_brg_type_when_fnInit()
{
	var i;
	var member_vid_var;

	var is_zoneBrg = 0;

	for(i=0; i<SRV_ZONE_BRG.length; i++){
		for(j=0; j<SRV_VPLAN.length; j++){
			member_vid_var = "member_vid" + j;

			if(parseInt(SRV_ZONE_BRG[i][member_vid_var]) > 0){
				is_zoneBrg = 1;
				break;
			}
		}
	}

	/* zone base */
	if(is_zoneBrg){
		document.getElementById("brg_type").value = ZONE_BASE;
	}
	/* port base */
	else{
		document.getElementById("brg_type").value = PORT_BASE;
	}

	/* show to the exact config field by bridge type. */
	fnChgLType_fnInit(document.getElementById("brg_type").value);
}

/******************************************************************
 *	Purpose:	Set the checkbox to true/false by finding the vlanid of
 				SRV_VLAN which is the same as bridge_member_vid of SRV_BRG
 				in current config entry.
 * 	Inputs: 	row - currnt config entry we are in now.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/15
 ******************************************************************/
function choose_portBase_brgMember(row)
{
	var bridge_member_vid_idx;
	var element;
	var brgMember_fieldID;	/* the config field ID of each bridge member. */

	var i;

	/* initialize every checkbox. */
	for(i=0; i<parseInt(port_count); i++){
		brgMember_fieldID = "port_brg_member_port" + i;
		document.getElementById(brgMember_fieldID).checked = "";
	}

	/* check the checkbox if this port is involved in port-base bridge. */
	for(i=0; i<SRV_VPLAN.length; i++){

		brgMember_fieldID = "port_brg_member_port" + i;

		if(SRV_VPLAN[i].bridge_group_id > 0){
			document.getElementById(brgMember_fieldID).checked = "true";
		}
	}
}

/******************************************************************
 *	Purpose:	Set the checkbox to true/false by finding the vlanid of
 				SRV_VLAN which is the same as bridge_member_vid of SRV_ZONE_BRG
 				in current config entry.
 * 	Inputs: 	row - currnt config entry we are in now.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/15
 ******************************************************************/
function choose_zoneBase_brgMember(row)
{
	var member_vid_idx;
	var element;
	var brgMember_fieldID;	/* the config field ID of each bridge member. */

	var member_vid_var;	/* variable name in SRV_BRG: member_vid0 ~ member_vid15 */
	var i;

	/*** initialize every checkbox. ***/
	/* zone-1 */
	for(i = 0; i < SRV_VPLAN.length; i++){
		brgMember_fieldID = "zone1_brg_member_vid" + SRV_VPLAN[i].pvid;

		/* if this variable is exist. */
		element = document.getElementById(brgMember_fieldID);
		if (element != null) {
			document.getElementById(brgMember_fieldID).checked = "";
		}
	}
	/* zone-2 */
	for(i = 0; i < SRV_VPLAN.length; i++){
		brgMember_fieldID = "zone2_brg_member_vid" + SRV_VPLAN[i].pvid;

		/* if this variable is exist. */
		element = document.getElementById(brgMember_fieldID);
		if (element != null) {
			document.getElementById(brgMember_fieldID).checked = "";
		}
	}

	/*** check the checkbox if vid is equal. ***/
	/* zone-1 */
	for(i=0; i < SRV_VPLAN.length; i++){

		brgMember_fieldID = "zone1_brg_member_vid" + SRV_VPLAN[i].pvid;

		member_vid_var = "member_vid0";

		if(SRV_VPLAN[i].pvid == SRV_ZONE_BRG[row][member_vid_var] && SRV_VPLAN[i].pvid != 0){
			document.getElementById(brgMember_fieldID).checked = "true";
			break;
		}
	}

	/* zone-2 */
	for(i=0; i < SRV_VPLAN.length; i++){

		brgMember_fieldID = "zone2_brg_member_vid" + SRV_VPLAN[i].pvid;

		member_vid_var = "member_vid1";

		if(SRV_VPLAN[i].pvid == SRV_ZONE_BRG[row][member_vid_var] && SRV_VPLAN[i].pvid != 0){
			document.getElementById(brgMember_fieldID).checked = "true";
			break;
		}
	}
}

/******************************************************************
 *	Purpose:	show the zone-name in input field.
 * 	Inputs: 	row - currnt config entry we are in now.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/25
 ******************************************************************/
function show_zoneBase_zoneName(row)
{
	/* zone-1 */
	document.getElementById("zone1_name").value = SRV_ZONE_BRG[row]["member_name0"];

	/* zone-2 */
	document.getElementById("zone2_name").value = SRV_ZONE_BRG[row]["member_name1"];
}

/******************************************************************
 *	Purpose:	1.) Set the checkbox to true/false by finding the vlanid of
 				SRV_VLAN which is the same as bridge_member_vid of SRV_BRG
 				in current config entry.
 				2.) if port-base bridge, enable/goose checkbox should be limited.
 * 	Inputs: 	row - currnt config entry we are in now.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/15
 ******************************************************************/
function check_brgMember_and_setLimitation(row)
{
	if(document.getElementById("brg_type").value == PORT_BASE){
		/* enable bridge member's checkbox. */
		choose_portBase_brgMember(row);
	}
	else{
		/* enable bridge member's checkbox. */
		choose_zoneBase_brgMember(row);

		/* show zone name. */
		show_zoneBase_zoneName(row);
	}

	/* limitation of port-base bridge setting. */
	//port_base_brgLimitation(row);
}

function Brg_Addformat(mod,i)
{
	var j=0;
	var k;
	for(k in SRV_BRG_type){
        if(mod == 0){
            if(k == "ifnameUsr"){
                newdata[j] = SRV_BRG[i][k];
            }else if(k == "enable"){
        	    if(SRV_BRG[i][k] == 1){
				    newdata[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
                }else{
	    			newdata[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
                }
            }else if(k == "ip" || k == "mask"){
                newdata[j] = SRV_BRG[i][k];
            }else if(k == "bridge_group_id" || k == "stp") {
                continue;
            }else if(k == "goose"){
				if(SRV_BRG[i][k] == 1)
					newdata[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
				else
					newdata[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
            }else{
                continue;
            }
        }else{
            if(k == "ifnameUsr"){
                newdata[j] = document.getElementById('LanForm')[k];
            }else if(k == "enable"){
		        if(document.getElementById('LanForm')[k].checked==true)
				    newdata[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
    			else
	    			newdata[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
            }else if(k == "ip" || k == "mask"){
                newdata[j] = document.getElementById('LanForm')[k];
            }else if(k == "bridge_group_id" || k == "stp") {
                continue;
            }else if(SRV_BRG_type[k] == 3){
                if(document.getElementById('LanForm')[k].checked==true)
				    newdata[j]="<IMG src=" + 'images/enable_3.gif'+ ">";
    			else
	    			newdata[j]= "<IMG src=" + 'images/disable_3.gif'+ ">";
            }else{
                continue;
            }
        }
		j++;
	}
}
/*
function Total_IP()
{
	if(SRV_BRG[table_index.value].length > BRG_MAX || SRV_BRG[table_index.value].length  < 0){
    alert('Number of IP is over or wrong');
		with(document){
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = true;
		}
	}else if(SRV_BRG[table_index.value].length == BRG_MAX){
		with (document) {
			getElementById('btnA').disabled = true;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else if(SRV_BRG[table_index.value].length == 1){
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = true;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}else{
		with (document) {
			getElementById('btnA').disabled = false;
			getElementById('btnD').disabled = false;
			getElementById('btnM').disabled = false;
			getElementById('btnS').disabled = false;
		}
	}
	//document.getElementById("totalipcnt").innerHTML = VLAN_IF_List + ' ('+if_data[table_index.value].length +'/' +VLAN_MAX+')';
}

*/
/*TODO check gid*/
/*
function check_vlan_inuse( vlanid, sel){
	var i,j;


	for(i=0;i< Ipset.length;i++){
		if(Ipset[i].vid==vlanid)
			return 0;
	}

	for(i = 0 ; i < wan0.length ; i++)
	{
		for(j = 0 ; j < if_data[i].length ; j++)
		{
			if((sel == 2) && (j == tNowrow_Get())) { // "Modify" clicked ignore the now row
				continue;
			}
			if(if_data[i][j].vid==vlanid)
				return 2;
		}
	}
	return 1;
}
*/

/*
	Return:
		0 is OK, otherwise name contains whitespaces
*/
function hasWhiteSpace(name) {
	if (/\s/.test(name)) {
    	// It has any kind of whitespace
		return 1;
	}
	else
		return 0;
}

/*
	Return:
		0 is OK, otherwise name is conflict
*/

function lan_checkIfname(name, sel)
{
	var i, j;

    /*
	for(i = 0 ; i < wan0.length ; i++) {
		for(j = 0 ; j < if_data[i].length ; j++) {
			if((sel == 2) && (j == tNowrow_Get())) { // "Modify" clicked ignore the now row
				continue;
			}

			//alert(if_data[i][j].ifname);
			if(if_data[i][j].ifname == name) { // name conflict
				return 1;
			}
		}
	}
    */
	return 0;
}

var if_data=new Array;
var vidsel = [{ value:"0", text:"--------"}];


function show_vlan(){
	var i, idx, len;

	idx=0;
	len = document.getElementById("vid").options.length;
	for(i = 0;i < len;i++){
		document.getElementById("vid").options.remove(i);
	}

	for(i=0; i < SRV_VLAN.length; i++){
		if(check_vlan_inuse(SRV_VLAN[i].vlanid, 0)){
			var varItem = new Option(SRV_VLAN[i].vlanid, SRV_VLAN[i].vlanid);
          	document.getElementById("vid").options.add(varItem);
			idx++;
		}
	}
}

var VLAN_CHECK_TABLE=new Array(4095);
function check_port_vlan_member()
{
	var i,k, name;
	for(i = 0; i < 4095; i++)
 		VLAN_CHECK_TABLE[i] = new Array;



	for(k=0; k < port_count+trk_count; k++){

		/*
		if(!document.getElementById("type"+k)||document.getElementById("type"+k).value==0)
			continue;
		name = "tagvid"+k;
		for(i=0;i<document.getElementById(name).value.split(',').length;i++){
			if(document.getElementById(name).value.split(',')[i] == "")
					continue;

			if(!isValidVid(document.getElementById(name).value.split(',')[i])) {
				alert("Tagged VLAN id is invalid !");
				return -1;
			}
			VLAN_CHECK_TABLE[document.getElementById(name).value.split(',')[i]]["checked"]=1;
			VLAN_CHECK_TABLE[document.getElementById(name).value.split(',')[i]][k]=1;
		}

		if(document.getElementById("type"+k).value==1)
			continue;
		name = "untagvid"+k;
		for(i=0;i<document.getElementById(name).value.split(',').length;i++){
			if(document.getElementById(name).value.split(',')[i] == "")
				continue;

			if(!isValidVid(document.getElementById(name).value.split(',')[i])) {
				alert("Untagged VLAN id is invalid !");
				return -1;
			}


			VLAN_CHECK_TABLE[document.getElementById(name).value.split(',')[i]]["checked"]=1;
			VLAN_CHECK_TABLE[document.getElementById(name).value.split(',')[i]][k]=2;
		}
		*/
	}
	return 1; // OK
}

/******************************************************************
 *	Purpose:	check port-base brg member config is legal.
 * 	Inputs: 	row_idx - bridge config table entry.
 * 	Return:		0: fail, it is illegal.
 *				1: ok, it is legal.
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/29
 ******************************************************************/
function check_portBase_brg_member_legal(row_idx)
{
	var i;
	var brgMember_fieldID;
	var total_port_brg_member;

	var elemnt;
	total_port_brg_member = 0;
	for(i = 0; i < SRV_VPLAN.length; i++){

		/* ready the checkbox id of the bridge member */
		brgMember_fieldID = "port_brg_member_port" + i;

		/* if this variable is exist. */
		element = document.getElementById(brgMember_fieldID);
		if (element != null) {
			if(document.getElementById(brgMember_fieldID).checked == true){	// if the bridge memeber has been checked.
				total_port_brg_member++;
			}
		}
	}

	if(document.getElementById("enable").checked == true){
		/* Can not enable port-Base bridge without bridge member. */
		if(total_port_brg_member == 0){
			alert("[Error] Must assign a port.");
			return 0;
		}
	}
	return 1;
}

/******************************************************************
 *	Purpose:	check zone-base brg member config is legal.
 * 	Inputs: 	row_idx - bridge config table entry.
 * 	Return:		0: fail, it is illegal.
 *				1: ok, it is legal.
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/29
 ******************************************************************/
function check_zoneBase_brg_member_legal(row_idx)
{
	var i;
	var j;
	var brgMember_fieldID;
	var total_zone1_brg_member;
	var total_zone2_brg_member;
	var elemnt;
	var isSettableVid;

	var record_zone1_vid_list = new Array(SRV_VPLAN.length);	// for record the vid which's checkbox has been printed. avoid record twice.
	var record_zone2_vid_list = new Array(SRV_VPLAN.length);	// for record the vid which's checkbox has been printed. avoid record twice.

	var zone1_pvid;
	var zone2_pvid;

	/* zone-1 */
	total_zone1_brg_member = 0;
	for(i = 0; i < SRV_VPLAN.length; i++){

		/* ready the checkbox id of the bridge member */
		brgMember_fieldID = "zone1_brg_member_vid" + SRV_VPLAN[i].pvid;
		isSettableVid = 1;

		for(j=0; j<SRV_VPLAN.length; j++){
			if(record_zone1_vid_list[j] == SRV_VPLAN[i].pvid){
				isSettableVid = 0;
			}
		}

		if(isSettableVid){
			/* if this variable is exist. */
			element = document.getElementById(brgMember_fieldID);
			if (element != null) {
				if(document.getElementById(brgMember_fieldID).checked == true){	// if the bridge memeber has been checked.
					total_zone1_brg_member++;
					zone1_pvid = SRV_VPLAN[i].pvid;
					record_zone1_vid_list[total_zone1_brg_member] = SRV_VPLAN[i].pvid;
				}

			}
		}
	}
	if(total_zone1_brg_member > 1){
		alert("[Error] Allow only one VLAN segment (VID) in each zone.");
		return 0;
	}

	/* zone-2 */
	total_zone2_brg_member = 0;
	for(i = 0; i < SRV_VPLAN.length; i++){

		/* ready the checkbox id of the bridge member */
		brgMember_fieldID = "zone2_brg_member_vid" + SRV_VPLAN[i].pvid;
		isSettableVid = 1;

		for(j=0; j<SRV_VPLAN.length; j++){
			if(record_zone2_vid_list[j] == SRV_VPLAN[i].pvid){
				isSettableVid = 0;
			}
		}

		if(isSettableVid){
			/* if this variable is exist. */
			element = document.getElementById(brgMember_fieldID);
			if (element != null) {
				if(document.getElementById(brgMember_fieldID).checked == true){	// if the bridge memeber has been checked.
					total_zone2_brg_member++;
					zone2_pvid = SRV_VPLAN[i].pvid;
					record_zone2_vid_list[total_zone2_brg_member] = SRV_VPLAN[i].pvid;
				}
			}
		}
	}
	if(total_zone2_brg_member > 1){
		alert("[Error] Allow only one VLAN segment (VID) in each zone.");
		return 0;
	}

	/* check member total and zone name */
	if(document.getElementById("enable").checked == true){
		/* Can not enable Zone-Base bridge without bridge member. */
		if(total_zone1_brg_member == 0 || total_zone2_brg_member == 0){
			alert("[Error] Must assign VLAN segment (VID) to each zone.");
			return 0;
		}

		/*Can not enable Zone-Base bridge with zone name in error format. */
		if(total_zone1_brg_member > 0 && isSymbol(document.getElementById("zone1_name"), "Zone-1 Name")){
			return 0;
		}

		/*Can not enable Zone-Base bridge with zone name in error format. */
		if(total_zone2_brg_member > 0 && isSymbol(document.getElementById("zone2_name"), "Zone-2 Name")){
			return 0;
		}

		/* Can not duplicated Zone Name */
		if(document.getElementById("zone1_name").value == document.getElementById("zone2_name").value){
			alert("[Error] Duplicated zone name.");
			return 0;
		}
		/* Can not duplicated Zone VID */
		if(total_zone1_brg_member == 1 && total_zone2_brg_member == 1){
			if(zone1_pvid == zone2_pvid ){
				alert("[Error] Each VLAN segment (VID) can only be assigned to one zone.");
				return 0;
			}
		}
	}

	return 1;
}

/******************************************************************
 *	Purpose:	check brg member config is legal.
 * 	Inputs: 	row_idx - bridge config table entry.
 * 	Return:		0: fail, it is illegal.
 *				1: ok, it is legal.
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/29
 ******************************************************************/
function check_brg_member_legal(row_idx)
{
	var ret;

	if(document.getElementById("brg_type").value == PORT_BASE){
		if(!check_portBase_brg_member_legal(row_idx)){
			return 0;
		}
	}
	else{
		if(!check_zoneBase_brg_member_legal(row_idx)){
			return 0;
		}
	}
	return 1;
}

/******************************************************************
 *	Purpose:	check it the vid is tagged vlan id
 * 	Inputs: 	vid
 * 	Return:		0: no, it is illegal.
 *				1: yes
 * 	Author: 	Kevin Haung
 * 	Date: 		2016/03/04
 ******************************************************************/
function is_TaggedVlan(vid)
{
	var i;
	var j;
	var vlan_port_name;
	var is_available_vid = 0;

	for(i=0; i<SRV_VLAN.length; i++){
		if(vid == SRV_VLAN[i].vlanid){
			is_available_vid = 1;
			for(j=0; j<port_count+trk_count; j++){
				vlan_port_name = "port" + j;
				if(SRV_VLAN[i][vlan_port_name] == 2){
					return 0;
				}
			}
		}
	}

	if(is_available_vid){
		return 1;
	}
	else{
		return 0;
	}
}

var manageID = new Array;	/* to record management vid. we won't do any change to this. */

/******************************************************************
 *	Purpose:	write the bridge memeber to the SRV_VLAN and SRV_VPLAN
 * 	Inputs: 	row_idx - bridge config table entry.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/29
 ******************************************************************/
function edit_portBase_brg_member(row_idx)
{
	var i;
	var j;
	var pvid;

	var brgMember_fieldID;
	var vlan_port_name;

	var change_pvid = new Array(4096);

	var is_find;
	var is_ok;

	/* to record management vid. we won't do any change to this. */
	manageID = SRV_VLAN[0];	/* mamagement vid is always at first SRV_VLAN config entry. */
	//alert(manageID["vlanid"]);

	/*** edit SRV_VPLAN ***/
	if(SRV_BRG[0].enable){	/* if port-base bridge is enabled. */

		for(i=0; i<parseInt(port_count); i++){
			pvid = PORT_BASE_PVID_BASE;

			brgMember_fieldID = "port_brg_member_port" + i;

			if(document.getElementById(brgMember_fieldID).checked){
				/* set the bridge own pvid */
				is_ok = 0;
				while(is_ok != 1){
					is_find = 0;
					for(j=0; j<SRV_VPLAN.length; j++){
						if(i!=j && pvid == SRV_VPLAN[j].pvid){
							is_find = 1;	/* this pvid now is used by others port. */
							break;
						}
						else if(is_TaggedVlan(pvid) == 1){
							is_find = 1;	/* this pvid now is used by tagged vlan. */
							break;
						}
					}




					if(is_find){
						pvid++;	/* try another pvid. */
					}
					else{
						is_ok = 1;
					}
				}

				//alert("brgMember_fieldID="+brgMember_fieldID+", pvid="+pvid+", SRV_VPLAN[4].pvid="+SRV_VPLAN[4].pvid);

				/* record what pvid has been changed. */
				change_pvid[SRV_VPLAN[i].pvid] = 1;



				/* if this port belongs to management VID originally, and now is changing, set 0 to SRV_VLAN[0].portX */
				vlan_port_name = "port" + i;
				if(SRV_VPLAN[i].pvid == SRV_VLAN[0].vlanid && SRV_VPLAN[i].pvid != pvid){
					SRV_VLAN[0][vlan_port_name] = 0;
				}


				/* set pvid. */
				SRV_VPLAN[i].pvid = pvid;
				pvid++;	/* for next bridge port use. */

				/* set to access port */
				SRV_VPLAN[i].accepttype = 0;

				/* set filert */
				SRV_VPLAN[i].filert = 0;

				/* set type */
				SRV_VPLAN[i].type = 0;

				/* set the bridge id. */
				SRV_VPLAN[i].bridge_group_id = 8001;

			}
			else{
				SRV_VPLAN[i].bridge_group_id = 0;
			}

		}
	}
	else{	/* remove all bridge port. */
		for(i=0; i<parseInt(port_count); i++){
			SRV_VPLAN[i].bridge_group_id = 0;
		}
	}

	/*** edit SRV_VLAN ***/

	var is_end_of_table = 0;

	/* delete the vlan which is changed because of being bridge port. */
	for(i=0; i<SRV_VLAN.length; i++){
		for(j=0; j<change_pvid.length; j++){
			if(change_pvid[j] == 1 && j == SRV_VLAN[i].vlanid){
				/* if i==0, this is management VID. is is unable to delete. */
				if(i != 0){
					//alert("SRV_VLAN["+i+"].vlanid="+SRV_VLAN[i].vlanid);
					SRV_VLAN.splice(i, 1);
					if(SRV_VLAN.length == i){
						is_end_of_table = 1 /* now SRV_VLAN has shorter then index, so we have to exit looping. */
						break;
					}
				}
			}
		}
		if(is_end_of_table){	/* now SRV_VLAN has shorter then index, so we have to exit looping. */
			break;
		}
	}

	/* add the the bridge port's vlan information. */
	for(i=0; i<SRV_VPLAN.length; i++){
		/* add new entry into SRV_VLAN */
		if(SRV_VPLAN[i].bridge_group_id > 0){

			if(SRV_VPLAN[i].pvid == manageID.vlanid){

				/* set portX */

				vlan_port_name = "port" + i;

				SRV_VLAN[0][vlan_port_name] = 2;


			}
			else{
				/* increase array length. */
				SRV_VLAN[SRV_VLAN.length] = new Array;

				/* set pvid. */
				SRV_VLAN[SRV_VLAN.length - 1].vlanid = SRV_VPLAN[i].pvid;

				/* set portX */
				for(j=0; j < port_count+trk_count; j++){
					vlan_port_name = "port" + j;
					if(j == i){
						SRV_VLAN[SRV_VLAN.length - 1][vlan_port_name] = 2;
					}
					else{
						SRV_VLAN[SRV_VLAN.length - 1][vlan_port_name] = 0;
					}

				}
			}
		}
	}
}

/******************************************************************
 *	Purpose:	write the bridge memeber to the XXX
 * 	Inputs: 	row_idx - bridge config table entry.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/29
 ******************************************************************/
function edit_zoneBase_brg_member(row_idx)
{
	var brgMember_fieldID;
	var i;
	var j;
	var isSettableVid;

	var total_of_brg_member;
	var member_vid_var;
	var member_name_var;

	var element;

	var brg_member_max = SRV_VPLAN.length;
	var record_vid_list = new Array(brg_member_max);	// for record the vid which's checkbox has been printed. avoid record twice.

	/* initialize all bridge_member_vid in SRV_VLAN[row_idx] */
	for(i = 0; i < SRV_VPLAN.length; i++){
		member_vid_var = "member_vid" + i;
		SRV_ZONE_BRG[row_idx][member_vid_var] = 0;
	}

	total_of_brg_member = 0;	// to record how many vid has been involved in bridge.

	/* record zone-1 vid if checkbox is enabled. */
	for(i = 0; i < SRV_VPLAN.length; i++){

		/* ready the checkbox id of the bridge member */
		brgMember_fieldID = "zone1_brg_member_vid" + SRV_VPLAN[i].pvid;
		member_vid_var = "member_vid0";
		member_name_var = "member_name0";

		/* if this vid has been in record, we don't save this vid again. */
		isSettableVid = 1;
		for(j=0; j<total_of_brg_member; j++){
			if(SRV_VPLAN[i].pvid == record_vid_list[j]){
				isSettableVid = 0;	// this vid has been printed, ignore this
			}
		}

		if(isSettableVid){
			/* if this variable is exist. */
			element = document.getElementById(brgMember_fieldID);
			if (element != null) {
				if(document.getElementById(brgMember_fieldID).checked == true){	// if the bridge memeber has been checked.
					/* set the bridge id into SRV_BRG.member_vidX. */
					SRV_ZONE_BRG[row_idx][member_vid_var] = SRV_VPLAN[i].pvid;

					/* set the name into SRV_BRG.member_nameX. */
					SRV_ZONE_BRG[row_idx][member_name_var] = document.getElementById("zone1_name").value;

					/* record this pvid's checkbox has been save. */
					record_vid_list[total_of_brg_member] = SRV_ZONE_BRG[row_idx][member_vid_var];
					total_of_brg_member++;
					break;
				}

			}
		}
	}

	/* record zone-2 vid if checkbox is enabled. */
	for(i = 0; i < SRV_VPLAN.length; i++){

		/* ready the checkbox id of the bridge member */
		brgMember_fieldID = "zone2_brg_member_vid" + SRV_VPLAN[i].pvid;
		member_vid_var = "member_vid1";
		member_name_var = "member_name1";

		/* if this vid has been in record, we don't save this vid again. */
		isSettableVid = 1;
		for(j=0; j<total_of_brg_member; j++){
			if(SRV_VPLAN[i].pvid == record_vid_list[j]){
				isSettableVid = 0;	// this vid has been printed, ignore this
			}
		}

		if(isSettableVid){
			/* if this variable is exist. */
			element = document.getElementById(brgMember_fieldID);
			if (element != null) {
				if(document.getElementById(brgMember_fieldID).checked == true){	// if the bridge memeber has been checked.
					/* set the bridge id into SRV_BRG.member_vidX. */
					SRV_ZONE_BRG[row_idx][member_vid_var] = SRV_VPLAN[i].pvid;

					/* set the name into SRV_BRG.member_nameX. */
					SRV_ZONE_BRG[row_idx][member_name_var] = document.getElementById("zone2_name").value;

					/* record this pvid's checkbox has been save. */
					record_vid_list[total_of_brg_member] = SRV_ZONE_BRG[row_idx][member_vid_var];
					total_of_brg_member++;
					break;
				}

			}
		}
	}
}

/******************************************************************
 *	Purpose:	write the bridge memeber to the SRV_XXX
 * 	Inputs: 	row_idx - bridge config table entry.
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/29
 ******************************************************************/
function edit_brg_member_inSRV(row_idx)
{
	if(document.getElementById("brg_type").value == PORT_BASE){
		edit_portBase_brg_member(row_idx);
	}
	else{
		edit_zoneBase_brg_member(row_idx);
	}
}

/******************************************************************
 *	Purpose:	port-base and zone-base bridge can not be enabled at the same time.
 *				so if enable port-base brg, we will disable zone-base brg in active.
 *				otherwise, enable zone-base brg, we will disable port-base brg in active.
 * 	Inputs: 	N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/24
 ******************************************************************/
function mutual_exclusive_brg_type()
{
	var i;
	var j;
	var member_vid_var;
	var member_name_var;

	var is_brgEnable;	// 0: not, 1: yes

	is_brgEnable = 0;

	if(document.getElementById("brg_type").value == PORT_BASE){


		/* disable zone-base bridge. */
		for(i=0; i<SRV_ZONE_BRG.length; i++){
			SRV_ZONE_BRG[i]["enable"] = 0;
			SRV_ZONE_BRG[i]["goose"] = 0;
		}


		/* clear zone-base member_vid and zone name. */
		for(i=0; i<SRV_ZONE_BRG.length; i++){
			for(j=0; j<SRV_VPLAN.length; j++){
				member_vid_var = "member_vid" + j;
				member_name_var = "member_name" + j;

				SRV_ZONE_BRG[i][member_vid_var] = 0;
				SRV_ZONE_BRG[i][member_name_var] = "";
			}
		}
	}
	else{
		/* disable port-base bridge. */
		for(i=0; i<SRV_BRG.length; i++){
			SRV_BRG[i]["enable"] = 0;
			SRV_BRG[i]["goose"] = 0;
		}

		/* disable port-base bridge id. */
		for(i=0; i<SRV_VPLAN.length; i++){
			SRV_VPLAN[i].bridge_group_id = 0;
		}
	}
}

function modify_SRV_XXX(row_idx)
{
	table_idx = row_idx;

	/* check data config field is legal. */
	if(!check_brg_member_legal(table_idx)){
		return 0;
	}

	/* modify what SRV_XXX is decided by bridge type. */
	if(document.getElementById("brg_type").value == PORT_BASE){
		tablefun.mod();
	}
	else{
		zone_brg_tablefun.mod();
	}

	/* tune the SRV_BRG's brg_member_id. */
	edit_brg_member_inSRV(table_idx);

	/* port-base and zone-base bridge can not be enabled at the same time. */
	mutual_exclusive_brg_type();

	return 1;
}

function Tabbtn_sel(form, sel)
{

    if(sel == 0 || sel == 2){
		if(sel == 0){ // "Add"
			table_idx = VLAN_MAX;
		}else{ // "Modify"
			table_idx = tNowrow_Get();
		}
	    if(!IpAddrNotMcastIsOK(form.ip, IP_Address) || !NetMaskIsOK(form.mask, Subnet_Mask))
		    return;
		if(!(IpAddrIsOK(form.ip, IP_Address)) || !(NetMaskIsOK(form.mask, Subnet_Mask)))
		{
			return;
		}

		if(lan_checkIfname(form.ifnameUsr.value, sel) != 0) {
			alert("The interface name is conflict !!");
			return;
		}
	}

	if(sel == 0){
		Brg_Addformat(1,0);
		tablefun.add();
	}else if(sel == 1){
		tablefun.del();
	}else if(sel == 2){	/* modify */

		/* check data config field is legal. */
		if(!check_brg_member_legal(table_idx)){
			return;
		}

		/* modify what SRV_XXX is decided by bridge type. */
		if(document.getElementById("brg_type").value == PORT_BASE){
			tablefun.mod();
		}
		else{
			zone_brg_tablefun.mod();
		}

		/* tune the SRV_BRG's brg_member_id. */
		edit_brg_member_inSRV(table_idx);

		/* port-base and zone-base bridge can not be enabled at the same time. */
		mutual_exclusive_brg_type();

		/* reload the bridge config table. */
		tablefun.reload();
	}
	//VConf_Total_IP();
}

function check_bridge_port(){
    var i=0;
    var brg_port_flag = 0;
    for(i=0; i<SRV_VPLAN.length; i++){
        if(SRV_VPLAN[i].bridge_group_id > 0){
            brg_port_flag =1 ;
            break;
        }
    }

    return brg_port_flag;
}

function check_all_bridge_port(){
    var i=0, brg_port_flag=1;
    for(i=0; i<SRV_VPLAN.length; i++){
        if(SRV_VPLAN[i].bridge_group_id > 0){
            brg_port_flag = 0;
            break;
        }
    }
    return brg_port_flag;
}

/******************************************************************
 *	Purpose:	to check if is there any bridge will be bring up after this summit.
 * 	Inputs: 	N/A
 * 	Return:		0 - there is no bridge after this summit.
 *				1 - here is one type of bridge will be bring up after this summit.
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/25
 ******************************************************************/
function is_brgEnable_inSRV()
{
	var i;
	for(i = 0; i < SRV_BRG.length ;i++){
		if(parseInt(SRV_BRG[i]["enable"]) > 0){
			return 1;
		}
	}
	for(i = 0; i < SRV_ZONE_BRG.length ;i++){
		if(parseInt(SRV_ZONE_BRG[i]["enable"]) > 0){
			return 1;
		}
	}

	return 0;
}

function Brg_Activate(form)
{
	document.getElementById("btnS").disabled = true;

	if(hasWhiteSpace(form.ifnameUsr.value) != 0){ // whitespace check
			alert("The interface name has whitespace !!");
			return;
	}

	/* if we want to disable bridge from enable state and all port are in the bridge, deny this. */
	if(document.getElementById("enable").checked == false){
		if(!confirm("[Warning] User will lose access control of the router from this network interface.")){
			document.getElementById("btnS").disabled = false;
			return;
		}
	}


	var i,j,k;
	var LanForm = document.getElementById('LanForm');

	if(!modify_SRV_XXX(0)){
		document.getElementById("btnS").disabled = false;
		return;
	}

	/*** ready SRV_BRG_tmp ****/
    for(i = 0; i < SRV_BRG.length ;i++){
        for(j in SRV_BRG[i]){
            if(j != "bridge_group_id"){
                form.brgtmp.value = form.SRV_BRG_tmp.value + SRV_BRG[i][j] + "+";
            }
            else{
                 form.brgtmp.value = form.SRV_BRG_tmp.value + "8001" + "+";
            }

        }
    }

	/*** ready SRV_ZONE_BRG_tmp ****/
	for(i = 0; i < SRV_ZONE_BRG.length ;i++){
        for(j in SRV_ZONE_BRG[i]){
            if(j != "bridge_group_id"){
                form.SRV_ZONE_BRG_tmp.value += SRV_ZONE_BRG[i][j] + "+";
            }
            else{
                 form.SRV_ZONE_BRG_tmp.value += "8002" + "+";
            }
        }
    }

	/*** ready SRV_VLAN_tmp ***/
	form.SRV_VLAN_tmp.value="";
	var min_pvid;
	var base_pvid = 0;

	/* SRV_VLAN[0] is reserved for management VID */
	for(j in SRV_VLAN[0]){
		form.SRV_VLAN_tmp.value += SRV_VLAN[0][j] + "+";
	}

	for(i=1; i<SRV_VLAN.length; i++){
		min_pvid = 4097;

		/* find the min. pvid. */
		for(k=1; k<SRV_VLAN.length; k++){
			if(parseInt(SRV_VLAN[k].vlanid) < parseInt(min_pvid) && parseInt(SRV_VLAN[k].vlanid) > parseInt(base_pvid)){
				min_pvid = SRV_VLAN[k].vlanid;
			}
		}

		/* set this min. pvid for finding next min. pvid. */
		base_pvid = min_pvid;

		/* write the SRV_VLAN_tmp from the entry who has the min. vlanid */
		for(k=1; k<SRV_VLAN.length; k++){
			if(SRV_VLAN[k].vlanid == min_pvid){

				/* write to form.SRV_VLAN_tmp.value */
				for(j in SRV_VLAN[k]){
					form.SRV_VLAN_tmp.value += SRV_VLAN[k][j] + "+";
				}
				break;
			}
		}
	}


	/*** ready SRV_VPLAN_tmp ***/
	form.SRV_VPLAN_tmp.value="";
	for(i=0;i<SRV_VPLAN.length;i++){
		for(j in SRV_VPLAN[i]){
			form.SRV_VPLAN_tmp.value += SRV_VPLAN[i][j] + "+";
		}
    }

	/* brg_auto_tmp and  brg_goose_tmp now are decided by config checkbox in this web page. */
	//form.brg_auto_tmp.value = check_bridge_port();
    //form.brg_goose_tmp.value = check_all_bridge_port();

	//alert(form.SRV_ZONE_BRG_tmp.value);
	//alert(form.brgtmp.value);
	//alert(form.SRV_VPLAN_tmp.value);
	//alert(form.SRV_VLAN_tmp.value);
	form.action="/goform/net_Web_get_value?SRV=SRV_VPLAN&SRV0=SRV_VLAN&SRV1=SRV_BRG&SRV2=SRV_ZONE_BRG";
	//form.action="/goform/net_Web_get_value?SRV=SRV_ZONE_BRG";
	form.submit();
}



function ChgLanIP() {
	var netwk = fnIp2Net( LanForm.lanip.value, LanForm.lanmask.value ) ;
	var same = 0;
	for (var i in wan)
		same |= (netwk==wan[i].netwk)
	if (same)
		alert(lan_alert);
}

function Activate(form)
{
	if(!IpAddrNotMcastIsOK(form.lanip, IP_Address) || !NetMaskIsOK(form.lanmask, Subnet_Mask))
		return;
	alert("If you change LAN IP address or Subnet Mask, maybe the DHCP Server, NAT, Firewall and more need reconfiguration");
	form.submit();
}

function check_brg_port()
{
    var idx;
    var flag = 0;
    for(idx=0; idx<DSYS_PORT; idx++){
	    if(SRV_VPLAN[idx].bridge_group_id == 0){
            flag = 1 ;
            return flag;
        }
    }
    return flag;
}

/******************************************************************
 *	Purpose:	to check if all port are in the zone-base bridge in config
 * 	Inputs: 	N/A
 * 	Return:		0 - at least one port is out of working zone-base bridge
 *				1 - now all port are in the zone-base bridge in config
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/25
 ******************************************************************/
function check_allPort_in_zoneBrg_bySRV_ZONE_BRG()
{
	var i;
	var j;

	var is_find_pvid_inBrg = 0;	// 0: no, 1: yes
	var is_allPort_inBrg = 1;	// 0: no, 1: yes
	var member_vid_var;

	for(i = 0; i < SRV_ZONE_BRG.length; i++){
		if(parseInt(SRV_ZONE_BRG[i]["enable"]) > 0){
			for(j = 0; j < parseInt(port_count); j++){
				if(parseInt(SRV_VPLAN[j].pvid) > 0){
					is_find_pvid_inBrg = 0;
					//alert("!!!");
					for(k=0; k<SRV_VPLAN.length; k++){
						member_vid_var = "member_vid" + k;

						if(SRV_ZONE_BRG[i][member_vid_var] == SRV_VPLAN[j].pvid){
							is_find_pvid_inBrg = 1;
							break;
						}
					}

				}

				/* if there is one pvid in SRV_VPLAN can't find in SRV_ZONE_BRG's member_vid, we will return 0. */
				if(!is_find_pvid_inBrg){
					is_allPort_inBrg = 0;
					break;
				}
			}
			if(!is_allPort_inBrg){
				break;
			}
		}
		else{
			is_allPort_inBrg = 0;
		}
	}

	/* all ports are in the zone-base bridge. */
	if(is_allPort_inBrg){
		return 1;
	}
	/* at least one port is out of the zone-base bridge. */
	else{
		return 0
	}
}

/******************************************************************
 *	Purpose:	to check if all port are in the bridge in config
 * 	Inputs: 	N/A
 * 	Return:		0 - at least one port is out of working bridge
 *				1 - now all port are in the bridge in config
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/25
 ******************************************************************/
function check_allPort_in_Brg_fnInit()
{
	if(document.getElementById("brg_type").value == PORT_BASE){
		if(check_brg_port()){
			return 0;
		}
		else{
			return 1;
		}
	}
	else{
		if(check_allPort_in_zoneBrg_bySRV_ZONE_BRG()){
			return 1;
		}
		else{
			return 0
		}
	}
}

function fnInit() {
	//Lan
    //document.getElementById("enable").disabled = true;
	LanForm = document.getElementById('LanForm');
	//Bridge Config
	tablefun.show();
/*
	fnLoadForm(LanForm, SRV_BRG[0], SRV_BRG_type);
    if(check_brg_port()){
        document.getElementById("goose").disabled = true;
    }
    ChgColor('tri', SRV_BRG.length, 0);
*/

	/* set brg_type and load the form. */
	select_brg_type_when_fnInit();

    /* set brg member and limitation of bridge setting. */
    check_brgMember_and_setLimitation(0);

	/* open checkbox of googe if available.*/
	Brg_open_goose();

	is_allPort_inZoneBrg = check_allPort_in_Brg_fnInit();
}

var trk_max=0;
var trk_group=new Array;
function set_trk_grup(){
	var i;
	trk_group[0]=new Array;
	trk_group[1]=new Array;
	for(i=0;i<port_count;i++){
		if(SRV_TRUNK_SETTING[i]["trkgrp"]>trk_max){
			trk_max = SRV_TRUNK_SETTING[i]["trkgrp"];
		}
		if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0){
			trk_group[0][(SRV_TRUNK_SETTING[i]["trkgrp"]-1)]=i;
			trk_group[1][(SRV_TRUNK_SETTING[i]["trkgrp"]-1)]|=1<<i;
		}
	}
}

/******************************************************************
 *	Purpose:	open goose's checkbox only when all ports are checked into port-base bridge.
 * 	Inputs: 	N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/28
 ******************************************************************/
function portBrg_open_goose()
{
	var i;
	var brgMember_fieldID;
	var is_allPort_inBrg = 1;	// 0: no, 1: yes

	var elemnt;

	for(i = 0; i < parseInt(port_count); i++){

		/* ready the checkbox id of the bridge member */
		brgMember_fieldID = "port_brg_member_port" + i;

		/* if this variable is exist. */
		element = document.getElementById(brgMember_fieldID);
		if (element != null) {
			if(document.getElementById(brgMember_fieldID).checked == false){	// if the bridge memeber has been checked.
				is_allPort_inBrg = 0;
				break;
			}
		}
	}

	/* all ports are in the port-base bridge. */
	if(is_allPort_inBrg){
		document.getElementById("goose").disabled = false;
	}
	/* at least one port is out of the port-base bridge. */
	else{
		document.getElementById("goose").disabled = true;
		/* if goose is disable to config, we hava to set the checkbox to false. */
		document.getElementById("goose").checked = false;
	}
}

/******************************************************************
 *	Purpose:	open goose's checkbox only when all vid are checked into zone-base bridge.
 * 	Inputs: 	N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/28
 ******************************************************************/
function zoneBrg_open_goose()
{
	var i;
	var j;
	var brgMember_fieldID;
	var is_find_pvid_inBrg = 1;	// 0: no, 1: yes
	var is_allPort_inBrg = 1;	// 0: no, 1: yes
	var elemnt;

	for(i = 0; i < parseInt(port_count); i++){
		if(parseInt(SRV_VPLAN[i].pvid) > 0){
			is_find_pvid_inBrg = 0;

			/* zone-1 */
			for(j=0; j < SRV_VPLAN.length; j++){
				/* ready the checkbox id of the bridge member */
				brgMember_fieldID = "zone1_brg_member_vid" + SRV_VPLAN[i].pvid;

				/* if this variable is exist. */
				element = document.getElementById(brgMember_fieldID);

				if (element != null) {
					if(document.getElementById(brgMember_fieldID).checked == true){	// if the bridge memeber has been checked.
						is_find_pvid_inBrg = 1;
						break;
					}
				}
			}

			/* zone-2 */
			for(j=0; j < SRV_VPLAN.length; j++){
				/* ready the checkbox id of the bridge member */
				brgMember_fieldID = "zone2_brg_member_vid" + SRV_VPLAN[i].pvid;

				/* if this variable is exist. */
				element = document.getElementById(brgMember_fieldID);

				if (element != null) {
					if(document.getElementById(brgMember_fieldID).checked == true){	// if the bridge memeber has been checked.
						is_find_pvid_inBrg = 1;
						break;
					}
				}
			}

			if(!is_find_pvid_inBrg){
				is_allPort_inBrg = 0;
			}
		}
	}

	/* all ports are in the zone-base bridge. */
	if(is_allPort_inBrg){
		document.getElementById("goose").disabled = false;
	}
	/* at least one port is out of the zone-base bridge. */
	else{
		document.getElementById("goose").disabled = true;
		/* if goose is disable to config, we hava to set the checkbox to false. */
		document.getElementById("goose").checked = false;
	}

}

/******************************************************************
 *	Purpose:	open goose's checkbox only when all vid are checked into bridge.
 * 	Inputs: 	N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/28
 ******************************************************************/
function Brg_open_goose()
{
	if(document.getElementById("brg_type").value == PORT_BASE){
		portBrg_open_goose();
	}
	else{
		zoneBrg_open_goose();
	}
}

/******************************************************************
 *	Purpose:	print the checkbox for each bridge memebers in config field.
 * 	Inputs: 	N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/28
 ******************************************************************/
function Print_portBase_BrgMember()
{
	var i;
	var j;
	var name;
	var columIdx = 0;

	var brgMember_fieldID;

	var brg_member_total = SRV_VPLAN.length;

	/* print all acceptable port base members */
	document.write('<table id="port_base_member">');
	document.write('<tr>');
	document.write('<td width = 100px>');
	document.write(BRIDGE_MEMBER);
	document.write('</td>');

	port_count=SRV_TRUNK_SETTING.length;
	trk_count=SRV_VPLAN.length - SRV_TRUNK_SETTING.length;
	set_trk_grup();

	columIdx = 0;
	/* print the checkbox of each vlan interface. */
	for(i=0; i<parseInt(port_count); i++){

		if(i >= COPER_PORT){	// fiber port
			name = "G" + (i-COPER_PORT+1);
		}
		else{	// coper port
			name = "Port" + (i+1);
		}

		brgMember_fieldID = "port_brg_member_port" + i;

		document.write('<td id=' + name + '>');
		document.write('<input type="checkbox" id=' + brgMember_fieldID + ' name=' + brgMember_fieldID + ' onClick=Brg_open_goose()>');
		document.write(name);
		document.write('</td>');

		if(i<port_count&&SRV_TRUNK_SETTING[i].trkgrp!=0){
			document.getElementById(brgMember_fieldID).style.display="none";
			document.getElementById(name).style.display="none";
			continue;
		}

		/* 3 bridge memeber at most in every row. */
		if((columIdx%3) == 2){
			document.write('</tr>');
			document.write('<tr>');
			document.write('<td></td>');
			columIdx = 0;
		}
		else{
			columIdx++;
		}

	}
	document.write('</tr>');
	document.write('</table>');
}


/******************************************************************
 *	Purpose:	print the checkbox for each bridge memebers in config field.
 *				seperate into two zone.
 * 	Inputs: 	N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/02/20
 ******************************************************************/
function Print_zoneBase_BrgMember()
{
	var i;
	var j;
	var name;
	var columIdx = 0;

	var brgMember_fieldID;

	var brg_member_max = SRV_VPLAN.length;
	var isSettableVid;	// 0: inavailable; 1: available
	var isSettablePort;	// 0: inavailable; 1: available

	var printed_zone1_vid_list = new Array(brg_member_max);	// for record the vid which's checkbox has been printed. avoid print twice.
	var printed_zone2_vid_list = new Array(brg_member_max);	// for record the vid which's checkbox has been printed. avoid print twice.

	/* print all acceptable zone base members */
	document.write('<table id="zone_base_member">');
	document.write('<tr>');
	document.write('<td width = 100px>');
	document.write(BRIDGE_MEMBER);
	document.write('</td>');


	/*** zone-1 bridge member. ***/
	document.write('<td>');
	document.write('<table><tr>');
	document.write('<td>');
	document.write(BRIDGE_ZONE1_NAME);
	document.write('</td>');
	document.write('<td>');
	document.write('<input type="text" id=zone1_name name="zone1_name" size=20 maxlength=31>');
	document.write('</td>');
	document.write('</tr></table>');
	document.write('</td>');

	document.write('<tr>');
	document.write('<td></td>');


	document.write('<td>');
	document.write('<table>');

	document.write('<tr>');
	columIdx = 0;
	/* print the checkbox of each vlan interface. */
	for(i=0; i < brg_member_max; i++){

		isSettableVid = 1;

		/* if this index is without pvid, this vid(=0) is inavailable */
		if(SRV_VPLAN[i].pvid == 0){
			isSettableVid = 0;	// this vid has been occupied, it is not settalbe.
		}

		/* if this vid has been printed, we don't print this vid's checkbox again. */
		for(j=0; j<brg_member_max; j++){
			if(SRV_VPLAN[i].pvid == printed_zone1_vid_list[j]){
				isSettableVid = 0;	// this vid has been printed, ignore this
			}
		}

		if(isSettableVid){

			name = "VID" + SRV_VPLAN[i].pvid;
			brgMember_fieldID = "zone1_brg_member_vid" + SRV_VPLAN[i].pvid;

			document.write('<td>');
			document.write('<input type="checkbox" id=' + brgMember_fieldID + ' name=' + brgMember_fieldID + ' onClick=Brg_open_goose()>');
			document.write(name);
			document.write('</td>');

			/* record this pvid's checkbox has been printed. */
			printed_zone1_vid_list[columIdx] = SRV_VPLAN[i].pvid;

			/* 3 bridge memeber at most in every row. */
			if((columIdx%3) == 2){
				document.write('</tr>');
				document.write('<tr>');
				columIdx = 0;
			}
			else{
				columIdx++;
			}
		}
	}
	document.write('</table>');
	document.write('</td>');
	document.write('</tr>');

	/*** zone-2 bridge member. ***/
	document.write('<tr>');
	document.write('<td></td>');

	document.write('<td>');
	document.write('<table><tr>');
	document.write('<td>');
	document.write(BRIDGE_ZONE2_NAME);
	document.write('</td>');
	document.write('<td>');
	document.write('<input type="text" id=zone2_name name="zone2_name" size=20 maxlength=31>');
	document.write('</td>');
	document.write('</tr></table>');
	document.write('</td>');

	document.write('<tr>');
	document.write('<td></td>');


	document.write('<td>');
	document.write('<table>');

	document.write('<tr>');
	columIdx = 0;
	/* print the checkbox of each vlan interface. */
	for(i=0; i < brg_member_max; i++){

		isSettableVid = 1;

		/* if this index is without pvid, this vid(=0) is inavailable */
		if(SRV_VPLAN[i].pvid == 0){
			isSettableVid = 0;	// this vid has been occupied, it is not settalbe.
		}

		/* if this vid has been printed, we don't print this vid's checkbox again. */
		for(j=0; j<brg_member_max; j++){
			if(SRV_VPLAN[i].pvid == printed_zone2_vid_list[j]){
				isSettableVid = 0;	// this vid has been printed, ignore this
			}
		}

		if(isSettableVid){

			name = "VID" + SRV_VPLAN[i].pvid;
			brgMember_fieldID = "zone2_brg_member_vid" + SRV_VPLAN[i].pvid;

			document.write('<td>');
			document.write('<input type="checkbox" id=' + brgMember_fieldID + ' name=' + brgMember_fieldID + ' onClick=Brg_open_goose()>');
			document.write(name);
			document.write('</td>');

			/* record this pvid's checkbox has been printed. */
			printed_zone2_vid_list[columIdx] = SRV_VPLAN[i].pvid;

			/* 3 bridge memeber at most in every row. */
			if((columIdx%3) == 2){
				document.write('</tr>');
				document.write('<tr>');
				columIdx = 0;
			}
			else{
				columIdx++;
			}
		}
	}
	document.write('</table>');
	document.write('</td>');
	document.write('</tr>');

	document.write('</table>');

}

/******************************************************************
 *	Purpose:	print the checkbox for each bridge memebers in config field.
 * 	Inputs: 	N/A
 * 	Return:		N/A
 * 	Author: 	Kevin Haung
 * 	Date: 		2015/01/28
 ******************************************************************/
function PrintBrgMember()
{
	Print_portBase_BrgMember();
	Print_zoneBase_BrgMember();
}

</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(BR_CONFIG)</script></h1>

<fieldset>
<form id=LanForm name=LanForm method="POST" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_BRG_tmp" id="brgtmp" value="" >
<input type="hidden" name="SRV_ZONE_BRG_tmp" id="zone_brgtmp" value="" >
<input type="hidden" name="SRV_VLAN_tmp" id="vlantmp" value="" >
<input type="hidden" name="SRV_VPLAN_tmp" id="vplantmp" value="" >
<input type="hidden" name="brg_auto_tmp" id="brg_auto_tmp" value="" >
<input type="hidden" name="brg_goose_tmp" id="brg_goose_tmp" value="" >
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border =0>
<tr><td>

<DIV style="height:400px">
<table cellpadding=1 cellspacing=1 border=0 width=100%>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(BR_IP_Configuration)</script></td></tr>
 <tr align="left">
  <td width=80px style="display:none"><script language="JavaScript">doc(Interface_)</script></td>
  <td width=80px><script language="JavaScript">doc(Name_)</script></td>
  <td width=150px><input type="text" id=ifnameUsr name="ifnameUsr" size=20 maxlength=31></td>
  <td width=80px><script language="JavaScript">doc(BRG_TYPE)</script></td>
  <td width=150px><script language="JavaScript">fnGenSelect(selstate, '')</script></td>
 </tr>
 <tr align="left">
  <td width=80px><script language="JavaScript">doc(Enable_)</script></td>
  <td width=150px><input type="checkbox" id=enable name="enable" value=1></td>
  <td width=80px><script language="JavaScript">doc(BR_GOOSE_MSG_)</script></td>
  <td width=150px><input type="checkbox" id=goose name="goose" value=0></td>
  </tr>
 <tr align="left">
  <td width = 100px><script language="JavaScript">doc(IP_Address)</script></td>
  <td><input type="text" id=ip name="ip" size=15 maxlength=15></td>
  <td width = 100px ><script language="JavaScript">doc(Subnet_Mask)</script></td>
  <td><input type="text" id=mask name="mask" size=15 maxlength=15></td>
  <td><input type="hidden" id=v_routing name="routing"></td></tr>
  <td><input type="hidden" id=v_dvmrp name="dvmrp"></td></tr>
</table>

<script language="JavaScript">PrintBrgMember()</script>
</DIV>

<input type="hidden" name="bridge_group_id" id="bridge_group_id" value="">
<input type="hidden" name="stp" id="stp" value="">
</td></tr>
<tr><td>
<table align=left border=0>
 <tr>
  <td width=300px><script language="JavaScript">fnbnSID(Submit_, 'onClick=Brg_Activate(this.form)', 'btnS')</script></td>
  <td width=100px style="display:none"><script language="JavaScript">fnbnBID(modb, 'onClick=Tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=100px></td>
  <td width=100px></td>
  <td width=50px></td>
 </tr>
</table>
</td></tr>
<tr><td>
<table align=left border=0>
	<tr style="height:50px"></tr>
</table>
</td></tr>
<tr><td>
<table cellpadding=1 cellspacing=2 id="show_available_table" border=0 style="display:none">
<tr class=r0>
 <td colspan=4 ></td>
 <td></td></tr>
 <tr align="left">
  <th width=210px><script language="JavaScript">doc(Name_)</script></th>
  <th width=120px><script language="JavaScript">doc(Enable_)</script></th>
  <th width=200px><script language="JavaScript">doc(IP_Address)</script></th>
  <th width=240px><script language="JavaScript">doc(Subnet_Mask)</script></th>
  <th width=10px><script language="JavaScript">doc(BR_GOOSE_MSG_P_T_)</script></th>
</table>
</td></tr>
<table>
</form>
<fieldset>

</body></html>
