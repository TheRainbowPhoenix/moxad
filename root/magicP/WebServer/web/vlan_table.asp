<html>
<head> 
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
var NON_FLAG  =0;
var TAG_FLAG  =1;
var UNTAG_FLAG=2;
if (!debug) {
	var wdata0 = {
		enable:'1', vid:'0', ip:'192.168.45.1',mask:'255.255.255.0'		
	};	
	var wtype0 = {
		enable:3, vid:4, ip:5, mask:5 
	};
}else{	
	<%net_Web_show_value('SRV_VLAN');%>	
	<%net_Web_show_value('SRV_VPLAN');%>	
	<%net_Web_show_value('SRV_TRUNK_SETTING');%>		
}
var port_desc=[<%net_webPortDesc();%>];
var trk_name="trk";
var trunk_all=4;
function addtd(content){
	document.write("<td>"+content+"</td>")
}

function vlan_delete( entry){
	var table=document.getElementById("vlan_table");
	
	SRV_VLAN[entry].vlanid=0;
	table.getElementsByTagName("tr")[entry+1].style.display="none";
}

function ShowVlanList(){
	var i, j, vid, deletebton;
	var acc_member,trunk_member,hybrid_member;

	for(i=0;i < SRV_VLAN.length; i++){
		acc_member="";
		trunk_member="";
		hybrid_member="";
		vid="";
		if(i%2==0){
			document.write("<tr class=even>");
		}else{
			document.write("<tr class=odd>");
		}
		addtd(i+1);
		if(i==0){
			vid = '*'; 
		}else{
			vid = "&nbsp"; 
		}
		addtd(vid +=SRV_VLAN[i].vlanid);
		for(j=0;j<SRV_VPLAN.length;j++){
			if(SRV_VLAN[i]["port"+j]==NON_FLAG){
				continue;
			}else if(SRV_VLAN[i]["port"+j]==UNTAG_FLAG&&(SRV_VPLAN[j]["pvid"]==SRV_VLAN[i].vlanid)){
				if(j<SRV_VPLAN.length-trunk_all){
					acc_member+=port_desc[j].index+',';
				}else{
					acc_member+=trk_name+(j-(SRV_VPLAN.length-trunk_all)+1)+',';
				}
			}else if(SRV_VLAN[i]["port"+j]==TAG_FLAG){
				if(j<SRV_VPLAN.length-trunk_all){
					trunk_member+=port_desc[j].index+',';
				}else{
					trunk_member+=trk_name+(j-(SRV_VPLAN.length-trunk_all)+1)+',';
				}
			}else{
				if(j<SRV_VPLAN.length-trunk_all){
					hybrid_member+=port_desc[j].index+',';
				}else{
					hybrid_member+=trk_name+(j-(SRV_VPLAN.length-trunk_all)+1)+',';
				}
			}
		}
		addtd(acc_member);
		addtd(trunk_member);
		addtd(hybrid_member);
		if(acc_member==""&&trunk_member==""&&hybrid_member==""){
			deletebton = '<input class=b0 type=button value="'+Delete_+'" onClick=vlan_delete('+i+')'+'>';
		}else{
			deletebton="";
		}
		addtd(deletebton);
		document.write("</tr>");
	}
	

}


function fnInit(){
}

function Activate(form){
	var i,j;

	form.vlantmp.value="";
	for(i=0;i<SRV_VLAN.length;i++){
		if(SRV_VLAN[i].vlanid!=0){
			for(j in SRV_VLAN[i]){
				form.vlantmp.value+=SRV_VLAN[i][j]+'+';
			}			
		}
	}

	form.action="/goform/net_Web_get_value?SRV=SRV_VLAN";
	form.submit();	
}
function stopSubmit()
{
	return false;
}
</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(VLAN_MANAG)</script></h1>
<form method="post" name="vlan_setting_form" onSubmit="return stopSubmit()">
<fieldset>
<input type="hidden" name="SRV_VLAN_tmp" id="vlantmp" value="" >
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0>
 <tr>
     <td><table>
          	 <tr><td><table id="vlan_table">
           	       <tr>           	    
                  	  <th width="6%"><script language="JavaScript">doc(Index_)</script></th>
                      <th width="7%" class=s0><script language="JavaScript">doc(VID_)</script></th>    
                      <th width="27%" class=s0><script language="JavaScript">doc(JOIN_ACCESS_PORT)</script></th>
                      <th width="27%" class=s0><script language="JavaScript">doc(JOIN_TRUNK_PORT)</script></th>    
                      <th width="27%" class=s0><script language="JavaScript">doc(JOIN_HYBRID_PORT)</script></th>
                      <th width="6%"><script language="JavaScript">doc(Action_)</script></th>
                   </tr>
                   <script language="JavaScript">ShowVlanList()</script>               
                   
          	 </table></td></tr>
          	 <tr><td><script language="JavaScript">fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td></tr>
         </table>
      </td></tr>
</table>
</fieldset>
</form>
</body>
</html>
