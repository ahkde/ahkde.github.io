function IsInsideChm() {   //returns true if current file is inside a CHM Help File
  var ra = /::/;
  return (location.href.search(ra) > 0); //If found then then we are in a CHM
  }
    
window.onload = function () {
	function gY(e) {
		var i = 0;
		while (e != null) {
			i += e.offsetTop;
			e = e.offsetParent;
		}
		return i;
	}
		var y = window.innerHeight || document.documentElement.clientHeight || document.getElementsByTagName('body')[0].clientHeight, c = document.getElementById('content');
		c.style.minHeight = (y - gY(c) - document.getElementById('end').offsetHeight - document.getElementById('copyright').offsetHeight - 1) + 'px';
};
