// forked Script by joedf
// Originally from: https://github.com/joedf/strapdown-topbar

;(function(){
	// Bonus Feature ! - Auto-Anchor Headings
	// Thanks for Ragnar-F's original code, this is a forked version
	// Permalink: https://github.com/Ragnar-F/ahk_docs_german/blob/93e17c109ed2739e1953bfdd63941f7d9c5ef0f2/static/content.js#L1413-L1448
	
	// Header processing loop
	for (var i = 1; i < 7; i++) {
		var headers = document.getElementsByTagName('h'+i);
		for (var j = 0; j < headers.length; j++) {
			// Get Header text
			var innerText = headers[j].innerHTML.replace(/<\/?[^>]+(>|$)/g, ""); // http://stackoverflow.com/a/5002161/883015
			
			// Add/Get anchor
			var anchorId = '_' + Date.now;
			if(headers[j].hasAttribute('id')) // if id anchor exists, use it
			{
				h_Id = headers[j].getAttribute('id');
				anchorId = (h_Id.length>0)?h_Id:anchorId;
				headers[j].removeAttribute('id');
			}
			else // if id anchor not exist, create one
			{
				var str = innerText.replace(/\s/g, '_'); // replace spaces with _
				var str = str.replace(/[():.,;'#\[\]\/{}&="|?!]/g, ''); // remove special chars
				var str = str.toLowerCase(); // convert to lowercase
				if(!!document.getElementById(str)) // if new id anchor exist already, set it to a unique one
					anchorId = str + anchorId;
				else
					anchorId = str;
			}
			// http://stackoverflow.com/a/1763629/883015
			var anchor = document.createElement('a');
				anchor.href = '#' + anchorId;
				anchor.style = 'text-decoration:none;';
				anchor.innerHTML = '<span id="'+anchorId+'" class="h'+i+'_anchor"></span>'
				anchor.appendChild(headers[j].cloneNode(true));
				headers[j].parentNode.replaceChild(anchor,headers[j]);
			
			// Show paragraph sign on mouseover
			headers[j].addEventListener('mouseenter', function(e){
				var p = document.createElement('span');
				p.innerHTML = ' &para;'; p.className = 'sd-para-symbol';
				this.appendChild(p);
			});
			headers[j].addEventListener('mouseleave', function(e){
				var p = document.getElementsByClassName('sd-para-symbol');
				for (var k = 0; k < p.length; k++)
					p[k].parentNode.removeChild(p[k]);
			});
		}
	}
	
	// Custom Header anchor styling
	window.onload = function() { //wait for window to load for window.getComputedStyle
		var css = document.createElement("style");
		css.type = "text/css";
		css.innerHTML = '.sd-para-symbol{color:#999;font-size:.7em;position:absolute;}'
						+ 'h1{line-height:normal !important;}';
		document.body.appendChild(css);
	}
})();