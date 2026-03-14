<!DOCTYPE html>
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<link rel="stylesheet" href="../bootstrap/css/bootstrap.min.css">
<script type="text/javascript" src="../jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="../moxa_common.js"></script>
<script src="../bootstrap/js/bootstrap.min.js"></script>
<% net_Web_file_include("1"); %>
<link href="../main_style.css" rel=stylesheet type="text/css">
<script type="text/javascript">
var ifs = [ {value:'all',text:'ALL'}];
<!--	
	var old_ifs=0,old_packetType=0;

	$(document).ready(function(){

		$("#ifs,#packetType_select").change(function(){	
			var ifs=0,packetType=0;

			ifs = $("#ifs").val();
			packetType = $("#packetType_select").val();
			

			if( (ifs>=0) && (ifs<=4)){
				$("#iframe_packetCount").attr("src","./packetCount_multiIfs.asp?func=" + ifs + "&type=" + packetType );
			}else{
				if(old_ports != ports){
					$("#iframe_packetCount").attr("src","./packetCount_singleIf.asp?ifs=" + (ifs-4));
				}
			}
			
			old_ifs = ifs;
			old_packetType = packetType;
			
		});		
		

	});
	
//-->
</script>
</head>
<body>
<div id='statisticsPacket_div' class="container">

	<div class="row" >
		<div class="col-xs-8 col-sm-8">
			[Format] Total Packets + Packets in past 5 secs
		</div>
		<div class="col-xs-4 col-sm-4">
			Update Interval: every 5 secs
		</div>
	</div>	

	<div class="row col-xs-12 col-sm-12" >
		<iframe marginwidth="0" id="iframe_packetCount" scrolling='no' style='overflow: hidden;border:0px; frameborder:0; width:700px; height:250px;' src="./packetCount_multiIfs.asp?func=0&type=0" ></iframe>
	</div>				
</div>   	
</body>
</html>

