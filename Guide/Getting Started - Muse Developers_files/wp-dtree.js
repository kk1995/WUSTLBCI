/*
WP-dTree 4.0 (ulfben 2010-10-17)
	Converted to plain JavaScript from previous PHP-fed monster.
	Replaced scriptacolous with jQuery
	Adjusted for use with WP script localization
	Removed stupid count-parameter
	Removed previously added silly HTML-escaping.
	Added some safety checks for undefined dom-selections.

WP-dTree 3.5 (ulfben 2008-10-27)
	Escapes HTML-entities so they don't break the link titles / display
	
WP-dTree 3.3 (ulfben 2007-10-26)
	Fixed $curdir being undefined on some servers. (contributed by Zarquod)
	Added base URL to the tree so we won't have to pass it in for every node.
	Added a truncate-title function so we wont have to pass redundant data.
	Removed the text and graphic for the root-node. 

WP-dTree 3.2 (ulfben 2007-10-08)
	Added duration parameter to the GET array.
	Removed title on root-node.				
*/

/*--------------------------------------------------|
| WP-dTree 2.2 | www.silpstream.com/blog/           |
|---------------------------------------------------|
| Copyright (c) 2006 Christopher Hwang              |
| Release Date: July 2006                           |
| Modifications:                                    |
| v2.2 Added support for generating page trees      |
|      Added support for excluding specific posts   |
|      from tree                                    |
|      Updated option menu                          |
|      Rewrite of base code                         |
|      Fixed support for tooltips on non-linked     |
|      folders                                      |
|      Added option for not displaying posts in     |
|      archive tree                                 |
| v2.1 Patch to work with Regulus theme             |
|      Ability to change open/close all link        |
|      Set folders as links option                  |
|      Highlight current position in blog           |
| v2.0 Support for scriptaculous effects added      |
|      Category based menu added                    |
|      Support for wpdTree options was built in       |
|      Option menu added to admin panel             |
|	v1.0 Work arounds added for wordpress beautified |
|      permalinks.                                  |
|--------------------------------------------------*/
/*--------------------------------------------------|
| wpdTree 2.05 | www.destroydrop.com/javascript/tree/ |
|---------------------------------------------------|
| Copyright (c) 2002-2003 Geir Landr?               |
|                                                   |
| This script can be used freely as long as all     |
| copyright messages are intact.                    |
|                                                   |
| Updated: 17.04.2003                               |
|--------------------------------------------------*/
// dtNode object
function dtNode(id, pid, name, url, title, targ, rsspath){ 
	this.id = id;
	this.pid = pid;
	this.name = name;
	this.url = url;
	this.title = title;	
	this.rsspath = rsspath; //for feed link.
	var icon, iconOpen, open; //these were originally passed as parameters, but were never used in wp-dtree.	
	this.target = targ;
	this.icon = icon;
	this.iconOpen = iconOpen;
	this._io = open || false;
	this._is = false;
	this._ls = false;
	this._hc = false;
	this._ai = 0;
	this._p;
};

