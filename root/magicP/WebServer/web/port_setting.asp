<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">	
checkCookie();
checkMode(<% net_Web_GetMode_WriteValue(); %>);
var SYSPORTS = <% net_Web_Get_SYS_PORTS(); %>		
<%net_Web_show_value('SRV_PORT_SETTING');%>
<%net_Web_show_value('SRV_TRUNK_SETTING');%>
var port_desc=[<%net_webPortDesc();%>];

var speedsel = [
	{ value:0, text:AUTO_},	{ value:1, text:FULL_100M_}, { value:2, text:HALF_100M_}, { value:3, text:FULL_10M_}, { value:4, text:HALF_10M_}
];
var gigaspeedsel = [
	{ value:0, text:AUTO_}, { value:5, text:FULL_1G_},	{ value:1, text:FULL_100M_}, { value:2, text:HALF_100M_}, { value:3, text:FULL_10M_}, { value:4, text:HALF_10M_}
];
var fdxsel = [
	{ value:0, text:Disable_},	{ value:1, text:Enable_}
];
var mdisel = [
	{ value:0, text:AUTO_},	{ value:1, text:MDI_}, { value:2, text:MDIX_}
];
var disfdx = [
	{ value:0, text:Disable_}
];
var trkspeedsel = [
	{ value:0, text:FULL_100M_}
];
var nosel = [
	{ value:0, text:"----"}
];

var DSYS_PTYPE_TYPE_FIBER=0x04;
var port_count;
var trunk_check=new Array;
var trunk_all=4;



function enableClick(item)
{
	var idx, idname;
	idx=parseInt(item.name.substring(6, item.name.len),10);
	if(item.checked)
	{   SRV_PORT_SETTING['enable'+idx]=1;
	    idname = "speed"+idx;
		document.getElementById(idname).disabled="";
		if(speedsel[document.getElementById(idname).selectedIndex].value==0)
	    {
		idname = "fdx"+idx;
		document.getElementById(idname).disabled="";
		}
		idname = "mdi"+idx;
		document.getElementById(idname).disabled="";
	}
	else
	{   SRV_PORT_SETTING['enable'+idx]=0;
	    idname = "speed"+idx;
		document.getElementById(idname).disabled="true";
	    idname = "fdx"+idx;
		document.getElementById(idname).disabled="true";
		idname = "mdi"+idx;
		document.getElementById(idname).disabled="true";	
	}
	
}

function speedChange(item)
{
	var idx, idname;
	idx=parseInt(item.name.substring(5, item.name.len),10);
	//alert(document.getElementById(item.name).selectedIndex);
	if(speedsel[document.getElementById(item.name).selectedIndex].value!=0)
	{
		idname = "fdx"+idx;
		document.getElementById(idname).disabled="true";
		document.getElementById(idname).value=0;
		//document.getElementById(idname).text="disable";
	}
	else if(speedsel[document.getElementById(item.name).selectedIndex].value==0 && 
		SRV_PORT_SETTING['enable'+idx]==1)
	{
		idname = "fdx"+idx;
		document.getElementById(idname).disabled="";
	}
	
}

function enableCheck(name,i)
{
    var idname;
	//for(i=0; i<SYSPORTS; i++)
	//{
	    if(name['enable'+i]==0)
	    {
		    idname = "speed"+i;
		    document.getElementById(idname).disabled="true";
		    idname = "fdx"+i;
		    document.getElementById(idname).disabled="true";
		    idname = "mdi"+i;
		    document.getElementById(idname).disabled="true";
	    }
	//}
}

function get_desc_text(desc, value)
{
	var i;
	for(i =0;i<desc.length;i++){
		if(desc[i].value == value){
			return desc[i].text;
		}
	}  
}



function Addformat(idx, name, newdata)
{	
    var select_speed,speed_value;
	var speed,media, port_dest;
    if(idx<SYSPORTS)
    {	
		newdata[0] = port_desc[idx].index;	
		newdata[1] = "<input type=checkbox name="+'enable'+idx+ " id="+'enable'+idx+ " " + ((parseInt(name['enable'+idx])) ? 'checked':'') +" onclick=enableClick(this) >";
		newdata[2] = port_desc[idx].desc;
		newdata[3] = "<input size=55 maxlength=48 type=text name="+'portname'+idx+ " id="+'portname'+idx+ " value="+ name['portname'+idx]+">";
		if(EDR_IF_IS_FIBER(port_desc, idx))
			newdata[4] = iGenSel2Str('speed' + idx,'speed' + idx,gigaspeedsel);
		else
	newdata[4] = iGenSel4Str('speed' + idx,'speed' + idx,speedsel,"speedChange");
	newdata[5] = iGenSel2Str('fdx' + idx,'fdx' + idx,fdxsel);
	newdata[6] = iGenSel2Str('mdi' + idx,'mdi' + idx,mdisel);
	newdata[7] = "<input type=hidden name="+'description'+idx+" id="+'description'+idx+" value="+name['description'+idx]+">";
    }else
	{
	var trkid=idx-SYSPORTS+1;
	newdata[0] = 'Trk'+trkid;	
		newdata[1] = "<input type=checkbox name="+'enable'+idx+ " id="+'enable'+idx+ " " + ((parseInt(name['enable'+idx])) ? 'checked':'') +">";
	newdata[2] = " ";
		newdata[3] = "<input size=55 maxlength=331 type=text name="+'portname'+idx+ " id="+'portname'+idx+ " value="+ name['portname'+idx]+">";
		newdata[4] = iGenSel2StrDisabled('speed' + idx,'speed' + idx, gigaspeedsel);
	newdata[5] = iGenSel2StrDisabled('fdx' + idx,'fdx' + idx,fdxsel);
	newdata[6] = iGenSel2StrDisabled('mdi' + idx,'mdi' + idx,nosel);
	newdata[7] = "<input type=hidden name="+'description'+idx+" id="+'description'+idx+" value="+name['description'+idx]+">";
	}
}	

