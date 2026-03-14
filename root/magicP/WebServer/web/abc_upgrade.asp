<html>
<head>
<% net_Web_file_include(); %>
<!-- 
<title><script language="JavaScript">//doc(Upgrade_Software_or_Configuration)</script>
Auto Backup Configurator
</title>
-->
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript" src=input.js></script>
<script language="JavaScript">
checkCookie();

    var http_request;
    var selectedPath = "", selectedName = "", selectedType="";
    var currentPath="";
    var showPage=0;
    var type;
    var button_disable = 0 ;
    var export_success=0;

    if(window.XMLHttpRequest){
        http_request = new XMLHttpRequest();
    }
    else if(window.ActiveXObject){
        try{
            http_request = new ActiveXObject("Msxml2.XMLHTTP");
        } catch(e){
            try {
                http_request = new ActiveXObject("Microsoft.XMLHTTP");
            } catch(e){}
        }
    }


checkCookie();
//<!--
	
	function init(){
		SI.Files.stylizeAll();
		//document.getElementById("fwrtext").readOnly=true; 
		//document.getElementById("configtext").readOnly=true;  		 
 	}

	function GetFirmwareRouter(){
		//document.getElementById("fwrtext").value=document.getElementById("fwrfile").value; 
	}
	var file_name;
	function MakeContents(http_request) {
		var nm, data;		
	    if (http_request.readyState == 4) {
			if (http_request.status == 200) {				
				location=file_name;
			} else {
                return ;
				//alert('There was a problem with the request.'+http_request.status);
			}
		}
	}

    function abc_MakeAndGetCfg(form){
        if(button_disable == 0){
            form.action = "/goform/ABC_02_MakeConfigureFile";
            form.submit();
            button_disable = 1;
        }
        else{
            return ;
        }
	}

	function MakeAndGetLog(form){
        if(button_disable == 0){
            form.action = "/goform/ABC_02_MakeMOXALogFile";
            form.submit();
            button_disable = 1;
       }
        else{
            return ;
        }
	}	
	
    function abc02_CfgImport(form){
        if(button_disable == 0){
            var Path = document.getElementById('id_pathRestore_config');
            if( Path.value != ""){
    			document.getElementById("loadingimg").style.visibility = "visible";

                form.action="/goform/ABC_02_cfgImport";
                form.submit();
                button_disable = 1;
            }
           else{ 
                return ;
                //alert("No configfile"); 
                }
        }
	}	
	var DifferenceSecond = 1;
	var barwidth1 = 1;
	var barwidth2 = 49;

    /*
	function send(form){
		form.action="/goform/net_Web_get_value?SRV=SRV_CFG_ENC_PW";	
		form.submit();	
	}*/


    function clock_post(form){
    if(button_disable == 0){
        var Path = document.getElementById('id_pathRestore');
        if( Path.value != ""){
            //JustinJZ.Huang
            form.action="/goform/ABC_02_fwUpload";
	        form.submit();
            button_disable = 1;
            clock();
        }   
        else{
            return;
            //alert("No firmware");
            }
        }
    else{
            return;
        }
    }


	//-->
    /*
    function percent_bar() { 
        table = document.getElementById("bar_table");
	    rows = table.getElementsByTagName("tr");
	    if(rows.length)
	    	table.deleteRow(0);
   		row = table.insertRow(0);
   		row.className="r1";
    	row.align="left";
   		cell = document.createElement("td");
    	cell.width= "20%"
   		cell.innerHTML = DifferenceSecond + " %";
   		cell.style.backgroundColor = "#FFFFFF";
   		row.appendChild(cell);
    	cell = document.createElement("td");
   		barwidth11 = barwidth1 + "%";
   	    cell.align="left";
    	cell.width= barwidth11;
	    cell.style.backgroundColor = "#00FF00";
   		row.appendChild(cell);
    	cell = document.createElement("td");
    	barwidth21 = barwidth2 + "%";
   	    cell.align="left";
   		cell.width= barwidth21;
    	cell.style.backgroundColor = "#FFFFFF";
   		row.appendChild(cell);
    	cell = document.createElement("td");
   		cell.width= "30%"
    	cell.style.backgroundColor = "#FFFFFF";
	    row.appendChild(cell);
   		DifferenceSecond = DifferenceSecond + 1;
    	if (DifferenceSecond%2)
	    	if (barwidth1 < 49)
   				barwidth1 = barwidth1+1;
       	barwidth2 = 50 - barwidth1;
   		if (DifferenceSecond < 100)
    		setTimeout("percent_bar()",3000)
	    else
		    location.href=location.reload();
    }
    */
	function clock()
	{
		table = document.getElementById("bar_table");
		rows = table.getElementsByTagName("tr");
		if(rows.length)
			table.deleteRow(0);
		row = table.insertRow(0);
		row.className="r1";
		row.align="left";
		cell = document.createElement("td");
		cell.width= "20%"
		cell.innerHTML = DifferenceSecond + " %";
		cell.style.backgroundColor = "#FFFFFF";
		row.appendChild(cell);
		cell = document.createElement("td");
		barwidth11 = barwidth1 + "%";
		cell.align="left";
		cell.width= barwidth11;
		cell.style.backgroundColor = "#00FF00";
		row.appendChild(cell);
		cell = document.createElement("td");
		barwidth21 = barwidth2 + "%";
		cell.align="left";
		cell.width= barwidth21;
		cell.style.backgroundColor = "#FFFFFF";
		row.appendChild(cell);
		cell = document.createElement("td");
		cell.width= "30%"
		cell.style.backgroundColor = "#FFFFFF";
		row.appendChild(cell);
		DifferenceSecond = DifferenceSecond + 1;
		if (DifferenceSecond%2)
			if (barwidth1 < 49)
				barwidth1 = barwidth1+1;
		barwidth2 = 50 - barwidth1;
		if (DifferenceSecond < 100)
			setTimeout("clock()",3000)
		else
			location.href=location.reload();
	}

    function selectFile(selection)
    {
    
	if(selectedPath == "" || selectedName == "" || selectedType == "")
		return
	if(selectedType == "file") {
		if(selection ==1 ){
			var inputRestore = document.getElementById('abc02_fieldRestore');
			inputRestore.value = selectedName;
			var inputPathRestore = document.getElementById('id_pathRestore');
			inputPathRestore.value = selectedPath;
			var divABC02Browse = document.getElementById('DivABCBrowse');
			divABC02Browse.style.display = "none";
     
		}	
		else if(selection ==2 ){
			var inputRestore = document.getElementById('abc02_fieldRestore_config');
			inputRestore.value = selectedName;
			var inputPathRestore = document.getElementById('id_pathRestore_config');
			inputPathRestore.value = selectedPath;
			var divABC02Browse = document.getElementById('DivABCBrowse_config');
			divABC02Browse.style.display = "none";
		}
	}

	else if(selectedType == "folder") {
        showPage=0;
		if(selectedName == ".") {
			USBFileBrowser("/mnt/ramdisk/usb_moxa/moxa",selection);
		}else if(selectedName == "..") {
		// not necessary, but can make things easily if need further handling, and make sure it won't be too long...
		// ex: /xxx/xxxx/xxxx/..
			USBFileBrowser(selectedPath.slice(0, selectedPath.lastIndexOf("/", selectedPath.length-4)),selection);
		}else{
			USBFileBrowser(selectedPath,selection);
		}
	}
	
	//alert(selectedPath + "   " + selectedName + "   " + selectedType);
    }

    function selectRow(rowIndex, path, name, type,selection)
    {
	if(selection ==1 )
		var browseTable = document.getElementById("id_ABCBrowseTable");
	else if(selection == 2)
		var browseTable = document.getElementById("id_ABCBrowseTable_config");
	var cells;
	for(var index = 0; index < browseTable.rows.length; ++index)
	{
	    cells = browseTable.rows[index].cells;
	    if(index == rowIndex) {
	        for(var cIndex = 0; cIndex < cells.length; ++cIndex) {
		        cells[cIndex].style.backgroundColor = "#00FF00";
	        }
	    } else {
	        for(var cIndex = 0; cIndex < cells.length; ++cIndex) {
			    cells[cIndex].style.backgroundColor = "#FFFFFF";
		    }
	    }
	}
	selectedPath = path;
	selectedName = name;
	selectedType = type;
    }
    function DoubleClickRow(rowIndex, path, name, type , selection)
    {
	    selectRow(rowIndex, path, name, type,selection);
	    selectFile(selection);
    }

    function addRow(path, name, type, selection)
    {
	if(selection ==1 )
		var browseTable = document.getElementById("id_ABCBrowseTable");
	if(selection ==2 )
		var browseTable = document.getElementById("id_ABCBrowseTable_config");
	
    var newRow = browseTable.insertRow(browseTable.rows.length);
	
    newRow.value = path;
	newRow.style.lineHeight = "1";
	
    var rowIndex = browseTable.rows.length -1 ;
	newRow.onclick = function(){selectRow(rowIndex, path, name, type,selection)};
	newRow.ondblclick = function(){DoubleClickRow(rowIndex, path, name, type ,selection)};
	
	var newCell = document.createElement("td");
	newCell.style.fontSize = "12px";
		
	if(type == "file")
		newCell.innerHTML = name;
	else if(type == "folder")
		newCell.innerHTML = "/" + name;
	else
		newCell.innerHTML = "???";	
	newRow.appendChild(newCell);
    }


    function USBFileBrowserStart(path,selection){ 
        showPage = 0;
        USBFileBrowser(path,selection);
    }
    function USBFileBrowserPrev(selection){
        showPage--; 
        USBFileBrowser(currentPath,selection);
    }
    function USBFileBrowserNext(selection) {
        showPage++;
        USBFileBrowser(currentPath,selection);
    }

	function USBFileBrowser(path,selection) {
        http_request.onreadystatechange = function()
		{
			if(selection == 1){
				var divABC02Browse = document.getElementById('DivABCBrowse');
				var divABC02Browse_tmp = document.getElementById('DivABCBrowse_config');
				divABC02Browse_tmp.style.display="none";
			}
			else if(selection ==2){
				var divABC02Browse = document.getElementById('DivABCBrowse_config');
				var divABC02Browse_tmp = document.getElementById('DivABCBrowse');
				divABC02Browse_tmp.style.display="none";
			}
			if (http_request.readyState == 4) {
				if (http_request.status == 200) {

                  if(selection == 1)
					    var browseTable = document.getElementById("id_ABCBrowseTable");
                    else if(selection == 2)
                        var browseTable = document.getElementById("id_ABCBrowseTable_config");
					var rows = browseTable.rows;
					if(rows.length > 0)
					{
    					for(var index = rows.length-1 ; index >= 0; index--)
						{
							browseTable.deleteRow(index);
						}
					}
					// Start parsing
					var xmldoc = http_request.responseXML;
					var root_node = xmldoc.getElementsByTagName('usb_data');
					var info_node, page_node;
					var path, name, type, hasNext;
					if(root_node.length > 0) {
						info_node = root_node[0].getElementsByTagName("info");
						for(var index = 0; index < info_node.length; ++index) {
							path = info_node[index].getAttribute('path');
							name = info_node[index].getAttribute('filename');
							type = info_node[index].getAttribute('type');
							addRow(path, name, type,selection);
						}

						page_node = root_node[0].getElementsByTagName("page");
						if(page_node.length > 0)
						{
							hasNext = page_node[0].getAttribute('hasNext');
							if(hasNext == "1" && selection == 1) {
								document.getElementById("id_abc_pageNext").style.visibility = "visible";
                                document.getElementById("id_abc_pageNext_config").style.visibility = "hidden";
							} 
                            else if (hasNext != "1" && selection == 1){
								document.getElementById("id_abc_pageNext").style.visibility = "hidden";
                                document.getElementById("id_abc_pageNext_config").style.visibility = "hidden";
							}
                            else if(hasNext == "1" && selection == 2){
                                document.getElementById("id_abc_pageNext").style.visibility = "hidden";
                                document.getElementById("id_abc_pageNext_config").style.visibility = "visible";
                            }
                            else if(hasNext != "1" && selection == 2){
    							document.getElementById("id_abc_pageNext").style.visibility = "hidden";
                                document.getElementById("id_abc_pageNext_config").style.visibility = "hidden";
                            }
						}
						
						divABC02Browse.style.display = "";
					} else {
						divABC02Browse.style.display = "none";
					}
					
				}else {
					divABC02Browse.style.display = "none";
				}
			}else {
				divABC02Browse.style.display = "none";
			}
			
		}

		if(showPage > 0 && selection == 1) {
			document.getElementById("id_abc_pagePrev").style.visibility = "visible";
        	document.getElementById("id_abc_pagePrev_config").style.visibility = "hidden";
           
		} 
        else if(showPage <= 0 && selection == 1){
			document.getElementById("id_abc_pagePrev").style.visibility = "hidden";
	        document.getElementById("id_abc_pagePrev_config").style.visibility = "hidden";
           
		}
        else if(showPage > 0 && selection == 2){
    		document.getElementById("id_abc_pagePrev").style.visibility = "hidden";
	        document.getElementById("id_abc_pagePrev_config").style.visibility = "visible";
                   
        }
        else if(showPage <= 0 && selection == 2){
    		document.getElementById("id_abc_pagePrev").style.visibility = "hidden";
	        document.getElementById("id_abc_pagePrev_config").style.visibility = "hidden";                   
        }

		currentPath = path;
    	http_request.open('GET', '/goform/BrowseUSBFiles?path='+path+'&show_page='+showPage.toString(), true);
    	http_request.send("");
	}

  