// Tree object
function wpdTree(objName, baseUrl, truncate){
	this.config ={
		target			: null,
		folderLinks		: false,
		useSelection	: false,
		useCookies		: true,
		useLines		: true,
		useIcons		: false,
		useStatusText	: false,
		closeSameLevel	: false,
		inOrder			: false
	}
	this.icon ={
		root		: WPdTreeSettings.imgurl + 'dtree-img/empty.gif',
		folder		: WPdTreeSettings.imgurl + 'dtree-img/folder.gif',
		folderOpen	: WPdTreeSettings.imgurl + 'dtree-img/folderopen.gif',
		node		: WPdTreeSettings.imgurl + 'dtree-img/page.gif',
		empty		: WPdTreeSettings.imgurl + 'dtree-img/empty.gif',
		line		: WPdTreeSettings.imgurl + 'dtree-img/line.gif',
		join		: WPdTreeSettings.imgurl + 'dtree-img/join.gif',
		joinBottom	: WPdTreeSettings.imgurl + 'dtree-img/joinbottom.gif',
		plus		: WPdTreeSettings.imgurl + 'dtree-img/plus.gif',
		plusBottom	: WPdTreeSettings.imgurl + 'dtree-img/plusbottom.gif',
		minus		: WPdTreeSettings.imgurl + 'dtree-img/minus.gif',
		minusBottom	: WPdTreeSettings.imgurl + 'dtree-img/minusbottom.gif',
		nlPlus		: WPdTreeSettings.imgurl + 'dtree-img/nolines_plus.gif',
		nlMinus		: WPdTreeSettings.imgurl + 'dtree-img/nolines_minus.gif',
		roots 		: {
				    'Android' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_android_white_16.svg',
				    'iOS' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_apple_white_16.svg',
				    'Research Tools' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_research_white_16.svg',
				    'Hardware &amp; Firmware' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_hardware_white_16.svg',
				    'Protocols' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_protocols_white_16.svg',
				    'File Formats' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_filetypes_white_16.svg',
				    'FAQ' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_faq_white_16.svg',	
				    'Release Notes' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_releasenotes_white_16.svg',
				    'Support' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_support_white_16.svg',
				    'Blog' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_blog_white_16.svg',
				    'Upcoming Events' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_upcoming_white_16.svg',
				    'Brand Guidelines' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_brand_guide_white_16_2.png',
				    'Third Party Apps' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_developer_white_16_2.png',
				    'Unity' : '//storage.googleapis.com/ix_choosemuse/uploads/dev-site/sidebar/ic_unity_white_16.svg'
				}	
	};
	this._url = baseUrl; 
	this._truncate = truncate;
	this._objName = objName;	
	this.adtNodes = [];
	this.aIndent = [];
	this.root = new dtNode("root");
	this.selecteddtNode = null;
	this.selectedFound = false;
	this.completed = false;
};

// Adds a new node to the node array
wpdTree.prototype.a = function(id, pid, name, title, path, link_target, rsspath){		
	if(rsspath != ""){
		rsspath = "<a class='dtree-rss' href='" + this._url + rsspath + "' title='Feed for "+name+"'></a>";	
	}		
	path += "";	//remove this and the next line breaks down for some reason.
	var url = path; //default value.
  	if(!path.indexOf('http://') == 0){		//if the path doesn't start with "http://" (eg. home path)
	  	url = this._url + path;
	}
	if(!title){title = name;}
	if(this._truncate > 0){
		name = this.truncate(name, this._truncate);
	}
	this.adtNodes[this.adtNodes.length] = new dtNode(id, pid, name, url, title, link_target, rsspath); 
};
 
wpdTree.prototype.truncate = function(str, length){
    var length = length || 16;
    var truncation = '...';
    if(str.length > length)  {
    	return str.slice(0, length - truncation.length) + truncation;
    }
    return str;
 };

// Open/close all nodes
wpdTree.prototype.openAll = function(){
	this.oAll(true);
};
wpdTree.prototype.closeAll = function(){
	this.oAll(false);
};

// Outputs the tree to the page
wpdTree.prototype.toString = function(){
	var type = this._objName.substr(0,3); //arc, pge, lnk, cat
	var str = '<div class="dtree_' + type +'" id="dtree_'+this._objName+'">\n';
	if(document.getElementById){
		if(this.config.useCookies) this.selecteddtNode = this.getSelected();
		str += this.adddtNode(this.root);
	} else str += 'Browser not supported.';
	str += '</div>';
	if(!this.selectedFound) this.selecteddtNode = null;
	this.completed = true;
	return str;
};

