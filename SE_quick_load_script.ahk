;
;   Space Engineers - AutoHotKey Quick Load Script
;
;  Quickly load a script into a PB by training this where to click.  This is to speed up development.
;
;  Shift+Alt+K  ->  While in SE Terminal it will prompt you to teach it the locations of buttons and search strings for PB and script
;  Ctrl+Alt+K   ->  If you just want to reprogram the PB and Script name for searching.
;  Alt+K        ->  In Terminal it will search for the PB and click buttons in sequence to search for and load script.
;
; Version: 1.0
;
; Todo:
;    Done: Implement search so the script shows up in a clickable location
;    Not Done: Use Icontray menus for configuring this script.

#IfWinActive, Space Engineers
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Mouse click seem to behave better when in windows admin mode?
#SingleInstance Force ; To not prompt you to overwrite non Admin script
if !A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

; Event mode seems to work much better than Input for detecting mouse clicks
SendMode Event
SetMouseDelay, 1
global updowndelay := 50  ; Delay between mouse click down and up
global speed := 1 ; Speed between button presses

; Experimental
; You can try this mode but it doesn't work for me at all
;SendMode Input
;SetMouseDelay, 1 ?Set Higher?
;global updowndelay := 50  ; Delay between mouse click down and up
;global speed := 200 ; Speed between button presses

; Use BlockInput to stop user actions during replay.
global block := false   ; Setting to true messes stuff up it seems.  Just be careful to not move mouse too much.
;#InstallMouseHook   ; Never was sure what this did.
; End Ecperimental 

; Config and Log locations are in the same directoy as the AHK script
global ConfigFile := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".cfg"
global LogFile := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".log"

;;;
;;;  Trained button locations and search strings are saved when trained to ConfigFile
;;;
global trained := ""
global Buttons := {"TerminalSearchFocus_Button": ""
                  ,"PB_Button": ""
                  ,"Edit_Button": ""
                  ,"BrowseScripts_Button": ""
				  ,"ScriptSearchFocus_Button": ""
                  ,"Script_Button": ""
                  ,"CopyEditor_Button": ""
                  ,"OK_Button": ""
                  ,"ClearSearch_Button": "" }
global SearchStrings := {"PB_SearchStr": "", "Script_SearchStr": ""}

