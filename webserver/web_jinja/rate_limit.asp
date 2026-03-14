<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var SYSPORTS = 10;
	var port_desc=[{desc:"100TX,RJ45.", type:"0x10", index:"1"},
	{desc:"100TX,RJ45.", type:"0x10", index:"2"},
	{desc:"100TX,RJ45.", type:"0x10", index:"3"},
	{desc:"100TX,RJ45.", type:"0x10", index:"4"},
	{desc:"100TX,RJ45.", type:"0x10", index:"5"},
	{desc:"100TX,RJ45.", type:"0x10", index:"6"},
	{desc:"100TX,RJ45.", type:"0x10", index:"7"},
	{desc:"100TX,RJ45.", type:"0x10", index:"8"},
	{desc:"1000FX, miniGBIC", type:"0xb5", index:"G1"},
	{desc:"1000FX, miniGBIC", type:"0xb5", index:"G2"}];
	var port_bandwidth=[{bandwidth: "100"},
	{bandwidth: "100"},
	{bandwidth: "100"},
	{bandwidth: "100"},
	{bandwidth: "100"},
	{bandwidth: "100"},
	{bandwidth: "100"},
	{bandwidth: "100"},
	{bandwidth: "1000"},
	{bandwidth: "1000"}];

	var SRV_RATE_LIMIT={ingress_limit_mode:'3',ingress_rate0:'0',ingress_rate1:'0',ingress_rate2:'0',ingress_rate3:'0',ingress_rate4:'0',
		ingress_rate5:'0',ingress_rate6:'0',ingress_rate7:'0',ingress_rate8:'0',ingress_rate9:'0',ingress_rate10:'0',
		ingress_rate11:'0',ingress_rate12:'0',ingress_rate13:'0',ingress_rate14:'0',ingress_rate15:'0',
		egress_rate0:'0',egress_rate1:'0',egress_rate2:'0',egress_rate3:'0',egress_rate4:'0',egress_rate5:'0',egress_rate6:'0',
		egress_rate7:'0',egress_rate8:'0',egress_rate9:'0'}
}else{
	var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}
	var port_desc=[{{ net_webPortDesc() | safe }}];
	var port_bandwidth=[{{ net_Web_Get_Port_Bandwidth() | safe }}];
	{{ net_Web_show_value('SRV_RATE_LIMIT') | safe }}
}

var rate_sel = [
	{ value:0, text:No_Limit_},	{ value:1, text:"3%"}, { value:2, text:"5%"}, { value:3, text:"10%"},
	{ value:4, text:"15%"},	{ value:5, text:"25%"}, { value:6, text:"35%"}, { value:7, text:"50%"},
	{ value:8, text:"65%"}, { value:9, text:"85%"},
];

//88E6095 giga ports rate limit only support to 256 Mbit/sec
var giga_rate_sel = [
	{ value:0, text:No_Limit_},	{ value:1, text:"3%"}, { value:2, text:"5%"}, { value:3, text:"10%"},
	{ value:4, text:"15%"},	{ value:5, text:"25%"},
];

var limite_mode_sel = [
	{ value:0, text:limit_all },
	{ value:1, text:limit_BMUcast },
	{ value:2, text:limit_BMcast },
	{ value:3, text:limit_Bcast }
];	
function rateChange(item)
{
	var  name,idx;
	var  mbits_sec,rate=100;
	var text;
	//rate
	if(item.value==0)rate=100;
	else rate=parseInt(rate_sel[parseInt(item.value)].text);

	//name
	name=item.name.substring(0, 7);
	if(name=="ingress")
	{
		idx=parseInt(item.name.substring(12, item.name.len),10);
		name="ingress_bandwidth"+idx;		
	}
	else
	{
		idx=parseInt(item.name.substring(11, item.name.len),10);
		name="egress_bandwidth"+idx;
	}

	mbits_sec=parseInt(port_bandwidth[idx].bandwidth)*rate/100;
	document.getElementById(name).innerHTML=mbits_sec;
}

