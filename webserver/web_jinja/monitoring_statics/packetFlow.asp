<!DOCTYPE html>
<html>
<head>
<title></title>
<link rel="stylesheet" href="../bootstrap/css/bootstrap.min.css">
<script type="text/javascript" src="../JSON-js/json2.js"></script>
<script type="text/javascript" src="../jquery-1.11.1.min.js"></script>
<script type="text/javascript" src="../jquery.sparkline.min.js"></script>
<script type="text/javascript" src="../jstorage.js"></script>
<script src="../bootstrap/js/bootstrap.min.js"></script>
<script src="../moxa_common.js"></script>
{{ net_Web_file_include("1") | safe }}
<link href="../main_style.css" rel=stylesheet type="text/css">
<script language="JavaScript">

var ifs = [ {{ net_Web_Filter_IFS_WriteValue() | safe }} ];
var brg_ifs	= [ {{ net_Web_NAT_show_brgIfs_WriteValue() | safe }} ];
var ports = [ {{ net_Web_STATUS_PORTSS_WriteValue() | safe }} ];

var if_packet_type_sel   = [{ value:'0',text:'All' }, { value:'4',text:'Error' }];
var port_packet_type_sel = [{ value:'0',text:'All' }, { value:'1',text:'Unicast' }, { value:'2',text:'Broadcast' }, { value:'3',text:'Multicast' }, { value:'4',text:'Error' }];

var kv_if_packet_type_sel   = {'All pkts':'0', 'Error pkts':'4'}
var kv_port_packet_type_sel = {'All pkts':'0', 'Unicast':'1', 'Broadcast':'2', 'Multicast':'3', 'Error pkts':'4'}

