<html>
<head>
<title></title>
<link rel="shortcut icon" href="image/favicon.ico" />
<script language="JavaScript" src="md5.js"></script>
<script language="Javascript" src="net_web.js"></script>
<script language="Javascript" src="moxa_common.js"></script>
{{ web_asp_home_login_set_cookie() | safe }}
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
{{ net_Web_file_include() | safe }}
<script type="text/javascript">
<!--
	function SetCookie(){
		{{ ShowTouchLasttime() | safe }}
	}
	//need to check logout time
		
	function responseDutData(xhr) {

		var response = xhr.responseXML;

		$(response).find('lastSuccessLogin').each(function() {				
			var itemTime=$(this).find('time').text();
			var itemAddress=$(this).find('address').text();
			var logoutTime=$(response).find('Auto-Logout_Time').text();
			web_cookie_create("Auto-Logout_Time",logoutTime);

			if(itemTime == ""){
				$("#current_login_content_information").hide();
			}else{			
				$("#current_login_time").html(itemTime);
				$("#current_login_address").html(itemAddress);
			}	
		});

		var index=1;
			
		$(response).find('failLogin').each(function() {				
			var itemTime=$(this).find('time').text();
			var itemAddress=$(this).find('address').text();
							
			$("#history_loginFail_time_" + index).html(itemTime);
			$("#history_loginFail_address_" + index).html(itemAddress);
			$("#history_loginFail_" + index).show();
			
			index++;
		});

		if(index>1){		
			$("#history_loginFail_content").show();
		}
			
	}

	function web_update_lastTime(){ 
		Gis_upgrading = 1;	// web server is busy on upgrading
		$.ajax({
			url:'./xml/net_led_xml.xml',
			dataType:'xml',
			cache:false,
			complete: function (xhr,status){
				
				setTimeout('web_update_lastTime();', 1000);	
			}			
		});
	}
    
    $(document).ready(function(){
    	// update lastTime by net_led_xml.xml, in order to avoid session idle timer.
    	web_update_lastTime();
		web_touchLasttime_check_for_loginHistory();
			
		var userName = web_cookie_read("NAME");
		
		if(userName == null){
			userName = "";
		}else{		
			$.ajax({
				url:'./xml/loginHistory.xml',
				dataType:'xml',
				cache:false,
				data:'queryName=' + userName,
				complete: function (xhr,status){
					if(status=="success"){
						responseDutData(xhr);
					}else{
						$("#login_content").hide();
					}					
				}			
			});
		}

		$("#current_login_name").html(userName);

		$("#clearButton").click(function(){			
			$("#action").attr("value","clearLog");			
		});

		$("#goButton").click(function(){			
			$("#action").attr("value","go");			
		});	
	});
	
-->
</script>
<STYLE>
	input {
		font-family: Verdana;
		font-size: 9pt;
		color: #000000;
	}
	body {
		font-family: Verdana;
		font-size: 10pt;
		background-color: #e5e5e5;
	}
	h2 {
		font-family: Verdana;
		font-size: 12pt;
		color: #0a51a1;
		background-color: #e5e5e5;
	}
    div.loginFailRecord {
        color: #FF0000;
    }
    
    input.button {
        font-family: "Swiss 721 BT";
        font-size: 13px;
        font-weight: bold;
        color: rgb(255, 255, 255);   
        background-color: rgb(0, 124, 100);
        width:79px; 
        height:25px; 
        background-repeat:no-repeat;
        border-style:none; 
        cursor:pointer;
        text-align: center; 
    }
</STYLE>
</head>

<body style="margin:0px" >
<form method="get" name="loginHistory_form" target="_top" action="./home.asp">
<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
		<tr height="105">
			<td>
				<table border=0 cellpadding=0 cellspacing=0 width="100%">
					<TD width="325"><IMG src="images/lup_logo1.gif" border=0></TD>
					<TD width="*" background="images/lup_logo2.gif" border=0>&nbsp;</TD>
				</table>
			</td>
		</tr>		
		<tr height="*">
			<td>
				<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
					<TD width="105" background="images/lleft_logo.gif" border=0>&nbsp;</TD>
					<td width="*">
						<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
							<tr height="33%"><td width="100%">&nbsp;</td></tr>
							<tr height="30%">
								<td width="*">
								<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
									<td width="*">&nbsp;</td>									
									<td width="450">
                                        <div id="login_content">
											<div id="current_login_content">
                                                <div>Welcome! <span id="current_login_name">user</span>.</div>
												<div id="current_login_content_information">
                                                	<div>The latest successful login time is</div>
                                                	<div>[<span id="current_login_time"></span>].</div>
                                                	<div>from <span id="current_login_address"></span></div>
												</div>
                                            </div>
                                            <div id="history_loginFail_content" class="loginFailRecord" style="position: relative; left: 0px;  top: 16px; display:none;">
                                                <div>The latest login failure record(s)</div>                                  
                                                <div id="history_loginFail_1" style='display:none;' >[<span id="history_loginFail_time_1"></span>]. from <span id="history_loginFail_address_1"></span></div>
                                                <div id="history_loginFail_2" style='display:none;' >[<span id="history_loginFail_time_2"></span>]. from <span id="history_loginFail_address_2"></span></div>
                                                <div id="history_loginFail_3" style='display:none;' >[<span id="history_loginFail_time_3"></span>]. from <span id="history_loginFail_address_3"></span></div>                                                    
                                            </div>
                                        </div>
                                        <div style="position: relative; left: 0px;  top: 32px;" >
                                          <input class="button" id="clearButton" value="Clear failure record(s) and continue" style=" width:234px; " type="submit"> <input class="button" id="goButton" value="Continue" type="submit">
                                        </div>
									</td>
									<td width="*">&nbsp;</td>
								</table>	
								</td>
							</tr>
							<tr height="37%"><td width="100%">
								<img border="0" src="images/goahead.gif" width="155" height="31"></TD></TR>
						</table>
					</td>
				</table>
			</td>
		</tr>
		<tr height="50">
			<td>
				<table border=0 cellpadding=0 cellspacing=0 width="100%">
					<TD width="105"><IMG src="images/ldown_logo1.gif" border=0></TD>
					<TD width="*" background="images/ldown_logo2.gif" border=0>&nbsp;</TD>
				</table>
			</td>
		</tr>
	</table>
	<input type="hidden" id="action" name="action" value="go">
</form>
</body>
</html>

