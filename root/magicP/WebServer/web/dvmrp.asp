<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(DVMRP_)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
if (!debug) {

	var SRV_DVMRP_MAX = 1;
	var SRV_DVMRP_type = {enable:4,port:4};
	var SRV_DVMRP={enable:'1',port:'0'}	
	var SRV_VCONF_MAX = 16;
	var SRV_VCONF_type = {interface:4,ifname:4,enable:3,type:4,vid:4,ip:5,mask:5,routing:4,dvmrp:4};
	var SRV_VCONF=[{interface:'0',ifname:'LAN',enable:'1',type:'0',vid:'1',ip:'192.168.127.254',mask:'255.255.255.0',routing:'0',dvmrp:'0'},
		{interface:'0',ifname:'LAN22',enable:'1',type:'0',vid:'22',ip:'22.22.22.253',mask:'255.255.255.0',routing:'32',dvmrp:'1'}];			
	dvmrp_ifs = [ { value:'1',text:'LAN' } , { value:'22',text:'LAN22' } , { value:'4',text:'LAN4' }  ];


}else{
	<%net_Web_show_value('SRV_DVMRP');%>	
	<%net_Web_show_value('SRV_VCONF');%>		
	var CurrentIp = [ <% net_webVrrpCurrentIp(); %> ];
	dvmrp_ifs = [ <% net_Web_IFS_WriteIntegerValue(); %> ];
}

var PROTO_MASK_DVMRP = (1 << 2);

/*var wtype = {
	dvmrpstate:2, wan1:3, wan2:3, lan1:3
};*/



var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

if(ProjectModel == MODEL_EDR_G903){
	var ifsel = [{ value:0, text:'WAN1' },	{ value:1, text:'WAN2' },	{ value:2, text:'LAN' }];
}else{
	var ifsel = [{ value:0, text:'WAN' },	{ value:1, text:'LAN' }];
}

var actb = 'Active';
var myForm;
var selstate = { type:'select', id:'v_enable', name:'enable', size:1, option:wtyp0 };

var nowEntry;

function set_table(i) {	
	
	var table = document.getElementById("show_table");

	var row = table.insertRow(table.getElementsByTagName("tr").length);			

	/* enable */
	cell = document.createElement("td");
	cell.innerHTML = "<input type=\"checkbox\" name="+i+">";		
	cell.width="50px";
	row.appendChild(cell);

	/* interface name */
	cell = document.createElement("td");
	cell.innerHTML = i.toUpperCase();
	row.appendChild(cell);

	/* ip address */
	cell = document.createElement("td");
	cell.innerHTML = CurrentIp[nowEntry].ip;
	row.appendChild(cell);

	/* VID	*/
	cell = document.createElement("td");
	cell.innerHTML = CurrentIp[nowEntry].ifs;
	row.appendChild(cell);
	
	row.style.Color = "black";
	row.align="left";			
	row.className = "r1";

}
	
function fnInit() {	
	var i,len;
	var j;
	var name;
	var k;
	
	myForm = document.getElementById('myForm');	
	
	for(i =0; i < dvmrp_ifs.length;i++){	
		name = dvmrp_ifs[i].text;

		nowEntry = 0;

		for(k=0; k<CurrentIp.length; k++){
			if(CurrentIp[k].ifs == dvmrp_ifs[i].value)
				nowEntry = k;
		}
		
		
		/* VLAN */
		for(j = 0 ; j < SRV_VCONF.length ; j++){
			if(name == SRV_VCONF[j].ifname && SRV_VCONF[j]["enable"] == 1){

				/* only show the vlan which is enalbed */
				set_table(name);
				
				if(SRV_VCONF[j]["routing"] & PROTO_MASK_DVMRP)
					document.getElementsByName(name)[0].checked = true;
				else
					document.getElementsByName(name)[0].checked = false;
				
			}
		}
		/* WAN */
		if(name == "WAN"){
			set_table(name);
			document.getElementsByName(name)[0].checked = (SRV_DVMRP.port&PROTO_MASK_DVMRP) >0?true:false;
		}	
	}
	
	fnLoadForm(myForm, SRV_DVMRP, SRV_DVMRP_type);

}

function Activate(form)
{	
	var i,j,k;
	var name;

	var myForm = document.getElementById('myForm');	

	/* vlan */
	//form.SRV_VCONF_tmp.value = "";

	for(i = 0 ; i < SRV_VCONF.length ; i++)
	{
		name = SRV_VCONF[i].ifname;
		if(document.getElementsByName(name)[0].checked){
			SRV_VCONF[i]["routing"] |= PROTO_MASK_DVMRP;	
		}else{
			SRV_VCONF[i]["routing"] &= ~PROTO_MASK_DVMRP;
		}

		for (var k in SRV_VCONF[i]){
			form.SRV_VCONF_ROUT_UPDATE_tmp.value = form.SRV_VCONF_ROUT_UPDATE_tmp.value + SRV_VCONF[i][k] + "+";		
		}
		
		
	}
	
	
	/* v_enable */
	//SRV_DVMRP["enable"] = document.getElementById("v_enable").selectedIndex;
	
	//alert(form.SRV_VCONF_tmp.value);
	/* wan */
	name = "WAN";
	var ifs_name;
	
	for(i =0; i < dvmrp_ifs.length;i++){
		ifs_name = dvmrp_ifs[i].text;
		if(name == ifs_name){	// find wan, if wan exist */
			if(ProjectModel == MODEL_EDR_G903 || ProjectModel == MODEL_EDR_G902){
				if(document.getElementsByName(name)[0].checked){
					form.port.value	= dvmrp_ifs[i].value;
				}
				else{
					form.port.value	= 0;
				}
 
			}
			else{
				if(document.getElementsByName(name)[0].checked){
					SRV_DVMRP["port"] |= PROTO_MASK_DVMRP;
					form.port.value	|= PROTO_MASK_DVMRP;	
				}
				else{
					SRV_DVMRP["port"] &= ~PROTO_MASK_DVMRP;
					form.port.value	&= ~PROTO_MASK_DVMRP;
				}
 
			}
		}
	}	

	
/*
	for (var k in SRV_DVMRP){
		form.SRV_DVMRP_tmp.value += SRV_DVMRP[k] + "+";
	}
*/
	document.getElementById("enable").value = SRV_DVMRP["enable"];

	form.action="/goform/net_Web_get_value?SRV=SRV_VCONF_ROUT_UPDATE&SRV0=SRV_DVMRP";
	form.submit();	
}
function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="SRV_VCONF_ROUT_UPDATE_tmp" id="SRV_VCONF_ROUT_UPDATE_tmp" value="" >
<input type="hidden" name="port" id="port" value="" >
<input type="hidden" name="enable" id="enable" value="" >
  
<table id="dvmrp_table" cellpadding=1 cellspacing=2 border=0 align=center width=300px>

<table cellpadding=1 cellspacing=2 id="show_table" style="width:630px">
 <tr class=r5 align="center" width=630px>
  <td width=50px><script language="JavaScript">doc('Enable')</script></td>
  <td width=100px><script language="JavaScript">doc('Interface Name')</script></td>
  <td width=80px><script language="JavaScript">doc('IP Address')</script></td>
  <td width=80px><script language="JavaScript">doc('VID')</script></td> 
  </tr>
</table>

</table>

<p><table class=tf align=center>
 <tr>
  <td><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td></tr>  
  <td width=15></td></tr>
</table></p>

</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

