#NoEnv
#SingleInstance force
#persistent

Loop, docs\*.htm, 0, 1
{
	content 	:= ""
	path	:= RegExReplace(A_LoopFileDir, "docs", "wiki")
	name	:= RegExReplace(A_LoopFileName, "\." A_LoopFileExt, ".wiki")
	FileRead, file, % A_LoopFileFullPath

	; CR+LF in LF umwandeln
	
	file := RegExReplace(file, "\r")

	; Tags über mehrere Zeilen entfernen

	file := RegExReplace(file, "si)<style.*?>.*?</style>")
	file := RegExReplace(file, "si)<(!DOCTYPE|meta).*?>")

	; Alleinstehende Tags

	tags := "table|tr|/td|/th"
	file := RegExReplace(file, "i)(<(?:" tags ").*?>)(?!\n)", "$1`n")
	file := RegExReplace(file, "i)(?<!\n)(<(?:" tags ").*?>)", "`n$1")

	; Tags zusammenfassen

	; file := RegExReplace(file, "i)(<caption.*?>)\n", "$1", lol)
	; If lol
	; {
	If (A_LoopFileName = "Progress.htm")
		Clipboard := file
	; 	MsgBox, % lol
	; }
	Loop, Parse, file, `n, `r
	{
		; ; Entities umwandeln

		; line := UnHTM(A_LoopField)

		line := A_LoopField

		; Unnötiges überspringen

		If line contains <html>,</html>,<head>,</head>,<title>,<link,<body>,</body>,<h1>
			continue
		If (!code and !line)
			continue

		; nowiki

		line := RegExReplace(line, "(\||''+)", "<nowiki>$1</nowiki>")

		; Tags entfernen

		line := RegExReplace(line, "i)<\bp\b.*?>")

		; Leerzeichen und Tabulatoren vom Anfang und Ende entfernen

		line := !code ? Trim(line) : line
		; break

		; line := RegExReplace(line, "<br>(\s|)", "`n")
		; If (A_LoopFileName = "_Include.htm")
			; MSgBox, % line

		; ----------------------------------------------------------------------
		; AUFZÄHLUNGEN
		; ----------------------------------------------------------------------

		If RegExMatch(line, "i)<ol>", s)
		{
			countchar .= "#"
			line := RegExReplace(line, s)
		}
		If RegExMatch(line, "i)<ul>", s)
		{
			countchar .= "*"
			line := RegExReplace(line, s)
		}
		If RegExMatch(line, "i)</(ol|ul)>", s)
		{
			countchar := SubStr(countchar, 1, -1)
			line := RegExReplace(line, s, "`n")
		}
		line := RegExReplace(line, "i)<li.*?>", countchar " ")

		; ----------------------------------------------------------------------
		; LINKS
		; ----------------------------------------------------------------------

		; Dateiendung entfernen
				
		line := RegExReplace(line, "i)\.htm\b")

		; Extern
		
		line := RegExReplace(line, "i)<a href=""((?:http|https|ftp):.*?)"">(.+?)</a>", "[$1 $2]")

		; Intern

		next_pos := 0
		; If (A_LoopFileName = "_IfWinActive.htm")
		; 	MsGBox, % line
		Loop
		{
			next_pos++
			; If (A_LoopFileName = "Scripts.htm")
			; 	MsgBox, % SubStr(line, next_pos)
			If (regex_pos := RegExMatch(line, "i)<a href="".*?([^/]*?)"">(.*?)</a>", s, next_pos))
			{
				; If (A_LoopFileName = "Scripts.htm")
				;  MsgBox, % s2

				; Sonderfälle

				If !s2
					continue
				If (s2 = "diese Seite") ; Scripts.htm
					s1 := "Script-Beispiele"
				
				next_pos := regex_pos
				replace := (s1 = s2) ? "[[" s1 "]]" : "[[" s1 "|" s2 "]]"
				line := RegExReplace(line, "\Q" s "\E", replace, "", 1, next_pos)
			}
			Else
				break
		}

		; Spezialfall: Anweisungen

		line := RegExReplace(line, "\[\[_", "[[.")

		; Anker

		line := RegExReplace(line, "i)<a name=""(.*?)"".*?></a>", "{{Anker|$1}}")
		line := RegExReplace(line, "i)(<.*?id=""(.*?)"".*?>)", "{{Anker|$2}}`n$1")
		line := RegExReplace(line, "i)id=""(.*?)""")

		; ----------------------------------------------------------------------
		; ÜBERSCHRIFTEN
		; ----------------------------------------------------------------------

		line := RegExReplace(line, "i)<h2.*?>(.*?)</h2>", "`n==={{h2|$1}}===")
		line := RegExReplace(line, "i)<h3.*?>(.*?)</h3>", "`n{{h4|$1}}")
		line := RegExReplace(line, "i)<h4.*?>(.*?)</h4>", "`n{{h4L|$1}}")

		; ----------------------------------------------------------------------
		; TABLE
		; ----------------------------------------------------------------------
			
		; Tags mit Zeilenumbrüchen trennen	
		
		line := RegExReplace(line, "i)([^^])(<(?:table|tr|th|td).*?>)", "$1`n$2")
		
		RegExReplace(line, "i)<.*?[^<>]*?>(?CTag_Single)")

		; AHK_L-Tabellen

		line := RegExReplace(line, "i)<div class=""methodShort"" id=""(.*)"">", "<div style=""border:solid thin silver; padding:0.5em; margin-bottom:1em;"" id=""$1"">`n")
		
		Tag_Single(match, number, pos, haystack, needle)
		{
			global line, table_class
			static main_class

			markup := {table: "{|", caption: "|+", tr: "|-", td: "|", th: "!", b: "'''", strong: "'''", i: "''", em: "''"}

			; Tag-Informationen aus match extrahieren

			match_temp		:= match
			infos			:= "class|style|id|href"
			tag				:= {}
			If RegExMatch(match, "s)<(\S+).*>", s)
				tag.name	:= s1
			Loop, Parse, infos, "|"
			{
				If RegExMatch(match_temp, "s)" A_LoopField "=""(.*?)""", s)
				{
					tag[A_LoopField]	:= s1
					match_temp			:= RegExReplace(match_temp, "s)\Q" s "\E")
				}
			}
			If RegExMatch(match_temp, "s)<" tag.name "(.*)>", s)
				tag.misc	:= Trim(s1)

			; Tabelle

			If (tag.name = "table")
			{
				main_class := tag.class
				style := tag.class ? "{{" tag.class "}}" : ""
				style .= tag.style ? "; " tag.style : ""
				line := RegExReplace(line, "\Q" match "\E", "{|" (style ? " style=""" style """ " : "") tag.misc)
			}
			If (tag.name = "caption")
			{
				line := RegExReplace(line, "\Q" match "\E", "|+ ")
			}
			If (tag.name = "tr")
			{
				line := RegExReplace(line, "\Q" match "\E", "|- ")
			}
			If (tag.name = "td")
			{
				style := tag.class ? "{{" tag.class "}}" : ""
				style .= tag.style ? "; " tag.style  "; " : ""
				style .= main_class ? "{{" main_class "_" tag.name "}}" : ""
				line := RegExReplace(line, "\Q" match "\E", "|" (style ? " style=""" style """ " : "") tag.misc " | ")
			}
			If (tag.name = "th")
			{
				style := tag.class ? "{{" tag.class "}}" : ""
				style .= tag.style ? "; " tag.style  "; " : ""
				style .= main_class ? "{{" main_class "_" tag.name "}}" : ""
				line := RegExReplace(line, "\Q" match "\E", "!" (style ? " style=""" style """ " : "") tag.misc " | ")
			}
			If (tag.name = "/table")
			{
				main_class := tag.class
				line := RegExReplace(line, "\Q" match "\E", "|}")
			}
		}

		; ----------------------------------------------------------------------
		; CODE
		; ----------------------------------------------------------------------

		; Wenn keine Aufzählung, dann fortfahren

		If !countchar
		{
			; Wenn <pre> vorhanden ist,
			; dann diese und nächste Zeilen als Code ansehen

			If RegExMatch(line, "i)<pre(.*?)>", s)
			{
				If RegExMatch(s1, "i)class=""Syntax""")
				{
					syntax := 1
					line := RegExReplace(line, s, "{{Code_Gelb|1=")
				}
				Else
					code := 1
				line := RegExReplace(line, "i)<pre(.*?)>")
			}

			If syntax
			{
				line := line "<br>"
				; line := RegExReplace(line, "#", "<nowiki>#</nowiki>")
			}
			; Wenn Zeile zum Code gehört und <pre> nicht am Anfang steht,
			; dann ein Leerzeichen davor setzen,
			; außerdem Kommentare anpassen

			If (code and !RegExMatch(line, "i)(\s+|^)</pre>"))
			{
	
				; Wenn <em> vorhanden ist,
				; dann diese und nächste Zeilen als Kommentar ansehen

				If RegExMatch(line, "i)<em.*?>")
					comment := 1

				; Wenn Zeile zum Kommentar gehört, dann anpassen

				If comment
				{
					If RegExMatch(line, "i)<em.*?>(.*?)$")
						line := RegExReplace(line, "i)<em.*?>(.*?)$", "{{K|1=$1}}")
					Else
						line := RegExReplace(line, "(\s*)(\S)(.+)", "$1{{K|1=$2$3}}")
				}

				; Wenn </em> vorhanden ist, dann Kommentar schließen
				
				If RegExMatch(line, "i)</em>", s)
				{
					line := RegExReplace(line, s)
					comment := 0
				}
				line := " " line
			}

			; Wenn </pre> vorhanden ist, dann Code schließen

			If RegExMatch(line, "i)</pre>")
			{
				If syntax
				{
					syntax := 0
					line := RegExReplace(line, "i)</pre>", "}}")
					line := RegExReplace(line, "i)<br>", "")
				}
				Else
				{
					code := 0
					line := RegExReplace(line, "i)</pre>", "`n")
				}
			}
		}
		; ----------------------------------------------------------------------
		; FORMATIERUNGEN
		; ----------------------------------------------------------------------

		; ---- unbedingt noch anpassen

		line := RegExReplace(line, "i)<span class=""(ver|dull)"">(.*?)</span>", "{{ver|$2}}")
		line := RegExReplace(line, "i)<span class=""red"">(.*?)</span>", "{{red|$1}}")
		line := RegExReplace(line, "i)<span class=""blue"">(.*?)</span>", "{{blue|$1}}")

		; ---- Vorlage

		line := RegExReplace(line, "i)<span class=""(.*?)"">(.*?)</span>", "<span style=""{{$1}}"">$2</span>")

		line := RegExReplace(line, "i)<(/|)(strong|b)>", "'''")
		line := RegExReplace(line, "i)<(/|)(em|i)>", "''")
		
		; ----------------------------------------------------------------------

		; Wenn kein Code, dann doppelte Leerzeichen entfernen

		If !code
			line := RegExReplace(line, "\S\K  (?=\S)", " ")

		; Bestimmte schließende Tags mit Zeilenumbruch ersetzen

		line := RegExReplace(line, "i)</(p)>", "`n")

		; Restliche Tags entfernen

		line := RegExReplace(line, "i)<(/|)\b(td|th|li|tr|a|caption)\b.*?>", "")

		; Nachbearbeitung

		line := RegExReplace(line, "^(#|\*)(\w)", "<nowiki>$1</nowiki>$2")

		; Entities entfernen

		line := UnHTM(line)

		; Darstellung von bestimmten Tags beibehalten

		line := RegExReplace(line, "<(/|)\b(em)\b>", "&lt;$1$2&gt;") ; em - Hotstrings.htm

		; Ende

		content .= line "`n"
	}

	; --------------------------------------------------------------------------
	; Sonderfall: Aufzählung
	; --------------------------------------------------------------------------

	; Immer mindesten eine Leerzeile zwischen den Aufzählungen

	content := RegExReplace(content, "[^\n]\K\n(#|\*) ", "`n`n$1 ")

	; Code in Aufzählung anpassen

	next_pos := 0
	Loop
	{
		next_pos++
		If (regex_pos := RegExMatch(content, "\n<pre.*?>(.*?)</pre>\n", s, next_pos))
		{
			; Msgbox, % s1
			next_pos := regex_pos
			s1 := RegExReplace(s1, "(\n|<br>)", "&#10;")
			s1 := RegExReplace(s1, "'+")
			s1 := RegExReplace(s1, "{{.*?\|(.*?)}}", "$1")
			content := RegExReplace(content, "\Q" s "\E", "<pre>" s1 "</pre>")
		}
		Else
			break
	}

	; Immer mindesten eine Leerzeile zwischen den Aufzählungen

	content := RegExReplace(content, "[^\n]\K\n(#|\*) ", "`n`n$1 ")

	; Absätze in Aufzählung anpassen

	next_pos := 0
	Loop
	{
		next_pos++
		If (regex_pos := RegExMatch(content, "\n(#|\*) (.*?)\n\n", s, next_pos))
		{
			next_pos := regex_pos
			; If (A_LoopFileName = "KeyList.htm")
			; 	MsgBox, % s2
			s2 := RegExReplace(s2, "^\n+")	; Anfangsleerzeilen entfernen
			s2 := RegExReplace(s2, "\n", "<br>")
			content := RegExReplace(content, "\Q" s "\E", "`n" s1 " " s2 "`n`n")
		}
		Else
			break
	}

	; Leerzeilen zwischen Aufzählungen entfernen

	content := RegExReplace(content, "\n+((?:#|\*)+) ", "`n$1 ")

	; Zeilen in der Syntaxdarstellung zusammenfassen

	If RegExMatch(content, "si){{Code_Gelb\|1=(.*?)}}", s)
		content := RegExReplace(content, "si)\Q" s1 "\E", RegExReplace(s1, "\n"))

	; Nachkorrekturen

	content := RegExReplace(content, "\n\n+ \n", "`n`n")
	content := RegExReplace(content, "\n\n\n+", "`n`n")
	content := RegExReplace(content, "\n\n(\||!)", "`n$1")	; table
	; content := RegExReplace(content, "i)<(/|)\ba\b.*?>")
	; content := RegExReplace(content, "\n(#|\*)(\S)", "`n<nowiki>$1</nowiki>$2")

	; Wiki-Einstellungen

	content .= "`n__NOTOC__"

	; Wiki-Datei erstellen

	If !FileExist(path)
		FileCreateDir, % path
	FileDelete, % path "\" name
	FileAppend, % content, % path "\" name
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