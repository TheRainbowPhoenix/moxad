//**************************************************************** 
// You are free to copy the "Folder-Tree" script as long as you  
// keep this copyright notice: 
// Script found in: http://www.geocities.com/Paris/LeftBank/2178/ 
// Author: Marcelino Alves Martins (martins@hks.com) December '97. 
//**************************************************************** 
 
//Log of changes: 
//       17 Feb 98 - Fix initialization flashing problem with Netscape
//       
//       27 Jan 98 - Root folder starts open; support for USETEXTLINKS; 
//                   make the ftien4 a js file 
//       
 
 
// Definition of class Folder 
// ***************************************************************** 
 var tmp1 = 0; // level
 var tmp2 = 2; // one level char number
 var shift = 1; // left shift
function Folder(folderDescription, hreference) //constructor 
{ 
  //constant data 
  this.desc = folderDescription 
  this.hreference = hreference 
  this.id = -1
  this.navObj = 0  
  this.iconImg = 0  
  this.nodeImg = 0  
  this.isLastNode = 0 
   
  //dynamic data 
  this.isOpen = true 
  this.iconSrc = "image/blank.gif"   
  this.children = new Array 
  this.nChildren = 0 
 
  //methods 
  this.initialize = initializeFolder 
  this.setState = setStateFolder 
  this.addChild = addChild 
  this.createIndex = createEntryIndex 
  this.hide = hideFolder 
  this.display = display 
  this.renderOb = drawFolder 
  this.totalHeight = totalHeight 
  this.subEntries = folderSubEntries 
  this.outputLink = outputFolderLink
} 
 
function setStateFolder(isOpen) 
{ 
  var subEntries 
  var totalHeight 
  var fIt = 0 
  var i=0 
 
  if (isOpen == this.isOpen) 
    return 

  if (browserVersion == 2)  
  { 
    totalHeight = 0 
    for (i=0; i < this.nChildren; i++) 
      totalHeight = totalHeight + this.children[i].navObj.clip.height 
      subEntries = this.subEntries() 
    if (this.isOpen) 
      totalHeight = 0 - totalHeight 
    for (fIt = this.id + subEntries + 1; fIt < nEntries; fIt++) 
      indexOfEntries[fIt].navObj.moveBy(0, totalHeight) 
  }  
  this.isOpen = isOpen 
    	
  propagateChangesInState(this) 
  
} 
 
function propagateChangesInState(folder) 
{   
  var i=0 
 
  if (folder.isOpen) 
  { 
    for (i=0; i<folder.nChildren; i++) 
      folder.children[i].display() 
  } 
  else 
  { 
    for (i=0; i<folder.nChildren; i++) 
    {
    if(folder.children[i].isOpen == true)
    {
    	id = folder.children[i].id
    	tmp_str = document.getElementById('link' + id).innerHTML.replace("- ", "- ")
    	document.getElementById('link' + id).innerHTML = tmp_str
		document.getElementById('link' + id).name = "close"
    }
      folder.children[i].hide() 
    }
  }  
} 
 
function hideFolder() 
{ 
  if (browserVersion == 1) { 
    if (this.navObj.style.display == "none") 
      return 
    this.navObj.style.display = "none" 
  } else { 
    if (this.navObj.visibility == "hiden") 
      return 
    this.navObj.visibility = "hiden" 
  } 
 
  this.setState(0) 
} 
 
function initializeFolder(level, lastNode, leftSide) 
{ 
  var j=0 
  var i=0 
  var numberOfFolders 
  var numberOfDocs 
  var nc 
  
  tmp1++;
      
  nc = this.nChildren 
   
  this.createIndex() 
 
  var auxEv = "" 
 
  if (browserVersion > 0) 
    auxEv = "<a href='javascript:clickOnNode("+this.id+")'>" 
  else 
    auxEv = "<a>" 
 
  if (level>0) 
    if (lastNode) //the last 'brother' in the children array 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' src='image/blank.gif' width=16 height=22 border=0></a>") 
      leftSide = leftSide + "<img src='image/blank.gif' width=16 height=22>"  
      this.isLastNode = 1 
    } 
    else 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' src='image/blank.gif' width=16 height=22 border=0></a>") 
      leftSide = leftSide + "<img src='image/blank.gif' width=16 height=22>" 
      this.isLastNode = 0 
    } 
  else 
    this.renderOb("") 

  if (nc > 0) 
  { 
    level = level + 1 
 
    for (i=0 ; i < this.nChildren; i++)  
    { 
      if (i == this.nChildren-1) 
        this.children[i].initialize(level, 1, leftSide) 
      else 
        this.children[i].initialize(level, 0, leftSide) 
      } 
  }
  tmp1--
} 
 