/*

	function GetUSBOptions() {
		http_request.onreadystatechange = function()
		{
			
			if (http_request.readyState == 4) {
				if (http_request.status == 200) {
					
					// Start parsing
					var xmldoc = http_request.responseXML;
					var root_node = xmldoc.getElementsByTagName('usb_options');
					var info_node;
					if(root_node.length > 0)
					{
						info_node = root_node[0].getElementsByTagName('auto_import');
						
						var auto_import = info_node[0].getAttribute('value');
						var autoConfigImport = document.getElementById('check_auto_import');
						if(auto_import == 1) {
							autoConfigImport.checked = true;
						} else {
							autoConfigImport.checked = false;
						}

						info_node = root_node[0].getElementsByTagName('auto_export');

						var auto_export = info_node[0].getAttribute('value');
						var autoConfigExport = document.getElementById('check_auto_export');
						if(auto_export == 1) {
							autoConfigExport.checked = true;
						} else {
							autoConfigExport.checked = false;
						}
						
					}
					
				}
			}
			
		}
		
		http_request.open('GET', '/goform/GetUSBOptions', false);
		http_request.send("");
		
	}
*/


//<% net_Web_show_value("SRV_ABC02"); %>

debug = 0;
if (debug) {
	var wdatatype = { auto_load_config:3, auto_config:3, auto_log:3 };
	var wdata = [
		{ auto_load_config:1, auto__config:1, auto_log:1}
	]
}
else{
	<% net_Web_show_value("SRV_ABC02"); %>
}

