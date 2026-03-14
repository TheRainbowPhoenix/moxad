<html>
<head>
{{ net_Web_file_include() | safe }}
<title><script language="JavaScript">doc(Relay_ );doc(" ");doc(Warning_ );doc(" ");doc(Event_ );doc(" ");doc(Settings_);</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
var NoIFS = {{ net_Web_GetNO_IFS_WriteValue() | safe }};
if (!debug) {
	var wdata = {
		override1:'1', pwfail1:'0', pwfail2:'1', dioff1:'0', dion1:'1'
	};
	var wdata1 = [
		{port:'1', link:1},
		{port:'2', link:0},
		{port:'3', link:1}
	];
}else{
	var wdata = {{ net_websSysRelay() | safe }};	
	var wdata1 = [
		{{ net_webPortRelay() | safe }}	
	];
		
}

var wtype = {
	override1:3, pwfail1:2,pwfail2:2,dioff1:2, dion1:2
};

var wtype2 = {port:4, link:3};

var ensel = [
	{ value:0, text:Disable_ },	{ value:1, text:Enable_}
];

var portsel = [
	{ value:0, text:Ignore_},	{ value:1, text:ON_}, { value:2, text:OFF_}
];

function Addformat(data, idx, newdata)
{	
	var j;	
	var k;	
	//alert(data +"idx = "+ idx);
	newdata[0] = data['port'];
	newdata[1] = iGenSel2Str('port_' + idx,'port' + idx,portsel);	
	/*newdata[3] = "<input type=checkbox name=tover" + idx + " " + ((data['tover']) ? 'checked':'') +">";
	newdata[4] = "<input type=text name=tthre" + idx + " value ="+ data['tthre']+">"
	newdata[5] = "<input type=text name=tdur" + idx + " value ="+ data['tdur']+">"*/
	//alert(newdata[0]);
}


function tableinit(){
	var newdata=new Array;
	var i, j, portid;
	if(NoIFS == wdata1.length){
		for(i=wdata1.length-1; i>=0; i--){
			Addformat(wdata1[i],i,newdata);
			tableaddRow("show_available_table", portid, newdata, "center");		
			portid = 'port'+i;
			document.getElementById(portid).selectedIndex = wdata1[i].link;
		}
	}else{
		for(i=0; i<wdata1.length; i++){
			Addformat(wdata1[i],i,newdata);
			tableaddRow("show_available_table", portid, newdata, "center");		
			portid = 'port'+i;
			document.getElementById(portid).selectedIndex = wdata1[i].link;
		}
	}
}

function dioffchange(idx){
	if(idx == 1){
		if(document.getElementById('dion1').selectedIndex == 1){
			alert("DI on/off relay can not enable at the same time");
			document.getElementById('dioff1').selectedIndex =0 ;
		} 
	}
}

function dionchange(idx){
	if(idx == 1){
		if(document.getElementById('dioff1').selectedIndex == 1){
			alert("DI on/off relay can not enable at the same time");
			document.getElementById('dion1').selectedIndex =0 ;
		} 
	}
}



var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, wdata, wtype);	
	tableinit();
}
</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[7].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[7])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" action="/goform/net_WebRelayEvent">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="ralarm_hidden" id="ralarm_hidden" value="" >
<table cellpadding=1 cellspacing=2 style="width=700px">
 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(Sys_event)</script></td></tr>  
 <tr class=r1>
  <td><input type="checkbox" id=override1 name="override_1" >
  <b><script language="JavaScript">doc(Override_);doc(" ");doc(Relay_);doc(" ");doc(Warning_);doc(" ");doc(Settings_);</script></b></td>  
  </tr>
 <tr class=r2>  
  <td><script language="JavaScript">doc(Power_);doc(" ");doc(Input_);doc(" ");document.write(1);doc(" ");doc(Failure_);document.write("(");doc(ON_);document.write("->");doc(OFF_);document.write(")");</script>
  <script language="JavaScript">iGenSel2('pw_1', 'pwfail1', ensel)</script></td>
  <td><script language="JavaScript">doc(Power_);doc(" ");doc(Input_);doc(" ");document.write(2);doc(" ");doc(Failure_);document.write("(");doc(ON_);document.write("->");doc(OFF_);document.write(")");</script>
  <script language="JavaScript">iGenSel2('pw_2', 'pwfail2', ensel)</script></td>   
  </tr> 
  <tr class=r1>  
  <td>
  <script language="JavaScript">doc(DI_);doc(" ");doc("(");doc(OFF_);doc(")");</script>
  <script language="JavaScript">iGenSel3('di_off_1', 'dioff1', ensel, 'dioffchange')</script>&nbsp;&nbsp;  
  <script language="JavaScript">doc(DI_);doc(" ");doc("(");doc(ON_);doc(")");</script>
  <script language="JavaScript">iGenSel3('di_on_1', 'dion1', ensel, 'dionchange');</script>
  </td>
  </tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" style="width:500px">
<tr class=r0>
 <td colspan=6><script language="JavaScript">doc(Port_event)</script></td></tr>
 <tr class=r5 align="center">
  <td width=250px><script language="JavaScript">doc(Port_)</script></td>
  <td width=250px><script language="JavaScript">doc(Link_)</script></td></tr> 
</table>
<p><table class=tf align=left>
 <tr>
  <td><script language="JavaScript">fnbnS(Submit_, '')</script></td>
  <td width=15></td></tr>
</table></p>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
