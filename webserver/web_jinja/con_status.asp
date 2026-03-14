<html>
<head>
{{ net_Web_file_include() | safe }}
<title>Connection Status</title>

<link href="./txtstyle.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
checkCookie();
function show_status()
{

    document.getElementById("myform").action="/goform/show_con_status";
    document.getElementById("myform").submit();
    
    /*
    form.action="/goform/show_con_status";
    form.submit();
    document.getElementById("con_Table").style.display="block";
    */
}
</script>
</head>
<body onload = "show_status();">

<form id=myform name=myform method="GET" action="/goform/show_con_status">
{{ net_Web_csrf_Token() | safe }}
    <div>
<!--            <iframe  id="con_Table" name="con_Table" width = "1600" height="600" src="con_Table.html" scrolling="yes" style="display:none"></iframe>
            <input type = "button" name ="button" value="Show" onclick="show_status(this.form);"> -->

    </div>

</form>
</body></html>