var myForm, enForm;

function fnChgEnable(form)
{
	var i, fName, destForm;
	var formName = ['Export_Config', 'Export_LOG', 'file_upload', 'UpConfig', 'ABC02Options_form'];

	myForm.enable.value = enForm.enable.checked?"on":"";
	for(fName in formName){
		destForm = document.getElementById(formName[fName]);
		if(destForm){
			for(i=0;i<destForm.getElementsByTagName('input').length;i++){
			destForm.getElementsByTagName('input')[i].disabled = !enForm.enable.checked;
			}
		}
	}
	document.getElementById('ABC02Options_form').btnS.disabled=false;
	
}

function fnInit() {
	enForm = document.getElementById('ABC02OEnable');
	myForm = document.getElementById('ABC02Options_form');
	fnLoadForm(enForm, SRV_ABC02, SRV_ABC02_type);
	fnLoadForm(myForm, SRV_ABC02, SRV_ABC02_type);

	return;
}



function Activate(form)
{	
    if(button_disable == 0){
	    form.action="/goform/net_Web_get_value?SRV=SRV_ABC02";
	    form.submit();
        button_disable = 1;
    }
	
}

</script>
<style type="text/css" title="text/css">
.MOXA-INPUT-STYLIZED label.cabinet
{
width: 100px; 
height: 22px; margin-top:15px;  
background: url(image/browse_button1.gif) 0 0 no-repeat;
display: block;
overflow: hidden;
cursor: pointer;
}
.MOXA-INPUT-STYLIZED label.cabinet input.file
{
position: relative;
height: 100%; 
width: auto; 
opacity: 0; 
-moz-opacity: 0;
filter:progid:DXImageTransform.Microsoft.Alpha(opacity=0);
}
</style>
</head>
<body  onLoad="fnInit()">
<h1>Auto Backup Configurator</h1>
<fieldset>
<form name = "ABC02OEnable" id = "ABC02OEnable" method = "post" action = "">
<% net_Web_csrf_Token(); %>
    <div style="width:69.5%">
        <table>
            <tr>
                <td style = "width:100%">
                     <input type="checkbox" id="enable" name="enable" onChange='fnChgEnable(this)'> Enable
                </td>
            </tr>
        </table>
    </div>
