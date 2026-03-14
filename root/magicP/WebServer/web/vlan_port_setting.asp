<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(VLAN_SETTING)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
if (!debug) {

}else{
	<%net_Web_show_value('SRV_VPLAN');%>
	<%net_Web_show_value('SRV_TRUNK_SETTING');%>		
}
var TRUNK= 1;
var ACCESS= 2;
var MEMBER= 3;

var acc_typ = [
	{ value:0, text:ALL_ACCEPT_ },	{ value:1, text:ONLY_TAG_FRAM_ }
];
var vid_count,port_count;

var trk_count=0;
var trk_group=new Array;

function set_trk_grup(){
	var i;
	trk_group[0]=new Array;
	trk_group[1]=new Array;

	for(i=0;i<SRV_VPLAN.length;i++){
		trk_group[0][trk_name+i]=0;
		trk_group[1][trk_name+i]=0;
	}
	
	for(i=0;i<SRV_VPLAN.length;i++){
		if(SRV_TRUNK_SETTING[i]["trkgrp"]>trk_count){
			trk_count = SRV_TRUNK_SETTING[i]["trkgrp"];
		}
		if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0){
			trk_group[0][trk_name+(SRV_TRUNK_SETTING[i]["trkgrp"]-1)]=i;
			trk_group[1][trk_name+(SRV_TRUNK_SETTING[i]["trkgrp"]-1)]|=1<<i;			
		}
	}
}


var trk_name="trk";
function Addformat(idx, data, newdata)
{	
	var i,j,name,tagname,tmp;	
	var count,k, tagvid_member, untagvid_member;	
	//alert(data +"idx = "+ idx);
	if(idx < SRV_VPLAN.length){
		/*if(SRV_TRUNK_SETTING[idx]["trkgrp"]!=0){
			newdata[0] = "<input type=hidden>";
			name = "pvid";
			newdata[1] = "<input type=hidden name="+name+ " value ="+SRV_VPLAN[idx].pvid+">";
			name = "accepttype";
			newdata[2] = "<input type=hidden name="+name+ " value ="+SRV_VPLAN[idx].accepttype+">"
			name = "filert";
			newdata[3] = "<input type=hidden name="+name+ " value ="+SRV_VPLAN[idx].filert+">"
		}else{*/
			newdata[0] = idx+1;
			name = "pvid";
			newdata[1] = "<input type=text name="+name+ " value ="+SRV_VPLAN[idx].pvid+">";
			name = "accepttype";
			newdata[2] = iGenSel2Str(name,name,acc_typ);
			name = "filert";
			newdata[3] = "<input type=checkbox name="+name+ ">";	
		//}
	}else{
		newdata[0] = trk_name+(idx-SRV_VPLAN.length+1);
		name = "pvid";
		newdata[1] = "<input type=text name="+name+ " value ="+SRV_VPLAN[trk_group[0][trk_name+(idx-SRV_VPLAN.length)]].pvid+">";
		name = "accepttype";
		newdata[2] = iGenSel2Str(name,name,acc_typ);
		name = "filert";
		newdata[3] = "<input type=checkbox name="+name+ ">";
	}	
}


function tableinit(){
	var newdata=new Array;
	var i, j=0, portid,name,table;	
	for(i=0; i<parseInt(SRV_VPLAN.length)+parseInt(trk_count); i++){
		if(trk_group[0][trk_name+(i-SRV_VPLAN.length)] == 0){
			j++;
			continue;
		}
		Addformat(i, SRV_VPLAN, newdata);
		tableaddRow("vlan_table_set", 0, newdata, "center");
		if(SRV_TRUNK_SETTING[i]["trkgrp"]!=0){
			table = document.getElementById("vlan_table_set");
			table.getElementsByTagName("tr")[table.getElementsByTagName("tr").length-1].style.display="none";
			continue;
		}
		if(i < SRV_VPLAN.length){
			document.getElementsByName("accepttype")[i].selectedIndex=SRV_VPLAN[i].accepttype;
			document.getElementsByName("filert")[i].checked=SRV_VPLAN[i].filert==1?true:false;
		}else{
			document.getElementsByName("accepttype")[i-j].selectedIndex=SRV_VPLAN[trk_group[0][trk_name+(i-SRV_VPLAN.length)]].accepttype;
			document.getElementsByName("filert")[i-j].checked=SRV_VPLAN[trk_group[0][trk_name+(i-SRV_VPLAN.length)]].filert==1?true:false;
		}
	}
}


