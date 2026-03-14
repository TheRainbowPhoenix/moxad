<html>
<head> 
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
if (!debug) {
	var SRV_VLAN={pvid0:'0',pvid1:'0',pvid2:'0',pvid3:'0',pvid4:'0',pvid5:'0',pvid6:'0',pvid7:'0',pvid8:'0',pvid9:'0',
		edge0:'0',edge1:'0',edge2:'0',edge3:'0',edge4:'0',edge5:'0',edge6:'0',edge7:'0',edge8:'0',edge9:'0',
		tagged0:'0',tagged1:'0',tagged2:'0',tagged3:'0',tagged4:'0',tagged5:'0',tagged6:'0',tagged7:'0',tagged8:'0',
		tagged9:'0',vid0:'0',vid1:'0',vid2:'0',vid3:'0',vid4:'0',vid5:'0',vid6:'0',vid7:'0',vid8:'0',vid9:'0',vid10:'0',
		vid11:'0',vid12:'0',vid13:'0',vid14:'0',vid15:'0',tagpbmp0:'0',tagpbmp1:'0',tagpbmp2:'0',tagpbmp3:'0',tagpbmp4:'0',
		tagpbmp5:'0',tagpbmp6:'0',tagpbmp7:'0',tagpbmp8:'0',tagpbmp9:'0',tagpbmp10:'0',tagpbmp11:'0',tagpbmp12:'0',tagpbmp13:'0'
		,tagpbmp14:'0',tagpbmp15:'0',untagpbmp0:'0',untagpbmp1:'0',untagpbmp2:'0',untagpbmp3:'0',untagpbmp4:'0',untagpbmp5:'0',
		untagpbmp6:'0',untagpbmp7:'0',untagpbmp8:'0',untagpbmp9:'0',untagpbmp10:'0',untagpbmp11:'0',untagpbmp12:'0',
		untagpbmp13:'0',untagpbmp14:'0',untagpbmp15:'0'}	


}else{
	{{ net_Web_show_value('SRV_VPLAN') | safe }}
	{{ net_Web_show_value('SRV_VLAN') | safe }}		
	{{ net_Web_show_value('SRV_TRUNK_SETTING') | safe }}	
}
var port_desc=[{{ net_webPortDesc() | safe }}];
var TRUNK= 1;
var ACCESS= 2;
var MEMBER= 3;


var seltyp = { type:'select', id:'authmode', name:'ikemode', size:1, onChange:'fnChgAuthType(this.value)', option:typ0};
var typ0 = [
	{ value:0, text:ACCESS_ },	{ value:1, text:TRUNK_ },	{ value:2, text:HYBRID_ }
];
var vid_count,port_count=0, trk_count=0;

function copyitems(index){
	document.getElementById("pvid"+index).value = document.getElementsByName("pvidq")[0].value;
	document.getElementById("type"+index).value = document.getElementsByName("typeq")[0].value;
	document.getElementById("tagvid"+index).value = document.getElementsByName("tagvidq")[0].value;
	document.getElementById("untagvid"+index).value = document.getElementsByName("untagvidq")[0].value;
	document.getElementById("type"+index).onchange();
}

var rang_keyword=':';
var trk_name="trk";
function index_check(id){
	if(id.substring(0, 3)==trk_name){
		if((id = port_count+parseInt(id.substring(3, id.length)))==port_count){
			return 0;
		}
	}else{
		if(isNumber(id)){
			id = parseInt(id);
		}else{
            if(id == "G1"){
                return 9;
            }else if(id == "G2"){
                return 10;
            }else{
			    return 0;
            }
		}
	}
	return id;
}


