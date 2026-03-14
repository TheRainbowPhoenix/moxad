<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
checkCookie();
var nowan={{ net_Web_GetNO_WAN_WriteValue() | safe }};
var noifs={{ net_Web_GetNO_IFS_WriteValue() | safe }};	
var MsgStr=[primary_msg];
if (debug) {
	var wdata = [
		{{ net_websIpset() | safe }}	
	];	
	{{ net_Web_show_value('SRV_IP_CLIENT') | safe }}
	{{ net_Web_show_value('SRV_VLAN') | safe }}
	{{ net_Web_show_value('SRV_VCONF') | safe }}	
}else{
	var wdata = [
		{widx:'1', wsta:'2', wtyp:'0',stip:'192.168.10.120', stmk:'0.0.0.0', stgw:'0.0.0.0', ppen:'0',psrv:'0.0.0.0', pusr:'', ppwd:'', mppe:'1', eusr:'', epwd:'', ehnm:'', dns1:'0.0.0.0',dns2:'0.0.0.0',dns3:'0.0.0.0', htnm:'', domn:'', wmac:'00-00-00-00-00-00' },
		{widx:'2', wsta:'2', wtyp:'0',stip:'0.0.0.0', stmk:'0.0.0.0', stgw:'0.0.0.0', ppen:'0',psrv:'0.0.0.0', pusr:'', ppwd:'', mppe:'1', eusr:'', epwd:'', ehnm:'', dns1:'0.0.0.0',dns2:'0.0.0.0',dns3:'0.0.0.0', htnm:'', domn:'', wmac:'00-00-00-00-00-00' }	
	];
}

var wan0 = [
	{ value:0, text:'WAN 1' },	{ value:1, text:'WAN 2' }
	];
	var updb = 'Update';

var wtype = {
	wsta:1, wtyp:2, stip:5, stmk:6, stgw:5,
	ppen:3, psrv:4, pusr:4, ppwd:4, mppe:2, eusr:4, epwd:4, ehnm:4,
	dns1:5, dns2:5, dns3:5, bcast:3//, htnm:4, domn:4, wmac:7
};

var wtyp0 = [
	{ value:0, text:Static_IP },	{ value:1, text:Dynamic_IP },
	{ value:4, text:PPPoE_ }
];
var linkmip = 'multiipsetting.asp?action=&page=0&back=0&';

var DataChg=false;
var seliface = { type:'select', id:'widx', name:'iface', size:1, onChange:'fnChgIface(this.value)', option:wan0 };
var selwtyp = { type:'select', id:'wtyp', name:'proto', size:1, onChange:'fnChgLType(this.value)', option:wtyp0 };

var vobjs = {};
var vname = ['trst0', 'trst1', 'trst2', 'trst3', 'trpp0', 'trpp1', 'trpp2', 'troe0', 'troe1' ];
var vnam2 = ['TDpen', 'TDpphd', 'TDden'];
//var vnam2 = ['TDpen', 'TDpphd', 'TDbkif'];

var cur_idx, myForm;
var DMZ_EN = 8;
var vidsel = [{ value:"0", text:"--------"}];
function ShowVlanId(){	
	if(nowan!=noifs-1){
		document.write('<tr class=r0>');
		document.write('<td colspan=4><script language="JavaScript">doc(V_ID_)<\/script><\/td><\/tr>');
	}
}

function check_vlan_inuse( vlanid){
	var i,j;

	for(i=0;i< SRV_VCONF.length;i++){
		if(SRV_VCONF[i].vid==vlanid)
			return 0;
	}
	return 1;
}