</form>
<form name="Export_Config" id="Export_Config" method="get" action="/goform/ABC_02_MakeConfigureFile">
<div align="center">
    <table width="100%" align="center" border="0">
    	 <tr class=r0>
            <td width="26%"><div align="left">
			<script language="JavaScript">doc(Configuration_File_)</script>
            </div></td>
	         <td width="20%" colspan="3" ><div align="left"><font size="2" face="Arial, Helve<utica, sans-serif, Marlett">
                <!-- <script language="JavaScript">fnbnB(Export_,  "onClick=\"this.form.submit()\"")</script>-->
                <script language="JavaScript">fnbnB(Export_,  "onClick=\"abc_MakeAndGetCfg(this.form)\"")</script>
	         </font></div></td>
             <td width=20%> </td>
             <td width=34%> </td>
        </tr>
    </table>
</div>
</form>
<!--<form name="Export_LOG" id="Export_LOG" method="get" action="/goform/ABC_02_MakeLogFile">-->
<form name="Export_LOG" id="Export_LOG" method="get">
   <div align="center">
  
    <table width="100%" align="center" border="0">        
        <tr class=r0>
            <td width="26%"><div align="left">
            <script language="JavaScript">doc(Log_File_)</script></div></td>
	        <td width="20%" colspan="3"><div align="left">
            <!--<script language="JavaScript">fnbnB(Export_, "onMouseover=\"document.body.style.cursor='hand'\" onMouseout=\"document.body.style.cursor='default'\"  onClick=\"MakeAndGetLog() \" ")</script>-->
                <script language="JavaScript">fnbnB(Export_,  "onClick=\"MakeAndGetLog(this.form)\"")</script>
	        </div></td>
            <td width=20%> </td>
            <td width=34%> </td>
       </tr>
   	</table>
