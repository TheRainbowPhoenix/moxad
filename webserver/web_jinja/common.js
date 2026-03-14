// -----------------------
// Bebin of Debug Section
// -----------------------
var debug=true;

function fnShowProp(name, obj)
{
	var tbl, obj0, obj1;
	var win=window.open('', 'fnShowProp', "resizable=yes,scrollbars=yes,status=yes");
	with (win.document) {
		tbl=createElement('table');
		tbl.id='unique';
		tbl.style.fontFamily='Arial';
		tbl.style.fontSize=12;
		tbl.border=1;
		tbl.cellSpacing=0;

		tbl.appendChild(createElement('caption'));
		tbl.caption.innerHTML='Property Of Object: '+name;

		obj0=createElement('tr');
		obj0.appendChild(obj1=createElement('th'));
		obj1.innerHTML='Property';
		obj0.appendChild(obj1=createElement('th'));
		obj1.innerHTML='Value';

		tbl.appendChild(createElement('thead'));
		tbl.tHead.appendChild(obj0);

		tbl.appendChild(createElement('tbody'));
		for (var property in obj) {
			obj0=createElement('tr');
			obj0.appendChild(obj1=createElement('td'));
			obj1.innerHTML=' '+property;
			obj0.appendChild(obj1=createElement('td'));
			obj1.appendChild(createTextNode((obj[property])? ' '+obj[property] : 'null'));
			tbl.tBodies[0].appendChild(obj0);
		}
		obj0=getElementById('unique');
		if (obj0)
			body.removeChild(obj0);
		body.appendChild(tbl);
	}
}

function fnAlertProp(name, obj) {
	msg='Prop of:'+name+'\n\n';
	i=0;
	for (property in obj) {
		i++;
		msg+=property+':\t'+obj[property]+'\n';
		if (i%10==0) {
			alert(msg);
			msg='Prop of:'+name+'\n\n';
		}
	}
	alert(msg);
}

var ptrcursor = (document.all) ? 'hand' : 'pointer';

// -----------------------
// End of Debug Section
// -----------------------
var MsgHead = ['Error: ', 'Warning: '];
var MsgStrs = [
	' IP Address less than 4 element.',
	' IP Address element value must be in range.',
	' Port number must be 1~65535.', 
	' IP Range is error.',
	' Range is error.',
	' Not in correct format, must be a-z, A-Z, 0-9 or . - _ @ ! # $ % ^ & * ( )',
	' Domain name should not have special characters ',
	' Not a valid number. ',
	' Limit value must be 1~4000. ',
	' Mask Address format is error. ',
	' IP Address element value must be 0~255',
	' Value is over range. ',
	' number must be 1~255',
	' Not a right mac address format. ',
	' The Sum of Min.BW is more than Total BW. ',
	' IP Address first element value must be 1~224.',
	' number must be 1~254',
	' IP Address element value must be 0~255.',
	' cannot have the space.',
	' MTU must be 68~1578.',
];

function bodyh() {document.write('<table class=t0><tr><td>')}
function bodyl() {document.write('</td></tr></table>')}
//function mainh() {}
//function mainl() {}
function mainh() {document.write('<table class=t2><tr><td>')}
function mainl() {document.write('</td></tr></table>')}
function help(tit, help) {
	with (document) {
		write('<table border=0><tr align="center"><td><h2>'+title+'</td><td width=36>');
		if (help)
			write('<a href="'+help+'" target=_self><img border=0 src="images/Help_1.gif"></a>');
		write('</td></tr></table>');
	}
}
function main_help(tit, help) {
	with (document) {
		write('<table border=0><tr align="center"><td><h1>'+title+'</td><td width=36>');
		if (help)
			write('<a href="'+help+'" target=_self><img border=0 src="images/Help_1.gif"></a>');
		write('</td></tr></table>');
	}
}
function helpback() {document.write('<p class=tl><a href="javascript:history.back()">Click to go back</a></p>')}
function hr(col) {document.write('<td colspan='+ col +'>&nbsp;</td>')}
function color_line(color,colon){document.write('<tr style="line-height:1px"><td  style="background-color:'+color+';line-height:1px;;padding:0px;"; colspan='+colon+'>&nbsp;</td></tr>')} 

function IpAddrIsOK(Obj, ObjName) {
	var iv = Obj.value.split('.');
	var ok = iv.length != 4;
	if (ok) {
		alert(MsgHead[0]+ObjName+MsgStrs[0]);
		return !ok;
	}
	for (var i=0; i< iv.length; i++){
		//ok = ok || (iv[i] < 0 || iv[i] > 255);
		ok = ok || !(iv[i] >= 0 && iv[i] <= 255);
	}
	ok = ok || (iv[iv.length - 1] < 1 || iv[iv.length-1] > 254);
	//ok = ok || !(iv[iv.length - 1] > -1 && iv[iv.length-1] < 256);
	if (ok)
		alert(MsgHead[0]+ObjName+MsgStrs[1]);
	return (!ok) ;
}


function IpAddrMaskIsOK(ObjIp,ObjMask, ObjName) {
	var iv = ObjIp.value.split('.');
	var ok = iv.length != 4;
	var objipnet = fnIp2Net(ObjIp.value, "255.255.255.255");	
	var masknet = fnIp2Net(ObjMask.value, "255.255.255.255");
	var allknet = fnIp2Net("255.255.255.255", "255.255.255.255");
	var ipnet = fnIp2Net(ObjIp.value, ObjMask.value);

	
	if (ok) {
		alert(MsgHead[0]+ObjName+MsgStrs[0]);
		return !ok;
	}
	
	for (var i=0; i< iv.length; i++){
		ok = ok || !(iv[i] >= 0 && iv[i] <= 255);
	}

	
	//ok = ok || (iv[iv.length - 1] < 1 || iv[iv.length-1] > 254);
	if(objipnet >= ipnet && objipnet <= (allknet - masknet + ipnet)){
		ok = false;
	}else{
		ok = true;
	}

	if (ok)
		alert(MsgHead[0]+ObjName+MsgStrs[1]);
	return (!ok) ;
}



function IpAddrIsOK_allow0and255(Obj, ObjName) {
	var iv = Obj.value.split('.');
	var ok = iv.length != 4;
	if (ok) {
		alert(MsgHead[0]+ObjName+MsgStrs[0]);
		return !ok;
	}
	for (var i=0; i< iv.length; i++){
		//ok = ok || (iv[i] < 0 || iv[i] > 255);
		ok = ok || !(iv[i] >= 0 && iv[i] <= 255);
	}
	//ok = ok || (iv[iv.length - 1] < 1 || iv[iv.length-1] > 254);
	ok = ok || !(iv[iv.length - 1] > -1 && iv[iv.length-1] < 256);
	if (ok)
		alert(MsgHead[0]+ObjName+MsgStrs[17]);
	return (!ok) ;
}



