<html>
<head>
<% net_Web_file_include(); %>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var SRV_LLDP = {
		lldpen:'1', interval:'0'
	};
	var SRV_LLDP1 = [
		{port:'WAN1', nid:'00:90:e8:16:a7:96', nport:'2', ndesc:'100TX,RJ45.', nsystem:'Not received'},
		{port:'WAN2', nid:'00:90:e8:00:05:15', nport:'6', ndesc:'100TX,RJ45.', nsystem:'MOXA'}
	];
}else{
	<%net_Web_show_value('SRV_LLDP');%>
	var SRV_LLDP1 = [<%net_webLldpinfo();%>];
}

var lldpsel = [
	{ value:0, text:Disable_ },	{ value:1, text:Enable_}
];

function tableinit(){
	var i, j, portidn, idx;
	table = document.getElementById("show_table");	
	for(i = 0; i < SRV_LLDP1.length; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		for(idx in SRV_LLDP1[0]){	
			cell = document.createElement("td");
			cell.innerHTML = SRV_LLDP1[i][idx];		
			row.appendChild(cell);
			row.style.Color = "black";
			row.align="center";
		}		
		row.className=((i%2)-1)?"r1":"r2";
	}	
}

function ChgInterval(value) {
	var myForm = document.getElementById('myForm');	
	var netwk;
	if(myForm.interval.value < 5 || myForm.interval.value > 32768){
		myForm.btnS.disabled = true;
		alert("LLDP Interval Must between 5~32768");				
	}else{
		myForm.btnS.disabled = false;
	}		
}

var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_LLDP, SRV_LLDP_type);	
	tableinit();
	
	//var LLDP_MAX = 64;
	//document.getElementById("totallldpcnt").innerHTML +='('+SRV_LLDP1.length +'/' +LLDP_MAX+')';
}

function Activate(form)
{	
	var myForm = document.getElementById('myForm');	
	if(!isNumber(myForm.interval.value)){
		alert("LLDP Interval must be Number and not NULL");
		return;
	}
	
	if(myForm.interval.value > 32768 || myForm.interval.value < 5){
		alert(" LLDP Interval must be between 5~32768");
		return;
	}	

	form.action="/goform/net_Web_get_value?SRV=SRV_LLDP";	
	form.submit();	
}

</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(Lldp_);doc(" ");doc(Settings_);</script></h1>
<form id=myForm name=form1 method="POST">
<% net_Web_csrf_Token(); %>
<fieldset>
<table cellpadding=1 cellspacing=2 style="width:700px">
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(General_);doc(" ");doc(Settings_);</script></td>
  </tr>  
 <tr>
  <td width="150px"><script language="JavaScript">doc(Lldp_);</script></td>  
  <td> <script language="JavaScript">iGenSel2('lldpen', 'lldpen', lldpsel)</script></td> 
  </tr>
 <tr>  
  <td width="150px"><script language="JavaScript">doc(Message_);doc(" ");doc(Transmit_);doc(" ");doc(Interval_);</script></td>
  <td> <input type="text" size=5 maxlength=5 id=interval name="interval" onClick=ChgInterval()></td>
  </tr> 
  
</tr>
</table>

<table align="left" style="width:700px">
<tr>
<td><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
</tr>
</table>

<p><br/>

<table cellpadding=1 cellspacing=2 id="show_table" style="width:700px" align="left">
<tr class=r0>
 <td id=totallldpcnt colspan=6><script language="JavaScript">doc(LLDP_Table_)</script>&nbsp;&nbsp;&nbsp;&nbsp;</td>
 </tr>
 <tr align="center">
  <th width=50px><script language="JavaScript">doc(Port_)</script></th>
  <th width=150px><script language="JavaScript">doc(Neighbor_);doc(" ");doc(ID_);</script></th>
  <th width=100px><script language="JavaScript">doc(Neighbor_);doc(" ");doc(Port_);</script></th>
  <th width=200px><script language="JavaScript">doc(Neighbor_);doc(" ");doc(Port_);doc(" ");doc(Description_);</script></th>
  <th width=200px><script language="JavaScript">doc(Neighbor_);doc(" ");doc(system_);</script></th>
 </tr>
 </table>

</fieldset>
</form>

</body></html>
