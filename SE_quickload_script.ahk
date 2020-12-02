;
;   Space Engineers
;

;  Quickly load a script into a PB by training this where to click.  This is to speed up development 
; and testing.
;
;  While in Terminal hit Shift+Alt+K and it will prompt you to teach it the locations of buttons.
;  After that, in Terminal hit Alt+K and it will click them in sequence to reload the script.  
; Version: 1.0

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
; Create empty config
if not (FileExist(ConfigFile)) {
	FileAppend,
	(
[main]
DeconstructButton=
PliersButton=
ShippingButton=
	), % ConfigFile, utf-16 ; save your ini file asUTF-16LE
}
; Or read saved values
IniRead, temp, % ConfigFile, main, DeconstructButton
global DeconstructButton := temp == "" ? "" : {x: StrSplit(temp,",")[1], y: StrSplit(temp,",")[2]}

IniRead, temp, % ConfigFile, main, PliersButton
global PliersButton := temp == "" ? "" : {x: StrSplit(temp,",")[1], y: StrSplit(temp,",")[2]}

IniRead, temp, % ConfigFile, main, ShippingButton 
global ShippingButton := temp == "" ? "" : {x: StrSplit(temp,",")[1], y: StrSplit(temp,",")[2]}


;;;
;;;
;;;SetCapsLockState, AlwaysOff

; Open Plumbing
CapsLock & 1::
	Send 1
	Return	
1::
	CustomESC()s
    Send {F6}
	Send 5
    Return
	
; Open Gases
CapsLock & 2::
	Send 2
	Return	
2::
	CustomESC()
    Send {F7}
	Send 6
    Return
	
; Open Electrical
CapsLock & 3::
	Send 3
	Return	
3::
	CustomESC()
    Send {F2}
	Send 3
    Return


; Open Logic
CapsLock & 4::
	Send 4
	Return	
4::
	BlockInput On
	CustomESC()
	Sleep 100
	Send {LShift down}
	Sleep 100
	Send {F2}
	Sleep 100
	Send {LShift up}
	Send {=}
	BlockInput Off
    Return

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
;;;  Rotate
;;;
WheelLeft::
WheelRight::
	Send o
Return

;;;
;;; Browser_Back reassignment to Copy Build
;;;
XButton1::
Send {B}
Return

;;;
;;; Browser_Forward reassignment to Deconstruct Build
;;;
XButton2::
	if ( DeconstructButton == "" ) {
		SetDeconstructButton()
	} else {
		MouseGetPos, oldX, oldY
		Sleep 100
		MouseClick Left, DeconstructButton["x"], DeconstructButton["y"], 1, 0
		Sleep 100
		MouseMove, oldX, oldY, 0
	}
Return

!XButton2::
	SetDeconstructButton()
Return

SetDeconstructButton() {
    UserPopupTip("Please click in the middle of the Deconstruct Build button.  Hit Alt-XButton2 to try again.")
    KeyWait, LButton, D
    MouseGetPos, X, Y
	DeconstructButton := {x: X, y: Y}
			IniWrite %  X . "," . Y, % ConfigFile, main, DeconstructButton
    UserPopupTip("")
}

;;;
;;; Quickly copy parts to a new location.
;    Shift Click     - Copy selected tile and zoom focus to slot bookmarked with ONI Ctrl+2 command.  Use vanilla Shift-1 to go back.  
+LButton::
;UserPopupTip("+LButton")
;Sleep 1000
;UserPopupTip("")
Send {2}
   KeyWait, Shift
 ;  UserPopupTip("release")
;Sleep 1000
;UserPopupTip("")
Send {b}
;Sleep 1000

Return

; Remap Alt + Click to Shift Click
!LButton::
KeyWait, Alt
;UserPopupTip("shift click it")
;Sleep 1000
;UserPopupTip("")
Send {Shift down}
Sleep 50
Send {Click}
Sleep 50
Send {Shift up}

Return

;;;
;;; Shortcut for pliers while in overlay screen
;;;
Capslock & x::
	if ( PliersButton == "" ) {
		SetPliersButton()
	} else {
		MouseGetPos, oldX, oldY
		Sleep 100
		MouseClick Left, PliersButton["x"], PliersButton["y"], 1, 0
		Sleep 100
		MouseMove, oldX, oldY, 0
	}
Return

!x::
	SetPliersButton()
Return

SetPliersButton() {
    UserPopupTip("Please click in the middle of the Pliers button.  Hit Alt-x to try again.")
    KeyWait, LButton, D
    MouseGetPos, X, Y
	PliersButton := {x: X, y: Y}
		IniWrite %  X . "," . Y, % ConfigFile, main, PliersButton

    UserPopupTip("")
}










;;;
;;;  Debug Log in the same directory as the script.  Uncomment Log lines to get output.
;;;
Log(text) {
   FileAppend, %text%, ONI_ShortCut_Debuglog.txt
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
;;;  Custom ESC to exit overlays or other menus
;;;
CustomESC() {
return
	;Progress, B2 FS16 ZX10 ZY10 X50 Y100 W500 CTwhite CWgrey, "wqweqweqweqwe", , , Arial Bold
	;UserPopupTip("clickig")
	Click, Right
	Sleep 100
	Click, Right
	;Sleep 100
	;UserPopupTip("")
}
	
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