function IpAddrNotMcastIsOK(Obj, ObjName) {
	var iv = Obj.value.split('.');
	var ok = iv.length != 4;
	if (ok) {
		alert(MsgHead[0]+ObjName+MsgStrs[0]);
		return !ok;
	}
	for (var i=0; i< iv.length; i++){
		//ok = ok || (iv[i] < 0 || iv[i] > 255);
		ok = ok || !(iv[i] >= 0 && iv[i] <= 255);
	}
	
	ok = ok || (iv[0] < 1 || iv[0] >= 224);
	if (ok)
		alert(MsgHead[0]+ObjName+MsgStrs[15]);
	
	return (!ok) ;
}

function IsIpOK(Obj, ObjName) {//0.0.0.0~255.255.255.255 will return true
	var iv = Obj.value.split('.');
	var ok = iv.length != 4;
	if (ok) {
		alert(MsgHead[0]+ObjName+MsgStrs[0]);
		return !ok;
	}
	for (var i=0; i< iv.length; i++){
		//ok = ok || (iv[i] < 0 || iv[i] > 255);
		ok = ok || !(iv[i] >= 0 && iv[i] <= 255);
	}
	//ok = ok || (iv[iv.length - 1] < 1 || iv[iv.length-1] > 254);
	ok = ok || !(iv[iv.length - 1] >= 0 && iv[iv.length-1] <= 255);
	if (ok)
		alert(MsgHead[0]+ObjName+MsgStrs[10]);
	return (!ok) ;
}

function IsMtuOK(Obj, ObjName) {//42~9600 will return true
	if (Obj.value > 67 && Obj.value < 1579) {
		return true;
	}
	else{
		alert(MsgHead[0]+ObjName+MsgStrs[19]);
		return false;
	}
	

}

function IpAddrRangCnt(addr1, addr2) {
	var ip1 = addr1.split('.');
	var ip2 = addr2.split('.');
	var cnt_tmp = 0;
	var cnt = 0;
	
	for (var i=0; i< ip1.length; i++){
		cnt_tmp = (ip2[i] - ip1[i]);
		if((3-i)>=3)
			cnt_tmp=cnt_tmp*256;
		if((3-i)>=2)
			cnt_tmp=cnt_tmp*256;
		if((3-i)>=1)
			cnt_tmp=cnt_tmp*254;//except 0 & 255
			
		cnt += cnt_tmp;
	}
	return (cnt) ;
}

function NetMaskIsOK(Obj, ObjName) {
	if(!IsIpOK(Obj, ObjName))
		return false;
	var mask=IP2V(Obj.value);
	//alert(mask);
	var FirstSetBit=0;
	var MiddleUnSetBit=0;
	var i;
	for(i=0; i<32; i++){
		//alert(mask & 0x1);
		if((mask & 0x1)==1){
			if(FirstSetBit==0){
				FirstSetBit=1;
			}	
		}
		else{
			if(FirstSetBit!=0){
				MiddleUnSetBit=1;
			}
		}
		mask=mask>>>1;
	}

	if(MiddleUnSetBit!=0){
		alert(MsgHead[0]+ObjName+MsgStrs[9]) ;
		return false;
	}
	else
		return true;
}

function MacAddrIsOK(Obj, ObjName) {
/*
 *	3 standard (IEEE 802) formats:
 * 	0a:1b:3c:4d:5e:6f
 * 	0a-1b-3c-4d-5e-6f
 * 	0a1b.3c4d.5e6f
 */
	var str = Obj.value.toLowerCase();
	var j = 0;
	var mac_addr_1 = '';
	var mac_addr_2 = '';
	var regu = "^[0-9a-zA-Z]+$";       
	var re = new RegExp(regu);    

	regex=/^([0-9a-fA-F]{2}([:-]|$)){6}$|([0-9a-fA-F]{4}([.]|$)){3}$/i; 

	if ((regex.test(Obj.value)) || (re.test(Obj.value))){
		if(str.length != 17 && str.length != 14){
			alert("MAC Address length error");
			return false;
		}
		for(var i = 0; i < str.length; i++){	
			if(!(str.charCodeAt(i) >= 48 && str.charCodeAt(i) <= 57)){
				if(!(str.charCodeAt(i) >= 97 && str.charCodeAt(i) <= 102)){
					continue;	
				}
			}
			mac_addr_1	= mac_addr_1 + str.substring(i,i+1);
			if (j < 2)
				mac_addr_2	= mac_addr_2 + str.substring(i,i+1);
			j++;
		}
		if (mac_addr_1 == "ffffffffffff") {
			alert("MAC Address can not be brocast MAC Address");
			return false;
		}
		//if (mac_addr_2 == "01") {
		if (parseInt(mac_addr_2)%2 == 1) {		
			alert("MAC Address can not be multicast MAC Address");
			return false;
		}
		return true;
	} 
	else{ 
		alert(MsgHead[0]+ObjName+MsgStrs[13]);
		return false;
	}
}

function MacAddrIsNotNull(Obj) 
{
	var str = Obj.value.toLowerCase();
	var j = 0;
	var mac_addr = '';
	var regu = "^[0-9a-zA-Z]+$";       
	var re = new RegExp(regu);    

	regex=/^([0-9a-fA-F]{2}([:-]|$)){6}$|([0-9a-fA-F]{4}([.]|$)){3}$/i; 

	if ((regex.test(Obj.value)) || (re.test(Obj.value))){
		if(str.length != 17 && str.length != 14){
			alert("MAC Address length error");
			return false;
		}
		for(var i = 0; i < str.length; i++){	
			if(!(str.charCodeAt(i) >= 48 && str.charCodeAt(i) <= 57)){
				if(!(str.charCodeAt(i) >= 97 && str.charCodeAt(i) <= 102)){
					continue;	
				}
			}
			mac_addr	= mac_addr + str.substring(i,i+1);
		}
		if (mac_addr == "000000000000") {
			alert("MAC Address can not be 00:00:00:00:00:00");
			return false;
		}
		return true;
	} 
}

