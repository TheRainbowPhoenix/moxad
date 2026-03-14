<html>
<head>
<script language="JavaScript" src=doc.js></script>
<link href="./main_style.css" rel=stylesheet type="text/css">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Cache-Control" content="no-cache">
<meta http-equiv="Content-Script-Type" content="text/javascript">
<script language="JavaScript" src=common.js></script>
<script language="JavaScript" src=mdata.js></script>
<script language="Javascript" src="jquery-1.11.1.min.js"></script>
<script language="Javascript" src="moxa_common.js"></script>
<script type="text/javascript">
checkMode(<% net_Web_GetMode_WriteValue(); %>);
<%net_Web_show_value('SRV_TRUNK_SETTING');%>
var SYSPORTS = <% net_Web_Get_SYS_PORTS(); %>
var SYSTRUNKS = <% net_Web_Get_SYS_TRUNKS(); %>
var port_desc=[<%net_webPortDesc();%>];
var port_diff=4;
var trunk_check=new Array;
<!--
    
	var stype;
	function resetCnt(stype){	
		location.href=location.reload();		
	}


	function showNewPage(form){
		var port,PKTtype;
		var dest;

		port=document.getElementById("port_select").value;
		PKTtype=document.getElementById("packet_select").value;
	
		dest="port_monitor.asp?"+ "show_port=" + port + "&" + "show_type=" + PKTtype;	
	
		location.href=dest;
	}
	
    var port_type, pkts_type;
    function getPageIndex()
    {
        var url=window.location.toString(); 
        var str="";  
        if(url.indexOf("?")!=-1)
        {
            var ary=url.split("?")[1].split("&");
    
            for(var i in ary)
            {
                str=ary[i].split("=")[0];
                if (str == "show_port")        
                    port_type = decodeURI(ary[i].split("=")[1]);
                    
                else if(str == "show_type")
                    pkts_type = decodeURI(ary[i].split("=")[1]);                    
            }
        }

    }
    

    function counterTable(TXPacket,RXPacket,TXUnicast,RXUnicast,TXBroadcast,RXBroadcast,TXMulticast,
                           RXMulticast,TXPausePkts,RXPausePkts,TXLateCollPkts,TXExcessCollPkts,RXUndersizePkts,
                           RXJabbers,RXFramesTooLong,RXFragments,RXCrcErrors,RXAlignErrors,TXErrorPkts,RXErrorPkts)
    {
        this.TXPacket=TXPacket;
        this.RXPacket=RXPacket;
        this.TXUnicast=TXUnicast;
        this.RXUnicast=RXUnicast;
        this.TXBroadcast=TXBroadcast;
        this.RXBroadcast=RXBroadcast;
        this.TXMulticast=TXMulticast;
        this.RXMulticast=RXMulticast;
        this.TXPausePkts=TXPausePkts;
        this.RXPausePkts=RXPausePkts;
        this.TXLateCollPkts=TXLateCollPkts;
        this.TXExcessCollPkts=TXExcessCollPkts;
        this.RXUndersizePkts=RXUndersizePkts;
        this.RXJabbers=RXJabbers;
        this.RXFramesTooLong=RXFramesTooLong;
        this.RXFragments=RXFragments;
        this.RXCrcErrors=RXCrcErrors;
        this.RXAlignErrors=RXAlignErrors;
        this.TXErrorPkts=TXErrorPkts;
        this.RXErrorPkts=RXErrorPkts;
    }
    var OldCounterTable = new Array(SYSPORTS+SYSTRUNKS);
    var NewCounterTable = new Array(SYSPORTS+SYSTRUNKS);
    
    function initCounter(CounterTable)
    {
        var i=0;
	    for(i=0;i<SYSPORTS+SYSTRUNKS;i++)
	    {
	        CounterTable[i] = new counterTable(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
	    }
    }
    
	function saveCounter(CounterTable)
	{	
		var response = xmlHttpPortCounter.responseXML;
        var i=0;
	    for(i=0;i<SYSPORTS+SYSTRUNKS;i++)
	    {	        
	        CounterTable[i].TXPacket=parseInt(response.getElementsByTagName('TXPacket')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXPacket=parseInt(response.getElementsByTagName('RXPacket')[i].childNodes[0].nodeValue);
	        CounterTable[i].TXUnicast=parseInt(response.getElementsByTagName('TXUnicast')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXUnicast=parseInt(response.getElementsByTagName('RXUnicast')[i].childNodes[0].nodeValue);
	        CounterTable[i].TXBroadcast=parseInt(response.getElementsByTagName('TXBroadcast')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXBroadcast=parseInt(response.getElementsByTagName('RXBroadcast')[i].childNodes[0].nodeValue);
	        CounterTable[i].TXMulticast=parseInt(response.getElementsByTagName('TXMulticast')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXMulticast=parseInt(response.getElementsByTagName('RXMulticast')[i].childNodes[0].nodeValue);
	        CounterTable[i].TXPausePkts=parseInt(response.getElementsByTagName('TXPausePkts')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXPausePkts=parseInt(response.getElementsByTagName('RXPausePkts')[i].childNodes[0].nodeValue);
	        CounterTable[i].TXLateCollPkts=parseInt(response.getElementsByTagName('TXLateCollPkts')[i].childNodes[0].nodeValue);
	        CounterTable[i].TXExcessCollPkts=parseInt(response.getElementsByTagName('TXExcessCollPkts')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXUndersizePkts=parseInt(response.getElementsByTagName('RXUndersizePkts')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXJabbers=parseInt(response.getElementsByTagName('RXJabbers')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXFramesTooLong=parseInt(response.getElementsByTagName('RXFramesTooLong')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXFragments=parseInt(response.getElementsByTagName('RXFragments')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXCrcErrors=parseInt(response.getElementsByTagName('RXCrcErrors')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXAlignErrors=parseInt(response.getElementsByTagName('RXAlignErrors')[i].childNodes[0].nodeValue);
	        CounterTable[i].TXErrorPkts=parseInt(response.getElementsByTagName('TXLateCollPkts')[i].childNodes[0].nodeValue)
    			             + parseInt(response.getElementsByTagName('TXExcessCollPkts')[i].childNodes[0].nodeValue);
	        CounterTable[i].RXErrorPkts=parseInt(response.getElementsByTagName('RXUndersizePkts')[i].childNodes[0].nodeValue)
    			             + parseInt(response.getElementsByTagName('RXJabbers')[i].childNodes[0].nodeValue)
    			             + parseInt(response.getElementsByTagName('RXFramesTooLong')[i].childNodes[0].nodeValue)
    			             + parseInt(response.getElementsByTagName('RXFragments')[i].childNodes[0].nodeValue)
    			             + parseInt(response.getElementsByTagName('RXCrcErrors')[i].childNodes[0].nodeValue)
    			             + parseInt(response.getElementsByTagName('RXAlignErrors')[i].childNodes[0].nodeValue);
	    }
	
	}
	function SendToJAVA(CounterTable)
	{
        var i=0,jj=0;
	    for(i=0;i<SYSPORTS+SYSTRUNKS;i++)
	    {
        document.getElementById("ShowSwitchPortGraph").sendData(i,CounterTable[i].TXUnicast,CounterTable[i].RXUnicast,
                                                            CounterTable[i].TXBroadcast,CounterTable[i].RXBroadcast,
                                                            CounterTable[i].TXMulticast,CounterTable[i].RXMulticast,
                                                            CounterTable[i].TXErrorPkts,CounterTable[i].RXErrorPkts);                                                   
        }
	
	}
	function deleteTableRows(table)
	{
    			rows = table.getElementsByTagName("tr");
	            if(rows.length > 1)
	            {
	             	for(var i=rows.length-1 ;i>0;i--)
		            {
			            table.deleteRow(i);
		            }
 	            }	    
	}
    function insertTable()
    {
                var response = xmlHttpPortCounter.responseXML;
                saveCounter(NewCounterTable);

                SendToJAVA(NewCounterTable);

                //var row_cnt;
                var port_firstrow,port_lastrow;
				if(port_type==0 || port_type==1|| port_type==2){
					port_firstrow=0;
					port_lastrow=SYSPORTS;
				}
				/*else if(port_type==1){//all mega
					port_firstrow=0;
					port_lastrow=8;
				}
				else if(port_type==2){//all giga
					port_firstrow=8;
					port_lastrow=10;
				}*/
				else if(port_type==3){//all trk
					port_firstrow=SYSPORTS;
					port_lastrow=SYSPORTS+SYSTRUNKS;
				}
				else{
					port_firstrow=0;
					port_lastrow=1;
				}

                
                ////TotalPktsTable
    			var TotalPktsTable = document.getElementById("TotalPktsTable"); 
    			deleteTableRows(TotalPktsTable);

                for(i=port_firstrow;i<port_lastrow;i++)
                {
                    if(port_firstrow==0 && port_lastrow==1)i=port_type-port_diff;
    			    
                    row = TotalPktsTable.insertRow(TotalPktsTable.getElementsByTagName("tr").length);
    		   	    cell = document.createElement("td");
    		   	    if(port_type==3)
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    			     else if(i>=SYSPORTS) 
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    		   	    else
    			    	cell.innerHTML =port_desc[i].index;
    			
    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTx=NewCounterTable[i].TXPacket-OldCounterTable[i].TXPacket;
	                cell.innerHTML = OldCounterTable[i].TXPacket + '+' + DifTx;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTxEr=NewCounterTable[i].TXErrorPkts-OldCounterTable[i].TXErrorPkts;
	                cell.innerHTML = OldCounterTable[i].TXErrorPkts + '+' + DifTxEr;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRx=NewCounterTable[i].RXPacket-OldCounterTable[i].RXPacket;
	                cell.innerHTML = OldCounterTable[i].RXPacket + '+' + DifRx;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxEr=NewCounterTable[i].RXErrorPkts-OldCounterTable[i].RXErrorPkts;
	                cell.innerHTML = OldCounterTable[i].RXErrorPkts + '+' + DifRxEr;

    		    	row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = "";

	                row.style.backgroundColor = "white";
	                row.className = "r1";
	                if(port_type==1){
	                	if(EDS_IF_IS_GIGA(port_desc, i)||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
	                else if(port_type==2){
	                	if(!(EDS_IF_IS_GIGA(port_desc, i))||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
					else if(port_type==3 && trunk_check[i+1-SYSPORTS]==0){
						row.style.display="none";
					}
	            }
	            
                ////TxPktsTable
    			var TxPktsTable = document.getElementById("TxPktsTable"); 
    			deleteTableRows(TxPktsTable);

                for(i=port_firstrow;i<port_lastrow;i++)
                {
                    if(port_firstrow==0 && port_lastrow==1)i=port_type-port_diff;
    			    
                    row = TxPktsTable.insertRow(TxPktsTable.getElementsByTagName("tr").length);
    		   	    cell = document.createElement("td");
    		   	    if(port_type==3)
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    			    else if(i>=SYSPORTS) 
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    		   	    else
    			    	cell.innerHTML =port_desc[i].index;
    			
    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTx=NewCounterTable[i].TXPacket-OldCounterTable[i].TXPacket;
	                cell.innerHTML = OldCounterTable[i].TXPacket + '+' + DifTx;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTxUni=NewCounterTable[i].TXUnicast-OldCounterTable[i].TXUnicast;
	                cell.innerHTML = OldCounterTable[i].TXUnicast + '+' + DifTxUni;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTxMul=NewCounterTable[i].TXMulticast-OldCounterTable[i].TXMulticast;
	                cell.innerHTML = OldCounterTable[i].TXMulticast + '+' +DifTxMul;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTxBro=NewCounterTable[i].TXBroadcast-OldCounterTable[i].TXBroadcast;
	                cell.innerHTML = OldCounterTable[i].TXBroadcast + '+' + DifTxBro;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTxCol=(NewCounterTable[i].TXLateCollPkts + NewCounterTable[i].TXExcessCollPkts) 
	                           - (OldCounterTable[i].TXLateCollPkts + OldCounterTable[i].TXExcessCollPkts);
	                cell.innerHTML = (parseInt(OldCounterTable[i].TXLateCollPkts) + parseInt(OldCounterTable[i].TXExcessCollPkts)) + '+' + DifTxCol;
	                
    		    	row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = "";

	                row.style.backgroundColor = "white";
	                row.className = "r1";

	                if(port_type==1){
	                	if(EDS_IF_IS_GIGA(port_desc, i)||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
	                else if(port_type==2){
	                	if(!(EDS_IF_IS_GIGA(port_desc, i))||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
					else if(port_type==3 && trunk_check[i+1-SYSPORTS]==0){
						row.style.display="none";
					}
	            }
	            
                ////RxPktsTable
    			var RxPktsTable = document.getElementById("RxPktsTable");
    			deleteTableRows(RxPktsTable);
                for(i=port_firstrow;i<port_lastrow;i++)
                {
                    if(port_firstrow==0 && port_lastrow==1)i=port_type-port_diff;
    			    
                    row = RxPktsTable.insertRow(RxPktsTable.getElementsByTagName("tr").length);
    		   	    cell = document.createElement("td");
    		   	    if(port_type==3)
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    			    else if(i>=SYSPORTS) 
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    		   	    else
    			    	cell.innerHTML =port_desc[i].index;
    			
    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRx=NewCounterTable[i].RXPacket-OldCounterTable[i].RXPacket;
	                cell.innerHTML = OldCounterTable[i].RXPacket + '+' + DifRx;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxUni=NewCounterTable[i].RXUnicast-OldCounterTable[i].RXUnicast;
	                cell.innerHTML = OldCounterTable[i].RXUnicast + '+' + DifRxUni;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxMul=NewCounterTable[i].RXMulticast-OldCounterTable[i].RXMulticast;
	                cell.innerHTML = OldCounterTable[i].RXMulticast + '+' +DifRxMul;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxBro=NewCounterTable[i].RXBroadcast-OldCounterTable[i].RXBroadcast;
	                cell.innerHTML = OldCounterTable[i].RXBroadcast + '+' + DifRxBro;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxPau=NewCounterTable[i].RXPausePkts - OldCounterTable[i].RXPausePkts;
	                cell.innerHTML = OldCounterTable[i].RXPausePkts + '+' + DifRxPau;
	                
    		    	row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = "";

	                row.style.backgroundColor = "white";
	                row.className = "r1";
	                
	                if(port_type==1){
	                	if(EDS_IF_IS_GIGA(port_desc, i)||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
	                else if(port_type==2){
	                	if(!(EDS_IF_IS_GIGA(port_desc, i))||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
					else if(port_type==3 && trunk_check[i+1-SYSPORTS]==0){
						row.style.display="none";
					}	             
	            }

                ////ErrorPktsTable
    			var ErrorPktsTable = document.getElementById("ErrorPktsTable");
    			deleteTableRows(ErrorPktsTable);
                for(i=port_firstrow;i<port_lastrow;i++)
                {
                    if(port_firstrow==0 && port_lastrow==1)i=port_type-port_diff;
    			    
                    row = ErrorPktsTable.insertRow(ErrorPktsTable.getElementsByTagName("tr").length);
    		   	    cell = document.createElement("td");
    		   	    if(port_type==3)
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    			    else if(i>=SYSPORTS) 
    			    	cell.innerHTML ="Trk "+(i+1-SYSPORTS);
    		   	    else
    			    	cell.innerHTML =port_desc[i].index;

	                row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTxLat=NewCounterTable[i].TXLateCollPkts-OldCounterTable[i].TXLateCollPkts;
	                cell.innerHTML = OldCounterTable[i].TXLateCollPkts + '+' + DifTxLat;
	                
    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifTxExc=NewCounterTable[i].TXExcessCollPkts-OldCounterTable[i].TXExcessCollPkts;
	                cell.innerHTML = OldCounterTable[i].TXExcessCollPkts + '+' + DifTxExc;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxCrc=NewCounterTable[i].RXCrcErrors-OldCounterTable[i].RXCrcErrors;
	                cell.innerHTML = OldCounterTable[i].RXCrcErrors + '+' + DifRxCrc;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxAli=NewCounterTable[i].RXAlignErrors-OldCounterTable[i].RXAlignErrors;
	                cell.innerHTML = OldCounterTable[i].RXAlignErrors + '+' +DifRxAli;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxUnd=NewCounterTable[i].RXUndersizePkts-OldCounterTable[i].RXUndersizePkts;
	                cell.innerHTML = OldCounterTable[i].RXUndersizePkts + '+' + DifRxUnd;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxFgm=NewCounterTable[i].RXFragments - OldCounterTable[i].RXFragments;
	                cell.innerHTML = OldCounterTable[i].RXFragments + '+' + DifRxFgm;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxOvr=NewCounterTable[i].RXFramesTooLong-OldCounterTable[i].RXFramesTooLong;
	                cell.innerHTML = OldCounterTable[i].RXFramesTooLong + '+' + DifRxOvr;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                var DifRxJab=NewCounterTable[i].RXJabbers - OldCounterTable[i].RXJabbers;
	                cell.innerHTML = OldCounterTable[i].RXJabbers + '+' + DifRxJab;
	                
    		    	row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = "";

	                row.style.backgroundColor = "white";
	                row.className = "r1";
	                
	                if(port_type==1){
	                	if(EDS_IF_IS_GIGA(port_desc, i)||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
	                else if(port_type==2){
	                	if(!(EDS_IF_IS_GIGA(port_desc, i))||SRV_TRUNK_SETTING[i].trkgrp!=0)
	                	row.style.display="none";
	                }
					else if(port_type==3 && trunk_check[i+1-SYSPORTS]==0){
						row.style.display="none";
					}	                
	            }

                ////TxPktsPerPortTable
    			var TxPktsPerPortTable = document.getElementById("TxPktsPerPortTable"); 
    			deleteTableRows(TxPktsPerPortTable);
                for(i=port_firstrow;i<port_lastrow;i++)
                {
                    if(port_firstrow==0 && port_lastrow==1)i=port_type-port_diff;
    			    
                    row = TxPktsPerPortTable.insertRow(TxPktsPerPortTable.getElementsByTagName("tr").length);
    		   	    cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].TXPacket + '+' + DifTx;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].TXUnicast + '+' + DifTxUni;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].TXMulticast + '+' +DifTxMul;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].TXBroadcast + '+' + DifTxBro;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = (parseInt(OldCounterTable[i].TXLateCollPkts) + parseInt(OldCounterTable[i].TXExcessCollPkts)) + '+' + DifTxCol;
	                
    		    	row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = "";

	                row.style.backgroundColor = "white";
	                row.className = "r1";
	            }

    			var RxPktsPerPortTable = document.getElementById("RxPktsPerPortTable");
    			deleteTableRows(RxPktsPerPortTable);
                for(i=port_firstrow;i<port_lastrow;i++)
                {
                    if(port_firstrow==0 && port_lastrow==1)i=port_type-port_diff;
    			    
                    row = RxPktsPerPortTable.insertRow(RxPktsPerPortTable.getElementsByTagName("tr").length);
    		   	    cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXPacket + '+' + DifRx;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXUnicast + '+' + DifRxUni;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXMulticast + '+' +DifRxMul;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXBroadcast + '+' + DifRxBro;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXPausePkts + '+' + DifRxPau;
	                
    		    	row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = "";

	                row.style.backgroundColor = "white";
	                row.className = "r1";
	            }

                ////ErrorPktsPerPortTable
    			var ErrorPktsPerPortTable = document.getElementById("ErrorPktsPerPortTable"); 
    			deleteTableRows(ErrorPktsPerPortTable);
                for(i=port_firstrow;i<port_lastrow;i++)
                {
                    if(port_firstrow==0 && port_lastrow==1)i=port_type-port_diff;
    			    
                    row = ErrorPktsPerPortTable.insertRow(ErrorPktsPerPortTable.getElementsByTagName("tr").length);
    		   	    cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].TXLateCollPkts + '+' + DifTxLat;
	                
    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].TXExcessCollPkts + '+' + DifTxExc;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXCrcErrors + '+' + DifRxCrc;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXAlignErrors + '+' +DifRxAli;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXUndersizePkts + '+' + DifRxUnd;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXFragments + '+' + DifRxFgm;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXFramesTooLong + '+' + DifRxOvr;

    			    row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = OldCounterTable[i].RXJabbers + '+' + DifRxJab;
	                
    		    	row.appendChild(cell);
	                cell = document.createElement("td");
	                cell.innerHTML = "";

	                row.style.backgroundColor = "white";
	                row.className = "r1";
	            }
	            
	            saveCounter(OldCounterTable);

	            setTimeout("refreshTable( )", 5000)


    }
    function displayTable()
    {
           document.getElementById('TotalPktsTableTitle').style.display="none"; 
           document.getElementById('TotalPktsTable').style.display="none";
           document.getElementById('TxPktsTableTitle').style.display="none"; 
           document.getElementById('TxPktsTable').style.display="none"; 
           document.getElementById('RxPktsTableTitle').style.display="none"; 
           document.getElementById('RxPktsTable').style.display="none"; 
           document.getElementById('ErrorPktsTableTitle').style.display="none"; 
           document.getElementById('ErrorPktsTable').style.display="none";
           document.getElementById('TxPktsPerPortTableTitle').style.display="none"; 
           document.getElementById('TxPktsPerPortTable').style.display="none"; 
           document.getElementById('RxPktsPerPortTableTitle').style.display="none"; 
           document.getElementById('RxPktsPerPortTable').style.display="none"; 
           document.getElementById('ErrorPktsPerPortTableTitle').style.display="none"; 
           document.getElementById('ErrorPktsPerPortTable').style.display="none";   
       if(port_type>=0 && port_type<4)
       {
           if(pkts_type==0)
           {
               document.getElementById('TotalPktsTableTitle').style.display=""; 
               document.getElementById('TotalPktsTable').style.display=""; 
           }
           if(pkts_type==1)
           {
               document.getElementById('TxPktsTableTitle').style.display=""; 
               document.getElementById('TxPktsTable').style.display=""; 
           }
           if(pkts_type==2)
           {
               document.getElementById('RxPktsTableTitle').style.display=""; 
               document.getElementById('RxPktsTable').style.display=""; 
           }
            if(pkts_type==3)
           {
               document.getElementById('ErrorPktsTableTitle').style.display=""; 
               document.getElementById('ErrorPktsTable').style.display=""; 
           }
       }
       else 
       {
           document.getElementById('TxPktsPerPortTableTitle').style.display=""; 
           document.getElementById('TxPktsPerPortTable').style.display=""; 
           document.getElementById('RxPktsPerPortTableTitle').style.display=""; 
           document.getElementById('RxPktsPerPortTable').style.display=""; 
           document.getElementById('ErrorPktsPerPortTableTitle').style.display=""; 
           document.getElementById('ErrorPktsPerPortTable').style.display="";            
       }
    }
	function creatAJAX(){

		if (window.XMLHttpRequest){// code for IE7+, Firefox, Chrome, Opera, Safari
		 	  xmlHttpPortCounter=new XMLHttpRequest();;
		  }else{// code for IE6, IE5
			  xmlHttpPortCounter=new ActiveXObject("Microsoft.XMLHTTP");
		 }
	}

	function getPortCounter(cnt) {
		var urlPortCounter = "./xml/portcounter.xml";

		xmlHttpPortCounter.open("GET", urlPortCounter, true);
		
	    xmlHttpPortCounter.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

		xmlHttpPortCounter.setRequestHeader("Cache-Control", "no-store, no-cache, must-revalidate");
		xmlHttpPortCounter.setRequestHeader("Cache-Control", "post-check=0, pre-check=0");
		xmlHttpPortCounter.setRequestHeader("Cache-Control", "no-cache, must-revalidate");
		xmlHttpPortCounter.setRequestHeader("Expires", "Mon, 26 Jul 1997 05:00:00 GMT");
		xmlHttpPortCounter.setRequestHeader("Pragma", "no-cache");

	    xmlHttpPortCounter.setRequestHeader("If-Modified-Since", "0");

		
		if(cnt==0)
		xmlHttpPortCounter.onreadystatechange = responsePortCounter;

		else
		xmlHttpPortCounter.onreadystatechange = responsePortCounter2;
		xmlHttpPortCounter.send(null);
	}

	function responsePortCounter2() {
		if(xmlHttpPortCounter.readyState == 4) {
			if(xmlHttpPortCounter.status == 200) {			
			insertTable();
    		}
    	}
    }
	
	function responsePortCounter() {
		if(xmlHttpPortCounter.readyState == 4) {
			if(xmlHttpPortCounter.status == 200) {
			saveCounter(OldCounterTable);
			
			insertTable();
    		}
    	}
    }
    
    function refreshTable()
    {
		creatAJAX();		
		getPortCounter(1);	    
    }
    
	function initTrunk()
	{
		for(i=0; i<SYSTRUNKS; i++){	    	
		  	trunk_check[i+1]=0;
		}
	
		for(i=0; i<SYSPORTS; i++){
	    	if(SRV_TRUNK_SETTING[i].trkgrp!=0){
		  		 trunk_check[SRV_TRUNK_SETTING[i].trkgrp]=1;
			}
		}

	}
	
	function init()
	{
		web_cookie_update_touchLasttime()
		initTrunk();
	    getPageIndex();
	    displayTable();
	    initCounter(OldCounterTable);
	    initCounter(NewCounterTable);
		creatAJAX();		
		getPortCounter(0);
	
	}
		
//-->
</script>
</head>


<body onLoad="init()" >
<h1>Monitor System : Total Packets</h1>
<fieldset>
<form method="post" name="Layer2_monitor_port_form" target="mid">
<% net_Web_csrf_Token(); %>
<table width="700" border="0"> 
<tr><td>
</td></tr>
<tr><td>
<div align="left">        
    <table width="700" border="0" cellspacing="0" cellpadding="0">        
    	<tr>
    		<td width="2%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    		</div></font></td>
    		<td width="25%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			<% ShowLayer2MonitorPortSelect(show_port,show_type); %>
    		</font></div></td> 
    		<td width="20%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
      			<% ShowLayer2MonitorPacketSelect(show_port,show_type); %>
    		</font></div></td>
    		<td width="53%"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">
    			<!--input name="ResetSubmit" src="reset_button.gif" onclick="resetCnt(1)" onmouseover="document.body.style.cursor='hand'" onmouseout="document.body.style.cursor='default'" type="image"-->
    		</font></div></td>    		
    	</tr>
    	<tr>             
            <td colspan="4">
				<APPLET codebase="./" archive="ShowSwitchPortGraph.jar" code="ShowSwitchPortGraph.class" id="ShowSwitchPortGraph" name="ShowSwitchPortGraph" width="690" height="160"> 
					<% ShowLayer2MonitorShowGraphParameters(show_port,show_type); %>
				</APPLET>           	
         	</td>
      	</tr>
        <tr><td colspan="4">      	
			<table  style="width:700px" border="0">
			<tr>
				<td style="width:500"><div align="left"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">[Format] Total Packets + Packets in previous 5 sec. interval</font></div></td>
				<td style="width:186"><div align="right"><font size="2" face="Arial, Helvetica, sans-serif, Marlett">update interval of 5 sec</font></div></td>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">  
			<table style="width:700px" border="0" id=TotalPktsTableTitle>
			<tr>
				<th style="width:40px">Port</th>
				<th style="width:200px">Tx</th>
				<th style="width:130px">Tx Error</th>
				<th style="width:200px">Rx</th>
                <th style="width:130px">Rx Error</th>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		    <table style="width:700px" valign="top" border="0" id=TotalPktsTable>
			<tr>
				<td  style="width:40px"></td>
				<td  style="width:200px"></td>
				<td  style="width:130px"></td>
				<td  style="width:200px"></td>
				<td  style="width:130px"></td>
			</tr>
			</table></td>
		</tr>

		<tr><td colspan="4">  
			<table style="width:700px" border="0" id=TxPktsTableTitle>
			<tr>
				<th style="width:40px"><div align="left">Port</div></th>
				<th style="width:132px"><div align="left">Total</div></th>
				<th style="width:132px"><div align="left">Unicast</div></th>
				<th style="width:132px"><div align="left">Multicast</div></th>
                <th style="width:132px"><div align="left">Broadcast</div></th>
                <th style="width:132px"><div align="left">Collision</div></th>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		    <table style="width:700px" valign="top" border="0" id=TxPktsTable>
			<tr>
				<td  style="width:40px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
			</tr>
			</table></td>
		</tr>	

		<tr><td colspan="4">  
			<table style="width:700px" border="0" id=RxPktsTableTitle>
			<tr>
				<th style="width:40px"><div align="left">Port</div></th>
				<th style="width:132px"><div align="left">Total</div></th>
				<th style="width:132px"><div align="left">Unicast</div></th>
				<th style="width:132px"><div align="left">Multicast</div></th>
                <th style="width:132px"><div align="left">Broadcast</div></th>
                <th style="width:132px"><div align="left">Pause</div></th>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		    <table style="width:700px" border="0" id=RxPktsTable>
			<tr>
				<td  style="width:40px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
				<td  style="width:132px"></td>
			</tr>
			</table></td>
		</tr>
	
		<tr><td colspan="4">  
			<table style="width:700px" border="0" id=ErrorPktsTableTitle>
			<tr>
				<th  style="width:40px"><div align="left"></div></td>
				<th  style="width:162px" colspan="2"><div align="left">Tx</div></td>
				<th  style="width:498px" colspan="6"><div align="left">Rx</div></td>
			</tr>
			<tr>
				<th  style="width:40px"><div align="left">Port</div></td>
				<th  style="width:81px"><div align="left">Late</div></td>
				<th  style="width:81px"><div align="left">Excessive</div></td>
				<th  style="width:83px"><div align="left">CRC Error</div></td>
                <th  style="width:83px"><div align="left">Discard</div></td>
                <th  style="width:83px"><div align="left">Undersize</div></td>
                <th  style="width:83px"><div align="left">Fragments</div></td>
                <th  style="width:83px"><div align="left">Oversize</div></td>
                <th  style="width:83px"><div align="left">Jabber</div></td>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		    <table style="width:700px" border="0" id=ErrorPktsTable>
			<tr>
				<td  style="width:40px"></td>
				<td  style="width:81px"></td>
				<td  style="width:81px"></td>
				<td  style="width:83px"></td>
				<td  style="width:83px"></td>
				<td  style="width:83px"></td>
				<td  style="width:83px"></td>
				<td  style="width:83px"></td>
				<td  style="width:83px"></td>
			</tr>
			</table></td>
		</tr>

		<tr><td colspan="4">  
			<table style="width:700px" border="0" id=TxPktsPerPortTableTitle>
			<tr>
				<th  style="width:140px"><div align="left">Tx Total</div></td>
				<th  style="width:140px"><div align="left">Tx Unicast</div></td>
				<th  style="width:140px"><div align="left">Tx Multicast</div></td>
                <th  style="width:140px"><div align="left">Tx Broadcast</div></td>
                <th  style="width:140px"><div align="left">Tx Collision</div></td>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		    <table style="width:700px" valign="top" border="0" id=TxPktsPerPortTable>
			<tr>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
			</tr>
			</table></td>
		</tr>	


		<tr><td colspan="4">  
			<table style="width:700px" border="0" id=RxPktsPerPortTableTitle>
			<tr>
                <th  style="width:140px"><div align="left">Rx Total</div></td>
				<th  style="width:140px"><div align="left">Rx Unicast</div></td>
				<th  style="width:140px"><div align="left">Rx Multicast</div></td>
                <th  style="width:140px"><div align="left">Rx Broadcast</div></td>
                <th  style="width:140px"><div align="left">Rx Pause</div></td>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		    <table style="width:700px" border="0" id=RxPktsPerPortTable>
			<tr>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
				<td  style="width:140px"></td>
			</tr>
			</table></td>
		</tr>

		<tr><td colspan="4">  
			<table style="width:700px" border="0" id=ErrorPktsPerPortTableTitle>
			<tr>
				<th  style="width:172px" colspan="2"><div align="left">Tx</div></td>
				<th  style="width:528px" colspan="6"><div align="left">Rx</div></td>
			</tr>
			<tr>
				<th  style="width:86px"><div align="left">Late</div></td>
				<th  style="width:86px"><div align="left">Excessive</div></td>
				<th  style="width:88px"><div align="left">CRC Error</div></td>
                <th  style="width:88px"><div align="left">Discard</div></td>
                <th  style="width:88px"><div align="left">Undersize</div></td>
                <th  style="width:88px"><div align="left">Fragments</div></td>
                <th  style="width:88px"><div align="left">Oversize</div></td>
                <th  style="width:88px"><div align="left">Jabber</div></td>
			</tr>
			</table></td>
		</tr>
		<tr><td colspan="4">
		    <table style="width:700px" border="0" id=ErrorPktsPerPortTable>
			<tr>
				<td  style="width:86px"></td>
				<td  style="width:86px"></td>
				<td  style="width:88px"></td>
				<td  style="width:88px"></td>
				<td  style="width:88px"></td>
				<td  style="width:88px"></td>
				<td  style="width:88px"></td>
				<td  style="width:88px"></td>
			</tr>
			</table></td>
		</tr>
		
   	</table>     		        
</div>
</td></tr>
</table>
</form>
</fieldset>
</body>
</html>

