<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
var ModelVLAN = {{ net_Web_GetModel_VLAN_WriteValue() | safe }};
var No_WAN = {{ net_Web_GetNO_WAN_WriteValue() | safe }};
var MAC_PORTS = {{ net_Web_GetNO_MAC_PORTS_WriteValue() | safe }};
var PROTO_MASK_RIP=(1 << 0);
checkCookie();
if (!debug) {
	var SRV_RIP = {
		enable:'0', wan1:'1', wan2:'1', lan:'0', ver:0, red:1
	};
	var SRV_VCONF=[{interface:'0',ifname:'arieskae',enable:'1',type:'0',vid:'1',ip:'1.1.1.1',mask:'255.255.0.0',routing:'0'}];
}else{
	{{ net_Web_show_value('SRV_RIP') | safe }}
	{{ net_Web_show_value('SRV_VCONF') | safe }}
	var wan = [
		{{ net_webLan_Wan_IP() | safe }}
	]			
} 

var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];

var ripVer = [
	{ value:1, text:RIP_V1_ }, { value:0, text:RIP_V2_ }
];



var actb = 'Active';
var myForm;
var selstate = { type:'select', id:'rip_stat', name:'enable', size:1, option:wtyp0 };
var selver = { type:'select', id:'ver', name:'ver', size:1, option:ripVer };
	
function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_RIP, SRV_RIP_type);	
	if(ProjectModel == MODEL_EDR_G902){
		for(var i=0; i <document.getElementsByName('h_wan2').length; i++){
			document.getElementsByName("h_wan2")[i].style.display="none";
		}
	}
}

var item_name="ripif";
var item_idx =0;

function Addformat(idx, data, newdata)
{	
	newdata[0] = data.ifname;
	newdata[1] = data.ip;
	newdata[2] = data.vid;
	newdata[3] = '<input type=checkbox id='+item_name+item_idx+' name="'+item_name+'">';
}
	
function PrintWanTable() {
	if(ModelVLAN==RETURN_TRUE){
		var newdata=new Array;
		var i;
		item_idx=0;
		document.write('<tr">');
			document.write('<table border="0" id="show_available_table" style="width:500px">');
	    		document.write('<tr align="center">');
	      		document.write('<th width=225px">'+Interface_+' '+Name_+'</th>');
	      		document.write('<th width=150px">'+IP_+'</th>');
	      		document.write('<th width=75px">'+VID_+'</th>');
	      		document.write('<th width=50px">'+Enable_+'</th>');
	  			document.write('</tr>');
	  		document.write('</table>');
		document.write('<tr align="left">');
		
		if(No_WAN+1 > MAC_PORTS){			
			var name;
			for(i=0;i< No_WAN;i++){
				if(i<No_WAN){
					name='wan';
					if(No_WAN>1){
						name+=i;
					}
				}
				if(wan[i].vid!=0){
					newdata[0] = name.toUpperCase();
					if(wan[i]){
						newdata[1] = wan[i].ipad;
						newdata[2] = wan[i].vid;
					}else{
						newdata[1] = "";
						newdata[2] = "";
					}				
					newdata[3] = '<input type=checkbox id='+item_name+item_idx+' name='+item_name+'>';
					tableaddRow("show_available_table", 0, newdata, "center");
					if(SRV_RIP.vif&1<<item_idx){
						document.getElementById(item_name+item_idx).checked=true;
					}
				}
				item_idx++;
			}			
		}
		
		for(i=0; i < SRV_VCONF.length; i++){
			Addformat(i, SRV_VCONF[i], newdata);
			tableaddRow("show_available_table", 0, newdata, "center");
			if(SRV_VCONF[i]["routing"]&PROTO_MASK_RIP){
				document.getElementById(item_name+item_idx).checked=true;
			}
			item_idx++;
		}
		
	}else{
		var i;
		for(i in  SRV_RIP){
			if(!document.getElementById(i)){
				document.write('<td class=r1 width=30px><input type=checkbox id='+i+' name='+i+'></td>');
				document.write('<td class=r1 width=40px>'+i.toUpperCase()+'</td>');			
			}
		}
	}
	
	/*if(ProjectModel == MODEL_EDR_G903){
		document.write('<td class=r1 width=30px><input type=checkbox id=rip_wan name=wan1></td>');
		document.write('<td class=r1 width=40px>'+WAN1_+'</td>');
	}
	else{
		document.write('<td class=r1 width=30px><input type=checkbox id=rip_wan name=wan></td>');
		document.write('<td class=r1 width=40px>'+WAN_+'</td>');
	}*/
}

