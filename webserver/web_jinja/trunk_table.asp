<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkMode({{ net_Web_GetMode_WriteValue() | safe }});
var SYSPORTS = {{ net_Web_Get_SYS_PORTS() | safe }}
var SYSTRUNKS = {{ net_Web_Get_SYS_TRUNKS() | safe }}
var port_desc=[{{ net_webPortDesc() | safe }}];
var PortLink=	new Array({{ net_Web_Get_Port_Link() | safe }});
{{ net_Web_show_value('SRV_TRUNK_SETTING') | safe }}	 
var linksel = [
	{ value:0, text:Fail_},	{ value:1, text:Success_}
];
var trunk_check=new Array;
//var trunk_member=new Array;

function addRow(idx,num) {
    var i,j;
	row = table.insertRow(table.getElementsByTagName("tr").length);
	cell = document.createElement("td");
	cell.setAttribute("rowSpan",num);
	cell.innerHTML = 'Trk'+idx;
	row.appendChild(cell);
	for(i=0,j=0; i<SYSPORTS; i++)
	{
        if(SRV_TRUNK_SETTING[i].trkgrp==idx)
        {	
	        cell = document.createElement("td");
	        cell.innerHTML =port_desc[i].index;
	        row.appendChild(cell);
	        cell = document.createElement("td");
	        cell.innerHTML =linksel[PortLink[i]].text;;
	        row.appendChild(cell);
            row.style.backgroundColor = "#CCE6E6";			
            row.className="r1";			
			j++;
	        if(num>j)
	        {
	            row = table.insertRow(table.getElementsByTagName("tr").length);
	        }
			else break;
	    }
	}
}

function ShowTrunk() {
var i,j;
        for(i=1; i<=SYSTRUNKS; i++)
		{
			trunk_check[i]=0;
		}
		for(i=0; i<SYSPORTS; i++){	    
		      if(SRV_TRUNK_SETTING[i].trkgrp!=0)
			  {
				  trunk_check[SRV_TRUNK_SETTING[i].trkgrp]=trunk_check[SRV_TRUNK_SETTING[i].trkgrp]+1;//number of ports of this trunk member
			  }
		}
		
	table = document.getElementById("show_trkgrp_member");
	//rows = table.getElementsByTagName("tr");
	//delete added the table members
	/*if(rows.length > 1)
	{
		for(i=rows.length-1 ;i>0;i--)
		{
			table.deleteRow(i);
		}
	}*/
	//re-join the array elements to the table
	for(i=1; i<=SYSTRUNKS; i++)
	{
		if(trunk_check[i]!=0)
		{			
		    addRow(i,trunk_check[i]);
        }		
	}
}

var myForm;
function fnInit() {
		myForm = document.getElementById('myForm');	
	    var i;
		/*for(i=1; i<=trunk_all; i++)
		{
			trunk_check[i]=0;
		}
		for(i=0; i<SYSPORTS; i++){	    
		      if(SRV_TRUNK_SETTING[i].trkgrp!=0)
			  {
			      trunk_check[SRV_TRUNK_SETTING[i].trkgrp]=trunk_check[SRV_TRUNK_SETTING[i].trkgrp]+1;
			  }
		}*/
	fnLoadForm(myForm, SRV_TRUNK_SETTING, SRV_TRUNK_SETTING_type);
}
</script>
</head>

<body bgcolor="#FFFFFF" text="#000000" topmargin="10" leftmargin="12" onLoad="fnInit()">
<h1><script language="JavaScript">doc("Trunking Status")</script></h1>
<form id=myForm  method="post" name="trunk_table_form">
<fieldset>
{{ net_Web_csrf_Token() | safe }}
<div align="left">
	<table width="20%" align="left" border="0">
		<tr>
			<td width="5%"></td>
        	<td width="60%">
        		<table width="300" align="left" border="0">
	        		<tr bgcolor="#007C60">
	    				<th width="20%"><script language="JavaScript">doc(TrunkGroup_)</script></th>
	    				<th width="20%"><script language="JavaScript">doc(MemberPort_)</script></th>
	    				<th width="20%"><script language="JavaScript">doc(Status_)</script></th>
	        		</tr>
	        	</table>
        	</td>
			<td width="35%"></td>
        </tr>
		<tr>
			<td width='5%'></td>
			<td width='60%'>
	            <table width="300" cellpadding=1 cellspacing=2 id="show_trkgrp_member" >	
		               <tr>
					       <td width='20%'></td>
 		                   <td width='20%'></td>
 		                   <td width='20%'></td>	
		               </tr>	
		               <script language="JavaScript">ShowTrunk()</script>
	            </table>
	        </td>
		</tr>	

</table>
</div>
</fieldset>
<!-- --> 
</form>
</body>
</html>