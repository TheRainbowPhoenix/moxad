// -----------------------
// Bebin of Debug Section
// -----------------------
var debug=false;
function fnShowProp(name, obj) {}
function fnAlertProp(name, obj) {}

var ptrcursor = (document.all) ? 'hand' : 'pointer';

// -----------------------
// End of Debug Section
// -----------------------
var MsgHead = ['Error: ', 'Warning: '];
var MsgStrs = [
	' IP Address less than 4 element.',
	' IP Address element value must be 0~255.'
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
			write('<a href="'+help+'" target=_self><img border=0 src="images/help.gif"></a>');
		write('</td></tr></table>');
	}
}
function helpback() {document.write('<p class=tl><a href="javascript:history.back()">Click to go back</a></p>')}
function hr(col) {document.write('<td colspan='+ col +'>&nbsp;</td>')}

function IpAddrIsOK(Obj, ObjName) {
	var iv = Obj.value.split('.');
	var ok = iv.length != 4;
	if (ok) {
		alert(MsgHead[0]+ObjName+MsgStrs[0]) ;
		return !ok;
	}
	for (var i=0; i< iv.length; i++)
		ok = ok || (iv[i] < 1 || iv[i] > 254);
	if (ok)
		alert(MsgHead[0]+ObjName+MsgStrs[1]) ;
	return (!ok) ;
}

function NetMaskIsOK() {
}
function MacAddrIsOK() {
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
	for (nm in type) {
		fd = form[nm];
		if (!fd) {
			alert('Field:'+nm+' not defined in Form:'+form);
			return;
		}
		switch (type[nm]) {
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
			for (i=0; i <fd.length; i++) {
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
		}
	}
	for (nm in type) {
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