function drawFolder(leftSide) 
{ 
  if (browserVersion == 2) { 
    if (!doc.yPos) 
      doc.yPos=8 
    doc.write("<layer id='folder" + this.id + "' top=" + doc.yPos + " visibility=hiden>") 
  } 
  str = this.desc
  len = str.length - str.indexOf("- ") + tmp1*tmp2 - 4

  len = len *7
 
  if(this.id == 0)
  	len = "100%"
  if(this.id == 0)
	  doc.write("<table width='229'") 
  else
  	  doc.write("<table ") 
//  doc.write("<table") 
  if (browserVersion == 1) 
    doc.write(" id='folder" + this.id + "' style='position:relative; background-repeat: no-repeat;' ") 
  if(this.id == 0) // Main Menu
  	doc.write(" border=0 cellspacing=0 cellpadding=0 background='image/cont_title.jpg' bgproperties='fixed';>") 
  else
  	doc.write(" border=0 cellspacing=0 cellpadding=0>") 
  doc.write("<tr width='100%' height='22'><td width='")

  doc.write(((tmp1*tmp2)*7-shift) + "'>")

  doc.write("</td><td valign=middle nowrap><font style='font-size: 9pt;' color='#4E4E4E'>") 
  if(this.id == 0) // Main Menu 
  	doc.write("<b>")
  if (USETEXTLINKS) 
  { 
    this.outputLink() 
    doc.write(this.desc + "</a>") 
  } 
  else 
    doc.write(this.desc) 
  if(this.id == 0)
  	doc.write("</b>")
  doc.write("</font></td>")  
  doc.write("</table>\n") 

  if (browserVersion == 2) { 
    doc.write("</layer>") 
  } 
 
  if (browserVersion == 1) { 
    this.navObj = doc.getElementById("folder"+this.id)
    this.iconImg = doc.getElementsByName("folderIcon"+this.id)[0]
    this.nodeImg = doc.getElementsByName("nodeIcon"+this.id)[0]
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["folder"+this.id] 
    this.iconImg = this.navObj.document.images["folderIcon"+this.id] 
    this.nodeImg = this.navObj.document.images["nodeIcon"+this.id] 
    doc.yPos=doc.yPos+this.navObj.clip.height 
  } 
} 
 
function outputFolderLink() 
{ 
  if(this.id == 0)
  	doc.write("<a>") 
  else
  {
    if (this.hreference) 
    { 
  	doc.write("<a href='" +	this.hreference	+ "' TARGET='contents'")
      if (browserVersion > 0) 
        doc.write("onClick='javascript:clickOnFolder("+this.id+")'") 
      doc.write(">") 
    } 
    else 
      doc.write("<a href='javascript:clickOnFolder("+this.id+")' onclick='javascript:linkfun(this, "+ this.id +")'  name='close', id='link" + this.id+"'>"
)   
  }
} 
 
function addChild(childNode) 
{ 
  this.children[this.nChildren] = childNode 
  this.nChildren++ 
  return childNode 
} 
 
function folderSubEntries() 
{ 
  var i = 0 
  var se = this.nChildren 
 
  for (i=0; i < this.nChildren; i++){ 
    if (this.children[i].children) //is a folder 
      se = se + this.children[i].subEntries() 
  } 
 
  return se 
} 
 
 
// Definition of class Item (a document or link inside a Folder) 
// ************************************************************* 
 
function Item(itemDescription, itemLink) // Constructor 
{ 
  // constant data 
  this.desc = itemDescription 
  this.link = itemLink 
  this.id = -1 //initialized in initalize() 
  this.navObj = 0 //initialized in render() 
  this.iconImg = 0 //initialized in render() 
  this.iconSrc = "image/blank.gif"
 
  // methods 
  this.initialize = initializeItem 
  this.createIndex = createEntryIndex 
  this.hide = hideItem 
  this.display = display 
  this.renderOb = drawItem 
  this.totalHeight = totalHeight 
} 
 
function hideItem() 
{ 
  if (browserVersion == 1) { 
    if (this.navObj.style.display == "none") 
      return 
    this.navObj.style.display = "none" 
  } else { 
    if (this.navObj.visibility == "hiden") 
      return 
    this.navObj.visibility = "hiden" 
  }     
} 
 
function initializeItem(level, lastNode, leftSide) 
{  
  this.createIndex() 
 
  if (level>0) 
    if (lastNode) //the last 'brother' in the children array 
    { 
      this.renderOb(leftSide + "<img src='image/blank.gif' width=16 height=22>") 
      leftSide = leftSide + "<img src='image/blank.gif' width=16 height=22>"  
    } 
    else 
    { 
      this.renderOb(leftSide + "<img src='image/blank.gif' width=16 height=22>") 
      leftSide = leftSide + "<img src='image/blank.gif' width=16 height=22>" 
    } 
  else 
    this.renderOb("")   
} 
 
