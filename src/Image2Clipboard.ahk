;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
#SingleInstance,Force
#Include <Notify>
#Include <Gdip_All>

Browser_Forward::Reload
Browser_Back::
FileSelectFile, File
if !File
{
	MsgBox, No File selected
	return
}
Image_to_Clipboard(File,0)
return


Image_to_Clipboard(File_Path,notification_type:=0){
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