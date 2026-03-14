<!DOCTYPE html>
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<script type="text/javascript" src="../jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="../moxa_common.js"></script>
<script type="text/javascript">
<!-- 
    function _webCookie_reset(){
		Request = {
	        QueryString : function( key ){
	            var svalue = location.search.match( new RegExp( "[\?\&]" + key + "=([^\&]*)(\&?)", "i" ) );
	            return svalue ? svalue[1] : svalue;
	        }
	    };
	    
		sessionID = Request.QueryString("sid");
		if(sessionID != null){			
			web_cookie_erase("sessionID");
			web_cookie_erase("AccountName508");
			web_cookie_erase("User");
			web_cookie_create("sessionID",sessionID);		 
			web_cookie_create("AccountName508","user");		 
		}
	    
    }

    $(document).ready(function(){			
        _webCookie_reset();        
        setTimeout(function(){ window.location.replace("./packetFlow.asp");},400);
    });	
//-->
</script>
</head>
<body></body>
</html>