function tableinit(){
	var newdata=new Array;
	var i;
		
	//for(i=0; i<port_count; i++){
	for(i=0; i<SYSPORTS; i++){
	    if(SRV_TRUNK_SETTING[i].trkgrp==0)
	    {
		    Addformat(i, SRV_PORT_SETTING, newdata);
		    tableaddRow("port_setting_table", i, newdata, "center");
			enableCheck(SRV_PORT_SETTING,i);	
	    }
		else
		{
		   trunk_check[SRV_TRUNK_SETTING[i].trkgrp]=1;
		}
	}
	for(i=0;i< trunk_all;i++)
		{
		   if( trunk_check[i+1]==1)
		   	{
		    Addformat(SYSPORTS+i, SRV_PORT_SETTING, newdata);
		    tableaddRow("port_setting_table", i, newdata, "center");		   	    
		   	}
		}
	
	for(i=0;i<SYSPORTS;i++){		
		if(SRV_TRUNK_SETTING[i].trkgrp==0){
			if(EDR_IF_IS_FIBER(port_desc, i)){		
				document.getElementById('speed' + i).disabled=true;
				document.getElementById('mdi' + i).disabled=true;
			}
		}else{
			if(EDR_IF_IS_FIBER(port_desc, i)){		
				document.getElementById('speed' + (SYSPORTS+parseInt(SRV_TRUNK_SETTING[i].trkgrp)-1)).disabled=true;
				document.getElementById('mdi' + (SYSPORTS+parseInt(SRV_TRUNK_SETTING[i].trkgrp)-1)).disabled=true;
			}
		}
	}
	//enableCheck(SRV_PORT_SETTING);
}


function isSystemSymbol(obj, ObjName){
	var TempObj;
	TempObj=obj.value;
	//var regu = "^[0-9a-zA-Z_@\u0020\u002d\u002e\u002f]+$";
	var regu = "^[0-9a-zA-Z_@!#$%^&*()\.\/\ \-]+$";    
	var re = new RegExp(regu);
	if (re.test( TempObj ) ) {    
		return 0;    
	} 
	else{   
		alert(MsgHead[0]+ObjName+MsgStrs[5]);
		return 1;    
	}
}

function space_check(obj)
{
	var i, substr, error_return_t=0;
		
	substr =obj.value.split(" ");
	if(substr.length > 5) {
        alert(Name_+" can only have at most 4 space.");
        error_return_t = 1;
    }

    for(i = 0; i < substr.length; i++) {
        // Case: continued spaces but not empty
        if((substr[i].length == 0) && (i != 0)) {
            alert(Name_+" cannot have continued spaces.");
            error_return_t = 1;
        }
    }	
	return error_return_t;
}



function ActivatetoEnable(form)
{	
	var i,temp;

	var error_return_t = 0;
	for(i in SRV_PORT_SETTING){		
		if(i.substring(0, 8)=="portname")
		{
		    if(document.getElementById(i)) 
			    if(!isNull(document.getElementById(i).value)){
		            if((isSystemSymbol(document.getElementById(i), Name_)))
			            error_return_t = 1;
					if(space_check(document.getElementById(i)))
						error_return_t = 1;
			    }
		}
	}
	if (error_return_t)
		return;
	
	for(i in SRV_PORT_SETTING)
	{
	if(document.getElementById(i))
		document.getElementById(i).disabled="";	

	}
	
	form.action="/goform/net_Web_get_value?SRV=SRV_PORT_SETTING";	
	form.submit();	
}
function stopSubmit()
{
	return false;
}

var myForm;
function fnInit() {
		myForm = document.getElementById('myForm');	
	var i;
	port_count=0;
	//alert(myForm["speed0"]);
	for(i in SRV_PORT_SETTING){
		if(i.substring(0, 3)=="fdx")
			port_count++;
	}
	tableinit();
	fnLoadForm(myForm, SRV_PORT_SETTING, SRV_PORT_SETTING_type);
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc("Port Setting")</script></h1>
<form id=myForm method="post" name="port_setting_form" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<table width="100%" border="0" align="left">
<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td width="97%" colspan="2">
		<table width="690" border="0" align="left" id="port_setting_table">
  			<tr bgcolor="#007C60">
  				<th width="6%" class=s0><script language="JavaScript">doc(Port_)</script></th>
    			<th width="9%" class=s0><script language="JavaScript">doc(Enable_)</script></th>
    			<th width="13%" class=s0><script language="JavaScript">doc(MediaType_)</script></th>
    			<th width="34%"><script language="JavaScript">doc(Description_)</script></th>
    			<th width="13%"><script language="JavaScript">doc(Speed_)</script></th>
    			<th width="13%" class=s0><script language="JavaScript">doc(Fdx_)</script></th>
    			<th width="10%" class=s0><script language="JavaScript">doc(Mdi_)</script></th>
  			</tr>
		</table>
	</td>
</tr>
<tr>
	<td width="3%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
		</font></div></td>
	<td><script language="JavaScript">fnbnS(Submit_, 'onClick=ActivatetoEnable(this.form)')</script></td></tr>
</tr>
<table style="visibility:hidden" id="hidden_table">
</table>
</table>

</form>
</body>
</html>
