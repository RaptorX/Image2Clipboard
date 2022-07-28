#Requires Autohotkey v1.1.33+
;--
;@Ahk2Exe-SetVersion     0.2.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName Image2Clipboard
;@Ahk2Exe-SetDescription Allows you to select an image and load it to the clipboard
;*******************************************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses. 
; They're structured in a way to make learning AHK EASY.
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************************************
#SingleInstance,Force
#Include <Notify>
#Include <Gdip_All>

global script := {base         : script
                 ,name         : regexreplace(A_ScriptName, "\.\w+")
                 ,version      : "0.2.0"
                 ,author       : "Joe Glines"
                 ,email        : "joe.glines@the-automator.com"
                 ,crtdate      : "July 25, 2022"
                 ,moddate      : "July 25, 2022"
                 ,homepagetext : ""
                 ,homepagelink : ""
                 ,donateLink   : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
                 ,resfolder    : A_ScriptDir "\res"
                 ,iconfile     : A_ScriptDir "\res\main.ico"
                 ,configfile   : A_ScriptDir "\settings.ini"
                 ,configfolder : A_ScriptDir ""}

try script.Update("https://raw.githubusercontent.com/RaptorX/Image2Clipboard/master/ver"
                 ,"https://github.com/RaptorX/Image2Clipboard/releases/download/latest/Image2Clipboard.zip")
Catch err
	if err.code != 6 ; latest version
		MsgBox, % err.msg

IniRead, hk, % "settings.ini", % "Hotkeys", % "main", % "Browser_Back"
Hotkey, %hk%, % "Image_to_Clipboard"
return

Browser_Forward::Reload

Image_to_Clipboard(){

	FileSelectFile, File_Path
	if !File_Path
	{
		MsgBox, No File selected
		return
	}
	pToken	:= Gdip_Startup()
	pBitmap	:= Gdip_CreateBitmapFromFile(File_Path)
	hBitmap	:= Gdip_CreateHBITMAPFromBitmap(pBitmap)
	Gdip_DisposeImage(pBitmap)
	Gdip_Shutdown(pToken)
	SetClipboardData(8,hBitmap)
	DllCall("DeleteObject", "Uint", hBitmap)

	switch notification_type
	{
	case 0:
	ToolTip, % File_Path " - copied to clipboard"
	Sleep, 2000
	ToolTip
	}
	;   If (Display_Notification=1)
	;     Notify("Image on Clipboard",%clipboard%,5,"TS=14 TM=12 GC_=Yellow SI_=500"  ) ;SI=speed In- smaller is faster
	;   If (Display_Notification=2)
	;     Notify("Image on Clipboard",%clipboard%,5,"TS=14 TM=12 GC_=Yellow SI_=500  WP=" File_Path ) ;SI=speed In- smaller is faster
}
Return

;~ https://autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/page-2#entry151138
SetClipboardData(nFormat, hBitmap){
	DllCall("GetObject", "Uint", hBitmap, "int", VarSetCapacity(oi,84,0), "Uint", &oi)
	hDBI :=	DllCall("GlobalAlloc", "Uint", 2, "Uint", 40+NumGet(oi,44))
	pDBI :=	DllCall("GlobalLock", "Uint", hDBI)
	DllCall("RtlMoveMemory", "Uint", pDBI, "Uint", &oi+24, "Uint", 40)
	DllCall("RtlMoveMemory", "Uint", pDBI+40, "Uint", NumGet(oi,20), "Uint", NumGet(oi,44))
	DllCall("GlobalUnlock", "Uint", hDBI)
	DllCall("OpenClipboard", "Uint", 0)
	DllCall("EmptyClipboard")
	DllCall("SetClipboardData", "Uint", nFormat, "Uint", hDBI)
	DllCall("CloseClipboard")
}