;;;
;;; Create empty trained data if file doesn't exist
;;;
if not (FileExist(ConfigFile)) {
	FileAppend, [main], %ConfigFile%, utf-16
	FileAppend, `ntrained=false,  %ConfigFile%
	For key, value in SearchStrings
	{
		FileAppend, `n%key%=, %ConfigFile%
	}
	For key, value in Buttons
	{
		FileAppend, `n%key%=, %ConfigFile%
	}
}

;;;
;;; Read any saved trained data
;;;
IniRead, trained, %ConfigFile%, main, trained
For key, value in SearchStrings
{
	IniRead, temp, %ConfigFile%, main, %key%
	SearchStrings[key] := temp
	;Prompt(" SearchStrings[" key "]=" . SearchStrings[key], 3000)
}
For key, value in Buttons
{
	IniRead, temp, %ConfigFile%, main, %key%
	Buttons[key] := temp
	;Prompt(" SearchStrings[" key "]=" . SearchStrings[key], 3000)
}

;;;
;;; Train all buttons and search strings
;;;
+!k::
	Prompt("Starting Training", 2000)
	SetButton("TerminalSearchFocus_Button", "Click the Terminal Search area")
	SetSearch("PB_SearchStr", "Enter in a search string to find your PB")
	PushButton("TerminalSearchFocus")
	DoSearch("PB_SearchStr")
	SetButton("PB_Button", "Click the PB block in the list")
	SetButton("Edit_Button", "Click the Edit button")
	SetButton("BrowseScripts_Button", "Click the Browse Scripts button")
	SetButton("ScriptSearchFocus_Button", "Click the Script Search area")
	SetSearch("Script_SearchStr", "Enter in a search string to find your script")
	DoSearch("Script_SearchStr")
	SetButton("Script_Button", "Click the script name in the list")
	SetButton("CopyEditor_Button", "Click the Copy to Editor button")
	SetButton("OK_Button", "Click the OK button")
	SetButton("ClearSearch_Button", "Click the X to clear the search")
	trained := true
	IniWrite, true, %ConfigFile%, main, trained
	Prompt("Successfully trained buttons and search strings!", 2000)
	Return
;;;
;;; Train search strings
;;;
^!k::
	SetSearch("PB_SearchStr", "Change search string for PB")
	SetSearch("Script_SearchStr", "Change search string for script")
	Prompt("Successfully trained search strings!", 2000)
	Return
		
;; Used trained button locations to refresh script source
!k::
	if (%trained% == false)
	{
		Prompt("Use hotkey Shift+Alt+K to train buttons and search strings.", 5000)
		Return
	}
	if (block)
		BlockInput, On
	Sleep %speed%
	PushButton("TerminalSearchFocus_Button")
	Sleep %speed%
	DoSearch("PB_SearchStr")
	Sleep %speed%
	PushButton("PB_Button")
	Sleep %speed%
	PushButton("Edit_Button")
	Sleep %speed%
	PushButton("BrowseScripts_Button")
	Sleep %speed%
	PushButton("ScriptSearchFocus_Button")
	Sleep %speed%
	DoSearch("Script_SearchStr")
	Sleep %speed%
	PushButton("Script_Button")
	Sleep %speed%
	PushButton("CopyEditor_Button")
	Sleep %speed%
	PushButton("OK_Button")
	Sleep %speed%
	Sleep 500
	PushButton("ClearSearch_Button")
	BlockInput, Off
	Return

;;;
;;; Get X,Y cords for button and save them
;;;
SetButton(buttonname, prompttext)
{
Prompt(prompttext)
	Prompt(prompttext)
    KeyWait, LButton, D
    MouseGetPos, X, Y
	pos := X . "," . Y
	Buttons[buttonname] := pos
	IniWrite, %pos%, %ConfigFile%, main, %buttonname%
    Prompt()
	Sleep 500
}

;;;
;;; Get search string and save it
;;;
SetSearch(searchname, prompttext)
{
	Prompt(prompttext)
	InputBox, UserInput  ;, "", "", ,  640, 480
	Sleep 500
	SearchStrings[searchname] := UserInput
	IniWrite, %UserInput%, %ConfigFile%, main, %searchname%
	Prompt()
}

;;;
;;;  Push saved button
;;;
PushButton(buttonname)
{
	X := StrSplit(Buttons[buttonname],",")[1]
	Y := StrSplit(Buttons[buttonname],",")[2]
	MouseMove X, Y
	MouseClick Left, X, Y, 1, 1, D
	Sleep %updowndelay%
	MouseClick Left, X, Y, 10, 1, U
}

;;;
;;; Enter in saved search string
;;;
DoSearch(searchname)
{
;Prompt("do search", 20000)
	string := SearchStrings[searchname]
	;Send, "testasdfad"
	Send, %string%
}
    
;;;
;;; User Prompt
;;;
Prompt(text="", timeout=0) {
    if (text != "")
        Progress, B2 FS10 ZX10 ZY10 X0 Y0 W500 CTwhite CWgrey, %text%, , , Arial Bold
    else
        Progress, Off
	if (timeout != 0) {
	Sleep timeout
	Progress, Off
	}
}
;;;
;;;  Debug Log in the same directory as the script, mainly used to aid development
;;;
Log(text) {
   FileAppend, %text%, %LogFile%
}

;;;
;;; Force Script Reload, mainly used to aid development
;;;
!r::
	Prompt("Reloading", 200)
	Reload
	Return
	
#IfWinActive