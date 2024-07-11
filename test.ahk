#Requires AutoHotkey v2.0
#SingleInstance force

#include SDebug.class.ahk

; ---

G_DOMAIN_NAME := "SDebug Test"

GUI_Main := Gui("", G_DOMAIN_NAME)
vBtnReload1 := GUI_Main.Add("Button", "vBtnReload default x200 y10 w60 h24", "Reload").OnEvent("Click", GUI_handlerReload)

vTxt1 := GUI_Main.Add("Text", "x10 y12 w170", "SDebug class : " SDebug.Version)
GUI_Main.Add("Text", "x10 y42 w170", "디버그 창 단축키 : ``")

GUI_Main.Add("Text", "x10 y66 w320 h2 0x10", "")

GUI_Main.Add("Text", "x10 y84 w60", "핫키:")
GUI_Main.Add("Hotkey", "vHotkey1 x60 y80 w100", "").OnEvent("Change", GUI_handlerDebug)




Initialize()
return


Initialize()
{
	GUI_Main.Show()
	
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
			, font : "gulimche"
			, font_size : "11"
			, font_weight : "400"
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

GUI_handlerDebug(guiobj, evt)
{
	SDebug.Log("handlerDebug", guiobj)
}

GUI_handlerReload(guiobj, eventInfo)
{
	Reload
}