function drawItem(leftSide) 
{ 
  var len =0;
  var str="";
  if (browserVersion == 2) 
    doc.write("<layer id='item" + this.id + "' top=" + doc.yPos + " visibility=hiden>") 
  str = this.desc
  len = str.length - str.indexOf("> ")
  len = len + (tmp1+1)*tmp2
  len = len*7
   
  doc.write("<table") 
  if (browserVersion == 1) 
    doc.write(" id='item" + this.id + "' style='position:relative;' ");
  doc.write(" border=0 cellspacing=0 cellpadding=0>");
  doc.write("<tr height='22'><td width='" + (((tmp1+1)*tmp2)*7-shift) + "'>");

  doc.write("</td><td valign=middle nowrap >") 
  if (USETEXTLINKS) 
    doc.write("<a href=" + this.link + ">" + this.desc + "</a>") 
  else 
    doc.write(this.desc) 
  doc.write("</table>") 
   
  if (browserVersion == 2) 
    doc.write("</layer>") 
 
  if (browserVersion == 1) { 
    this.navObj = doc.getElementById("item"+this.id)
    this.iconImg = doc.getElementsByName("itemIcon"+this.id)[0]
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["item"+this.id] 
    this.iconImg = this.navObj.document.images["itemIcon"+this.id] 
    doc.yPos=doc.yPos+this.navObj.clip.height 
  } 
} 
 
 
// Methods common to both objects (pseudo-inheritance) 
// ******************************************************** 
 
function display() 
{ 
  if (browserVersion == 1) 
    this.navObj.style.display = "block"
  else 
    this.navObj.visibility = "show" 
} 
 
function createEntryIndex() 
{ 
  this.id = nEntries 
  indexOfEntries[nEntries] = this 
  nEntries++ 
} 
 
// total height of subEntries open 
function totalHeight() //used with browserVersion == 2 
{ 
  var h = this.navObj.clip.height 
  var i = 0 
   
  if (this.isOpen) //is a folder and _is_ open 
    for (i=0 ; i < this.nChildren; i++)  
      h = h + this.children[i].totalHeight() 
 
  return h 
} 
 
 
// Events 
// ********************************************************* 
 
function clickOnFolder(folderId) 
{ 
  var clicked = indexOfEntries[folderId] 

    clickOnNode(folderId) 

  return  
 
  if (clicked.isSelected) 
    return 
} 
 
function clickOnNode(folderId) 
{ 
  var clickedFolder = 0 
  var state = 0 
 
  clickedFolder = indexOfEntries[folderId] 
  state = clickedFolder.isOpen 
 
  clickedFolder.setState(!state) //open<->close  
} 
 
function initializeDocument() 
{ 
  if (doc.all) 
    browserVersion = 1 //IE4   
  else 
    if (doc.layers) 
      browserVersion = 2 //NS4 
    else 
      browserVersion = 1 //other 

  foldersTree.initialize(0, 1, "") 
  foldersTree.display()
  
  if (browserVersion > 0) 
  { 
    doc.write("<layer top="+indexOfEntries[nEntries-1].navObj.top+">&nbsp;</layer>") 
 
    // close the whole tree 
    clickOnNode(0) 
    // open the root folder 
    clickOnNode(0) 
  } 
} 
 
// Auxiliary Functions for Folder-Treee backward compatibility 
// ********************************************************* 
var num=0;
function gFld(description, hreference) 
{ 
  description="<font face='Arial'; style=font-size:9pt; font-color: rgb(236, 244, 217); id='font" + num + "' >- " + description + "</font>"
  folder = new Folder(description, hreference)  
  num++
  return folder    
}

function MainFld(description, hreference) 
{ 
  description="<a href='" + hreference + "' target=mid>"+ "<font face='Arial'; style=font-size:9pt; font-color: rgb(236, 244, 217); id='font" + num + "' > " + description + "</font>" + "</a>"

  folder = new Folder(description, hreference)  
  num++
  return folder    
}
 
function gLnk(target, description, linkData) 
{ 
  num++
  description="<font face='Arial'; style=font-size:9pt;  font-color: #0000ff;background-color:#ccff99; >  " + description
  fullLink = "" 
 
  if (target==0) 
  { 
    fullLink = "'"+linkData+"' target=mid" 
  } 
  else 
  { 
    if (target==1) 
       fullLink = "'http://"+linkData+"' target=_top" 
    else 
       fullLink = "'http://"+linkData+"' target=\"basefrm\"" 
  } 
 
  linkItem = new Item(description, fullLink)   
  return linkItem 
} 
 
function insFld(parentFolder, childFolder) 
{ 
  return parentFolder.addChild(childFolder) 
} 
 
function insDoc(parentFolder, document) 
{ 
  parentFolder.addChild(document) 
} 
 
// Global variables 
// **************** 
 
USETEXTLINKS = 1
indexOfEntries = new Array 
nEntries = 0 
doc = document 
browserVersion = 0 
selectedFolder=0




function isIE(){ //ie?
if (window.navigator.userAgent.toLowerCase().indexOf("msie")>=1)
    return true;
else
    return false;
}

if(!isIE()){ //firefox innerText define
    HTMLElement.prototype.__defineGetter__("innerText",
    function(){
        var anyString = "";
        var childS = this.childNodes;
        for(var i=0; i<childS.length; i++) {

            if(childS[i].nodeType==1)
                anyString += childS[i].innerText;
            else if(childS[i].nodeType==3)
                anyString += childS[i].nodeValue;
        }
        return anyString;
    }
    );
    HTMLElement.prototype.__defineSetter__("innerText",
    function(sText){
        this.textContent=sText;

    }
    );
}


var tmp_str;	
function linkfun(doc, id)
{
}



