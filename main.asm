.686
.model flat, stdcall
option casemap:none

include D:\masm32\include\windows.inc
include D:\masm32\include\user32.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\gdi32.inc

includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\gdi32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

WINDOW_WIDTH  EQU 465
WINDOW_HEIGHT EQU 130

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

; ============================================================
; Program Entry
; ============================================================

start:

    invoke GetModuleHandle,NULL
    mov hInstance,eax

    invoke WinMain,hInstance,NULL,NULL,SW_SHOWDEFAULT
    invoke ExitProcess,eax


; ============================================================
; WinMain
; ============================================================

WinMain proc hInst:HINSTANCE,hPrev:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD

    local wc:WNDCLASSEX
    local msg:MSG
    local screenW:DWORD
    local screenH:DWORD
    local posX:DWORD
    local posY:DWORD


    ; --------------------------------------------------------
    ; Register Window Class
    ; --------------------------------------------------------

    mov wc.cbSize,SIZEOF WNDCLASSEX
    mov wc.style,CS_HREDRAW or CS_VREDRAW
    mov wc.lpfnWndProc,offset WndProc
    mov wc.cbClsExtra,0
    mov wc.cbWndExtra,0

    push hInst
    pop wc.hInstance

    invoke LoadIcon,NULL,IDI_INFORMATION
    mov wc.hIcon,eax
    mov wc.hIconSm,eax

    invoke LoadCursor,NULL,IDC_ARROW
    mov wc.hCursor,eax

    mov wc.hbrBackground,COLOR_WINDOW+1
    mov wc.lpszMenuName,NULL
    mov wc.lpszClassName,offset ClassName

    invoke RegisterClassEx,addr wc


    ; --------------------------------------------------------
    ; Calculate Centered Position
    ; --------------------------------------------------------

    invoke GetSystemMetrics,SM_CXSCREEN
    mov screenW,eax

    invoke GetSystemMetrics,SM_CYSCREEN
    mov screenH,eax

    mov eax,screenW
    sub eax,WINDOW_WIDTH
    shr eax,1
    mov posX,eax

    mov eax,screenH
    sub eax,WINDOW_HEIGHT
    shr eax,1
    mov posY,eax


    ; --------------------------------------------------------
    ; Create Main Overlay
    ; --------------------------------------------------------

    invoke CreateWindowEx,\
        WS_EX_TOPMOST,\
        addr ClassName,\
        addr WindowTitle,\
        WS_POPUP or WS_VISIBLE,\
        posX,posY,\
        WINDOW_WIDTH,WINDOW_HEIGHT,\
        NULL,NULL,hInst,NULL

    mov hMediaWnd,eax


    ; --------------------------------------------------------
    ; Rounded Corners
    ; --------------------------------------------------------

    invoke CreateRoundRectRgn,\
        0,0,\
        WINDOW_WIDTH,WINDOW_HEIGHT,\
        24,24

    invoke SetWindowRgn,\
        hMediaWnd,eax,TRUE


    ; --------------------------------------------------------
    ; Previous Button
    ; --------------------------------------------------------

    invoke CreateWindowEx,\
        0,\
        addr ButtonClass,\
        addr PrevText,\
        WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
        58,42,90,45,\
        hMediaWnd,101,hInst,NULL


    ; --------------------------------------------------------
    ; Play / Pause Button
    ; --------------------------------------------------------

    invoke CreateWindowEx,\
        0,\
        addr ButtonClass,\
        addr PlayText,\
        WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
        158,42,150,45,\
        hMediaWnd,100,hInst,NULL


    ; --------------------------------------------------------
    ; Next Button
    ; --------------------------------------------------------

    invoke CreateWindowEx,\
        0,\
        addr ButtonClass,\
        addr NextText,\
        WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON,\
        318,42,90,45,\
        hMediaWnd,102,hInst,NULL


    ; --------------------------------------------------------
    ; Keyboard Focus
    ; --------------------------------------------------------

    invoke SetFocus,hMediaWnd


    ; --------------------------------------------------------
    ; Alt + M
    ; --------------------------------------------------------

    invoke RegisterHotKey,\
        hMediaWnd,1,MOD_ALT,'M'


    ; ========================================================
    ; Message Loop
    ; ========================================================

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


; ============================================================
; Window Procedure
; ============================================================

