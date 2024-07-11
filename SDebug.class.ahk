#Requires AutoHotkey v2.0
#SingleInstance force

/*
 * SDebug for AutoHotKey v2
 * v0.1 (240710)
 *
 * 변수 내용을 보기 쉬운 문자열로 표시
 *
 *
 * @ Method
 *
 * Init(mainWinTitle, options?) - 사용전 초기화 (디버그용 새 창을 생성 및 핫키 설정)
 * Log(description, vars*) - 변수 출력
 * ToggleVisible() - 창 표시/감춤 토글
 * Show() - 창 표시
 * Hide() - 창 감춤
 *
 *
 * @ Property
 *
 * gui - 디버그 윈도우 GUI 객체 (Gui Object)
 * enabled - 디버그 활성화/비활성화 = [ true | false ]
 *
 *
 * @ Options
 *
 * enabled		: 디버그 활성/비활성 여부. false인 경우 기능을 완전 끔 (default: true)
 * show_on_init	: 초기화 시 디버그 창을 바로 표시할지 여부 (default: true)
 * tab_size 	: 탭 크기 (default: 4)
 * display_time	: 출력시 앞에 시간 표시 여부 (default: true)
 * x			: 디버그 창 X 위치 (default: -1 (center))
 * y			: 디버그 창 Y 위치 (default: -1 (center))
 * width 		: 새창 넓이 (default: 500)
 * height 		: 새창 높이 (default: 600)
 * padding 		: 새창에서 컨트롤들의 안쪽 여백 (default: 5)
 * max_lines 	: 최대 표시할 줄 수 (default: 150)
 *
 *
 * @ Examples
 *
 * SDebug.Init("SDebug Test")
 *
 * SDebug.Log("number", 10, 21.923, 0xFF)
 * > ◆ number
 *   (1) <Integer> 10
 *   (2) <Float> 21.922999999999998
 *   (3) <Integer> 255
 *
 * RegExMatch("man on the moon", "(?<4word>[a-z]{4})", &matched)
 * SDebug.Log("regex matched", matched)
 * > ◆ regex matched
 *   (1) <RegExMatchInfo (1)> = {
 *       [1] <4word> (at 12) : <String (4)> "moon"
 *   }
 *
 * o := {map:Map("a",65, "b",66, "c",67), cnt:2, str:"alphabet", time:FormatTime(, "yyyyMMddHHmmss"), arr:[1, 2, 3]}
 * SDEbug.Log("object", o)
 * > ◆ object
 *   (1) <Object (4)> = {
 *       map : <Map (3)> = [
 *           a : <Integer> 65,
 *           b : <Integer> 66,
 *           c : <Integer> 67
 *       ],
 *       cnt : <Integer> 2,
 *       str : <String (8)> "alphabet",
 *       time : <String:Time (14)> "20240710222402",
 *       arr : [
 *           1,
 *           2,
 *           3
 *       ]
 *   }
 *
 * ; GUI 컨트롤 중 Hotkey 객체 사용시 ctrl(^), shift(+), alt(!)를 보기 쉽게 변환 표시
 * GUI_Main.Add("Hotkey", "vHotkey1 x60 y80 w100", "").OnEvent("Change", GUI_handlerDebug)
 * GUI_handlerDebug(guiobj, evt)
 * {
 *     SDebug.Log("handlerDebug", guiobj)
 * }
 * > ◆ handlerDebug
 *   (1) [Gui.Hotkey] Hotkey1.Value = ^1 (ctrl+1)
 *
 *
 * @ Update
 * [v0.1.1] 24-07-12
 * - Gui Hotkey 컨트롤에서 특수키 변환 표시 지원 (^+! -> ctrl,shift,alt로 표시)
 * - 폰트, 크기 설정 추가
 *
 * [v0.1] 24-07-10
 * - 초기 버전
 */
class SDebug
{
	static Version := "v0.1 (240710)"
	
	static gui := false
	
	static _guiEdit := false
	static _mainWinTitle := ""
	static _winTitle := ""
	static _enabled := true
	static _isShow := false
	static _currentLines := 0
	
