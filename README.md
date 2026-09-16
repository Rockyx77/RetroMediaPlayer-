# RetroMediaPlayer

A tiny native Windows media controller overlay written entirely in **x86 Assembly**.

> I was supposed to be studying.
>
> Instead, I decided writing a Windows media controller in Assembly was a better use of my time.
>
> So... here we are.

## Features

* ▶️ Play / Pause
* ⏮️ Previous track
* ⏭️ Next track
* `Space` → Play / Pause
* `←` → Previous track
* `→` → Next track
* `Alt + M` → Show / hide the overlay
* Double-click → Teleport the window back to the center
* Always-on-top window
* Draggable
* Rounded corners because apparently rectangles weren't good enough
* Works with Windows media controls
* Extremely small native executable

## Built With

* **x86 Assembly**
* **UASM**
* **Win32 API**
* **MASM32 libraries**

No frameworks.
No runtime.
No Electron.
No 47 MB node_modules folder.

Just Assembly and Win32.

## Building

This project uses UASM and the MASM32 libraries.

### Assemble

```bat
D:\UASM\uasm32.exe /coff main.asm
```

### Link

```bat
D:\masm32\bin\link.exe /SUBSYSTEM:WINDOWS /ENTRY:start /OUT:RetroMediaPlayer.exe main.obj D:\masm32\lib\user32.lib D:\masm32\lib\kernel32.lib D:\masm32\lib\gdi32.lib
```

### Run

```bat
RetroMediaPlayer.exe
```

## Why?

Windows already has media controls.

I just wanted something extremely simple:

**three buttons, some keyboard shortcuts, and absolutely no reason for it to be this complicated.**

I also wanted to see how small I could make a useful Windows utility using native Assembly.

Apparently, the answer is:

**small enough that I started measuring the executable in KB instead of MB.**

## Current Status

**Working.**

### v1.2

The current version includes:

* Basic media playback controls
* Keyboard shortcuts
* `Alt + M` visibility toggle
* Double-click-to-center
* Draggable overlay
* Rounded corners
* Always-on-top behavior

It currently does exactly what I wanted it to do.

Which obviously means I'll probably add more stuff to it anyway.

## Roadmap

Maybe:

* Media metadata
* Album artwork
* Playback state
* Current media source
* More questionable decisions made entirely in Assembly

## Philosophy

Keep it small.

Keep it native.

Don't install half the internet just to draw three buttons.

## License

MIT License

Copyright (c) 2026 Rockyx77
