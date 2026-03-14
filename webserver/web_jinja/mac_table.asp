<html>
<head>  
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">

<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}
var SYSTRUNKS = {{ net_Web_Get_SYS_TRUNKS() | safe }}
var IVL_check = {{ net_Web_Get_IVL() | safe }}
var port_desc=[{{ net_webPortDesc() | safe }}];
{{ net_Web_show_value('SRV_TRUNK_SETTING') | safe }}
{{ net_Web_show_value('SRV_AGE_TIME') | safe }}
if (!debug) {
	var SRV_MAC_TABLE = [
		{mac:'00-90-e8-0d-ea-f3', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'1', port6:'0', port7:'0', port8:'0', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'},
		{mac:'00-90-10-00-aa-f3', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'0', port6:'1', port7:'1', port8:'0', port9:'0', port10:'1', port11:'0', port12:'0', port13:'0'},
		{mac:'00-90-e8-dd-ff-ff', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'0', port6:'0', port7:'0', port8:'1', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'},
		{mac:'00-ee-e8-0d-dd-dd', type:'ucast', set:'learn',  vlan:'1', port0:'1', port1:'0' ,port2:'0', port3:'0', port4:'0', port5:'1', port6:'0', port7:'0', port8:'0', port9:'0', port10:'0', port11:'0', port12:'1', port13:'0'},
		{mac:'00-ff-e8-0d-ee-0e', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'0', port3:'1', port4:'0', port5:'1', port6:'0', port7:'1', port8:'0', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'},
		{mac:'00-ff-ff-0d-ef-aa', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'1', port6:'0', port7:'0', port8:'0', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'},
		{mac:'00-90-e8-0d-ba-ab', type:'ucast', set:'learn',  vlan:'1', port0:'1', port1:'0' ,port2:'0', port3:'0', port4:'0', port5:'1', port6:'0', port7:'1', port8:'0', port9:'0', port10:'1', port11:'0', port12:'0', port13:'0'},
		{mac:'00-90-e8-bb-ea-f3', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'1', port6:'1', port7:'0', port8:'0', port9:'0', port10:'0', port11:'0', port12:'1', port13:'0'},
		{mac:'00-90-e8-ab-ea-f3', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'1', port6:'0', port7:'0', port8:'0', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'},
		{mac:'00-90-e8-ab-ea-f3', type:'mcast', set:'static',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'1', port6:'0', port7:'0', port8:'0', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'},
		{mac:'00-90-e8-ab-ea-f3', type:'mcast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'1', port6:'0', port7:'0', port8:'0', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'},
		{mac:'00-90-e8-bd-ea-f3', type:'ucast', set:'learn',  vlan:'1', port0:'0', port1:'0' ,port2:'1', port3:'0', port4:'0', port5:'1', port6:'0', port7:'1', port8:'0', port9:'0', port10:'0', port11:'0', port12:'0', port13:'0'}
		
	];
	var page_display=0;
	var page_all=1;
}
else{
	{{ net_WebMacTable() | safe }}

}
var check_list =[
    {index:'set', text:'learn'}, {index:'set', text:'static'}, {index:'type', text:'mcast'},
]
var select_list = [
	{ value:0, text:'All' }, { value:1, text:'All Learned' }, { value:2, text:'All Static' },
	{ value:3, text:'All Multicast' },
	]
var select_page = [
	{ value:0, text:'Page 1/1' },
	]
//var sel_list = { type:'select', id:'select_mac_list', name:'select_mac_list', size:1, onChange:'ShowTable(this.value,0)', option:select_list };
var sel_list = { type:'select', id:'select_mac_list', name:'select_mac_list', size:1, onChange:'showNewWebPage(this.value,0)', option:select_list };
var sel_page = { type:'select', id:'select_page_list', name:'select_page_list', size:1, onChange:'ShowTable2(this.value)', option:select_page };
var trunk_check=new Array;
var port_list=new Array;
var port_list_total=0;


function trunk_check_init()
{
	var i;
    for(i=0;i<= (SYSTRUNKS+1);i++)//init
	    trunk_check[i]=0;
	for(i=0;i< SYSPORTS;i++)
	{
	    if(SRV_TRUNK_SETTING[i].trkgrp==0)
		{
		    port_list[port_list_total]=i;
			port_list_total++;
		}
		trunk_check[SRV_TRUNK_SETTING[i].trkgrp]++; //count trunk group's ports
	}
	for(i=0;i<SYSTRUNKS;i++)
	{
	    if(trunk_check[i+1]!=0)
		{
		    port_list[port_list_total]=i+SYSPORTS;
			//alert(port_list[port_list_total]);
			port_list_total++;		
		}
	}
}

function show_list_select()
{
    var i, idx, len, name, list_count=4;
	fnGenSelect(sel_list, 0);
	trunk_check_init();
	for(i=0; i < SYSPORTS+SYSTRUNKS; i++)
	{
		if(i<SYSPORTS && SRV_TRUNK_SETTING[i].trkgrp==0)
		{
		    idx=i+1;
			name='Port '+port_desc[i].index;
			var varItem = new Option(name,list_count);      
          	document.getElementById("select_mac_list").options.add(varItem); 
            list_count++;			
		}
		else if(i>=SYSPORTS && trunk_check[i-SYSPORTS+1]!=0)
		{
		    idx=i+1-SYSPORTS;
			name='Port Trk'+idx;
			var varItem = new Option(name,list_count);      
          	document.getElementById("select_mac_list").options.add(varItem); 
            list_count++; 		    
		}
		else
		{
		    //trunk_check[SRV_TRUNK_SETTING[i].trkgrp]++;
		}
	}
}
//
function show_page_select()
{
    var i, idx, name, page;
	document.getElementById("select_page_list").options.length=0; 

	
	//if(total_item%10==0)page=total_item/10;
	//else page=Math.floor(total_item/10)+1;
	page=page_all;

	if(page!=0)
	{
	    for(i=0; i<page ; i++)
	    {
	        idx=i+1;
	        name='Page '+idx+'/'+page;
		    var varItem = new Option(name,i);
		    document.getElementById("select_page_list").options.add(varItem); 
    	}
	}
	
}
//
function addrow(add_i,add_item)
{
 	var port_num_total=" ",count=0,temp;
	row = table.insertRow(table.getElementsByTagName("tr").length);
	cell = document.createElement("td");
	cell.innerHTML = (page_type*10) + add_item + 1;		
	row.appendChild(cell);
	row.style.Color = "black";
	row.style.backgroundColor = "white";
	row.align="center";
	for(idx in SRV_MAC_TABLE[0])
	{				
		if(idx=="type")
		{ 
			 cell = document.createElement("td");
			 if(SRV_MAC_TABLE[add_i]["set"]=="learn")
			 cell.innerHTML=SRV_MAC_TABLE[add_i]["type"]+"(l)";
			 else if(SRV_MAC_TABLE[add_i]["set"]=="static")
			 cell.innerHTML=SRV_MAC_TABLE[add_i]["type"]+"(s)";
		}
		else if(idx=="set");
		else if(idx=="port0")
		{
		     for(var i=0;i<SYSPORTS+4;i++)
			 {
			     if(SRV_MAC_TABLE[add_i]["port"+i]==1 && i<SYSPORTS)
				 {
				     temp_number=port_desc[i].index;
					 if(count==0)
					     port_num_total=temp_number;
					 else
					     port_num_total=port_num_total+', '+temp_number;
					 count++;
				 }
				 else if(SRV_MAC_TABLE[add_i]["port"+i]==1 && i>=SYSPORTS)
				 {
				     temp=i-SYSPORTS+1;				
					 temp_number='Trk'+temp;
					 if(count==0)
					     port_num_total=temp_number;
					 else
					     port_num_total=port_num_total+', '+temp_number;
					 count++;					 
				 }
			 }
			 cell = document.createElement("td");
			 cell.innerHTML = port_num_total;
			 row.appendChild(cell);
			 break;
		}
		else if(idx=="vlan")
		{
			 if(IVL_check){
			 	cell = document.createElement("td");
			 	cell.innerHTML = SRV_MAC_TABLE[add_i][idx];
			 }
		}
		else
		{
			 cell = document.createElement("td");
			 cell.innerHTML = SRV_MAC_TABLE[add_i][idx];		
		}
		row.appendChild(cell);
	}   
}
function ShowTable2(page)
{
    
    var list=document.getElementById("select_mac_list").value;
	showNewWebPage(list,page);
}
function ShowTable(list,page)
{
	var page_item=0, total_item=SRV_MAC_TABLE.length;
	table = document.getElementById("show_mac_table");	
	for(i = table.getElementsByTagName("tr").length-1; i > 0; i--)
	{
		table.deleteRow(i);
	}
	if(list==0)
	{
	    for(i=0, page_item = 0; i < SRV_MAC_TABLE.length && page_item < page*10+10; i++,page_item++)
	    {				
		    if( page_item>=page*10)
			{
			    addrow(i,page_item);
		        row.className=((i%2)-1)?"r1":"r2";				
			}
	    }
    }
	else if(list<4)
	{
		for(i=0, page_item = 0; i < SRV_MAC_TABLE.length && page_item < page*10+10; i++)
		{
            if(SRV_MAC_TABLE[i][check_list[list-1].index]==check_list[list-1].text)	
            {		
		        if(page_item>=page*10)
				{			
                    addrow(i,page_item);
		            row.className=((i%2)-1)?"r1":"r2"; 
				}
				page_item++;
	        }
	        else 
			{
				total_item--;
			}
	    }
	}
	else
	{
		list=port_list[list-4];
		for(i=0, page_item = 0; i < SRV_MAC_TABLE.length && page_item < page*10+10; i++)
		{
            if(SRV_MAC_TABLE[i]['port'+list]==1)	
            {
		        if(page_item>=page*10)
				{			
                    addrow(i,page_item);
		            row.className=((i%2)-1)?"r1":"r2"; 
				}
				page_item++;
	        }
	        else 
			{
				total_item--;
			}
	    }
	}
	
	//if(page==0)show_page_select(total_item);
}

    var list_type, refresh_type, page_type;
    function getWebPageIndex()
    {
        var url=window.location.toString(); 
        var str="";  
        if(url.indexOf("?")!=-1)
        {
            var ary=url.split("?")[1].split("&");
    
            for(var i in ary)
            {
                str=ary[i].split("=")[0];
                if (str == "show_list")        
                    list_type = decodeURI(ary[i].split("=")[1]);                   
                else if(str == "show_page")
                    page_type = decodeURI(ary[i].split("=")[1]);  
				else if(str == "show_refresh")
                    refresh_type = decodeURI(ary[i].split("=")[1]);
            }
        }

    }

function showNewWebPage(list,page){
	var refresh=1;
	var dest;	
	dest="mac_table.asp?"+ "show_list=" + list + "&" + "show_page=" + page + "&" + "show_refresh=" + refresh ;	
	location.href=dest;
}	
function stopSubmit()
{
	return false;
}

function Send(form){
    if(form.agetime.value < 5 || form.agetime.value > 300){
        alert("Age time should be between 5s ~ 300s");
        return;
    }
    form.action="/goform/net_Web_get_value?SRV=SRV_AGE_TIME"
    form.submit();
}

var myForm;
function fnInit() 
{	
	getWebPageIndex();
	document.getElementById("select_mac_list").value=list_type;
	if(IVL_check==0)document.getElementById("show_IVL").style.display="none";
	
	if(SRV_MAC_TABLE==""){
		return;
	}	

	show_page_select();
	if(refresh_type==1){
		document.getElementById("select_page_list").value=page_type;
		ShowTable(list_type,0);
	}
	else ShowTable(0,0);

	myForm = document.getElementById('myForm');	
	fnLoadForm(myForm, SRV_AGE_TIME, SRV_AGE_TIME_type);
}
</script>
</head>
<body class=main onLoad=fnInit()>
<h1><script language="JavaScript">doc(mac_table);</script></h1>
<fieldset>
<!--<form id=myForm method="post" name="age_time_form" action="/goform/net_Web_get_value?SRV=SRV_AGE_TIME">-->
<form id=myForm method="post" name="age_time_form">
{{ net_Web_csrf_Token() | safe }}
<table style="width:650px" border="0">
 <tr>
  <td width=130px ><script language="JavaScript">doc(Age_)</script></td>
  <td width=250px ><input type=text id="agetime" name="agetime" size="30" maxlength="30"></td>
  <td width=220px ><script language="JavaScript">fnbnS(Submit_, 'onclick=Send(myForm)')</script></td>
 </tr>
</table>
</form>

<table style="width:650px" border="0">
 <tr>
  <td style="width:650px" bgcolor='blue'><td>
 </tr>
</table>

<table style="width:650px">
<tr align="left" >
 <td width=150px align="left"><script language="JavaScript">show_list_select()</script></td>
 <td><script language="JavaScript">fnGenSelect(sel_page, 0)</script></td>
</tr> 
</table>
<table cellpadding=1 cellspacing=2 id="show_mac_table" style="width:650px">
 <tr align="center" width=620px>
  <th width=50px ><script language="JavaScript">doc(Index_)</script></th>
  <th width=170px ><script language="JavaScript">doc(MAC_Address)</script></th>
  <th width=130px ><script language="JavaScript">doc(Type_)</script></th>
  <th width=110px id="show_IVL"><script language="JavaScript">doc(Vlan_)</script></th>
  <th width=110px ><script language="JavaScript">doc(Port_)</script></th>
 </tr>
</table>
</fieldset>
</body>
</html>
