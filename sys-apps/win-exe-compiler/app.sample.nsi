/**
* Change settings below to set information about your application. 
* Uncomment VIAddVersionKey lines if needed.
* This file is an nsis installer file. http://nsis.sourceforge.net/
*/
!define PRODUCT_NAME "DeskshellApp"
!define PRODUCT_VERSION "0.1.0"
!define PRODUCT_PUBLISHER "DeskshellUser"
!define PRODUCT_WEB_SITE "http://github.com/sihorton/appjs-deskshell"
VIProductVersion "${PRODUCT_VERSION}.0.0"
VIAddVersionKey ProductName "${PRODUCT_NAME}"
VIAddVersionKey Comments "Deskshell - desktop applications built with html5 technology."
;VIAddVersionKey CompanyName company
;VIAddVersionKey LegalCopyright legal
VIAddVersionKey FileDescription "${PRODUCT_NAME}"
VIAddVersionKey FileVersion "${PRODUCT_VERSION}"
VIAddVersionKey ProductVersion "${PRODUCT_VERSION}"
VIAddVersionKey InternalName "${PRODUCT_NAME}"
;VIAddVersionKey LegalTrademarks ""
VIAddVersionKey OriginalFilename "${PRODUCT_NAME}.exe"

;icon to use for your executable
Icon "htdocs\favicon.ico"



/**
* Deskshell install information, no need to change.
*/
!define PRODUCT_UPDATE_NAME "deskshell"
!define DESKSHELL_INSTALL "$LOCALAPPDATA\Deskshell\Deskshell"
!define NEW_VERSION_URL "http://raw.github.com/sihorton/appjs-deskshell/master/installer/win/common/installer-runtime-version.txt"
!define NEW_VERSION_URL_PORTABLE "http://raw.github.com/sihorton/appjs-deskshell/master/installer/win/common/installer-portable-version.txt"
!define UPDATE_NAME "deskshell-installer"

!include "MUI2.nsh"
!define MUI_TEXT_INSTALLING_TITLE "Downloading"
!define MUI_TEXT_INSTALLING_SUBTITLE "Please wait while ${PRODUCT_UPDATE_NAME} is being downloaded."
!insertmacro MUI_LANGUAGE "English"

RequestExecutionLevel user
Caption "${PRODUCT_NAME}"
Name "${PRODUCT_NAME}"
ShowInstDetails hide

;executable name
OutFile "../app.exe"

Function .onInit
 Var /GLOBAL DeskshellPath
	;This code will detect if deskshell is installed
	;No need to edit this code.

    ;test for deskshell portable
    StrCpy $DeskshellPath '..\deskshell\deskshell.exe'
    IfFileExists "$DeskshellPath" LaunchDeskshell DeskshellMissing1
    