	static _options := Map(
		"show_on_init", false
		, "hotkey", "``"
		, "tab_size", 4
		, "display_time", true
		, "prefix", "◆"
		, "x", -1
		, "y", -1
		, "width", 500
		, "height", 600
		, "padding", 5
		, "font", "gulimche"
		, "font_size", "11"	; 11pt
		, "font_weight", "400"	; 400 = normal, 700 = bold
		, "max_lines", 150
	)
	
	__New() {
		throw Error("SDebug는 static 클래스 입니다", -1)
	}
	
	static Init(mainWinTitle, options := "", enabled := true) {
		if (options) {
			for key, val in options.OwnProps() {
				if (SDebug._options.Has(key))
					SDebug._options[key] := val
			}
		}
		
		SDebug._options["tab"] := ""
		Loop SDebug._options["tab_size"] {
			SDebug._options["tab"] .= " "
		}
		
		if ( ! SDebug.gui) {
			SDebug._mainWinTitle := mainWinTitle
			SDebug._winTitle := mainWinTitle "-Debug Window"
			SDebug.gui := GUI("+Owner", SDebug._winTitle)
			SDebug.gui.SetFont("s" SDebug._options["font_size"] " w" SDebug._options["font_weight"], SDebug._options["font"])
			
			w := SDebug._options["width"]
			h := SDebug._options["height"]
			p := SDebug._options["padding"]
			
			SDebug._guiEdit := SDebug.gui.Add("Edit", "x5 y5 w" (w - p - p) " h" (h - 35 - p - p) , "")
			SDebug.gui.Add("Button", "x" ((w - 80) / 2) " y" (h - 30 - p) " w80 h30", "닫기")
						.OnEvent("Click", (*) => SDebug.Hide())
		}
		
		SDebug.enabled := enabled
		
		if (SDebug._options["show_on_init"]) {
			SDebug.Show()
		}
	}
	
	static enabled {
		get {
			return SDebug._enabled
		}
		set {
			SDebug._enabled := value
			
			if (SDebug._enabled) {
				HotIfWinActive(SDebug._mainWinTitle)
				Hotkey SDebug._options["hotkey"], SDebug.ToggleVisible, "On"
				
				HotIfWinActive(SDebug._winTitle)
				Hotkey SDebug._options["hotkey"], SDebug.ToggleVisible, "On"
			} else {
				HotIfWinActive(SDebug._mainWinTitle)
				Hotkey SDebug._options["hotkey"], SDebug.ToggleVisible, "Off"
				
				HotIfWinActive(SDebug._winTitle)
				Hotkey SDebug._options["hotkey"], SDebug.ToggleVisible, "Off"
			}
		}
	}
	
	static Log(description, vars*) {
		if ( ! SDebug.enabled) {
			return
		}
		
		result := []
		for key, val in vars {
			result.push("(" A_Index ") " SDebug._stringfy(val))
		}
		
		result := SDebug.ArrayJoin(&result, "`n")
		line := SDebug.StrCount(&result, "`n") +2
		logs := SDebug._guiEdit.value
		over := (SDebug._currentLines + line) - SDebug._options["max_lines"]
		
		if (over > 0) {
			SDebug._currentLines+= (line - over)
			logs := SubStr(logs, 1, InStr(logs, "`n", false, , -over) -1)
		} else {
			SDebug._currentLines+= line
		}
		
		time := (SDebug._options["display_time"]) ? " [" FormatTime(, "HH:mm:ss") "]" : ""
		
		SDebug._guiEdit.value := Format("{1}{2} {3}`n{4}`n`n{5}",
										SDebug._options["prefix"], time, description, result, logs)
	}
	