function copytofun(){
	var i,j, copydata,copydata_org, copydatal, copydatah;
	for(i=0;i< document.getElementById("copyto").value.split(',').length;i++){
		copydata=document.getElementById("copyto").value.split(',')[i];
		if(copydata.split(rang_keyword).length==1){
			copydata_org = copydata;
			copydata = index_check(copydata)-1;
			if(document.getElementById("type"+copydata)){
				copyitems(copydata);
			}else{
				alert(copydata_org+' '+WRONG_FORMAT_);
			}
		}else{
			copydatal = copydata.split(rang_keyword)[0];
			copydatah = copydata.split(rang_keyword)[1];			
			copydatal = index_check(copydatal)-1;
			copydatah = index_check(copydatah)-1;
			if(!document.getElementById("type"+copydatal)||!document.getElementById("type"+copydatah)){
				alert(copydata+' '+WRONG_FORMAT_);
				return;
			}
			if(document.getElementById("type"+copydatal)||document.getElementById("type"+copydatah)||copydatal>=copydatah){
				for(j = copydatal; j<=copydatah;j++){
					if(!document.getElementById("type"+j))
						continue;
					copyitems(j);
				}
			}else{
				alert(copydata+' '+WRONG_FORMAT_);
			}
		}
	}
	}
	
