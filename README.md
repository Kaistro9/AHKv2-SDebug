SDebug v0.1 (240710) for AutoHotKey v2
=====================

변수 내용을 보기 쉬운 문자열로 표시

핫키(HotKey)인 `(BackTick) 키를 눌러 디버그 창 표시/감춤

## Method

* Init(mainWinTitle, options?) - 사용전 초기화 (디버그용 새 창을 생성 및 핫키 설정)
* Log(description, vars*) - 변수 출력
* ToggleVisible() - 창 표시/감춤 토글
* Show() - 창 표시
* Hide() - 창 감춤

## Property

* gui - 디버그 윈도우 GUI 객체 (Gui Object)
* enabled - 디버그 활성화/비활성화 = [ true | false ]

## Options

* enabled : 디버그 활성/비활성 여부. false인 경우 기능을 완전 끔 (default: true)
* show_on_init : 초기화 시 디버그 창을 바로 표시할지 여부 (default: true)
* tab_size : 탭 크기 (default: 4)
* display_time : 출력시 앞에 시간 표시 여부 (default: true)
* x : 디버그 창 X 위치 (default: -1 (center))
* y : 디버그 창 Y 위치 (default: -1 (center))
* width : 새창 넓이 (default: 500)
* height : 새창 높이 (default: 600)
* padding : 새창에서 컨트롤들의 안쪽 여백 (default: 5)
* max_lines : 최대 표시할 줄 수 (default: 150)


## Examples

### 1) 초기화

```AutoHotkey
SDebug.Init("SDebug Test")
```

### 2) 여러 변수 출력

```AutoHotkey
SDebug.Log("number", 10, 21.923, 0xFF)
```

결과:

    ◆ number
    (1) <Integer> 10
    (2) <Float> 21.922999999999998
    (3) <Integer> 255

### 3) 정규표현식 매치 변수 출력

```AutoHotkey
RegExMatch("man on the moon", "(?<4word>[a-z]{4})", &matched)
SDebug.Log("regex matched", matched)
```

결과:

    ◆ regex matched
    (1) <RegExMatchInfo (1)> = {
        [1] <4word> (at 12) : <String (4)> "moon"
    }

### 4) 객체, Map, Array 등의 변수 출력

```AutoHotKey
o := {map:Map("a",65, "b",66, "c",67), cnt:2, str:"alphabet", time:FormatTime(, "yyyyMMddHHmmss"), arr:[1, 2, 3]}
SDEbug.Log("object", o)
```

결과:

    ◆ object
    (1) <Object (4)> = {
        map : <Map (3)> = [
            a : <Integer> 65,
            b : <Integer> 66,
            c : <Integer> 67
        ],
        cnt : <Integer> 2,
        str : <String (8)> "alphabet",
        time : <String:Time (14)> "20240710222402",
        arr : [
            1,
            2,
            3
        ]
    }