// Creates the tree structure
wpdTree.prototype.adddtNode = function(pdtNode){
	var str = '';
	var n=0;
	if(this.config.inOrder) n = pdtNode._ai;
	for (n; n < this.adtNodes.length; n++){
		if(this.adtNodes[n].pid == pdtNode.id){
			var cn = this.adtNodes[n];
			cn._p = pdtNode;
			cn._ai = n;
			this.setCS(cn);
			if(!cn.target && this.config.target) cn.target = this.config.target;
			if(cn._hc && !cn._io && this.config.useCookies) cn._io = this.isOpen(cn.id);
			if(!this.config.folderLinks && cn._hc) cn.url = null;
			if(this.config.useSelection && cn.id == this.selecteddtNode && !this.selectedFound){
					cn._is = true;
					this.selecteddtNode = n;
					this.selectedFound = true;
			}
			str += this.node(cn, n);
			if(cn._ls) break;
		}
	}
	return str;
};

// Creates the node icon, url and text
wpdTree.prototype.node = function(node, nodeId){	
	var str = '<div class="dtNode">' + this.indent(node, nodeId);	
	if(this.config.useIcons){
		if(!node.icon) node.icon = (this.root.id == node.pid) ? this.icon.root : ((node._hc) ? this.icon.folder : this.icon.node);
		if(!node.iconOpen) node.iconOpen = (node._hc) ? this.icon.folderOpen : this.icon.node;
		if(this.root.id != node.pid){		
			str += '<img id="i' + this._objName + nodeId + '" src="' + ((node._io) ? node.iconOpen : node.icon) + '" alt="" />';
		}
	}
	if(this.root.id != node.pid){
		if(node.url){
			str += '<a id="s' + this._objName + nodeId + '" class="' + ((this.config.useSelection) ? ((node._is ? 'nodeSel' : 'node')) : 'node') + '" href="' + node.url + '"';
			if(node.title) str += ' title="' + node.title + '"';
			if(node.target) str += ' target="' + node.target + '"';
			if(this.config.useStatusText) str += ' onmouseover="window.status=\'' + node.name + '\';return true;" onmouseout="window.status=\'\';return true;" ';
			if(this.config.useSelection && ((node._hc && this.config.folderLinks) || !node._hc))
				str += ' onclick="javascript: ' + this._objName + '.s(' + nodeId + ');"';
			str += '>';
		}
		else if((!this.config.folderLinks || !node.url) && node._hc && node.pid != this.root.id){
			str += '<a href="javascript: ' + this._objName + '.o(' + nodeId + ');"'
			if(true || node.title) str += ' title="' + node.title + '"';
			str += ' class="node">';
		}
		str += node.name;	
		if(node.url || ((!this.config.folderLinks || !node.url) && node._hc)) str += '</a>';	
	}	
	if(node.rsspath){
		str	+= node.rsspath;
	}
	str += ' </div>';	
	if(node._hc){
		str += '<div id="d' + this._objName + nodeId + '" class="clip" style="display:' + ((this.root.id == node.pid || node._io) ? 'block' : 'none') + ';">';
		str += this.adddtNode(node);	
		str += '</div>';
	}	
	this.aIndent.pop();
	return str;
};

// Adds the empty and line icons
wpdTree.prototype.indent = function(node, nodeId){
	var str = '';
	if(this.root.id != node.pid){
		for (var n=0; n<this.aIndent.length; n++)
			str += '<img src="' + ( (this.aIndent[n] == 1 && this.config.useLines) ? this.icon.line : this.icon.empty ) + '" alt="" />';
		(node._ls) ? this.aIndent.push(0) : this.aIndent.push(1);
		if(node._hc){
			str += '<a href="javascript: ' + this._objName + '.o(' + nodeId + ');"><img id="j' + this._objName + nodeId + '" src="';
			str += ( this.icon.roots[node.name] ) ? this.icon.roots[node.name] : this.icon.empty ;
			//else str += ( (node._io) ? ((node._ls && this.config.useLines) ? this.icon.minusBottom : this.icon.minus) : ((node._ls && this.config.useLines) ? this.icon.plusBottom : this.icon.plus ) );
			str += '" alt="" /></a>';
		} else str += '<img src="' + ( (this.config.useLines) ? ((node._ls) ? this.icon.joinBottom : this.icon.join ) :(this.icon.roots[node.name]) ? this.icon.roots[node.name] :  this.icon.empty) + '" alt="" />';
	}
	return str;
};

