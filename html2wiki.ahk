#NoEnv
#SingleInstance force
SetBatchLines, -1

; Ausnahmen: mehrere index

keyword 	:= {Fenster			: "Fensterverwaltung"
			, 	Datei			: "Dateiverwaltung"
			,	Ordner			: "Ordnerverwaltung"
			,	Laufwerk		: "Laufwerksverwaltung"
			,	String			: "Stringverwaltung"
			,	Tastatur		: "Tastaturverwaltung"
			,	Maus			: "Mausverwaltung"
			,	Joystick		: "Joystickverwaltung"
			,	Steuerelement	: "Steuerelementverwaltung"
			,	Sound			: "Soundverwaltung"
			,	Objekt			: "Objektverwaltung"
			,	Prozess			: "Prozessverwaltung"
			,	Registrierung	: "Registrierungsverwaltung"
			,	Bildschirm		: "Bildschirmverwaltung"
			,	Kommentar		: "Kommentarverwaltung"
			,	Fehler			: "Fehlerbehandlung"
			,	Zwischenablage	: "Zwischenablageverwaltung"}

; Wiki-Ordner löschen

FileRemoveDir, wiki

;Progress

Loop, *.htm, 0, 1
	Total := A_Index
SysGet, Mon, MonitorWorkArea
Progress, % "B R1-" Total " H50 W300 C0 X" MonRight - 300 " Y" MonBottom - 50

; Prozess beginnen