function Activate(form)
{	
	var i,j,k=0,name,vidname,bpmpname;

	var myForm = document.getElementById('myForm');	
	form.SRV_VPLAN_tmp.value="";
	for(i=0;i<trk_count;i++){
		if(trk_group[0][trk_name+i] == 0){
			k++;
			continue;
		}
		name = trk_name+i;
		for(j=0;j<SRV_VPLAN.length;j++){
			if(trk_group[1][name]&(1<<j)){
				//alert(name);
				//alert(SRV_VPLAN.length+i-k);
				document.getElementsByName("pvid")[j].value = document.getElementsByName("pvid")[SRV_VPLAN.length+i-k].value;
				document.getElementsByName("accepttype")[j].value = document.getElementsByName("accepttype")[SRV_VPLAN.length+i-k].value;
				document.getElementsByName("filert")[j].value = document.getElementsByName("filert")[SRV_VPLAN.length+i-k].value;
			}	
		}	
	}
	//alert(SRV_VPLAN.length);
	for(i=0;i<SRV_VPLAN.length;i++){
		form.SRV_VPLAN_tmp.value += document.getElementsByName("pvid")[i].value + "+";	
		form.SRV_VPLAN_tmp.value += document.getElementsByName("accepttype")[i].value + "+";	
		form.SRV_VPLAN_tmp.value += (document.getElementsByName("filert")[i].checked==true?1:0) + "+";	
		form.SRV_VPLAN_tmp.value += 0 + "+";	
	}
	
	form.action="/goform/net_Web_get_value?SRV=SRV_VPLAN";	
	//alert(form.SRV_VPLAN_tmp.value);
	form.submit();	
}

function fnInit() {	
	var i;
	set_trk_grup();
	tableinit();
}
function stopSubmit()
{
	return false;
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<form method="post" name="vlan_setting_form" onSubmit="return stopSubmit()">
<input type="hidden" name="SRV_VPLAN_tmp" id="SRV_VPLAN_tmp" value="" >
<% net_Web_csrf_Token(); %>
<div align="left">
	<font size="5" face="Arial, Helvetica, sans-serif, Marlett" color="#007C60"><b>
    <script language="JavaScript">doc("802.1Q VLAN Settings")</script></b></font>
</div>
<div align="left">
<table width="100%" border="0" align="left">	
<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td width="97%" colspan="2"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		<table width="690" border="0" align="left" id="vlan_table_set">
  			<tr bgcolor="#007C60">
  				<td width="15%"><div align="center"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#FFFFFF">
					<script language="JavaScript">doc(Port)</script></font></div></td>
    			<td width="30%"><div align="center"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#FFFFFF">
					<script language="JavaScript">doc(PVID)</script></font></div></td>
    			<td width="32%"><div align="center"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#FFFFFF">
    				<script language="JavaScript">doc(ACCEPT_FRAM_)</script></font></div></td>
    			<td width="23%"><div align="center"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#FFFFFF">
    				<script language="JavaScript">doc(IN_FILTER_)</script></font></div></td>
    			<!--td width="37%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#FFFFFF">
    				<script language="JavaScript">doc(FIXED_VLAN_UNTAG)</script></font></div></td-->
  			</tr>
		</table>
	</td>
</tr>

<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td></tr>
</tr>
<table style="visibility:hidden" id="hidden_table">
</table>
</table>
</div>
</form>
</body>
</html>
