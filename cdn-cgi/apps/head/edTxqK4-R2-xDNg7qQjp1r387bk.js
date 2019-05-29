;window.CloudflareApps=window.CloudflareApps||{};CloudflareApps.siteId="00b3d7c4e48bcd4d645d53311798c59a";CloudflareApps.installs=CloudflareApps.installs||{};;(function(){'use strict'
CloudflareApps.internal=CloudflareApps.internal||{}
var errors=[]
CloudflareApps.internal.placementErrors=errors
var errorHashes={}
function noteError(options){var hash=options.selector+'::'+options.type+'::'+(options.installId||'')
if(errorHashes[hash]){return}
errorHashes[hash]=true
errors.push(options)}
var initializedSelectors={}
var currentInit=false
CloudflareApps.internal.markSelectors=function markSelectors(){if(!currentInit){check()
currentInit=true
setTimeout(function(){currentInit=false})}}
function check(){var installs=window.CloudflareApps.installs
for(var installId in installs){if(!installs.hasOwnProperty(installId)){continue}
var selectors=installs[installId].selectors
if(!selectors){continue}
for(var key in selectors){if(!selectors.hasOwnProperty(key)){continue}
var hash=installId+'::'+key
if(initializedSelectors[hash]){continue}
var els=document.querySelectorAll(selectors[key])
if(els&&els.length>1){noteError({type:'init:too-many',option:key,selector:selectors[key],installId:installId})
initializedSelectors[hash]=true
continue}else if(!els||!els.length){continue}
initializedSelectors[hash]=true
els[0].setAttribute('cfapps-selector',selectors[key])}}}
CloudflareApps.querySelector=function querySelector(selector){if(selector==='body'||selector==='head'){return document[selector]}
CloudflareApps.internal.markSelectors()
var els=document.querySelectorAll('[cfapps-selector="'+selector+'"]')
if(!els||!els.length){noteError({type:'select:not-found:by-attribute',selector:selector})
els=document.querySelectorAll(selector)
if(!els||!els.length){noteError({type:'select:not-found:by-query',selector:selector})
return null}else if(els.length>1){noteError({type:'select:too-many:by-query',selector:selector})}
return els[0]}
if(els.length>1){noteError({type:'select:too-many:by-attribute',selector:selector})}
return els[0]}}());(function(){'use strict'
var prevEls={}
CloudflareApps.createElement=function createElement(options,prevEl){options=options||{}
CloudflareApps.internal.markSelectors()
try{if(prevEl&&prevEl.parentNode){var replacedEl
if(prevEl.cfAppsElementId){replacedEl=prevEls[prevEl.cfAppsElementId]}
if(replacedEl){prevEl.parentNode.replaceChild(replacedEl,prevEl)
delete prevEls[prevEl.cfAppsElementId]}else{prevEl.parentNode.removeChild(prevEl)}}
var element=document.createElement('cloudflare-app')
var container
if(options.pages&&options.pages.URLPatterns&&!CloudflareApps.matchPage(options.pages.URLPatterns)){return element}
try{container=CloudflareApps.querySelector(options.selector)}catch(e){}
if(!container){return element}
if(!container.parentNode&&(options.method==='after'||options.method==='before'||options.method==='replace')){return element}
if(container===document.body){if(options.method==='after'){options.method='append'}else if(options.method==='before'){options.method='prepend'}}
switch(options.method){case'prepend':if(container.firstChild){container.insertBefore(element,container.firstChild)
break}
case'append':container.appendChild(element)
break
case'after':if(container.nextSibling){container.parentNode.insertBefore(element,container.nextSibling)}else{container.parentNode.appendChild(element)}
break
case'before':container.parentNode.insertBefore(element,container)
break
case'replace':try{var id=element.cfAppsElementId=Math.random().toString(36)
prevEls[id]=container}catch(e){}
container.parentNode.replaceChild(element,container)}
return element}catch(e){if(typeof console!=='undefined'&&typeof console.error!=='undefined'){console.error('Error creating Cloudflare Apps element',e)}}}}());(function(){'use strict'
CloudflareApps.matchPage=function matchPage(patterns){if(!patterns||!patterns.length){return true}
var loc=document.location.host+document.location.pathname
if(window.CloudflareApps&&CloudflareApps.proxy&&CloudflareApps.proxy.originalURL){var url=CloudflareApps.proxy.originalURL.parsed
loc=url.host+url.path}
for(var i=0;i<patterns.length;i++){var re=new RegExp(patterns[i],'i')
if(re.test(loc)){return true}}
return false}}());CloudflareApps.installs["fDGuZgDsBBwg"]={appId:"lMxPPXVOqmoE",scope:{}};;CloudflareApps.installs["fDGuZgDsBBwg"].options={"account":{"accountId":"EKIVE6T1dcLh","service":"googleanalytics","userId":"100681249369148434078"},"anonymizeIp":false,"id":"","organization":"5170375","social":false,"web-properties-for-117776493":"UA-117776493-1","web-properties-for-5170375":"UA-5170375-17","webPropertySchemaNames":["web-properties-for-117776493","web-properties-for-5170375"]};;CloudflareApps.installs["t61Cn3s9SYbf"]={appId:"yOqKXAyfqbFq",scope:{}};;CloudflareApps.installs["t61Cn3s9SYbf"].options={"advancedOptions":{"autoDisplay":false,"multilanguagePage":true},"advancedOptionsToggle":true,"colors":{"background":"#6c6c6c","foreground":"#fafafa","text":"#444444"},"element":{"method":"append","selector":"body \u003e .mbr-box.mbr-section.mbr-section--relative.mbr-section--fixed-size.mbr-section--full-height.mbr-section--bg-adapted.mbr-parallax-background \u003e .mbr-box__magnet.mbr-box__magnet--sm-padding.mbr-box__magnet--center-center \u003e .mbr-box__container.mbr-section__container.container \u003e .mbr-box.mbr-box--stretched \u003e .mbr-box__magnet.mbr-box__magnet--center-center \u003e .row \u003e .col-sm-8.col-sm-offset-2"},"pageLanguage":"en","position":"center","specificLanguages":{"af":false,"ar":false,"az":false,"be":false,"bg":false,"bn":false,"bs":false,"ca":false,"ceb":false,"cs":true,"cy":false,"da":false,"de":true,"el":true,"en":true,"eo":false,"es":false,"et":false,"eu":false,"fa":true,"fi":true,"fr":true,"ga":false,"gl":false,"gu":false,"ha":false,"hi":true,"hmn":false,"hr":true,"ht":false,"hu":false,"hy":true,"id":false,"ig":false,"is":false,"it":true,"iw":false,"ja":true,"jv":false,"ka":true,"kk":false,"km":false,"kn":false,"ko":false,"la":false,"lo":false,"lt":true,"lv":true,"mg":false,"mi":false,"mk":false,"ml":false,"mn":false,"mr":false,"ms":false,"mt":false,"my":false,"nl":false,"no":false,"ny":false,"pa":false,"pl":true,"pt":true,"ro":true,"ru":true,"si":false,"sk":false,"sl":false,"so":false,"sq":false,"sr":true,"su":false,"sv":false,"sw":false,"ta":false,"te":false,"tg":false,"th":true,"tl":false,"tr":false,"uk":true,"ur":true,"uz":false,"vi":false,"yi":false,"yo":false,"zh_CN":true,"zh_TW":true,"zu":false},"specificLanguagesToggle":true};;CloudflareApps.installs["t61Cn3s9SYbf"].selectors={"element.selector":"body \u003e .mbr-box.mbr-section.mbr-section--relative.mbr-section--fixed-size.mbr-section--full-height.mbr-section--bg-adapted.mbr-parallax-background \u003e .mbr-box__magnet.mbr-box__magnet--sm-padding.mbr-box__magnet--center-center \u003e .mbr-box__container.mbr-section__container.container \u003e .mbr-box.mbr-box--stretched \u003e .mbr-box__magnet.mbr-box__magnet--center-center \u003e .row \u003e .col-sm-8.col-sm-offset-2"};;CloudflareApps.installs["vtvEMD1hxFvI"]={appId:"RV-QzZv0Mpa_",scope:{}};;CloudflareApps.installs["vtvEMD1hxFvI"].options={"horizontal_padding":null,"location":{"method":"append","selector":"body \u003e .mbr-section.mbr-section--relative.mbr-section--fixed-size \u003e .mbr-section__container.container \u003e .mbr-contacts.mbr-contacts--wysiwyg.row"},"position":"left","vertical_padding":null};;CloudflareApps.installs["vtvEMD1hxFvI"].selectors={"location.selector":"body \u003e .mbr-section.mbr-section--relative.mbr-section--fixed-size \u003e .mbr-section__container.container \u003e .mbr-contacts.mbr-contacts--wysiwyg.row"};;if(CloudflareApps.matchPage(CloudflareApps.installs['fDGuZgDsBBwg'].URLPatterns)){(function(){var options=CloudflareApps.installs['fDGuZgDsBBwg'].options;var id;if(options.account&&options.organization){id=options["web-properties-for-"+options.organization];}else{id=(options.id||"").trim();}
if(!id){console.log("Cloudflare Google Analytics: Disabled. UA-ID not present.");return;}else if("fDGuZgDsBBwg"==="preview"){console.log("Cloudflare Google Analytics: Enabled",id);}
function resolveParameter(uri,parameter){if(uri){var parameters=uri.split("#")[0].match(/[^?=&]+=([^&]*)?/g);for(var i=0,chunk;(chunk=parameters[i]);++i){if(chunk.indexOf(parameter)===0){return unescape(chunk.split("=")[1]);}}}}
window.dataLayer=window.dataLayer||[];function gtag(){window.dataLayer.push(arguments);}
gtag("js",new Date());gtag("config",id);gtag("set",{anonymizeIp:options.anonymizeIp});var vendorScript=document.createElement("script");vendorScript.src="https://www.googletagmanager.com/gtag/js?id="+id;document.head.appendChild(vendorScript);if(options.social){window.addEventListener("load",function googleAnalyticsSocialTracking(){var FB=window.FB;var twttr=window.twttr;if("FB"in window&&"Event"in FB&&"subscribe"in window.FB.Event){FB.Event.subscribe("edge.create",function(targetUrl){gtag("event","share",{method:"facebook",event_action:"like",content_id:targetUrl});});FB.Event.subscribe("edge.remove",function(targetUrl){gtag("event","share",{method:"facebook",event_action:"unlike",content_id:targetUrl});});FB.Event.subscribe("message.send",function(targetUrl){gtag("event","share",{method:"facebook",event_action:"send",content_id:targetUrl});});}
if("twttr"in window&&"events"in twttr&&"bind"in twttr.events){twttr.events.bind("tweet",function(event){if(event){var targetUrl;if(event.target&&event.target.nodeName==="IFRAME"){targetUrl=resolveParameter(event.target.src,"url");}
gtag("event","share",{method:"twitter",event_action:"tweet",content_id:targetUrl});}});}},false);}})();};if(CloudflareApps.matchPage(CloudflareApps.installs['t61Cn3s9SYbf'].URLPatterns)){(function(modules){var installedModules={};function __webpack_require__(moduleId){if(installedModules[moduleId]){return installedModules[moduleId].exports;}
var module=installedModules[moduleId]={i:moduleId,l:false,exports:{}};modules[moduleId].call(module.exports,module,module.exports,__webpack_require__);module.l=true;return module.exports;}
__webpack_require__.m=modules;__webpack_require__.c=installedModules;__webpack_require__.i=function(value){return value;};__webpack_require__.d=function(exports,name,getter){if(!__webpack_require__.o(exports,name)){Object.defineProperty(exports,name,{configurable:false,enumerable:true,get:getter});}};__webpack_require__.n=function(module){var getter=module&&module.__esModule?function getDefault(){return module['default'];}:function getModuleExports(){return module;};__webpack_require__.d(getter,'a',getter);return getter;};__webpack_require__.o=function(object,property){return Object.prototype.hasOwnProperty.call(object,property);};__webpack_require__.p="";return __webpack_require__(__webpack_require__.s=1);})
([,(function(module,exports,__webpack_require__){"use strict";(function(){if(!window.addEventListener)return
var ELEMENT_ID='cloudflare-app-google-translate'
var CALLBACK_NAME='CloudflareAppsGoogleTranslateOnload'
var style=document.createElement('style')
document.head.appendChild(style)
var options=CloudflareApps.installs['t61Cn3s9SYbf'].options
var element=void 0
var script=void 0
function updateStylesheet(){var _options=options,_options$colors=_options.colors,background=_options$colors.background,foreground=_options$colors.foreground,text=_options$colors.text
element.setAttribute('data-position',options.position)
style.innerHTML='\n      .goog-te-gadget {\n        background-color: '+background+';\n      }\n\n      #'+ELEMENT_ID+' select {\n        background-color: '+foreground+';\n        color: '+text+';\n      }'}
function unmountNode(node){if(node&&node.parentNode)node.parentNode.removeChild(node)}
window[CALLBACK_NAME]=function updateElement(){var _options2=options,pageLanguage=_options2.pageLanguage
var TranslateElement=window.google.translate.TranslateElement
var spec={layout:TranslateElement.InlineLayout.VERTICAL,pageLanguage:pageLanguage}
element=CloudflareApps.createElement(options.element,element)
element.id=ELEMENT_ID
if(options.specificLanguagesToggle){var _options3=options,specificLanguages=_options3.specificLanguages
spec.includedLanguages=Object.keys(specificLanguages).filter(function(key){return specificLanguages[key]}).map(function(key){return key.replace('_','-')}).join(',')}
if(options.advancedOptionsToggle){var _options4=options,advancedOptions=_options4.advancedOptions
spec.multilanguagePage=advancedOptions.multilanguagePage
spec.autoDisplay=advancedOptions.autoDisplay}
updateStylesheet()
new TranslateElement(spec,ELEMENT_ID)}
function updateScript(){[script,document.querySelector('.skiptranslate')].forEach(unmountNode)
script=document.createElement('script')
script.type='text/javascript'
script.src='//translate.google.com/translate_a/element.js?cb='+CALLBACK_NAME
document.head.appendChild(script)}
if(document.readyState==='loading'){document.addEventListener('DOMContentLoaded',updateScript)}else{updateScript()}
window.CloudflareApps.installs['t61Cn3s9SYbf'].scope={setStylesheet:function setStylesheet(nextOptions){options=nextOptions
updateStylesheet()},setOptions:function setOptions(nextOptions){options=nextOptions
document.cookie=document.cookie.split('; ').filter(function(cookie){return cookie.indexOf('googtrans')===-1}).join('; ')
updateScript()}}})()})]);};(function(){try{var link=document.createElement('link');link.rel='stylesheet';link.href='data:text/css;charset=utf-8;base64,I2Nsb3VkZmxhcmUtYXBwLWdvb2dsZS10cmFuc2xhdGUgc2VsZWN0IHsKICAtbW96LWFwcGVhcmFuY2U6IG5vbmU7CiAgLXdlYmtpdC1hcHBlYXJhbmNlOiBub25lOwogIGFwcGVhcmFuY2U6IG5vbmU7CiAgYmFja2dyb3VuZC1pbWFnZTogdXJsKCJkYXRhOmltYWdlL3N2Zyt4bWw7dXRmOCw8c3ZnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zycgdmlld0JveD0nMCAwIDE1IDgnPjxnPjxwb2x5Z29uIGZpbGw9J3JnYmEoMCwwLDAsMC43MzQpJyB0cmFuc2Zvcm09J3RyYW5zbGF0ZSUyODcuNSwgNC41JTI5IHNjYWxlJTI4MSwgLTElMjkgdHJhbnNsYXRlJTI4LTcuNSwgLTQuNSUyOScgcG9pbnRzPSc3LjUgMSAxNCA4IDEgOCc+PC9wb2x5Z29uPjwvZz48L3N2Zz4iKTsKICBiYWNrZ3JvdW5kLXBvc2l0aW9uOiByaWdodCA0NSU7CiAgYmFja2dyb3VuZC1yZXBlYXQ6IG5vLXJlcGVhdDsKICBiYWNrZ3JvdW5kLXNpemU6IDIuNWVtIC42ZW07CiAgYm9yZGVyLWJvdHRvbS1jb2xvcjogcmdiYSgwLCAwLCAwLCAwLjM1KTsKICBib3JkZXI6IDFweCBzb2xpZCByZ2JhKDAsIDAsIDAsIDAuMik7CiAgY3Vyc29yOiBwb2ludGVyOwogIGRpc3BsYXk6IGJsb2NrOwogIGxpbmUtaGVpZ2h0OiAxLjQ7CiAgbWFyZ2luOiAwIGF1dG8gOHB4OwogIHdpZHRoOiAxMDAlOwogIHBhZGRpbmc6IC42ZW0gMi4yNWVtIC42ZW0gLjhlbTsKICAtd2Via2l0LXRhcC1oaWdobGlnaHQtY29sb3I6IHRyYW5zcGFyZW50OwogIHRleHQtcmVuZGVyaW5nOiBvcHRpbWl6ZUxlZ2liaWxpdHk7Cn0KCi5nb29nLXRlLWNvbWJvIHsKICBmb250LWZhbWlseTogaW5oZXJpdCAhaW1wb3J0YW50Owp9CgouZ29vZy1sb2dvLWxpbmsgewogIGRpc3BsYXk6IGlubGluZS1ibG9jazsKfQoKLmdvb2ctbG9nby1saW5rOmJlZm9yZSB7CiAgYmFja2dyb3VuZC1pbWFnZTogdXJsKGRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEQ5NGJXd2dkbVZ5YzJsdmJqMGlNUzR3SWlCbGJtTnZaR2x1WnowaVZWUkdMVGdpSUhOMFlXNWtZV3h2Ym1VOUltNXZJajgrUEhOMlp5QjRiV3h1Y3pwa1l6MGlhSFIwY0RvdkwzQjFjbXd1YjNKbkwyUmpMMlZzWlcxbGJuUnpMekV1TVM4aUlIaHRiRzV6T21OalBTSm9kSFJ3T2k4dlkzSmxZWFJwZG1WamIyMXRiMjV6TG05eVp5OXVjeU1pSUhodGJHNXpPbkprWmowaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1UazVPUzh3TWk4eU1pMXlaR1l0YzNsdWRHRjRMVzV6SXlJZ2VHMXNibk02YzNablBTSm9kSFJ3T2k4dmQzZDNMbmN6TG05eVp5OHlNREF3TDNOMlp5SWdlRzFzYm5NOUltaDBkSEE2THk5M2QzY3Vkek11YjNKbkx6SXdNREF2YzNabklpQjJaWEp6YVc5dVBTSXhMakVpSUhkcFpIUm9QU0l4WlRNaUlHaGxhV2RvZEQwaU16STRMalUySWlCcFpEMGljM1puTWlJK0lEeHdZWFJvSUhOMGVXeGxQU0ptYVd4c09pTTBNamcxWmpRN1ptbHNiQzF2Y0dGamFYUjVPakVpSUdROUltMHlORFl1TVRFZ01URTJMakU0YUMweE1UWXVOVGQyTXpRdU5Ua3hhRGd5TGpZM00yTXROQzR3T0RReUlEUTRMalV3TmkwME5DNDBOQ0EyT1M0eE9USXRPREl1TlRNeklEWTVMakU1TWkwME9DNDNNellnTUMwNU1TNHlOalF0TXpndU16UTJMVGt4TGpJMk5DMDVNaTR3T1RJZ01DMDFNaTR6TlRjZ05EQXVOVFF0T1RJdU5qYzVJRGt4TGpNM01TMDVNaTQyTnprZ016a3VNakUzSURBZ05qSXVNekkySURJMUlEWXlMak15TmlBeU5Xd3lOQzR5TWkweU5TNHdPREZ6TFRNeExqQTROeTB6TkM0Mk1EZ3RPRGN1TnpnMExUTTBMall3T0dNdE56SXVNVGszTFRBdU1EQXhMVEV5T0M0d05TQTJNQzQ1TXpNdE1USTRMakExSURFeU5pNDNOU0F3SURZMExqUTVNeUExTWk0MU16a2dNVEkzTGpNNElERXlPUzQ0T1NBeE1qY3VNemdnTmpndU1ETXhJREFnTVRFM0xqZ3pMVFEyTGpZd05DQXhNVGN1T0RNdE1URTFMalV5SURBdE1UUXVOVE01TFRJdU1URXdPUzB5TWk0NU5ESXRNaTR4TVRBNUxUSXlMamswTW5vaUlHWnBiR3c5SWlNME9EZzFaV1FpSUdsa1BTSndZWFJvTWprNU9DSWdMejRnSUR4d1lYUm9JSE4wZVd4bFBTSm1hV3hzT2lObFlUUXpNelU3Wm1sc2JDMXZjR0ZqYVhSNU9qRWlJR1E5SW0wek5ERXVOaUE1TVM0eE1qbGpMVFEzTGpnek1pQXdMVGd5TGpFeE1TQXpOeTR6T1RVdE9ESXVNVEV4SURneExqQXdPQ0F3SURRMExqSTFPQ0F6TXk0eU5Ea2dPREl1TXpRNElEZ3lMalkzTXlBNE1pNHpORGdnTkRRdU56UXlJREFnT0RFdU16azNMVE0wTGpFNU55QTRNUzR6T1RjdE9ERXVNemszSURBdE5UUXVNRGs0TFRReUxqWXpPQzA0TVM0NU5Ua3RPREV1T1RVNUxUZ3hMamsxT1hwdE1DNDBOelUyTXlBek1pNHdPRE5qTWpNdU5USXlJREFnTkRVdU9ERXlJREU1TGpBeE55QTBOUzQ0TVRJZ05Ea3VOallnTUNBeU9TNDVPVE10TWpJdU1UazFJRFE1TGpVMU1pMDBOUzQ1TWlBME9TNDFOVEl0TWpZdU1EWTRJREF0TkRZdU5qTXpMVEl3TGpnM09DMDBOaTQyTXpNdE5Ea3VOemtnTUMweU9DNHlPVElnTWpBdU16RXRORGt1TkRJeUlEUTJMamMwTVMwME9TNDBNako2SWlCbWFXeHNQU0lqWkdJek1qTTJJaUJwWkQwaWNHRjBhRE13TURBaUlDOCtJQ0E4Y0dGMGFDQnpkSGxzWlQwaVptbHNiRG9qWm1KaVl6QTFPMlpwYkd3dGIzQmhZMmwwZVRveElpQmtQU0p0TlRJd0xqRTRJRGt4TGpFeU9XTXRORGN1T0RNeUlEQXRPREl1TVRFeElETTNMak01TlMwNE1pNHhNVEVnT0RFdU1EQTRJREFnTkRRdU1qVTRJRE16TGpJME9TQTRNaTR6TkRnZ09ESXVOamN6SURneUxqTTBPQ0EwTkM0M05ESWdNQ0E0TVM0ek9UY3RNelF1TVRrM0lEZ3hMak01TnkwNE1TNHpPVGNnTUMwMU5DNHdPVGd0TkRJdU5qTTRMVGd4TGprMU9TMDRNUzQ1TlRrdE9ERXVPVFU1ZW0wd0xqUTNOVFl5SURNeUxqQTRNMk15TXk0MU1qSWdNQ0EwTlM0NE1USWdNVGt1TURFM0lEUTFMamd4TWlBME9TNDJOaUF3SURJNUxqazVNeTB5TWk0eE9UVWdORGt1TlRVeUxUUTFMamt5SURRNUxqVTFNaTB5Tmk0d05qZ2dNQzAwTmk0Mk16TXRNakF1T0RjNExUUTJMall6TXkwME9TNDNPU0F3TFRJNExqSTVNaUF5TUM0ek1TMDBPUzQwTWpJZ05EWXVOelF4TFRRNUxqUXlNbm9pSUdacGJHdzlJaU5tTkdNeU1HUWlJR2xrUFNKd1lYUm9NekF3TlNJZ0x6NGdJRHh3WVhSb0lITjBlV3hsUFNKbWFXeHNPaU0wTWpnMVpqUTdabWxzYkMxdmNHRmphWFI1T2pFaUlHUTlJbTAyT1RVdU16UWdPVEV1TWpFMVl5MDBNeTQ1TURRZ01DMDNPQzQwTVRRZ016Z3VORFV6TFRjNExqUXhOQ0E0TVM0Mk1UTWdNQ0EwT1M0eE5qTWdOREF1TURBNUlEZ3hMamMyTlNBM055NDJOVGNnT0RFdU56WTFJREl6TGpJM09TQXdJRE0xTGpZMU55MDVMakkwTURVZ05EUXVOemsyTFRFNUxqZzBOM1l4Tmk0eE1EWmpNQ0F5T0M0eE9DMHhOeTR4TVNBME5TNHdOVFV0TkRJdU9UTTJJRFExTGpBMU5TMHlOQzQ1TkRrZ01DMHpOeTQwTmpNdE1UZ3VOVFV4TFRReExqZ3hNaTB5T1M0d056aHNMVE14TGpNNU1TQXhNeTR4TWpOak1URXVNVE0ySURJekxqVTBOeUF6TXk0MU5UUWdORGd1TVRBeklEY3pMalEyTXlBME9DNHhNRE1nTkRNdU5qVXlJREFnTnpZdU9USXlMVEkzTGpRNU5TQTNOaTQ1TWpJdE9EVXVNVFU1ZGkweE5EWXVOemRvTFRNMExqSTBOWFl4TXk0NE16WmpMVEV3TGpVekxURXhMak0wTnkweU5DNDVNeTB4T0M0M05EVXRORFF1TURRdE1UZ3VOelExZW0wekxqRTNPQ0F6TWk0d01UaGpNakV1TlRJMUlEQWdORE11TmpJNElERTRMak00SURRekxqWXlPQ0EwT1M0M05qZ2dNQ0F6TVM0NU1EUXRNakl1TURVMklEUTVMalE0TnkwME5DNHhNRFFnTkRrdU5EZzNMVEl6TGpRd05pQXdMVFExTGpFNE5TMHhPUzR3TURVdE5EVXVNVGcxTFRRNUxqRTROQ0F3TFRNeExqTTFPQ0F5TWk0Mk1Ua3ROVEF1TURjeElEUTFMalkyTFRVd0xqQTNNWG9pSUdacGJHdzlJaU0wT0RnMVpXUWlJR2xrUFNKd1lYUm9NekF3TnlJZ0x6NGdJRHh3WVhSb0lITjBlV3hsUFNKbWFXeHNPaU5sWVRRek16VTdabWxzYkMxdmNHRmphWFI1T2pFaUlHUTlJbTA1TWpVdU9Ea2dPVEV1TURKakxUUXhMalF4TkNBd0xUYzJMakU0TnlBek1pNDVOUzAzTmk0eE9EY2dPREV1TlRjZ01DQTFNUzQwTkRjZ016Z3VOelU1SURneExqazFPU0E0TUM0eE5qVWdPREV1T1RVNUlETTBMalUxT0NBd0lEVTFMamMyT0MweE9DNDVNRFlnTmpndU5ESTJMVE0xTGpnME5Xd3RNamd1TWpNMUxURTRMamM0TjJNdE55NHpNalk0SURFeExqTTNNUzB4T1M0MU56WWdNakl1TkRnMExUUXdMakF4T0NBeU1pNDBPRFF0TWpJdU9UWXlJREF0TXpNdU5USXRNVEl1TlRjMExUUXdMakEyTVMweU5DNDNOVFJzTVRBNUxqVXlMVFExTGpRME5DMDFMalk0TlRrdE1UTXVNekU0WXkweE1DNDFPQzB5Tmk0d09DMHpOUzR5TmkwME55NDROaTAyTnk0NU1pMDBOeTQ0Tm5wdE1TNDBNalk0SURNeExqUXhNMk14TkM0NU1qTWdNQ0F5TlM0Mk5qTWdOeTQ1TXpReUlETXdMakl5TkNBeE55NDBORGRzTFRjekxqRXpPU0F6TUM0MU4yTXRNeTR4TlRNeUxUSXpMalkyTnlBeE9TNHlOamt0TkRndU1ERTNJRFF5TGpreE5TMDBPQzR3TVRkNklpQm1hV3hzUFNJalpHSXpNak0ySWlCcFpEMGljR0YwYURNd01URWlJQzgrSUNBOGNHRjBhQ0J6ZEhsc1pUMGlabWxzYkRvak16UmhPRFV6TzJacGJHd3RiM0JoWTJsMGVUb3hJaUJrUFNKdE56azNMalE1SURJME9TNDNhRE0xTGprM05YWXRNalF3TGpjMWFDMHpOUzQ1TnpWNklpQm1hV3hzUFNJak0yTmlZVFUwSWlCcFpEMGljR0YwYURNd01UVWlJQzgrUEM5emRtYytDZz09KTsKICBiYWNrZ3JvdW5kLXJlcGVhdDogbm8tcmVwZWF0OwogIGJhY2tncm91bmQtc2l6ZTogY292ZXI7CiAgZGlzcGxheTogaW5saW5lLWJsb2NrOwogIGNvbnRlbnQ6ICIiOwogIG1hcmdpbi1yaWdodDogM3B4OwogIGhlaWdodDogMTJweDsKICB3aWR0aDogMzdweDsKICB2ZXJ0aWNhbC1hbGlnbjogbWlkZGxlOwp9CgouZ29vZy1sb2dvLWxpbmsgaW1nIHsKICBkaXNwbGF5OiBub25lOwp9CgouZ29vZy10ZS1nYWRnZXQgewogIGJvcmRlci1yYWRpdXM6IDVweDsKICAtbXMtYm94LXNpemluZzogYm9yZGVyLWJveDsKICBib3gtc2l6aW5nOiBib3JkZXItYm94OwogIGZvbnQtZmFtaWx5OiBpbmhlcml0ICFpbXBvcnRhbnQ7CiAgbWFyZ2luLWJvdHRvbTogMS4xZW07CiAgbWFyZ2luLXRvcDogMS4xZW07CiAgbWF4LXdpZHRoOiAxMDAlOwogIHBhZGRpbmc6IDE1cHggMTVweCAxMXB4OwogIHRleHQtYWxpZ246IGNlbnRlcjsKICB3aWR0aDogMjBlbTsKfQoKI2Nsb3VkZmxhcmUtYXBwLWdvb2dsZS10cmFuc2xhdGVbZGF0YS1wb3NpdGlvbj0ibGVmdCJdIC5nb29nLXRlLWdhZGdldCB7CiAgbWFyZ2luLWxlZnQ6IDEuMWVtOwogIG1hcmdpbi1yaWdodDogYXV0bzsKfQoKI2Nsb3VkZmxhcmUtYXBwLWdvb2dsZS10cmFuc2xhdGVbZGF0YS1wb3NpdGlvbj0iY2VudGVyIl0gLmdvb2ctdGUtZ2FkZ2V0IHsKICBtYXJnaW4tbGVmdDogYXV0bzsKICBtYXJnaW4tcmlnaHQ6IGF1dG87Cn0KCiNjbG91ZGZsYXJlLWFwcC1nb29nbGUtdHJhbnNsYXRlW2RhdGEtcG9zaXRpb249InJpZ2h0Il0gLmdvb2ctdGUtZ2FkZ2V0IHsKICBtYXJnaW4tbGVmdDogYXV0bzsKICBtYXJnaW4tcmlnaHQ6IDEuMWVtOwp9Cg==';document.getElementsByTagName('head')[0].appendChild(link);}catch(e){}})();(function(){var script = document.createElement('script');script.src = '/cdn-cgi/apps/body/gmiOevYkD6YsbkRFCVGANMEUFGw.js';document.head.appendChild(script);})();