function fnInit(row) {
	var table=document.getElementById("vlan_id");
	var newdata=new Array;
	var i;
	var rowidx = table.insertRow(table.getElementsByTagName("tr").length);
	if(nowan!=noifs-1){
		for(i=1; i < SRV_VLAN.length; i++){
			if(check_vlan_inuse(SRV_VLAN[i].vlanid)){
			vidsel[i+1] = new Array;
			vidsel[i+1].value=SRV_VLAN[i].vlanid;
			vidsel[i+1].text=SRV_VLAN[i].vlanid;
		}	
		}	
		newdata[0]=iGenSel2Str('vid', 'vid', vidsel);
		tableaddRow("vlan_id", 0, newdata, "left");	
		document.getElementById("vid").selectedIndex = wdata[row].vid;
	}
	with (document) {
		myForm = getElementById('myForm');
		for (var i in vname)
			vobjs[vname[i]] = getElementById(vname[i]).style;
		for (var i in vnam2)
			vobjs[vnam2[i]] = getElementById(vnam2[i]);
	}
	//myForm.widx.selectedIndex = fnGetSelIndex(wdata[row].widx, wan0);

	if(wdata[0].mppe > 0){	
		document.getElementById('myForm').mppe[0].checked = false;
		document.getElementById('myForm').mppe[1].checked = true;
	}
	else{
		document.getElementById('myForm').mppe[0].checked = true;
		document.getElementById('myForm').mppe[1].checked = false;
	}

	fnEnDMZ(myForm.dmz.checked);
	EditRow(row);
}

/*function fnGetSelIndex(val, opt) {
	for (var i in opt)
		if (opt[i].value==val)
			return i;
	return 0;
}

function fnChgIface(widx) {
	if (!fnChkChg(myForm, wdata[cur_idx], wtype) || confirm(MsgStr[0]) ) {
		var idx=fnGetSelIndex(widx, wan0);
		if (wdata[idx])
			EditRow(idx);
	} else
		myForm.widx.selectedIndex = cur_idx;
}*/

function fnEnDMZ(dmzpen) {
	with (myForm) {
		psrv.disabled = dmzpen;
		pusr.disabled = dmzpen;
		ppwd.disabled = dmzpen;
		ppen.disabled = dmzpen;
		wtyp.disabled = dmzpen;
		stgw.disabled = dmzpen;
		dns1.disabled = dmzpen;
		dns2.disabled = dmzpen;
		dns3.disabled = dmzpen;
		wsta[2].disabled=dmzpen;
	}
	if(!dmzpen){
		fnEnPPTP(myForm.ppen.checked);
	}
}

function fnEnPPTP(pptpen) {
	with (myForm) {
		psrv.disabled=!pptpen;
		pusr.disabled=!pptpen;
		ppwd.disabled=!pptpen;
		mppe[0].disabled=!pptpen;
		mppe[1].disabled=!pptpen;
	}
}

function fnEnBcast(checked)
{
	if(checked == true){
		document.getElementById('bcastIP').disabled = false;
	}
	else{
		document.getElementById('bcastIP').disabled = true;
		document.getElementById('bcastIP').checked = false;
	}
}

function EditRow(row) {
	cur_idx = row;
	fnLoadForm(myForm, wdata[row], wtype);
	fnChgLMode(wdata[row].wsta);
}

function fnChgLType(val) {
	with (document) {
		vobjs.trst0.display = (val==0) ? '' : 'none' ;
		vobjs.trst1.display = (val==0) ? '' : 'none' ;
		vobjs.trst2.display = (val==0) ? '' : 'none' ;
		vobjs.trst3.display = (val==0) ? '' : 'none' ;		

		vobjs.TDden.disabled = !(val==0) ;

		vobjs.TDpen.disabled = val==4 ;
		vobjs.TDpphd.innerHTML = (val==4 ? PPPoE_ : PPTP_ ) +' '+ Dialup_;

		vobjs.trpp0.display = (val==4) ? 'none' : '' ;
		vobjs.trpp1.display = (val==4) ? 'none' : '' ;
		vobjs.trpp2.display = (val==4) ? 'none' : '' ;
		vobjs.troe0.display = (val==4) ? '' : 'none' ;
		vobjs.troe1.display = (val==4) ? '' : 'none' ;
	}
	fnEnPPTP(myForm.ppen.checked);
}

