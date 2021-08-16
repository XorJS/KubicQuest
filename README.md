# Kubic Quest

Kubic Quest is my 3D game that I did for my end computer science school project in early 2000. 100% in assembly and software rasterizer.

![Screenshot0](/Screenshots/screenshot0.png)

More info here: https://www.jsr-productions.com/blogpost76aaed1.html

## Videos

[![Kubic Quest: Gameplay](http://img.youtube.com/vi/Ck8Y0p3449Q/0.jpg)](http://www.youtube.com/watch?v=Ck8Y0p3449Q "Kubic Quest: Gameplay")

[![Kubic Quest: Game Over](http://img.youtube.com/vi/v8tOxfxpPFA/0.jpg)](http://www.youtube.com/watch?v=v8tOxfxpPFA "Kubic Quest: Game Over")

## Requirements

### Run

- Download and install DosBox: https://www.dosbox.com/

### Compile

- Turbo Assembler: https://en.wikipedia.org/wiki/Turbo_Assembler 

## Files

- **Build.bat**: Launch turbo assembler (TASM) to compile and generate the Kubic Quest executable
- **dosbox-template.conf**: My DosBox config that work with Kubic Quest
- **GAME_DAT.jsr**: Kubic Quest Game Data
- **Game~001.fmt**: Kubic Quest In-game Music
- **Game~002.fmt**: Kubic Quest In-game Music
- **KQuest.asm**: Kubic Quest source code
- **KQuest.exe**: Fixed version for DosBox
- **License***: MIT License
- **README.md**: Déjà Vu!
- **Screenshots**: Screenshot folder

## Build
```
tasm KQuest.asm
tlink KQuest.obj /3
```

If you want to run on real hardware, you should replace those lines in KQuest.asm:

```
[6692] ;[DosBox] Call Get_Free_Xms
[6693] ;[DosBox] Call Check_Flat_Mode
[6695] ;[DosBox] Call Install_Flat_Mode
```
by
```
[6692] Call Get_Free_Xms
[6693] Call Check_Flat_Mode
[6695] Call Install_Flat_Mode
```

## Notes

*Did in early 2000, the code was in English but comments in French… Sorry!*

