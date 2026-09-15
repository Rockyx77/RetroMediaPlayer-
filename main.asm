.686
.model flat, stdcall
option casemap:none

include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc

includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

.data
ClassName    db "MediaOverlayClass",0
WindowTitle  db "Media Controller",0
ButtonClass  db "BUTTON",0

PrevText     db "<",0
PlayText     db "PLAY / PAUSE",0
NextText     db ">",0

.data?
hInstance    HINSTANCE ?
hMediaWnd    HWND ?

.code

start:
    invoke GetModuleHandle,NULL
    mov hInstance,eax

    invoke WinMain,hInstance,NULL,NULL,SW_SHOWDEFAULT
    invoke ExitProcess,eax


WinMain proc hInst:HINSTANCE,hPrev:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD

    local wc:WNDCLASSEX
    local msg:MSG

    ; Window class
    mov wc.cbSize,SIZEOF WNDCLASSEX
    mov wc.style,CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc,offset WndProc
    mov wc.cbClsExtra,0
    mov wc.cbWndExtra,0

    push hInst
    pop wc.hInstance

    ; Built-in Windows icon
    invoke LoadIcon,NULL,IDI_INFORMATION
    mov wc.hIcon,eax
    mov wc.hIconSm,eax

    invoke LoadCursor,NULL,IDC_ARROW
    mov wc.hCursor,eax

    mov wc.hbrBackground,COLOR_WINDOW+1
    mov wc.lpszMenuName,NULL
    mov wc.lpszClassName,offset ClassName

    invoke RegisterClassEx,addr wc

    ; Main overlay
    invoke CreateWindowEx,\
        WS_EX_TOPMOST,\
        addr ClassName,\
        addr WindowTitle,\
        WS_POPUP or WS_VISIBLE,\
        700,400,500,150,\
        NULL,NULL,hInst,NULL

    mov hMediaWnd,eax

    ; Previous button
    invoke CreateWindowEx,\
        0,\
        addr ButtonClass,\
        addr PrevText,\
        WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
        75,50,90,45,\
        hMediaWnd,101,hInst,NULL

    ; Play / Pause button
    invoke CreateWindowEx,\
        0,\
        addr ButtonClass,\
        addr PlayText,\
        WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
        175,50,150,45,\
        hMediaWnd,100,hInst,NULL

    ; Next button
    invoke CreateWindowEx,\
        0,\
        addr ButtonClass,\
        addr NextText,\
        WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
        335,50,90,45,\
        hMediaWnd,102,hInst,NULL

    ; Alt + M
    invoke RegisterHotKey,hMediaWnd,1,MOD_ALT,'M'


msgloop:
    invoke GetMessage,addr msg,NULL,0,0

    cmp eax,0
    je done

    invoke TranslateMessage,addr msg
    invoke DispatchMessage,addr msg

    jmp msgloop


done:
    invoke UnregisterHotKey,hMediaWnd,1
    invoke ExitProcess,msg.wParam

WinMain endp


WndProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

    .if uMsg == WM_HOTKEY

        ; Alt + M = show / hide
        invoke IsWindowVisible,hWnd

        .if eax == 0
            invoke ShowWindow,hWnd,SW_SHOWNORMAL
            invoke SetForegroundWindow,hWnd
        .else
            invoke ShowWindow,hWnd,SW_HIDE
        .endif


    .elseif uMsg == WM_COMMAND

        ; Get button ID
        mov eax,wParam
        and eax,0FFFFh

        ; Previous
        .if eax == 101
            invoke keybd_event,VK_MEDIA_PREV_TRACK,0,0,0
            invoke keybd_event,VK_MEDIA_PREV_TRACK,0,KEYEVENTF_KEYUP,0

        ; Play / Pause
        .elseif eax == 100
            invoke keybd_event,VK_MEDIA_PLAY_PAUSE,0,0,0
            invoke keybd_event,VK_MEDIA_PLAY_PAUSE,0,KEYEVENTF_KEYUP,0

        ; Next
        .elseif eax == 102
            invoke keybd_event,VK_MEDIA_NEXT_TRACK,0,0,0
            invoke keybd_event,VK_MEDIA_NEXT_TRACK,0,KEYEVENTF_KEYUP,0
        .endif


    .elseif uMsg == WM_CLOSE

        invoke ShowWindow,hWnd,SW_HIDE


    .else

        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret

    .endif

    xor eax,eax
    ret

WndProc endp

end start