function fnChgLMode(mode) {
	if(mode == 2)
		document.getElementById('dmz').disabled=true;
	else
		document.getElementById('dmz').disabled=false;
}
/*
function fnGenBkIface(row) {
	var s = '';
	for (i=0; i<wdata.length; i++)
		if (i != row)
			s+=' <input type="checkbox" name="bk_iface" value='+eval(2^(i+1))+'>WAN'+(i+1);
	vobjs.TDbkif.innerHTML=s;
}
*/
function Send(form) {
	with (myForm) {
		psrv.disabled = false;
		pusr.disabled = false;
		ppwd.disabled = false;
		mppe[0].disabled = false;
		mppe[1].disabled = false;
	}
	
	if(document.getElementsByName('state')[2].checked==true)
		alert(backup_alert_);
	if(myForm.wtyp.value==4){
		if(isNull(myForm.eusr.value) ||	isNull(myForm.epwd.value)){
			alert(PPPoE_Dialup + " User Name or Password Null")
			return;
		}else{
			if( isSymbol(myForm.eusr, PPPoE_Dialup + 'User Name')
			 || isSymbol(myForm.epwd, PPPoE_Dialup + 'Password')
			 || isSymbol(myForm.ehnm, PPPoE_Dialup + 'Host Name')) {
				return;
			}
		}
	} else {
		if(myForm.wtyp.value == 0) {
			if(!IpAddrNotMcastIsOK(myForm.stip,IP_Address) || !NetMaskIsOK(myForm.stmk, "Subnet_Mask")) {
				return;
			}
		}
		if(myForm.ppen.checked) {
			if(isNull(myForm.pusr.value) ||	isNull(myForm.ppwd.value)) {
				alert(PPTP_Connection + " User Name or Password is Null");
				return;
			} else {
				if( isSymbol(myForm.pusr, PPTP_Connection + 'User Name')
			 	|| isSymbol(myForm.ppwd, PPTP_Connection + 'Password')) {
					return;
				}
			}
			if(!isNull(myForm.psrv.value))
				if(!IsIpOK(myForm.psrv,PPTP_Connection + IP_Address))
					return;
		}
	}
	if(!isNull(myForm.stgw.value))
		if(!IsIpOK(myForm.stgw,Gateway_))
			return;
	if(!isNull(myForm.dns1.value))
		if(!IsIpOK(myForm.dns1,DNS_Optional_for_dynamic_IP))
			return;
	if(!isNull(myForm.dns2.value))
		if(!IsIpOK(myForm.dns2,DNS_Optional_for_dynamic_IP))
			return;
	if(!isNull(myForm.dns3.value))
		if(!IsIpOK(myForm.dns3,DNS_Optional_for_dynamic_IP))
			return;
	form.action="/goform/net_WebIPCLIENTGetValue?wan=1";
	form.submit();
}

</script>
</head>
<body onLoad=fnInit(0)>
<h1><script language="JavaScript">doc(WAN_)</script>&nbsp;&nbsp;<script language="JavaScript">doc(Configuration_)</script></h1>

