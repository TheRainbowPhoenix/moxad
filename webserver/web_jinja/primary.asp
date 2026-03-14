<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(Primary_Setup)</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var MsgStr=[primary_msg];
if (debug) {
	var wdata = [
		{{ net_websIpset() | safe }}	
	];
}else{
	var wdata = [
		{widx:'1', wsta:'2', wtyp:'0',stip:'192.168.10.120', stmk:'0.0.0.0', stgw:'0.0.0.0', ppen:'0',psrv:'0.0.0.0', pusr:'', ppwd:'',eusr:'', epwd:'', ehnm:'', dns1:'0.0.0.0',dns2:'0.0.0.0',dns3:'0.0.0.0', htnm:'', domn:'', wmac:'00-00-00-00-00-00' },
		{widx:'2', wsta:'2', wtyp:'0',stip:'0.0.0.0', stmk:'0.0.0.0', stgw:'0.0.0.0', ppen:'0',psrv:'0.0.0.0', pusr:'', ppwd:'',eusr:'', epwd:'', ehnm:'', dns1:'0.0.0.0',dns2:'0.0.0.0',dns3:'0.0.0.0', htnm:'', domn:'', wmac:'00-00-00-00-00-00' }
	
	];
}

var wan0 = [
	{ value:0, text:'WAN 1' },	{ value:1, text:'WAN 2' }
	];
	var updb = 'Update';

