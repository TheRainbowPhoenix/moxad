<html>
<head>
<title></title>
<link rel="shortcut icon" href="image/favicon.ico" />
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src="md5.js"></script>
<script language="Javascript" src="net_web.js"></script>
<script language="Javascript" src="moxa_common.js"></script>
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
<script language="JavaScript" src="md5.js"></script>
{{ net_Web_file_include() | safe }}

<script language="JavaScript">
var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
checkCookie();

if (!debug) {

}else{
	{{ net_Web_show_value('SRV_EVENTLOG_MGMT') | safe }}	
}

<!--
	$(document).ready(function(){		
	
		$("body").click(function(){			
			web_cookie_update_touchLasttime();
		});

		$("body").keypress(function(){			
			web_cookie_update_touchLasttime();
		});

		$("input#capacity_threshold").change(function(){			
			var capacity_threshold = $("input#capacity_threshold").val();

			if((capacity_threshold<0) || (capacity_threshold>100) || isNaN(capacity_threshold) ){
				alert("Capacity Threshold (%) (50~100)");
				$("input#capacity_threshold").val("90");
			}
		});

		$("#CapacityWarning_enable").click(function(){			
			var checkboxVal = $("#CapacityWarning_enable").is(':checked');
			if(checkboxVal == true){
				web_enable_DOM_item("#capacity_threshold",true);
				web_enable_DOM_item("#snmp_checkbox",true);
				web_enable_DOM_item("#email_checkbox",true);				
			}else{
				web_enable_DOM_item("#capacity_threshold",false);
				web_enable_DOM_item("#snmp_checkbox",false);
				web_enable_DOM_item("#email_checkbox",false);				
			}
		});

		
		web_account_diff();
		
	});
//-->
</script>
</head>
<body>
<form name="eventlog_setting_form" method="post" action="/goform/SetEventLogManagement" target="mid" >
{{ net_Web_csrf_Token() | safe }}
<h1>Event Log Settings</h1>

<div style='width:100%;'>
<table style='width:100%;'>
	<tr>
		<td style='width:25%;'></td>
		<td style='width:20%;'></td>
		<td style='width:35%;'></td>
		<td></td>
	</tr>
	<tr><td colspan="2"><h2>{{ GetEventLogManagement(1) | safe }} Enable Log Capacity Warning at {{ GetEventLogManagement(2) | safe }} (%)</h2></td><td></td></tr>        
	<tr><td colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;Warning By:
						&nbsp;&nbsp;{{ GetEventLogManagement(3) | safe }} SNMP Trap
						&nbsp;&nbsp;{{ GetEventLogManagement(4) | safe }} Email
	</td></tr>
    
	
	<tr><td colspan="3">
		<br>
		<h2>Event Log Oversize Action : &nbsp;
			<select id="oversize_action" name="oversize_action">
				{{ GetEventLogManagement(5) | safe }}	
			</select>
		</h2>
	</td></tr>

           
</table>
</div>
<div style="width:100%; text-align:left; margin-top:25px;" >
	<script language="JavaScript">fnbnB(Submit_, 'onClick=this.form.submit()')</script>
</div>

	
</form>
</body>
</html>