function Addformat(idx, name, newdata)
{	
    if(idx<SYSPORTS)
    {	
		newdata[0] = port_desc[idx].index;;	
		if(EDS_IF_IS_GIGA(port_desc, idx)){
			newdata[1] = iGenSel4Str('ingress_rate'+idx,'ingress_rate'+idx,giga_rate_sel,"rateChange");
			newdata[2] = iGenSel4Str('egress_rate'+idx,'egress_rate'+idx,giga_rate_sel,"rateChange");
		}
		else{
			newdata[1] = iGenSel4Str('ingress_rate'+idx,'ingress_rate'+idx,rate_sel,"rateChange");
			newdata[2] = iGenSel4Str('egress_rate'+idx,'egress_rate'+idx,rate_sel,"rateChange");
		}
		//newdata[1] += "<label id=ingress_bandwidth"+idx+">" + port_bandwidth[idx].bandwidth + "</label> Mbits/sec";
		//newdata[2] += "<label id=egress_bandwidth"+idx+">" + port_bandwidth[idx].bandwidth + "</label> Mbits/sec";
		newdata[1] += "<SPAN style='display:inline-block; width:28px;' id=ingress_bandwidth"+idx+">" + port_bandwidth[idx].bandwidth + "</SPAN> Mbits/sec";
		newdata[2] += "<SPAN style='display:inline-block; width:28px;' id=egress_bandwidth"+idx+">" + port_bandwidth[idx].bandwidth + "</SPAN> Mbits/sec";
    }
}
function RateCheck_Send(form){
	var error_return_t = 0;
	var i;
	for(i=0;i<SYSPORTS;i++){
	if (!IsInRange(form['ingress_rate'+i], 'Limit Ingress', 0, 100))
		error_return_t = 1;
	if (!IsInRange(form['egress_rate'+i], 'Limit Egress', 0, 100))
		error_return_t = 1;
	}
	if (error_return_t)
		return;

	form.action="/goform/net_Web_get_value?SRV=SRV_RATE_LIMIT";
		form.submit();	
}
function tableinit(){
	var newdata=new Array;
	var i;
	
	for(i=0; i<SYSPORTS; i++){
		    Addformat(i, SRV_RATE_LIMIT, newdata);
		    tableaddRow("show_available_table", i, newdata, "center");
	}
}


var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	tableinit();
	fnLoadForm(myForm, SRV_RATE_LIMIT, SRV_RATE_LIMIT_type);
}
</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(RateLimit)</script></h1>
<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_RATE_LIMIT">
<fieldset>
<input type="hidden" name="em_hidden" id="em_hidden" value="" >
{{ net_Web_csrf_Token() | safe }}
<table width="100%" border="0" align="left">
<tr>
		<td width="7%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
			</font></div></td>
<td>
		<table cellpadding=1 cellspacing=2 style="width:700px">
		 <tr>
		  <td width="150" align="left"><script language="JavaScript">doc(Policy)</script></td>
		  <td width="550"><script language="JavaScript">iGenSel2('ingress_limit_mode', 'ingress_limit_mode', limite_mode_sel)</script></td>
		  </tr>
		</table>
		<table cellpadding=1 cellspacing=2 id="show_available_table" style="width:600px">
		 <tr align="center" >
		  <th width="6%"><script language="JavaScript">doc(WAN_Port_)</script></th>
		  <th width="25%"><script language="JavaScript">doc(Ingress)</script></th>
		  <th width="25%"><script language="JavaScript">doc(Egress)</script></th>
		  </tr>
		</table>
		<p><table class=tf align=left>
		 <tr>
		  <td><script language="JavaScript">fnbnS(Submit_, '')</script></td>
		  <td width=15></td></tr>
		</table></p>
</td>
<tr>
</table>
</fieldset>
</form>

</body>
</html>