// Checks ifa node has any children and ifit is the last sibling
wpdTree.prototype.setCS = function(node){
	var lastId;
	for (var n=0; n<this.adtNodes.length; n++){
		if(this.adtNodes[n].pid == node.id) node._hc = true;
		if(this.adtNodes[n].pid == node.pid) lastId = this.adtNodes[n].id;
	}
	if(lastId==node.id) node._ls = true;
};

// Returns the selected node
wpdTree.prototype.getSelected = function(){
	var sn = this.getCookie('cs' + this._objName);
	return (sn) ? sn : null;
};

// Highlights the selected node
wpdTree.prototype.s = function(id){
	if(!this.config.useSelection) return;
	var cn = this.adtNodes[id];
	if(cn._hc && !this.config.folderLinks) return;
	if(this.selecteddtNode != id){
		if(this.selecteddtNode || this.selecteddtNode==0){
			eOld = document.getElementById("s" + this._objName + this.selecteddtNode);
			if(eOld){
				eOld.className = "node";
			}
		}
		eNew = document.getElementById("s" + this._objName + id);
		if(eNew){
			eNew.className = "nodeSel";
		}
		this.selecteddtNode = id;
		if(this.config.useCookies) this.setCookie('cs' + this._objName, cn.id);
	}
};

// Toggle Open or close
wpdTree.prototype.o = function(id){
	var cn = this.adtNodes[id];
	this.nodeStatus(!cn._io, id, cn._ls);
	cn._io = !cn._io;
	if(this.config.closeSameLevel) this.closeLevel(cn);
	if(this.config.useCookies) this.updateCookie();
};

// Open or close all nodes
wpdTree.prototype.oAll = function(status){
	for (var n=0; n<this.adtNodes.length; n++){
		if(this.adtNodes[n]._hc && this.adtNodes[n].pid != this.root.id){
			// silpstream: hack to work with scriptaculous
			if(this.adtNodes[n]._io != status) this.nodeStatus(status, n, this.adtNodes[n]._ls)
			this.adtNodes[n]._io = status;
		}
	}
	if(this.config.useCookies) this.updateCookie();
};

// Opens the tree to a specific node
wpdTree.prototype.openTo = function(nId, bSelect, bFirst){	
	if(!bFirst){
		for (var n=0; n<this.adtNodes.length; n++){
			if(this.adtNodes[n].id == nId){
				nId=n;
				break;
			}
		}
	}
	var cn=this.adtNodes[nId];	
	if (cn===undefined) return;
	if(cn.pid==this.root.id || !cn._p) return;
	cn._io = true;
	cn._is = bSelect;
	if(this.completed && cn._hc) this.nodeStatus(true, cn._ai, cn._ls);
	if(this.completed && bSelect) this.s(cn._ai);
	else if(bSelect) this._sn=cn._ai;
	this.openTo(cn._p._ai, false, true);
};

// Closes all nodes on the same level as certain node
wpdTree.prototype.closeLevel = function(node){
	for (var n=0; n<this.adtNodes.length; n++){
		if(this.adtNodes[n].pid == node.pid && this.adtNodes[n].id != node.id && this.adtNodes[n]._hc){
			this.nodeStatus(false, n, this.adtNodes[n]._ls);
			this.adtNodes[n]._io = false;
			this.closeAllChildren(this.adtNodes[n]);
		}
	}
}