Loop, *.htm, 0, 1
{
	parsing		:= 0
	countchar	:= ""
	content 	:= ""
	cat			:= {}

	file	:= FileOpen(A_LoopFileFullPath, "r`n").read()

	name	:= RegExReplace(A_LoopFileName, "\." A_LoopFileExt)

	; Mehrere index

	If (name = "index")
	{
		If RegExMatch(file, "<title>(.*?)</title>", s)
			name := UnHTM(s1)
	}

	Progress, %A_Index%, %A_Index%/%Total% - %name%

	; Kategorien abrufen

	If RegExMatch(file, "<meta name=""keywords"" content=""(.*?)"">", s)
	{
		meta_keywords := UnHTM(s1)
		Loop, Parse, meta_keywords, `,, %A_Space%
		{
			If keyword[A_LoopField]
				cat[A_Index] := keyword[A_LoopField]
			Else
				cat[A_Index] := A_LoopField
		}
		
	}

	; Titel ändern, falls Direktive

	If (name ~= "^_.*")
		content := "{{DISPLAYTITLE:" RegExReplace(name, "_", "#") "}}`n`n"

	; Tag-Paare samt Inhalt entfernen

	file		:= RegExReplace(file, "si)<(h1|script)\b.*?>.*?</\1>")

	; Bestimmte Tags entfernen (setzt gutes Indent voraus)

	file		:= RegExReplace(file, "i)\n<(/|)div\b.*?>")
	file		:= RegExReplace(file, "i)\n  <(/|)div\b.*?>")

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
	nl_front:= "h\d|pre"
	file	:= RegExReplace(file, "i)(<(?:" nl_back ")\b[^<]*>)(?!\n\n)", "$1`n`n")
	file	:= RegExReplace(file, "i)(?<!\n\n)(<(?:" nl_front ")\b[^<]*>)", "`n`n$1")

	; Zeichen/String von Wiki-Formatierung ausschließen

	file := RegExReplace(file, "\|", "&#124;")
	file := RegExReplace(file, "(''+|\[\[|\]\])", "<nowiki>$1</nowiki>")

	; Sonderfall: Code und Absätze in Aufzählung

	pos := 1
	While (pos := RegExMatch(file, "i)<li\b(.*?)>(.*?)</li>", s, pos + StrLen(s2)))
	{
		; Code

		pos2 := 1
		While (pos2 := RegExMatch(s2, "i)\s*<pre\b.*?>(.*?)</pre>\s*", x, pos2 + StrLen(x1)))
		{
			x1 := RegExReplace(x1, "\n|<br>", "&#10;") ; Sonderbehandlung für Zeilenumbrüche 
			x1 := RegExReplace(x1, "<.*?>") ; restliche Formatierungen aufheben
			x1 := "<pre exclude>" x1 "</pre>" ; Ausschlussmarkierung
			s2 := RegExReplace(s2, "\s*" preg_quote(x),  x1)
		}
		
		; Absätze

		pos2 := 1
		While (pos2 := RegExMatch(s2, "i)\s*<p\b.*?>(.*?)</p>\s*", x, pos2 + StrLen(x1)))
		{
			x1 := RegExReplace(x1, "\n+", "<br>")
			s2 := RegExReplace(s2, preg_quote(x),  x1)
		}

		file := RegExReplace(file, preg_quote(s), "<li" s1 ">" s2 "</li>")
	}

	; Code

	pos := 1
	While (pos := RegExMatch(file, "i)<pre\b(.*?)>(.*?)</pre>", s, pos + StrLen(s2)))
	{
		; pre tags von Sonderfall ausschließen

		If (s1 ~= "exclude")
			continue

		; Anker

		If RegExMatch(s1, "id=""(.*?)""", y)
			s_Anker := "{{Anker|" y1 "}}"
		Else
			s_Anker := ""

		; Kursiv mit Fett ersetzen

		s2	:= RegExReplace(s2, "<(/|)i>", "<$1b>")

		; Kommentare

		pos2 := 1
		While (pos2 := RegExMatch(s2, "i)<em\b(.*?)>(.*?)</em>", x, pos2 + StrLen(x2)))
		{
			; Anker

			If RegExMatch(x1, "id=""(.*?)""", y)
				x_Anker := "{{Anker|" y1 "}}"
			Else
				x_Anker := ""

			x2	:= x_Anker "''" RegExReplace(x2, "\n([ \t]*)", "''`n$1''") "''"
			s2	:= RegExReplace(s2, preg_quote(x), x2)
		}

		; ----------------------------------------------------------------------
		
		If (s1 ~= "class=""Syntax""")
			s2 := "<p class=""Syntax"">" s2 "</p>"
		Else
			s2 := "&nbsp;" s_Anker RegExReplace(s2, "\n", "`n&nbsp;")


		file := RegExReplace(file, preg_quote(s), s2)
	}

	; Leerzeichen vom Anfang und Ende entfernen

	file := RegExReplace(file, "`am)^[ \t]+|[ \t]+$")

	; Zeichen am Zeilenanfang nicht als Wiki-Markup interpretieren

	file := RegExReplace(file, "`am)^(<p\b[^<]*?>|)(#|\||\!|\*|\=|;|\:|')", "$1<nowiki/>$2")

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
			{
				If Tag(s)
					break
			}
			Else
				break
		}

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
		search	:= "\| style=""width: 16px;"" \| <img alt="""" src=""\.\./images/clr/(.*?)\.gif"">"
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

	; Kategorien setzen

	For k, catname in cat
		content .= "`n[[Kategorie:" UnHTM(catname) "]]"

	; Wiki-Datei erstellen

	If !FileExist("wiki")
		FileCreateDir, % "wiki"
	FileOpen("wiki\" name ".wiki", "w`n", "UTF-8").Write(content)
}

Tag(match)
{
	global line, countchar, name, index
	static main_class, skip
	static wiki_markups := "onlyinclude|nowiki"
	; --------------------------------------------------------------------------
	; Tag-Informationen aus match extrahieren
	; --------------------------------------------------------------------------
	match_temp		:= match
	infos			:= "class|style|id|href|name"
	tag				:= {}
	If RegExMatch(match, "s)<(\S+)(.*?)>", s)
	{
		tag.label	:= s1
		tag.params	:= s2
	}
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
	; Anker
	; --------------------------------------------------------------------------
	If (tag.label = "a" and tag.name)
		line := RegExReplace(line, preg_quote(match) "</a>", "{{Anker|" tag.name "}}")
	If (tag.label = "a" and tag.id)
		line := RegExReplace(line, preg_quote(match) "</a>", "{{Anker|" tag.id "}}")
	If (tag.id and !(tag.label ~= "^(tr|td|th|caption|div)$"))
		line := RegExReplace(line, preg_quote(match), "$0{{Anker|" tag.id "}}")
	; --------------------------------------------------------------------------
	; Tabelle
	; --------------------------------------------------------------------------
	If (tag.label = "table")
	{
		line := RegExReplace(line, preg_quote(match), "{|" tag.params)
	}
	Else If (tag.label = "tr")
	{
		line := RegExReplace(line, preg_quote(match), "|-" tag.params)
	}
	Else If (tag.label = "caption")
	{
		replace := (tag.params ? "|+" tag.params " | " : "|+ ")
		line := RegExReplace(line, preg_quote(match), replace)
	}
	Else If (tag.label = "td")
	{
		replace := (tag.params ? "|" tag.params " | " : "| ")
		line := RegExReplace(line, preg_quote(match), replace)
	}
	Else If (tag.label = "th")
	{
		replace := (tag.params ? "!" tag.params " | " : "! ")
		line := RegExReplace(line, preg_quote(match), replace)
	}
	Else If (tag.label = "/table")
	{
		main_class := ""
		line := RegExReplace(line, preg_quote(match), "|}")
	}
	; --------------------------------------------------------------------------
	; Aufzählung
	; --------------------------------------------------------------------------
	Else If (tag.label = "ol")
	{
		countchar .= "#"
		line := RegExReplace(line, preg_quote(match), "!!REMOVE!!")
	}
	Else If (tag.label = "ul")
	{
		countchar .= "*"
		line := RegExReplace(line, preg_quote(match), "!!REMOVE!!")
	}
	Else If (tag.label ~= "/(ol|ul)")
	{
		countchar := SubStr(countchar, 1, -1)
		line := RegExReplace(line, preg_quote(match))
	}
	Else If (tag.label = "li")
		line := RegExReplace(line, preg_quote(match), countchar " ")
	; --------------------------------------------------------------------------
	; Links
	; --------------------------------------------------------------------------
	Else If (tag.label = "a" and tag.href)
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
		If !filename
		{
			If tag.href.anchor
				tag.href.filename := A_LoopFileName
			Else
				tag.href.filename := "index.htm"
		}
		Else
			tag.href.filename := filename
		tag.href.dir 		:= dir
		tag.href.ext 		:= ext
		tag.href.namenoext	:= namenoext
		Loop, % A_LoopFileDir "\" tag.href.dir "\" tag.href.filename
    		tag.href.relative := SubStr(A_LoopFileLongPath, StrLen(A_WorkingDir)+2)

		; Dateinamenerweiterung

		If (tag.href.ext ~= "ahk|zip") and !tag.href.dir
			tag.href.full := "http://de.autohotkey.com/docs/scripts/" tag.href.filename

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
			 	{
			 		If FileExist(tag.href.relative)
			 			If RegExMatch(FileOpen(tag.href.relative, "r").Read(), "<title>(.*?)</title>", x)
			 				link := UnHTM(x1)
			 	}
				replace := "[[" (link == s1 ? link : link "|" s1) "]]"
				line := RegExReplace(line, preg_quote(s), replace)
			}
		}
	}
	Else If (tag.label = "/a")
		Return
	; --------------------------------------------------------------------------
	; Bilder
	; --------------------------------------------------------------------------
	Else If (tag.label = "img")
		Return
	; --------------------------------------------------------------------------
	; Absätze
	; --------------------------------------------------------------------------
	Else If (tag.label = "p" and tag.class = "syntax")
		skip := 1

	Else If (tag.label = "/p" and skip)
		skip := 0
	; --------------------------------------------------------------------------
	; Zeilenumbruch
	; --------------------------------------------------------------------------
	Else If (tag.label = "br")
		Return
	; --------------------------------------------------------------------------
	; Code
	; --------------------------------------------------------------------------
	Else If (tag.label ~= "^(/|)code$")
		Return

	Else If (tag.label = "pre" and tag.params = " exclude")
	{
		line := RegExReplace(line, preg_quote(match), "<pre>")
		skip := 1
	}

	Else If (tag.label = "/pre" and skip)
		skip := 0
	; --------------------------------------------------------------------------
	; Formatierung
	; --------------------------------------------------------------------------
	Else If (tag.label ~= "i)^(/|)(strong|b)$")
		line := RegExReplace(line, preg_quote(match), "'''")
	Else If (tag.label ~= "i)^(/|)(i|em)$")
		line := RegExReplace(line, preg_quote(match), "''")
	Else If (tag.label ~= "i)^(/|)(u|s|sup)$")
		Return
	Else If (tag.label ~= "i)^(/|)span$")
		line := RegExReplace(line, "i)<span class=""(.*?)"">", "<span style=""{{$1}}"">")
	Else If (tag.label ~= "i)^(/|)div$")
		Return
	; --------------------------------------------------------------------------
	; Überschriften
	; --------------------------------------------------------------------------
	Else If RegExMatch(tag.label, "(/|)h(\d)", s)
	{
		Loop % s2
			markup .= "="
		markup := (s1 ? " " markup : markup " ")
		line := RegExReplace(line, preg_quote(match), markup)
	}
	; --------------------------------------------------------------------------
	; Tastendarstellung
	; --------------------------------------------------------------------------
	Else If (tag.label = "kbd")
		line := RegExReplace(line, preg_quote(match), "{{Taste|")
	Else If (tag.label = "/kbd")
		line := RegExReplace(line, preg_quote(match), "}}")
	; --------------------------------------------------------------------------
	; Erzwungene Wiki-Markups
	; --------------------------------------------------------------------------

	; Versionierung für wiki (AHKL_ChangeLog.htm)

	Else If RegExMatch(tag.label, "!--(/|)(" wiki_markups ")--", s)
		line := RegExReplace(line, preg_quote(match), "<" s1 s2 ">")
	Else If (tag.label ~= wiki_markups)
		Return

	; --------------------------------------------------------------------------
	; Restliche Tags entfernen
	; --------------------------------------------------------------------------

	Else
		line := RegExReplace(line, preg_quote(match), "", "", 1)
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