var count_base=[{},{},{},{},{},{},{},{}];

	var colorArray = ["red","blue","purple","green","Brown","#000000","#EEEE00","#808080"];
	var xmlData = new Array(10);


	function _XMLbasicResponse_interface(response, lineidx, setifname, sniffMode, packetType, displayMode) {
		var packet_type_srt=["Packet", "UnicastPacket", "BroadcastPacket", "MulticastPacket", "ErrPacket"];		
		var idx, v;
		count_base[lineidx]["ALL"]=0;

		$(response).find("interface").each(function(idx, v) {
			if(displayMode==1){
				if(packetType == 0){
					count_base[lineidx][$(v).find("name").text()]=0;
					if(sniffMode !=2){
						count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("TXPacket").text());
					}

					if(sniffMode !=1){
						count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("RXPacket").text());
					}
				}
			}else{
				count_base[lineidx][$(v).find("name").text()]=0;
				if(sniffMode !=2){
					count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("TXBytes").text());
				}

				if(sniffMode !=1){
					count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("RXBytes").text());
				}
			}
			
			
			if(count_base[lineidx][$(v).find("name").text()]){
				count_base[lineidx]["ALL"]+=parseInt(count_base[lineidx][$(v).find("name").text()]);
			}
	    });

		$(response).find("port").each(function(idx, v) {
			if(displayMode==1){
				count_base[lineidx][$(v).find("name").text()]=0;
				if(sniffMode !=2){
					count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("TX"+packet_type_srt[packetType]).text());
				}

				if(sniffMode !=1){
					count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("RX"+packet_type_srt[packetType]).text());
				}				
			}else{
				count_base[lineidx][$(v).find("name").text()]=0;
				if(sniffMode !=2){
					count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("TXBytes").text());
				}

				if(sniffMode !=1){
					count_base[lineidx][$(v).find("name").text()] += parseInt($(v).find("RXBytes").text());
				}
			}
			
			
			//alert("if="+$(v).find("name").text()+" count="+count_base[lineidx][$(v).find("name").text()]);
			//count_base[lineidx]["ALL"]+=count_base[lineidx][$(v).find("name").text()];
	    });
		
		//alert("2count_base["+lineidx+"][all]="+count_base[lineidx]["ALL"]);
	  	//alert(JSON.stringify(count_base));
	}
	

	 function statisticscPacketsBase_get(lineidx, setifname, sniffMode, packetType, displayMode){
    	var interfaceUrl='../xml/counter.xml';
				
		$.ajax({
			url:interfaceUrl,
			dataType:'xml',
			cache:false,
			timeout:10000,
			async: false,
			success: function (response){
					_XMLbasicResponse_interface(response, lineidx, setifname, sniffMode, packetType, displayMode);
			},
		});		
    }

    function ConstructLineData(LineID,linkStatus,portName,currentIndexOfData,LineOption){
        var pushCount = currentIndexOfData;

        this.LineID = LineID;
        this.linkStatus = linkStatus;
        this.portName = portName; 
        this.LineOption = LineOption;
        this.PacketData = new Array();


		if(pushCount<1){
			//Add start point.
        	this.PacketData.push(0);
        }else{
        	//Add start point and data point.
	        for(var i = 0 ; i <= pushCount ; i++){
	            this.PacketData.push(null);
	        }
        }   

		return this;                       
    }

	function ConstructLineID(lineIndex,displayType,queryIndex,sniffMode,packetType){
		this.lineIndex = lineIndex;
		this.displayType = displayType;
		this.queryIndex = queryIndex;
		this.sniffMode = sniffMode;
		this.packetType = packetType;

		this.equals = function(LineID,displayMode){

			if(
				(this.displayType == LineID.displayType) &&
				(this.queryIndex == LineID.queryIndex) &&
				(this.sniffMode == LineID.sniffMode)
			){
				if(displayMode == 1){
					if (this.packetType == LineID.packetType){
						return true;
					}
				}else{
					return true;
				}
			}
			return false;
		};

		return this;
	}

	function ConstructXmlData(linkStatus,portName,packet,displayMode){
        this.linkStatus = linkStatus;
        this.packet = packet;
        this.portName = portName;
        this.displayMode = displayMode;

		return this;                      
    }

    function ResetPortCount(){				
		$.ajax({
			url:'../goform/ResetStatisticCnt',
			dataType:'html',
			cache:false,			
		});				
    }
	
	function _XMLresponse_port(response, Panel_obj) {
		var lineNum = $(response).find('ID').attr('lineNum');
		var displayMode = $(response).find('Packet').attr('displayMode');
		var linkStatus, packet_tmp, selName, lineIndex, speed;
		var packet, tempData;
		
		for(var i=0; i<=lineNum; i++){
			linkStatus = $(response).find('Info').attr('linkStatus'+i);
			packet_tmp = $(response).find('Packet').attr('packetRate'+i);
			selName = $(response).find('Info').attr('selName'+i);
			lineIndex = $(response).find('ID').attr('lineIndex'+i);
			speed = $(response).find('Info').attr('speed'+i)*1000000;
		
			//count packet per second
			packet = packet_tmp - count_base[i][selName];
			if(displayMode==0){
				packet /= speed * Panel_obj.options.DataUpdateTime_inSec / 100;// 5 for 5 secs, 100 for percentage
				if(packet < 0.01){
					packet = 0;
				}
			}
			tempData = new ConstructXmlData(linkStatus,selName,packet,displayMode);
			count_base[i][selName] = packet_tmp;
			xmlData[i] = tempData;
			/*console.log('xmlData:'+i+
						';linkStatus:'+xmlData[i].linkStatus+
						';selName:'+xmlData[i].portName+
						';packet:'+xmlData[i].packet+
						';displayMode:'+xmlData[i].displayMode
			);*/
		}
		_panelDataUpdate(Panel_obj);
	}

	
	var counter=0;
	function _panelData_get(Panel_obj){
		var LineDataArray = Panel_obj.status.LineDataArray;

		var LineIndexArr =[], QueryIndexArr =[], SniffModeArr =[], PacketTypeArr =[], displayTypeArr =[];
		var PortFlag = 0, lineNum = 0;
		for(var LineIndex in LineDataArray){
			if(LineDataArray[LineIndex].LineID.displayType == 0){
				PortFlag = 1;
			}
			LineIndexArr.push(LineDataArray[LineIndex].LineID.lineIndex);
			QueryIndexArr.push(LineDataArray[LineIndex].LineID.queryIndex);
			SniffModeArr.push(LineDataArray[LineIndex].LineID.sniffMode);
			PacketTypeArr.push(LineDataArray[LineIndex].LineID.packetType);
			displayTypeArr.push(LineDataArray[LineIndex].LineID.displayType);
			lineNum = LineIndex;
		}
		var LineIndexStr = LineIndexArr.toString();
		var QueryIndexStr = QueryIndexArr.toString();
		var SniffModeStr = SniffModeArr.toString();
		var PacketTypeStr = PacketTypeArr.toString();
		var displayTypeStr = displayTypeArr.toString();
		/*console.log('LineIndexStr:'+LineIndexStr+
					';QueryIndexStr:'+QueryIndexStr+
					';SniffModeStr:'+SniffModeStr+
					';PacketTypeStr:'+PacketTypeStr+
					';displayTypeStr:'+displayTypeStr);*/
		counter++;
		$.ajax({
			url:'../xml/PacketFlowCounter.xml',
			dataType:'xml',
			cache:false,
			timeout:10000,
			data:{
					displayMode:Panel_Func.options.displayMode,
					portFlag: PortFlag,
					lineNum: lineNum,
					counter: counter,
					lineIndex:  LineIndexStr,
					queryIndex: QueryIndexStr,
					sniffMode: SniffModeStr,
					packetType: PacketTypeStr,
					displayType: displayTypeStr
				  },
			success: function (response){
				//console.log('response success');
				_XMLresponse_port( response, Panel_obj);
			},
			error: function(xhr, status, error) {
				//console.log('response fail');
            }   
		});
    }


    var NowMaxPacket = 100;

    function _panelDataUpdate(Panel_obj){
        var options = Panel_obj.options;
        var status  = Panel_obj.status;   

        for(LineIndex in status.LineDataArray){
			if(xmlData[LineIndex].displayMode != options.displayMode ){ //condition: is before mode change data
				continue;
			}
			
            if((status.IndexOfData+1)>options.MaxDisplayData){
                status.LineDataArray[LineIndex].PacketData.shift();                                        
            }
            
            status.LineDataArray[LineIndex].PacketData.push(xmlData[LineIndex].packet);
            status.LineDataArray[LineIndex].linkStatus = xmlData[LineIndex].linkStatus;
			//alert("xmlData[LineIndex].portName="+xmlData[LineIndex].portName);
			if(xmlData[LineIndex].portName != "" ){
				status.LineDataArray[LineIndex].portName = xmlData[LineIndex].portName;
			}

            if( options.displayMode == 1 ){
				if( parseInt (xmlData[LineIndex].packet) > parseInt( status.MaxDataRange) ){
                	status.MaxDataRange = parseInt(xmlData[LineIndex].packet);
					NowMaxPacket =  parseInt(xmlData[LineIndex].packet);
                }            
			}
        }

        //clear data.        
        xmlData.length=0;

        if(status.IndexOfData < options.MaxDisplayData){
            status.IndexOfData++;
        }
        
		status.AmountOfData++;
	}

    function canvasDatasetUpdate(Panel_obj){
        _panelData_get(Panel_obj);
	}    

	function _toMMSS(time_inSec) {
	    var sec_num = time_inSec;
	    var hours   = Math.floor(sec_num / 3600);
	    var minutes = Math.floor((sec_num - (hours * 3600)) / 60);
	    var seconds = sec_num - (hours * 3600) - (minutes * 60);

	    if (minutes < 10) {minutes = "0"+minutes;}
	    if (seconds < 10) {seconds = "0"+seconds;}
	    var time    = minutes+':'+seconds;
	    return time;
	}
        
    function canvasTipDisplay(Panel_obj){
        var options = Panel_obj.options;
        var status  = Panel_obj.status;            
		var TotalLineData =	status.AmountOfData;
		var MaxLineData = options.MaxDisplayData;
		var DataUpdateTimer_inSec =	options.DataUpdateTime_inSec;
        
        var Axis_x_range = (MaxLineData/4);
		var Axis_x_base;

		var Axis_x_range;
		var Axis_x_base;
		var Axis_y_base_digit;
		var Axis_y_base_width = -25;

		if(TotalLineData < MaxLineData){
			Axis_x_base = 0;
		}else{
			Axis_x_base = TotalLineData - MaxLineData;
		}
		
		if(Panel_obj.options.displayMode == 0){
			Axis_y_base = 100;
			$("#Axis_Y_All").css("left","-25px");
		}
		else{
			Axis_y_base = ( Math.ceil(NowMaxPacket / 4) ) * 4;
			Axis_y_base_digit = Axis_y_base.toString().length;
			if(Axis_y_base_digit > 3){
				Axis_y_base_width = -25 + (-8 *(Axis_y_base_digit - 3));
				$("#Axis_Y_All").css("left",+Axis_y_base_width+"px");
			}
		}

		Axis_y_range = (Axis_y_base/4);
        for(var x=0;x<5;x++){
			$("#Axis_X_" + (x+1) ).html( _toMMSS( ( Axis_x_base + Axis_x_range * (x)) * DataUpdateTimer_inSec )  );
			$("#Axis_Y_" + (x+1) ).html(Axis_y_base - Axis_y_range * (x));
		}
    }

    function canvasLineDisplay(Panel_obj,force){
        var intialData =[null];
        var tooltipTitleString,portNameString,LineID;
        var options = Panel_obj.options;
        var status  = Panel_obj.status;
        var sparkline_initialOption = Panel_obj.sparkline_initialOption;        
        var widthValue = Math.floor( options.PWidth / (options.MaxDisplayData - 1)) * (status.IndexOfData);


		if( (status.AmountOfData<=0) && (force == false) ){
			return;
		}
        
        if(widthValue >= options.PWidth){
            widthValue = options.PWidth;           
        }

		options.sparkline_initialOption.width = widthValue;
		options.sparkline_initialOption.height= options.PHeight;
        options.sparkline_initialOption.chartRangeMin = parseInt(status.MinDataRange);
        options.sparkline_initialOption.chartRangeMax = parseInt(status.MaxDataRange);
                  
        $("#" + Panel_obj.ID ).sparkline(intialData,options.sparkline_initialOption);
        
        for(LineIndex in status.LineDataArray){
			LineID = status.LineDataArray[LineIndex].LineID ;
			tooltipTitleString =  TooltipTitle(status.LineDataArray[LineIndex].linkStatus,LineID.displayType,status.LineDataArray[LineIndex].portName);				
			
			status.LineDataArray[LineIndex].LineOption.tooltipChartTitle = tooltipTitleString;
			status.LineDataArray[LineIndex].LineOption.chartRangeMax = parseInt(status.MaxDataRange);

			$("#" + Panel_obj.ID ).sparkline(status.LineDataArray[LineIndex].PacketData,status.LineDataArray[LineIndex].LineOption);
			if(AddNewLineFlag == 1){
				/*console.log('AddNewline lineColor: '+status.LineDataArray[LineIndex].LineOption.lineColor+
				',tooltipChartTitle: '+status.LineDataArray[LineIndex].LineOption.tooltipChartTitle+
				',tooltipPrefix: '+status.LineDataArray[LineIndex].LineOption.tooltipPrefix+
				',LineIndex: '+LineIndex);*/
				if(LineIndex == 0){
					$('#Axis_item ul').empty();
				}
				$('#Axis_item ul').append('<li><div id="circle" style="background-color: '+status.LineDataArray[LineIndex].LineOption.lineColor+'"></div>'
				+'<span>'+status.LineDataArray[LineIndex].LineOption.tooltipChartTitle
				+'&nbsp;'+status.LineDataArray[LineIndex].LineOption.tooltipPrefix.slice(0,-1)+'</span></li>');
			}
		}
		AddNewLineFlag = 0;
    }

    function canvasRefresh(Panel_obj,force){
    	canvasTipDisplay(Panel_obj);
    	canvasLineDisplay(Panel_obj,force);
    }
		
	function TooltipTitle(linkStatus,displayType,NameString){
		var tooltipTitleString,displayTypeString;
		var linkStatusString;
	
		if(linkStatus == 0){
			linkStatusString = "Link down - ";
		}else if(linkStatus == 1){
			linkStatusString = "Link up - ";
		}else{
			linkStatusString = "";
		}

		if(displayType == 0){
			displayTypeString = "Ports(";
		}else{				
			displayTypeString = "Interface(";
		}

		if(NameString == "ALL"){
			tooltipTitleString = linkStatusString + displayTypeString + "All" + ")";
		}else{
			tooltipTitleString = linkStatusString + displayTypeString + NameString + ")";
		}
		return tooltipTitleString;

	}

	function TooltipPrefix(displayMode,sniffMode,packetType){
		var sniff_selectString = $('#sniff_select :eq(' + sniffMode + ')').text();
		//var packet_selectString = $('#packet_select :eq(' + packetType + ')').text();
		var packet_selectString = $('#packet_select').find(":selected").text()
		var tooltipPrefixString;

		tooltipPrefixString = sniff_selectString + "(" + packet_selectString + ")" + ":";
		
		/*if(displayMode == 0){
			tooltipPrefixString = sniff_selectString + ":";				
		}else{
			if( (sniffMode!=0) || (packetType!=0)) {
				if( (sniffMode!=0) && (packetType!=0)){
					tooltipPrefixString = sniff_selectString + "." + packet_selectString + ":";
				}else if( (sniffMode!=0)){
					tooltipPrefixString = sniff_selectString + ":";
				}else{
					tooltipPrefixString = packet_selectString + ":";
				}
			}else{
				tooltipPrefixString = "All:";
			}
		}*/
		return tooltipPrefixString;
	}

	function TooltipSuffix(displayMode){
		var tooltipSuffixString;

		if(displayMode == 1){
			tooltipSuffixString = '&#32;Packets';
		}else{
			tooltipSuffixString = '&#32;&#37;';
		}

		return tooltipSuffixString;

	}

	function LineID_get(lineIndex){
		var ports_select = $("#ports_select").val();
		var interface_select = $("#ifs option:selected").text();
		var sniff_select = $("#sniff_select").val();
		var packet_select = $("#packet_select").val();
		var displayMode_radio,displayType_radio,queryIndex;


		if($("#displayMode_radioUtilization").prop("checked")== true ){
			displayMode_radio = 0 ;
		}else{
			displayMode_radio = 1 ;
		}

		if($("#settingPanel_displayType_radioPorts").prop("checked")== true ){
			displayType_radio = 0 ;
			queryIndex = ports_select;
		}else{
			displayType_radio = 1 ;
			queryIndex = interface_select;
		}

		var retLineID = new ConstructLineID(lineIndex,displayType_radio,queryIndex,sniff_select,packet_select);

		return retLineID;

	}
	
	function cookie_saveConfig(Panel_obj){		
		$.jStorage.set("PacketFlowConfig",Panel_obj);			
	}

	function cookie_loadConfig(Panel_obj){
		var config_obj	= $.jStorage.get("PacketFlowConfig","n/a");

		if(0 ){			
			$.extend(true,Panel_obj,config_obj);			

			var LineID = new ConstructLineID(0,1,"ALL",0,0);
			for(LineIndex in Panel_obj.status.LineDataArray){
				//to extend method,because jStorage can't backup method.
				$.extend(LineID,Panel_obj.status.LineDataArray[LineIndex].LineID);
				$.extend(Panel_obj.status.LineDataArray[LineIndex].LineID,LineID);
	        }
			return true;
		}else{
			return false;
		}

	}

	function cookie_eraseConfig(){
		$.jStorage.deleteKey("PacketFlowConfig");
	}

	function PanelConfig_intial(Panel_obj){
        var options = Panel_obj.options;
        var status  = Panel_obj.status;

		if(status.NumberOfLines != 0 ){ //condition: not default config
			status.MaxDataRange = 100;		
			status.IndexOfData = 0 ;
			status.AmountOfData = 0 ;

			for(LineIndex in status.LineDataArray){ 	    
				status.LineDataArray[LineIndex].PacketData.length = 0;
				
				//Add start point.
				status.LineDataArray[LineIndex].PacketData.push(0);
	        }
		}else{
			statisticscPacketsBase_get(0, "ALL", 0, 0, options.displayMode);
			
			status.NumberOfLines = 1 ;
			status.IndexOfData = 0 ;
			status.AmountOfData = 0 ;
			status.MaxDataRange = 100;
			status.LineDataArray.length = 0;
			status.LineDataArray = new Array();
	
			/* Add default line */
			var LineID = new ConstructLineID(0,1,"ALL",0,0);
			var nameString = "ALL";
			var tooltipTitleString =  TooltipTitle(-1,LineID.displayType,nameString);				
			var tooltipPrefixString = TooltipPrefix(options.displayMode,LineID.sniffMode,LineID.packetType);
			var tooltipSuffixString = TooltipSuffix(options.displayMode);			
			var color_select = colorArray[status.NumberOfLines-1];
			var NewlineData = new ConstructLineData(LineID,-1,nameString,status.IndexOfData,{ 
				composite: true,
				type: 'line',
				lineColor: color_select, 
				chartRangeMin: status.MinDataRange, 
				chartRangeMax: status.MaxDataRange,				
				fillColor: false,           
				minSpotColor: false,
				maxSpotColor: false,
				tooltipChartTitle : tooltipTitleString,
				tooltipPrefix : tooltipPrefixString,
				tooltipSuffix : tooltipSuffixString,
				spotRadius: 2,
		        disableHighlight : false,
			});
			status.LineDataArray.push(NewlineData);
			cookie_saveConfig(Panel_obj);
		}
	}

	function LinePanel_Construct(Panel_obj){ // web intial function		
		cookie_loadConfig(Panel_obj);
        PanelConfig_intial(Panel_obj);
			
	}

	function LinePanel_Destruct(Panel_obj){	//reset button handler		
		/* re-intial  */
		cookie_eraseConfig();
		Panel_obj.status.NumberOfLines = 0;
		Panel_obj.options.displayMode = 1;
		PanelConfig_intial(Panel_obj);
		AddNewLineFlag = 1;
		canvasRefresh(Panel_obj,true);	
	}

	function LinePanel_ModeChange(Panel_obj,displayMode){ // mode change radio handler
		cookie_eraseConfig();
		Panel_obj.status.NumberOfLines = 0;
		Panel_obj.options.displayMode = displayMode;
		PanelConfig_intial(Panel_obj);
		AddNewLineFlag = 1;
		canvasRefresh(Panel_obj,true);	

	}


	function LinePanel_Refresh(Panel_obj){ //refresh button handler
		var options = Panel_obj.options;
        var status  = Panel_obj.status;
		var tooltipSuffixString	= TooltipSuffix(Panel_obj.options.displayMode);
		var TooltipPrefixString,LineID;
		
		status.AmountOfData = 0;
		status.IndexOfData = 0;        		
		status.MaxDataRange = 100;
		
		for(LineIndex in status.LineDataArray){		
            status.LineDataArray[LineIndex].LineOption.chartRangeMax = parseInt(status.MaxDataRange);
			status.LineDataArray[LineIndex].LineOption.tooltipSuffix = tooltipSuffixString;
			status.LineDataArray[LineIndex].PacketData.length = 0;

			LineID = status.LineDataArray[LineIndex].LineID;
			TooltipPrefixString = TooltipPrefix(options.displayMode,LineID.sniffMode,LineID.packetType)
			status.LineDataArray[LineIndex].LineOption.tooltipPrefix = TooltipPrefixString;
		}
		NowMaxPacket = 100;
		$("#Axis_Y_All").css("left","-25px");
		canvasRefresh(Panel_obj,true);
	}

    
    function LinePanel_Update(Panel_obj) {        
		canvasDatasetUpdate(Panel_obj);
		canvasRefresh(Panel_obj,false);
        //setTimeout(function(){ canvasRefresh(Panel_obj,false);},2500);
		setTimeout(function(){ LinePanel_Update(Panel_obj);} ,Panel_obj.options.DataUpdateTime_inSec * 1000);
    }

	var AddNewLineFlag = 1;

    function LinePanel_Newline(Panel_obj){ // add new line button handler
        var options = Panel_obj.options;
        var status  = Panel_obj.status;
		var tooltipTitleString,tooltipPrefixString,tooltipSuffixString;
		var LineID;

		if((status.NumberOfLines+1) > options.MAXNumberOfLines){
			alert("Exceed the max. numbers ("+options.MAXNumberOfLines+") of line display. To add new lines, please reset the existing settings.");
			return;
		}

		//from setting panel.
		LineID = LineID_get(status.NumberOfLines);

		for(LineIndex in status.LineDataArray){
            if(status.LineDataArray[LineIndex].LineID.equals(LineID,options.displayMode)== true){
				alert("This line is existed."); 
				return;
            } 
        }

		status.NumberOfLines++;
		if(LineID.displayType == 0 ){
			portNameString = $("#ports_select option:selected").text();
		}else{
			portNameString = $("#ifs option:selected").text();
		}

		//alert("status.NumberOfLines="+status.NumberOfLines);
		statisticscPacketsBase_get(status.NumberOfLines-1, portNameString, LineID.sniffMode, LineID.packetType, options.displayMode);
		tooltipTitleString =  TooltipTitle(-1,LineID.displayType,portNameString);
		tooltipPrefixString = TooltipPrefix(options.displayMode,LineID.sniffMode,LineID.packetType);
		tooltipSuffixString = TooltipSuffix(options.displayMode);
		
		color_select = colorArray[status.NumberOfLines-1];
		var NewlineData = new ConstructLineData(LineID,-1,portNameString,Panel_obj.status.IndexOfData,{ 
			composite: true,
			type: 'line',
			lineColor: color_select, 
			chartRangeMin: status.MinDataRange, 
			chartRangeMax: status.MaxDataRange,				
			fillColor: false,           
			minSpotColor: false,
			maxSpotColor: false,
			tooltipChartTitle : tooltipTitleString,
			tooltipPrefix : tooltipPrefixString,
			tooltipSuffix : tooltipSuffixString,
	        disableHighlight : true,			
		});
		status.LineDataArray.push(NewlineData);
		cookie_saveConfig(Panel_obj);
		AddNewLineFlag = 1;
    }

    var Panel_Func ={
    	ID:'drawLine_canvas',
		options   :{
			PWidth: 600,
			PHeight: 300,
			displayMode : 1, // 0 for utilization , 1 for packet
			MAXNumberOfLines:8, //reserve 1 line for All system default: 4
			MaxDisplayData:120,
			DataUpdateTime_inSec:5,	//default: 5

			sparkline_initialOption :{
	            type: 'line', 
	            chartRangeMin: 0,  
	            chartRangeMax: 100,
	            lineWidth: 3,
	            spotRadius: 3,
	            width: 0, 
	            height: 0,
	            fillColor: false,           
	            minSpotColor: false,
	            maxSpotColor: false,
	            tooltipOffsetX : 0,
	            disableHighlight : true,
			}
		},		
		status:{
			NumberOfLines:0,   
			IndexOfData:0,
			AmountOfData:0,    
			MinDataRange:0,
			MaxDataRange:100,
			LineDataArray: new Array(),
		},      		
    };

    function _webDom_update(Panel_obj){
		if(Panel_obj.options.displayMode == 0){
			$("#canvas_hint_y").html('<sup>Utilization/5 Sec</sup>');
			$("#typeOfPacketSelect_div").hide();			

			$("#displayMode_radioPacket").prop("checked",false);
			$("#displayMode_radioUtilization").prop("checked",true);
		}else{
			$("#canvas_hint_y").html('<sup>Packet/5 Sec</sup>');
			$("#typeOfPacketSelect_div").show();			

			$("#displayMode_radioPacket").prop("checked",true);
			$("#displayMode_radioUtilization").prop("checked",false);
		}
    }

	function change_packet_type_selection(option){
		var $el = $("#packet_select");
		
		$el.empty(); // remove old options
		$.each(option, function(key,value) {
		  $el.append($("<option></option>")
		     .attr("value", value).text(key));
		});

	}
	
	$(document).ready(function(){
		change_packet_type_selection(kv_if_packet_type_sel);
		
		for(var item in brg_ifs){
			$('#ifs').append($("<option></option>")
			                    .attr("value",brg_ifs[item]["valus"])
			                    .text(brg_ifs[item]["text"]));			
		}

		
		$("#settingPanel_displayButton").click(function(){			
			$("#settingPanel_div").toggle();
		});
		
		$("#settingPanel_displayType_radioPorts,#settingPanel_displayType_radioInterface").change(function(){
			var option;
			if($("#settingPanel_displayType_radioPorts").prop("checked")==true ){
				option = kv_port_packet_type_sel;
				$("#interfaceSelect_div").hide();
				$("#portsSelect_div").fadeIn();
			}else if( $("#settingPanel_displayType_radioInterface").prop("checked")==true ){
				option = kv_if_packet_type_sel;
				$("#portsSelect_div").hide();
				$("#interfaceSelect_div").fadeIn();
			}
			
			change_packet_type_selection(option);
		});		
						
		$("#addNewLine_button").click(function(){
			LinePanel_Newline(Panel_Func);
		});			

		$("#displayMode_radioUtilization,#displayMode_radioPacket").change(function(){
			if($("#displayMode_radioUtilization").prop("checked")==true ){
				LinePanel_ModeChange(Panel_Func,0);
			}else if( $("#displayMode_radioPacket").prop("checked")==true ){				
				LinePanel_ModeChange(Panel_Func,1);
			}
			_webDom_update(Panel_Func);
			
		});				
		
		$("#refreshData_button").click(function(){
			LinePanel_Refresh(Panel_Func);
//			ResetPortCount();
			
		});


		$("#resetConfig_button").click(function(){
			LinePanel_Destruct(Panel_Func);
			_webDom_update(Panel_Func);
		});

		LinePanel_Construct(Panel_Func);
		_webDom_update(Panel_Func);
		LinePanel_Update(Panel_Func);		

	});	
