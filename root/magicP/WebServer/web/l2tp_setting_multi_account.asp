<html>
<head>
<% net_Web_file_include(); %>
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">

var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
checkMode(<% net_Web_GetMode_WriteValue(); %>);
checkCookie();
if (!debug) {
	var SRV_L2TPD = [
		{enable:'0', lip:'10.10.10.1', oiplo:'10.10.10.2', oiphi:'10.10.10.254',username:'aries', userpw:'123456'},
		{enable:'0', lip:'10.10.10.1', oiplo:'10.10.10.2', oiphi:'10.10.10.254',username:'aries', userpw:'123456'}
	];
}else{
	
	<%net_Web_show_value('SRV_L2TPD');%>
	
}


/*var SRV_L2TPD_type = {
	enable:2, lip:5, oiplo:5, oiphi:5, username:4, userpw:4
};*/

var wtyp0 = [
	{ value:0, text:Disable_ }, { value:1, text:Enable_ }
];
var table_idx = 0;
var newdata=new Array;
var tablefun = new table_show(document.getElementsByName('form1'),"UserTable" ,account_type, account, table_idx, newdata, Addformat, 0);

var myForm;	


var set_flag=0;	// 4 for l2tp server setting

function delete_account(form,index){
	set_flag=0;

	form.username.value=account[index].username;
	form.action="/goform/net_l2tp_account_set?mode="+set_flag;
	form.submit();
}


function Addformat(mod,idx)
{
	newdata[0] = account[idx].username;
	newdata[1] = '<input class=b0 type=button value="'+ Delete_+ '" onClick=delete_account(this.form,'+idx+')>';	
}


function Total_Policy()
{
	if(account.length > account_MAX){
		alert('Number of policy is Over');		
		with(document.myForm){
			btnA.disabled = true;			
			btnM.disabled = true;			
			btnU.disabled = true;
		}		
		
	}else if(account.length == account_MAX){
		with (document.myForm) {
			btnA.disabled = true;
			btnM.disabled = false;
			btnU.disabled = false;
		}
	}else{
		with (document.myForm) {
			btnA.disabled = false;
			btnM.disabled = false;
			btnU.disabled = false;
		}
	}
	document.getElementById("totalpolicy").innerHTML = '('+account.length +'/' +account_MAX+')';
}

function Activate(form)
{	
	var i;
	var j;
	
	form.l2tpSvrtmp.value="";

	for(i = 0 ; i < l2tpSvr.length ; i++)
	{	
		if(!(SerIpRangeCheck(document.getElementsByName('oiplo')[i].value,document.getElementsByName('oiphi')[i].value, 256)))
		{
			document.getElementById("btnU").disabled="";
			return;
		}
		for (var j in l2tpSvr_type){
			form.l2tpSvrtmp.value = form.l2tpSvrtmp.value + document.getElementsByName(j)[i].value  + "+";	
		}		
	}
	

	set_flag = 4;
	form.action="/goform/net_l2tp_account_set?mode="+set_flag;
	form.submit();	
}

var actb = 'Active';
var myForm;
var selstate = { type:'select', id:'enable', name:'enable', size:1, option:wtyp0 };
	
<!--#include file="lan_data"-->
//var link0 = (debug) ? 'dhcplist.htm': 'dhcplist.cgi?action=&page=0&back=0&';