function typeChange(item){
	var idx, tagname, untagname;
	idx=item.id.substring(4, item.id.len);
	tagname = "tagvid"+idx;
	untagname = "untagvid"+idx;
	if(typ0[document.getElementById(item.id).selectedIndex].value==0){
		document.getElementById(tagname).disabled="true";
		document.getElementById(untagname).disabled="true";
	}else if(typ0[document.getElementById(item.id).selectedIndex].value==1){
		document.getElementById(tagname).disabled="";
		document.getElementById(untagname).disabled="true";
	}else if(typ0[document.getElementById(item.id).selectedIndex].value==2){
		document.getElementById(tagname).disabled="";
		document.getElementById(untagname).disabled="";
	}
}
function Addformat(idx, data, newdata)
{	
	var i,j,name,tagname,tmp, name;	
	var count,k;	
	var tagvid_member="";
	var untagvid_member="";

	if(idx>=port_count){
		newdata[0] = trk_name+(idx-port_count+1);
	}else{
		newdata[0] = port_desc[idx].index;
	}
	
	newdata[1] = iGenSel4Str("type","type"+idx,typ0,"typeChange");
	name = "pvid";
	newdata[2] = "<input size=4 maxlength=4 type=text name="+name+ " id ="+name+idx +" value ="+ data[idx]["pvid"]+">";
	name="port";
	for(i=0; i < SRV_VLAN.length; i++){
		if(SRV_VLAN[i].vlanid == SRV_VPLAN[idx].pvid){
			continue;
		}else if(SRV_VLAN[i][name+idx]!=0){
			if(SRV_VLAN[i][name+idx]==1){
				tagvid_member+=SRV_VLAN[i].vlanid+',';
			}else if(SRV_VLAN[i][name+idx]==2){
				untagvid_member+=SRV_VLAN[i].vlanid+',';
			}
		}
		
	}
	name = "tagvid"+idx;
	newdata[3] = "<input size=55 maxlength=331 type=text id="+name+ " value ="+ tagvid_member+">";	
	name = "untagvid"+idx;
	newdata[4] = "<input size=55 maxlength=331 type=text id="+name+ " value ="+untagvid_member+">";	
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
function tableinit(){
	var newdata=new Array;
	var i, j, portid,name;	
	table = document.getElementById("vlan_table_set");
	set_trk_grup();
	for(i=0; i<parseInt(port_count)+parseInt(trk_max); i++){		
		//alert(i);
		Addformat(i, SRV_VPLAN, newdata);
		tableaddRow("vlan_table_set", 0, newdata, "center");
		document.getElementById("type"+i).value=SRV_VPLAN[i]["type"];		
		document.getElementById("type"+i).onchange();
		if(i<port_count&&SRV_TRUNK_SETTING[i].trkgrp!=0){
			//alert(table.getElementsByTagName("tr")[table.getElementsByTagName("tr").length-1].style.display);
			table.getElementsByTagName("tr")[table.getElementsByTagName("tr").length-1].style.display="none";
			continue;
		}else if(i>=port_count&&!trk_group[0][i-port_count]){
			table.getElementsByTagName("tr")[table.getElementsByTagName("tr").length-1].style.display="none";
			continue;
		}
	}
}

var confirm_value=-1;
function del_confirm(value){
	confirm_value = value;
	Activate(document.getElementsByName("vlan_setting_form")[0]); 
}

function del_vid_confirm(del_vid){
	var table=document.getElementById("vlan_warring_table");
	var row = table.insertRow(table.getElementsByTagName("tr").length);
	var cell;
	document.getElementById("vlan_setting_table").style.display="none"
	document.getElementById("vlan_warring_button").style.display=""
	table.style.display="";

	row.className = "r1";
	cell = document.createElement("td");
	cell.innerHTML = "No member ports in vlan "+del_vid;		
	row.style.color="#ff0000";
	row.style.fontSize="20px";
	row.appendChild(cell);
	
	row = table.insertRow(table.getElementsByTagName("tr").length);
	row.className = "r1";
	cell = document.createElement("td");
	cell.innerHTML = "Click \"Keep\" to keep vlan "+del_vid+"click \"Remove\" to remove vlan "+del_vid+" or click \"Cancel\" to restore the previous page.";		
	row.style.color="#ff0000";
	row.appendChild(cell);

	
	//del_vid = confirm("No member ports in vlan "+del_vid+".\nClick \"Keep\" to keep vlan "+del_vid+",click \"Remove\" to remove vlan "+del_vid+", or click \"Cancel\" to restore the previous page.");// yes(keep), no(remove), cancel(restore)
};

function panel_hidden(){
	var panel_system=document.getElementById("quick_setting_table").style;
	panel_system.display=(panel_system.display=="")?"none":"";
}

function isValidVid(vid)
{

	if(vid < 1 || vid > 4095) {
		return 0;
	}

	return 1;
}

var VLAN_CHECK_TABLE=new Array(4095);
function check_port_vlan_member()
{
	var i,k, name;
	for(i = 0; i < 4095; i++)
 		VLAN_CHECK_TABLE[i] = new Array;

	for(k=0; k < port_count+trk_count; k++){
		VLAN_CHECK_TABLE[document.getElementById("vlan_management_id").value]["checked"]=1;
		VLAN_CHECK_TABLE[document.getElementById("vlan_management_id").value][k]=0;
	}	
	for(i=0;i<SRV_VPLAN.length;i++){
		name = "pvid"+i;
		if(document.getElementById(name)){
			if(!isValidVid(document.getElementById(name).value)) {
				alert("PVID is invalid !");
				return -1;
			}
			
			SRV_VPLAN[i].pvid= document.getElementById(name).value;
			VLAN_CHECK_TABLE[SRV_VPLAN[i].pvid]["checked"]=1;
			VLAN_CHECK_TABLE[SRV_VPLAN[i].pvid][i]=2;
		}else{
			SRV_VPLAN[i].pvid=0;
		}
	}
	
	for(k=0; k < port_count+trk_count; k++){
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
	}

	return 1; // OK
}		



function Activate(form)
{	
	var i,j,k,name,vlan_get, del_vid, count;

	
	if(confirm_value==-1){		
		if(check_port_vlan_member() < 0) {			
			return;
		}
		
		del_vid="";
		for(i=0;i<SRV_VLAN.length;i++){
			if(VLAN_CHECK_TABLE[SRV_VLAN[i].vlanid]["checked"]){
				continue;
			}
			del_vid+=SRV_VLAN[i].vlanid+',';
		}
		if(del_vid!=""){
			del_vid_confirm(del_vid);
			return;
		}
	}
	if(confirm_value==1){ // Keep
		for(i=0;i<SRV_VLAN.length;i++){
			VLAN_CHECK_TABLE[SRV_VLAN[i].vlanid]["checked"]|=2; // 2 is for old VID
		}
	}
	else if(confirm_value==2){ // Remove
		for(i=0;i<SRV_VLAN.length;i++){
			if(VLAN_CHECK_TABLE[SRV_VLAN[i].vlanid]["checked"]==2) {
				VLAN_CHECK_TABLE[SRV_VLAN[i].vlanid]["checked"]=0;
			}
		}
	}
	else if(confirm_value==0){
		location.href=location;
		return;
	}
	
	form.vlantmp.value="";
	vlan_get="";
	count=0;
	for(i=1;i<4095;i++){
		if(VLAN_CHECK_TABLE[i]["checked"]){			
			if(count >= SRV_VLAN_MAX){
				alert("Vlans must be less than "+SRV_VLAN_MAX);
				return;
			}
			count++;
			if(i==document.getElementById("vlan_management_id").value){
				form.vlantmp.value+=i + "+";
				for(k=0;k<port_count+trk_count;k++){
					if(VLAN_CHECK_TABLE[i][k]){
						form.vlantmp.value+=VLAN_CHECK_TABLE[i][k] + "+";
					}else{
						form.vlantmp.value+=0 + "+";
		}
				}
					}else{
				vlan_get+=i + "+";
				for(k=0;k<port_count+trk_count;k++){
					if(VLAN_CHECK_TABLE[i][k]){
						vlan_get+=VLAN_CHECK_TABLE[i][k] + "+";
					}else{
						vlan_get+=0 + "+";
						}
					}
				}		
			}
		}
	form.vlantmp.value+=vlan_get;
	//alert(form.vlantmp.value);
	form.SRV_VPLAN_tmp.value="";
	for(i=0;i<SRV_VPLAN.length;i++){
		for(j in SRV_VPLAN_type){
			if(document.getElementById(j+i)){
				form.SRV_VPLAN_tmp.value += document.getElementById(j+i).value + "+";	
			}else{
				form.SRV_VPLAN_tmp.value += 0 + "+";	
	}
		}		
	}
	//alert(form.SRV_VPLAN_tmp.value);	
	form.action="/goform/net_Web_get_value?SRV=SRV_VPLAN&SRV0=SRV_VLAN";
	form.submit();	
}

function fnInit() {	
	var i;
	document.getElementById("vlan_warring_table").style.display="none";
	document.getElementById("vlan_warring_button").style.display="none";
	document.getElementById("quick_setting_table").style.display="none";

	port_count=SRV_TRUNK_SETTING.length;
	trk_count=SRV_VPLAN.length - SRV_TRUNK_SETTING.length;
	vid_count=0;
	if(SRV_VLAN[0]){
		document.getElementById("vlan_management_id").value=SRV_VLAN[0].vlanid;
	}else{
		document.getElementById("vlan_management_id").value=1;
	}
	
	tableinit();
	document.getElementById("typeq").onchange();
}
function stopSubmit()
{
	return false;
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc("802.1Q VLAN Settings")</script></h1>
<form method="post" name="vlan_setting_form" onSubmit="return stopSubmit()">
<fieldset>
<input type="hidden" name="SRV_VLAN_tmp" id="vlantmp" value="" >
<input type="hidden" name="SRV_VPLAN_tmp" id="vplantmp" value="" >
{{ net_Web_csrf_Token() | safe }}
<table>
<tr><td><table border="0" align="left" id="vlan_setting_table"> 	
<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div>
	</td>
	<td width="97%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		<table border="0" cellpadding="0" cellspacing="0">	
		<tr><td> 
		<table width="690" border="0" cellpadding="0" cellspacing="0" align="left">
			<tr align="left">
			 <td colspan=5>
			  <table border="0" cellpadding="0" cellspacing="0">
			   <tr class=r0>
			    <td width="18%" valign="bottom" onclick=panel_hidden() onMouseover="this.style.cursor='hand';">
			    <script language="JavaScript">doc(QUICK_SET_PANEL_)</script>
			    <img src='image/trangle.bmp' width=10 height=10></td>
			   </tr>
			  </table>
			 </td>
			</tr>
			<tr><td colspan=5><table id="quick_setting_table">
  			<tr class="r8"> 
  				<td width="10%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
					<script language="JavaScript">doc(Port)</script></font></div></td>
    			<td width="11%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
					<script language="JavaScript">doc(Type_)</script></font></div></td>
    			<td width="5%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    				<script language="JavaScript">doc(PVID)</script></font></div></td>
    			<td width="37%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    				<script language="JavaScript">doc(FIXED_VLAN_TAG)</script></font></div></td>
    			<td width="37%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    				<script language="JavaScript">doc(FIXED_VLAN_UNTAG)</script></font></div></td>
  			</tr>
  			<tr class=r1 align="center">
  				<td><input type="text" id="copyto" size="10" maxlength="20"></td>
  				<td><script language="JavaScript">iGenSel4("typeq","typeq",typ0,"typeChange");</script></td>
  				<td><input size=4 maxlength=4 type=text name=pvidq id=pvidq></td>
  				<td><input size=55 maxlength=331 type=text name=tagvidq id=tagvidq></td>
  				<td><input size=55 maxlength=331 type=text name=untagvidq id=untagvidq></td>
  			</tr>
  			<tr class=r1 align="left">
  				<td><script language="JavaScript">fnbnB(SET_TO_TABLE_,'onClick=copytofun()')</script></td>
  			</tr>
  			<tr class=r1 align="left">	
  				<td colspan=6>Note: 1,2,10:13,20:24 means the configuration will be copy to port 1,2,10,11,12,13,20,21,23,24</td>
  			</tr>
  			</table></td></tr>
		</table>
		</td></tr>
		</table>
	</td>
</tr>

<tr>
	<tr class=r0 id=trst0>
	  <td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>	
	  <td colspan=5><script language="JavaScript">doc(VLAN_ID_CONFIGURATION_TABLE_)</script></td></tr>  
<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
  	<td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		<script language="JavaScript">doc(M_VLAN_ID_)</script></font></div></td>
    <td width="77%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett"> 
    	<input type="text" id="vlan_management_id" size="4" maxlength="4" value="1" ></font></div></td>
</tr>    	
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td width="97%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		<table width="690" border="0" align="left" id="vlan_table_set">
  			<tr bgcolor="#007C60">
  				<th width="10%"><script language="JavaScript">doc(Port)</script></th>
    			<th width="11%"><script language="JavaScript">doc(Type_)</script></th>
    			<th width="5%"><script language="JavaScript">doc(PVID)</script></th>
    			<th width="37%"><script language="JavaScript">doc(FIXED_VLAN_TAG)</script></th>
    			<th width="37%"><script language="JavaScript">doc(FIXED_VLAN_UNTAG)</script></th>
  			</tr>
		</table>
	</td>
</tr>

<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td></tr>
</tr>
</table></td></tr>
<tr><td><table width="100%" border="0" align="left" id="vlan_warring_table"> 
</table></td></tr>
<tr><td><table width="100%" border="0" align="left" id="vlan_warring_button"> 
 <tr>
  <td width="10%"><script language="JavaScript">fnbnB(KEEP_, 'onClick=del_confirm(1)')</script></td>
  <td width="10%"><script language="JavaScript">fnbnB(REMOVE_, 'onClick=del_confirm(2)')</script></td>
  <td ><script language="JavaScript">fnbnB(Cancel_, 'onClick=del_confirm(0)')</script></td>
 </tr>
</table></td></tr>
</table>
</div>
</fieldset>
</form>
</body>
</html>
