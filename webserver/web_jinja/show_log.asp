<html>
<head>
{{ net_Web_file_include() | safe }}

<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
if (!debug) {
	var moxaLog = [
		{index:'1', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'2', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'3', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'4', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'5', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'6', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'7', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'8', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'9', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'},
		{index:'10', date:'2009/03/24', time:'01:42:00', event:'WAN1 link on'}
	];
	
var selpage0 = [
	{ value:0, text:'Page 1/2' },	{ value:1, text:'Page 2/2' }
	];			
}else{
	{{ net_showMoxaLog() | safe }}
}

var MoxaLogRange = [{ value:0, text:'<=' },{ value:1, text:'==' },{ value:2, text:'>=' }];

var seliface_page = { type:'select', id:'seliface_page', name:'seliface_page', size:1, onChange:'fnFreshPage()', option:MoxaLogPage };
var seliface_category = { type:'select', id:'seliface_category', name:'seliface_category', size:1, onChange:'fnFreshPage()', option:MoxaLogCategory };
var seliface_level = { type:'select', id:'seliface_level', name:'seliface_level', size:1, onChange:'fnFreshPage()', option:MoxaLogLevel };
var seliface_range = { type:'select', id:'seliface_range', name:'seliface_range', size:1, onChange:'fnFreshPage()', option:MoxaLogRange };

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


function MakeAndGetMoxaLog(){
	var category_idx;
	var category = document.getElementById("seliface_category").value;

	for(category_idx = 0; category_idx < MoxaLogCategory.length; category_idx++ ){
		if(category == MoxaLogCategory[category_idx].value)
			break;
	}

	if(MoxaLogCategory[category_idx].text == 'All')
		file_name = '/MOXA_'+MoxaLogCategory[category_idx].text+'_LOG.tar.gz';
	else if(MoxaLogCategory[category_idx].text == 'VPN')
		file_name = '/MOXA_IPSec_LOG.ini';
	else if(MoxaLogCategory[category_idx].text == 'System')
		file_name = '/MOXA_LOG.ini';
	else
		file_name = '/MOXA_'+MoxaLogCategory[category_idx].text+'_LOG.ini';

	var link_path = "/goform/net_MakeMoxaLogFile?show_category="+category;
	
	makeRequest(link_path, MakeContents ,0);
	
}	

function fnFreshPage() {		
	var page = document.getElementById("seliface_page").value;
	var range = document.getElementById("seliface_range").value;
	var level = document.getElementById("seliface_level").value;
	var category = document.getElementById("seliface_category").value;
	
	location.href="show_log.asp?show_page="+page+"&show_range="+range+"&show_level="+level+"&show_category="+category;	
}

function fnDeleteLog(page) {		
	
	var range = document.getElementById("seliface_range").value;
	var level = document.getElementById("seliface_level").value;
	var category = document.getElementById("seliface_category").value;

	var category_idx;
	
	for(category_idx = 0; category_idx < MoxaLogCategory.length; category_idx++ ){
		if(category == MoxaLogCategory[category_idx].value)
			break;
	}

	if(page==-1&&!window.confirm('Delete '+MoxaLogCategory[category_idx].text+' log?')){
		return;
	}
	location.href="show_log.asp?show_page="+page+"&show_range="+range+"&show_level="+level+"&show_category="+category;	
}

function setSelectValue()
{
	//alert("category="+moxaLogSelectValue.categoryValue+" level="+moxaLogSelectValue.levelValue+" page="+moxaLogSelectValue.pageValue);

	document.getElementById("seliface_page").value = moxaLogSelectValue.pageValue;
	document.getElementById("seliface_range").value = moxaLogSelectValue.rangeValue;
	document.getElementById("seliface_level").value = moxaLogSelectValue.levelValue;
	document.getElementById("seliface_category").value = moxaLogSelectValue.categoryValue;
}

function fnInit() {	
	var i;

	setSelectValue();
	
	if(moxaLog[0].index == 0)
		return;
	table = document.getElementById("show_table");	
	for(i = 0; i < moxaLog.length; i++ ){				
		row = table.insertRow(table.getElementsByTagName("tr").length);
		if((i%2) > 0)
			row.className="odd";
		else
			row.className="even";
		
		for(idx in moxaLog[0]){	
			cell = document.createElement("td");
			if(idx == "level")
				cell.innerHTML = fnGetSelText(moxaLog[i][idx], MoxaLogLevel);
			else if(idx == "category")
				cell.innerHTML = fnGetSelText(moxaLog[i][idx], MoxaLogCategory);
			else
				cell.innerHTML = moxaLog[i][idx];		
			row.appendChild(cell);
			row.style.Color = "black";
			row.align="center";
		}
	}

	
	//document.getElementById("seliface_category").value = moxaLogIdx.categoryIdx;
}

function stopSubmit()
{
	return false;
}
</script>
</head>
<body onLoad=fnInit()>
<h1>
 <script language="JavaScript">doc(Event_);</script> 
 <script language="JavaScript">doc(Log_);</script> 
 <script language="JavaScript">doc(Table_);</script>
</h1>

<fieldset>
<form id=myForm name=form1 method="POST" onSubmit="return stopSubmit()">
{{ net_Web_csrf_Token() | safe }}
<input type="hidden" name="static_tmp" id="statictmp" value="" >
<table>
<tr>
 <td><script language="JavaScript">fnGenSelect(seliface_category, ((moxaLog[0].index-1)/20)+1)</script></td>
 <td><script language="JavaScript">fnGenSelect(seliface_range, ((moxaLog[0].index-1)/20)+1)</script></td>
 <td><script language="JavaScript">fnGenSelect(seliface_level, ((moxaLog[0].index-1)/20)+1)</script></td>
 <td><script language="JavaScript">fnGenSelect(seliface_page, ((moxaLog[0].index-1)/20)+1)</script></td>
<tr> 
</table>
<table cellpadding=1 cellspacing=2 id="show_table" style="width:810px">
 <tr align="center" width=760px>
  <th width=50px><script language="JavaScript">doc(Index_)</script></th>
  <th width=60px><script language="JavaScript">doc(Date_)</script></th>
  <th width=60px><script language="JavaScript">doc(Time_)</script></th> 
  <th width=60px><script language="JavaScript">doc(Functions_)</script></th> 
  <th width=110px><script language="JavaScript">doc(Severity_)</script></th> 
  <th width=400px><script language="JavaScript">doc(Event_)</script></th> </tr>
</table></tr>

<table align=left border=0>
<tr style="height:50px"></tr>
</table>

<p><table align=left>
 <tr>
  <td><script language="JavaScript">fnbnB(Refresh_, 'onClick=fnFreshPage()')</script></td>
  <td><script language="JavaScript">fnbnS(Export_, 'onClick=MakeAndGetMoxaLog()')</script></td>
  <td><script language="JavaScript">fnbnS('Clear', 'onClick=fnDeleteLog(-1)')</script></td>
 </tr>
</table></p>

</form>
</fieldset>

<script language="JavaScript">mainl()</script>
<script language="JavaScript">bodyl()</script>
</body></html>

