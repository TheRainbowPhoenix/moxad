function net_selectDisplay(inputSelect, inputIndex, inputID)
{
	if( typeof inputSelect == "undefined" )
   		return;
	
   var tmp = document.getElementById(inputID);
   
   if( typeof tmp == "undefined" )
   		return;
   
   if( inputIndex == inputSelect.selectedIndex ){
       tmp.style.display = "none";
   } else {
       tmp.style.display = "";
   }
   
}
            
function net_selectSet(inputSelect, token)
{
   var i, j = 0;
   
   if( typeof inputSelect == "undefined")
   		return;
   
   for(i = 0; i < inputSelect.length; i++){
        if( inputSelect[i].value == token ){
          inputSelect.selectedIndex = i;
          j++;
          break;
        }
   }
   if( 0 == j ){ 
         inputSelect.selectedIndex = 0;
   }
}
            
function net_checkedSet(inputSelect, token)
{
   var i, j = 0;
   
   if( typeof inputSelect == "undefined")
   		return;
   
        if( "ENABLE" == token )
          inputSelect.checked = true;
        else
	   inputSelect.checked = false;
}

function net_radioDisplay(inputRadio, inputIndex, inputID)
{
   var tmp = document.getElementById(inputID);
   if( true == inputRadio[inputIndex].checked ){
       tmp.style.display = "none";
   } else {
       tmp.style.display = "";
   }
   
}

function net_radioSet(inputRadio, token)
{
    var i, j = 0;
    
    if( typeof inputRadio == "undefined")
   		return;
    
    for( i = 0; i < inputRadio.length; i++ ){
        if( inputRadio[i].value == token ){
          inputRadio[i].checked = true;
          j++;
          break;
        }                  
    }
    if( 0 == j ){
         inputRadio[0].checked = true;
    }
}

function net_checkDisplay(inputCheck, inputID)
{
	if( typeof inputCheck == "undefined" )
   		return;
	
   var tmp = document.getElementById(inputID);
   
   if( typeof tmp == "undefined" )
   		return;
   
   if( true == inputCheck.checked ){
       tmp.style.display = "none";
   } else {
       tmp.style.display = "";
   }
}

function net_checkSet(inputCheck, token)
{
	if( typeof inputCheck == "undefined" )
   		return;
	
    if( token == inputCheck.value ){
        inputCheck.checked = true;
    } else {
        inputCheck.checked = false;
    }
    
}

/*
ajax basic routines
*/
function net_inithttpreq()
{
	var http_req = false;
	
	try {  http_req = new ActiveXObject('Msxml2.XMLHTTP');   }
	catch (e) 
	{
		try {   http_req = new ActiveXObject('Microsoft.XMLHTTP');    }
		catch (e2) 
		{
			try {  http_req = new XMLHttpRequest();     }
			catch (e3) {  http_req = false;   }
		}
	}
	
	return http_req;
}