DeskshellMissing1:
    ;test for deskshell portable (allow running from deploy directory
    StrCpy $DeskshellPath '..\..\deskshell\deskshell.exe'
    IfFileExists "$DeskshellPath" LaunchDeskshell DeskshellMissing2
 DeskshellMissing2:
    
;test for deskshell portable2
    StrCpy $DeskshellPath '..\deskshell.exe'
    IfFileExists "$DeskshellPath" LaunchDeskshell DeskshellMissing3
    
 DeskshellMissing3:
    ;test for deskshell install location
    StrCpy $DeskshellPath "${DESKSHELL_INSTALL}.exe"
    IfFileExists "$DeskshellPath" LaunchDeskshell DeskshellMissing

LaunchDeskshell:
    Call GetParameters
    Pop $2
    Exec '$DeskshellPath "$EXEPATH" $2'
    ;To run your app with a console (debug) window comment out the above line and uncomment the below line.
    ;Exec '${DeskshellPath}_debug.exe "$EXEPATH" $2'
    Quit

DeskshellMissing:
; continue to rest of the installer which will offer to download and install for you.
FunctionEnd

Section "MainSection" SEC01
	;This code will download install deskshell and then run your application.
	;No need to change this code.

    SetAutoClose true
    Var /GLOBAL AvailableVersion
    Var /GLOBAL NewInstaller
    Var /GLOBAL MyPath

	;decide if you need to install the runtime or portable version of deskshell
    ;Call InstallRuntime
	Call InstallPortable
SectionEnd
Function InstallRuntime
MessageBox MB_YESNO 'This application requires the Deskshell runtime to be able to run. Would you like to download and install it now?' IDNO stopLaunch IDYES download
stoplaunch:
    Quit
download:
    inetc::get /SILENT  "${NEW_VERSION_URL}" "$TEMP\version-latest.txt"
    FileOpen $4 "$TEMP\version-latest.txt" r
    FileRead $4 $AvailableVersion
    FileRead $4 $NewInstaller
    FileClose $4


    inetc::get "$NewInstaller" "$TEMP\${UPDATE_NAME}.exe"
    Pop $0
    StrCmp $0 "OK" doinstall error
    error:
     MessageBox MB_OK "Error:$1 when downloading $NewInstaller. Please try again."
     Abort

    doinstall:
    Call GetParameters
    Pop $2

    FileOpen $5 "$LOCALAPPDATA\Deskshell\run.txt" w
    FileWrite $5 '"$EXEPATH" $2'
    FileClose $5
    
	ExecShell "open" '$TEMP\${UPDATE_NAME}.exe'
    Quit
FunctionEnd

Function InstallPortable
MessageBox MB_YESNO 'This application requires the Deskshell portable to be able to run. Would you like to download and install it now?' IDNO stopLaunch IDYES download
stoplaunch:
    Quit
download:
    inetc::get /SILENT  "${NEW_VERSION_URL_PORTABLE}" "$TEMP\version-latest.txt"
    FileOpen $4 "$TEMP\version-latest.txt" r
    FileRead $4 $AvailableVersion
    FileRead $4 $NewInstaller
    FileClose $4

    inetc::get "$NewInstaller" "$TEMP\${UPDATE_NAME}.exe"
    Pop $0
    StrCmp $0 "OK" doinstall error
    error:
     MessageBox MB_OK "Error:$1 when downloading $NewInstaller. Please try again."
     Abort

    doinstall:
    Call GetParameters
    Pop $2

    FileOpen $5 "$LOCALAPPDATA\Deskshell\run.txt" w
    FileWrite $5 '"$EXEPATH" $2'
    FileClose $5
    
	Push "$EXEPATH"
    Call GetParent
    Call GetParent
    Pop $MyPath
    Exec '$TEMP\${UPDATE_NAME}.exe /D=$MyPath\deskshell'
    Quit
FunctionEnd

Function GetParameters

  Push $R0
  Push $R1
  Push $R2
  Push $R3

  StrCpy $R2 1
  StrLen $R3 $CMDLINE

  ;Check for quote or space
  StrCpy $R0 $CMDLINE $R2
  StrCmp $R0 '"' 0 +3
    StrCpy $R1 '"'
    Goto loop
  StrCpy $R1 " "

  loop:
    IntOp $R2 $R2 + 1
    StrCpy $R0 $CMDLINE 1 $R2
    StrCmp $R0 $R1 get
    StrCmp $R2 $R3 get
    Goto loop

  get:
    IntOp $R2 $R2 + 1
    StrCpy $R0 $CMDLINE 1 $R2
    StrCmp $R0 " " get
    StrCpy $R0 $CMDLINE "" $R2

  Pop $R3
  Pop $R2
  Pop $R1
  Exch $R0

FunctionEnd

Function GetParent

  Exch $R0
  Push $R1
  Push $R2
  Push $R3

  StrCpy $R1 0
  StrLen $R2 $R0

  loop:
    IntOp $R1 $R1 + 1
    IntCmp $R1 $R2 get 0 get
    StrCpy $R3 $R0 1 -$R1
    StrCmp $R3 "\" get
  Goto loop

  get:
    StrCpy $R0 $R0 -$R1

    Pop $R3
    Pop $R2
    Pop $R1
    Exch $R0

FunctionEnd