function MacAddrIsOK_Except_Muilticast_Broadcast(Obj, ObjName) {
/*
 *	3 standard (IEEE 802) formats:
 * 	0a:1b:3c:4d:5e:6f
 * 	0a-1b-3c-4d-5e-6f
 * 	0a1b.3c4d.5e6f
 */
	var str = Obj.value.toLowerCase();
	var j = 0;
	var mac_addr_1 = '';
	var mac_addr_2 = '';
	var regu = "^[0-9a-zA-Z]+$";       
	var re = new RegExp(regu);    

	regex=/^([0-9a-fA-F]{2}([:-]|$)){6}$|([0-9a-fA-F]{4}([.]|$)){3}$/i; 

	if ((regex.test(Obj.value)) || (re.test(Obj.value))){
		if(str.length != 17 && str.length != 14){
			alert("MAC Address length error");
			return false;
		}
		for(var i = 0; i < str.length; i++){	
			if(!(str.charCodeAt(i) >= 48 && str.charCodeAt(i) <= 57)){
				if(!(str.charCodeAt(i) >= 97 && str.charCodeAt(i) <= 102)){
					continue;	
				}
			}
			mac_addr_1	= mac_addr_1 + str.substring(i,i+1);
			if (j < 2)
				mac_addr_2	= mac_addr_2 + str.substring(i,i+1);
			j++;
		}
		return true;
	} 
	else{ 
		alert(MsgHead[0]+ObjName+MsgStrs[13]);
		return false;
	}
}

function fnAppendRow(tbl, list, data) {
	var rIdx = tbl.rows.length-(tbl.tHead ? tbl.tHead.rows.length : 0)-(tbl.tFoot ? tbl.tFoot.rows.length : 0);
	var objRow = document.createElement("tr");
	var objCel;
	objRow.className = rIdx%2 ? "r3" : "r4";
	for (var i in list) {
		objCel = document.createElement("td");
		objCel.innerHTML=eval('data.'+list[i]);
		objRow.appendChild(objCel);
	}
	tbl.tBodies[0].appendChild(objRow);
}

//======================================
// netstat.htm, wanstat.htm, vserver.htm, url.htm, upnp.htm, sfilter.htm, acfilter.htm
function fnGenTbody(tbl, data, list, fmt) {
	var i;
	var tobj = document.getElementById(tbl);
	if (tobj.tBodies.length == 0)
		tobj.appendChild(document.createElement("tbody"));
	for (i in data)
		fnGenRow(tobj, data[i], list, fmt);
}

function fnGenRow(tbl, data, list, fmt) {
	var rIdx = tbl.rows.length-(tbl.tHead ? tbl.tHead.rows.length : 0)-(tbl.tFoot ? tbl.tFoot.rows.length : 0);
	var objRow = document.createElement("tr");
	var objCel, objFmt;
	objRow.className = rIdx%2 ? "r3" : "r4";
	for (var i in list) {
		objFmt = eval('fmt.'+list[i]);
		sv = eval('data.'+list[i]);
		objCel = document.createElement("td");
		objCel.innerHTML = (objFmt) ? iGenField(objFmt, sv) : sv;
		objRow.appendChild(objCel);
	}
	tbl.tBodies[0].appendChild(objRow);
}

// - vserver.htm, url.htm, sfilter.htm, acfilter.htm
function iGenField(obj, val) {
	var s;
	if (obj.length) {
		s = '';
		for (var j in obj)
			s += (obj[j].type == 'select') ? iGenSelect(obj[j], val[j]) : iGenInput(obj[j], val[j]);
	} else
		s = (obj.type == 'select') ? iGenSelect(obj, val) : iGenInput(obj, val);
	return s;
}

// - sfilter.htm, url.htm, acfilter.htm
function fnGenSelect(obj, val) {
	document.write(iGenSelect(obj, val));
}
function iGenSelect(sel, val) {
	var s = '';
	for (var i in sel)
		switch (i) {
		case 'type':
			s = '<select ' + s;
			break;
		case 'option':
			var opt = sel[i];
			for (var j in opt)
				s += '><option value="'+opt[j].value+(opt[j].value==val? '" selected' : '"')+'>'+opt[j].text+'</option';
			break;
		default:
			s += ' '+i+'="'+sel[i]+'"';
			break;
		}
	s += '></select>';
	return s;
}

// - vserver.htm, url.htm, sfilter.htm, acfilter.htm
function iGenInput(obj, val) {
	var s = "";
	for (var i in obj)
		if (i != 'text')
			s += " "+i+"='"+obj[i]+"'";

	if (obj.type) {
		switch (obj.type) {
		case 'radio':
			if (obj.value==val)
				s += " checked" ;
			break;
		case 'checkbox':
			if (!(val==''||val=='0'))
				s += " checked" ;
			break;
		case 'password':
		case 'text':
			s += " value='"+val+"'";
			break;
		default:
			break;
		}
		s = "<input"+s+">"+obj.text;
	}
	return s;
}

// = snmp.htm, syslog.htm, spapp.htm
function iGenSel2(slnm, slid, opt) {
	document.write('<select size=1 name="' +slnm+ '" id=' +slid+ '>');
	for (var i in opt)
		document.write('<option value='+opt[i].value+'>'+opt[i].text+'</option>');
	document.write('</select>');
}

function iGenSel2_with_width(slnm, slid, opt, width) {
	document.write('<select style="width:'+width+'px;" size=1 name="' +slnm+ '" id=' +slid+ '>');
	for (var i in opt)
		document.write('<option value='+opt[i].value+'>'+opt[i].text+'</option>');
	document.write('</select>');
}

function iGenSel2StrDisabled(slnm, slid, opt) {
	var s;
		s='<select size=1 name="' +slnm+ '" id=' +slid+ ' disabled="true">';
	for (var i in opt)
		s+='<option value='+opt[i].value+'>'+opt[i].text+'</option>';
	s+='</select>';
	return s;
}
function iGenSel2Str(slnm, slid, opt) {
	var s;
		s='<select size=1 name="' +slnm+ '" id=' +slid+ '>';
	for (var i in opt)
		s+='<option value='+opt[i].value+'>'+opt[i].text+'</option>';
	s+='</select>';
	return s;
}
//'onchange="' +changeFUN+ '(this.selectedIndex);"'
function iGenSel3(slnm, slid, opt, changeFUN){
	document.write('<select size=1 name="' +slnm+ '" id=' +slid+ ' onchange="' +changeFUN+ '(this.selectedIndex)">' );
	for (var i in opt)
		document.write('<option value='+opt[i].value+'>'+opt[i].text+'</option>');
	document.write('</select>');
}
function iGenSel3_with_width(slnm, slid, opt, changeFUN, width){
	document.write('<select style="width:'+width+'px;" size=1 name="' +slnm+ '" id=' +slid+ ' onchange="' +changeFUN+ '(this.selectedIndex)">' );
	for (var i in opt)
		document.write('<option value='+opt[i].value+'>'+opt[i].text+'</option>');
	document.write('</select>');
}

//change by item
function iGenSel4Str(slnm, slid, opt, changeFUN){
	var s;
		s='<select size=1 name="' +slnm+ '" id=' +slid+ ' onchange="' +changeFUN+ '(this)">';
	for (var i in opt)
		s+='<option value='+opt[i].value+'>'+opt[i].text+'</option>';
	s+='</select>';
	return s;
}

