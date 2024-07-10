#Requires AutoHotkey v2.0
#SingleInstance force

#include SDebug.class.ahk

; ---

G_DOMAIN_NAME := "SDebug Test"

GUI_Main := Gui("", G_DOMAIN_NAME)
GUI_Main.Add("Button", "vBtnReload default x200 y10 w60 h24", "Reload").OnEvent("Click", GUI_handlerReload)

GUI_Main.Add("Text", "x10 y12 w170", "SDebug class : " SDebug.Version)
GUI_Main.Add("Text", "x10 y42 w170", "디버그 창 단축키 : ``")


Initialize()
return


Initialize()
{
	GUI_Main.Show("w270 h100")
	
	; SDebug 초기화
	SDebug.Init(G_DOMAIN_NAME,
		{
			show_on_init : false
			, hotkey : "``"
			, tab_size : 4
			, display_time : true
			, prefix : "◆"
			, x : -1
			, y : -1
			, width : 500
			, height : 600
			, padding : 5
			, max_lines : 150
		}
	)
	
	; 여러 변수를 한번에 출력
	SDebug.Log("number", 10, 21.923, 0xFF)
	
	; 정규표현식 매치 결과 출력
	RegExMatch("man on the moon", "(?<4word>[a-z]{4})", &matched)
	SDebug.Log("regex matched", matched)
	
	; 객체 및 Map, Array 복합적인 변수 출력
	o := {map:Map("a",65, "b",66, "c",67), cnt:2, str:"alphabet", time:FormatTime(, "yyyyMMddHHmmss"), arr:[1, 2, 3]}
	SDEbug.Log("object", o)
}

GUI_handlerReload(guiobj, eventInfo)
{
	Reload
}




