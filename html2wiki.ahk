#NoEnv
#SingleInstance force
#persistent
SetBatchLines, -1

Loop, docs\*.htm, 0, 1
{
	parsing		:= 0
	countchar	:= ""
	content 	:= ""
	path	:= RegExReplace(A_LoopFileDir, "docs", "wiki")
	name	:= RegExReplace(A_LoopFileName, "\." A_LoopFileExt, ".wiki")
	TrayTip, % "HTML in Wiki umwandeln", % name

	file	:= FileOpen(A_LoopFileFullPath, "r`n").read()

	; Tag-Paare samt Inhalt entfernen

	file	:= RegExReplace(file, "si)<(h1)>.*?</\1>")

	; Bestimmte Tags benötigen Zeilenumbruch davor oder danach

	lf_back		:= "table|tr|/tr|/td|/th|ul|/ul|ol|/ol|/p"
	lf_front	:= "table|/table|tr|/tr|td|th|ul|/ul|ol|/ol|p|/p"
	file		:= RegExReplace(file, "i)(<(?:" lf_back ")\b[^<]*>)(?!\n)", "$1`n")
	file		:= RegExReplace(file, "i)(?<!\n)(<(?:" lf_front ")\b[^<]*>)", "`n$1")

	; Bestimmte Tags benötigen keinen Zeilenumbruch davor oder danach

	not_lf_back	:= "caption|pre|ol|ul"
	not_lf_front:= "/pre"
	file		:= RegExReplace(file, "i)(<(?:" not_lf_back ")\b[^<]*>)\s+", "$1")
	file		:= RegExReplace(file, "i)\s+(<(?:" not_lf_front ")\b[^<]*>)", "$1")

	; Bestimmte Tags brauchen Leerzeile davor oder danach

	nl_back	:= "/table"
	nl_front:= "h\d"
	file	:= RegExReplace(file, "i)(<(?:" nl_back ")\b[^<]*>)(?!\n\n)", "$1`n`n")
	file	:= RegExReplace(file, "i)(?<!\n\n)(<(?:" nl_front ")\b[^<]*>)", "`n`n$1")

	; nowiki

	file := RegExReplace(file, "(\||''+|\[\[|\]\])", "<nowiki>$1</nowiki>")
	file := RegExReplace(file, "(?:<p>|\n)\K(#|\*)(?=\w)", "<nowiki>$1</nowiki>")

	; Sonderfall: Code und Absätze in Aufzählung

	pos := 1
	While (pos := RegExMatch(file, "i)<li\b.*?>(.*?)</li>", s, pos + StrLen(s1)))
	{
		; Code

		pos2 := 1
		While (pos2 := RegExMatch(s1, "i)\s*<pre\b.*?>(.*?)</pre>\s*", x, pos2 + StrLen(x1)))
		{
			x1 := RegExReplace(x1, "<.*?>") ; Formatierungen aufheben
			x1 := "<pre exclude>" RegExReplace(x1, "\n|<br>", "&#10;") "</pre>"
			s1 := RegExReplace(s1, "\s*" preg_quote(x),  x1)
		}
		
		; Absätze

		pos2 := 1
		While (pos2 := RegExMatch(s1, "i)\s*<p\b.*?>(.*?)</p>\s*", x, pos2 + StrLen(x1)))
		{
			x1 := RegExReplace(x1, "\n+", "<br>")
			s1 := RegExReplace(s1, preg_quote(x),  x1)
		}
		file := RegExReplace(file, preg_quote(s), "<li>" s1 "</li>")
	}

	; Code

	pos := 1
	While (pos := RegExMatch(file, "i)<pre\b(.*?)>(.*?)</pre>", s, pos + StrLen(s2)))
	{
		; pre tags von Sonderfall ausschließen

		If (s1 ~= "exclude")
		{
			s2	:= "<pre>" s2 "</pre>"
			file:= RegExReplace(file, preg_quote(s), s2)
		}

		; Kommentare

		pos2 := 1
		While (pos2 := RegExMatch(s2, "i)<em\b.*?>(.*?)</em>", x, pos2 + StrLen(x1)))
		{
			x1	:= "{{K|1=" RegExReplace(x1, "\n([ \t]*)", "}}`n$1{{K|1=") "}}"
			s2	:= RegExReplace(s2, preg_quote(x), x1)
		}

		; ----------------------------------------------------------------------
		
		If (s1 ~= "class=""Syntax""")
		{
			; Klammer "}" in Vorlagesyntax
			s2	:= RegExReplace(s2, "(?>=})}(?=})", "&#125;")
			s2	:= "{{Code_Gelb|1=" RegExReplace(s2, "\n", "<br>") "}}"
			file:= RegExReplace(file, preg_quote(s), s2)
		}
		Else
		{
			s2 := "`n!!SPACE!!" RegExReplace(s2, "\n", "`n!!SPACE!!") "`n"
			file := RegExReplace(file, preg_quote(s), s2)
		}
	}

	; Leerzeichen vom Anfang und Ende entfernen

	file := RegExReplace(file, "`am)^[ \t]+|[ \t]+$")

	; Anfangsleerzeichen von Code setzen

	file := RegExReplace(file, "!!SPACE!!", " ")

	; --------------------------------------------------------------------------
	; Zeilen abarbeiten
	; --------------------------------------------------------------------------

	Loop, Parse, file, `n, `r
	{
		line := A_LoopField

		; Nur body-Bereich abarbeiten

		If (line ~= "<(/|)body[^<]*>")
		{
			parsing := !parsing
			continue
		}
		If (!line or !parsing)
			continue

		; Tags durchgehen

		pos 	:= 0
		temp 	:= line
		Loop
		{
			If (pos := RegExMatch(temp, "<[^<>]*?>", s, pos + 1))
				Tag(s)
			Else
				break
		}

		; ----------------------------------------------------------------------
		; FORMATIERUNGEN
		; ----------------------------------------------------------------------

		line := RegExReplace(line, "i)<span class=""(.*?)"">", "<span style=""{{$1}}"">")
		line := RegExReplace(line, "i)<div class=""(.*?)"".*?>", "<div style=""{{$1}}"">")

		line := RegExReplace(line, "i)<(/|)(strong|b)\b.*?>", "'''")
		line := RegExReplace(line, "i)<(/|)(em|i)\b.*?>", "''")
		
		; ----------------------------------------------------------------------

		; Restliche Tags entfernen

		line := RegExReplace(line, "i)<(/|)(td|th|li|tr|a|caption|p|!--|ol|ul)\b[^<]*?>")

		; Entities entfernen

		line := UnHTM(line)

		; Darstellung von bestimmten Tags beibehalten

		If (name = "Hotstrings.wiki")
			line := RegExReplace(line, "<((/|)em)>", "&lt;$1&gt;")
		If (name = "StringSplit.wiki")
			line := RegExReplace(line, "<(br)>", "&lt;$1&gt;")
		If (name = "Transform.wiki")
		{
			line := RegExReplace(line, "\Q""<> in &quot;&<>\E", """&<> in &quot;&amp;&lt;&gt;")
			line := RegExReplace(line, "&", "&amp;")
			line := RegExReplace(line, "<(br)>", "&lt;$1&gt;")
		}

		; Ende

		content .= line "`n"
	}

	; --------------------------------------------------------------------------

	; Sonderfall: Progress.htm Farbtabelle

	If (name = "Progress.wiki")
	{
		search	:= "\| width=""16"" \| <img src=""\.\./images/clr/(.*?)\.gif"">"
		replace	:= "| bgcolor=""$1"" style=""{{color_td}}"" |"
		content := RegExReplace(content, search, replace)
	}

	; Nachkorrekturen

	content := RegExReplace(content, "\n\n\n+", "`n`n")
	content := RegExReplace(content, "\n+(\||!)", "`n$1")	; table

	; Wiki-Einstellungen

	content .= "`n__NOTOC__"

	; Wiki-Datei erstellen

	If !FileExist(path)
		FileCreateDir, % path
	FileOpen(path "\" name, "w`n", "UTF-8").Write(content)
}

Tag(match)
{
	global line, countchar, name
	static main_class
	; --------------------------------------------------------------------------
	; Tag-Informationen aus match extrahieren
	; --------------------------------------------------------------------------
	match_temp		:= match
	infos			:= "class|style|id|href|name"
	tag				:= {}
	If RegExMatch(match, "s)<(\S+).*>", s)
		tag.label	:= s1
	Loop, Parse, infos, "|"
	{
		If RegExMatch(match_temp, "s)" A_LoopField "=""(.*?)""", s)
		{
			tag[A_LoopField]	:= s1
			match_temp			:= RegExReplace(match_temp, preg_quote(s))
		}
	}
	If RegExMatch(match_temp, "s)<" tag.label "(.*)>", s)
		tag.misc	:= Trim(s1)
	; --------------------------------------------------------------------------
	; Tabelle
	; --------------------------------------------------------------------------
	If (tag.label = "table")
	{
		main_class := tag.class
		style := tag.class ? "{{" tag.class "}}" : ""
		style .= tag.style ? "; " tag.style : ""
		replace := (style ? "style=""" style """ " : "") tag.misc
		line := RegExReplace(line, preg_quote(match), "{| " replace)
	}
	If (tag.label = "caption")
	{
		line := RegExReplace(line, preg_quote(match), "|+ ")
	}
	If (tag.label = "tr")
	{
		line := RegExReplace(line, preg_quote(match), "|- ")
	}
	If (tag.label = "td")
	{
		style := tag.class ? "{{" tag.class "}}" : ""
		style .= tag.style ? "; " tag.style  "; " : ""
		style .= main_class ? "{{" main_class "_" tag.label "}}" : ""
		replace := (style ? "style=""" style """ " : "") tag.misc
		line := RegExReplace(line, preg_quote(match), "| " (replace ? replace " | " : ""))
	}
	If (tag.label = "th")
	{
		style := tag.class ? "{{" tag.class "}}" : ""
		style .= tag.style ? "; " tag.style  "; " : ""
		style .= main_class ? "{{" main_class "_" tag.label "}}" : ""
		replace := (style ? "style=""" style """ " : "") tag.misc
		line := RegExReplace(line, preg_quote(match), "| " (replace ? replace " | " : ""))
	}
	If (tag.label = "/table")
	{
		main_class := ""
		line := RegExReplace(line, preg_quote(match), "|}")
	}
	; --------------------------------------------------------------------------
	; Aufzählung
	; --------------------------------------------------------------------------
	If (tag.label = "ol")
		countchar .= "#"
	If (tag.label = "ul")
		countchar .= "*"
	If (tag.label ~= "/(ol|ul)")
		countchar := SubStr(countchar, 1, -1)
	If (tag.label = "li")
		line := RegExReplace(line, preg_quote(match), countchar " ")
	; --------------------------------------------------------------------------
	; Links
	; --------------------------------------------------------------------------
	If (tag.label = "a" and tag.href)
	{
		main_site := "http://www.autohotkey.net/~Ragnar/"

		; Dateinamenerweiterung
		If RegExMatch(tag.href, "\.\w+(?=(#|$))", extension)
			If (extension ~= "\.(ahk|zip)")
				tag.href := main_site tag.href

		; Externer Link
		If (tag.href ~= "(http|https|ftp):")
		{
			If RegExMatch(line, preg_quote(match) "(.*?)</a>", s)
			{
				; If the "named" version contains a closing square bracket "]",
				; then you must use the HTML special character syntax, i.e. &#93; 
				; otherwise the MediaWiki software will prematurely interpret this 
				; as the end of the external link.
				replace := "[" tag.href  " " RegExReplace(s1, "\]", "&#93;") "]"
				line := RegExReplace(line, preg_quote(s), replace)
			}
		}
		Else
		{
			; Interner Link
			If RegExMatch(line, preg_quote(match) "(.*?)</a>", s)
			{
				; Dateinamenerweiterung entfernen
				link := RegExReplace(tag.href, preg_quote(extension))
				; Name der zukünftigen Wikiseite extrahieren
				link := RegExReplace(link, "^.*?([^/\\]*?)$", "$1")
				; Sonderfall: Anweisungen
				link := RegExReplace(link, "^_", ".")
			 	; Sonderfall: Index-Verlinkung
			 	If (tag.href = "commands/index.htm")
			 		link := "Alphabetischer Befehls- und Funktionsindex"
			 	If (tag.href = "../index.htm")
			 		link := "Hauptseite"
			 	If (tag.href = "scripts/" or tag.href = "index.htm")
			 		link := "Script-Beispiele"
				replace := "[[" (link == s1 ? link : link "|" s1) "]]"
				
				line := RegExReplace(line, preg_quote(s), replace)
			}
		}
	}
	; --------------------------------------------------------------------------
	; Anker
	; --------------------------------------------------------------------------
	If (tag.label = "a" and tag.name)
		line := RegExReplace(line, preg_quote(match), "{{Anker|" tag.name "}}")
	If tag.id
		line := RegExReplace(line, preg_quote(match), "{{Anker|" tag.id "}}$0")
	; --------------------------------------------------------------------------
	; Überschriften
	; --------------------------------------------------------------------------
	If (tag.label ~= "^h\d$")
		line := RegExReplace(line, preg_quote(match), "`n{{" tag.label "|1=")
	If (tag.label ~= "/h\d")
		line := RegExReplace(line, preg_quote(match), "}}`n")
	; --------------------------------------------------------------------------
	; Sonderfall: Versionierung für wiki (AHKL_ChangeLog.htm)
	; --------------------------------------------------------------------------
	If RegExMatch(match, "<!--((?:/|)onlyinclude)-->", s)
		line := RegExReplace(line, preg_quote(match), "<" s1 ">")
}

UnHTM(HTM) {
 Static HT :=  "&aacuteá&acircâ&acute´&aeligæ&agraveà&amp&aringå&atildeã&au"
 . "mlä&bdquo„&brvbar¦&bull•&ccedilç&cedil¸&cent¢&circˆ&copy©&curren¤&dagger†&dagger‡&deg"
 . "°&divide÷&eacuteé&ecircê&egraveè&ethð&eumlë&euro€&fnofƒ&frac12½&frac14¼&frac34¾&gt>&h"
 . "ellip…&iacuteí&icircî&iexcl¡&igraveì&iquest¿&iumlï&laquo«&ldquo“&lsaquo‹&lsquo‘&lt<&m"
 . "acr¯&mdash—&microµ&middot·&nbsp &ndash–&not¬&ntildeñ&oacuteó&ocircô&oeligœ&ograveò&or"
 . "dfª&ordmº&oslashø&otildeõ&oumlö&para¶&permil‰&plusmn±&pound£&quot""&raquo»&rdquo”&reg"
 . "®&rsaquo›&rsquo’&sbquo‚&scaronš&sect§&shy &sup1¹&sup2²&sup3³&szligß&thornþ&tilde˜&tim"
 . "es×&trade™&uacuteú&ucircû&ugraveù&uml¨&uumlü&yacuteý&yen¥&yumlÿ&UumlÜ&AumlÄ&OumlÖ"
 pos1 := 0
 HTM2 := HTM
While % (pos1 := RegExMatch(HTM, "&(.*?);", s, pos1 + 1))
 	If (pos2 := RegExMatch(HT, s1))
 		HTM2 := RegExReplace(HTM2, "&" s1 ";", SubStr(HT, pos2 + StrLen(s1), 1), total)
Return HTM2
}

; preg_quote() setzt einen Backslash vor jedes Zeichen von str, 
; das zur Syntax eines regulären Ausdrucks gehört. Das ist nützlich, 
; wenn Sie einen Text nach Übereinstimmungen mit einer zur Laufzeit 
; erzeugten Zeichenkette durchsuchen müssen, die spezielle 
; RegEx-Zeichen enthalten könnte.
preg_quote(str)
{
	chars	:= "\.+*?[^]$(){}=!<>|:-"
	pos		:= 1
	While (char := SubStr(chars, pos++, 1))
		str	:= RegExReplace(str, "\" char, "\" char)
	Return str
}