//'onchange="' +changeFUN+ '(this.selectedIndex);"'
function iGenSel4(slnm, slid, opt, changeFUN){
	document.write('<select size=1 name="' +slnm+ '" id=' +slid+ ' onchange="' +changeFUN+ '(this)">' );
	for (var i in opt)
		document.write('<option value='+opt[i].value+'>'+opt[i].text+'</option>');
	document.write('</select>');
}


// For Form and Lists edit
function fnGetSelText(val, sobj) {
	for (var j in sobj)
		if (sobj[j].value == val)
			return sobj[j].text;
}

function ChgColor(name, max, row) {
	for (var i=0; i<max; i++)
		document.getElementById(name+i).className = (i==row ? "rh" : (i%2 ? "r3" : "r4"));
}

function fnAdd(form) {
	if (form.idx)
		form.idx.value = -1;
}

function fnChgUniq(obj, data) {
	var form = obj.form;
	var va = data[form.idx.value];
	if (va)
		form.btnD.disabled = obj.value!=va[obj.id];
}

function isInit(fld) {
	var inited = document.getElementById(fld);
	if (inited) {
		var oldv = inited.value;
		inited.value=true;
		return oldv;
	}
	return false;
}
//======================================
//- primary.htm

function fnLoadForm(form, fdata, type, dflt) {
	
	var nm, fd;
	if (!fdata) {
		if (!dflt)
			var dflt = {};
		for (nm in type) {
			if (!dflt[nm]) {
				switch (type[nm]) {
				case 7:
					dflt[nm]='00-00-00-00-00-00';
					break;
				case 6:
					dflt[nm]='255.255.255.0';
					break;
				case 5:
					dflt[nm]='0.0.0.0';
					break;
				case 1:
					dflt[nm]='0';
					break;
				default:
					dflt[nm]='';
					break;
				}
			}
		}
		if (form.btnD)
			form.btnD.disabled = (!fdata);
		if (form.btnU)
			form.btnU.disabled = (!fdata);
	}
	var data = fdata?fdata:dflt;	
	for (nm in data) {
		fd = form[nm];
		if (!fd) {
			//alert('Field:'+nm+' not defined in Form:'+form);
			continue;
		}
		var input_type=undefined;
		if(fd.type){
			input_type = fd.type;
		}else if(fd[0]){
			input_type = fd[0].type;			
		}
		switch (input_type){
			case "radio":
				for (i=0; i < fd.length; i++)
					fd[i].checked = fd[i].value==data[nm];
				break;
			case "checkbox":
				fd.checked = !(data[nm]==''||data[nm]=='0');
				break;
			case "select-one":
				for (var i=0; i <fd.length; i++) {
					if (fd[i].value == data[nm])
						fd.selectedIndex = i;
				}
				break;
			case "text":
			case "password":
				fd.value = data[nm];
				break;
			default:
				fd.value = data[nm];
				break;
		}
		/*switch (type[nm]) {
		case 7:		// text with MAC pattern
		case 6:		// text with IP mask pattern
		case 5:		// text with IP pattern
		case 4:		// text, password, hidden
			fd.value = data[nm];
			break;
		case 3:		// checkbox
			fd.checked = !(data[nm]==''||data[nm]=='0');
			break;
		case 2:		// select
			for (var i=0; i <fd.length; i++) {
				if (fd[i].value == data[nm])
					fd.selectedIndex = i;
			}
			break;
		case 1:		// radio button
			for (i=0; i < fd.length; i++)
				fd[i].checked = fd[i].value==data[nm];
			break;
		default:
			alert('Type '+type[nm]+' not yet support.');
			break;
		}*/
	}

	for (nm in data) {
		fd = form[nm];
		if (fd && fd.onchange)
			fd.onchange();		
		}		
}

function fnChkChg(form, data, type) {
	var nm, fd;
	var DataChg=false;
	for (nm in type) {
		fd = form[nm];
		switch (type[nm]) {
		case 4:		// text, password, hidden
			if (fd.value != data[nm])
				DataChg=true;
			break;
		case 3:		// checkbox
			if (fd.checked == ((data[nm]=='')||(data[nm]=='0')))
				DataChg=true;
			break;
		case 2:		// select
			i = fd.selectedIndex;
			if (fd[i].value!= data[nm])
				DataChg=true;
			break;
		case 1:		// radio button
			for (i=0; i < fd.length; i++)
				if (fd[i].checked && (fd[i].value!=data[nm]))
					DataChg=true;
			break;
		default:
			break;
		}
	}
	return DataChg;
}

function ipadd(initip, iprange)
{
	//var x = "192.168.127";
	//x += "." + 25;
	var x="";
	var ipclass="";
	var ipnum=0;
	var addedip="";
	var j,k=0;
	for(j=0;j<initip.length; j++){
		if(k==3)
			x += initip.charAt(j);
		else{
			ipclass += initip.charAt(j);
			if(initip.charAt(j)==".")
				k++;
		}
	}
	ipnum=parseInt(x)+parseInt(iprange);
	addedip = ipclass + (parseInt(x)+parseInt(iprange));
	return addedip;
}

function getiprange(ipstart, ipend)
{
	var j, k=0;
	var ipnum1="";
	var ipnum2="";
	var ipscope=0;
	for(j=0;j<ipstart.length; j++){
		if(k==3)
			ipnum1 += ipstart.charAt(j);
		else{
			if(ipstart.charAt(j)==".")
				k++;
		}
	}
	k=0;
	for(j=0;j<ipend.length; j++){
		if(k==3)
			ipnum2 += ipend.charAt(j);
		else{
			if(ipend.charAt(j)==".")
				k++;
		}
	}
	ipscope = parseInt(ipnum2)-parseInt(ipnum1);
//	alert(ipscope);
	return ipscope;
}


function fnIp2Array(ipstr) {
	var iv = ipstr.split('.');
	var il = iv.length;
	if ( il > 1 && il < 4) {
		var a0 = iv.shift();
		for (i = 0; i< 4-il ; i++)
			iv.unshift( '0' );
		iv.unshift( a0 );
	}
	return iv;
}

function fnIp2Net(ipstr, mkstr) {
	var iv = fnIp2Array(ipstr);
	var mv = fnIp2Array(mkstr);
	var val = 0;
	for (var i=0; i<4; i++)
		val = val * 256 + Number(iv[i] & mv[i]);
	return val;
}

function SerIpRangeCheck(ip_lo, ip_hi, MAX){
	var ip1 = fnIp2Net(ip_lo, "255.255.255.255");
	var ip2 = fnIp2Net(ip_hi, "255.255.255.255");
	var ret=1;
	if(!((ip2 - ip1 <= MAX) && (ip2 - ip1 >= 0))){
		alert("IP Range must less than "+MAX);
		ret = 0;
	}
	return ret;
}

