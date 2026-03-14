<html>
<head>

{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">
checkCookie();
debug = 0;   
if (debug) {
    var SRV_OPENVPN_SERVER_USER_type;
    var openvpnServer0_type = { username0:4, password0:4, remoteNetwork0:5, remoteNetmask0:5};
    var SRV_OPENVPN_SERVER_USER= { clientNum0:'1', clientNum1:'1' };
    var openvpnServer0=[ { username0:'test', password0:'1234', remoteNetwork0:'10.1.1.1', remoteNetmask0:'255.255.255.0'},
                         { username0:'Scada', password0:'1234678@@1', remoteNetwork0:'20.1.1.1', remoteNetmask0:'255.255.255.0'}  ];
    
}
else {
	{{ net_Web_show_value('SRV_OPENVPN_SERVER_USER') | safe }}	
}

var myForm;
var ovpnServerId = 1;
var OPENVPN_MAX_CLIENT_NUM = 5;
    
var ovpnServer0 = [
        { value:1,   text:'ovpnserver1' },
        //{ value:2,   text:'ovpnserver2' }
];
        
var selOvpnServer = { type:'select', id:'ovpnServerId', name:'ovpnServerId', size:1, option:ovpnServer0 };
    
// Table function
var newdata = new Array;
var table_idx = 0;
//var tablefun = new table_show(document.getElementsByName('myForm'), "show_openvpn_table", openvpnServer0_type, openvpnServer0, table_idx, newdata, Addformat, 0);
var showentry = {username0:0, remoteNetwork0:0, remoteNetmask0:0};
var tablefun = new table_set_diff_show(document.getElementsByName('myForm'),"show_available_table" ,openvpnServer0_type, openvpnServer0, table_idx, newdata, Addformat, showentry);

function EditRow(rowidx) 
{

    //alert("index="+ rowidx);
    fnLoadForm(myForm, openvpnServer0[rowidx], openvpnServer0_type);
    ChgColor('tri', openvpnServer0.length, rowidx);
  
}    

    
function ovpn_checkTableStatus()
{
    /* Check and change the button states */
	if(openvpnServer0.length > OPENVPN_MAX_CLIENT_NUM || openvpnServer0.length  < 0){		
		alert('Number of OpenVPN users is over or wrong');
		with(document.myForm){
			btnA.disabled = true;			
			btnD.disabled = false;			
			btnM.disabled = false;			
			btnS.disabled = true;
		}				
	}else if(openvpnServer0.length == OPENVPN_MAX_CLIENT_NUM){
		with(document.myForm){
			btnA.disabled = true;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}else if(openvpnServer0.length == 0){		
		with(document.myForm){		
			btnA.disabled = false;
			btnD.disabled = true;
			btnM.disabled = true;
			btnS.disabled = false;
		}
	}else{		
		with(document.myForm){		
			btnA.disabled = false;
			btnD.disabled = false;
			btnM.disabled = false;
			btnS.disabled = false;
		}
	}
    
    return;   
}
    
function Addformat(mod, i)
{
	var j = 0, k, m;

	for(k in openvpnServer0_type){

		if(mod == 0){
			newdata[k] = openvpnServer0[i][k];
		}
		else{
			newdata[k] = document.getElementById('myForm')[k].value;
		}

        //alert(j +"value ="+newdata[j]);
		//j++;
	}

}    
    
function tabbtn_sel(form, sel)
{
    var i;

    if((sel == 0) || (sel == 2)){ // Add or Modify

        if(sel == 0){ // Add
            table_idx = 5;

            // Check the user information
            for(i=0; i<openvpnServer0.length; i++){
                if(openvpnServer0[i].username0==form.username0.value){
                    alert("User name must be unique");
                    return;
                }
            }
        }
        else{ // Modify
            table_idx = tNowrow_Get();
        }

        // Check the user and password data
        if(form.username0.value == "") {
            alert("Error: "+User_Name+" is NULL");
	    return;
	}
        
        if(form.password0.value != form.password_c.value){  
            alert("Password setting values are mismatch");
            return;
        }

        if(form.password0.value.length < 4 || form.password0.value.length > 32) {
            alert("Password must have 4 ~ 32 characters");

            return;
        }

    }

    if(sel == 0){ // add
        Addformat(1, 0);
        tablefun.add();
    }
    else if(sel == 1){ // delete
        tablefun.del();
    }
    else if(sel == 2){ // modify
        tablefun.mod();
    }
    
    ovpn_checkTableStatus();
}    
    
function Activate(form)
{
	var i, j;

	form.openvpnServer0_tmp.value = "";

	for(i=0; i<openvpnServer0.length; i++){
		for(j in openvpnServer0[i]){
			form.openvpnServer0_tmp.value = form.openvpnServer0_tmp.value + openvpnServer0[i][j] + "+";
		}

	}

	form.action="/goform/net_Web_get_value?SRV=SRV_OPENVPN_SERVER_USER";
	form.submit();	
}


function fnInit() 
{	
		
	myForm = document.getElementById('myForm');	
	
	// init for table
	tablefun.show();
	EditRow(0);

}

function stopSubmit()
{
	return false;
}
</script>
</head>
    
<body onLoad=fnInit()>
<h1>OpenVPN User Management</h1>

<fieldset width="700px">
<form id=myForm name=myForm method="POST"  onSubmit="return stopSubmit()" >
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="openvpnServer0_tmp" id="openvpnServer0_tmp" value="" >
<DIV style="width:700px;">
<table cellpadding=1 cellspacing=2 border=0 width="700px">
 <tr>
    <td width=270px>OpenVPN Server</td>
    <td width=130px><script language="JavaScript">fnGenSelect(selOvpnServer, ovpnServerId)</script></td>
    <td width=300px></td>
 </tr>
 <tr >   
   <td width=270px><script language="JavaScript">doc(User_Name)</script></td>
   <td width=130px><input type="text" id=username0 name="username0" size=30 maxlength=64></td>
   <td width=300px></td>
 </tr>

  <tr  id="modify_hidden1">   
   <td width=270px><script language="JavaScript">doc(New_PW)</script></td>
   <td width=130px><input type="password" id=password0 name="password0" size=30 maxlength=64 autocomplete="off"></td>
   <td width=300px></td>

 </tr>  
 <tr >   
   <td width=270px><script language="JavaScript">doc(CONFIRM_PWD_)</script></td>
   <td width=130px><input type="password" id=password_c name="password_c" size=30 maxlength=64 autocomplete="off"></td>
   <td width=300px></td>
 </tr>
 <tr> 
  <td>Remote Network</td>
  <td nowrap><input type="text" id="remoteNetwork0" name="remoteNetwork0" size="15" maxlength="15"></td> 
  <td>Netmask</td>
  <td nowrap><input type="text" id="remoteNetmask0" name="remoteNetmask0" size="15" maxlength="15"></td> 
 </tr>
</table>

<p>
<table align=left border=0 width=700px>
 <tr>
  <td width=400px><script>fnbnBID(addb, 'onClick=tabbtn_sel(this.form,0)', 'btnA')</script>
    <script>fnbnBID(delb, 'onClick=tabbtn_sel(this.form,1)', 'btnD')</script>
    <script>fnbnBID(modb, 'onClick=tabbtn_sel(this.form,2)', 'btnM')</script></td>
  <td width=200px><script>fnbnSID(Submit_, 'onClick=Activate(this.form)', 'btnS')</script></td>
  <td width=100px></td>
 </tr>
</table></p>
    
<table align=left border=0>
<tr style="height:50px"></tr>
</table>
</DIV>
</form>

<table cellpadding=1 cellspacing=2 width="450px">
 <tr class=r0>
  <td width=200px>OpenVPN User</td>
  <td id="totalpolicy" colspan=5></td></tr>
</table>     
    
<table cellpadding=1 cellspacing=2 id="show_available_table" style="width:550px">
 <tr> 
  <td colspan=4></td> 
 </tr>
 <tr align="center">
  <th width=150px class="s0"><script language="JavaScript">doc(User_Name)</script></th>  
  <!--<th width=100px class="s0">Password</th>
-->
  <th width=150px class="s0">Remote Network</th>
  <th width=150px class="s0">Netmask </th>       
 </tr> 
   
</table>
</fieldset>


</body></html>