// Closes all children of a node
wpdTree.prototype.closeAllChildren = function(node){
	for (var n=0; n<this.adtNodes.length; n++){
		if(this.adtNodes[n].pid == node.id && this.adtNodes[n]._hc){
			if(this.adtNodes[n]._io) this.nodeStatus(false, n, this.adtNodes[n]._ls);
			this.adtNodes[n]._io = false;
			this.closeAllChildren(this.adtNodes[n]);
		}
	}
}

// Change the status of a node(open or closed)
wpdTree.prototype.nodeStatus = function(status, id, bottom){
	eDiv	= document.getElementById('d' + this._objName + id);
	eJoin	= document.getElementById('j' + this._objName + id);
	if(this.config.useIcons){
		eIcon	= document.getElementById('i' + this._objName + id);
		eIcon.src = (status) ? this.adtNodes[id].iconOpen : this.adtNodes[id].icon;
	}
	//eJoin.src = (this.config.useLines)?
	//((status)?((bottom)?this.icon.minusBottom:this.icon.minus):((bottom)?this.icon.plusBottom:this.icon.plus)):
	//((status)?this.icon.nlMinus:this.icon.nlPlus);	
	if(WPdTreeSettings.animate === "1" && typeof jQuery == 'function'){ 
		(status) ? jQuery(eDiv).slideDown(parseInt(WPdTreeSettings.duration)) : jQuery(eDiv).slideUp(parseInt(WPdTreeSettings.duration));
	}else{
		eDiv.style.display = (status) ? 'block': 'none';
	}		
};


// [Cookie] Clears a cookie
wpdTree.prototype.clearCookie = function(){
	var now = new Date();
	var yesterday = new Date(now.getTime() - 1000 * 60 * 60 * 24);
	this.setCookie('co'+this._objName, 'cookieValue', yesterday);
	this.setCookie('cs'+this._objName, 'cookieValue', yesterday);
};

// [Cookie] Sets value in a cookie
wpdTree.prototype.setCookie = function(cookieName, cookieValue, expires, path, domain, secure){
	document.cookie =
		escape(cookieName) + '=' + escape(cookieValue)
		+ (expires ? '; expires=' + expires.toGMTString() : '')
		+ (path ? '; path=' + path : '; path=/')
		+ (domain ? '; domain=' + domain : '')
		+ (secure ? '; secure' : '');
};

// [Cookie] Gets a value from a cookie
wpdTree.prototype.getCookie = function(cookieName){
	var cookieValue = '';
	var posName = document.cookie.indexOf(escape(cookieName) + '=');
	if(posName != -1){
		var posValue = posName + (escape(cookieName) + '=').length;
		var endPos = document.cookie.indexOf(';', posValue);
		if(endPos != -1) cookieValue = unescape(document.cookie.substring(posValue, endPos));
		else cookieValue = unescape(document.cookie.substring(posValue));
	}
	return (cookieValue);
};

// [Cookie] Returns ids of open nodes as a string
wpdTree.prototype.updateCookie = function(){
	var str = '';
	for (var n=0; n<this.adtNodes.length; n++){
		if(this.adtNodes[n]._io && this.adtNodes[n].pid != this.root.id){
			if(str) str += '.';
			str += this.adtNodes[n].id;
		}
	}
	this.setCookie('co' + this._objName, str);
};

// [Cookie] Checks ifa node id is in a cookie
wpdTree.prototype.isOpen = function(id){
	var aOpen = this.getCookie('co' + this._objName).split('.');
	for (var n=0; n<aOpen.length; n++)
		if(aOpen[n] == id) return true;
	return false;
};

// ifPush and pop is not implemented by the browser
if(!Array.prototype.push){
	Array.prototype.push = function array_push(){
		for(var i=0;i<arguments.length;i++)
			this[this.length]=arguments[i];
		return this.length;
	}
};
if(!Array.prototype.pop){
	Array.prototype.pop = function array_pop(){
		lastElement = this[this.length-1];
		this.length = Math.max(this.length-1,0);
		return lastElement;
	}
};