function tableaddRowHidden(tablename, idx, data, align)
{
	var i, j;
	var cell;
	var row;
		
	table = document.getElementById(tablename);
	row = table.insertRow(table.getElementsByTagName("tr").length);


	for(i=0 ; i < data.length; i++){
		cell = document.createElement("td");
		cell.innerHTML = data[i];	
		row.appendChild(cell);
	}

	row.style.Color = "white";
	row.className = "r1";
	row.align=align;
    row.style.display="none";
}

function tableaddRowHidden_2(tablename, idx, data, align)
{
	var i, j;
	var cell;
	var row;
		
	table = document.getElementById(tablename);
	row = table.insertRow(table.rows.length);


	for(i=0 ; i < data.length; i++){
		cell = document.createElement("td");
		cell.innerHTML = data[i];	
		row.appendChild(cell);
	}
	
	row.style.Color = "black";
	row.className = "r1";
	row.align=align;
    row.style.display="none";

}



function tableaddRow(tablename, idx, data, align)
{
	var i, j;
	var cell;
	var row;
		
	table = document.getElementById(tablename);
	row = table.insertRow(table.rows.length);


	for(i=0 ; i < data.length; i++){
		cell = document.createElement("td");
		cell.innerHTML = data[i];	
		row.appendChild(cell);
	}
	
	row.style.Color = "black";
	row.className = "r1";
	row.align=align;
	//row.style.backgroundColor = "white";
	//var k=i+1;
	//row.id = 'tri'+i;
	//var form = this.form;
	//var formidx = this.formidx;
	//var data = this.data;
	//var type = this.type;
	//row.onclick=function(){RowEdit(this,form,formidx,data,type)};
	//row.style.cursor=ptrcursor;
	//row.align="center";
} 

function main_tableaddRow(tablename, idx, data, align)
{
	var i, j;
	var cell;
	var row;
		
	table = document.getElementById(tablename);
	row = table.insertRow(table.rows.length);


	for(i=0 ; i < data.length; i++){
		cell = document.createElement("td");
		cell.innerHTML = data[i];	
		row.appendChild(cell);
	}
	
	row.style.Color = "black";
	row.align=align;
	//row.style.backgroundColor = "white";
	//var k=i+1;
	//row.id = 'tri'+i;
	//var form = this.form;
	//var formidx = this.formidx;
	//var data = this.data;
	//var type = this.type;
	//row.onclick=function(){RowEdit(this,form,formidx,data,type)};
	//row.style.cursor=ptrcursor;
	//row.align="center";
} 

function GetRadioValue(allNodes){
  for(var i=0; i<allNodes.length; i++)
  	if(allNodes[i].checked)
		return(allNodes[i].value);
  return(null);
}

function ipMask2Number(mask){
	var mask=IP2V(mask);
	var SetBit=0;
	var i;
	for(i=0; i<32; i++){
		//alert(mask & 0x1);
		if((mask & 0x1)==1){
			SetBit++;
		}		
		mask=mask>>>1;
	}
	return SetBit;
	
}



function Number2Ip(number) {

 var ip=number%256;
 for (var i=1;i<=3;i++)
 {
   number=Math.floor(number/256);
   ip=number%256+'.'+ip;
 }
 return ip; // As string
}

function Number2ipMask(SetBit){
	var mask=0;
	var i;
	
	for(i=0; i<32; i++){
		mask=mask*2	
		if(i<SetBit){
			mask=mask+1
		}
	}
	return Number2Ip(mask);
}




function stopSubmit()
{
	return false;
}
/*
	table_set_diff_show:
		¥Î©óTable­nSHOW¥Xªºentries»P¨Ï¥ÎªÌ¿é¤Jªºentries¤£¦P
		§Q¥Îtype¨Ó°µ°Ï§O

	table_show:
		¥Î©óTable­nSHOW¥Xªºentries»P¨Ï¥ÎªÌ¿é¤Jªºentries¬Û¦P

*/

function table_set_diff_show(form, tablename, type, data, formidx, newdata, add1, showentry, entryinit){
	this.formidx = formidx;
	this.form = form;
	this.tablename=tablename;
	this.type = type;
	this.data = data;
	this.newdata = newdata;
	this.add = tAdd;
	this.del = tDel;
	this.mod = tModify;
	this.arow = adddiffRow;
	this.add1 = add1;
	this.entinit = entryinit;
	this.reload = tReload;
	this.show = tShow;
	this.redit = RowEdit;
	this.entry = showentry;	
}

function table_show(form, tablename, type, data, formidx, newdata, add1, entryinit){
	this.formidx = formidx;
	this.form = form;
	this.tablename=tablename;
	this.type = type;
	this.data = data;
	this.newdata = newdata;
	this.add = tAdd;
	this.del = tDel;
	this.mod = tModify;
	this.arow = addRow;
	this.add1 = add1;
	this.reload=tReload;
	this.show=tShow;
	this.redit=RowEdit
	this.entinit = entryinit;
}

