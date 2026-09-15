# RetroMediaPlayer

A tiny native Windows media controller overlay written entirely in x86 Assembly.

> I was supposed to be studying.
>
> Instead, I decided writing a Windows media controller in Assembly was a better use of my time.
>
> So... here we are. 

## Features

* ▶️ Play / Pause
* ⏮️ Previous track
* ⏭️ Next track
* `Alt + M` to show / hide the overlay
* Always-on-top window
* Works with Windows media controls
* Extremely small native executable

## Built With

* **x86 Assembly**
* **UASM**
* **Win32 API**
* **MASM32 libraries**

No frameworks. No runtime. No Electron. Just Assembly and Win32.

## Building

This project uses UASM and the MASM32 libraries.

### Assemble

```bat
D:\UASM\uasm32.exe /coff main.asm
```

### Link

```bat
D:\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /ENTRY:start /OUT:MediaOverlay.exe main.obj D:\masm32\lib\user32.lib D:\masm32\lib\kernel32.lib
```

### Run

```bat
MediaOverlay.exe
```

## Why?

Windows already has media controls, but I wanted something extremely simple: a tiny overlay with just the controls I actually use.

I also wanted to see how small I could make a useful Windows utility using native Assembly.

## Status

**Working.**

The current version supports basic media playback controls and the `Alt + M` visibility toggle.

More features may come later.

## License

MIT License
