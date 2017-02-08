;(function(){for(var i=1;i<7;i++){var headers=document.getElementsByTagName('h'+i);for(var j=0;j<headers.length;j++){var innerText=headers[j].innerHTML.replace(/<\/?[^>]+(>|$)/g,"");var anchorId='_'+ Date.now;if(headers[j].hasAttribute('id'))
{h_Id=headers[j].getAttribute('id');anchorId=(h_Id.length>0)?h_Id:anchorId;headers[j].removeAttribute('id');}
else
{var str=innerText.replace(/\s/g,'_');var str=str.replace(/[():.,;'#\[\]\/{}&="|?!]/g,'');var str=str.toLowerCase();if(!!document.getElementById(str))
anchorId=str+ anchorId;else
anchorId=str;}
var anchor=document.createElement('a');anchor.href='#'+ anchorId;anchor.style='text-decoration:none;';anchor.innerHTML='<span id="'+anchorId+'" class="h'+i+'_anchor"></span>'
anchor.appendChild(headers[j].cloneNode(true));headers[j].parentNode.replaceChild(anchor,headers[j]);headers[j].addEventListener('mouseenter',function(e){var p=document.createElement('span');p.innerHTML=' &para;';p.className='sd-para-symbol';this.appendChild(p);});headers[j].addEventListener('mouseleave',function(e){var p=document.getElementsByClassName('sd-para-symbol');for(var k=0;k<p.length;k++)
p[k].parentNode.removeChild(p[k]);});}}
window.onload=function(){var css=document.createElement("style");css.type="text/css";css.innerHTML='.sd-para-symbol{color:#999;font-size:.7em;position:absolute;}'
+'h1{line-height:normal !important;}';document.body.appendChild(css);}})();