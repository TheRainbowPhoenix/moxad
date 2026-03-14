<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var SRV_MIRROR={port0:'0',port1:'0',port2:'0',port3:'0',port4:'0',port5:'0',port6:'0',port7:'0',port8:'0',port9:'0',port10:'0',port11:'0',port12:'0',port13:'0',port14:'0',port15:'0',direction:'0',mirror:'0'}
}else{
	var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}
	var SYSTRUNKS = {{ net_Web_Get_SYS_TRUNKS() | safe }}
	{{ net_Web_show_value('SRV_MIRROR') | safe }}
	{{ net_Web_show_value('SRV_TRUNK_SETTING') | safe }}
}

var dir_sel = [
	{ value:0, text:Input_Stream_},
	{ value:1, text:Output_Stream_},
	{ value:2, text:Bi_dir_}
];

var port_desc=[{{ net_webPortDesc() | safe }}];
var mirrorsel = [{ value:0, text:'--------'}];
var trunk_check=new Array;

function trunk_check_init()
{
    var i;
    for(i=0;i<= SYSTRUNKS;i++)
	    trunk_check[i]=0;
	for(i=0;i< SYSPORTS;i++)
		trunk_check[SRV_TRUNK_SETTING[i].trkgrp]++;
}

function show_Mirror_select()
{
    var i, idx, len, name;
	iGenSel2('mirror','mirror',mirrorsel);
	//trunk_check_init();
	for(i=0; i < SYSTRUNKS+SYSPORTS; i++)
	{
		if(i<SYSPORTS && SRV_TRUNK_SETTING[i].trkgrp==0)
		{
		    idx=i+1;
			name=port_desc[i].index;
			var varItem = new Option(name,idx);      
          	document.getElementById("mirror").options.add(varItem);   						
		}
	}

}
function show_Port_check()
{
	var i,idx,line_cnt=0;
	trunk_check_init();
	document.write('<table cellpadding=1 cellspacing=1 border=0>');
	document.write('<tr>');	
	for(i=0; i < SYSTRUNKS+SYSPORTS; i++)
	{
		if(i<SYSPORTS)
		{
	        idx=i+1;				
            if(SRV_TRUNK_SETTING[i].trkgrp==0)
            {	
			    document.write('<td class=r1>');				
				document.write('<input type=checkbox name=monitored'+i+' id=monitored'+i+' '+((parseInt(SRV_MIRROR["monitored"+i])) ? "checked":"") +'>');
	            document.write(port_desc[i].index+'</td>');
				line_cnt++;
			}
			else 
			{
				document.write('<input type=hidden name=monitored'+i+' id=monitored'+i+' value='+SRV_MIRROR["monitored"+i]+'>');				
		    }
		}
		else
		{
			idx=i+1;					
            if(trunk_check[i-SYSPORTS+1]!=0)
            {
                document.write('<td class=r1>');			
		        document.write('<input type=checkbox name=monitored'+i+' id=monitored'+i+'>');
			    idx=idx-SYSPORTS;
		        document.write('Trk '+idx+'</td>');
				line_cnt++;
			}
		    else
            {				
				document.write('<input type=hidden name=monitored'+i+' id=monitored'+i+' value='+SRV_MIRROR["monitored"+i]+'>');
			}
		}
		
		if(line_cnt%5==0)
		{
			document.write('</tr>');	
			document.write('<tr>');	
		}

	}
	document.write('</tr>');	
	document.write('</table>');

}
	
function Activate_to_check(form)
{
    	var i,port_cnt=0,moniter_flag=0,mir=0,moniter;

	for(i in SRV_MIRROR){
		moniter=i.slice(0,9);
		if(moniter != "monitored")
		continue;
		//alert(document.getElementById('monitored'+port_cnt).checked);
		if (document.getElementById(moniter+port_cnt).checked == true){
			moniter_flag=1;
		}
		port_cnt++;
	}

	mir = document.getElementById('mirror').value;
    port_cnt=mir-1;
	document.getElementById('mirror_setting_table').style.display="none";
	document.getElementById('active_button').style.display="none";

	if(moniter_flag==0 && mir != 0)
		document.getElementById('moniter_error_table').style.display="";

	else if(moniter_flag!=0 && mir == 0){
		document.getElementById('mirror_error_table').style.display="";
	}else if(mir != 0 && (document.getElementById('monitored'+port_cnt).checked == true)){
			document.getElementById('same_error_table').style.display="";
	}else{
		form.action="/goform/net_Web_get_value?SRV=SRV_MIRROR";
		form.submit();
	}
	 //alert("123");
}

function stopSubmit()
{
	return false;
}
var myForm;
function fnInit() {
	myForm = document.getElementById('myForm');
	document.getElementById('same_error_table').style.display="none";
	document.getElementById('moniter_error_table').style.display="none";
	document.getElementById('mirror_error_table').style.display="none";
	fnLoadForm(myForm, SRV_MIRROR, SRV_MIRROR_type);
}
//<tr><table width='670' align='left' border='0' id="mirror_setting">
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc("Port Mirroring")</script></h1>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<fieldset>
<input type="hidden" name="em_hidden" id="em_hidden" value="">
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2 id="mirror_setting_table">
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(" ")</script></td></tr>
 <tr align="left">
  <td width=120px><script language="JavaScript">doc(Monitor_)</script></td>
  <td width="300"><script language="JavaScript">show_Port_check()</script></td>
  </tr>
 <tr class=r2>
  <td width=120px><script language="JavaScript">doc(Direction_)</script></td>
  <td ><script language="JavaScript">iGenSel2('direction', 'direction', dir_sel)</script></td>
  </tr>
 <tr class=r3>
  <td width=120px><script language="JavaScript">doc(Mirror_)</script></td>
  <td ><script language="JavaScript">show_Mirror_select()</script></td>
  </tr>
</table>
<table class=tf align=left id="active_button">
 <tr height="120">
  <td><script language="JavaScript">fnbnS(Submit_, 'onClick=Activate_to_check(this.form)')</script></td>
  </tr>
</table>

<!--table: same_error_table-->
<table width="100%" border="0" align="center" id="same_error_table">
<tr>
<td width="100%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#ff0000">
<p><script language="JavaScript">doc(warningmsg_)</script></p>
<p><script language="JavaScript">doc(sameerror_)</script></p></font></div>
</td></tr>
</table>
<!--table: moniter_error_table-->
<table width="100%" border="0" align="center" id="moniter_error_table">
<tr>
<td width="100%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#ff0000">
<p><script language="JavaScript">doc(warningmsg_)</script></p>
<p><script language="JavaScript">doc(monitererror_)</script></p></font></div>
</td></tr>
</table>
<!--table: mirror_error_table-->
<table width="100%" border="0" align="center" id="mirror_error_table">
<tr>
<td width="100%" colspan="3"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett" color="#ff0000">
<p><script language="JavaScript">doc(warningmsg_)</script></p>
<p><script language="JavaScript">doc(mirrorerror_)</script></p></font></div>
</td></tr>
</table>
<!-- -->
</fieldset>
</form>
</body></html>
