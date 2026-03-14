<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(Email_);doc(" ");doc(Warning_ );doc(" ");doc(Event_ );doc(" ");doc(Settings_);</script></title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var wdata = {
		rcs:'1', rws:'0', ptnf:'0', ptfn:'1', 
		DI1on:'1', DI1off:'1', authfail:'1'
	};
	var wdata1 = [
		{port:'1', lon:1, loff:0, tover:0, tthre:'68', tdur:'92'},
		{port:'2', lon:0, loff:1, tover:1, tthre:'95', tdur:'81'},
		{port:'3', lon:1, loff:0, tover:1, tthre:'89', tdur:'21'}
	];
}else{
	var wdata = {
		<%net_websSysEvent();%>	
	};
	var wdata1 = [
		<%net_websPortEvent();%>	
	];
	<%net_Web_show_value('SRV_EEVENT');%>
		
}


	
<!--#include file="lan_data"-->



var wtype = {
	rcs:3, rws:3, ptnf:3, ptfn:3, DI1off:3, DI1on:3, conchg:3, authfail:3
};

var wtype2 = {port:4, lon:3, loff:3/*, tover:3, tthre:4, tdur:4*/};



function Addformat(name, idx, newdata, index)
{	
	var j;	
	var k;
	name=name.slice(0,idx);		
	newdata[0] = wdata1[index]['port'];	
	newdata[1] = "<input type=checkbox name="+name+'_lon'+ " " + ((parseInt(SRV_EEVENT[name+'_lon'])) ? 'checked':'') +">";
	newdata[2] = "<input type=checkbox name="+name+'_loff'+ " " + ((parseInt(SRV_EEVENT[name+'_loff'])) ? 'checked':'') +">";	
}	


function tableinit(){
	var newdata=new Array;
	var i, j, idx, name;
	j=0;
	for(i in SRV_EEVENT){
		if((idx = i.indexOf("_lon",0))!=-1){			
			Addformat(i,idx,newdata, j);
			tableaddRow("show_available_table", i, newdata, "center");
			j++;
		}
	}
	
	/*for(i=wdata1.length-1; i >= 0; i--){
		Addformat(wdata1[i],i,newdata);
		tableaddRow("show_available_table", i, newdata, "center");
	}*/
}



var myForm;
function fnInit() {	
	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_EEVENT, SRV_EEVENT_type);	
	tableinit();
}
</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[7].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[7])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_EEVENT">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="em_hidden" id="em_hidden" value="" >
<table cellpadding=1 cellspacing=2>

 <tr class=r0>
  <td colspan=4><script language="JavaScript">doc(Sys_event)</script></td></tr>  
 <tr class=r1>
  <td><input type="checkbox" id=rcs name="rcs" ></td>
  <td><script language="JavaScript">doc(CS_)</script></td>
  <td><input type="checkbox" id=rws name="rws" ></td>
  <td><script language="JavaScript">doc(WS_)</script></td>
  <td><input type="checkbox" id=ptnf name="ptnf" ></td>
  <td><script language="JavaScript">doc(Pow_tran);document.write("(");doc(ON_);document.write("~");doc(OFF_);document.write(")")</script></td>
  <td><input type="checkbox" id=ptfn name="ptfn" ></td>
  <td><script language="JavaScript">doc(Pow_tran);document.write("(");doc(OFF_);document.write("~");doc(ON_);document.write(")")</script></td>
  </tr>
  <tr class=r2>
  <td><input type="checkbox" id=DI1off name="DI1off" ></td>
  <td><script language="JavaScript">doc(DI_);document.write(" (");doc(OFF_)</script>)</td>
  <td><input type="checkbox" id=DI1on name="DI1on" ></td>
  <td><script language="JavaScript">doc(DI_);document.write(" (");doc(ON_)</script>)</td> 
  <td><input type="checkbox" id=conchg name="conchg" ></td>
  <td><script language="JavaScript">doc(Conf_Chg)</script></td>
  <td><input type="checkbox" id=authfail name="authfail" ></td>
  <td><script language="JavaScript">doc(Auth_Fail)</script></td>
  </tr>
 
  <script language="JavaScript">hr(4)</script></tr>
</table>

<table cellpadding=1 cellspacing=2 id="show_available_table" style="width:600px">
<tr class=r0 >
 <td colspan=3 ><script language="JavaScript">doc(Port_event)</script></td></tr>
 <tr class=r5 align="center" >
  <td width=200px><script language="JavaScript">doc(Port_)</script></td>
  <td width=200px><script language="JavaScript">doc(Link_);document.write("-");doc(ON_)</script></td>
  <td width=200px><script language="JavaScript">doc(Link_);document.write("-");doc(OFF_)</script></td></tr>
<!--  <td width=120px><script language="JavaScript">doc(Traffic_);document.write("-");doc(Overload_)</script></td>
  <td width=120px><script language="JavaScript">doc(Traffic_);document.write("-");doc(Threshold_)</script>(%)</td>
  <td width=120px><script language="JavaScript">doc(Traffic_);document.write("-");doc(Duration_)</script>(s)</td>-->
 
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