function tReload(){
	var table = document.getElementById(this.tablename);
	var rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 0)
	{
		for(i=rows.length-1; i > 1; i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(i=0; i < this.data.length; i++)
	{
		this.add1(0,i);
		this.arow(i);
	}
}

function adddiffRow(i)
{
	var j;
	var form;
	var formidx;
	var data;
	var type;
		
	var table = document.getElementById('show_available_table');
	var row = table.insertRow(table.getElementsByTagName("tr").length);
	/* original */
	/*
	for(j in this.entry){
		cell = document.createElement("td");
		cell.innerHTML = this.newdata[j];
		row.appendChild(cell);
	}
	*/
	
	/* new modify */
	for(j in this.entry){	
		cell = document.createElement("td");
		if(j == "my_idx")
			cell.innerHTML = i+1;
		else
			cell.innerHTML = this.newdata[j];
		row.appendChild(cell);
	}
	
	row.style.Color = "black";
	//row.style.backgroundColor = "white";
	var k=i+1;
	row.id = 'tri'+i;
	var form = this.form;
	var formidx = this.formidx;
	var data = this.data;
	var type = this.type;
	var entinit = this.entinit;
	
	row.onclick=function(){RowEdit(this,form,formidx,data,type,entinit)};
	row.style.cursor=ptrcursor;
	row.align="center";
} 


function addRow(i)
{
	var j;
	var form;
	var formidx;
	var data;
	var type;
		
	var table = document.getElementById(this.tablename);
	var row = table.insertRow(table.getElementsByTagName("tr").length);
	var cell;
	for(j=0 ; j < this.newdata.length; j++){
		cell = document.createElement("td");
		cell.innerHTML = this.newdata[j];		
		row.appendChild(cell);
	}
	
	row.style.Color = "black";
	//row.style.backgroundColor = "white";
	var k=i+1;
	row.id = 'tri'+i;
	var form = this.form;
	var formidx = this.formidx;
	var data = this.data;
	var type = this.type;
	var entinit = this.entinit;
	row.onclick=function(){RowEdit(this,form,formidx,data,type,entinit)};
	row.style.cursor=ptrcursor;
	row.align="center";
} 

var nowrow=0;
function tNowrow_Get()
{
	return nowrow-2;
}
function tAdd()
{
	var i;
	var j;
	var type;	

	nowrow = this.data.length++;
	this.data[nowrow]=new Array();	
	
	j = 0;
	for (i in this.type){
		/*if(this.form[this.formidx][i].length>1){
			type = this.form[this.formidx][i][0].type;
		}else{
			type = this.form[this.formidx][i].type;
		}*/

		/* if this variable is exist. */
		if(typeof document.getElementsByName(i)[0] != 'undefined'){
			
			type = document.getElementsByName(i)[0].type;
			if(type=="checkbox"){
			//if(this.type[i] == 3){
				if(this.form[this.formidx][i].checked==true)
						this.data[nowrow][i]=1;
					else
						this.data[nowrow][i]=0;
				continue;	
			}
			//if(this.type[i] == 1){
			if(type=="radio"){
				this.data[nowrow][i] = GetRadioValue(this.form[this.formidx][i]);
				continue;
			}
			this.data[nowrow][i] = this.form[this.formidx][i].value;
		}
	}
	
	this.reload();	
	ChgColor('tri', this.data.length, this.data.length-1);	
	nowrow = (this.data.length-1+2);
}

function tDel()
{	
	var table = document.getElementById(this.tablename);
	var rows = table.getElementsByTagName("tr");
	if(nowrow - 2 > rows.length - 1 )
		return;
	this.data.splice(nowrow - 2,1);		
	this.reload();
	ChgColor('tri', this.data.length, nowrow);
	rows = table.getElementsByTagName("tr");
	if(nowrow >= rows.length){
		if(rows.length > 2){
			nowrow = rows.length-1;
		}else{			
			fnLoadForm(this.form[this.formidx], this.data[0], this.type);
			if(this.entinit != 0){
				this.entinit(-1);
			}
			return;
		}
	}
	RowEdit(rows[nowrow],this.form,this.formidx,this.data,this.type, this.entinit);
}


function RowEdit(row, form, idx, data, type, entinit) 
{	
	var rowidx = row.rowIndex - 2;	
	chooseOne(rowidx);
	fnLoadForm(form[idx], data[rowidx], type);	
	ChgColor('tri', data.length, rowidx);
	nowrow = rowidx + 2;	
	if(entinit != 0){
		entinit(rowidx);
	}
}

function tModify()
{	
	var i, type;
	for (i in this.type){
		//if(this.type[i] == 3){
		/*if(this.form[this.formidx][i].length>1){
			type = this.form[this.formidx][i][0].type;
		}else{
			type = this.form[this.formidx][i].type;
		}*/
		/* if this variable is exist. */
		if(typeof document.getElementsByName(i)[0] != 'undefined'){
			type = document.getElementsByName(i)[0].type;
			if(type=="checkbox"){
				if(this.form[this.formidx][i].checked==true)
						this.data[nowrow - 2][i]=1;
					else
						this.data[nowrow - 2][i]=0;
				continue;	
			}
			//if(this.type[i] == 1){		
			if(type=="radio"){			
				this.data[nowrow - 2][i] = GetRadioValue(this.form[this.formidx][i]);
				continue;
			}
			this.data[nowrow - 2][i] = this.form[this.formidx][i].value;
		}
	}
	
	var table = document.getElementById(this.tablename);
	var rows = table.getElementsByTagName("tr");
	this.reload();
	ChgColor('tri', this.data.length, nowrow-2);	
}

function tShow() {
	var table = document.getElementById(this.tablename);
	var rows = table.getElementsByTagName("tr");
	//delete added the table members
	if(rows.length > 0)
	{
		for(var i=rows.length-1 ;i>1;i--)
		{
			table.deleteRow(i);
		}
	}
	//re-join the array elements to the table
	for(var i=0; i<this.data.length; i++)
	{
		this.add1(0,i);
		this.arow(i);		
	}
	nowrow = 2;
	ChgColor('tri', this.data.length, 0);
}

function chooseOne(cb)
{
  var obj = document.getElementsByName("cbox");
  for (i=0; i<obj.length; i++)
  {
    if (i!=cb){
		obj[i].checked = false;
    }else{  
		obj[i].checked = true;
    }
  }
}

function IP2V(ip) 
{ 
	ip=ip.split(".");
	//alert("IP­È¬O¡G"+(ip[0]*255*255*255+ip[1]*255*255+ip[2]*255+ip[3]*1)); 
	return (ip[0]*256*256*256+ip[1]*256*256+ip[2]*256+ip[3]*1);
}  

/*
¥Î³~¡GÀË¬d¿é¤J¦r²Å¦ê¬O§_?ªÅ©ÎªÌ¥þ³¡³£¬OªÅ®æ
¿é¤J¡Gstr
ªð¦^¡G
¦pªG¥þ¬OªÅªð¦^true,§_«hªð¦^false
*/
function isNull(str) {
	if (str == "") 
		return true;
	var regu = "^[ ]+$";
	var re = new RegExp(regu);
	return 
		re.test(str);
} 

/*
¥Î³~: ÀË¬dip¦a§}ªº®æ¦¡
¿é¤J: strIP:IP¦ì§}
ªð¦^: ¦pªG³q¹LÅçÃÒªð¦^true,§_«hfalse
*/
function isIP(strIP) {
	var re = /^((\d)|(([1-9])\d)|(1\d\d)|(2(([0-4]\d)|5([0-5]))))\.((\d)|(([1-9])\d)|(1\d\d)|(2(([0-4]\d)|5([0-5]))))\.((\d)|(([1-9])\d)|(1\d\d)|(2(([0-4]\d)|5([0-5]))))\.((\d)|(([1-9])\d)|(1\d\d)|(2(([0-4]\d)|5([0-5]))))$/;
 
	if(re.test(strIP))
		return true;
 	else  
  		return false;
}

/*
¥Î³~¡GÀË¬d¿é¤J¦r²Å¦ê¬O§_²Å¦X¥¿¾ã¼Æ®æ¦¡
®Ñ¤J¡G
s¡G¦r²Å¦ê
ªð¦^¡G
¦pªG³q¹LÅçÃÒªð¦^true,§_«hªð¦^false
 
*/
function isNumber(s){
	if(s!=""){
        var r,re;
        re = /\d*/i; //\dªí¥Ü?¦r,*ªí¥Ü¤Ç°t¦h??¦r
        r = s.match(re);
        return (r==s)?true:false;
    }
    return false;
} 

function isMetric(Obj, ObjName){
	if(!isNumber(Obj.value)){
		alert(MsgHead[0]+ObjName+MsgStrs[7]);
		return false;
	}
	else{
		if(Obj.value>255 || Obj.value<1){
			alert(MsgHead[0]+ObjName+MsgStrs[12]);
			return false
		}
		return true;
	}
}

/*
¥Î³~¡GÀË¬d¿é¤J¹ï¶Hªº­È¬O§_²Å¦XºÝ¤f¸¹®æ¦¡
¿é¤J¡Gstr¿é¤Jªº¦r²Å¦ê
ªð¦^¡G¦pªG³q¹LÅçÃÒªð¦^true,§_«hªð¦^false
 
*/
function isPort(Obj, ObjName){
	if(!isNumber(Obj.value)){
		alert(MsgHead[0]+ObjName+MsgStrs[2]) ;
		return false;
	}
	else{
		if(Obj.value>65535 || Obj.value<1){
			alert(MsgHead[0]+ObjName+MsgStrs[2]) ;
			return false;
		}
		else
			return true;
	}
}
function ipRange(Obj1, Obj2, ObjName){
	if(IpAddrRangCnt(Obj1.value, Obj2.value)<0){
		alert(MsgHead[0]+ObjName+MsgStrs[3]) ;
		return 0;
	}
	return 1;
}

function PortRangCnt(t1, t2)
{
	var t;
	t = t2-t1;
	return t;
}

function portRange(Obj1, Obj2, ObjName){
	if(PortRangCnt(Obj1.value, Obj2.value)<0){
		alert(MsgHead[0]+ObjName+MsgStrs[4]) ;
		return false;
	}
	return true;
}

function IndexRange(index, data)
{
	if(!isNumber(index)){
		alert(MsgHead[0]+"Index"+MsgStrs[7]) ;
		return -1
	}
	if(index > (data.length+1) || index < 1){
		alert("Index error/Index must be 1-128");
		return -1;
	}
	return 1;
}

function MoveIndexRange(index, data)
{
	if(!isNumber(index)){
		alert(MsgHead[0]+"Index"+MsgStrs[7]) ;
		return -1
	}
	if(index > (data.length) || index < 1){
		alert("Index error/Index must be 1-128");
		return -1;
	}

	return 1;
}

function IndexRangeAndInputRange(index, data, min, max)
{
	if(!isNumber(index)){
		alert(MsgHead[0]+"Index"+MsgStrs[7]) ;
		return -1
	}
	if(index > (data.length+1) || index < 1){
		alert("Index error/Index must be "+ min +"-" + max);
		return -1;
	}
	return 1;
}

function MoveIndexRangeAndInputRange(index, data, min, max)
{
	if(!isNumber(index)){
		alert(MsgHead[0]+"Index"+MsgStrs[7]) ;
		return -1
	}
	if(index > (data.length) || index < 1){
		alert("Index error/Index must be "+ min +"-" + max);
		return -1;
	}

	return 1;
}


var REGEX_PATTERN_EMAIL_ADDR = "^[_a-zA-Z0-9-]+(\\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))$";


/*
	§PÂ_¬O§_¬°¦XªkªºMail Address
	¦Xªk¦^¶Ç:	0
	¤£¦Xªk¦^¶Ç:	1
*/
function isMailAddress(obj, ObjName){
	var TempObj;
	TempObj=obj.value;
	//TempObj=TempObj.replace(' ', '');
	var regu = REGEX_PATTERN_EMAIL_ADDR;       
	var re = new RegExp(regu);    
	if (re.test( TempObj ) ) {    
		return 0;    
	} 
	else{   
		alert(MsgHead[0]+ObjName+" Not in correct format");
		return 1;    
	}
}


/*
	§PÂ_¬O§_¬°¦Xªkªº²Å¸¹(a~z, A~Z, 0~9, '.', '-', '_', '@')
	¦Xªk¦^¶Ç:	0
	¤£¦Xªk¦^¶Ç:	1
*/
function isSymbol(obj, ObjName){
	var TempObj;
	TempObj=obj.value;
	//TempObj=TempObj.replace(' ', '');
	var regu = "^[0-9a-zA-Z_@!#$%^&*()\.\-]+$";       
	var re = new RegExp(regu);    
	if (re.test( TempObj ) ) {    
		return 0;    
	} 
	else{   
		alert(MsgHead[0]+ObjName+MsgStrs[5]);
		return 1;    
	}
}

function isDomain(Obj, ObjName)
{
	var mai = Obj.value;
	var val = true;

	var dot = mai.lastIndexOf(".");
	var dname = mai.substring(0,dot);
	var ext = mai.substring(dot,mai.length);
		
	for(var j=0; j<dname.length; j++){
		var dh = dname.charAt(j);
		var hh = dh.charCodeAt(0);
		if((hh > 47 && hh<58) || (hh > 64 && hh<91) || (hh > 96 && hh<123) || hh==46 || hh==64 || hh==95 || hh==44){
		}
		else{
			alert(MsgHead[0]+ObjName+MsgStrs[6]);
			return false;
		}
	}	
	return true;
}

function IsInRange(Obj, ObjName, num1, num2)
{
	if(!isNumber(Obj.value)){
		alert(MsgHead[0]+ObjName+MsgStrs[7]);
		return false;
	} else {
		if(Obj.value > num2){
			alert(MsgHead[0]+ObjName+MsgStrs[11]+'Must be '+num1+'~'+num2+'. ');
			return false;
		}
		if(Obj.value < num1){
			alert(MsgHead[0]+ObjName+MsgStrs[11]+'Must be '+num1+'~'+num2+'. ');
			return false;
		}
		return true;
	}
}



function QoSLikeCheckFormat(form)
{
	var error=0;
	if(form.tSel.value=='ipqos'){ // by ip
		if(form.SrcIPSel.value=='single'){
			if(!IpAddrIsOK(form.ip1, 'Source IP')){
				error=1;
			}
		}
		else if(form.SrcIPSel.value=='range'){
			if(!IpAddrIsOK(form.ip2, 'Source IP Range (initial)')){
				error=1;
			}
			if(!IpAddrIsOK(form.ip3, 'Source IP Range (end)')){
				error=1;
			}
			if(!ipRange(form.ip2, form.ip3, 'Source')){
				error=1;
			}
		}
		
		if(form.DstIPSel.value=='single'){
			if(!IpAddrIsOK(form.ip4, 'Destination IP')){
				error=1;
			}
		}
		else if(form.DstIPSel.value=='range'){
			if(!IpAddrIsOK(form.ip5, 'Destination IP Range (initial)')){
				error=1;
			}
			if(!IpAddrIsOK(form.ip6, 'Destination IP Range (end)')){
				error=1;
			}
			if(!ipRange(form.ip5, form.ip6, 'Destination')){
				error=1;
			}
		}
	}
	else{
		if(!MacAddrIsOK(form.mac, 'Mac Address')){
			error=1;
		}
	}
	if(form.prot.value==2 || form.prot.value==3){
		if(form.SrcPortSel.value=='single'){
			if(!isPort(form.port1, 'Source Port')){
				error=1;
			}
		}
		else if(form.SrcPortSel.value=='range'){
			if(!isPort(form.port2, 'Source Port Range (initial)')){
				error=1;
			}
			if(!isPort(form.port3, 'Source Port Range (end)')){
				error=1;
			}
			if(!portRange(form.port2, form.port3, 'Source')){
				error=1;
			}
		}
		if(form.DstPortSel.value=='single'){

			if(!isPort(form.port4, 'Destination Port')){
				error=1;
			}
		}
		else if(form.DstPortSel.value=='range'){
			
			if(!isPort(form.port5, 'Destination Port (initial)')){
				error=1;
			}
			if(!isPort(form.port6, 'Destination Port (end)')){
				error=1;
			}
			if(!portRange(form.port5, form.port6, 'Destination')){
				error=1;
			}
		}
	}
	return error;
}


function PasswordLikeCheckFormat(form)
{
	var error=0;

	if( !isNull(form.old_pw.value) && isSymbol(form.old_pw, "Old Password") ){
		error=1;
	}
	if( !isNull(form.new_pw.value) && isSymbol(form.new_pw, "New Password") ){
		error=1;
	}
		
	return error;
}

function makeRequest(url, alertContents, sync) {
    var http_request = false;

    if (window.XMLHttpRequest) { // Mozilla, Safari,...
      http_request = new XMLHttpRequest();
    } else if (window.ActiveXObject) { // IE
      try {
        http_request = new ActiveXObject("Msxml2.XMLHTTP");
      } catch (e) {
        try {
          http_request = new ActiveXObject("Microsoft.XMLHTTP");
        } catch (e) {}
      }
    }

    if (!http_request) {
      //alert('Giving up :( Cannot create an XMLHTTP instance');
      return false;
    }
    // ©w¸q¨Æ¥ó³B²z¨ç¼Æ¬° alterContents()	
    http_request.onreadystatechange = function() {alertContents(http_request); };	
	if(sync==0){
		http_request.open('GET', url, true);
	}else{
		http_request.open('GET', url, false);
	}
	http_request.setRequestHeader("If-Modified-Since","0");
    http_request.send(null);
}


function duplicate_check(idx, wdata, item, form_value, alertinfo){
	for(var i = 0; i < wdata.length; i++){		
		if(wdata[i][item] == form_value){
			if(idx == i){
				continue;
			}
			alert(alertinfo);
			return -1;
		}
	}
	return 1;
}

function subnet_duplicate_check(idx, wdata, ipname, maskname, form_ip, form_mask, alertinfo){
	var form_subnet = (IP2V(form_ip)&IP2V(form_mask));
	for(var i = 0; i < wdata.length; i++){		
		if((IP2V(wdata[i][ipname])&IP2V(wdata[i][maskname])) == form_subnet){
			if(idx == i){
				continue;
			}
			if(alertinfo!=0){
				alert(alertinfo);
			}			
			return -1;
		}
	}
	return 1;
}

function subnet_mapping_check(idx, wdata, ipname, maskname, form_ip, form_mask){
	var form_subnet = (IP2V(form_ip)&IP2V(form_mask));
	if((IP2V(wdata[idx][ipname])&IP2V(wdata[idx][maskname])) == form_subnet){			
		return 1;
	}

	return -1;
}

function mac_format(mac_addr){	
	var j = 0;
	var str = mac_addr.toLowerCase();
	mac_addr = '';

	for(var i = 0; i < str.length; i++){	
		if(!(str.charCodeAt(i) >= 48 && str.charCodeAt(i) <= 57)){
			if(!(str.charCodeAt(i) >= 97 && str.charCodeAt(i) <= 102)){
				continue;	
			}
		}
		
		if((j+1)%3 == 0 && j > 0){
			mac_addr= mac_addr + ':';
			j++;
		}		
		mac_addr = mac_addr + str.substring(i,i+1);
		j++;
		//alert(mac_addr);
	}
	return mac_addr;
}

function IsMinBwLessThanTotol(Obj1, Obj2, FuncName, PrioName, ObjName1, ObjName2) 
{
	if(isNumber(Obj1.value)){
		if(isNumber(Obj2.value)){
			if(parseInt(Obj1.value) <= parseInt(Obj2.value)){
				return true;
			}
			else{
				alert(MsgHead[0]+FuncName+PrioName+ObjName1+' can\'t more than '+ObjName2);
				return false;
			}
		}
		else{
			alert(MsgHead[0]+FuncName+PrioName+ObjName2+MsgStrs[7]);
			return false;
		}
	}
	else{
		alert(MsgHead[0]+FuncName+PrioName+ObjName1+MsgStrs[7]);
	}
}

function IsMinBwNatual(Obj1, FuncName, PrioName, ObjName1)
{
	if(parseInt(Obj1.value)<1){
		alert(MsgHead[0]+FuncName+PrioName+ObjName1+'can\'t less than 1');
		return false
	}
	else
		return true;
}


function CheckFlag(CheckedValue, MaskNumber)
{
	var temp;
	temp = (CheckedValue % (MaskNumber*10) - CheckedValue%MaskNumber )/MaskNumber;

	return temp;
}

var DSYS_PTYPE_SPEED_MEGA =	0x00; /* 00 */
var DSYS_PTYPE_SPEED_GIGA = 0x01; /* 01 */
var DSYS_PTYPE_SPEED_10   = 0x02; /* 02 */
var DSYS_PTYPE_SPEED_10G  = 0x03; /* 03 */
var	DSYS_PTYPE_SPEED_MASK =	0x03;

var DSYS_PTYPE_TYPE_COPPER = 0x00; /* 00 */
var DSYS_PTYPE_TYPE_FIBER  = 0x04; /* 01 */
var DSYS_PTYPE_TYPE_COMBO  = 0x08; /* 10 */
//#define DSYS_PTYPE_TYPE_10G 	0x10 /* 100 */

function	EDR_IF_IS_FIBER(port,p){
	return (parseInt(port[p].type) & DSYS_PTYPE_TYPE_FIBER);
}	

function	EDS_IF_IS_GIGA(port,p){		
	return ((parseInt(port[p].type) & DSYS_PTYPE_SPEED_MASK) == DSYS_PTYPE_SPEED_GIGA);
}
function	EDS_IF_IS_COMBO(port,p){
	return (parseInt(port[p].type) & DSYS_PTYPE_TYPE_COMBO);
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
	return null;
}

function web_cookie_erase(name) {
	web_cookie_create(name,"",-1);
}

