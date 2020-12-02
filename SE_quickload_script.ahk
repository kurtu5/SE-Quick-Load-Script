;
;   Space Engineers
;

;  Quickly load a script into a PB by training this where to click.  This is to speed up development 
; and testing.
;
;  While in Terminal hit Shift+Alt+K and it will prompt you to teach it the locations of buttons.
;  After that, in Terminal hit Alt+K and it will click them in sequence to reload the script.  
; Version: 1.0
;
; Todo:
;    Implement search so the script shows up in a clickable location
;


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#IfWinActive, Space Engineers
#InstallMouseHook
SetCapsLockState, AlwaysOff

;;;
;;;  Save button locations across restarts
;;;
global ConfigFile := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".cfg"
global LogFile := A_ScriptDir . "\" . SubStr(A_ScriptName, 1, -4) . ".log"

; Create empty config
if not (FileExist(ConfigFile)) {
	FileAppend,
	(
[main]
trained=false
PB_Button=
PB_SearchStr=
PB_Button=
Edit_Button=
BrowseScripts_Button=
Script_SearchStr=
Script_Button=
CopyEditor_Button=
OK_Button=

	), % ConfigFile, utf-16 ; save your ini file asUTF-16LE
}
; Or read saved values
IniRead, temp, % ConfigFile, main, DeconstructButton
global DeconstructButton := temp == "" ? "" : {x: StrSplit(temp,",")[1], y: StrSplit(temp,",")[2]}


; Open Shipping
CapsLock & 5::
	Send 5
	Return	
5::
	if ( ShippingButton == "" ) {
		SetShippingButton()
	} else {
		BlockInput On
		CustomESC()
		Sleep 100
		Send {LShift down}
		Sleep 100
		Send {F3}
		Sleep 100
		Send {LShift up}
		Sleep 100
		MouseClick Left, ShippingButton["x"], ShippingButton["y"], 1, 0
		Sleep 100
		BlockInput Off
		Return
	}
	
!5::
	SetShippingButton()
Return

SetShippingButton() {
    UserPopupTip("Please click in the middle of the Shipping Button.  Hit Alt-CapsLock 5 to try again.")
    KeyWait, LButton, D
    MouseGetPos, X, Y
	ShippingButton := {x: X, y: Y}
	IniWrite %  X . "," . Y, % ConfigFile, main, ShippingButton
    UserPopupTip("")
}







;;;
;;;  Debug Log in the same directory as the script.  Uncomment Log lines to get output.
;;;
Log(text) {
   FileAppend, %text%, %LogFile%
}
    
;;;
;;; User Prompt
;;;
UserPopupTip(text) {
    if (text != "")
        Progress, B2 FS16 ZX10 ZY10 X50 Y100 W500 CTwhite CWgrey, %text%, , , Arial Bold
    else
        Progress, Off
}
UserPopupTipTimeOut:
    SetTimer UserPopupTipTimeOut, Off
    UserPopupTip("")
    Return

;;;
;;; Force Script Reload
;;;
!r::
    
	UserPopupTip("Reloading")
	Sleep 200
	UserPopupTip("")
	Reload
Return
#IfWinActive