</script>
<style type="text/css">
.jqstooltip{//to fix tooltip display problem in jQuery.sparkline with bootstrip. 
	-webkit-box-sizing: content-box;
	-moz-box-sizing: content-box;
	box-sizing: content-box;
}

#Axis_item ul {
	width: 600px;
	padding: 0px;
}

#Axis_item ul > li {
	width: 280px;
	float: left;
	display: inline;
}

#Axis_item ul > li > div#circle{
	display: inline-block;
	width:10px;height:10px;
	border-radius:999em;
	margin-right: 1em;
}
</style> 
</head>
<body>
<fieldset>
<div class="container" style="width:700px; position: absolute; left: 0px;  top:0px ;" >
	<div class="row">
		<div class="col-xs-4 col-sm-4">
			<h2>Display Mode</h2>
		</div>
		<div class="col-xs-6 col-sm-6" style="margin:1em 0em 0em 0em; ">
			<input type="radio" id="displayMode_radioUtilization" name="dataType_radio" checked="true">&nbsp;Bandwidth Utilization &nbsp;&nbsp;
			<input type="radio" id="displayMode_radioPacket" name="dataType_radio">&nbsp;Packet Counter &nbsp;&nbsp;
		</div>		
	</div>
</div>

<div class="container" style="width:700px; position: absolute; left: 0px;  top:35px ;">
	<div class="row">
		<div class="col-xs-12 col-sm-12" id="settingPanel_displayButton">
			<h2 style="cursor:pointer; width:12em;" >
				Display Setting &nbsp;
				<img src='../image/trangle.bmp' width=10 height=10>
			</h2>		
		</div>
	</div>