<fieldset>
<form id=myForm method="POST">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" id=dmz name="dmz_en" onClick="fnEnDMZ(this.checked)">
<table cellpadding=1 cellspacing=2 border=0 id="vlan_id">
<script language="JavaScript">ShowVlanId()</script>
</table>
<table cellpadding=1 cellspacing=2 border=0>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(Connection_)</script></td></tr>
<!-- <tr class=r1>
  <td><script language="JavaScript">doc(Interface_)</script></td>
  <td><script language="JavaScript">doc(WAN_)</script>1</td>  
  </tr>-->
 <tr>
  <td width = 360px colspan=4><script language="JavaScript">doc(Connect_Mode)</script>
  <input type="radio" id=wsta name="state" value=0 onClick=fnChgLMode(0)> <script language="JavaScript">doc(Disable_)</script>
  <input type="radio" id=wsta name="state" value=1 onClick=fnChgLMode(1)> <script language="JavaScript">doc(Enable_)</script>
  <input type="hidden" id=wsta name="state" value=2 onClick=fnChgLMode(2)> </td>
  <td id=TDden></td>
  </td></tr>  
 <tr>
  <td colspan=4>
  	<script language="JavaScript">doc(Connect_Type)</script>
	<script language="JavaScript">fnGenSelect(selwtyp, '')</script>
  </td></tr>
 <tr colspan=4>
  <script language="JavaScript">hr(3)</script></tr>
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(DIR_BCAST)</script></td></tr>
 <tr>
  <td colspan=4>
  	<input type="checkbox" id=bcast name="bcast" onChange="fnEnBcast(this.checked)">
	<script language="JavaScript">doc(Enable_)</script>
	<input type="checkbox" id=bcastIP name="bcastIP">
	<script language="JavaScript">doc(OVERWRITE_SRC_IP)</script>
  </td></tr>
 <!--tr class=r2>
  <td>Backup of</td>
  <td colspan=2 id=TDbkif>&nbsp;</td></tr-->
 <tr colspan=4>
  <script language="JavaScript">hr(3)</script></tr>
 <tr class=r0 id=trst0>
  <td colspan=4><script language="JavaScript">doc(Address_Information)</script></td></tr>  
  <td colspan=4>
  <table>
   <tr id=trst1>
    <td style="width:80px"><script language="JavaScript">doc(IP_Address)</script></td>
    <td style="width:170px"><input type="text" size=15 maxlength=15 id=stip name="ipaddr"></td>
    <td style="width:50px"><script language="JavaScript">doc(Gateway_)</script></td>
    <td><input type="text" size=15 maxlength=15 id=stgw name="gateway"></td></tr>
    <td></<td>
   <tr id=trst2>
    <td><script language="JavaScript">doc(Subnet_Mask)</script></td>
    <td><input type="text" size=15 maxlength=15 id=stmk name="netmask"></td></tr>
    <td></<td>
   <tr id=trst3>
    <script language="JavaScript">hr(3)</script>
  </table></td></tr>
 <tr class=r0>
  <td colspan=4 id=TDpphd><script language="JavaScript">doc(PPPoE_Dialup)</script></td></tr>
  <tr id=trpp0>
  <td id=TDpen><script language="JavaScript">doc(PPTP_Connection)</script>
      <input type="checkbox" id=ppen name="pptp_en" onClick="fnEnPPTP(this.checked)"><script language="JavaScript">doc(Enable_)</script></td>
  <td><script language="JavaScript">doc(IP_Address)</script>
      <input type="text" size=15 maxlength=15 id=psrv name="pptp_srvr">
 </td></tr>
 <tr id=trpp1>
  <td style="width:250px"><script language="JavaScript">doc(User_Name)</script>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="text" size=15 maxlength=64 id=pusr name="pptp_user"></td>
  <td><script language="JavaScript">doc(Password_)</script>&nbsp
      <input type="text" size=15 maxlength=64 id=ppwd name="pptp_pswd"></td></tr>     
 <tr id=trpp2>
	<td><script language="JavaScript">doc(MPPE_Eencryption)</script>
	  <input type="radio" id=mppe name="mppe" value=0 onClick=fnChgLMode(0)> <script language="JavaScript">doc(None_)</script>
	  <input type="radio" id=mppe name="mppe" value=1 onClick=fnChgLMode(1)> <script language="JavaScript">doc(Encrypt_)</script></td></tr>
 <tr id=troe0>
  <td style="width:250px"><script language="JavaScript">doc(User_Name)</script>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="text" size=15 maxlength=64 id=eusr name="poe_user"></td>
  <td><script language="JavaScript">doc(Password_)</script>
      <input type="text" size=15 maxlength=64 id=epwd name="poe_pswd"></td></tr>
 <tr id=troe1>
  <td style="width:250px"><script language="JavaScript">doc(Host_Name)</script>&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="text" size=15 maxlength=64 id=ehnm name="poe_host"></td></tr>
 <tr >
  <script language="JavaScript">hr(3)</script></tr> 
</table>

<table cellpadding=1 cellspacing=2 width=600px>
 <tr class=r0>  
  <td colspan=4><script language="JavaScript">doc(DNS_Optional_for_dynamic_IP_PPPoE_IP)</script></td></tr>
 <tr>
    <td width=150px><script language="JavaScript">doc(Server_)</script> 1</td>
    <td width=150px><script language="JavaScript">doc(Server_)</script> 2</td>
	<td ><script language="JavaScript">doc(Server_)</script> 3</td></tr>
 <tr>
    <td><input type="text" size=15 maxlength=15 id=dns1 name="dnsip1"></td>
    <td><input type="text" size=15 maxlength=15 id=dns2 name="dnsip2"></td>
    <td><input type="text" size=15 maxlength=15 id=dns3 name="dnsip3"></td></tr>
</table>

<table align=left>
<tr>
  <td><script language="JavaScript">fnbnB(Submit_, 'onClick=Send(this.form)')</script></td>
  <td width=15></td>
</table>
</form>
</fieldset>

</body></html>
