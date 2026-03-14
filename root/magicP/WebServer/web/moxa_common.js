
	function web_MSGStr_cut_byte(str,maxByte){
		var length = web_getStrLength_utf8(str);
		
		if(length > maxByte){
			str = str.substr(0,str.length-1);
			length = web_getStrLength_utf8(str);
		
			if(length > maxByte){
				str = web_MSGStr_cut_byte(str,maxByte);
			}
		}		
		return str;	
	}


	function web_getStrLength_utf8(str){
	    var realLength = 0;
	    var len = str.length;
	    var charCode = -1;

	    for(var i = 0; i < len; i++){
	        charCode = str.charCodeAt(i);

			if(charCode <= 0x007f) {
                realLength += 1;
            }else if(charCode <= 0x07ff){
                realLength += 2;
            }else if(charCode <= 0xffff){
                realLength += 3;
            }else{
                realLength += 4;
            }
			
	    }
	    return realLength;
	}



	function web_enable_DOM_item(item,enable){
		if(enable == true){
			$(item).attr("disabled",false);
			$(item).css("backgroundColor","#FFFFFF");
		}else{
			$(item).attr("disabled",true);
			$(item).css("backgroundColor","#F5F5F5");
		}		
	}

	function web_cookie_create(name,value,days) {
	    if (days) {
	        var date = new Date();
	        date.setTime(date.getTime()+(days*24*60*60*1000));
	        var expires = "; expires="+date.toGMTString();
	    }
	    else var expires = "";
	    document.cookie = name+"="+value+expires+"; path=/";
	}

	function web_cookie_read(name) {
	    var nameEQ = name + "=";
	    var ca = document.cookie.split(';');
	    for(var i=0;i < ca.length;i++) {
	        var c = ca[i];
	        while (c.charAt(0)==' ') c = c.substring(1,c.length);
	        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	    }
	    return -1;
	}

	function web_cookie_erase(name) {
	    web_cookie_create(name,"",-1);
	}
		

	function web_account_diff(){		
		theData = "";
		theName = "AccountName508=";
		theCookie = document.cookie+";";
		start = theCookie.indexOf(theName);
		if(start != -1){
			end=theCookie.indexOf(";",start);
			theData = unescape(theCookie.substring(start+theName.length,end));
		}
		
		if(theData == "user"){
			$("input").each(function(){
				web_enable_DOM_item(this,false);
			});
			
			$("select").each(function(){
				web_enable_DOM_item(this,false);
			});
			
			$("textarea").each(function(){
				web_enable_DOM_item(this,false);
			});

			$("button").each(function(){
				web_enable_DOM_item(this,false);
			});


 

		}
			
	}
	var Gis_upgrading;
	
	function web_cookie_update_touchLasttime(){
		theName = "lasttime";
		expires = null;
		now=new Date( );
		document.cookie =theName + "=" + now.getTime() + "; path=/" + ((expires == null) ? " " : "; expires = " +expires.toGMTString());
	}

	function web_touchLasttime_check(){	
		var theLasttime_Data = web_cookie_read("lasttime");
		var theAuto_Logout_Time_Data = web_cookie_read("Auto-Logout_Time");
				
		if((theLasttime_Data == -1) || (theAuto_Logout_Time_Data == -1)){
			location.href="/logout.asp";
		}

		if(theAuto_Logout_Time_Data > 0){
			now = new Date();
			if(((now.getTime() - theLasttime_Data) > theAuto_Logout_Time_Data) && Gis_upgrading != 1){
				location.href="/logout.asp";
			}						
		}
		
		setTimeout("web_touchLasttime_check()", 5000);
	}


	function web_createFixedTable(ID,maxHeight,themeClassName){
            var tableHeight = $("#" + ID).height();
			if(tableHeight > maxHeight){
                $("#" + ID).fixedHeaderTable({
                                    footer:false,
                                    cloneHeadToFoot:false,
                                    fixedColumn:false,
                                    themeClass:themeClassName,
                                    height:maxHeight
                });
            }            
	}

	/* we don't need to consider Gis_upgrading, so we create web_touchLasttime_check_for_loginHistory for loginHistory.asp */
	function web_touchLasttime_check_for_loginHistory(){	
		var theLasttime_Data = web_cookie_read("lasttime");
		var theAuto_Logout_Time_Data = web_cookie_read("Auto-Logout_Time");
				
		if((theLasttime_Data == -1) || (theAuto_Logout_Time_Data == -1)){
			location.href="/logout.asp";
		}
		
		if(theAuto_Logout_Time_Data > 0){
			now = new Date();
			
			if(((now.getTime() - theLasttime_Data) > theAuto_Logout_Time_Data)){
				location.href="/logout.asp";
			}						
		}
		
		setTimeout("web_touchLasttime_check_for_loginHistory()", 5000);
		
	}