var wtype = {
	wsta:1, wtyp:2, stip:5, stmk:6, stgw:5,
	ppen:3, psrv:4, pusr:4, ppwd:4, eusr:4, epwd:4, ehnm:4,
	dns1:5, dns2:5, dns3:5//, htnm:4, domn:4, wmac:7
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
var vname = ['trst0', 'trst1', 'trst2', 'trst3', 'trpp0', 'trpp1', 'troe0', 'troe1' ];
var vnam2 = ['TDpen', 'TDpphd', 'TDden'];
//var vnam2 = ['TDpen', 'TDpphd', 'TDbkif'];

var cur_idx, myForm;
function fnInit(row) {
	with (document) {
		myForm = getElementById('myForm');
		for (var i in vname)
			vobjs[vname[i]] = getElementById(vname[i]).style;
		for (var i in vnam2)
			vobjs[vnam2[i]] = getElementById(vnam2[i]);
	}
	myForm.widx.selectedIndex = fnGetSelIndex(wdata[row].widx, wan0);
	EditRow(row);
}

function fnGetSelIndex(val, opt) {
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
}

function fnEnDMZ(dmzpen) {
	with (myForm) {
		psrv.disabled = dmzpen;
		pusr.disabled = dmzpen;
		ppwd.disabled = dmzpen;
		ppen.disabled = dmzpen;
		wtyp.disabled = dmzpen;
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
		vobjs.troe0.display = (val==4) ? '' : 'none' ;
		vobjs.troe1.display = (val==4) ? '' : 'none' ;
	}
	fnEnPPTP(myForm.ppen.checked);
}

function fnChgLMode(mode) {
//	vobjs.TDbkif.disabled = (mode!=2) ;
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
function Send() {
	with (myForm) {
		psrv.disabled = false;
		pusr.disabled = false;
		ppwd.disabled = false;
	}
}
</script>
</head>
<body class=main onLoad=fnInit(0)>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[0].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[0])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm method="POST" action="/goform/net_WebIPCLIENTGetValue">
{{ net_Web_csrf_Token() | safe }}
<table cellpadding=1 cellspacing=2>
 <tr class=r0>
  <td colspan=3><script language="JavaScript">doc(Connection_)</script></td></tr>
 <tr class=r1>
  <td><script language="JavaScript">doc(Interface_)</script></td>
  <td><script language="JavaScript">fnGenSelect(seliface, wdata[0].widx)</script></td>
  <td id=TDden><input type="checkbox" id=dmz name="dmz_en" value=1 onClick="fnEnDMZ(this.checked)">DMZ <script language="JavaScript">doc(Enable_)</script></td></tr>
 <tr class=r2>
  <td><script language="JavaScript">doc(Connect_Mode)</script></td>
  <td><script language="JavaScript">doc(Connect_Type)</script></td>
  <td><script language="JavaScript">doc(PPTP_Connection)</script></td></tr>
 <tr class=r1>
  <td><input type="radio" id=wsta name="state" value=0 onClick=fnChgLMode(0)> <script language="JavaScript">doc(Disable_)</script>
      <input type="radio" id=wsta name="state" value=1 onClick=fnChgLMode(1)> <script language="JavaScript">doc(Enable_)</script>
      <input type="radio" id=wsta name="state" value=2 onClick=fnChgLMode(2)> Backup</td>
  <td><script language="JavaScript">fnGenSelect(selwtyp, '')</script></td>
  <td id=TDpen><input type="checkbox" id=ppen name="pptp_en" onClick="fnEnPPTP(this.checked)"><script language="JavaScript">doc(Enable_)</script></td></tr>
 <!--tr class=r2>
  <td>Backup of</td>
  <td colspan=2 id=TDbkif>&nbsp;</td></tr-->
 <tr class=r1>
  <script language="JavaScript">hr(3)</script></tr>
 <tr class=r0 id=trst0>
  <td colspan=3><script language="JavaScript">doc(Address_Information)</script></td></tr>
 <tr class=r1 id=trst1>
  <td><script language="JavaScript">doc(IP_Address)</script></td>
  <td><script language="JavaScript">doc(Subnet_Mask)</script></td>
  <td><script language="JavaScript">doc(Gateway_)</script></td></tr>
 <tr class=r2 id=trst2>
  <td><input type="text" size=15 maxlength=15 id=stip name="ipaddr"></td>
  <td><input type="text" size=15 maxlength=15 id=stmk name="netmask"></td>
  <td><input type="text" size=15 maxlength=15 id=stgw name="gateway"></td></tr>
 <tr class=r1 id=trst3>
  <script language="JavaScript">hr(3)</script></tr>
 <tr class=r0>
  <td colspan=3 id=TDpphd><script language="JavaScript">doc(PPPoE_Dialup)</script></td></tr>
 <tr class=r1 id=trpp0>
  <td><script language="JavaScript">doc(PPTP_Server_IP_Address)</script></td>
  <td><script language="JavaScript">doc(User_Name)</script></td>
  <td><script language="JavaScript">doc(Password_)</script></td></tr>
 <tr class=r2 id=trpp1>
  <td><input type="text" size=15 maxlength=15 id=psrv name="pptp_srvr"></td>
  <td><input type="text" size=15 maxlength=47 id=pusr name="pptp_user"></td>
  <td><input type="text" size=15 maxlength=35 id=ppwd name="pptp_pswd"></td></tr>
 <tr class=r1 id=troe0>
  <td><script language="JavaScript">doc(User_Name)</script></td>
  <td><script language="JavaScript">doc(Password_)</script></td>
  <td>PPPoE <script language="JavaScript">doc(Host_Name)</script></td></tr>
 <tr class=r2 id=troe1>
  <td><input type="text" size=15 maxlength=47 id=eusr name="poe_user"></td>
  <td><input type="text" size=15 maxlength=35 id=epwd name="poe_pswd"></td>
  <td><input type="text" size=15 maxlength=35 id=ehnm name="poe_host"></td></tr>
 <tr class=r1>
  <script language="JavaScript">hr(3)</script></tr>
 <tr class=r0>
  <td colspan=3><script language="JavaScript">doc(DNS_Optional_for_dynamic_IP)</script></td></tr>
 <tr class=r1>
  <td><script language="JavaScript">doc(Server_)</script> 1</td>
  <td><script language="JavaScript">doc(Server_)</script> 2</td>
  <td><script language="JavaScript">doc(Server_)</script> 3</td></tr>
 <tr class=r2>
  <td><input type="text" size=15 maxlength=15 id=dns1 name="dnsip1"></td>
  <td><input type="text" size=15 maxlength=15 id=dns2 name="dnsip2"></td>
  <td><input type="text" size=15 maxlength=15 id=dns3 name="dnsip3"></td></tr>
 <tr class=r1>
  <script language="JavaScript">hr(3)</script></tr>
<!-- <tr class=r0>
  <td colspan=3><script language="JavaScript">doc(Optional_)</script></td></tr>
 <tr class=r1>
  <td><script language="JavaScript">doc(Host_Name)</script></td>
  <td><script language="JavaScript">doc(Domain_Name)</script></td>
  <td><script language="JavaScript">doc(MAC_Address)</script></td></tr>
 <tr class=r2>
  <td><input type="text" size=15 maxlength=31 id=htnm name="hostname"></td>
  <td><input type="text" size=15 maxlength=31 id=domn name="domain"></td>
  <td><input type="text" size=17 maxlength=17 id=wmac name="macaddr"></td></tr>-->
</table>
<p><table class=tf align=center>
 <tr><td style='color:red'><b>{% include "htmldemo/primary_reboot_data" ignore missing %}</b></td></tr>
</table></p>
<p><table class=tf align=center>
<tr>
  <td><script language="JavaScript">fnbnS(updb, 'onClick=Send()')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnS(Submit, 'onClick=Send()')</script></td>
  <td width=15></td>
  <td><script language="JavaScript">fnbnB(Cancel_, 'onClick=location.reload()')</script></td>
<!--  <td width=80></td>
  <td><script language="JavaScript">fnbnB(Multi_IP_Set, 'onClick=location.href=linkmip')</script></td></tr>
 <tr>
  <td width=150></td>
  <td><input class=button type="submit" value="Submit" name="submit" onClick="Send()"></td>
  <td width=30></td>
  <td><input class=button type="button" value="Cancel" onClick="location.reload()"></td>
  <td width=150></td></tr-->
</table></p>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
