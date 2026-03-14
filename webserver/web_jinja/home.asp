<html>
<head>
<link rel="shortcut icon" href="image/favicon.ico" />
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
<script language="Javascript" src="moxa_common.js"></script>
<script type="text/javascript">
	function LoginCheckAdminPasswd(){
		{{ LoginCheckAdminPasswd() | safe }}

		if(showWarning == 1){
			alert("Please change the default password in consideration of higher security level");
		}
	}
	
	$(document).ready(function(){
			setTimeout('LoginCheckAdminPasswd();', 2000);	
			web_touchLasttime_check();			
	});
</script>
</head>
<FRAMESET rows="55,60,*" frameborder="NO" border=0> 
		<FRAME name="top" scrolling="NO" target="contents" src="name.asp" noresize>
		<FRAME name="status" scrolling="NO" target="contents" src="led.asp" noresize>
		<FRAMESET cols="247,*" border=0>
    		<FRAME name="contents" target="mid" src="left.asp" noresize marginwidth="0" marginheight="0">
    		<FRAME name="mid" src="overview.asp" marginwidth="0" noresize marginheight="0" scrolling="auto">
    	</FRAMESET>
    	<NOFRAMES>
			<P>This page uses frame, but your browser doesn't support.</P>
	    </NOFRAMES>
	</FRAMESET>
</html>