</div>
</form>
<!--<form name="file_upload" id="file_upload" method="post" action="/goform/ABC_02_fwUpload" >-->
<form name="file_upload" id="file_upload" method="post">
<% net_Web_csrf_Token(); %>
<div align="center">
    <table width="100%" align="center" border="0">
    	 <tr class=r0>
            <td width="26.5%"><div align="left">
                <script language="JavaScript">doc(Upgrade_Firmware)</script>
                </div></td>
        	<td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
            		<input name="browserButton" id="browserButton" type="button"  value="Browse" onclick="USBFileBrowserStart('/mnt/ramdisk/usb_moxa/moxa',1);" > 
        	<br></font></div></td>
            <td width="20%"><div align="left"> 
            <input id="abc02_fieldRestore" type="text" >
            <input type="text" name="pathRestore" id="id_pathRestore" value="" style="display:none;">
            </div> </td>
        	<td width="33.5%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
	        	<script language="JavaScript">fnbnB(Import_, 'onClick=clock_post(this.form)')</script>
        	</font></div></td>
        </tr>
   	</table>
</div>
</form>

<form>
<div name = "DivABCBrowse" id = "DivABCBrowse" align = "center" style = "margin-left:70px ; width:350px ; height:144px; background-color:rgb(148,252,200); display:none;">
    <div style="width:100%;height=1px;background-color:rgb(148,252,200)">
    </div>
    <div style="width:100%; height:110px; overflow-x:hidden; overflow-y:auto">
	<table id="id_ABCBrowseTable" style="width:98%; margin:1%; background-color:white; font-weight:bold;">			
	</table>
    </div>
    <div style="width:100%; height:25px">
	<table style="width:100%; background-color:rgb(148,252,200);">
	<tr>
		<td style="width:100%; text-align:center; background-color:rgb(148,252,200);">
			<input type="button" class="button" name="abc_pagePrev" id='id_abc_pagePrev' style="font-size:12px; visibility:hidden;" value="Prev" onClick="USBFileBrowserPrev(1);">
			&nbsp;
			<input type="button" class="button" name="abc_pageNext" id='id_abc_pageNext' style="font-size:12px; visibility:hidden;" value="Next" onClick="USBFileBrowserNext(1);">
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
			<input type="button" class="button" name="abc_fileSelect" style="font-size:12px;" value="Select" onClick="selectFile(1);">
		</td>
	</tr>
	</table>
    </div>    
</div>
</form>



