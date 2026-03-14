<html>
<head>
{{ net_Web_file_include() | safe }}
<link href="./main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript" src=mdata.js></script>
<script language="JavaScript">
    var ProjectModel = {{ net_Web_GetModel_WriteValue() | safe }};
	
    var http_request;
	var stat_led_status;
	var poe_led_status=new Array();

	if(window.XMLHttpRequest) { // Mozilla, Safari, ...
		http_request = new XMLHttpRequest();
	}
	else if(window.ActiveXObject) { // IE
		try {
			http_request = new ActiveXObject("Msxml2.XMLHTTP");
		} catch (e) {
			try {
				http_request = new ActiveXObject("Microsoft.XMLHTTP");
			} catch (e) { }
		}
	}

    function drawPort(port_node, leftOffset, topOffset)
    {
        var port_label, port_coordX, port_coordY;
        var port_type, port_status, port_speed, port_img_src;

        port_label  = port_node.attributes.getNamedItem('label').nodeValue;
        port_coordX = port_node.attributes.getNamedItem('coord_x').nodeValue;
        port_coordY = port_node.attributes.getNamedItem('coord_y').nodeValue;
        port_img_src= port_node.attributes.getNamedItem('img_src').nodeValue;

        var port_div = document.createElement('img');
        port_div.id             =   port_label;
        port_div.title          =   port_label;
        port_div.style.position =   "absolute";
        port_div.style.overflow =   "hidden";
        port_div.style.left     =   String(parseInt(port_coordX)+parseInt(leftOffset)+"px");
        port_div.style.top      =   String(parseInt(port_coordY)+parseInt(topOffset)+"px");
        port_div.src            =   port_img_src; 
        port_div.style.display = "";
   
        document.body.appendChild(port_div);
    }

    function drawLED(led_node, leftOffset, topOffset)
    {
        var led_label, led_coord_x, led_coord_y, led_width, led_height, led_status, led_img_src;

        led_label   = led_node.attributes.getNamedItem('label').nodeValue;
        led_coord_x = led_node.attributes.getNamedItem('coord_x').nodeValue;
        led_coord_y = led_node.attributes.getNamedItem('coord_y').nodeValue;
        led_width   = led_node.attributes.getNamedItem('width').nodeValue;
        led_height  = led_node.attributes.getNamedItem('height').nodeValue;
        led_status  = led_node.attributes.getNamedItem('status').nodeValue;
		led_img_src = led_node.attributes.getNamedItem('img_src').nodeValue;

        var led_div = document.createElement('img');
        led_div.id              =   led_label;
        led_div.title           =   led_label;
        led_div.style.position  =   "absolute";
        led_div.style.overflow  =   "hidden";
        led_div.style.left      =   String(parseInt(led_coord_x)+parseInt(leftOffset)+"px");
        led_div.style.top       =   String(parseInt(led_coord_y)+parseInt(topOffset)+"px");
        led_div.style.width     =   led_width + "px";
        led_div.style.height    =   led_height + "px";
        //led_div.style.display   ="";
        //led_div.style.backgroundColor = "#000000";
        document.body.appendChild(led_div);
        if(led_status != "0")
        {
			led_div.src = led_img_src;
			led_div.style.display = "";
        }
    }

    function refreshGetPanelStatus(http_request)
    {
        if(http_request.readyState == 4){
            if(http_request.status == 200){
                setTimeout("makeRequest('/xml/GetPanelStatus', refreshGetPanelStatus, 0);", 3000);
            }else{
                 setTimeout("makeRequest('/xml/GetPanelStatus', refreshGetPanelStatus, 0);", 3000);
            }
        }
    }

    function fnInit()
    {
	    makeRequest("/xml/GetPanelStatus", PanelStatus ,0);		
    }

    function PanelStatus(http_request)
    {
        if(http_request.readyState == 4){
            if(http_request.status == 200){
                var xmldoc=http_request.responseXML;
				var root_node = xmldoc.getElementsByTagName('panel_info');
                
                var leftOffset = 0
                var topOffset = 0;
                if(root_node.length > 0)
				{
                    var offset_node;
                    offset_node = root_node[0].getElementsByTagName('offest');
                    if(offset_node.length > 0)
                    {
                        leftOffset = offset_node[0].attributes.getNamedItem("leftOffset").nodeValue;
                        topOffset = offset_node[0].attributes.getNamedItem("topOffset").nodeValue;
                    }

   					document.getElementById('div_device').style.left = leftOffset;
					document.getElementById('div_device').style.top = topOffset;
                }
                   
                /* panel  */
				var file_node;
				var panelImg = document.getElementById('id_panelImage');
				if(root_node.length > 0)
				{
					file_node = root_node[0].getElementsByTagName('img_file');
					if(file_node.length > 0) {
						panelImg.src = file_node[0].firstChild.nodeValue;
					}
				}
                /* port */ 
                var port_node;
                var i;
                if(root_node.length > 0)
                {
                    port_node = root_node[0].getElementsByTagName('port');
                    if(port_node.length > 0)
                    {
                        for(i=0; i<port_node.length; i++)
                        {
                            drawPort(port_node[i], leftOffset, topOffset);
                        }
                    }
                }
                
				/* port speed */ 
                var port_node;
                var i;
                if(root_node.length > 0)
                {
                    port_node = root_node[0].getElementsByTagName('portspeed');
                    if(port_node.length > 0)
                    {
                        for(i=0; i<port_node.length; i++)
                        {
                            drawPort(port_node[i], leftOffset, topOffset);
                        }
                    }
                }
                
                /* led */
                var led_node;
                var led_label, led_status;
                if(root_node.length > 0){
                    led_node = root_node[0].getElementsByTagName('led_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }

                    led_node = root_node[0].getElementsByTagName('pw1_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }
                    led_node = root_node[0].getElementsByTagName('pw2_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }

                    led_node = root_node[0].getElementsByTagName('fault_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }

                    led_node = root_node[0].getElementsByTagName('master_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }

                    led_node = root_node[0].getElementsByTagName('couple_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }

					led_node = root_node[0].getElementsByTagName('vrrp_m_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }

					led_node = root_node[0].getElementsByTagName('vpn_state');
                    if(led_node.length > 0)
                    {
                        drawLED(led_node[0], leftOffset, topOffset);
                    }

                }

            }else{
                setTimeout("makeRequest('/xml/GetPanelStatus', PanelStatus, 0);", 3000);
            }
        }
    }

</script>
</head>

<body class=main onLoad=fnInit()>
    <div id="div_device" style="position:absolute;">
           <img id="id_panelImage"/>
    </div>
</body>
</html>
