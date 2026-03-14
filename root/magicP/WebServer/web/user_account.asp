<html>
<head>
<script language="JavaScript" src=doc.js></script>

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=common.js></script>
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
var ProjectModel = <% net_Web_GetModel_WriteValue(); %>;
var ModelVLAN = <% net_Web_GetModel_VLAN_WriteValue(); %>;
var No_WAN = <% net_Web_GetNO_WAN_WriteValue(); %>;
var MAC_PORTS = <% net_Web_GetNO_MAC_PORTS_WriteValue(); %>;
var PROTO_MASK_RIP=(1 << 0);
checkCookie();
if (!debug) {
	SRV_USER_ACCOUNT=[
		{userName:'moxa1',userEnable:'0', authority:'0'},
		{userName:'moxa2',userEnable:'1', authority:'0x10'}];

}else{
	<%net_Web_show_value('SRV_USER_ACCOUNT');%>
		
}

var Username = [
	{ value:0x00, text:'System Admin' },
    { value:0x11, text:'Configuration Admin'},
	{ value:0x10, text:'User' }
];
	
var myForm;
var selstate = { type:'select', id:'authority', name:'authority', size:1, option:Username };

var set_flag=0;	

function delete_account(index){
    set_flag = 0;
	var ret = confirm("Delete user account "+SRV_USER_ACCOUNT[index].userName+"?");	
	if(!ret){
		return;
	}else{
		var i, admin_count=0;
		if(SRV_USER_ACCOUNT[index].authority==0x00){
			for(i=0; i<SRV_USER_ACCOUNT.length;i++){
				if(i!=index&&SRV_USER_ACCOUNT[i].authority==0x00){
					break;
				}
			}
		}
		document.getElementById("userName").value=SRV_USER_ACCOUNT[index].userName;
		document.getElementById("userName").disabled=false;		
		myForm.action="/goform/net_account_set?mode="+set_flag;
		myForm.submit();	
	}
}

var newdata=new Array;
function Addformat(mod,idx)
{
	if(SRV_USER_ACCOUNT[idx].userEnable==1){
		newdata[0]="<IMG src=" + 'images/enable_3.gif'+ ">";
	}else{
		newdata[0]= "<IMG src=" + 'images/disable_3.gif'+ ">";
	}
	newdata[1] = SRV_USER_ACCOUNT[idx].userName;
	for(i=0; i < Username.length;i++){
		if(Username[i].value == SRV_USER_ACCOUNT[idx].authority){
			newdata[2] = Username[i].text;
		}
	}
	if(AuthUser=='admin'){
		newdata[3] = '<input class=b0 type=button value="'+ Delete_+ '" onClick=delete_account('+idx+')>';	
	}else{
		newdata[3] = '';	
	}
}



var table_idx=0;
var tablefun = new table_show(document.getElementsByName('form1'),"show_setting_table" ,SRV_USER_ACCOUNT_type, SRV_USER_ACCOUNT, table_idx, newdata, Addformat, chg_fun);

function chg_fun(){
	document.getElementById("modify_hidden0").style.display="";	
	document.getElementById("modify_hidden1").style.display="";	
	document.getElementById("modify_show0").style.display="none";	
	set_flag=0;
	document.getElementById("userName").disabled=true;		
}


function creativeAccount()
{
		document.getElementById("modify_hidden0").style.display="none";	
		document.getElementById("modify_hidden1").style.display="none";	
		document.getElementById("modify_show0").style.display="";	
		set_flag=1;
		document.getElementById("userName").disabled=false;		
		document.getElementById("userName").value="";	
		document.getElementById("authority").value=0;	
}