<!--<form name="UpConfig" method="post" action="/goform/ABC_02_cfgImport">-->
<form id="UpConfig" name="UpConfig" method="post">
<% net_Web_csrf_Token(); %>
<div align="center">
    <table width="100%" align="center" border="0">
    	 <tr class=r0>
            <td width="26.5%"><div align="left">
             <script language="JavaScript">doc(Upload_Configure_Data_)</script>
             </div></td>
	        <td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
           		<input name="browserButton" id="browserButton" type="button"  value="Browse" onclick="USBFileBrowserStart('/mnt/ramdisk/usb_moxa/moxa',2);" > 
                <!--<input name="binary" id="configfile" type="file"  class="file">-->
	        <br></font></div></td>
            <td width="20%"><div align="left"> 
                <input id="abc02_fieldRestore_config" type="text" class="file" name="binary"> 
                <input type="text" name="pathRestore_config" id="id_pathRestore_config" value="" style="display:none;">
            </div> </td>
        	<td width="33.5%"><div align="left">
                <!-- <script language="JavaScript">fnbnB(Import_,  "onClick=\"this.form.submit()\"")</script>-->
                <script language="JavaScript">fnbnB(Import_,  "onClick=\"abc02_CfgImport(this.form)\"")</script> 
               
        	</div></td>
        </tr>
   	</table>
</div>
</form>


<form>
<div name = "DivABCBrowse_config" id = "DivABCBrowse_config" align = "center" style = "margin-left:70px ; width:350px ; height:144px; background-color:rgb(148,252,200); display:none;">
    <div style="width:100%;height=1px;background-color:rgb(148,252,200)">
    </div>
    <div style="width:100%; height:110px; overflow-x:hidden; overflow-y:auto">
	<table id="id_ABCBrowseTable_config" style="width:98%; margin:1%; background-color:white; font-weight:bold;">			
	</table>
    </div>
    <div style="width:100%; height:25px">
	<table style="width:100%; background-color:rgb(148,252,200);">
	<tr>
		<td style="width:100%; text-align:center; background-color:rgb(148,252,200);">
			<input type="button" class="button" name="abc_pagePrev" id='id_abc_pagePrev_config' style="font-size:12px; visibility:hidden;" value="Prev" onClick="USBFileBrowserPrev(2);">
			&nbsp;
			<input type="button" class="button" name="abc_pageNext" id='id_abc_pageNext_config' style="font-size:12px; visibility:hidden;" value="Next" onClick="USBFileBrowserNext(2);">
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
							&nbsp;
			<input type="button" class="button" name="abc_fileSelect" style="font-size:12px;" value="Select" onClick="selectFile(2);">
		</td>
	</tr>
	</table>
    </div>    
</div>
</form>

<form name = "ABC02Options_form" id = "ABC02Options_form" style = "line-height:0px" method = "post" action = "/goform/net_Web_get_value?SRV=SRV_ABC02">
<% net_Web_csrf_Token(); %>
	<input type="hidden" id="enable" name="enable">
    <div name ="DivAdvanceOptions" id="DivAdvanceOptions" style="width:69.5%">
        <table>
            <tr>
                <td style = "width:100%">
                     <input type="checkbox" id="auto_load_config" name="auto_load_config"> Auto load configuration from ABC-02-USB to system when boot up.
                </td>
            </tr>
            <tr>
                <td style = "width:100%" >
                    <input type="checkbox" id="auto_config" name="auto_config"> Auto backup to ABC-02-USB when configuration change.
                </td>
            </tr>
            <tr>
                <td style = "width:100%" >
                    <input type="checkbox" id="auto_log" name="auto_log"> Auto backup of event log to prevent overwrite.
                </td>
            </tr>
            <tr> 
                <td style = "width:100% ; height : 20px" > 
                </td>
            </tr>
            <tr>
                <td style = "width:100% ; text-align:left;">  
                    <input type="text" name="dummy_input" style="display:none" value="0">
                    <script language="JavaScript">fnbnSID(Submit_, 'onClick="fnChgEnable(this)"', 'btnS')</script>
                </td>
            </tr>
        </table>
    </div>
</form>

<div align="center">
<table width="100%" align="center" border="0" id="bar_table" >
</table>
   	<table width="100%" align="center" border="0" style="visibility:hidden" id="loadingimg" >
    	 <tr class=r1>
            <td width="35%"><div align="left">			
            </div></td>
	         <td width="67%" colspan="3"><div align="left">
	          <img style="POSITION:relative;" src="image/ajax-loader.gif"></img>
	         </div></td>
        </tr>
    </table>


</div>
<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</fieldset>
</body>
</html>       