WndProc proc hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

    local hDC:HDC
    local hPen:HPEN
    local hOldPen:HGDIOBJ
    local hOldBrush:HGDIOBJ
    local ps:PAINTSTRUCT

    local screenW:DWORD
    local screenH:DWORD
    local posX:DWORD
    local posY:DWORD


    ; ========================================================
    ; Paint
    ; ========================================================

    .if uMsg == WM_PAINT

        invoke BeginPaint,hWnd,addr ps
        mov hDC,eax

        invoke CreatePen,PS_SOLID,2,0808080h
        mov hPen,eax

        invoke SelectObject,hDC,hPen
        mov hOldPen,eax

        invoke GetStockObject,NULL_BRUSH
        invoke SelectObject,hDC,eax
        mov hOldBrush,eax

        invoke RoundRect,\
            hDC,\
            2,2,\
            WINDOW_WIDTH-2,WINDOW_HEIGHT-2,\
            24,24

        invoke SelectObject,hDC,hOldBrush
        invoke SelectObject,hDC,hOldPen

        invoke DeleteObject,hPen
        invoke EndPaint,hWnd,addr ps

        xor eax,eax
        ret


    ; ========================================================
    ; Keyboard Shortcuts
    ; ========================================================

    .elseif uMsg == WM_KEYDOWN

        ; ----------------------------------------------------
        ; Space = Play / Pause
        ; ----------------------------------------------------

        .if wParam == VK_SPACE

            invoke keybd_event,\
                VK_MEDIA_PLAY_PAUSE,\
                0,\
                0,\
                0

            invoke keybd_event,\
                VK_MEDIA_PLAY_PAUSE,\
                0,\
                KEYEVENTF_KEYUP,\
                0


        ; ----------------------------------------------------
        ; Left Arrow = Previous
        ; ----------------------------------------------------

        .elseif wParam == VK_LEFT

            invoke keybd_event,\
                VK_MEDIA_PREV_TRACK,\
                0,\
                0,\
                0

            invoke keybd_event,\
                VK_MEDIA_PREV_TRACK,\
                0,\
                KEYEVENTF_KEYUP,\
                0


        ; ----------------------------------------------------
        ; Right Arrow = Next
        ; ----------------------------------------------------

        .elseif wParam == VK_RIGHT

            invoke keybd_event,\
                VK_MEDIA_NEXT_TRACK,\
                0,\
                0,\
                0

            invoke keybd_event,\
                VK_MEDIA_NEXT_TRACK,\
                0,\
                KEYEVENTF_KEYUP,\
                0

        .endif

        xor eax,eax
        ret


    ; ========================================================
    ; Double Click = Return To Center
    ; ========================================================

    .elseif uMsg == WM_NCLBUTTONDBLCLK

        ; ----------------------------------------------------
        ; Get screen dimensions
        ; ----------------------------------------------------

        invoke GetSystemMetrics,SM_CXSCREEN
        mov screenW,eax

        invoke GetSystemMetrics,SM_CYSCREEN
        mov screenH,eax


        ; ----------------------------------------------------
        ; Calculate centered X
        ; ----------------------------------------------------

        mov eax,screenW
        sub eax,WINDOW_WIDTH
        shr eax,1
        mov posX,eax


        ; ----------------------------------------------------
        ; Calculate centered Y
        ; ----------------------------------------------------

        mov eax,screenH
        sub eax,WINDOW_HEIGHT
        shr eax,1
        mov posY,eax


        ; ----------------------------------------------------
        ; Move window to center
        ; ----------------------------------------------------

        invoke SetWindowPos,\
            hWnd,\
            HWND_TOPMOST,\
            posX,posY,\
            0,0,\
            SWP_NOSIZE or SWP_NOACTIVATE


        xor eax,eax
        ret


    ; ========================================================
    ; Window Dragging
    ; ========================================================

    .elseif uMsg == WM_NCHITTEST

        invoke DefWindowProc,\
            hWnd,\
            uMsg,\
            wParam,\
            lParam

        cmp eax,HTCLIENT
        jne hit_done

        mov eax,HTCAPTION

hit_done:

        ret


    ; ========================================================
    ; Alt + M
    ; ========================================================

    .elseif uMsg == WM_HOTKEY

        invoke IsWindowVisible,hWnd

        .if eax == 0

            invoke ShowWindow,\
                hWnd,\
                SW_SHOWNORMAL

            invoke SetForegroundWindow,hWnd
            invoke SetFocus,hWnd

        .else

            invoke ShowWindow,\
                hWnd,\
                SW_HIDE

        .endif


    ; ========================================================
    ; Button Commands
    ; ========================================================

    .elseif uMsg == WM_COMMAND

        mov eax,wParam
        and eax,0FFFFh


        ; ----------------------------------------------------
        ; Previous
        ; ----------------------------------------------------

        .if eax == 101

            invoke keybd_event,\
                VK_MEDIA_PREV_TRACK,\
                0,\
                0,\
                0

            invoke keybd_event,\
                VK_MEDIA_PREV_TRACK,\
                0,\
                KEYEVENTF_KEYUP,\
                0


        ; ----------------------------------------------------
        ; Play / Pause
        ; ----------------------------------------------------

        .elseif eax == 100

            invoke keybd_event,\
                VK_MEDIA_PLAY_PAUSE,\
                0,\
                0,\
                0

            invoke keybd_event,\
                VK_MEDIA_PLAY_PAUSE,\
                0,\
                KEYEVENTF_KEYUP,\
                0


        ; ----------------------------------------------------
        ; Next
        ; ----------------------------------------------------

        .elseif eax == 102

            invoke keybd_event,\
                VK_MEDIA_NEXT_TRACK,\
                0,\
                0,\
                0

            invoke keybd_event,\
                VK_MEDIA_NEXT_TRACK,\
                0,\
                KEYEVENTF_KEYUP,\
                0

        .endif


        ; Return keyboard focus to main window

        invoke SetFocus,hWnd


    ; ========================================================
    ; Close
    ; ========================================================

    .elseif uMsg == WM_CLOSE

        invoke ShowWindow,\
            hWnd,\
            SW_HIDE


    ; ========================================================
    ; Default Handler
    ; ========================================================

    .else

        invoke DefWindowProc,\
            hWnd,\
            uMsg,\
            wParam,\
            lParam

        ret

    .endif


    xor eax,eax
    ret

WndProc endp


; ============================================================
; End
; ============================================================

end start