function Activate(form_info)
{
	if(form_info.id==CREATE_){
		creativeAccount();
	}else{
		if(set_flag==0 || set_flag==2){//modify
			set_flag=2;

			if(document.getElementById("new_pw").value != document.getElementById("confirm_pw").value){			
				alert(CONFIRM_PWD_+" is not equal to "+Password_);
				return;
			}
		}else{//add
			var i;
			for(i=0; i<SRV_USER_ACCOUNT.length;i++){
				if(SRV_USER_ACCOUNT[i].userName==document.getElementById("userName").value){
					alert(User_Name+" must be unique");
					return;
				}
			}

			if(document.getElementById("set_pw").value != document.getElementById("confirm_pw").value){	
				alert(CONFIRM_PWD_+" is not equal to "+Password_);
				return;
			}
		}

		/*if(!isNull(document.getElementById("confirm_pw").value)){	
			if(isSymbol(document.getElementById("confirm_pw"), Password_)){
				return;
			}	
		}*/
		
		document.getElementById("userName").disabled=false;	
		form_info.form.action="/goform/net_account_set?mode="+set_flag;
		form_info.form.submit();	
	}
	
}

function fnInit() {	
	var i;
	
	myForm = document.getElementById('myForm');	
	tablefun.show();
	creativeAccount();
	//fnLoadForm(myForm, SRV_USER_ACCOUNT[0], SRV_USER_ACCOUNT_type);	
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body onLoad=fnInit()>
<h1><script language="JavaScript">doc(USER_ACCOUNT_)</script></h1>

<form id=myForm name=form1 method="POST"  onSubmit="return stopSubmit()" >
<fieldset>
<% net_Web_csrf_Token(); %>
<table cellpadding=1 cellspacing=2 border=0 align="center">
<tbody>
 <tr >   
   <td width=270px><script language="JavaScript">doc(actb)</script></td>
   <td width=130px><input type="checkbox" id=userEnable name="userEnable"></td>
   <td width=300px></td>
 </tr>   
 <tr >   
   <td width=270px><script language="JavaScript">doc(AUTHORITY_)</script></td>
   <td width=130px><script language="JavaScript">fnGenSelect(selstate, '')</script></td>
   <td width=300px></td>

</tr>   
 <tr >   
   <td width=270px><script language="JavaScript">doc(User_Name)</script></td>
   <td width=130px><input type="text" id=userName name="userName" size=16 maxlength=16 disabled></td>
   <td width=300px></td>

</tr>  
   <tr  id="modify_hidden0">   
   <td width=270px><script language="JavaScript">doc(Old_PW)</script></td>
   <td width=130px><input type="password" id=old_pw name="old_pw" size=16 maxlength=16 autocomplete="off"></td>
   <td width=300px></td>

</tr>  
  <tr  id="modify_hidden1">   
   <td width=270px><script language="JavaScript">doc(New_PW)</script></td>
   <td width=130px><input type="password" id=new_pw name="new_pw" size=16 maxlength=16 autocomplete="off"></td>
   <td width=300px></td>

 </tr>  
  <tr  id="modify_show0" style="display:none">   
   <td width=270px><script language="JavaScript">doc(Password_)</script></td>
   <td width=130px><input type="password" id=set_pw name="set_pw" size=16 maxlength=16 autocomplete="off"></td>
   <td width=300px></td>

 </tr>  
  <tr >   
   <td width=270px><script language="JavaScript">doc(CONFIRM_PWD_)</script></td>
   <td width=130px><input type="password" id=confirm_pw name="confirm_pw" size=16 maxlength=16 autocomplete="off"></td>
   <td width=300px></td>

</tr>  
</tbody>
</table>
<table>
<tbody>

 <tr>
  <td colspan=2>
 	<table cellpadding=1 cellspacing=2 border=0>
     <tr>   
       <td width=400px><script language="JavaScript">fnbnBID_Admin(CREATE_, 'onClick=Activate(this)', CREATE_)</script></td>
       <td width=300px><script language="JavaScript">fnbnBID_Admin(APPLY_, 'onClick=Activate(this)', APPLY_)</script></td>
     </tr>  
	</table>  
  </td>
 </tr>
 </tbody>

</table>  

<table cellpadding=1 cellspacing=2 id="show_setting_table" style="width:450px">
<tr width=450px></tr>
 <tr align="center">
  <th width=100px><script language="JavaScript">doc(actb)</script></th>
  <th width=150px><script language="JavaScript">doc(User_Name)</script></th>
  <th width=150px><script language="JavaScript">doc(AUTHORITY_)</script></th>
  <th width=50px></th>
 </tr> 
</table>
</fieldset>
</form>
<!--
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>i
-->
</body></html>