function showServer(){
	var table=document.getElementById("ServerTable"); 
	var i, row, cell;
	for(i=0;i<l2tpSvr.length;i++){
		row = table.insertRow(table.getElementsByTagName("tr").length);
		row.align="center";
		row.className = "r0";
		cell = document.createElement("td");		
		cell.innerHTML = L2TP_SERVER_SETTING_+' ('+WAN_+ (l2tpSvr.length>1?(i+1):"") + ')';
		row.appendChild(cell);
		row = table.insertRow(table.getElementsByTagName("tr").length);
		row.align="center";
		cell = document.createElement("td");
		cell.innerHTML = L2tp_STATE_;
		row.appendChild(cell);		
		cell = document.createElement("td");
		cell.innerHTML = iGenSel2Str('enable', 'enable', wtyp0);
		row.appendChild(cell);
		row = table.insertRow(table.getElementsByTagName("tr").length);
		row.align="center";
		cell = document.createElement("td");
		cell.innerHTML = L2tp_L_IP_;
		row.appendChild(cell);
		cell = document.createElement("td");
		cell.innerHTML = '<input type="text" id=lip name="lip" size=15 maxlength=15>';
		row.appendChild(cell);
		row = table.insertRow(table.getElementsByTagName("tr").length);
		row.align="center";
		cell = document.createElement("td");
		cell.innerHTML = Offered_IP_Range;
		row.appendChild(cell);
		cell = document.createElement("td");
		cell.innerHTML = '<input type="text" id=oiplo name="oiplo" size=15 maxlength=15 >~<input type="text" id=oiphi name="oiphi" size=15 maxlength=15 >';
		row.appendChild(cell);
	}
	

}

function tabbtn_sel(form, sel)// 1 for add,2 for modify
{	
	if(document.getElementById('username').value==""||document.getElementById('userpw').value==""){
		alert("Error: "+User_Name+" or "+Password_+" is NULL");
		return;
	}
	set_flag = sel;

	form.action="/goform/net_l2tp_account_set?mode="+set_flag;
	form.submit();	
	
}

function fnInit() {	
	myForm = document.getElementsByName('form1');
	for(var i = 0 ; i < account.length ; i++)
	{
		account[i]["userpw"]="";
	}
	
	showServer();
	tablefun.show();
	
	for(var i = 0 ; i < l2tpSvr.length ; i++)
	{			
		fnLoadForm(myForm[i], l2tpSvr[i], l2tpSvr_type);	
	}

	
	Total_Policy();
}


function stopSubmit()
{
	return false;
}
</script>
</head>

<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(L2tp_Settings_)</script></h1>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
<% net_Web_csrf_Token(); %>
<input style="display:none" name="l2tpSvr_tmp" id="l2tpSvrtmp" value="">
<fieldset>
<table cellpadding=1 cellspacing=2 border=0>
 <tr><td>
	<table id=ServerTable border=0></table>
 </td></tr>	
 	<tr><td>
	<table border=0>
	<tr>
	<td><script language="JavaScript">fnbnBID(Submit_, 'onClick=Activate(this.form)', 'btnU')</script></td>
	</tr>
	</table>
 </td></tr>
 <tr><td>
  <table>
  <tr class=r0>
 	<td colspan=4><script language="JavaScript">doc(User_Name);doc(" ");doc(Settings_)</script></td>
  </tr>
  <tr>
   <td width=80px><script language="JavaScript">doc(User_Name)</script></td>
   <td width=120px><input type="text" id=username name="username" size=15 maxlength=32></td>
   <td width=80px><script language="JavaScript">doc(Password_)</script></td>
   <td><input type="text" id=userpw name="userpw" size=15 maxlength=32></td></tr>
  </table>
 </td></tr>
 <p><tr><td><table align=left>
 <tr>
  <td width=400>
   <script language="JavaScript">fnbnBID(addb, 'onClick=tabbtn_sel(this.form,1)', 'btnA')</script>
   <script language="JavaScript">fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=15></td>
  </tr>
</td></tr>
</table></p>

 <tr><td>
 	<table>
 		<tr class=r0>
 		 <td  width = 120px><script language="JavaScript">doc(L2tp_Account_)</script></td>
  		 <td id = "totalpolicy"></td>
  		</tr> 
 	</table>
 	<table id=UserTable> 		
		<tr width=450px></tr>
		 <tr align="left">
		  <th width=300px><script language="JavaScript">doc(User_Name)</script></th>
		  <th width=50px></th>
		 </tr> 
	</table>
 </td></tr>
</table>
</fieldset>
</form>
</body></html>
