<html>
<head>
<% net_Web_file_include(); %>
<title><script language="JavaScript">doc(SNMP_);doc(" ");doc(Trap_ );doc(" ");doc(Settings_);</script></title>

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
	<%net_Web_show_value('SRV_SNMPTRAP');%>
}	
<!--#include file="lan_data"-->



/*function Addformat(data, idx, newdata)
{	
	var j;	
	var k;	
	//alert(data +"idx = "+ idx);
	newdata[0] = data['port'];
	newdata[1] = "<input type=checkbox name="+lon + idx + " " + ((data['lon']) ? 'checked':'') +">";
	newdata[2] = "<input type=checkbox name="+loff + idx + " " + ((data['loff']) ? 'checked':'') +">";
	/*newdata[3] = "<input type=checkbox name=tover" + idx + " " + ((data['tover']) ? 'checked':'') +">";
	newdata[4] = "<input type=text name=tthre" + idx + " value ="+ data['tthre']+">"
	newdata[5] = "<input type=text name=tdur" + idx + " value ="+ data['tdur']+">"*/
	//alert(newdata[0]);
//}*/

function Addformat(name, idx, newdata)
{	
	var j;	
	var k,port_name;
	if(name.slice(0,4) == "port"){
		port_name = "port"+(parseInt(name.slice(4,idx))+1);
	}

	name=name.slice(0,idx);		
	newdata[0] = port_name.toUpperCase();	
	newdata[1] = "<input type=checkbox name="+name+'_lon'+ " " + ((parseInt(SRV_SNMPTRAP[name+'_lon'])) ? 'checked':'') +">";
	newdata[2] = "<input type=checkbox name="+name+'_loff'+ " " + ((parseInt(SRV_SNMPTRAP[name+'_loff'])) ? 'checked':'') +">";		
}	


function tableinit(){
	var newdata=new Array;
	var i, j, idx, name;
	
	for(i in SRV_SNMPTRAP){
		if((idx = i.indexOf("_lon",0))!=-1){						
			Addformat(i,idx,newdata);
			tableaddRow("show_available_table", i, newdata, "center");
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
	fnLoadForm(myForm, SRV_SNMPTRAP, SRV_SNMPTRAP_type);	
	tableinit();
}
</script>
</head>
<body class=main onLoad=fnInit()>
<script language="JavaScript">bodyh()</script>
<script language="JavaScript">help(TREE_NODES[7].text, "")</script>
<script language="JavaScript">menu(TREE_NODES[7])</script>
<script language="JavaScript">mainh()</script>

<form id=myForm name=form1 method="POST" action="/goform/net_Web_get_value?SRV=SRV_SNMPTRAP">
<% net_Web_csrf_Token(); %>
<input type="hidden" name="trap_hidden" id="trap_hidden" value="" >
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
  <td><script language="JavaScript">fnbnS(Submit_, '')</script></td></tr>
</table></p>
</form>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>
