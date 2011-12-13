#NoEnv
#SingleInstance force
SetBatchLines, -1

; Kategorien ermitteln

site := GetCategories()

; Ausnahmen: mehrere index

index := {"docs"			: "Hauptseite"
		, "docs\commands"	: "Alphabetischer Befehls- und Funktionsindex"
		, "docs\scripts"	: "Script-Beispiele"}

; Wiki-Ordner löschen

FileRemoveDir, wiki

;Progress

Loop, docs\*.htm, 0, 1
	Total := A_Index
SysGet, Mon, MonitorWorkArea
Progress, % "B R1-" Total " H50 W300 C0 X" MonRight - 300 " Y" MonBottom - 50

; Prozess beginnen

Loop, docs\*.htm, 0, 1
{
	parsing		:= 0
	countchar	:= ""
	content 	:= ""

	name := RegExReplace(A_LoopFileName, "\." A_LoopFileExt)

	; Mehrere index

	If (name = "index")
		name := index[A_LoopFileDir]

	Progress, %A_Index%, %A_Index%/%Total% - %name%

	file	:= FileOpen(A_LoopFileFullPath, "r`n").read()

	; Tag-Paare samt Inhalt entfernen

	file	:= RegExReplace(file, "si)<(h1)>.*?</\1>")

	; Bestimmte Tags benötigen Zeilenumbruch davor oder danach

	lf_back		:= "table|tr|/tr|/td|/th|/p|/ol|ol|/ul|ul|/li"
	lf_front	:= "table|/table|tr|/tr|td|th|p|/p|/ol|ol|/ul|ul"
	file		:= RegExReplace(file, "i)(<(?:" lf_back ")\b[^<]*>)(?!\n)", "$1`n")
	file		:= RegExReplace(file, "i)(?<!\n)(<(?:" lf_front ")\b[^<]*>)", "`n$1")

	; Bestimmte Tags benötigen keinen Zeilenumbruch davor oder danach

	not_lf_back	:= "caption|pre"
	not_lf_front:= "/pre"
	file		:= RegExReplace(file, "i)(<(?:" not_lf_back ")\b[^<]*>)\n+", "$1")
	file		:= RegExReplace(file, "i)\s+(<(?:" not_lf_front ")\b[^<]*>)", "$1")

	; Bestimmte Tags brauchen Leerzeile davor oder danach

	nl_back	:= "/table"
	nl_front:= "h\d"
	file	:= RegExReplace(file, "i)(<(?:" nl_back ")\b[^<]*>)(?!\n\n)", "$1`n`n")
	file	:= RegExReplace(file, "i)(?<!\n\n)(<(?:" nl_front ")\b[^<]*>)", "`n`n$1")

	; Zeichen/String von Wiki-Formatierung ausschließen

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
			x1 := RegExReplace(x1, "\n|<br>", "&#10;") ; Sonderbehandlung für Zeilenumbrüche 
			x1 := RegExReplace(x1, "<.*?>") ; restliche Formatierungen aufheben
			x1 := "<pre exclude>" x1 "</pre>" ; Ausschlussmarkierung
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
			s2	:= "<pre>" s2 "</pre>"

		; Klammer "}" in Vorlagesyntax

		If (s1 ~= "class=""Syntax""")
			s2	:= RegExReplace(s2, "}", "&#125;")

		; Kommentare

		pos2 := 1
		While (pos2 := RegExMatch(s2, "i)<em\b.*?>(.*?)</em>", x, pos2 + StrLen(x1)))
		{
			x1	:= "{{K|1=" RegExReplace(x1, "\n([ \t]*)", "}}`n$1{{K|1=") "}}"
			s2	:= RegExReplace(s2, preg_quote(x), x1)
		}

		; ----------------------------------------------------------------------
		
		If (s1 ~= "class=""Syntax""")
			s2	:= "{{Code_Gelb|1=" RegExReplace(s2, "\n", "<br>") "}}"
		Else
			s2 := "!!SPACE!!" RegExReplace(s2, "\n", "`n!!SPACE!!")


		file := RegExReplace(file, preg_quote(s), s2)
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

		If (line ~= "i)<(/|)body[^<]*>")
		{
			parsing := !parsing
			continue
		}
		If !parsing
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

		line := RegExReplace(line, "i)<(/|)(td|th|li|tr|a|caption|p|!--|ol|ul|tbody)\b[^<]*?>")

		; Entities entfernen

		line := UnHTM(line)

		; Darstellung von bestimmten Tags beibehalten

		If (name = "Hotstrings")
			line := RegExReplace(line, "<((/|)em)>", "&lt;$1&gt;")
		If (name = "StringSplit" or name = "LoopParse")
			line := RegExReplace(line, "<(br)>", "&lt;$1&gt;")
		If (name = "Transform")
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

	If (name = "Progress")
	{
		search	:= "\| width=""16"" \| <img src=""\.\./images/clr/(.*?)\.gif"">"
		replace	:= "| bgcolor=""$1"" style=""{{color_td}}"" |"
		content := RegExReplace(content, search, replace)
	}

	; Nachkorrekturen

	content := RegExReplace(content, "^\n+|\n+$") ; 
	content := RegExReplace(content, "\n\n\n+", "`n`n")
	content := RegExReplace(content, "\n+(\||!)", "`n$1")	; table

	; Zeilen entfernen

	content := RegExReplace(content, "!!REMOVE!!\n")

	; Internen Inhaltsverzeichnis unterdrücken

	content .= "`n`n__NOTOC__`n"

	; catn setzen

	maincat := 	(A_LoopFileDir ~= "commands") 	? "Befehl"
			: 	(A_LoopFileDir ~= "misc")		? "Sonstiges"
			:	(A_LoopFileDir ~= "objects")	? "Objekt"
			:	(A_LoopFileDir ~= "scripts")	? "Script"
			:	""

	If maincat
		content .= "`n[[cat:" maincat "]]"

	For k, cat in site[name]
		If (cat != " ")
			content .= "`n[[cat:" cat "]]"

	; Wiki-Datei erstellen

	If !FileExist("wiki")
		FileCreateDir, % "wiki"
	FileOpen("wiki\" name ".wiki", "w`n", "UTF-8").Write(content)
}

Tag(match)
{
	global line, countchar, name, index
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
		line := RegExReplace(line, preg_quote(match), "! " (replace ? replace " | " : ""))
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
	{
		countchar .= "#"
		line := RegExReplace(line, preg_quote(match), "!!REMOVE!!")
	}
	If (tag.label = "ul")
	{
		countchar .= "*"
		line := RegExReplace(line, preg_quote(match), "!!REMOVE!!")
	}
	If (tag.label ~= "/(ol|ul)")
		countchar := SubStr(countchar, 1, -1)
	If (tag.label = "li")
		line := RegExReplace(line, preg_quote(match), countchar " ")
	; --------------------------------------------------------------------------
	; Links
	; --------------------------------------------------------------------------
	If (tag.label = "a" and tag.href)
	{
		; Aufteilen

		tag.href := {full: tag.href}
		If RegExMatch(tag.href.full, "#.*", s)
		{
			tag.href.anchor := s
			tag.href.full := SubStr(tag.href.full, 1, -StrLen(s))
		}
		path := RegExReplace(tag.href.full, "/", "\")
		SplitPath, path, filename, dir, ext, namenoext
		tag.href.filename 	:= filename
		tag.href.dir 		:= dir
		tag.href.ext 		:= ext
		tag.href.namenoext	:= namenoext

		; Dateinamenerweiterung

		If (tag.href.ext ~= "ahk|zip") and !tag.href.dir
			tag.href.full := "http://www.autohotkey.net/~Ragnar/" tag.href.filename

		; Externer Link
		If (tag.href.full ~= "(http|https|ftp):")
		{
			If RegExMatch(line, preg_quote(match) "(.*?)</a>", s)
			{
				; If the "named" version contains a closing square bracket "]",
				; then you must use the HTML special character syntax, i.e. &#93; 
				; otherwise the MediaWiki software will prematurely interpret this 
				; as the end of the external link.
				s1 := RegExReplace(s1, "\]", "&#93;")
				replace := "[" tag.href.full tag.href.anchor " " s1 "]"
				line := RegExReplace(line, preg_quote(s), replace)
			}
		}
		Else
		{
			; Interner Link
			If RegExMatch(line, preg_quote(match) "(.*?)</a>", s)
			{
				; Sonderfall: Anweisungen
				link := RegExReplace(tag.href.namenoext tag.href.anchor, "^_", ".")
			 	; Sonderfall: Index-Verlinkung
			 	If (tag.href.filename = "index.htm")
			 	or (!tag.href.filename and !tag.href.anchor)
			 	{
			 		If !tag.href.dir
			 			link := index[A_LoopFileDir]
			 		Else If (tag.href.dir = "..")
			 			link := index["docs"]
			 		Else
			 			link := index["docs\" tag.href.dir]
			 	}
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
	; Tastendarstellung
	; --------------------------------------------------------------------------
	If (tag.label = "kbd")
		line := RegExReplace(line, preg_quote(match), "{{Taste|")
	If (tag.label = "/kbd")
		line := RegExReplace(line, preg_quote(match), "}}")
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

GetCategories()
{
	cat := [], site := {}, scan := 0

	catlist := {"Grundlagen und Syntax" 	: "Grundlage"
			,	"Objekte" 					: "Objektverwaltung"
			,	"Zu AutoHotkey_L wechseln"	: "AutoHotkey_L"
			,	"Umgebungsverwaltung" 		: "Systemumgebung"
			,	"Natives Code-Interop"		: "Interoperabilität"
			,	"COM" 						: "COM"
			,	"Datei-, Verzeichnis- und Laufwerksverwaltung": "Dateiverwaltung"
			,	"Ablaufsteuerung" 			: "Ablaufsteuerung"
			,	"If-Befehle" 				: "Bedingte Anweisung"
			,	"Loop-Befehle" 				: "Anweisungswiederholung"
			,	"Interne Funktionen"		: "Interne Funktion"
			,	"GUI, MsgBox, InputBox &amp; weitere Dialogfenster": "Benutzeroberfläche"
			,	"Maus und Tastatur"			: "Eingabegerätesteuerung"
			,	"Hotkeys und Hotstrings"	: " "
			,	"Mathematik" 				: "Berechnung"
			,	"Bildschirmverwaltung" 		: "Bildschirmverwaltung"
			,	"Sonstige Befehle"			: " "
			,	"Prozessverwaltung" 		: "Prozessverwaltung"
			,	"Registrierungsverwaltung" 	: "Registrierungsverwaltung"
			,	"Sound-Befehle" 			: "Soundverwaltung"
			,	"Stringverwaltung" 			: "Stringverwaltung"
			,	"Fensterverwaltung" 		: "Fensterverwaltung"
			,	"Steuerelemente" 			: "Steuerelementverwaltung"
			,	"Fenstergruppen" 			: "Fenstergruppenverwaltung"
			,	"#Direktiven" 				: "Direktive"}

	Loop, Read, Table of Contents.hhc
	{
		If RegExMatch(A_LoopReadLine, "i)<param name=""Name"" value=""(.*)"">", s)
		{
			If catlist[s1]
			{
				scan++
				cat[scan] := catlist[s1]
			}
		}

		If scan
		{
			If RegExMatch(A_LoopReadLine, "i)<param name=""Local"" value=""(.*)"">", s)
			{
				skip := 0
				path := RegExReplace(s1, "#.*")
				path := RegExReplace(path, "/", "\")
				SplitPath, path,,,, namenoext
				For k, v in site[namenoext]
				{
					If (v = cat[scan])
					{
						skip := 1
						Break
					}
				}
				If !skip
				{
					site[namenoext] := []
					site[namenoext].Insert(cat[scan])
				}
			}
		}

		If RegExMatch(A_LoopReadLine, "i)</ul>")
		{
			cat[scan].Remove()
			scan--
		}
	}
	Return % site
}