</div>

<div id="settingPanel_div" style="width:640px; display:none; z-index:1; position: absolute; left: 30px;  top: 75px;" class="container img-thumbnail">					
	<div class="row">
		<div class="col-xs-4 col-sm-4">
			Display Type
		</div>
		<div class="col-xs-4 col-sm-4">
			<input type="radio" id="settingPanel_displayType_radioPorts" name="type_radio" >&nbsp;Ports &nbsp;&nbsp;
			<input type="radio" id="settingPanel_displayType_radioInterface" name="type_radio" checked="true" >&nbsp;IP Interface &nbsp;&nbsp;
		</div>
	</div>
				
	<div class="row" id="portsSelect_div" style="display:none;">
		<div class="col-xs-4 col-sm-4">
			Port Selection
		</div>
		<div class="col-xs-4 col-sm-4">
			<script language="JavaScript">iGenSel2('ports_select', 'ports_select', ports)</script>
		</div>
	</div>

	<div class="row" id="interfaceSelect_div" >	
		<div class="col-xs-4 col-sm-4">
			Interface Selection
		</div>	
		<div class="col-xs-4 col-sm-4">
			<script language="JavaScript">iGenSel2('ifs_select', 'ifs', ifs)</script>
		</div>
	</div>							

	<div class="row">
		<div class="col-xs-4 col-sm-4">
			Sniffer Mode
		</div>
		<div class="col-xs-4 col-sm-4">
			<select id="sniff_select" size="1" style="width:10em;" >
				<option value="0" selected="selected">TX+RX</option>
				<option value="1">TX</option>
				<option value="2">RX</option>
			</select>
		</div>
	</div>
	<div class="row" id="typeOfPacketSelect_div" style="display:none;" >
		<div class="col-xs-4 col-sm-4">
			Packet Type
		</div>
		<div class="col-xs-4 col-sm-4">
			<select id="packet_select" size="1" style="width:10em;" >
			</select>
		</div>
	</div>

	<div class="row">
		<div  class="col-xs-10 col-sm-10" style="text-align:right;">	
			<input class="button" id ="addNewLine_button" value="Add" type="button">
			
			<input class="button" id ="resetConfig_button" value="Reset" type="button">
		</div>
	</div>
	