	static _stringfy(obj, depth := 0) {
		if (isObject(obj)) {
			temp := []
			, t1 := SDebug.Replicate(SDebug._options["tab"], depth)
			, t2 := t1 . SDebug._options["tab"]
			
			; Map
			if (obj is Map) {
				for key, val in Obj {
					temp.push(
						Format(t2 "{1} : {2}",
								key, SDebug._stringfy(val, depth +1))
					)
				}
				
				temp := Format("<Map ({1})> = [`n{2}`n{3}]",
								obj.Count, RTrim(SDebug.ArrayJoin(&temp, ",`n")), t1)
			}
			
			; RegExMatch Match Object
			else if (obj is RegExMatchInfo) {
				Loop obj.Count {
					key := (obj.Name(A_Index) ? " <" obj.Name(A_Index) ">" : "")
					, val := obj[A_Index]
					, pos := obj.Pos(A_Index)
					
					temp.push(
						Format(t2 "[{1}]{2} (at {3}) : {4}",
								A_Index, key, pos, SDebug._stringfy(val, depth +1))
					)
				}
				
				temp := Format("<RegExMatchInfo ({1})> = {`n{2}`n{3}}",
								obj.Count, RTrim(SDebug.ArrayJoin(&temp, ",`n")), t1)
			}
			
			; Array
			else if (obj is Array) {
				Loop obj.Length {
					temp.push(Format(t2 "[{1}] : {2}", A_Index, SDebug._stringfy(obj[A_Index], depth +1)))
				}
				
				temp := Format("<Array ({1})> = [`n{2}`n{3}]",
								obj.Length, RTrim(SDebug.ArrayJoin(&temp, ",`n")), t1)
			}
			
			; Gui Control : Hotkey
			else if (obj.__Class = "Gui.Hotkey") {
				name := obj.Name ? obj.Name : "-"
				keys := []
				
				if (InStr(obj.Value, "+", false, 1) > 0)
					keys.push("shift")
				if (InStr(obj.Value, "^", false, 1) > 0)
					keys.push("ctrl")
				if (InStr(obj.Value, "!", false, 1) > 0)
					keys.push("alt")
				keys.push(RegExReplace(obj.Value, "[\+\!\^]+", ""))
				
				temp := Format("[{1}] {2}.Value = {3} ({4})", obj.__Class, name, obj.Value, SDebug.ArrayJoin(&keys, "+"))
				
			}
			
			; Object
			else {
				if (HasMethod(obj, "OwnProps")) {
					count := 0
					for key, val in obj.OwnProps() {
						temp.push(
							Format(t2 "{1} : {2}",
									key, SDebug._stringfy(val, depth +1))
						)
						count++
					}
					
					temp := Format("<Object ({1})> = {`n{2}`n{3}}",
									count, RTrim(SDebug.ArrayJoin(&temp, ",`n")), t1)
				} else {
					temp := "[Object]"
				}
			}
		}
		
		else if (obj is Number) {
			temp := Format("<{1}> {2}", Type(obj), String(obj))
		}
		
		else if (obj is String) {
			; YYYYMMDDHH24MISS 형식의 문자열인 경우
			if (isTime(obj)) {
				temp := Format('<String:Time ({1})> "{2}"', StrLen(obj), obj)
			} else {
				temp := Format('<String ({1})> "{2}"', StrLen(obj), obj)
			}
		}
		
		else {
			temp := "unknown"
		}
		
		return temp
	}
	
	static ToggleVisible() {
		if (SDebug._isShow)
			SDebug.Hide()
		else
			SDebug.Show()
	}
	
	static Show() {
		x := SDebug._options["x"] != -1 && isNumber(SDebug._options["x"]) ? "x" SDebug._options["x"] : ""
		y := SDebug._options["y"] != -1 && isNumber(SDebug._options["y"]) ? "y" SDebug._options["y"] : ""
		w := SDebug._options["width"]
		h := SDebug._options["height"]
		
		SDebug._isShow := true
		SDebug.gui.Show(Format("{1} {2} w{3} h{4}", x, y, w, h))
	}
	
	static Hide() {
		SDebug._isShow := false
		SDebug.gui.Hide()
	}

	static ArrayJoin(&arr, joinstr := ", ") {
		s := ""
		Loop arr.Length
			 s .= arr[A_Index] joinstr
		return RTrim(s, joinstr)
	}
	
	static Replicate(str, repeat) {
		r := ""
		Loop repeat
			r .= str
		Return r
	}
	
	static StrCount(&str, char) {
		p := 0, c := 0
		while (p := InStr(str, char, false, p +1, 1))
			c++
		return c
	}
}