function Activate(form)
{
	var iflen;
	document.getElementById("vif").value=0;
	if(ModelVLAN==RETURN_TRUE){
		iflen=document.getElementsByName(item_name).length;
		for(var i=0; i < iflen; i++){
			if(No_WAN+1 > MAC_PORTS){
				if(i < No_WAN && wan[i].vid==0){
					iflen++;
					continue;
				}
				if(document.getElementById(item_name+i).checked==true){					
					if(i < No_WAN){
						document.getElementById("vif").value= parseInt(document.getElementsByName("vif")[0].value,10)|1<<i;
					}else{
						SRV_VCONF[i-No_WAN]["routing"]|= PROTO_MASK_RIP;
					}
				}else{
					if(i >= (No_WAN)){
						SRV_VCONF[i-No_WAN]["routing"]&= ~PROTO_MASK_RIP;
					}
			}
		}
	}
	}
	
	for(var i = 0 ; i < SRV_VCONF.length ; i++)
	{
		for (var k in SRV_VCONF[i]){
			form.vlantmp.value = form.vlantmp.value + SRV_VCONF[i][k] + "+";		
		}				
	}
	//alert(document.getElementById("vif").value);
	form.action="/goform/net_Web_get_value?SRV=SRV_VCONF_ROUT_UPDATE&SRV0=SRV_RIP";	
	form.submit();	
}
function stopSubmit()
{
	return false;
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(RIP_SETTING_)</script></h1>
<form id=myForm name=form1 method="POST"  onSubmit="return stopSubmit()" >
<fieldset>
 <input type="hidden" name="vif" id="vif" value="0" >
 <input type="hidden" name="SRV_VCONF_ROUT_UPDATE_tmp" id="vlantmp" value="" >
 {{ net_Web_csrf_Token() | safe }}
 <table cellpadding=1 cellspacing=2 border=0 align=center width=700px>
  <tr align="left">
   <td width=100px><input type="checkbox" id=rip_stat name="enable"><script language="JavaScript">doc(Enable_+" "+RIP_)</script></td>
   </tr>     
 </table>  
 
 <table cellpadding=1 cellspacing=2 border=0 align=center width=700px>  
  <tr align="left">
   <td width=100px><script language="JavaScript">doc(RIP_VER_)</script></td>
   <td><script language="JavaScript">fnGenSelect(selver, '')</script></td>   
  </tr>     
 </table>  
 
 <table cellpadding=1 cellspacing=2 border=0 align=center width=700px>
  <tr align="left">
    <td width=100px><script language="JavaScript">doc(DISTRIBUTION_)</script></td>
    <td width=100px><input type="checkbox" id=red_c name="red_c"><script language="JavaScript">doc(Connected_)</script></td>
    <td width=100px><input type="checkbox" id=red_s name="red_s"><script language="JavaScript">doc(RIP_STATIC_)</script></td>
    <td width=100px><input type="checkbox" id=red_o name="red_o"><script language="JavaScript">doc(OSPF_)</script></td>
    <td></td>
   </tr>     
 </table>
 
 
 <table cellpadding=1 cellspacing=2 border=0 align=center width=500px>
   <tr align="left">
   <script language="JavaScript">PrintWanTable()</script>
   <!--td id="h_wan2" name="h_wan2" class=r1 width=30px><input type="checkbox" id=rip_wan2 name="wan2"></td>
   <td id="h_wan2" name="h_wan2" class=r1 width=40px><script language="JavaScript">doc(WAN2_)</script></td>
   <td class=r1 width=30px><input type="checkbox" id=rip_lan name="lan"></td>
   <td class=r1><script language="JavaScript">doc(LAN_)</script></td-->
   <td></td>
   </tr>  
 </table>
 
<table align=left>
  <tr>
   <td style="width:600px" align=left><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
   <td width=15></td></tr>
 </table>
</fieldset>
</form>
</body></html>