</div>
			
<div style="width:670px; height:320px; overflow:hind; z-index:0;  position: absolute; left: 30px;  top: 100px; " class="container">
	<div class="row">
		<div style="position: relative;">
			<span id="canvas_hint_y" style="position: absolute;left: -30px;  top: -20px;"><sup>Utilization/5 Sec</sup></span>
		</div>
		
		<div style="position: relative; left: -20px;  top: 320px;">
			<span id="Axis_X_1" style="position: absolute; left: 20px;"> 0 </span>
			<span id="Axis_X_2" style="position: absolute; left: 170px;"> 150 </span>
			<span id="Axis_X_3" style="position: absolute; left: 320px;"> 300 </span>
			<span id="Axis_X_4" style="position: absolute; left: 470px;"> 450 </span>
			<span id="Axis_X_5" style="position: absolute; left: 610px;"> 600 </span>
			<span id="canvas_hint_x" style="position: absolute; left: 650px; "><sup>Min:Sec</sup></span>
		</div>

		<div id="Axis_Y_All" style="position: relative; left: -25px;  top: 0px;">
			<span id="Axis_Y_1" style="position: absolute; left: 0px; top: 0px;"> 100 </span>
			<span id="Axis_Y_2" style="position: absolute; left: 0px; top: 75px;"> 75 </span>
			<span id="Axis_Y_3" style="position: absolute; left: 0px; top: 150px;"> 50 </span>
			<span id="Axis_Y_4" style="position: absolute; left: 0px; top: 225px;"> 25 </span>
			<span id="Axis_Y_5" style="position: absolute; left: 0px; top: 300px;"> 0 </span>
		</div>
		
		<div style=" width:620px; height:320px; position: relative; left: 0px;  top: 0px;" class="img-thumbnail">
			<span id="drawLine_canvas" style="position: absolute;left: 10px; top: 10px;"></span>
		</div>
	</div>
	<div class="row col-xs-12 col-sm-12" id="Axis_item" style="margin: 1.5em 0em 0em 0em;">
		<ul></ul>
	</div>
	<div class="row col-xs-12 col-sm-12" style="text-align:right;  margin: 0em 0em 0em 0em;">
		<input class="button" id="refreshData_button" value="Refresh" type="button">
	</div>
</div>
</fieldset>
</body>
</html>




