;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
; Website: https://www.jsr-productions.com/blogpost76aaed1.html
; GitHub: https://github.com/XorJS/KubicQuest
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;- Programmer Par : Jean-Sebastien Royer                                     -
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

Title KubicQuest
P486
Model Flat

MyStack Segment Para Stack 'Stack'
        Db 1000h dup (0)
MyStack Ends                                                
                
Data Segment Para Public Use16 'Data'
       ;            Description de la table GDT pour le Flat Mode
       ;            ---------------------------------------------
       ; 16 Bits  Longeur du Segment
       ; 24 Bits  Adresse Physique
       ; 08 Bits  Droits d'acces
       ; 16 Bits  Bits Supplementaires pour la longueur du segment
       ; La premiere occurence doit commencer par un segment nul
       ; La deuxieme occurence -
       ; L'adresse physique est null pour commencer au debut de la memoire
       ;  Droit d'acces a 092h pour propriete maximun pour un segment de
       ;  donnees.
       ;  Totalite de la memoire (4gb 2 premiers et 2 derniers octets)

 GDT_Table  Db 000h,000h,000h,000h,000h,000h,000h,000h ; Avec Segment Null
            Db 0FFh,0FFh,000h,000h,000h,092h,0CFh,0FFh ; Seg = 0 , Max =4gb

 GDT_Offset Dw $-GDT_Table,000h,000h

 M640x480x08Bpp Equ 0101h      ; Mode Video 640x480 avec 256 couleurs

 VesaInfo_Table_F0_Struc Struc
  Signature Dd ?  ; Signature Vesa indiquant si la carte adhere aux standards
                  ; Vesa ayant comme valeur "VESA" .
  Version_  Dw ?  ; Numero de Version [Xh.Xl]
  From_Ptr  Dd ?  ; Pointeur Vers une chaine contenant le nom du contructeur
                  ; et le modele de la carte. '/0'
  Fonction  Dd ?  ; Fonctionnalite (Futures Specification)
  List_Mode Dd ?  ; Pointeur vers Liste des modes.
  Memory    Dw ?  ; Memoire Totale dont la carte est munie.
                  ; Memoire Totale = Memory * 64ko
  Reserved  Db 236 dup (0) ; Inutilise, Reserver a des specifications futures.
 VesaInfo_Table_F0_Struc Ends

;-----------------------------------------------------------------------------
VesaInfo_Table_F1_Struc Struc
  Mode_Attr Dw ?           ; Attributs du Mode
                           ;  Bits 15-5  : Inutilises, Normalement a 0
                           ;        4 = 0: Mode Texte
                           ;            1: Mode Graphique
                           ;        3 = 0: Mode Monochrome, E/S = 3B4h
                           ;            1: Mode Video 7 ou 0Fh (Monochromes)
                           ;        2 = 0: Mode Couleur, E/S = 3D4h
                           ;            1: Fonction de Sorties Bios
                           ;        1 = 0: Pas d'information de mode etendu
                           ;          = 1: Info entendu debutent au depl 012h
                           ;        0 = 0: le mode n'est pas supporte par
                           ;               l'ecran (memoire)
                           ;            1: Mode Video Supporter
  WinA_Attr Db ?           ; Attributs de la fenetre A
  WinB_Attr Db ?           ; Attributs de la fenetre B
  Win_Granu Dw ?           ; Granularite de la fenetre, la plus petit partie
                           ; de la fenetre pouvant etre place en memoire Video
  Win_Size  Dw ?           ; Taille de la fenetre (Ko)
  WinA_Seg  Dw ?           ; Segment de la fenetre A
  WinB_Seg  Dw ?           ; Segment de la fenetre B
  WinF_Ptr  Dd ?           ; Pointeur de la fonction Schema de fenetre (4F05)
  O_Bal_Lin Dw ?           ; Octets par ligne de balayage logique
 
 ; Les informations de mode entendu suivantes de sont valides que si le bit
 ; 1 du mot 0 des attributs du mode est positionne a 1.
  X_Resolut Dw ?           ; Resolution horizontal, Nombre de pixel par ligne
  Y_Resolut Dw ?           ; Resolution verticale
  Car_Larg  Db ?           ; Largeur de la cellule de caracteres
  Car_Haut  Db ?           ; Hauteur de la cellule de caracteres
  Mem_Plan  Db ?           ; Nombre de plans de memoire.
  Pixel_Bit Db ?           ; Nombre de bit par Pixel
  Bank_Nbrs Db ?           ; Nombre de banques
  Mem_Organ Db ?           ; Organisation de la memoire
                           ;  0     = Mode Texte(Caractere et Attribut)
                           ;  1     = Graphique Cga.
                           ;  2     = Graphique Hercule
                           ;  3     = 4-plan.
                           ;  4     = Pixels par paquet
                           ;  5     = Nonchain 4, 256 couleurs
                           ;  6-F   = reserve pour les modes Vesa a venir
                           ;  10-FF = Vendeur defini
  Bank_Size Db ?           ; Taille de banque est Ko
  Page_Nbr  Db ?           ; Nombre de pages images
  Page_Fnct Db ?           ; Fonction de page (Toujours 1)
  Inutilise Db 224 Dup (0) ; Inutilise, specification futures
 VesaInfo_Table_F1_Struc Ends

 VesaInfo_Table_F0 VesaInfo_Table_F0_Struc 1 Dup (<>) ; 1e Table D'info
 VesaInfo_Table_F1 VesaInfo_Table_F1_Struc 1 Dup (<>) ; 2e Table D'info                                                                       

 Endl Equ 0Dh,0Ah
 Vesa_Erreur Db "Le Mode Vesa n'est pas support‚ !",Endl,'$'
 No_Flat_Mode Db "Votre Machine est en Mode Virtuel 86.",Endl
              Db "D‚sactivez le gestionnaire d'EMS si activ‚"
              Db " (Emm386.exe).",Endl
              Db "Un gestionnaire XMS est requis (Himem.Sys).",Endl,Endl
              Db "Red‚marrez votre ordinateur et aprŠs le [Memory test], "
              Db Endl
              Db "appuyer sur la touche [F8] et s‚lectionner l'invitation "
              Db Endl,"Invite MS-DOS Seulement,",Endl
              Db "dans le menu de d‚marrage de Microsoft.",Endl,'$'
 No_Xms_Drv   Db "Aucun gestionnaire d'XMS install‚ (Himem.Sys).",Endl,'$'
 Xms_Drv_Lw   Db "Votre gestionnaire d'XMS doit posseder une version,",Endl
              Db "Ult‚rieur ou ‚gale a 2.0 .",Endl,'$'
 Miss_Mem     Db "Manque de M‚moire.",Endl,'$'
 Miss_File    Db "Fichier Non-Trouver.",Endl,'$'

 Filename     Db "Game_Dat.Jsr",00h
 Mem_Handle   Dw 00h   ; Handle de memoire conventionnelle de 64 ko

 Key_Table Db 128 Dup (1)      ; Table du Keyboard
 Xms_Drivers_Ptr  Dd 'JSR '    ; Pointeur sur le gestionnaire d'XMS

 Xms_Struc Struc
 Xms_Length  Dw ?              ; Longueur
 Xms_Handle  Dw ?              ; Handle
 Xms_Ptr     Dd ?              ; Pointeur
 Xms_Struc Ends

 Nbr_Mem_Handle Equ 19          ; [Mem / 1024] , (Kb)
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 Screen Xms_Struc 1 Dup (<302,00,00>)     ; Buffer Video
 World  Xms_Struc 1 Dup (<103,00,00>)     ; Ptr_Mesh Du Monde
 GOver  Xms_Struc 1 Dup (<005,00,00>)     ; Sprite du Game Over
 Crest1 Xms_Struc 1 Dup (<013,00,00>)     ; Ptr_Mesh d'un Crest
 Tlport Xms_Struc 1 Dup (<025,00,00>)     ; Ptr_Mesh du Teleport
 Energy Xms_Struc 1 Dup (<001,00,00>)     ; Ptr_Mesh de L'Energie
 EnemA1 Xms_Struc 1 Dup (<009,00,00>)     ; Ptr_Mesh de L'Enemie

 EnemB1 Xms_Struc 1 Dup (<007,00,00>)     ; Ptr_Mesh de L'Enemie2
 EnemC1 Xms_Struc 1 Dup (<006,00,00>)     ; Ptr_Mesh de L'Enemie3
 HeroHn Xms_Struc 1 Dup (<063,00,00>)     ; Ptr_Mesh du Hero
 HeroSp Xms_Struc 1 Dup (<786,00,00>)     ; Ptr_Mesh du Hero (Animation)
 IcoEne Xms_Struc 1 Dup (<288,00,00>)     ; Icone de l'Energy
 TitleK Xms_Struc 1 Dup (<014,00,00>)     ; Titre du Jeu
 TheEnd Xms_Struc 1 Dup (<010,00,00>)     ; Logo de The End
 PStart Xms_Struc 1 Dup (<002,00,00>)     ; Press Start 
 EnLogo Xms_Struc 1 Dup (<008,00,00>)     ; Logo Ennemies
 Treasu Xms_Struc 1 Dup (<004,00,00>)     ; Treasure Logo
 Radar  Xms_Struc 1 Dup (<060,00,00>)     ; Radar (Gps dans le Jeu)
 MusicX Xms_Struc 1 Dup (<900,00,00>)     ; Handle pour La Musique
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

 Vesa_Ptr Dd 'JSR '            ; Pointeur direct vers la memoire video

 Dest_Pal           Db    0,   0,   0
                    Db    0,   0,   0
                    Db    0,   0,   0
                    Db    0,   0,   0
                    Db    0,   0,   1
                    Db    0,   0,   1
                    Db    0,   0,   1
                    Db    0,   0,   1
                    Db    0,   1,   2
                    Db    0,   1,   2
                    Db    0,   1,   2
                    Db    0,   1,   2
                    Db    0,   1,   3
                    Db    0,   1,   3
                    Db    0,   1,   3
                    Db    0,   1,   3
                    Db    1,   2,   4
                    Db    1,   2,   4
                    Db    1,   2,   4
                    Db    1,   2,   4
                    Db    1,   2,   5
                    Db    1,   2,   5
                    Db    1,   2,   5
                    Db    1,   2,   5
                    Db    1,   3,   6
                    Db    1,   3,   6
                    Db    1,   3,   6
                    Db    1,   3,   6
                    Db    1,   3,   7
                    Db    1,   3,   7
                    Db    1,   3,   7
                    Db    1,   3,   7
                    Db    2,   4,   8
                    Db    2,   4,   8
                    Db    2,   4,   8
                    Db    2,   4,   8
                    Db    2,   4,   9
                    Db    2,   4,   9
                    Db    2,   4,   9
                    Db    2,   4,   9
                    Db    2,   5,  10
                    Db    2,   5,  10
                    Db    2,   5,  10
                    Db    2,   5,  10
                    Db    2,   5,  11
                    Db    2,   5,  11
                    Db    2,   5,  11
                    Db    2,   5,  11
                    Db    3,   6,  12
                    Db    3,   6,  12
                    Db    3,   6,  12
                    Db    3,   6,  12
                    Db    3,   6,  13
                    Db    3,   6,  13
                    Db    3,   6,  13
                    Db    3,   6,  13
                    Db    3,   7,  14
                    Db    3,   7,  14
                    Db    3,   7,  14
                    Db    3,   7,  14
                    Db    3,   7,  15
                    Db    3,   7,  15
                    Db    3,   7,  15
                    Db    3,   7,  15
                    Db    4,   8,  16
                    Db    4,   8,  16
                    Db    4,   8,  16
                    Db    4,   8,  16
                    Db    4,   8,  17
                    Db    4,   8,  17
                    Db    4,   8,  17
                    Db    4,   8,  17
                    Db    4,   9,  18
                    Db    4,   9,  18
                    Db    4,   9,  18
                    Db    4,   9,  18
                    Db    4,   9,  19
                    Db    4,   9,  19
                    Db    4,   9,  19
                    Db    4,   9,  19
                    Db    5,  10,  20
                    Db    5,  10,  20
                    Db    5,  10,  20
                    Db    5,  10,  20
                    Db    5,  10,  21
                    Db    5,  10,  21
                    Db    5,  10,  21
                    Db    5,  10,  21
                    Db    5,  11,  22
                    Db    5,  11,  22
                    Db    5,  11,  22
                    Db    5,  11,  22
                    Db    5,  11,  23
                    Db    5,  11,  23
                    Db    5,  11,  23
                    Db    5,  11,  23
                    Db    6,  12,  24
                    Db    6,  12,  24
                    Db    6,  12,  24
                    Db    6,  12,  24
                    Db    6,  12,  25
                    Db    6,  12,  25
                    Db    6,  12,  25
                    Db    6,  12,  25
                    Db    6,  13,  26
                    Db    6,  13,  26
                    Db    6,  13,  26
                    Db    6,  13,  26
                    Db    6,  13,  27
                    Db    6,  13,  27
                    Db    6,  13,  27
                    Db    6,  13,  27
                    Db    7,  14,  28
                    Db    7,  14,  28
                    Db    7,  14,  28
                    Db    7,  14,  28
                    Db    7,  14,  29
                    Db    7,  14,  29
                    Db    7,  14,  29
                    Db    7,  14,  29
                    Db    7,  15,  30
                    Db    7,  15,  30
                    Db    7,  15,  30
                    Db    7,  15,  30
                    Db    7,  15,  31
                    Db    7,  15,  31
                    Db    7,  15,  31
                    Db    7,  15,  31
                    Db    8,  16,  32
                    Db    8,  16,  32
                    Db    8,  16,  32
                    Db    8,  16,  32
                    Db    8,  16,  33
                    Db    8,  16,  33
                    Db    8,  16,  33
                    Db    8,  16,  33
                    Db    8,  17,  34
                    Db    8,  17,  34
                    Db    8,  17,  34
                    Db    8,  17,  34
                    Db    8,  17,  35
                    Db    8,  17,  35
                    Db    8,  17,  35
                    Db    8,  17,  35
                    Db    9,  18,  36
                    Db    9,  18,  36
                    Db    9,  18,  36
                    Db    9,  18,  36
                    Db    9,  18,  37
                    Db    9,  18,  37
                    Db    9,  18,  37
                    Db    9,  18,  37
                    Db    9,  19,  38
                    Db    9,  19,  38
                    Db    9,  19,  38
                    Db    9,  19,  38
                    Db    9,  19,  39
                    Db    9,  19,  39
                    Db    9,  19,  39
                    Db    9,  19,  39
                    Db   10,  20,  40
                    Db   10,  20,  40
                    Db   10,  20,  40
                    Db   10,  20,  40
                    Db   10,  20,  41
                    Db   10,  20,  41
                    Db   10,  20,  41
                    Db   10,  20,  41
                    Db   10,  21,  42
                    Db   10,  21,  42
                    Db   10,  21,  42
                    Db   10,  21,  42
                    Db   10,  21,  43
                    Db   10,  21,  43
                    Db   10,  21,  43
                    Db   10,  21,  43
                    Db   11,  22,  44
                    Db   11,  22,  44
                    Db   11,  22,  44
                    Db   11,  22,  44
                    Db   11,  22,  45
                    Db   11,  22,  45
                    Db   11,  22,  45
                    Db   11,  22,  45
                    Db   11,  23,  46
                    Db   11,  23,  46
                    Db   11,  23,  46
                    Db   11,  23,  46
                    Db   11,  23,  47
                    Db   11,  23,  47
                    Db   11,  23,  47
                    Db   11,  23,  47
                    Db   12,  24,  48
                    Db   12,  24,  48
                    Db   13,  25,  48
                    Db   13,  25,  48
                    Db   14,  26,  49
                    Db   14,  26,  49
                    Db   15,  27,  49
                    Db   15,  27,  49
                    Db   16,  29,  50
                    Db   16,  29,  50
                    Db   17,  30,  50
                    Db   17,  30,  50
                    Db   18,  31,  51
                    Db   18,  31,  51
                    Db   19,  32,  51
                    Db   19,  32,  51
                    Db   21,  34,  52
                    Db   21,  34,  52
                    Db   22,  35,  52
                    Db   22,  35,  52
                    Db   23,  36,  53
                    Db   23,  36,  53
                    Db   24,  37,  53
                    Db   24,  37,  53
                    Db   25,  39,  54
                    Db   25,  39,  54
                    Db   26,  40,  54
                    Db   26,  40,  54
                    Db   27,  41,  55
                    Db   27,  41,  55
                    Db   28,  42,  55
                    Db   28,  42,  55
                    Db   30,  44,  56
                    Db   30,  44,  56
                    Db   31,  45,  56
                    Db   31,  45,  56
                    Db   32,  46,  57
                    Db   32,  46,  57
                    Db   33,  47,  57
                    Db   33,  47,  57
                    Db   34,  49,  58
                    Db   34,  49,  58
                    Db   35,  50,  58
                    Db   35,  50,  58
                    Db   36,  51,  59
                    Db   36,  51,  59
                    Db   37,  52,  59
                    Db   37,  52,  59
                    Db   39,  54,  60
                    Db   39,  54,  60
                    Db   40,  55,  60
                    Db   40,  55,  60
                    Db   41,  56,  61
                    Db   41,  56,  61
                    Db   42,  57,  61
                    Db   42,  57,  61
                    Db   43,  59,  62
                    Db   43,  59,  62
                    Db   44,  60,  62
                    Db   44,  60,  62
                    Db   45,  61,  63
                    Db   45,  61,  63
                    Db   46,  62,  63
                    Db   46,  62,  63

 Palette  Db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
          Db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
          Db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
          Db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
          Db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
          Db   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
          Db   0,  0,  0,  3,  0,  0,  5,  0,  0,  7,  0,  0,  9,  0,  0, 11
          Db   0,  0, 13,  0,  0, 15,  0,  0, 17,  0,  0, 19,  0,  0, 21,  0
          Db   0, 23,  0,  0, 25,  0,  0, 27,  0,  0, 29,  0,  0, 31,  0,  0
          Db  33,  0,  0, 35,  0,  0, 37,  0,  0, 39,  0,  0, 41,  0,  0, 43
          Db   0,  0, 45,  0,  0, 47,  0,  0, 49,  0,  0, 51,  0,  0, 53,  0
          Db   0, 55,  0,  0, 57,  0,  0, 59,  0,  0, 61,  0,  0, 63,  0,  0
          Db   0,  0,  0,  0,  3,  0,  0,  5,  0,  0,  7,  0,  0,  9,  0,  0
          Db  11,  0,  0, 13,  0,  0, 15,  0,  0, 17,  0,  0, 19,  0,  0, 21
          Db   0,  0, 23,  0,  0, 25,  0,  0, 27,  0,  0, 29,  0,  0, 31,  0
          Db   0, 33,  0,  0, 35,  0,  0, 37,  0,  0, 39,  0,  0, 41,  0,  0
          Db  43,  0,  0, 45,  0,  0, 47,  0,  0, 49,  0,  0, 51,  0,  0, 53
          Db   0,  0, 55,  0,  0, 57,  0,  0, 59,  0,  0, 61,  0,  0, 63,  0
          Db   0,  0,  0,  3,  3,  0,  5,  5,  0,  7,  7,  0,  9,  9,  0, 11
          Db  11,  0, 13, 13,  0, 15, 15,  0, 17, 17,  0, 19, 19,  0, 21, 21
          Db   0, 23, 23,  0, 25, 25,  0, 27, 27,  0, 29, 29,  0, 31, 31,  0
          Db  33, 33,  0, 35, 35,  0, 37, 37,  0, 39, 39,  0, 41, 41,  0, 43
          Db  43,  0, 45, 45,  0, 47, 47,  0, 49, 49,  0, 51, 51,  0, 53, 53
          Db   0, 55, 55,  0, 57, 57,  0, 59, 59,  0, 61, 61,  0, 63, 63,  0
          Db   0,  0,  0,  0,  0,  3,  0,  0,  5,  0,  0,  7,  0,  0,  9,  0
          Db   0, 11,  0,  0, 13,  0,  0, 15,  0,  0, 17,  0,  0, 19,  0,  0
          Db  21,  0,  0, 23,  0,  0, 25,  0,  0, 27,  0,  0, 29,  0,  0, 31
          Db   0,  0, 33,  0,  0, 35,  0,  0, 37,  0,  0, 39,  0,  0, 41,  0
          Db   0, 43,  0,  0, 45,  0,  0, 47,  0,  0, 49,  0,  0, 51,  0,  0
          Db  53,  0,  0, 55,  0,  0, 57,  0,  0, 59,  0,  0, 61,  0,  0, 63
          Db   0,  0,  0,  3,  0,  3,  5,  0,  5,  7,  0,  7,  9,  0,  9, 11
          Db   0, 11, 13,  0, 13, 15,  0, 15, 17,  0, 17, 19,  0, 19, 21,  0
          Db  21, 23,  0, 23, 25,  0, 25, 27,  0, 27, 29,  0, 29, 31,  0, 31
          Db  33,  0, 33, 35,  0, 35, 37,  0, 37, 39,  0, 39, 41,  0, 41, 43
          Db   0, 43, 45,  0, 45, 47,  0, 47, 49,  0, 49, 51,  0, 51, 53,  0
          Db  53, 55,  0, 55, 57,  0, 57, 59,  0, 59, 61,  0, 61, 63,  0, 63
          Db   0,  0,  0,  0,  3,  3,  0,  5,  5,  0,  7,  7,  0,  9,  9,  0
          Db  11, 11,  0, 13, 13,  0, 15, 15,  0, 17, 17,  0, 19, 19,  0, 21
          Db  21,  0, 23, 23,  0, 25, 25,  0, 27, 27,  0, 29, 29,  0, 31, 31
          Db   0, 33, 33,  0, 35, 35,  0, 37, 37,  0, 39, 39,  0, 41, 41,  0
          Db  43, 43,  0, 45, 45,  0, 47, 47,  0, 49, 49,  0, 51, 51,  0, 53
          Db  53,  0, 55, 55,  0, 57, 57,  0, 59, 59,  0, 61, 61,  0, 63, 63
          Db   0,  0,  0,  3,  3,  3,  5,  5,  5,  7,  7,  7,  9,  9,  9, 11
          Db  11, 11, 13, 13, 13, 15, 15, 15, 17, 17, 17, 19, 19, 19, 21, 21
          Db  21, 23, 23, 23, 25, 25, 25, 27, 27, 27, 29, 29, 29, 31, 31, 31
          Db  33, 33, 33, 35, 35, 35, 37, 37, 37, 39, 39, 39, 41, 41, 41, 43
          Db  43, 43, 45, 45, 45, 47, 47, 47, 49, 49, 49, 51, 51, 51, 53, 53
          Db  53, 55, 55, 55, 57, 57, 57, 59, 59, 59, 61, 61, 61, 63, 63, 63             

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                          Structure D'un Mesh 3d
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 Mesh_3d_Struc Struc
                      ; * Un pointeur Diviser en Cinq . . .
 M_V3d_Src       Dd ? ; [4] Pointeur Sur Les Vertices Originals.
                      ; X3d(4),Y3d(4),Z3d(4) : [12]
 M_Face_Src      Dd ? ; [4] Pointeur Sur Les Faces
                      ; V1(2),V2(2),V3(2),Color(4) : [10]                           
 M_V3d_Dest      Dd ? ; [4] Pointeur Sur Les Nouveaux Vertices.
                      ; X3d(4),Y3d(4),Z3d(4) : [12]
 M_V2d_Dest      Dd ? ; [4] Pointeur Sur Les Vertices en 2d.
                      ; X2d(2),Y2d(2),Z3d(4) : [08]
 M_Sort_Face     Dd ? ; [4] Pointeur Sur les faces triees.
                      ; Z_M(4),Face_Num(4) : [08]

 M_Nbr_Vertices  Dw ? ; [2] Nombre De Vertices
 M_Nbr_Faces     Dw ? ; [2] Nombre De Faces

 M_X_Pos         Dd ? ; [4] Position xXx     
 M_Y_Pos         Dd ? ; [4] Position yYy
 M_Z_Pos         Dd ? ; [4] Position zZz

 M_X_Inc_Pos     Dd ? ; [4] Incrementation de la position xXx
 M_Y_Inc_Pos     Dd ? ; [4] Incrementation de la position yYy
 M_Z_Inc_Pos     Dd ? ; [4] Incrementation de la position zZz
 
 M_X_Rot         Db ? ; [1] Position de la Rotation xXx
 M_Y_Rot         Db ? ; [1] Position de la Rotation yYy
 M_Z_Rot         Db ? ; [1] Position de la Rotation zZz
 
 M_X_Inc_Rot     Db ? ; [1] Incrementation de L'Angle xXx
 M_Y_Inc_Rot     Db ? ; [1] Incrementation de L'Angle yYy
 M_Z_Inc_Rot     Db ? ; [1] Incrementation de L'Angle zZz

 M_Ia            Db ? ; [1] Techniques de L'intelligence Artificielle.
 M_Technik       Db ? ; [1] Techniques de Formule Mathematique.
                      ;     |-> Rx Ry Rz Tx Ty Tz Ia Draw
                      ;   Bits:  7  6  5  4  3  2  1    0
 M_Ia_Move       Dw ? ; Compteur Pour le Mouvement
 M_Ia_Move_Const Dw ? ; Constante Pour le Mouvement
 M_Ia_Var_TxXx   Db ? ; Variable Pour L'intelligence -=(X)=-
 M_Ia_Var_TyYy   Db ? ; Variable Pour L'intelligence -=(Y)=-
 M_Ia_Var_TzZz   Db ? ; Variable Pout L'intelligence -=(Z)=-
 M_Ia_Var_RxXx   Db ? ; Variable Pour L'intelligence -=(X)=-
 M_Ia_Var_RyYy   Db ? ; Variable Pour L'intelligence -=(Y)=-
 M_Ia_Var_RzZz   Db ? ; Variable Pout L'intelligence -=(Z)=-
 M_Score         Dw ? ; Valeur pour le Score
                      ; -=[68]=-
 Mesh_3d_Struc Ends
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;                          Structure D'un Monde 3d
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
 World_3d_Struc Struc
                    ; * Un pointeur Diviser en Cinq . . .
 W_V3d_Src       Dd ? ; [4] Pointeur Sur Les Vertices Originals.
                      ; X3d(4),Y3d(4),Z3d(4) : [12]
 W_Face_Src      Dd ? ; [4] Pointeur Sur Les Faces
                      ; V1(2),V2(2),V3(2),Color(4) : [10]                           
 W_V3d_Dest      Dd ? ; [4] Pointeur Sur Les Nouveaux Vertices.
                      ; X3d(4),Y3d(4),Z3d(4) : [12]
 W_V2d_Dest      Dd ? ; [4] Pointeur Sur Les Vertices en 2d.
                      ; X2d(2),Y2d(2),Z3d(4) : [08]
 W_Sort_Face     Dd ? ; [4] Pointeur Sur les faces triees.
                      ; Z_M(4),Face_Num(4) : [08]

 W_Nbr_Vertices  Dw ? ; [2] Nombre De Vertices
 W_Nbr_Faces     Dw ? ; [2] Nombre De Faces

 W_X_Pos         Dd ? ; [4] Position xXx     
 W_Y_Pos         Dd ? ; [4] Position yYy
 W_Z_Pos         Dd ? ; [4] Position zZz

 W_X_Inc_Pos     Dd ? ; [4] Incrementation de la position xXx
 W_Y_Inc_Pos     Dd ? ; [4] Incrementation de la position yYy
 W_Z_Inc_Pos     Dd ? ; [4] Incrementation de la position zZz

 W_X_Rot         Db ? ; [1] Position de la Rotation xXx
 W_Y_Rot         Db ? ; [1] Position de la Rotation yYy
 W_Z_Rot         Db ? ; [1] Position de la Rotation zZz
 W_Temp          Db ? ; Aider au Code

 W_X_Cam         Dd ? ; [4] Position xXx de la Camera     
 W_Y_Cam         Dd ? ; [4] Position yYy de la Camera
 W_Z_Cam         Dd ? ; [4] Position zZz de la Camera

 W_X_Inc_Cam     Dd ? ; [4] Incrementation de la position xXx de la Camera
 W_Y_Inc_Cam     Dd ? ; [4] Incrementation de la position yYy de la Camera
 W_Z_Inc_Cam     Dd ? ; [4] Incrementation de la position zZz de la Camera

 World_3d_Struc Ends
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
Even
 Bac_Mesh Mesh_3d_Struc 1 Dup (<>)     ; Utiliser pour Connecter le monde avec
                                       ; les Objets.
 Bac_01   Mesh_3d_Struc 1 Dup (<>)     
 Bac_02   Mesh_3d_Struc 1 Dup (<>)     
 Bac_03   Mesh_3d_Struc 1 Dup (<>)     
 Bac_04   Mesh_3d_Struc 1 Dup (<>)     

 World_Mesh World_3d_Struc 1 Dup (<>)  ; Env du Monde
   W3d_Vert Equ 2478d
   W3d_Face Equ 1324d
 Crest_1 Mesh_3d_Struc 1 Dup (<>)      ; Mesh d'un Tresor
   VCrest Equ 0192d
   FCrest Equ 0384d
 TPort_1 Mesh_3d_Struc 1 Dup(<>)       ; Mesh du Teleport
   VTeleport Equ 0384d
   FTeleport Equ 0768d
 Energ_1 Mesh_3d_Struc 1 Dup(<>)       ; Mesh de l'energie
   VEnergy Equ 0018d
   FEnergy Equ 0024d
 EnemyA1 Mesh_3d_Struc 1 Dup(<>)       ; Mesh de L'enemie
   VEnemyA Equ 0145d
   FEnemyA Equ 0240d
 EnemyB1 Mesh_3d_Struc 1 Dup(<>)       ; Mesh de L'enemie
   VEnemyB Equ 0097d
   FEnemyB Equ 0190d
 EnemyC1 Mesh_3d_Struc 1 Dup(<>)       ; Mesh de L'enemie
   VEnemyC Equ 0097d
   FEnemyC Equ 0158d
 HeroStr Mesh_3d_Struc 1 Dup(<>)       ; Mesh du Hero
   VHero Equ 1031d
   FHero Equ 1732d
 Crest_2 Mesh_3d_Struc 1 Dup (<>)      
 Crest_3 Mesh_3d_Struc 1 Dup (<>)      
 Crest_4 Mesh_3d_Struc 1 Dup (<>)      
 Crest_5 Mesh_3d_Struc 1 Dup (<>)      
 Energ_2 Mesh_3d_Struc 1 Dup(<>)       
 EnemyA2 Mesh_3d_Struc 1 Dup(<>)       
 EnemyA3 Mesh_3d_Struc 1 Dup(<>)       
 EnemyA4 Mesh_3d_Struc 1 Dup(<>)       
 EnemyB2 Mesh_3d_Struc 1 Dup(<>)       
 EnemyB3 Mesh_3d_Struc 1 Dup(<>)       
 EnemyB4 Mesh_3d_Struc 1 Dup(<>)       
 EnemyC2 Mesh_3d_Struc 1 Dup(<>)       
 EnemyC3 Mesh_3d_Struc 1 Dup(<>)       
 EnemyC4 Mesh_3d_Struc 1 Dup(<>)       

Sinus_3D        Dw     0,   6,  13,  19,  25,  31,  38,  44  ; Cosinus
                Dw    50,  56,  62,  68,  74,  80,  86,  92  ; Sinus+64   
                Dw    98, 104, 109, 115, 121, 126, 132, 137
                Dw   142, 147, 152, 157, 162, 167, 172, 177
                Dw   181, 185, 190, 194, 198, 202, 206, 209
                Dw   213, 216, 220, 223, 226, 229, 231, 234
                Dw   237, 239, 241, 243, 245, 247, 248, 250
                Dw   251, 252, 253, 254, 255, 255, 256, 256
                Dw   256, 256, 256, 255, 255, 254, 253, 252
                Dw   251, 250, 248, 247, 245, 243, 241, 239
                Dw   237, 234, 231, 229, 226, 223, 220, 216
                Dw   213, 209, 206, 202, 198, 194, 190, 185
                Dw   181, 177, 172, 167, 162, 157, 152, 147
                Dw   142, 137, 132, 126, 121, 115, 109, 104
                Dw    98,  92,  86,  80,  74,  68,  62,  56
                Dw    50,  44,  38,  31,  25,  19,  13,   6
                Dw     0,  -6, -13, -19, -25, -31, -38, -44
                Dw   -50, -56, -62, -68, -74, -80, -86, -92
                Dw   -98,-104,-109,-115,-121,-126,-132,-137
                Dw  -142,-147,-152,-157,-162,-167,-172,-177
                Dw  -181,-185,-190,-194,-198,-202,-206,-209
                Dw  -213,-216,-220,-223,-226,-229,-231,-234
                Dw  -237,-239,-241,-243,-245,-247,-248,-250
                Dw  -251,-252,-253,-254,-255,-255,-256,-256
                Dw  -256,-256,-256,-255,-255,-254,-253,-252
                Dw  -251,-250,-248,-247,-245,-243,-241,-239
                Dw  -237,-234,-231,-229,-226,-223,-220,-216
                Dw  -213,-209,-206,-202,-198,-194,-190,-185
                Dw  -181,-177,-172,-167,-162,-157,-152,-147
                Dw  -142,-137,-132,-126,-121,-115,-109,-104
                Dw   -98, -92, -86, -80, -74, -68, -62, -56
                Dw   -50, -44, -38, -31, -25, -19, -13,  -6

                Dw     0,   6,  13,  19,  25,  31,  38,  44  ; Cosinus
                Dw    50,  56,  62,  68,  74,  80,  86,  92  ; Sinus+64   
                Dw    98, 104, 109, 115, 121, 126, 132, 137  
                Dw   142, 147, 152, 157, 162, 167, 172, 177
                Dw   181, 185, 190, 194, 198, 202, 206, 209
                Dw   213, 216, 220, 223, 226, 229, 231, 234
                Dw   237, 239, 241, 243, 245, 247, 248, 250
                Dw   251, 252, 253, 254, 255, 255, 256, 256

 Rot_Sinus_X    Dd 00000000h ; Bac_X_Sin          
 Rot_Cosin_X    Dd 00000000h ; Bac_X_Cos       
 Rot_Sinus_Y    Dd 00000000h ; Bac_Y_Sin
 Rot_Cosin_Y    Dd 00000000h ; Bac_Y_Cos
 Rot_Sinus_Z    Dd 00000000h ; Bac_Z_Sin
 Rot_Cosin_Z    Dd 00000000h ; Bac_Z_Cos

;----= I T E M =----
 Energie_Vide Equ 0147456d
 EFrame_Size Equ 096*096

 Life Db 00111b ; 3 Icones D'Energie ;111
 L1R  Db 00000d ; Icone 1, Frame x
 L1S  Db 00000d ; Sinus 
 L2R  Db 00006d ; Icone 2, Frame x
 L2S  Db 00140d ; Sinus 
 L3R  Db 00028d ; Icone 3, Frame x
 L3S  Db 00203d ; Sinus 
 Dead_Frame  Dd 00h 

;------= Poly =------
 Bac_X2Y2  Dd 0000h    ; Pour les Triangles
 Bac_X3Y3  Dd 0000h

;------= Player =------
 Frame    Dd 0000h
 Pos      Dd 0000h
 Key_Hit  Db 00h

;----= All_Objets =----
 Const_Nbr_Objects Equ 020d
 Nbr_Objects  Db Const_Nbr_Objects             ; Hi_Byte <> 0 , Enemy Dead
 Table_3d_Objects  Dw 0A000h,Offset HeroStr    ;
                   Dw 0C000h,Offset Crest_1    ; 0000 000 0
                   Dw 0C200h,Offset Crest_2    ;    |   | | 
                   Dw 0C400h,Offset Crest_3    ;    |   | -> Enemy_Dead
                   Dw 0C600h,Offset Crest_4    ;    |   |--> Detector
                   Dw 0E000h,Offset Energ_2    ;    |------> Couleur au Gps+1
                   Dw 0E200h,Offset Energ_1    ;
                   Dw 08000h,Offset EnemyA1    ; [0.2.4.6]
                   Dw 08200h,Offset EnemyA2              
                   Dw 08400h,Offset EnemyA3             
                   Dw 08600h,Offset EnemyA4    
                   Dw 06000h,Offset EnemyB1
                   Dw 06200h,Offset EnemyB2
                   Dw 06400h,Offset EnemyB3
                   Dw 06600h,Offset EnemyB4
                   Dw 04000h,Offset EnemyC1 
                   Dw 04200h,Offset EnemyC2
                   Dw 04400h,Offset EnemyC3
                   Dw 04600h,Offset EnemyC4
                   Dw 02100h,Offset TPort_1  
                   
 BWSF_32 Dd 00h
 Bac_W_Sort_Face Db (0148d*08d) Dup (0)

 Go_Inc Db 00h
 Camera_Select Db 00h          ; *032d 
 Camera_Type Dd 016384d/04d
             Db 00h,080h,00h,00h
             Dd 00h,00h,00h,06400d,02d*06400d,02d
             Dd 016384d/08d
             Db 00h,080h,00h,00h
             Dd 00h,00h,00h,01600d,02d*01600d,02d
             Dd 016384d/06d
             Db 010h,080h,00h,00h
             Dd 00h,00h,0,01600d,02d*01600d,02d
             Dd 016384d/06d
             Db 020h,080h,00h,00h
             Dd 0100h,-0200h,00h,01600d,02d*01600d,02d
             Dd 016384d/012d
             Db 020h,080h,00h,00h
             Dd 0100h,-0400h,00h,01600d,02d*01600d,02d
             Dd 016384d/012d
             Db 030h,080h,00h,00h
             Dd 0100h,-0400h,00h,01600d,02d*01600d,02d
             Dd 016384d/014d
             Db 00h,080h,00h,00h
             Dd 00h,00h,00h,01600d,02d*01600d,02d
             Dd 016384d/032d
             Db 040h,080h,00h,00h
             Dd 0100h,-0200h,-0500h,01600d,02d*01600d,02d

 Direction Db 00h              ; Attack Rotation
 End_Mission Db 00h
 Bac_Direct Db 00h
 D_Gps_Pos  Dd 00h             ; Position dans le Gps

CNo_Key   Dw +0000d,+0000d,+0000d,+0000d,+0000d,+0000d
CKey_72   Dw -0128d,-0127d,-0129d,-0256d,-0255d,-0257d
CKey_80   Dw +0128d,+0127d,+0129d,+0256d,+0257d,+0255d
CKey_75   Dw -0001d,-0002d,-0129d,-0130d,+0127d,+0126d
CKey_77   Dw +0001d,+0002d,+0129d,+0130d,-0127d,-0126d
CKey_7275 Dw -0001d,-0128d,-0129d,-0130d,-0257d,-0258d
CKey_7580 Dw -0001d,+0128d,+0127d,+0126d,+0255d,+0254d
CKey_7277 Dw +0001d,-0128d,-0127d,-0126d,-0255d,-0254d
CKey_7780 Dw +0001d,+0128d,+0129d,+0130d,+0257d,+0258d

CKey_Proc Dw Offset CNo_Key,Offset CKey_72,Offset CKey_75,Offset CKey_7275
          Dw Offset CKey_77,Offset CKey_7277,Offset CNo_Key,Offset CKey_72
          Dw Offset CKey_80,Offset CNo_Key,Offset CKey_7580,Offset CKey_75
          Dw Offset CKey_7780,Offset CKey_77,Offset CKey_80,CNo_Key

Sinus_32      Dw 0,1,2,2
              Dw 3,4,5,5
              Dw 6,7,8,9
              Dw 9,10,11,12
              Dw 12,13,14,14
              Dw 15,16,17,17
              Dw 18,18,19,20
              Dw 20,21,22,22
              Dw 23,23,24,24
              Dw 25,25,26,26
              Dw 27,27,28,28
              Dw 28,29,29,29
              Dw 30,30,30,30
              Dw 31,31,31,31
              Dw 31,32,32,32
              Dw 32,32,32,32
              Dw 32,32,32,32
              Dw 32,32,32,31
              Dw 31,31,31,31
              Dw 31,30,30,30
              Dw 29,29,29,28
              Dw 28,28,27,27
              Dw 26,26,26,25
              Dw 25,24,24,23
              Dw 22,22,21,21
              Dw 20,19,19,18
              Dw 18,17,16,15
              Dw 15,14,13,13
              Dw 12,11,10,10
              Dw 9,8,7,7
              Dw 6,5,4,4
              Dw 3,2,1,0
              Dw 0,-1,-2,-3
              Dw -4,-4,-5,-6
              Dw -7,-7,-8,-9
              Dw -10,-10,-11,-12
              Dw -13,-13,-14,-15
              Dw -15,-16,-17,-18
              Dw -18,-19,-19,-20
              Dw -21,-21,-22,-22
              Dw -23,-24,-24,-25
              Dw -25,-26,-26,-26
              Dw -27,-27,-28,-28
              Dw -28,-29,-29,-29
              Dw -30,-30,-30,-31
              Dw -31,-31,-31,-31
              Dw -31,-32,-32,-32
              Dw -32,-32,-32,-32
              Dw -32,-32,-32,-32
              Dw -32,-32,-32,-31
              Dw -31,-31,-31,-31
              Dw -30,-30,-30,-30
              Dw -29,-29,-29,-28
              Dw -28,-28,-27,-27
              Dw -26,-26,-25,-25
              Dw -24,-24,-23,-23
              Dw -22,-22,-21,-20
              Dw -20,-19,-18,-18
              Dw -17,-17,-16,-15
              Dw -14,-14,-13,-12
              Dw -12,-11,-10,-9
              Dw -9,-8,-7,-6
              Dw -5,-5,-4,-3
              Dw -2,-2,-1,0

Logo_JsrS  Db 00h

 Speed Db 00h
 Bpm   Db 00h
 Octave Db 00h
 Instruments Db 00h
 TP Db 00h              ; Track or Pattern Select
 Pattern Db 00h

 Track_Pos Db 00h       ; (0..17)  (0..8) Left , (9..17) Right
 Track_In_Pos Db 00h    ; 0 , 1 , 2  (Note,Instrument,Volume)
 Track_Vert Db 00h
 Pos_Vert Db 00h

 N_Val Dw 0343d,0363d,0385d,0408d,0432d,0458d,0485d,0514d,0544d,0577d
;           C     C#    D     D#    E     F     F#    G     G#    A
       Dw 0611d,0647d
;           B    A#h

; Notes: 0..11, Octave:0..7, Instruments : 00..FF, Volume : 00..FF
; 3 Octets  18 Channels * Size(3) * 64
 M_Pat Db (18*3*64) Dup (0FFh);
       Db (018d*03d*01d) Dup (0FFh)   ; Pour le BackSpace
       Db (018d*03d*01d) Dup (0FFh)   ; Pour le BackSpace

 Pattern_Table Db 256 Dup (0);
 Pattern_Counter Db 256 Dup (0);
 Play_Pattern_Pos Dw 00h
 Pattern_Line Equ (03d*018d)
 Music_Counter Dd 00h
 Nbr_Pattern Db 00h

;                                                   Bits
;---------------------------------------------------------------------------
;Facteur de Multiplication                          0..3
;Reduction des aigus Activee                        4
;Type de l'enveloppe (0:Decroissante,1:Contine)     5
;Vibrator                                           6
;Tremolo                                            7
;---------------------------------------------------------------------------
;Facteur d'Attenuation                              0..5
;Attenuation des aigus par Octave                   6..7
;---------------------------------------------------------------------------
;Decay de l'Enveloppe                               0..3
;Attack de l'Enveloppe                              4..8
;---------------------------------------------------------------------------
;Release de l'Enveloppe                             0..3
;Sustain de l'Enveloppe                             4..8
;---------------------------------------------------------------------------
;WaveForm                                           0..1
;---------------------------------------------------------------------------
;Liaison des Cellules d'oScillateur (0:MC,1:Add)    0
;FeedBack                                           1..3
;---------------------------------------------------------------------------
;Song Name (24), Modulator, Carrier
 Instruments_Table  Db (0256d *(024d+06d+06d)) Dup (00d)
; ---------------------------------------------------------------------------
; Canal  : 00 01 02 03 04 05 06 07 08
; Osc Mod: 00 01 02 06 07 08 12 13 14
; Osc Car: 03 04 05 09 10 11 15 16 17
; -----------------------------= Oscillateur =-------------------------------
; #CO: 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 
; Ofs: 00 01 02 03 04 05 08 09 0A 0B 0C 0D 10 11 12 13 14 15
; ---------------------------------------------------------------------------
 Channel Db 00h,01h,02h,08h,09h,0Ah,10h,11h,12h   ; Modulator
         Db 03h,04h,05h,0Bh,0Ch,0Dh,13h,14h,15h   ; Carrier = Mod + 03d
         Db 00h,01h,02h,03h,04h,05h,06h,07h,08h   ; Pour Activation du Channel
         Db 00h,01h,02h,03h,04h,05h,06h,07h,08h   ; Pour Activation du Channel

 Song_N_Length Db 00h                    
 I_Name_Temp Db "Game~001.Fmt",00h,"JSR" ; Pendant La Game
             Db "Game~002.Fmt",00h,"JSR" ; Au Debut

 WMusic Dw 00h

 NH8 Dd 00h  ; Adresse Du Nop_Play
 MH8 Dd 00h  ; Adresse Du Play_Music
 Music_Pos Dd 00h;

 File_Id Db 'JSR_FMT~'
 Check_Id Db '        '
;*****************************************************************************
;* Signature d'un Fichier FMT                                                *
;*****************************************************************************
; 8 Octets     Id 'JSR_FMT~'
; 1 Octet      Speed
; 1 Octet      Bpm
; 9216 Octets  Table d'Instruments
; 256 Octets   Pattern_Table 
; 1 Octet      Nombre de Pattern
;=- xXx - 09683d
; 1 Octet      Numero Du Pattern
; 3456 Octets  Contenu Du Pattern
;*****************************************************************************

Data Ends
 
Code Segment Dword Public Use16 'CODE'
Assume Cs:Code,Ds:Data,Fs:Data,Gs:Data

Even
Install_Vesa Proc Near
;****************************************************************************
;*                         I n s t a l l _ V e s a                          *
;****************************************************************************
;* Verification et Installation du mode Vesa 640x480x08                     *
;****************************************************************************
 Mov Bp,0004Fh
 Mov Ax,04F00h                 ; Premiere Verification
 Push Ds
 Pop Es
 Mov Di,Offset VesaInfo_Table_F0
 Int 10h
 Mov Dx,Offset Vesa_Erreur

 Sub Ax,Bp
 Je @Vesa1                     ; Branchement Si Supporter

@Vesa_Erreur:
 Mov Ah,09h                    ; Affichage d'un erreur
 Int 021h

 Pop Ax                        ; Depile l'adresse de retour
 Mov Ax,4C00h
 Int 021h    
@Vesa1:

 Mov Ax,4F01h                  ; Deuxieme Verification
 Mov Cx,M640x480x08Bpp
 Mov Di,Offset VesaInfo_Table_F1
 Int 010h

 Sub Ax,Bp                     ; Si le mode n'est pas supporter
 Jne @Vesa_Erreur

 Mov Ax,4F02h                  ; Installation 
 Mov Bx,M640x480x08Bpp
 Int 10h

 Sub Ax,Bp
 Jne @Vesa_Erreur

Ret
EndP

Install_New_Handler Proc Near
;****************************************************************************
;*                  I n s t a l l _ N e w _ H a n d l e r                   *
;****************************************************************************
;*  Detourne plusieurs interruptions comme le Keyboard...                   *
;****************************************************************************
 Cli
 Mov Ax,Seg Key_Table          ; Data Segment
 Mov Gs,Ax
 
 Xor Ax,Ax                     ; Sauvegarde l'ancien Gestionnaire
 Mov Es,Ax                     ; du keyboard
 Mov Bx,09*04
 Mov Eax,Es:[Bx]
 Mov Cs:[Old_Int_9],Eax

 Mov Cx,Cs                     ; Active le nouveau Gestionnaire
 Shl Ecx,16
 Mov Cx,Offset Handler_9
 Mov Es:[Bx],Ecx

 Sub Bx,04                     ; Sauvegarde l'ancien Gestionnaire
 Mov Eax,Es:[Bx]               ; du Timer
 Mov Cs:[Old_Int_8],Eax

 Mov Cx,Offset Nop_Handler_8   ; Active le nouveau Gestionnaire
 Mov Es:[Bx],Ecx

 Mov Gs:[NH8],Ecx
 Mov Cx,Offset Handler_Music
 Mov Gs:[MH8],Ecx

 Mov Dx,043h                  ; Remplace le 18,1 interruption a
 Mov Cx,07786d                ; 0256 interruptions a la seconde
 Mov Al,036h
 Out Dx,Al

 Sub Dx,03
 Mov Al,Cl
 Out Dx,Al
 Mov Al,Ch
 Out Dx,Al

 Mov Bx,01Ch*04
 Mov Eax,Es:[Bx]
 Mov Cs:[Old_Int_1C],Eax
 
 Mov Cx,Cs                     ; Active le nouveau Gestionnaire
 Shl Ecx,16
 Mov Cx,Offset Int_Iret
 Mov Es:[Bx],Ecx
 Sti
Ret
EndP

Even
Int_Iret Proc Near
;****************************************************************************
;*                             I n t _ I r e t                              *
;****************************************************************************
Iret
Endp

Even
Old_Int_8  Dd 0     ; Le timer
Old_Int_1C Dd 0     ; Le temporisateur

Remove_New_Handler Proc Near
;****************************************************************************
;*                    R e m o v e _ N e w _ H a n d l e r                   *
;****************************************************************************
;*  Remet les anciennes interruptions pour le timing,le keyboard...         *
;****************************************************************************
 Cli
 Xor Ax,Ax                    ; Active l'ancien gestionnaire du clavier
 Mov Es,Ax
 Mov Bx,09*04
 Mov Eax,Cs:[Old_Int_9]
 Mov Es:[Bx],Eax

 Sub Bx,04                     ; Active l'ancien gestionnaire du timer
 Mov Eax,Cs:[Old_Int_8]
 Mov Es:[Bx],Eax

 Mov Dx,043h                   ; Le remet a 18,1 impulsions a la seconde
 Mov Al,036h
 Out Dx,Al
 Sub Dx,03
 Xor Al,Al
 Out Dx,Al
 Out Dx,Al

 Mov Bx,01Ch*04
 Mov Eax,Cs:[Old_Int_1C]
 Mov Es:[Bx],Eax
 Sti
Ret
EndP

Even
Handler_9 Proc Near
;****************************************************************************
;*                             H a n d l e r _ 9                            *
;****************************************************************************
;* Nouvelle interruption pour le keyboard.                                  *
;* La procedure fonctionne a la methode binaire, un 1 signifie que la touche*
;* est relache, un 0 appuyer.                                               *
;****************************************************************************
 Push Ax
 Push Bx

 In Al,60h

 Xor Bh,Bh
 Mov Bl,Al
 And Bl,01111111b

 Shr Al,07

 Add Bx,Offset Key_Table
 Mov Gs:[Bx],Al

 Mov Al,20h
 Out 20h,Al

 Pop Bx
 Pop Ax
Iret
EndP

Even
Old_Int_9  Dd 0     ; Le keyboard

Nop_Handler_8 Proc Near
 Push Ax
 Mov Al,020h
 Out 020h,Al
 Pop Ax
Iret
EndP
EndP

Even
Handler_Music Proc Near
 Push Eax
 Push Ebx

 Mov Eax,Gs:[Music_Counter]
 Dec Eax
 Mov Gs:[Music_Counter],Eax
 Jnz @No_Play_Line_Music 

 Xor Ebx,Ebx
 Mov Bx,Word Ptr Gs:[Speed]
 Mov Gs:[Music_Counter],Ebx
 Pushfd
 Pushad
 Call Play_Music
 Popad
 Popfd
 Inc Dword Ptr Gs:[Music_Pos]

@No_Play_Line_Music:
 Mov Al,20h
 Out 20h,Al

 Pop Ebx
 Pop Eax

Iret
EndP

Even
Output_Fm Proc Near
 Push Dx
 Push Cx
 Mov Dx,0388h
 Out Dx,Al
 Mov Cx,08d+(032d*256)
Even
@Loop_Wait1:
 In Al,Dx
 Dec Cl
 Jnz @Loop_Wait1
 Inc Dx
 Mov Al,Ah
 Out Dx,Al
@Loop_Wait2:
 In Al,Dx
 Dec Ch
 Jnz @Loop_Wait2
 Pop Cx
 Pop Dx
Ret
EndP

Even
Output_Fm2 Proc Near
 Push Dx
 Push Cx
 Mov Dx,038Ah
 Out Dx,Al
 Mov Cx,08d+(032d*256)
 Jmp @Loop_Wait1
EndP

Reset Proc Near
 Mov Cx,0256d
Even
@Loop_Reset:
 Xor Ah,Ah
 Mov Al,Cl
 Call Output_Fm
;--
 Xor Ah,Ah
 Mov Al,Cl
 Call Output_Fm2
 Dec Cx
 Jnz @Loop_Reset
Ret
EndP

Stop_Music Proc Near
 Mov Bx,00B0h
 Mov Bp,00A0h
 Mov Cl,09d
Even
@Loop_Disabled_Sound:
 Mov Ax,Bp
 Call Output_Fm
 Mov Ax,Bx
 Call Output_Fm
 Mov Ax,Bp
 Call Output_Fm2
 Mov Ax,Bx
 Call Output_Fm2
 Inc Bx
 Inc Bp
 Dec Cl
 Jnz @Loop_Disabled_Sound
Ret
EndP

Even
Play_Music Proc Near
 Mov Bx,Offset Pattern_Table
 Mov Di,Offset Channel

 Mov Al,Gs:[Bx]
 Inc Al
 Jnz @No_Stop
 Mov Dword Ptr Gs:[Music_Pos],00h
 Ret
@No_Stop:

 Mov Eax,Gs:[Music_Pos]
 Mov Ebp,Gs:[MusicX.Xms_Ptr]
 Mov Ecx,Eax
 Shr Ecx,06d
 And Eax,063d
 Imul Eax,Pattern_Line
 Add Bx,Cx
 Xor Ecx,Ecx
 Mov Cl,Gs:[Bx]
 Inc Cl
 Jnz @No_Loop_Music
 Mov Dword Ptr Gs:[Music_Pos],00h
 Jmp @Loop_Music
@No_Loop_Music:
 Dec Cl
 Imul Ecx,((018d*03d)*064d)    ; Longeur d'un Pattern
 Add Ecx,Eax
 Add Ebp,Ecx

@Loop_Music:

 Push Ebp
 Mov Dl,09d
Even
@Music_Loop_Nine:
 Push Dx
 Push Di

 Mov Al,Fs:[Ebp]
 Inc Al
 Jz @Music_No_Play

;- Effectue un Cut
 Mov Ax,0A0h           ; Stop Channel
 Neg Dl
 Add Dl,09h
 Add Al,Dl
 Call Output_Fm

 Mov Ax,0B0h           ; Empeche la Montee
 Add Al,Dl
 Call Output_Fm

 Mov Cl,02d
 Mov Si,Offset Instruments_Table
 Mov Al,Fs:[Ebp+1]      ; Instruments
 Xor Ah,Ah
 Imul Ax,036d
 Add Si,Ax
Even
@Music_Loop_Mod_Car:
 Push Cx

 Mov Al,020h           ; Facteur de Mult
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]
 Call Output_Fm
 Inc Si

 Mov Al,040h           ; Volume
 Add Al,Gs:[Di]
 Mov Ah,Fs:[Ebp+2]      
 Xor Ah,0FFh
 Call Output_Fm
 Inc Si

 Mov Al,060h           ; Attack/Decay
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]     
 Call Output_Fm
 Inc Si

 Mov Al,080h           ; Sustain/Release
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]     
 Call Output_Fm
 Inc Si

 Mov Al,0E0h
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]
 Call OutPut_Fm
 Inc Si

 Mov Al,0C0h
 Add Al,Gs:[Di+018d]
 Mov Ah,Gs:[Si]
 Or Ah,00010000b     
 Call OutPut_Fm
 Inc Si
 Add Di,09d            ; Passe Au Carrier
 Pop Cx
 Dec Cl
 Jnz @Music_Loop_Mod_Car

 Sub Di,018d

 Mov Si,Offset N_Val
 Mov Al,Fs:[Ebp]        ; Notes, Octave
 Mov Ah,Al
 And Al,0Fh
 Shr Ah,04d
 Xor Ch,Ch
 Mov Cl,Al
 Add Cx,Cx
 Add Si,Cx
 Mov Dx,Gs:[Si]
 Shl Ah,02d
 Or Dh,Ah
 Or Dh,032d            ; Active le Son

 Mov Al,0A0h
 Add Al,Gs:[Di+018d]
 Mov Ah,Dl
 Call Output_Fm

 Mov Al,0B0h
 Add Al,Gs:[Di+018d]
 Mov Ah,Dh
 Call Output_Fm
@Music_No_Play:

 Pop Di
 Pop Dx
 Add Ebp,03d
 Inc Di
 Dec Dl
 Jnz @Music_Loop_Nine
;=-

 Pop Ebp
 Mov Di,Offset Channel
 Add Ebp,09d*03d

 Mov Dl,09d
Even
@Music_Loop_Nine2:
 Push Dx
 Push Di

 Mov Al,Fs:[Ebp]
 Inc Al
 Jz @Music_No_Play2

;- Effectue un Cut
 Mov Ax,0A0h           ; Stop Channel
 Neg Dl
 Add Dl,09h
 Add Al,Dl
 Call Output_Fm2

 Mov Ax,0B0h           ; Empeche la Montee
 Add Al,Dl
 Call Output_Fm2

 Mov Cl,02d
 Mov Si,Offset Instruments_Table
 Mov Al,Fs:[Ebp+1]      ; Instruments
 Xor Ah,Ah
 Imul Ax,036d
 Add Si,Ax
Even
@Music_Loop_Mod_Car2:
 Push Cx

 Mov Al,020h           ; Facteur de Mult
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]
 Call Output_Fm2
 Inc Si

 Mov Al,040h           ; Volume
 Add Al,Gs:[Di]
 Mov Ah,Fs:[Ebp+2]      
 Xor Ah,0FFh
 Call Output_Fm2
 Inc Si

 Mov Al,060h           ; Attack/Decay
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]     
 Call Output_Fm2
 Inc Si

 Mov Al,080h           ; Sustain/Release
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]     
 Call Output_Fm2
 Inc Si

 Mov Al,0E0h
 Add Al,Gs:[Di]
 Mov Ah,Gs:[Si]
 Call OutPut_Fm2
 Inc Si

 Mov Al,0C0h
 Add Al,Gs:[Di+018d]
 Mov Ah,Gs:[Si]
 Or Ah,00100000b     
 Call OutPut_Fm2
 Inc Si
 Add Di,09d            ; Passe Au Carrier
 Pop Cx
 Dec Cl
 Jnz @Music_Loop_Mod_Car2
 Sub Di,018d

 Mov Si,Offset N_Val
 Mov Al,Fs:[Ebp]        ; Notes, Octave
 Mov Ah,Al
 And Al,0Fh
 Shr Ah,04d
 Xor Ch,Ch
 Mov Cl,Al
 Add Cx,Cx
 Add Si,Cx
 Mov Dx,Gs:[Si]
 Shl Ah,02d
 Or Dh,Ah
 Or Dh,032d            ; Active le Son

 Mov Al,0A0h
 Add Al,Gs:[Di+018d]
 Mov Ah,Dl
 Call Output_Fm2

 Mov Al,0B0h
 Add Al,Gs:[Di+018d]
 Mov Ah,Dh
 Call Output_Fm2

@Music_No_Play2:
 Pop Di
 Pop Dx
 Add Ebp,03d
 Inc Di
 Dec Dl
 Jnz @Music_Loop_Nine2
;=-

Ret
EndP

Even
Copy_Pattern_2_Music Proc Near
 Push Ds
 Push Es
 Push Gs
 Xor Esi,Esi
 Pop Ds
 Mov Es,Si
 Mov Si,Offset M_Pat

 Xor Ch,Ch
 Mov Cl,Gs:[Pattern]
 Mov Bx,Offset Pattern_Table
 Mov Edi,Gs:[MusicX.Xms_Ptr]
 Add Bx,Cx
 Xor Ecx,Ecx
 Mov Cl,Gs:[Bx]
 Imul Ecx,((018d*03d)*064d)    ; Longueur d'un Pattern
 Add Edi,Ecx

 Mov Ecx,(018d*03d*064d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Pop Es
 Pop Ds

Ret
EndP

Even
Check_Flat_Mode Proc Near
;****************************************************************************
;*                     C h e c k _ F l a t _ M o d e                        *
;****************************************************************************
;* Verifie si le bit du protected mode est activ‚.                          *
;****************************************************************************
 Mov Eax,Cr0
 Mov Dx,Offset No_Flat_Mode
 Test Ax,01
 Jne @Vesa_Erreur
Ret
EndP

Even
Install_Flat_Mode Proc Near
;****************************************************************************
;*                    I n s t a l l _ F l a t _ M o d e                     *
;****************************************************************************
;* Installation du Flat mode en activant le protected et le real mode.      *
;****************************************************************************
 Xor Eax,Eax
 Xor Ebx,Ebx
 Mov Cl,04
 Mov Ax,Seg GDT_Table
 Shl Eax,Cl
 Mov Bx,Offset GDT_Table
 Add Eax,Ebx
 Mov Dword Ptr GDT_Offset[2],Eax
 Lgdt pword ptr GDT_Offset
 
 Cli
 Mov Eax,Cr0
 Or Eax,01d
 Mov Cr0,Eax

 Jmp @On_Pm                   ; Vide la queue d'instruction (Pipe Execution)
@On_Pm:
 Mov Bx,08h
 Mov Ds,Bx
 Mov Es,Bx
 Mov Fs,Bx
 Mov Gs,Bx                    ; Adapte aux segments a 4Gb

 And Al,0FEh                  ; Retour en Rm sans Reset du processeur
 Mov Cr0,Eax
 Jmp @On_Rm                   ; Vide la queue d'instruction
@On_Rm:
 Xor Ax,Ax
 Mov Fs,Ax
 Mov Es,Ax
 Mov Ds,Ax
 Sti

Ret
EndP

Even
Check_Xms Proc Near
;****************************************************************************
;*                            C h e c k _ X m s                             *
;****************************************************************************
;* Verification d'un gestionnaire d'XMS.                                    *
;****************************************************************************
 Mov Ax,04300h                 ; Check s'il y a un gestionnaire d'XMS
 Int 02Fh
 Mov Dx,Offset No_Xms_Drv
 Sub Al,080h
 Jne @Vesa_Erreur

 Mov Ax,04310h                 ; Obtient le pointeur du Gestionnaire
 Int 02Fh
 Mov Word Ptr Xms_Drivers_Ptr,Bx
 Mov Word Ptr Xms_Drivers_Ptr + 02, Es

 Xor Ax,Ax                     ; Obtenir le numero de version
 Call Dword ptr [Xms_Drivers_Ptr]

 Mov Dx,Offset Xms_Drv_Lw      ; 2.0 et plus
 Sub Ax,0200h
 Js @Vesa_Erreur

Ret
EndP

Even
Get_Free_Xms Proc Near
;****************************************************************************
;*                        G e t _ F r e e _ X m s                           *
;****************************************************************************
;* Obtenir le nombre de Ko de libre.                                        *
;****************************************************************************
 Mov Ax,0800h
 Call Dword Ptr [Xms_Drivers_Ptr]

 Mov Dx,Ax
 Mov Dx,Offset Miss_Mem
 Sub Ax,300                    ; (640*480) / 1024
 Jns @Vesa_Erreur

Ret
EndP

Even
Get_Mem_Xms Proc Near
;****************************************************************************
;*                          G e t _ M e m _ X m s                           *
;****************************************************************************
;* Obtenir de le memoire.                                                   *
;****************************************************************************
 Mov Cx,Nbr_Mem_Handle
 Mov Bp,Offset Screen  ; Premier Structure pour Get_Mem

@Loop_Get_Mem:
 Push Cx
 Push Bp

 Mov Ax,0900h                  ; Obtenir xKo de memoire
 Mov Dx,Gs:[Bp.Xms_Length]
 Call Dword Ptr Gs:[Xms_Drivers_Ptr]
 Mov Gs:[Bp.Xms_Handle],Dx

 Mov Ax,0C00h                  ; Proteger contre deplacement et obtenir le Ptr
 Call Dword Ptr Gs:[Xms_Drivers_Ptr]

 Mov Word Ptr Gs:[Bp.Xms_Ptr],Bx
 Mov Word Ptr Gs:[Bp.Xms_Ptr+02],Dx

 Pop Bp
 Pop Cx
 Add Bp,08d
 Dec Cx
 Jnz @Loop_Get_Mem
Ret
EndP

Even
Free_Mem_Xms Proc Near
;****************************************************************************
;*                        F r e e _ M e m _ X m s                           *
;****************************************************************************
;* Obtenir de le memoire.                                                   *
;****************************************************************************
 Mov Cx,Nbr_Mem_Handle
 Mov Bp,Offset Screen  ; Premier Structure pour Get_Mem

@Loop_Free_Mem:
 Push Cx
 Push Bp

 Mov Ax,0D00h                                  ; Desactive la protection
 Mov Dx,Gs:[Bp.Xms_Handle]
 Call Dword Ptr Gs:[Xms_Drivers_Ptr]

 Mov Ax,0A00h                                  ; Desalloue la memoire
 Mov Dx,Gs:[Bp.Xms_Handle]
 Call Dword Ptr Gs:[Xms_Drivers_Ptr]

 Pop Bp
 Pop Cx
 Add Bp,08d
 Dec Cx
 Jnz @Loop_Free_Mem

Ret
EndP

Even
Show Proc Near
;****************************************************************************
;*                               S h o w                                    *
;****************************************************************************
 Mov Edi,Gs:[Vesa_Ptr]
 Mov Esi,Gs:[Screen.Xms_Ptr]
 Mov Ecx,(640*480) / 04
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
Ret
EndP

Even
Clear Proc Near
;****************************************************************************
;*                              C l e a r                                   *
;****************************************************************************
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Eax,Eax
 Mov Ecx,(640*480)/04
 Rep Stos Dword Ptr Es:[Edi] 
Ret
EndP

Even
Copy_Pal Proc Near
;****************************************************************************
;*                           C o p y _ P a l                                *
;****************************************************************************
 Push Ds
 Push Es
 Push Gs
 Pop Ds
 Push Gs
 Pop Es
 Mov Si,Offset Palette
 Mov Di,Offset Dest_Pal
 Mov Ecx,(0768/04)
 Rep Movsd
 Pop Es
 Pop Ds
Ret
EndP

Even
Set_Pal Proc Near
;****************************************************************************
;*                             S e t _ P a l                                *
;****************************************************************************
 Mov Bp,Ds
 Push Gs
 Pop Ds
 Mov Dx,03C8h
 Mov Si,Offset Dest_Pal
 Mov Cx,0768d
 Xor Al,Al
 Out Dx,Al
 Inc Dx
 Rep Outsb
 Mov Ds,Bp
Ret
EndP

Get_Mem Proc Near
;****************************************************************************
;*                             G e t _ M e m                                *
;****************************************************************************
;* Obtenir de la memoire conventionnelle.                                   *
;****************************************************************************
 Mov Ax,4800h
 Mov Bx,(065536d/016d)
 Int 21h
 Mov Dx,Offset Miss_Mem
 Jc @Vesa_Erreur
 Mov Gs:[Mem_Handle],Ax
Ret
EndP

Free_Mem Proc Near
;****************************************************************************
;*                            F r e e _ M e m                               *
;****************************************************************************
;* Libere de la memoire conventionnelle.                                    *
;****************************************************************************
 Mov Ax,Word Ptr Gs:[Mem_Handle]
 Mov Es,Ax
 Mov Ah,049h
 Int 21h
Ret
Endp

@Uni_Erreur:
 Pop Ax
 Push Gs
 Pop Ds
 Mov Ax,03
 Int 10h
 Mov Ah,09h
 Int 021h
 Mov Ax,04C00h
 Int 021h

Objects_Table  Dw Offset World,042980d
               Dd (042980d-04d)/04d
               Dw Offset Crest1,06148d
               Dd (06148-04d)/04d
               Dw Offset Tlport,012292d
               Dd (012292d-04d)/04d
               Dw Offset Energy,0460d
               Dd (0460-04d)/04d
               Dw Offset EnemA1,04144d
               Dd (04144-04d)/04d
               Dw Offset EnemB1,03068d
               Dd (03068-04d)/04d
               Dw Offset EnemC1,02748d
               Dd (02748-04d)/04d

Load_File Proc Near
;****************************************************************************
;*                            L o a d _ F i l e                             *
;****************************************************************************
;* Chargement de L'environnement                                            *
;****************************************************************************
 Mov Ax,03D00h                 ; Ouvre le fichier
 Push Gs
 Pop Ds
 Mov Dx,Offset Filename
 Int 021h
 Mov Bp,Ax                     ; Handle
 Jc @Erreur

 Mov Ax,03F00h                 ; Id_File
 Mov Bx,Bp
 Mov Dx,Gs:[Mem_Handle]
 Mov Ds,Dx
 Xor Dx,Dx
 Mov Cx,020d
 Int 021h
 Jc @Erreur
 Bswap Ebp

 Mov Bp,Offset Objects_Table
 Mov Di,07d
@Loop_Load_Objects:
 Push Di
 Push Bp
 Mov Ax,03F00h
 Xor Dx,Dx                                    
 Mov Cx,Cs:[Bp+02]
 Int 021h
 Jc @Erreur
 Mov Si,Cs:[Bp]
 Mov Edi,Gs:[Si.Xms_Ptr]
 Mov Esi,04
 Mov Ecx,Cs:[Bp+04]
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Pop Bp
 Pop Di
 Add Bp,08d
 Dec Di
 Jnz @Loop_Load_Objects

 Mov Ax,03F00h
 Xor Dx,Dx                     ; Hero
 Mov Cx,029696d
 Int 021h
 Jc @Erreur
 Mov Esi,04
 Mov Edi,Gs:[HeroHn.Xms_Ptr]
 Mov Ecx,(029696-04d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Edi,Gs:[HeroSp.Xms_Ptr]   ; Sprite Normale
 Mov Esi,04
 Mov Ecx,(012372d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Bp,064d
@Load_Hero_Animation:
 Mov Ax,03F00h
 Xor Dx,Dx                     ; Hero (Animation)
 Mov Cx,012372d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Ecx,(012372d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Dec Bp
 Jnz @Load_Hero_Animation

 Mov Edi,Gs:[IcoEne.Xms_Ptr]   
 Mov Bp,32
@Load_Energy_Animation:
 Mov Ax,03F00h
 Xor Dx,Dx                     ; Icone_Energy (Animation)
 Mov Cx,09216d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Ecx,(09216d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Dec Bp
 Jnz @Load_Energy_Animation

 Mov Ax,03F00h
 Xor Dx,Dx                     ; Titre Du Jeu
 Mov Cx,013348d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Edi,Gs:[TitleK.Xms_Ptr]
 Mov Ecx,(013348)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Ax,03F00h
 Xor Dx,Dx                     ; Radar
 Mov Cx,024336d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Edi,Gs:[Radar.Xms_Ptr]
 Mov Ecx,(024336)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Ax,03F00h
 Xor Dx,Dx                     ; Game Over
 Mov Cx,04704d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Edi,Gs:[GOver.Xms_Ptr]
 Mov Ecx,(04704)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Ax,03F00h
 Xor Dx,Dx                     ; The End Logo
 Mov Cx,09900d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Edi,Gs:[TheEnd.Xms_Ptr]
 Mov Ecx,(09900d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Ax,03F00h
 Xor Dx,Dx                     ; The End Logo
 Mov Cx,02048d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Edi,Gs:[PStart.Xms_Ptr]
 Mov Ecx,(02048d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Ax,03F00h
 Xor Dx,Dx                     ; The Ennemies Logo
 Mov Cx,07252d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Edi,Gs:[EnLogo.Xms_Ptr]
 Mov Ecx,(07252)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Ax,03F00h
 Xor Dx,Dx                     ; The Ennemies Logo
 Mov Cx,03811d
 Int 021h
 Jc @Erreur
 Xor Esi,Esi
 Mov Edi,Gs:[Treasu.Xms_Ptr]
 Mov Ecx,(03811d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Bswap Ebp
 Mov Ah,03Eh                   ; Ferme le fichier
 Mov Bx,Bp
 Int 021h

 Push Fs
 Pop Ds
Ret
EndP

Setting_All_Meshs Proc Near
;****************************************************************************
;*                   S e t t i n g _ A l l _ M e s h s                      *
;****************************************************************************
; -=World=-
 Mov Esi,W3d_Vert*012d
 Mov Edi,Gs:[World.Xms_Ptr]
 Mov Gs:[World_Mesh.W_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[World_Mesh.W_Face_Src],Edi
 Add Edi,W3d_Face*010d
 Mov Gs:[World_Mesh.W_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[World_Mesh.W_V2d_Dest],Edi
 Add Edi,W3d_Vert*08d
 Mov Gs:[World_Mesh.W_Sort_Face],Edi

 Xor Eax,Eax
 Mov Word Ptr Gs:[World_Mesh.W_Nbr_Vertices],W3d_Vert
 Mov Word Ptr Gs:[World_Mesh.W_Nbr_Faces],W3d_Face

 Mov Dword Ptr Gs:[World_Mesh.W_X_Pos],Eax
 Mov Dword Ptr Gs:[World_Mesh.W_Y_Pos],Eax
 Mov Dword Ptr Gs:[World_Mesh.W_Z_Pos],016384d  

 Mov Dword Ptr Gs:[World_Mesh.W_X_Inc_Pos],Eax 
 Mov Dword Ptr Gs:[World_Mesh.W_Y_Inc_Pos],Eax
 Mov Dword Ptr Gs:[World_Mesh.W_Z_Inc_Pos],Eax

 Mov Dword Ptr Gs:[World_Mesh.W_X_Cam],Eax        ; Camera
 Mov Dword Ptr Gs:[World_Mesh.W_Y_Cam],Eax
 Mov Dword Ptr Gs:[World_Mesh.W_Z_Cam],Eax  

 Mov Dword Ptr Gs:[World_Mesh.W_X_Inc_Cam],Eax    ; Camera
 Mov Dword Ptr Gs:[World_Mesh.W_Y_Inc_Cam],Eax
 Mov Dword Ptr Gs:[World_Mesh.W_Z_Inc_Cam],Eax

 Mov Byte Ptr Gs:[World_Mesh.W_X_Rot],Al
 Mov Byte Ptr Gs:[World_Mesh.W_Y_Rot],080h
 Mov Byte Ptr Gs:[World_Mesh.W_Z_Rot],Ah

; -=Crest=-
 Mov Esi,VCrest*012d
 Mov Edi,Gs:[Crest1.Xms_Ptr]
 Mov Gs:[Crest_1.M_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[Crest_1.M_Face_Src],Edi
 Add Edi,FCrest*010d
 Mov Gs:[Crest_1.M_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[Crest_1.M_V2d_Dest],Edi
 Add Edi,VCrest*08d
 Mov Gs:[Crest_1.M_Sort_Face],Edi

 Mov Word Ptr Gs:[Crest_1.M_Nbr_Vertices],VCrest
 Mov Word Ptr Gs:[Crest_1.M_Nbr_Faces],FCrest
 Mov Dword Ptr Gs:[Crest_1.M_X_Pos],-11100d 
 Mov Dword Ptr Gs:[Crest_1.M_Y_Pos],9100d
 Mov Dword Ptr Gs:[Crest_1.M_Z_Pos],0400d
 Mov Dword Ptr Gs:[Crest_1.M_X_Inc_Pos],0d   
 Mov Dword Ptr Gs:[Crest_1.M_Y_Inc_Pos],0d
 Mov Dword Ptr Gs:[Crest_1.M_Z_Inc_Pos],0d
 Mov Byte Ptr Gs:[Crest_1.M_X_Rot],00d
 Mov Byte Ptr Gs:[Crest_1.M_Y_Rot],080h
 Mov Byte Ptr Gs:[Crest_1.M_Z_Rot],00d
 Mov Byte Ptr Gs:[Crest_1.M_X_Inc_Rot],02d
 Mov Byte Ptr Gs:[Crest_1.M_Y_Inc_Rot],02d
 Mov Byte Ptr Gs:[Crest_1.M_Z_Inc_Rot],02d
 Mov Byte Ptr Gs:[Crest_1.M_Ia],01h

 Push Gs
 Pop Ds
 Push Gs
 Pop Es
 Mov Bx,068d/04d
 Mov Bp,Offset Crest_1
 Mov Di,Offset Crest_2
 Mov Si,Bp
 Mov Dl,03
@Loop_Clone_Crest:
 Mov Cx,Bx
 Rep Movsd
 Mov Si,Bp
 Dec Dl
 Jnz @Loop_Clone_Crest

 Xor Ax,Ax
 Mov Es,Ax
 Mov Ds,Ax
 Mov Dword Ptr Gs:[Crest_2.M_X_Pos],-8000d
 Mov Dword Ptr Gs:[Crest_2.M_Y_Pos],-8000d
 Mov Dword Ptr Gs:[Crest_3.M_X_Pos],11000d 
 Mov Dword Ptr Gs:[Crest_3.M_Y_Pos],-4800d       
 Mov Dword Ptr Gs:[Crest_4.M_X_Pos],8400d
 Mov Dword Ptr Gs:[Crest_4.M_Y_Pos],10400d       

;-=Teleport=-
 Mov Esi,VTeleport*012d
 Mov Edi,Gs:[TlPort.Xms_Ptr]
 Mov Gs:[TPort_1.M_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[TPort_1.M_Face_Src],Edi
 Add Edi,FTeleport*010d
 Mov Gs:[TPort_1.M_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[TPort_1.M_V2d_Dest],Edi
 Add Edi,VTeleport*08d
 Mov Gs:[TPort_1.M_Sort_Face],Edi

 Mov Word Ptr Gs:[TPort_1.M_Nbr_Vertices],VTeleport
 Mov Word Ptr Gs:[TPort_1.M_Nbr_Faces],FTeleport
 Mov Dword Ptr Gs:[TPort_1.M_X_Pos],0d 
 Mov Dword Ptr Gs:[TPort_1.M_Y_Pos],-3200d
 Mov Dword Ptr Gs:[TPort_1.M_Z_Pos],0400d
 Mov Dword Ptr Gs:[TPort_1.M_X_Inc_Pos],0d
 Mov Dword Ptr Gs:[TPort_1.M_Y_Inc_Pos],0d
 Mov Dword Ptr Gs:[TPort_1.M_Z_Inc_Pos],0d
 Mov Byte Ptr Gs:[TPort_1.M_X_Rot],00d
 Mov Byte Ptr Gs:[TPort_1.M_Y_Rot],080h
 Mov Byte Ptr Gs:[TPort_1.M_Z_Rot],00d
 Mov Byte Ptr Gs:[TPort_1.M_Ia],02h

;-=Energy=-
 Mov Esi,VEnergy*012d
 Mov Edi,Gs:[Energy.Xms_Ptr]
 Mov Gs:[Energ_1.M_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[Energ_1.M_Face_Src],Edi
 Add Edi,FEnergy*010d
 Mov Gs:[Energ_1.M_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[Energ_1.M_V2d_Dest],Edi
 Add Edi,VEnergy*08d
 Mov Gs:[Energ_1.M_Sort_Face],Edi

 Mov Word Ptr Gs:[Energ_1.M_Nbr_Vertices],VEnergy
 Mov Word Ptr Gs:[Energ_1.M_Nbr_Faces],FEnergy

 Mov Dword Ptr Gs:[Energ_1.M_X_Pos],4000d       
 Mov Dword Ptr Gs:[Energ_1.M_Y_Pos],1800d
 Mov Dword Ptr Gs:[Energ_1.M_Z_Pos],400d  
 Mov Dword Ptr Gs:[Energ_1.M_X_Inc_Pos],0d   
 Mov Dword Ptr Gs:[Energ_1.M_Y_Inc_Pos],0d
 Mov Dword Ptr Gs:[Energ_1.M_Z_Inc_Pos],0d
 Mov Byte Ptr Gs:[Energ_1.M_X_Rot],00d
 Mov Byte Ptr Gs:[Energ_1.M_Y_Rot],080h
 Mov Byte Ptr Gs:[Energ_1.M_Z_Rot],00d
 Mov Byte Ptr Gs:[Energ_1.M_Ia],02h
 Push Gs
 Pop Ds
 Push Gs
 Pop Es
 Mov Si,Offset Energ_1
 Mov Di,Offset Energ_2
 Mov Cx,068d/04d
 Rep Movsd
 Xor Ax,Ax
 Mov Es,Ax
 Mov Ds,Ax
 Mov Dword Ptr Gs:[Energ_2.M_X_Pos],-1600d       
 Mov Dword Ptr Gs:[Energ_2.M_Y_Pos],-11000d

;-=Enemy~1=-   
 Mov Esi,VEnemyA*012d
 Mov Edi,Gs:[EnemA1.Xms_Ptr]
 Mov Gs:[EnemyA1.M_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[EnemyA1.M_Face_Src],Edi
 Add Edi,FEnemyA*010d
 Mov Gs:[EnemyA1.M_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[EnemyA1.M_V2d_Dest],Edi
 Add Edi,VEnemyA*08d
 Mov Gs:[EnemyA1.M_Sort_Face],Edi

 Mov Word Ptr Gs:[EnemyA1.M_Nbr_Vertices],VEnemyA
 Mov Word Ptr Gs:[EnemyA1.M_Nbr_Faces],FEnemyA
 Mov Dword Ptr Gs:[EnemyA1.M_X_Pos],0d  
 Mov Dword Ptr Gs:[EnemyA1.M_Y_Pos],011600d
 Mov Dword Ptr Gs:[EnemyA1.M_Z_Pos],0400d 
 Mov Dword Ptr Gs:[EnemyA1.M_X_Inc_Pos],0d
 Mov Dword Ptr Gs:[EnemyA1.M_Y_Inc_Pos],0d
 Mov Dword Ptr Gs:[EnemyA1.M_Z_Inc_Pos],0400d
 Mov Byte Ptr Gs:[EnemyA1.M_X_Rot],00d
 Mov Byte Ptr Gs:[EnemyA1.M_Y_Rot],00h
 Mov Byte Ptr Gs:[EnemyA1.M_Z_Rot],00d
 Mov Byte Ptr Gs:[EnemyA1.M_Ia],03h
 Mov Word Ptr Gs:[EnemyA1.M_Ia_Move],0100h

 Push Gs
 Pop Ds
 Push Gs
 Pop Es
 Mov Bx,068d/04d
 Mov Bp,Offset EnemyA1
 Mov Di,Offset EnemyA2
 Mov Si,Bp
 Mov Dl,03
@Loop_Clone_Ea:
 Mov Cx,Bx
 Rep Movsd
 Mov Si,Bp
 Dec Dl
 Jnz @Loop_Clone_Ea
 Xor Ax,Ax
 Mov Es,Ax
 Mov Ds,Ax
 Mov Dword Ptr Gs:[EnemyA2.M_X_Pos],08000d 
 Mov Dword Ptr Gs:[EnemyA2.M_Y_Pos],-09600d
 Mov Dword Ptr Gs:[EnemyA3.M_X_Pos],011200d
 Mov Dword Ptr Gs:[EnemyA3.M_Y_Pos],05200d       
 Mov Dword Ptr Gs:[EnemyA4.M_X_Pos],-08000d
 Mov Dword Ptr Gs:[EnemyA4.M_Y_Pos],01200d       

 Mov Byte Ptr Gs:[EnemyA1.M_Ia_Var_TzZz],080h
 Mov Byte Ptr Gs:[EnemyA2.M_Ia_Var_TzZz],040h
 Mov Byte Ptr Gs:[EnemyA3.M_Ia_Var_TzZz],0A0h
 Mov Byte Ptr Gs:[EnemyA4.M_Ia_Var_TzZz],000h

;-=Enemy~2=-   
 Mov Esi,VEnemyB*012d
 Mov Edi,Gs:[EnemB1.Xms_Ptr]
 Mov Gs:[EnemyB1.M_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[EnemyB1.M_Face_Src],Edi
 Add Edi,FEnemyB*010d
 Mov Gs:[EnemyB1.M_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[EnemyB1.M_V2d_Dest],Edi
 Add Edi,VEnemyB*08d
 Mov Gs:[EnemyB1.M_Sort_Face],Edi

 Mov Word Ptr Gs:[EnemyB1.M_Nbr_Vertices],VEnemyB
 Mov Word Ptr Gs:[EnemyB1.M_Nbr_Faces],FEnemyB

 Mov Dword Ptr Gs:[EnemyB1.M_X_Pos],4000d    
 Mov Dword Ptr Gs:[EnemyB1.M_Y_Pos],-4800d
 Mov Dword Ptr Gs:[EnemyB1.M_Z_Pos],0400d 
 Mov Dword Ptr Gs:[EnemyB1.M_X_Inc_Pos],32d    
 Mov Dword Ptr Gs:[EnemyB1.M_Y_Inc_Pos],32d
 Mov Dword Ptr Gs:[EnemyB1.M_Z_Inc_Pos],0d
 Mov Byte Ptr Gs:[EnemyB1.M_X_Rot],00d
 Mov Byte Ptr Gs:[EnemyB1.M_Y_Rot],00h
 Mov Byte Ptr Gs:[EnemyB1.M_Z_Rot],00d
 Mov Byte Ptr Gs:[EnemyB1.M_Ia],04h

 Push Gs
 Pop Ds
 Push Gs
 Pop Es
 Mov Bx,068d/04d
 Mov Bp,Offset EnemyB1
 Mov Di,Offset EnemyB2
 Mov Si,Bp
 Mov Dl,03
@Loop_Clone_Eb:
 Mov Cx,Bx
 Rep Movsd
 Mov Si,Bp
 Dec Dl
 Jnz @Loop_Clone_Eb
 Xor Ax,Ax
 Mov Es,Ax
 Mov Ds,Ax
 Mov Dword Ptr Gs:[EnemyB2.M_X_Pos],-07200d 
 Mov Dword Ptr Gs:[EnemyB2.M_Y_Pos],-0800d
 Mov Dword Ptr Gs:[EnemyB3.M_X_Pos],-06400d 
 Mov Dword Ptr Gs:[EnemyB3.M_Y_Pos],06400d       
 Mov Dword Ptr Gs:[EnemyB4.M_X_Pos],05600d
 Mov Dword Ptr Gs:[EnemyB4.M_Y_Pos],08000d       

;-=Enemy~3=-   
 Mov Esi,VEnemyC*012d
 Mov Edi,Gs:[EnemC1.Xms_Ptr]
 Mov Gs:[EnemyC1.M_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[EnemyC1.M_Face_Src],Edi
 Add Edi,FEnemyC*010d
 Mov Gs:[EnemyC1.M_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[EnemyC1.M_V2d_Dest],Edi
 Add Edi,VEnemyC*08d
 Mov Gs:[EnemyC1.M_Sort_Face],Edi

 Mov Word Ptr Gs:[EnemyC1.M_Nbr_Vertices],VEnemyC
 Mov Word Ptr Gs:[EnemyC1.M_Nbr_Faces],FEnemyC
 Mov Dword Ptr Gs:[EnemyC1.M_X_Pos],-01600d        
 Mov Dword Ptr Gs:[EnemyC1.M_Y_Pos],03400d
 Mov Dword Ptr Gs:[EnemyC1.M_Z_Pos],0400d  
 Mov Dword Ptr Gs:[EnemyC1.M_X_Inc_Pos],016d    
 Mov Dword Ptr Gs:[EnemyC1.M_Y_Inc_Pos],016d
 Mov Dword Ptr Gs:[EnemyC1.M_Z_Inc_Pos],0d
 Mov Byte Ptr Gs:[EnemyC1.M_X_Rot],00d
 Mov Byte Ptr Gs:[EnemyC1.M_Y_Rot],00h
 Mov Byte Ptr Gs:[EnemyC1.M_Z_Rot],00d
 Mov Byte Ptr Gs:[EnemyC1.M_Ia],05h
 Mov Byte Ptr Gs:[EnemyC1.M_Ia_Var_TzZz],00h
 Mov Byte Ptr Gs:[EnemyC1.M_Ia_Var_RxXx],00h
 Mov Byte Ptr Gs:[EnemyC1.M_Ia_Var_RyYy],00h

 Push Gs
 Pop Ds
 Push Gs
 Pop Es
 Mov Bx,068d/04d
 Mov Bp,Offset EnemyC1
 Mov Di,Offset EnemyC2
 Mov Si,Bp
 Mov Dl,03
@Loop_Clone_Ec:
 Mov Cx,Bx
 Rep Movsd
 Mov Si,Bp
 Dec Dl
 Jnz @Loop_Clone_Ec
 Xor Ax,Ax
 Mov Es,Ax
 Mov Ds,Ax
 Mov Dword Ptr Gs:[EnemyC2.M_X_Pos],08000d 
 Mov Dword Ptr Gs:[EnemyC2.M_Y_Pos],-01600d
 Mov Dword Ptr Gs:[EnemyC3.M_X_Pos],-010600d
 Mov Dword Ptr Gs:[EnemyC3.M_Y_Pos],06000d       
 Mov Dword Ptr Gs:[EnemyC4.M_X_Pos],-08800d     
 Mov Dword Ptr Gs:[EnemyC4.M_Y_Pos],-10400d       
 Mov Word Ptr Gs:[EnemyC1.M_Ia_Move],Offset Crest_1
 Mov Word Ptr Gs:[EnemyC2.M_Ia_Move],Offset Crest_2
 Mov Word Ptr Gs:[EnemyC3.M_Ia_Move],Offset Crest_3
 Mov Word Ptr Gs:[EnemyC4.M_Ia_Move],Offset Crest_4
 Mov Word Ptr Gs:[EnemyC1.M_Ia_Move_Const],Offset EnemyB1
 Mov Word Ptr Gs:[EnemyC2.M_Ia_Move_Const],Offset EnemyB2
 Mov Word Ptr Gs:[EnemyC3.M_Ia_Move_Const],Offset EnemyB3
 Mov Word Ptr Gs:[EnemyC4.M_Ia_Move_Const],Offset EnemyB4
 Mov Word Ptr Gs:[EnemyC1.M_Ia_Var_TxXx],Offset EnemyA1
 Mov Word Ptr Gs:[EnemyC2.M_Ia_Var_TxXx],Offset EnemyA2
 Mov Word Ptr Gs:[EnemyC3.M_Ia_Var_TxXx],Offset EnemyA3
 Mov Word Ptr Gs:[EnemyC4.M_Ia_Var_TxXx],Offset EnemyA4

;-= Hero =-   
 Mov Esi,VHero*012d
 Mov Edi,Gs:[HeroHn.Xms_Ptr]
 Mov Gs:[HeroStr.M_V3d_Src],Edi
 Add Edi,Esi
 Mov Gs:[HeroStr.M_Face_Src],Edi
 Add Edi,FHero*010d
 Mov Gs:[HeroStr.M_V3d_Dest],Edi
 Add Edi,Esi
 Mov Gs:[HeroStr.M_V2d_Dest],Edi
 Add Edi,VHero*08d
 Mov Gs:[HeroStr.M_Sort_Face],Edi

 Mov Word Ptr Gs:[HeroStr.M_Nbr_Vertices],VHero
 Mov Word Ptr Gs:[HeroStr.M_Nbr_Faces],FHero

 Mov Dword Ptr Gs:[HeroStr.M_X_Pos],0d       
 Mov Dword Ptr Gs:[HeroStr.M_Y_Pos],-3200d   
 Mov Dword Ptr Gs:[HeroStr.M_Z_Pos],0400d   

 Mov Dword Ptr Gs:[HeroStr.M_X_Inc_Pos],0d 
 Mov Dword Ptr Gs:[HeroStr.M_Y_Inc_Pos],0d
 Mov Dword Ptr Gs:[HeroStr.M_Z_Inc_Pos],0d

 Mov Byte Ptr Gs:[HeroStr.M_X_Rot],00d
 Mov Byte Ptr Gs:[HeroStr.M_Y_Rot],00d
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],00d

;-= Control de Collision =-
 Mov Edi,Gs:[Radar.Xms_Ptr]
 Add Edi,024336d
 Xor Eax,Eax
 Mov Ecx,032768/04d
 Rep Stos Dword Ptr Es:[Edi]

 Mov Eax,0FFFFFFFFh
 Sub Edi,032768d
 Mov Edx,0128d
 Mov Ebp,Edi
 Mov Cx,016d*0256d+016d
 Mov Bx,Offset Init_Block_Gps
 Mov Si,016d
@Set_LBlock:
 Add Edi,Cs:[Bx]

@Set_LBlock_Mapy:
 Mov [Edi],Eax
 Mov [Edi+04h],Eax
 Mov [Edi+08h],Eax
 Mov [Edi+0Ch],Eax
 Bswap Eax
 Add Edi,Edx 
 Dec Cl
 Jnz @Set_LBlock_Mapy
 Mov Edi,Ebp
 Mov Cl,Ch
 Add Bx,04d
 Dec Si
 Jnz @Set_LBlock

Ret
Endp

Even
Math_World Proc Near
;****************************************************************************
;*                         M a t h _ W o r l d                              *
;****************************************************************************
;  -=-=-=-=-=-=-=-=-=-=-
; -= Rotation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-
 Mov Eax,Dword Ptr Gs:[World_Mesh.W_X_Rot]     ; X_Rot, Y_Rot, Z_Rot, Temp
 Mov Bp,Offset Sinus_3d
 Mov Cx,0510d                  ; 256*02 du au Shiftage

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe xXx
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Al
 Xor Bh,Bh
 Add Bx,Bx             ; Adresse Double
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_X],Edi
 Mov Gs:[Rot_CoSin_X],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe yYy
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Ah
 Xor Bh,Bh
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Y],Edi
 Mov Gs:[Rot_CoSin_Y],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe zZz
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Bswap Eax
 Xor Bh,Bh
 Mov Bl,Ah
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Z],Edi
 Mov Gs:[Rot_CoSin_Z],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Effectue les calculs de rotation et de translation
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edi,Gs:[World_Mesh.W_V3d_Dest]
 Mov Esi,Gs:[World_Mesh.W_V3d_Src]
 Mov Bp,W3d_Vert
        
Even
@Loop_World_Vertices_3d:
 Push Bp
 Push Esi
 Push Edi

 Mov Eax,[Esi]        ; xXx
 Mov Ebx,[Esi+04]     ; yYy
 Mov Ecx,[Esi+08]     ; zZz
 Sub Eax,Dword Ptr Gs:[World_Mesh.W_X_Cam]        ; Camera
 Add Ebx,Dword Ptr Gs:[World_Mesh.W_Y_Cam]
 Add Ecx,Dword Ptr Gs:[World_Mesh.W_Z_Cam]  

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_Y = ( Y*Sinus[Angle+64] - Z*Sinus[Angle] )
; Temp_Z = ( Y*Sinus[Angle] + Z*Sinus[Angle+64] )
; Y = Temp_Y Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_X]
 Mov Ebp,Gs:[Rot_CoSin_X]

 Mov Edi,Ebx   ; Y
 Mov Esi,Ecx   ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Ebx
 Imul Ebp,Ecx

 Sub Edi,Esi
 Add Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Ecx,Ebp
 Mov Ebx,Edi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] + Z*Sinus[Angle] )
; Temp_Z = ( Z*Sinus[Angle+64] - X*Sinus[Angle] )
; X = Temp_X Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Y]
 Mov Ebp,Gs:[Rot_CoSin_Y]

 Mov Edi,Eax     ; X
 Mov Esi,Ecx     ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Ebp,Ecx
 Imul Edx,Eax

 Add Edi,Esi
 Sub Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Eax,Edi
 Mov Ecx,Ebp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] - Y*Sinus[Angle] )
; Temp_Y = ( X*Sinus[Angle] + Y*Sinus[Angle+64] )
; X = Temp_X Div 256
; Y = Temp_Y Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Z]
 Mov Ebp,Gs:[Rot_CoSin_Z]

 Mov Edi,Eax     ; X
 Mov Esi,Ebx     ; Y

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Eax
 Imul Ebp,Ebx

 Sub Edi,Esi
 Add Edx,Ebp

 Sar Edi,08
 Sar Edx,08

 Mov Eax,Edi
 Mov Ebx,Edx

 Pop Edi
 Pop Esi

;  -=-=-=-=-=-=-=-=-=-=-=-
; -= Translation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-=-
 Sub Eax,Dword Ptr Gs:[World_Mesh.W_X_Cam]        ; Camera
 Sub Ebx,Dword Ptr Gs:[World_Mesh.W_Y_Cam]
 Sub Ecx,Dword Ptr Gs:[World_Mesh.W_Z_Cam]  
 Add Eax,Gs:[World_Mesh.W_X_Pos]
 Add Ebx,Gs:[World_Mesh.W_Y_Pos]
 Add Ecx,Gs:[World_Mesh.W_Z_Pos]
 Mov [Edi],Eax        ; xXx
 Mov [Edi+04],Ebx     ; yYy
 Mov [Edi+08],Ecx     ; zZz

 Add Edi,012d
 Add Esi,012d

 Pop Bp
 Dec Bp
 Jnz @Loop_World_Vertices_3d

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Converties les vertices en 2d  
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edi,Gs:[World_Mesh.W_V2d_Dest]
 Mov Esi,Gs:[World_Mesh.W_V3d_Dest]
 Mov Bp,W3d_Vert

Even
@Loop_World_Vertices_2d:
 Push Bp
 Push Esi
 Push Edi

 Mov Eax,[Esi]         ; xXx
 Mov Ecx,[Esi+08]      ; zZz
 Mov Ebx,[Esi+04]      ; yYy

 Z_Clip Equ (0256d*01h)
 Push Ecx              ; Clipping de Bas Niveau
 Sub Ecx,Z_Clip      
 Jns @No_Divide_Zero
 Xor Ecx,Ecx
@No_Divide_Zero:
 Add Ecx,Z_Clip

 Cdq
 Shld Edx,Eax,08
 Shl Eax,08
 Idiv Ecx
 Add Eax,0320d
 Mov Si,Ax
 
 Mov Eax,Ebx
 Cdq
 Shld Edx,Eax,08
 Shl Eax,08
 Idiv Ecx
 Add Eax,0240d
 Bswap Eax
 Mov Ax,Si

 Pop Ecx               ; Obtenir la Vrai Valeur de zZz
 Mov [Edi],Eax
 Mov [Edi+04],Ecx

 Pop Edi
 Pop Esi
 Add Edi,08d
 Add Esi,012d

 Pop Bp
 Dec Bp
 Jnz @Loop_World_Vertices_2d

Ret
EndP

NFloors_World Equ (0148d)                      ; All_Cubes
All_3d_Faces Equ (W3d_Face+Const_Nbr_Objects)  ; All_Objects + All_Cubes
All_3d_Floors Equ (W3d_Face-NFloors_World)     ; All_Floors

Even
Sort_yYy_3d_World Proc Near
;****************************************************************************
;*                    S o r t _ y Y y _ 3 d _ W o r l d                     *
;****************************************************************************
; Subdiviser le monde en deux, le plancher et le reste.
 Mov Edi,Gs:[World_Mesh.W_V2d_Dest]
 Mov Esi,Gs:[World_Mesh.W_V3d_Src]
 Mov Bp,W3d_Vert
Even
@Loop_World_Vertices_2d_yYy:
 Push Bp
 Mov Eax,[Esi+08]     ; zZz
 Mov [Edi+04],Eax
 Add Edi,08d
 Add Esi,012d
 Pop Bp
 Dec Bp
 Jnz @Loop_World_Vertices_2d_yYy

 Mov Esi,Gs:[World_Mesh.W_Face_Src]
 Mov Edi,Gs:[World_Mesh.W_V2d_Dest]
 Mov Edx,Gs:[World_Mesh.W_Sort_Face]
 Mov Bp,W3d_Face
 Push Edx
 Push Esi
Even
@Loop_Make_Y_World:
 Xor Eax,Eax           ; Eax =  [X1,Y1]
 Xor Ebx,Ebx           ; Ebx =  [X2,Y2]
 Mov Ax,[Esi+2]        ; Ecx =  [X3,Y3]
 Mov Bx,[Esi]
 Add Eax,Edi           ; Positionnement dans les vertices
 Xor Ecx,Ecx
 Add Ebx,Edi
 Mov Cx,[Esi+4]

 Mov Eax,[Eax+04d]     
 Add Ecx,Edi
 Mov Ebx,[Ebx+04d]
 Mov Ecx,[Ecx+04d]      

 Sub Eax,Ecx
 Jns @No_Z1
 Xor Eax,Eax
@No_Z1:
 Add Eax,Ecx
 Sub Eax,Ebx
 Jns @No_Z2
 Xor Eax,Eax
@No_Z2:
 Add Eax,Ebx

 Mov [Edx],Eax         ; Moyenne
 Mov [Edx+04],Esi      ; Pointeur de la Face

 Add Esi,010d
 Add Edx,08

 Dec Bp
 Jnz @Loop_Make_Y_World

; -= Trie a Bulle (Tres Lent, Mais Utiliser une fois seulement) =-
 Pop Esi
 Pop Edx

 Mov Di,W3d_Face-1
@Bubble_Sort_01:
 Push Edx
 Push Esi
 Mov Bp,W3d_Face-1
@Bubble_Sort_02:
 Mov Eax,[Edx]
 Mov Ebx,[Edx+08]
 Sub Eax,Ebx
 Js @N_Bubble_Inverse
 Add Eax,Ebx
 Mov [Edx],Ebx
 Mov [Edx+08d],Eax
 Mov Eax,[Edx+04d]
 Mov Ebx,[Edx+012d]
 Mov [Edx+04d],Ebx
 Mov [Edx+012d],Eax
@N_Bubble_Inverse:
 Add Edx,08
 Add Esi,010d
 Dec Bp
 Jnz @Bubble_Sort_02
 Pop Esi
 Pop Edx
 Dec Di
 Jnz @Bubble_Sort_01

 Mov Esi,Gs:[World_Mesh.W_Sort_Face]   ; (Z_M(4), Face_Num(4))
 Add Esi,(All_3d_Floors*08d)
 Xor Eax,Eax
 Xor Ebx,Ebx
 Mov Ax,Gs
 Mov Bx,Offset Bac_W_Sort_Face
 Shl Eax,04
 Add Eax,Ebx
 Mov Gs:[BWSF_32],Eax
 Mov Edi,Eax
 Mov Ecx,(NFloors_World*08d)/04
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

Ret
EndP

Even
Draw_Floors Proc Near
;****************************************************************************
;*                          D r a w _ F l o o r s                           *
;****************************************************************************
@ED_F9F10:
 Nop
 Mov Esi,Gs:[World_Mesh.W_Sort_Face]   ; (Z_M(4), Face_Num(4))
 Mov Edi,Gs:[World_Mesh.W_V2d_Dest]
 Mov Bp,All_3d_Floors
 Add Esi,(All_3d_Floors-1)*08       

Even
@WLoop_Draw_Floors:
 Push Esi
 Push Edi
 Push Bp

 Mov Eax,[Esi]
 Sub Eax,Z_Clip*01h
 Js @WPoly_End_Quit_Floors

 Mov Esi,[Esi+04]              ; Pointe vers une Face
 Mov Edx,[Esi+06]
 Mov Dword Ptr Cs:[@WPut_Color_Floors+02],Edx

 Xor Eax,Eax           ; Eax =  [X2,Y2]
 Xor Ebx,Ebx           ; Ebx =  [X1,Y1]
 Mov Ax,[Esi+2]        ; Ecx =  [X3,Y3]
 Mov Bx,[Esi+4]        
 Add Eax,Edi
 Xor Ecx,Ecx
 Add Ebx,Edi
 Mov Cx,[Esi]

;=-
 Mov Eax,[Eax]
 Add Ecx,Edi
 Mov Ebx,[Ebx]                 ; X,Y(Swap)
 Mov Ecx,[Ecx]

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Mov Dx,Ax
 Xor Bp,Bp

 Sub Dx,Bx             ; Trie les vertices pour le point inferieur
 Jle @WC1_Floors
 Xor Dx,Dx
 Inc Bp
@WC1_Floors:
 Add Dx,Bx
 
 Sub Dx,Cx
 Jle @WC2_Floors
 Xor Dx,Dx
 Mov Bp,02
@WC2_Floors:
 Add Dx,Cx

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Dec Bp                ; Positionnement du point inferieur
 Jnz @WN2_Floors
 Xchg Eax,Ebx
 Xchg Ebx,Ecx
@WN2_Floors:

 Dec Bp
 Jnz @WN3_Floors
 Xchg Eax,Ecx
 Xchg Ecx,Ebx
@WN3_Floors:

 Sub Bp,479            ; Poly_Limit_Bottom
 Jns @WPoly_End_Quit_Floors

 Mov Bp,Ax             ; Poly_Limit_Left
 And Bp,Bx
 Test Bp,Cx
 Js @WPoly_End_Quit_Floors

 Mov Gs:[Bac_X2Y2],Ebx  
 Mov Gs:[Bac_X3Y3],Ecx 

;=--------------------------------------------------------------------------=
 Mov Dx,04647h                 ; Inc E(di) ; Inc E(si);
 Sub Bx,Ax
 Jns @WNo_Delta_X_Change_Floors   ; [X2-X1]
 Neg Bx
 Mov Dl,04Fh                   ; Dec Edi
@WNo_Delta_X_Change_Floors:
 Jnz @WAuto_CorX1_Floors          ; Corrige le defaut lorsque la ligne est droite
 Dec Ax
@WAuto_CorX1_Floors:

 Sub Cx,Ax                     ; [X3-X1]
 Jns @WNo_Delta_X_Change2_Floors
 Neg Cx
 Mov Dh,04Eh                   ; Dec Esi
@WNo_Delta_X_Change2_Floors:
 Jnz @WAuto_CorX2_Floors          ; Corrige le defaut lorsque la ligne est droite
 Inc Ax
@WAuto_CorX2_Floors:

 Mov Byte Ptr Cs:[@WDelta_Move_Floors+1],Dl
 Mov Byte Ptr Cs:[@WDelta_Move2_Floors+1],Dh

 Movsx Esi,Ax                  ; Conserve X1
 Mov Bp,Cx                     ; T u
 Mov Dx,Bx                     ;  a x

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Test Bx,Cx                    ; Polygone hors de l'ecran (Superieur)
 Js @WPoly_End_Quit_Floors             ; Les Deux Points Maximal Negatif 

 Sub Bx,Ax                     ; Delta_yYy
 Jnz @WNo_Top_Left_Flat_Floors
 Inc Bx
@WNo_Top_Left_Flat_Floors:

 Sub Cx,Ax
 Jnz @WNo_Top_Right_Flat_Floors
 Inc Cx
@WNo_Top_Right_Flat_Floors:

 Movsx Edi,Ax                  ; Y1
 Mov Ax,Cx                     ; Hauteur
 Bswap Eax

 Mov Ax,Bp                     ; Taux
 Mov Bp,Dx                     ; Taux

 Mov Dx,Bx                     ; Hauteur
 Imul Edi,640
 Bswap Edx
 Mov Dx,Bp

 Mov Ebp,Edi
 Mov Edi,Esi

 ;        Hi   Lo
 ; ---------------
 ; Eax : Haut Taux 3-Right
 ; Edx : Haut Taux 2-Left
 ; Ebx : D_X  D_Y  2-Left
 ; Ecx : D_X  D_Y  3-Right

Even
@WLine_Main_Loop_Floors:

 Test Dx,Dx
@WLoop_Line_01_Floors:
 Js @WAdd_Delta_X1_Floors
@WDelta_Move_Floors:
 Inc Edi
 Sub Dx,Bx                     ; -Dy
 Jns @WDelta_Move_Floors

@WAdd_Delta_X1_Floors:
 Bswap Ebx
 Add Dx,Bx                     ; +Dx
 Bswap Ebx

 Test Ax,Ax
@WLoop_Line_02_Floors:
 Js @WAdd_Delta_X2_Floors
@WDelta_Move2_Floors:
 Inc Esi
 Sub Ax,Cx
 Jns @WDelta_Move2_Floors

@WAdd_Delta_X2_Floors:
 Bswap Ecx
 Add Ax,Cx
 Bswap Ecx

 Test Ebp,Ebp                  ; Clipping Top
 Js @WNo_Line_Draw2_Floors

 Push Esi
 Push Eax
 Push Ecx
 Push Edi

 Mov Eax,Ebp
 Mov Ecx,Esi                   ; Droite
 Sub Eax,480*640               ; Clipping Bottom
 Jns @WNo_Line_Draw_Floors            

 Sub Ecx,Edi                   ; Gauche
 Js @WNo_Line_Draw_Floors
 Mov Eax,0639d
 Inc Ecx

 Test Esi,Edi                  ; Clipping de Gauche
 Js @WNo_Line_Draw_Floors

 Sub Esi,Eax                   ; Clipping Droite
 Js @WNo_Clip_Right_Floors
 Sub Ecx,Esi
 Js @WNo_Line_Draw_Floors
@WNo_Clip_Right_Floors:

 Test Edi,Edi                  ; Clipping de Gauche pour (X2 Negatif)
 Jns @WNo_Clip_Left_Floors
 Add Ecx,Edi
 Xor Edi,Edi  
@WNo_Clip_Left_Floors:
 
@WPut_Color_Floors:
 Mov Eax,0F0F0F0F0H 

 Add Edi,Ebp                   ; yYy
 Mov Esi,Ecx
 Add Edi,Gs:[Screen.Xms_Ptr]   ; Offset Mem Video

 And Ecx,03h
 Shr Esi,02
 Rep Stos Byte Ptr Es:[Edi]

 Mov Ecx,Esi
 Rep Stos Dword Ptr Es:[Edi]

@WNo_Line_Draw_Floors:
 Pop Edi
 Pop Ecx
 Pop Eax
 Pop Esi
@WNo_Line_Draw2_Floors:
 Add Ebp,0640d                 ; Saute une ligne

 Bswap Edx
 Bswap Eax

 Dec Dx
 Jz @WNext_Line_01_Floors
@WBack_From_Line_01_Floors:

 Dec Ax
 Jz @WNext_Line_02_Floors

 Bswap Eax
 Bswap Edx
 Jnz @WLine_Main_Loop_Floors

Even
@WNext_Line_02_Floors:                 ; D r o i t e . . .
@WRight_Line_Abs_Floors:

 Push Ebx
 Push Edx
 Mov Ebx,Gs:[Bac_X2Y2]
 Mov Ecx,Gs:[Bac_X3Y3]
 Mov Dl,04Eh

 Sub Cx,Bx
 Jns @WNo_Inv_NDeltaX1_Floors
 Mov Dl,046h
 Neg Cx
@WNo_Inv_NDeltaX1_Floors:
 Inc Cx
 Mov Byte Ptr Cs:[@WDelta_Move2_Floors+1],Dl

 Bswap Eax
 Mov Ax,Cx     ; Taux
 Bswap Ebx
 Bswap Ecx
 Bswap Eax

 Sub Cx,Bx
 Jns @WNo_Inv_NDeltaY1_Floors
 Neg Cx
@WNo_Inv_NDeltaY1_Floors:
 Inc Cx

 Pop Edx
 Pop Ebx
 Mov Ax,Dx     ; Hauteur

 Test Ax,Ax
 Bswap Eax
 Bswap Edx
 Jnz @WLine_Main_Loop_Floors

@WPoly_End_Quit_Floors:
 Pop Bp
 Pop Edi
 Pop Esi
 Sub Esi,08d   ; Moyenne_Z, Pointeur_Face
 Dec Bp
 Jnz @WLoop_Draw_Floors
Ret

Even
@WNext_Line_01_Floors:                 ; G a u c h e . . .
@WLeft_Line_Abs_Floors:

 Push Ecx
 Push Eax
 Mov Ebx,Gs:[Bac_X2Y2]
 Mov Ecx,Gs:[Bac_X3Y3]
 Mov Al,04Fh

 Sub Bx,Cx
 Jns @WNo_Inv_NDeltaX2_Floors
 Mov Al,047h
 Neg Bx
@WNo_Inv_NDeltaX2_Floors:
 Inc Bx
 Mov Byte Ptr Cs:[@WDelta_Move_Floors+1],Al

 Bswap Edx               
 Mov Dx,Bx     ; Taux
 Bswap Edx

 Bswap Ebx
 Bswap Ecx

 Sub Bx,Cx
 Jns @WNo_Inv_NDeltaY2_Floors
 Neg Bx
@WNo_Inv_NDeltaY2_Floors:
 Inc Bx

 Pop Eax
 Pop Ecx

 Mov Dx,Ax                    ; Hauteur
 Dec Dx
 Jz @WPoly_End_Quit_Floors
 Inc Dx
 Jns @WBack_From_Line_01_Floors

Ret
EndP

Even
Draw_World Proc Near
;****************************************************************************
;*                           D r a w _ W o r l d                            *
;****************************************************************************
 Mov Esi,Gs:[World_Mesh.W_Sort_Face]   ; (Z_M(4), Face_Num(4))
 Mov Edi,Gs:[World_Mesh.W_V2d_Dest]
 Mov Bp,All_3d_Faces-All_3d_Floors
 Add Esi,(All_3d_Faces-1)*08d

Even
@WLoop_Draw_World:
 Push Esi
 Push Edi
 Push Bp

 Mov Eax,[Esi]                 ; zZz
 Mov Esi,[Esi+04]              ; Pointe vers une Face
 Mov Edx,[Esi+06]

 Test Dl,Dl                    ; Pour un Object 0,Offset de la Structure_3d
 Jnz @No_Draw_Objects
 Test Dh,01
 Jnz @Enemy_Dead

 Xor Dh,Dh
 Bswap Edx
 Xchg Dl,Dh
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Ebp,012800d
 Mov Eax,Gs:[Bac_Mesh.M_X_Pos]
 Mov Ebx,Gs:[Bac_Mesh.M_Y_Pos]
 Mov Ecx,Gs:[HeroStr.M_X_Pos]
 Mov Edx,Gs:[HeroStr.M_Y_Pos]
 Add Eax,Ebp
 Add Ebx,Ebp
 Add Ecx,Ebp
 Add Edx,Ebp
 Sub Ecx,Eax
 Sub Edx,Ebx

;Camera_Table []
 M3d_Clip Equ 06400d
 Mov Eax,M3d_Clip
 Mov Ebx,M3d_Clip*02d
 Sub Ecx,Eax
 Jns @Enemy_Dead
 Add Ecx,Ebx
 Js @Enemy_Dead
 Sub Edx,Eax
 Jns @Enemy_Dead
 Add Edx,Ebx
 Js @Enemy_Dead

 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh
@Enemy_Dead:
 Pop Bp
 Pop Edi
 Pop Esi
 Sub Esi,08d   ; Moyenne_Z, Pointeur_Face
 Dec Bp
 Jnz @WLoop_Draw_World
Ret
@No_Draw_Objects:

 Sub Eax,Z_Clip*02d
 Js @WPoly_End_Quit_World
 Mov Dword Ptr Cs:[@WPut_Color_World+02],Edx

 Xor Eax,Eax           ; Eax =  [X2,Y2]
 Xor Ebx,Ebx           ; Ebx =  [X1,Y1]
 Mov Ax,[Esi+2]        ; Ecx =  [X3,Y3]
 Mov Bx,[Esi+4]        
 Add Eax,Edi
 Xor Ecx,Ecx
 Add Ebx,Edi
 Mov Cx,[Esi]

;=-
 Mov Edx,[Eax+04]
 Mov Eax,[Eax]
 Add Ecx,Edi
 Mov Ebx,[Ebx]                 ; X,Y(Swap)
 Mov Ecx,[Ecx]

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Mov Dx,Ax
 Xor Bp,Bp

 Sub Dx,Bx             ; Trie les vertices pour le point inferieur
 Jle @WC1_World
 Xor Dx,Dx
 Inc Bp
@WC1_World:
 Add Dx,Bx
 
 Sub Dx,Cx
 Jle @WC2_World
 Xor Dx,Dx
 Mov Bp,02
@WC2_World:
 Add Dx,Cx

 Mov Di,Bx                     ; Clip Bottom
 Mov Si,Cx
 Sub Di,480
 Js @WNo_Clip_Bottom
 Sub Si,480
 Jns @WPoly_End_Quit_World  
@WNo_Clip_Bottom:

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Dec Bp                ; Positionnement du point inferieur
 Jnz @WN2_World
 Xchg Eax,Ebx
 Xchg Ebx,Ecx
@WN2_World:

 Dec Bp
 Jnz @WN3_World
 Xchg Eax,Ecx
 Xchg Ecx,Ebx
@WN3_World:

; Sub Bp,479            ; Poly_Limit_Bottom
; Jns @WPoly_End_Quit_World

 Mov Bp,Ax             ; Poly_Limit_Left
 And Bp,Bx
 Test Bp,Cx
 Js @WPoly_End_Quit_World

 Mov Gs:[Bac_X2Y2],Ebx  
 Mov Gs:[Bac_X3Y3],Ecx 

;=--------------------------------------------------------------------------=
 Mov Dx,04647h                 ; Inc E(di) ; Inc E(si);
 Sub Bx,Ax
 Jns @WNo_Delta_X_Change_World   ; [X2-X1]
 Neg Bx
 Mov Dl,04Fh                   ; Dec Edi
@WNo_Delta_X_Change_World:
 Jnz @WAuto_CorX1_World          ; Corrige le defaut lorsque la ligne est droite
 Dec Ax
@WAuto_CorX1_World:

 Sub Cx,Ax                     ; [X3-X1]
 Jns @WNo_Delta_X_Change2_World
 Neg Cx
 Mov Dh,04Eh                   ; Dec Esi
@WNo_Delta_X_Change2_World:
 Jnz @WAuto_CorX2_World          ; Corrige le defaut lorsque la ligne est droite
 Inc Ax
@WAuto_CorX2_World:

 Mov Byte Ptr Cs:[@WDelta_Move_World+1],Dl
 Mov Byte Ptr Cs:[@WDelta_Move2_World+1],Dh

 Movsx Esi,Ax                  ; Conserve X1
 Mov Bp,Cx                     ; T u
 Mov Dx,Bx                     ;  a x

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Test Bx,Cx                    ; Polygone hors de l'ecran (Superieur)
 Js @WPoly_End_Quit_World             ; Les Deux Points Maximal Negatif 

 Sub Bx,Ax                     ; Delta_yYy
 Jnz @WNo_Top_Left_Flat_World
 Inc Bx
@WNo_Top_Left_Flat_World:

 Sub Cx,Ax
 Jnz @WNo_Top_Right_Flat_World
 Inc Cx
@WNo_Top_Right_Flat_World:

 Movsx Edi,Ax                  ; Y1
 Mov Ax,Cx                     ; Hauteur
 Bswap Eax

 Mov Ax,Bp                     ; Taux
 Mov Bp,Dx                     ; Taux

 Mov Dx,Bx                     ; Hauteur
 Imul Edi,640
 Bswap Edx
 Mov Dx,Bp

 Mov Ebp,Edi
 Mov Edi,Esi

 ;        Hi   Lo
 ; ---------------
 ; Eax : Haut Taux 3-Right
 ; Edx : Haut Taux 2-Left
 ; Ebx : D_X  D_Y  2-Left
 ; Ecx : D_X  D_Y  3-Right

Even
@WLine_Main_Loop_World:

 Test Dx,Dx
@WLoop_Line_01_World:
 Js @WAdd_Delta_X1_World
@WDelta_Move_World:
 Inc Edi
 Sub Dx,Bx                     ; -Dy
 Jns @WDelta_Move_World

@WAdd_Delta_X1_World:
 Bswap Ebx
 Add Dx,Bx                     ; +Dx
 Bswap Ebx

 Test Ax,Ax
@WLoop_Line_02_World:
 Js @WAdd_Delta_X2_World
@WDelta_Move2_World:
 Inc Esi
 Sub Ax,Cx
 Jns @WDelta_Move2_World

@WAdd_Delta_X2_World:
 Bswap Ecx
 Add Ax,Cx
 Bswap Ecx

 Test Ebp,Ebp                  ; Clipping Top
 Js @WNo_Line_Draw2_World

 Push Esi
 Push Eax
 Push Ecx
 Push Edi

 Mov Eax,Ebp
 Mov Ecx,Esi                   ; Droite
 Sub Eax,480*640               ; Clipping Bottom
 Jns @WNo_Line_Draw_World            

 Sub Ecx,Edi                   ; Gauche
 Js @WNo_Line_Draw_World
 Mov Eax,0639d
 Inc Ecx

 Test Esi,Edi                  ; Clipping de Gauche
 Js @WNo_Line_Draw_World

 Sub Esi,Eax                   ; Clipping Droite
 Js @WNo_Clip_Right_World
 Sub Ecx,Esi
 Js @WNo_Line_Draw_World
@WNo_Clip_Right_World:

 Test Edi,Edi                  ; Clipping de Gauche pour (X2 Negatif)
 Jns @WNo_Clip_Left_World
 Add Ecx,Edi
 Xor Edi,Edi  
@WNo_Clip_Left_World:
 
@WPut_Color_World:
 Mov Eax,0F0F0F0F0H 

 Add Edi,Ebp                   ; yYy
 Mov Esi,Ecx
 Add Edi,Gs:[Screen.Xms_Ptr]   ; Offset Mem Video

 And Ecx,03h
 Shr Esi,02
 Rep Stos Byte Ptr Es:[Edi]

 Mov Ecx,Esi
 Rep Stos Dword Ptr Es:[Edi]

@WNo_Line_Draw_World:
 Pop Edi
 Pop Ecx
 Pop Eax
 Pop Esi
@WNo_Line_Draw2_World:
 Add Ebp,0640d                 ; Saute une ligne

 Bswap Edx
 Bswap Eax

 Dec Dx
 Jz @WNext_Line_01_World
@WBack_From_Line_01_World:

 Dec Ax
 Jz @WNext_Line_02_World

 Bswap Eax
 Bswap Edx
 Jnz @WLine_Main_Loop_World

Even
@WNext_Line_02_World:                 ; D r o i t e . . .
@WRight_Line_Abs_World:

 Push Ebx
 Push Edx
 Mov Ebx,Gs:[Bac_X2Y2]
 Mov Ecx,Gs:[Bac_X3Y3]
 Mov Dl,04Eh

 Sub Cx,Bx
 Jns @WNo_Inv_NDeltaX1
 Mov Dl,046h
 Neg Cx
@WNo_Inv_NDeltaX1:
 Inc Cx
 Mov Byte Ptr Cs:[@WDelta_Move2_World+1],Dl

 Bswap Eax
 Mov Ax,Cx     ; Taux
 Bswap Ebx
 Bswap Ecx
 Bswap Eax

 Sub Cx,Bx
 Jns @WNo_Inv_NDeltaY1
 Neg Cx
@WNo_Inv_NDeltaY1:
 Inc Cx

 Pop Edx
 Pop Ebx
 Mov Ax,Dx     ; Hauteur

 Test Ax,Ax
 Bswap Eax
 Bswap Edx
 Jnz @WLine_Main_Loop_World

@WPoly_End_Quit_World:
 Pop Bp
 Pop Edi
 Pop Esi
 Sub Esi,08d   ; Moyenne_Z, Pointeur_Face
 Dec Bp
 Jnz @WLoop_Draw_World
Ret

Even
@WNext_Line_01_World:                 ; G a u c h e . . .
@WLeft_Line_Abs_World:

 Push Ecx
 Push Eax
 Mov Ebx,Gs:[Bac_X2Y2]
 Mov Ecx,Gs:[Bac_X3Y3]
 Mov Al,04Fh

 Sub Bx,Cx
 Jns @WNo_Inv_NDeltaX2
 Mov Al,047h
 Neg Bx
@WNo_Inv_NDeltaX2:
 Inc Bx
 Mov Byte Ptr Cs:[@WDelta_Move_World+1],Al

 Bswap Edx               
 Mov Dx,Bx     ; Taux
 Bswap Edx

 Bswap Ebx
 Bswap Ecx

 Sub Bx,Cx
 Jns @WNo_Inv_NDeltaY2
 Neg Bx
@WNo_Inv_NDeltaY2:
 Inc Bx

 Pop Eax
 Pop Ecx

 Mov Dx,Ax                    ; Hauteur
 Dec Dx
 Jz @WPoly_End_Quit_World
 Inc Dx
 Jns @WBack_From_Line_01_World

Ret
EndP

Even
Sort_3d_World Proc Near
;****************************************************************************
;*                       S o r t _ 3 d _ W o r l d                          *
;****************************************************************************
 Mov Edi,Gs:[World_Mesh.W_Sort_Face]   ; (Z_M(4), Face_Num(4))
 Mov Esi,Gs:[BWSF_32]
 Add Edi,(All_3d_Floors*08d)
 Mov Ecx,(NFloors_World*08d)/04
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Esi,Gs:[World_Mesh.W_Face_Src]
 Mov Edi,Gs:[World_Mesh.W_V2d_Dest]
 Mov Edx,Gs:[World_Mesh.W_Sort_Face]
 Mov Bp,W3d_Face

Even
@Loop_Make_Z_World2:
 Mov Esi,[Edx+04]      ; Pointer sur la Face
 Xor Eax,Eax           ; Eax =  [X1,Y1]
 Xor Ebx,Ebx           ; Ebx =  [X2,Y2]
 Mov Ax,[Esi+2]        ; Ecx =  [X3,Y3]
 Mov Bx,[Esi]
 Add Eax,Edi           ; Positionnement dans les vertices
 Xor Ecx,Ecx
 Add Ebx,Edi
 Mov Cx,[Esi+4]

 Mov Eax,[Eax+04d]     
 Add Ecx,Edi
 Mov Ebx,[Ebx+04d]
 Mov Ecx,[Ecx+04d]      

 Sub Eax,Ecx           ; Le Plus Loin
 Jns @No_Z1w
 Xor Eax,Eax
@No_Z1w:
 Add Eax,Ecx
 Sub Eax,Ebx
 Jns @No_Z2w
 Xor Eax,Eax
@No_Z2w:
 Add Eax,Ebx

 Mov [Edx],Eax         ; Moyenne
 Add Edx,08
 Dec Bp
 Jnz @Loop_Make_Z_World2

 Mov Edi,Gs:[World_Mesh.W_Sort_Face]
 Add Edi,(All_3d_Floors*08d)

; -= Trie QuickSort =-
 Mov Esi,Edi
 Add Edi,(NFloors_World+Const_Nbr_Objects-1)*08d

Even
Recursive_Sort_World Proc Near
 Mov Ebp,Edi                   ; Element du Milieu
 Sub Ebp,Esi
 Shr Ebp,01
 And Ebp,Not 07
 Add Ebp,Esi
 Mov Ebp,Ds:[Ebp]      ; Element Milieu
 Mov Edx,08

 Mov Eax,Esi           ; Pointeur Gauche
 Mov Ebx,Edi           ; Pointeur Droite

Even
@Loop_Sort_World:
@Loop_Ptr_Forward_World:
 Mov Ecx,[Eax]                 
 Add Eax,Edx
 Sub Ecx,Ebp                   
 Js @Loop_Ptr_Forward_World
 Sub Eax,Edx

Even
@Loop_Ptr_BackWard_World:
 Mov Ecx,Ebp
 Sub Ebx,Edx
 Sub Ecx,[Ebx+08]
 Js @Loop_Ptr_BackWard_World
 Add Ebx,Edx

 Mov Ecx,Ebx
 Sub Ecx,Eax
 Js @No_Swap_Sort_World
 Mov Edx,[Eax]
 Mov Ecx,[Ebx]
 Mov [Ebx],Edx
 Mov [Eax],Ecx

 Mov Edx,[Eax+4]
 Mov Ecx,[Ebx+4]
 Mov [Ebx+4],Edx
 Mov [Eax+4],Ecx

 Mov Edx,08
 Add Eax,Edx
 Sub Ebx,Edx
@No_Swap_Sort_World:

 Mov Ecx,Ebx
 Sub Ecx,Eax
 Jns @Loop_Sort_World

 Sub Esi,Ebx
 Jns @No_New_Sort1_World
 Add Esi,Ebx

 Push Eax
 Push Ebx
 Push Esi
 Push Edi
 Mov Edi,Ebx
 Call Recursive_Sort_World
 Pop Edi
 Pop Esi
 Pop Ebx
 Pop Eax

@No_New_Sort1_World:

 Sub Eax,Edi
 Jns @No_New_Sort2_World
 Add Eax,Edi

 Push Eax
 Push Ebx
 Push Esi
 Push Edi
 Mov Esi,Eax
 Call Recursive_Sort_World
 Pop Edi
 Pop Esi
 Pop Ebx
 Pop Eax
@No_New_Sort2_World:

Ret
Endp
EndP

;================================= M e s h ===================================
Even
Math_Mesh Proc Near
;****************************************************************************
;*                         M a t h _ M e s h                                *
;****************************************************************************
;  -=-=-=-=-=-=-=-=-=-=-
; -= Rotation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-
 Mov Eax,Dword Ptr Gs:[Bac_Mesh.M_X_Rot]     ; X_Rot, Y_Rot, Z_Rot, Temp
 Mov Bp,Offset Sinus_3d
 Mov Cx,0510d                  ; 256*02 du au Shiftage

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe xXx
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Al
 Xor Bh,Bh
 Add Bx,Bx             ; Adresse Double
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_X],Edi
 Mov Gs:[Rot_CoSin_X],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe yYy
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Ah
 Xor Bh,Bh
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Y],Edi
 Mov Gs:[Rot_CoSin_Y],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe zZz
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Bswap Eax
 Xor Bh,Bh
 Mov Bl,Ah
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Z],Edi
 Mov Gs:[Rot_CoSin_Z],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Effectue les calculs de rotation et de translation
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edi,Gs:[Bac_Mesh.M_V3d_Dest]
 Mov Esi,Gs:[Bac_Mesh.M_V3d_Src]
 Mov Bp,Gs:[Bac_Mesh.M_Nbr_Vertices]
 Push Edi
 Push Bp

Even
@Loop_Mesh_Vertices_3d:
 Push Bp
 Push Esi
 Push Edi

 Mov Eax,[Esi]        ; xXx
 Mov Ebx,[Esi+04]     ; yYy
 Mov Ecx,[Esi+08]     ; zZz

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_Y = ( Y*Sinus[Angle+64] - Z*Sinus[Angle] )
; Temp_Z = ( Y*Sinus[Angle] + Z*Sinus[Angle+64] )
; Y = Temp_Y Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_X]
 Mov Ebp,Gs:[Rot_CoSin_X]

 Mov Edi,Ebx   ; Y
 Mov Esi,Ecx   ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Ebx
 Imul Ebp,Ecx

 Sub Edi,Esi
 Add Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Ecx,Ebp
 Mov Ebx,Edi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] + Z*Sinus[Angle] )
; Temp_Z = ( Z*Sinus[Angle+64] - X*Sinus[Angle] )
; X = Temp_X Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Y]
 Mov Ebp,Gs:[Rot_CoSin_Y]

 Mov Edi,Eax     ; X
 Mov Esi,Ecx     ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Ebp,Ecx
 Imul Edx,Eax

 Add Edi,Esi
 Sub Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Eax,Edi
 Mov Ecx,Ebp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] - Y*Sinus[Angle] )
; Temp_Y = ( X*Sinus[Angle] + Y*Sinus[Angle+64] )
; X = Temp_X Div 256
; Y = Temp_Y Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Z]
 Mov Ebp,Gs:[Rot_CoSin_Z]

 Mov Edi,Eax     ; X
 Mov Esi,Ebx     ; Y

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Eax
 Imul Ebp,Ebx

 Sub Edi,Esi
 Add Edx,Ebp

 Sar Edi,08
 Sar Edx,08

 Mov Eax,Edi
 Mov Ebx,Edx

 Pop Edi
 Pop Esi

;  -=-=-=-=-=-=-=-=-=-=-=-
; -= Translation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-=-
 Add Eax,Gs:[Bac_Mesh.M_X_Pos]
 Add Ebx,Gs:[Bac_Mesh.M_Y_Pos]
 Add Ecx,Gs:[Bac_Mesh.M_Z_Pos]

 Mov [Edi],Eax        ; xXx
 Mov [Edi+04],Ebx     ; yYy
 Mov [Edi+08],Ecx     ; zZz

 Add Edi,012d
 Add Esi,012d

 Pop Bp
 Dec Bp
 Jnz @Loop_Mesh_Vertices_3d

;  -=-=-=-=-=-=-=-=-=-=-
; -= Rotation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-
 Mov Eax,Dword Ptr Gs:[World_Mesh.W_X_Rot]     ; X_Rot, Y_Rot, Z_Rot, Temp
 Mov Bp,Offset Sinus_3d
 Mov Cx,0510d                  ; 256*02 du au Shiftage

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe xXx
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Al
 Xor Bh,Bh
 Add Bx,Bx             ; Adresse Double
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_X],Edi
 Mov Gs:[Rot_CoSin_X],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe yYy
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Ah
 Xor Bh,Bh
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Y],Edi
 Mov Gs:[Rot_CoSin_Y],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe zZz
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Bswap Eax
 Xor Bh,Bh
 Mov Bl,Ah
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Z],Edi
 Mov Gs:[Rot_CoSin_Z],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Effectue les calculs de rotation et de translation
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Pop Bp
 Pop Edi
 Mov Esi,Edi
        
Even
@World_Loop_Mesh_Vertices_3d:
 Push Bp
 Push Esi
 Push Edi

 Mov Eax,[Esi]        ; xXx
 Mov Ebx,[Esi+04]     ; yYy
 Mov Ecx,[Esi+08]     ; zZz
 Sub Eax,Dword Ptr Gs:[World_Mesh.W_X_Cam]        ; Camera
 Add Ebx,Dword Ptr Gs:[World_Mesh.W_Y_Cam]
 Add Ecx,Dword Ptr Gs:[World_Mesh.W_Z_Cam]  

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_Y = ( Y*Sinus[Angle+64] - Z*Sinus[Angle] )
; Temp_Z = ( Y*Sinus[Angle] + Z*Sinus[Angle+64] )
; Y = Temp_Y Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_X]
 Mov Ebp,Gs:[Rot_CoSin_X]

 Mov Edi,Ebx   ; Y
 Mov Esi,Ecx   ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Ebx
 Imul Ebp,Ecx

 Sub Edi,Esi
 Add Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Ecx,Ebp
 Mov Ebx,Edi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] + Z*Sinus[Angle] )
; Temp_Z = ( Z*Sinus[Angle+64] - X*Sinus[Angle] )
; X = Temp_X Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Y]
 Mov Ebp,Gs:[Rot_CoSin_Y]

 Mov Edi,Eax     ; X
 Mov Esi,Ecx     ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Ebp,Ecx
 Imul Edx,Eax

 Add Edi,Esi
 Sub Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Eax,Edi
 Mov Ecx,Ebp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] - Y*Sinus[Angle] )
; Temp_Y = ( X*Sinus[Angle] + Y*Sinus[Angle+64] )
; X = Temp_X Div 256
; Y = Temp_Y Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Z]
 Mov Ebp,Gs:[Rot_CoSin_Z]

 Mov Edi,Eax     ; X
 Mov Esi,Ebx     ; Y

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Eax
 Imul Ebp,Ebx

 Sub Edi,Esi
 Add Edx,Ebp

 Sar Edi,08
 Sar Edx,08

 Mov Eax,Edi
 Mov Ebx,Edx

 Pop Edi
 Pop Esi

;  -=-=-=-=-=-=-=-=-=-=-=-
; -= Translation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-=-
 Sub Eax,Dword Ptr Gs:[World_Mesh.W_X_Cam]        ; Camera
 Sub Ebx,Dword Ptr Gs:[World_Mesh.W_Y_Cam]
 Sub Ecx,Dword Ptr Gs:[World_Mesh.W_Z_Cam]  
 Add Eax,Gs:[World_Mesh.W_X_Pos]
 Add Ebx,Gs:[World_Mesh.W_Y_Pos]
 Add Ecx,Gs:[World_Mesh.W_Z_Pos]
 Mov [Edi],Eax        ; xXx
 Mov [Edi+04],Ebx     ; yYy
 Mov [Edi+08],Ecx     ; zZz

 Add Edi,012d
 Add Esi,012d

 Pop Bp
 Dec Bp
 Jnz @World_Loop_Mesh_Vertices_3d

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Converties les vertices en 2d  
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edi,Gs:[Bac_Mesh.M_V2d_Dest]
 Mov Esi,Gs:[Bac_Mesh.M_V3d_Dest]
 Mov Bp,Gs:[Bac_Mesh.M_Nbr_Vertices]

Even
@Loop_Mesh_Vertices_2d:
 Push Bp
 Push Esi
 Push Edi

 Mov Eax,[Esi]        ; xXx
 Mov Ecx,[Esi+08]     ; zZz
 Mov Ebx,[Esi+04]     ; yYy

 Push Ecx              ; Clipping de Bas Niveau
 Sub Ecx,Z_Clip      
 Jns @No_Divide_Zero2
 Xor Ecx,Ecx
@No_Divide_Zero2:
 Add Ecx,Z_Clip

 Cdq               
 Shld Edx,Eax,08
 Shl Eax,08
 Idiv Ecx
 Add Eax,0320d
 Mov Si,Ax
 
 Mov Eax,Ebx
 Cdq
 Shld Edx,Eax,08
 Shl Eax,08
 Idiv Ecx
 Add Eax,0240d
 Bswap Eax
 Mov Ax,Si

 Pop Ecx           
 Mov [Edi],Eax
 Mov [Edi+04],Ecx

 Pop Edi
 Pop Esi
 Add Edi,08d
 Add Esi,012d

 Pop Bp
 Dec Bp
 Jnz @Loop_Mesh_Vertices_2d

Ret
EndP

Even
Sort_3d_Mesh Proc Near
;****************************************************************************
;*                       S o r t _ 3 d _ M e s h                            *
;****************************************************************************
 Mov Esi,Gs:[Bac_Mesh.M_Face_Src]
 Mov Edi,Gs:[Bac_Mesh.M_V2d_Dest]
 Mov Edx,Gs:[Bac_Mesh.M_Sort_Face]
 Mov Bp,Gs:[Bac_Mesh.M_Nbr_Faces]
 Push Edx
 Push Bp

Even
@Loop_Make_Z_Mesh:
 Xor Eax,Eax           ; Eax =  [X1,Y1]
 Xor Ebx,Ebx           ; Ebx =  [X2,Y2]
 Mov Ax,[Esi+2]        ; Ecx =  [X3,Y3]
 Mov Bx,[Esi]
 Add Eax,Edi           ; Positionnement dans les vertices
 Xor Ecx,Ecx
 Add Ebx,Edi
 Mov Cx,[Esi+4]

 Mov Eax,[Eax+04d]     ; zZz1
 Add Ecx,Edi
 Mov Ebx,[Ebx+04d]     ; zZz2
 Mov Ecx,[Ecx+04d]     ; zZz3

 Sub Eax,Ecx           ; Le Plus Loin
 Jns @No_Z1m
 Xor Eax,Eax
@No_Z1m:
 Add Eax,Ecx
 Sub Eax,Ebx
 Jns @No_Z2m
 Xor Eax,Eax
@No_Z2m:
 Add Eax,Ebx

 Mov [Edx],Eax         ; Moyenne de zZz
 Mov [Edx+04],Esi      ; Pointeur de la Face

 Add Esi,010d
 Add Edx,08

 Dec Bp
 Jnz @Loop_Make_Z_Mesh

; -= Trie QuickSort =-
 Xor Ebp,Ebp
 Pop Bp
 Pop Edi
 Mov Esi,Edi
 Dec Bp
 Shl Ebp,03
 Add Edi,Ebp

Even
Recursive_Sort Proc Near
 Mov Ebp,Edi                   ; Element du Milieu
 Sub Ebp,Esi
 Shr Ebp,01
 And Ebp,Not 07
 Add Ebp,Esi
 Mov Ebp,Ds:[Ebp]      ; Element Milieu
 Mov Edx,08

 Mov Eax,Esi           ; Pointeur Gauche
 Mov Ebx,Edi           ; Pointeur Droite

Even
@Loop_Sort:
@Loop_Ptr_Forward:
 Mov Ecx,[Eax]                 
 Add Eax,Edx
 Sub Ecx,Ebp                   
 Js @Loop_Ptr_Forward
 Sub Eax,Edx

Even
@Loop_Ptr_BackWard:
 Mov Ecx,Ebp
 Sub Ebx,Edx
 Sub Ecx,[Ebx+08]
 Js @Loop_Ptr_BackWard
 Add Ebx,Edx

 Mov Ecx,Ebx
 Sub Ecx,Eax
 Js @No_Swap_Sort
 Mov Edx,[Eax]
 Mov Ecx,[Ebx]
 Mov [Ebx],Edx
 Mov [Eax],Ecx

 Mov Edx,[Eax+4]
 Mov Ecx,[Ebx+4]
 Mov [Ebx+4],Edx
 Mov [Eax+4],Ecx

 Mov Edx,08
 Add Eax,Edx
 Sub Ebx,Edx
@No_Swap_Sort:

 Mov Ecx,Ebx
 Sub Ecx,Eax
 Jns @Loop_Sort

 Sub Esi,Ebx
 Jns @No_New_Sort1
 Add Esi,Ebx

 Push Eax
 Push Ebx
 Push Esi
 Push Edi
 Mov Edi,Ebx
 Call Recursive_Sort
 Pop Edi
 Pop Esi
 Pop Ebx
 Pop Eax

@No_New_Sort1:

 Sub Eax,Edi
 Jns @No_New_Sort2
 Add Eax,Edi

 Push Eax
 Push Ebx
 Push Esi
 Push Edi
 Mov Esi,Eax
 Call Recursive_Sort
 Pop Edi
 Pop Esi
 Pop Ebx
 Pop Eax
@No_New_Sort2:

Ret
Endp
EndP

Even
Draw_Mesh Proc Near
;****************************************************************************
;*                           D r a w _ M e s h                              *
;****************************************************************************
 Xor Eax,Eax
 Mov Bp,Gs:[Bac_Mesh.M_Nbr_Faces]
 Mov Esi,Gs:[Bac_Mesh.M_Sort_Face]
 Mov Ax,Bp
 Mov Edi,Gs:[Bac_Mesh.M_V2d_Dest]
 Dec Ax
 Shl Eax,03
 Add Esi,Eax

Even
@Loop_Draw_Mesh:
 Push Esi
 Push Edi
 Push Bp

 Mov Esi,[Esi+04]              ; Pointe vers une Face
 Mov Edx,[Esi+06]
 Mov Dword Ptr Cs:[@Put_Color_Mesh+02],Edx

 Xor Eax,Eax           ; Eax =  [X2,Y2]
 Xor Ebx,Ebx           ; Ebx =  [X1,Y1]
 Mov Ax,[Esi+2]        ; Ecx =  [X3,Y3]
 Mov Bx,[Esi+4]        
 Add Eax,Edi
 Xor Ecx,Ecx
 Add Ebx,Edi
 Mov Cx,[Esi]

;=-
 Mov Eax,[Eax]
 Add Ecx,Edi
 Mov Ebx,[Ebx]                 ; X,Y(Swap)
 Mov Ecx,[Ecx]

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Mov Dx,Ax
 Xor Bp,Bp

 Sub Dx,Bx             ; Trie les vertices pour le point inferieur
 Jle @C1_Mesh
 Xor Dx,Dx
 Inc Bp
@C1_Mesh:
 Add Dx,Bx
 
 Sub Dx,Cx
 Jle @C2_Mesh
 Xor Dx,Dx
 Mov Bp,02
@C2_Mesh:
 Add Dx,Cx

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Dec Bp                ; Positionnement du point inferieur
 Jnz @N2_Mesh
 Xchg Eax,Ebx
 Xchg Ebx,Ecx
@N2_Mesh:

 Dec Bp
 Jnz @N3_Mesh
 Xchg Eax,Ecx
 Xchg Ecx,Ebx
@N3_Mesh:

 Sub Bp,479            ; Poly_Limit_Bottom
 Jns @Poly_End_Quit_Mesh

 Mov Bp,Ax             ; Poly_Limit_Left
 And Bp,Bx
 Test Bp,Cx
 Js @Poly_End_Quit_Mesh

 Mov Gs:[Bac_X2Y2],Ebx  
 Mov Gs:[Bac_X3Y3],Ecx 

;=--------------------------------------------------------------------------=
 Mov Dx,04647h                 ; Inc E(di) ; Inc E(si);
 Sub Bx,Ax
 Jns @No_Delta_X_Change_Mesh   ; [X2-X1]
 Neg Bx
 Mov Dl,04Fh                   ; Dec Edi
@No_Delta_X_Change_Mesh:
 Jnz @Auto_CorX1_Mesh          ; Corrige le defaut lorsque la ligne est droite
 Dec Ax
@Auto_CorX1_Mesh:

 Sub Cx,Ax                     ; [X3-X1]
 Jns @No_Delta_X_Change2_Mesh
 Neg Cx
 Mov Dh,04Eh                   ; Dec Esi
@No_Delta_X_Change2_Mesh:
 Jnz @Auto_CorX2_Mesh          ; Corrige le defaut lorsque la ligne est droite
 Inc Ax
@Auto_CorX2_Mesh:

 Mov Byte Ptr Cs:[@Delta_Move_Mesh+1],Dl
 Mov Byte Ptr Cs:[@Delta_Move2_Mesh+1],Dh

 Movsx Esi,Ax                  ; Conserve X1
 Mov Bp,Cx                     ; T u
 Mov Dx,Bx                     ;  a x

 Bswap Eax
 Bswap Ebx
 Bswap Ecx

 Test Bx,Cx                    ; Polygone hors de l'ecran (Superieur)
 Js @Poly_End_Quit_Mesh             ; Les Deux Points Maximal Negatif 

 Sub Bx,Ax                     ; Delta_yYy
 Jnz @No_Top_Left_Flat_Mesh
 Inc Bx
@No_Top_Left_Flat_Mesh:

 Sub Cx,Ax
 Jnz @No_Top_Right_Flat_Mesh
 Inc Cx
@No_Top_Right_Flat_Mesh:

 Movsx Edi,Ax                  ; Y1
 Mov Ax,Cx                     ; Hauteur
 Bswap Eax

 Mov Ax,Bp                     ; Taux
 Mov Bp,Dx                     ; Taux

 Mov Dx,Bx                     ; Hauteur
 Imul Edi,640
 Bswap Edx
 Mov Dx,Bp

 Mov Ebp,Edi
 Mov Edi,Esi

 ;        Hi   Lo
 ; ---------------
 ; Eax : Haut Taux 3-Right
 ; Edx : Haut Taux 2-Left
 ; Ebx : D_X  D_Y  2-Left
 ; Ecx : D_X  D_Y  3-Right
Even
@Line_Main_Loop_Mesh:

 Test Dx,Dx
@Loop_Line_01_Mesh:
 Js @Add_Delta_X1_Mesh
@Delta_Move_Mesh:
 Inc Edi
 Sub Dx,Bx                     ; -Dy
 Jns @Delta_Move_Mesh

@Add_Delta_X1_Mesh:
 Bswap Ebx
 Add Dx,Bx                     ; +Dx
 Bswap Ebx

 Test Ax,Ax
@Loop_Line_02_Mesh:
 Js @Add_Delta_X2_Mesh
@Delta_Move2_Mesh:
 Inc Esi
 Sub Ax,Cx
 Jns @Delta_Move2_Mesh

@Add_Delta_X2_Mesh:
 Bswap Ecx
 Add Ax,Cx
 Bswap Ecx

 Test Ebp,Ebp                  ; Clipping Top
 Js @No_Line_Draw2_Mesh

 Push Esi
 Push Eax
 Push Ecx
 Push Edi

 Mov Eax,Ebp
 Mov Ecx,Esi                   ; Droite
 Sub Eax,480*640               ; Clipping Bottom
 Jns @No_Line_Draw_Mesh            

 Sub Ecx,Edi                   ; Gauche
 Js @No_Line_Draw_Mesh
 Mov Eax,0639d
 Inc Ecx

 Test Esi,Edi                  ; Clipping de Gauche
 Js @No_Line_Draw_Mesh

 Sub Esi,Eax                   ; Clipping Droite
 Js @No_Clip_Right_Mesh
 Sub Ecx,Esi
 Js @No_Line_Draw_Mesh
@No_Clip_Right_Mesh:

 Test Edi,Edi                  ; Clipping de Gauche pour (X2 Negatif)
 Jns @No_Clip_Left_Mesh
 Add Ecx,Edi
 Xor Edi,Edi  
@No_Clip_Left_Mesh:
 
@Put_Color_Mesh:
 Mov Eax,0F0F0F0F0H 

 Add Edi,Ebp                   ; yYy
 Mov Esi,Ecx
 Add Edi,Gs:[Screen.Xms_Ptr]   ; Offset Mem Video

 And Ecx,03h
 Shr Esi,02
 Rep Stos Byte Ptr Es:[Edi]

 Mov Ecx,Esi
 Rep Stos Dword Ptr Es:[Edi]

@No_Line_Draw_Mesh:
 Pop Edi
 Pop Ecx
 Pop Eax
 Pop Esi
@No_Line_Draw2_Mesh:
 Add Ebp,0640d                 ; Saute une ligne

 Bswap Edx
 Bswap Eax

 Dec Dx
 Jz @Next_Line_01_Mesh
@Back_From_Line_01_Mesh:

 Dec Ax
 Jz @Next_Line_02_Mesh

 Bswap Eax
 Bswap Edx
 Jnz @Line_Main_Loop_Mesh

Even
@Next_Line_02_Mesh:                 ; D r o i t e . . .
@Right_Line_Abs_Mesh:

 Push Ebx
 Push Edx
 Mov Ebx,Gs:[Bac_X2Y2]
 Mov Ecx,Gs:[Bac_X3Y3]
 Mov Dl,04Eh

 Sub Cx,Bx
 Jns @No_Inv_NDeltaX1
 Mov Dl,046h
 Neg Cx
@No_Inv_NDeltaX1:
 Inc Cx

 Mov Byte Ptr Cs:[@Delta_Move2_Mesh+1],Dl

 Bswap Eax
 Mov Ax,Cx     ; Taux
 Bswap Ebx
 Bswap Ecx
 Bswap Eax

 Sub Cx,Bx
 Jns @No_Inv_NDeltaY1
 Neg Cx
@No_Inv_NDeltaY1:
 Pop Edx
 Pop Ebx
 Inc Cx
 Mov Ax,Dx     ; Hauteur

 Test Ax,Ax
 Bswap Eax
 Bswap Edx
 Jnz @Line_Main_Loop_Mesh

@Poly_End_Quit_Mesh:
 Pop Bp
 Pop Edi
 Pop Esi
 Sub Esi,08d   ; Moyenne_Z, Pointeur_Face
 Dec Bp
 Jnz @Loop_Draw_Mesh
Ret

Even
@Next_Line_01_Mesh:                 ; G a u c h e . . .
@Left_Line_Abs_Mesh:

 Push Ecx
 Push Eax
 Mov Ebx,Gs:[Bac_X2Y2]
 Mov Ecx,Gs:[Bac_X3Y3]
 Mov Al,04Fh

 Sub Bx,Cx
 Jns @No_Inv_NDeltaX2
 Mov Al,047h
 Neg Bx
@No_Inv_NDeltaX2:
 Inc Bx
 Mov Byte Ptr Cs:[@Delta_Move_Mesh+1],Al

 Bswap Edx               
 Mov Dx,Bx     ; Taux
 Bswap Edx

 Bswap Ebx
 Bswap Ecx

 Sub Bx,Cx
 Jns @No_Inv_NDeltaY2
 Neg Bx
@No_Inv_NDeltaY2:
 Inc Bx
 Pop Eax
 Pop Ecx

 Mov Dx,Ax                    ; Hauteur
 Dec Dx
 Jz @Poly_End_Quit_Mesh
 Inc Dx
 Jns @Back_From_Line_01_Mesh

Ret
EndP

Even
Math_Gps_Mesh Proc Near
;****************************************************************************
;*                       G p s _ M a t h _ M e s h                          *
;****************************************************************************
;  -=-=-=-=-=-=-=-=-=-=-
; -= Rotation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-
 Mov Edi,Gs:[World_Mesh.W_Sort_Face]
 Mov Si,Offset Table_3d_Objects
 Add Edi,(W3d_Face)*08d

 Xor Eax,Eax
 Xor Ebx,Ebx
 Mov Ax,Gs
 Mov Dl,Byte Ptr Gs:[Nbr_Objects]
 Shl Eax,04
 Mov Bx,(Offset Table_3d_Objects)
 Add Eax,Ebx
 Sub Eax,06

Even
@Loop_All_Objects:
 Push Dx
 Mov Bp,Gs:[Si+02]     ; Offset du Mesh
 Push Eax
 Push Edi
 Push Si
 Push Bp
 Mov Eax,Dword Ptr Gs:[Bp.M_X_Rot]     ; X_Rot, Y_Rot, Z_Rot, Temp
 Mov Bp,Offset Sinus_3d
 Mov Cx,0510d                  ; 256*02 du au Shiftage

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe xXx
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Al
 Xor Bh,Bh
 Add Bx,Bx             ; Adresse Double
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_X],Edi
 Mov Gs:[Rot_CoSin_X],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe yYy
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Ah
 Xor Bh,Bh
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Y],Edi
 Mov Gs:[Rot_CoSin_Y],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe zZz
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Bswap Eax
 Xor Bh,Bh
 Mov Bl,Ah
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Z],Edi
 Mov Gs:[Rot_CoSin_Z],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Effectue les calculs de rotation et de translation
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Pop Bp
 Push Bp
 Mov Eax,[Bp.M_X_Pos]     ; xXx
 Mov Ebx,[Bp.M_Y_Pos]     ; yYy
 Mov Ecx,[Bp.M_Z_Pos]     ; zZz

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_Y = ( Y*Sinus[Angle+64] - Z*Sinus[Angle] )
; Temp_Z = ( Y*Sinus[Angle] + Z*Sinus[Angle+64] )
; Y = Temp_Y Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_X]
 Mov Ebp,Gs:[Rot_CoSin_X]

 Mov Edi,Ebx   ; Y
 Mov Esi,Ecx   ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Ebx
 Imul Ebp,Ecx

 Sub Edi,Esi
 Add Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Ecx,Ebp
 Mov Ebx,Edi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] + Z*Sinus[Angle] )
; Temp_Z = ( Z*Sinus[Angle+64] - X*Sinus[Angle] )
; X = Temp_X Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Y]
 Mov Ebp,Gs:[Rot_CoSin_Y]

 Mov Edi,Eax     ; X
 Mov Esi,Ecx     ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Ebp,Ecx
 Imul Edx,Eax

 Add Edi,Esi
 Sub Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Eax,Edi
 Mov Ecx,Ebp

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] - Y*Sinus[Angle] )
; Temp_Y = ( X*Sinus[Angle] + Y*Sinus[Angle+64] )
; X = Temp_X Div 256
; Y = Temp_Y Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Z]
 Mov Ebp,Gs:[Rot_CoSin_Z]

 Mov Edi,Eax     ; X
 Mov Esi,Ebx     ; Y

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Eax
 Imul Ebp,Ebx

 Sub Edi,Esi
 Add Edx,Ebp

 Sar Edi,08
 Sar Edx,08

;  -=-=-=-=-=-=-=-=-=-=-=-
; -= Translation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-=-
 Pop Bp
 Add Edi,Gs:[Bp.M_X_Pos]
 Add Edx,Gs:[Bp.M_Y_Pos]
 Add Ecx,Gs:[Bp.M_Z_Pos]
 Push Bp
 Push Edi
 Push Edx
 Push Ecx

;  -=-=-=-=-=-=-=-=-=-=-
; -= Rotation_3d. . . =-
;  -=-=-=-=-=-=-=-=-=-=-
 Mov Eax,Dword Ptr Gs:[World_Mesh.W_X_Rot]     ; X_Rot, Y_Rot, Z_Rot, Temp
 Mov Bp,Offset Sinus_3d
 Mov Cx,0510d                  ; 256*02 du au Shiftage

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe xXx
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Al
 Xor Bh,Bh
 Add Bx,Bx             ; Adresse Double
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_X],Edi
 Mov Gs:[Rot_CoSin_X],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe yYy
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Bl,Ah
 Xor Bh,Bh
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Y],Edi
 Mov Gs:[Rot_CoSin_Y],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Calcule la valeur du Sinus et Cosinus de l'axe zZz
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Bswap Eax
 Xor Bh,Bh
 Mov Bl,Ah
 Add Bx,Bx
 Add Bx,Bp
 Mov Di,Gs:[Bx]        ; Lit le Sinus
 Mov Si,Gs:[Bx+0128d]  ; Lit le Cosinus

 Movsx Edi,Di
 Movsx Esi,Si
 Mov Gs:[Rot_Sinus_Z],Edi
 Mov Gs:[Rot_CoSin_Z],Esi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Effectue les calculs de rotation et de translation
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Pop Ecx       ; zZz
 Pop Ebx       ; yYy
 Pop Eax       ; xXx
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_Y = ( Y*Sinus[Angle+64] - Z*Sinus[Angle] )
; Temp_Z = ( Y*Sinus[Angle] + Z*Sinus[Angle+64] )
; Y = Temp_Y Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_X]
 Mov Ebp,Gs:[Rot_CoSin_X]

 Mov Edi,Ebx   ; Y
 Mov Esi,Ecx   ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Edx,Ebx
 Imul Ebp,Ecx

 Sub Edi,Esi
 Add Ebp,Edx

 Sar Edi,08
 Sar Ebp,08

 Mov Ecx,Ebp
 Mov Ebx,Edi

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
; Temp_X = ( X*Sinus[Angle+64] + Z*Sinus[Angle] )
; Temp_Z = ( Z*Sinus[Angle+64] - X*Sinus[Angle] )
; X = Temp_X Div 256
; Z = Temp_Z Div 256
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 Mov Edx,Gs:[Rot_Sinus_Y]
 Mov Ebp,Gs:[Rot_CoSin_Y]

 Mov Edi,Eax     ; X
 Mov Esi,Ecx     ; Z

 Imul Edi,Ebp
 Imul Esi,Edx

 Imul Ebp,Ecx
 Imul Edx,Eax

 Add Edi,Esi
 Sub Ebp,Edx

 Sar Edi,08
 Sar Ebp,08
 Mov Ebx,Ebp
 Pop Bp
 Pop Si
 Pop Edi
 Pop Eax
 Pop Dx
 Mov [Edi],Ebx
 Mov [Edi+04],Eax
 Add Si,04
 Add Edi,08d
 Add Eax,04d
 Dec Dl
 Jnz @Loop_All_Objects
Ret
EndP

EFrame Dd EFrame_Size*00d,EFrame_Size*01d,EFrame_Size*02d,EFrame_Size*03d
       Dd EFrame_Size*04d,EFrame_Size*05d,EFrame_Size*06d,EFrame_Size*07d
       Dd EFrame_Size*08d,EFrame_Size*09d,EFrame_Size*10d,EFrame_Size*11d
       Dd EFrame_Size*12d,EFrame_Size*13d,EFrame_Size*14d,EFrame_Size*15d

Even
Show_All_Item Proc Near
;****************************************************************************
;*                        S h o w _ A l l _ I t e m                         *
;****************************************************************************
;-----= Energie du Joueur =---------
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[IcoEne.Xms_Ptr]
 Mov Al,Gs:[Life]
 Mov Bx,Offset L1R
 Mov Ah,03
 Mov Ebp,04
 Add Edi,640*380d

Even
@Loop_Show_Energy:
 Push Ax
 Push Bx
 Push Esi
 Push Edi

 Test Al,01
 Jnz @No_Lost_Energy
 Add Esi,Energie_Vide
@No_Lost_Energy:

 Xor Ah,Ah
 Mov Bx,Word Ptr Gs:[Bx]
 Mov Al,Bh
 Xor Bh,Bh
 And Bl,0Fh
 Shl Bl,02
 Add Bx,Offset EFrame
 Add Esi,Cs:[Bx]

 Add Ax,Ax
 Add Ax,Offset Sinus_3D
 Mov Bx,Ax
 Movsx Eax,Word Ptr Gs:[Bx]
 Sar Eax,04
 Imul Eax,640
 Add Edi,Eax

 Mov Dx,024d*256+096d
 Mov Ebx,0640d-096d
Even
@Loop_Y_Energy:
 Mov Cl,Dh
Even
@Loop_X_Energy:
 Mov Eax,[Esi]

 Test Al,Al
 Jz @No_Draw_FPixel
 Mov [Edi],Al
@No_Draw_FPixel:

 Test Ah,Ah
 Jz @No_Draw_SPixel
 Mov [Edi+1],Ah
@No_Draw_SPixel:

 Bswap Eax

 Test Ah,Ah
 Jz @No_Draw_TPixel
 Mov [Edi+2],Ah
@No_Draw_TPixel:

 Test Al,Al
 Jz @No_Draw_QPixel
 Mov [Edi+3],Al
@No_Draw_QPixel:

 Add Esi,Ebp
 Add Edi,Ebp
 Dec Cl
 Jnz @Loop_X_Energy
 Add Edi,Ebx
 Dec Dl
 Jnz @Loop_Y_Energy

 Pop Edi
 Pop Esi
 Pop Bx
 Pop Ax
 
 Add Edi,080d
 Inc Bx
 Shr Al,01
 Inc Bx
 Dec Ah
 Jnz @Loop_Show_Energy

 Mov Eax,Dword Ptr Gs:[L1R]
 Mov Bx,Word Ptr Gs:[L3R]
 Add Eax,07010801h
 Add Bx,0801h
 Mov Dword Ptr Gs:[L1R],Eax
 Mov Word Ptr Gs:[L3R],Bx

;----= Titre du Jeu =----

 Mov Esi,Gs:[TitleK.Xms_Ptr]
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Ebp,0640d-0284d
 Mov Dx,(71*256) + 47
 Mov Ebx,04
 Add Edi,178+(640*00)

Even
@Loop_Y_Title:
 Mov Cl,Dh
Even
@Loop_X_Title:
 Mov Eax,[Esi]

 Test Al,Al
 Jz @No_Draw_FPixel2
 Mov [Edi],Al
@No_Draw_FPixel2:

 Test Ah,Ah
 Jz @No_Draw_SPixel2
 Mov [Edi+1],Ah
@No_Draw_SPixel2:

 Bswap Eax

 Test Ah,Ah
 Jz @No_Draw_TPixel2
 Mov [Edi+2],Ah
@No_Draw_TPixel2:

 Test Al,Al
 Jz @No_Draw_QPixel2
 Mov [Edi+3],Al
@No_Draw_QPixel2:

 Add Esi,Ebx
 Add Edi,Ebx
 Dec Cl
 Jnz @Loop_X_Title
 Add Edi,Ebp
 Dec Dl
 Jnz @Loop_Y_Title

;----= Radar du Jeu =----

 Mov Esi,Gs:[Radar.Xms_Ptr]
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Ebp,0640d-0156d
 Mov Dx,(39*256) + 156d
 Mov Ebx,04
 Add Edi,(640-156)+(480-156)*640

Even
@Loop_Y_Radar:
 Mov Cl,Dh
Even
@Loop_X_Radar:
 Mov Eax,[Esi]

 Test Al,Al
 Jz @No_Draw_FPixel3
 Mov [Edi],Al
@No_Draw_FPixel3:

 Test Ah,Ah
 Jz @No_Draw_SPixel3
 Mov [Edi+1],Ah
@No_Draw_SPixel3:

 Bswap Eax

 Test Ah,Ah
 Jz @No_Draw_TPixel3
 Mov [Edi+2],Ah
@No_Draw_TPixel3:

 Test Al,Al
 Jz @No_Draw_QPixel3 
 Mov [Edi+3],Al
@No_Draw_QPixel3:

 Add Esi,Ebx
 Add Edi,Ebx
 Dec Cl
 Jnz @Loop_X_Radar
 Add Edi,Ebp
 Dec Dl
 Jnz @Loop_Y_Radar

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Add Edi,(640-128)+(480-128)*640
 Mov Edx,011110000111100001111000011110000b
 Mov Bx,(16*256)+128

 Mov Ebp,08
@Loop_Tr1:
 Mov Cl,Bh
Even
@Loop_Tr2:
 Mov Eax,[Edi]
 Mov Esi,[Edi+4]
 Or Eax,Edx
 Or Esi,Edx
 Mov [Edi],Eax
 Mov [Edi+04],Esi
 Add Edi,Ebp
 Dec Cl
 Jnz @Loop_Tr2
 Add Edi,640-128
 Dec Bl
 Jnz @Loop_Tr1

;--= Block sur la map =--
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Edx,0640d
 Add Edi,0225792d
 Mov Cx,016d*0256d+016d
 Mov Ebp,Edi
 Mov Bx,Offset Block_Gps
 Mov Si,016d
@LBlock:
 Add Edi,Cs:[Bx]
 Mov Eax,Cs:[Bx+04]

@LBlock_Mapy:
 Mov [Edi],Eax
 Mov [Edi+04h],Eax
 Mov [Edi+08h],Eax
 Mov [Edi+0Ch],Eax
 Bswap Eax
 Add Edi,Edx 
 Dec Cl
 Jnz @LBlock_Mapy
 Mov Edi,Ebp
 Mov Cl,Ch
 Add Bx,08d
 Dec Si
 Jnz @LBlock

;=- Gps Du Joueur,Des Enemies, Energies, Portal, Items

 Mov Si,Offset Table_3d_Objects + 02d 
 Mov Cx,Const_Nbr_Objects
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
Even
@Loop_All_Gps_Objects:
 Push Si
 Push Cx
 Push Edi
 Mov Ax,Gs:[Si-2]
 Mov Si,Gs:[Si]
 Push Ax

 Add Edi,0225792d
 Xor Edx,Edx
 Mov Eax,Ebp
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx

 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Imul Eax,640
 Add Edi,Eax

 Pop Ax
 Test Ah,01
 Jnz @No_Show_Gps
 And Ah,0F0h
 Dec Ah
 Mov Byte Ptr [Edi],Ah
 Sub Ah,0Fh
 Mov Byte Ptr [Edi+1],Ah
 Mov Byte Ptr [Edi-640],Ah
 Mov Byte Ptr [Edi-1],Ah
 Mov Byte Ptr [Edi+640],Ah
@No_Show_Gps:
 Pop Edi
 Pop Cx
 Pop Si
 Add Si,04d
 Dec Cx
 Jnz @Loop_All_Gps_Objects
Ret
EndP

Blck_Size Equ 010240d

Block_Gps Dd 00d,0B0BFB0BFh
          Dd 0112d,0B0BFB0BFh
          Dd 32+Blck_Size,0505F505Fh
          Dd 64+Blck_Size,0707F707Fh
          Dd 80+Blck_Size,0D0DFD0DFh
          Dd 80+Blck_Size*2,0505F505Fh
          Dd 96+Blck_Size*2,0303F303Fh
          Dd Blck_Size*3,0F0FFF0FFh
          Dd 32+Blck_Size*3,0B0BFB0BFh
          Dd 48+Blck_Size*4,0909F909Fh
          Dd 80+Blck_Size*4,0707F707Fh
          Dd 112+Blck_Size*4,0D0DFD0DFh
          Dd 16+Blck_Size*6,0B0BFB0BFh
          Dd 48+Blck_Size*6,0B0BFB0BFh
          Dd Blck_Size*7,0B0BFB0BFh
          Dd 112+Blck_Size*7,0B0BFB0BFh

Init_Blck_Size Equ 02048d

Init_Block_Gps Dd 00d
               Dd 0112d
               Dd 32+Init_Blck_Size
               Dd 64+Init_Blck_Size
               Dd 80+Init_Blck_Size
               Dd 80+Init_Blck_Size*2
               Dd 96+Init_Blck_Size*2
               Dd Init_Blck_Size*3
               Dd 32+Init_Blck_Size*3
               Dd 48+Init_Blck_Size*4
               Dd 80+Init_Blck_Size*4
               Dd 112+Init_Blck_Size*4
               Dd 16+Init_Blck_Size*6
               Dd 48+Init_Blck_Size*6
               Dd Init_Blck_Size*7
               Dd 112+Init_Blck_Size*7

Key_Proc Dw Offset @No_Key,Offset @Key_72,Offset @Key_75,Offset @Key_7275
         Dw Offset @Key_77,Offset @Key_7277,Offset @No_Key,Offset @Key_72
         Dw Offset @Key_80,Offset @No_Key,Offset @Key_7580,Offset @Key_75
         Dw Offset @Key_7780,Offset @Key_77,Offset @Key_80,@No_Key

Even
Control_Player Proc Near
;****************************************************************************
;*                      C o n t r o l _ P l a y e r                         *
;****************************************************************************
 Mov Dl,Gs:[Life]
 Test Dl,Dl
 Jz @Key_Frame

 Mov Eax,Gs:[Frame]
 Mov Ecx,Gs:[Pos]
 Mov Dl,Gs:[Key_Hit]
 Test Eax,Eax
 Jnz @No_Attack_Key
 Mov Bl,Gs:[Key_Table[29]]
 Test Bl,Bl
 Jnz @No_Key_029d
 Mov Eax,016d
 Mov Ecx,017d
 Or Dl,01h
@No_Key_029d:

 Mov Bl,Gs:[Key_Table[56]]
 Test Bl,Bl
 Jnz @No_Key_056d
 Mov Ecx,049d
 Mov Eax,016d
 Or Dl,01h
@No_Key_056d:
@No_Attack_Key:
 Mov Gs:[Key_Hit],Dl
 Mov Dword Ptr Gs:[Pos],Ecx
 Mov Dword Ptr Gs:[Frame],Eax

 Xor Eax,Eax
 Xor Ebx,Ebx
 Test Dl,Dl
 Jnz @Key_Frame

 Mov Eax,Dword Ptr Gs:[Key_Table[72]]  ; 72 . . 75  -=[Left,Right]=-
 Mov Ecx,Dword Ptr Gs:[Key_Table[77]]  ; 77 . . 80   -=[Up,Down]=-
 Xor Edx,Edx
 Xor Ebx,Ebx
 Mov Bl,Al     ; 72
 Bswap Eax
 Add Bx,Bx
 Mov Dx,Cs
 Or Bl,Al      ; 75
 Add Bx,Bx
 Or Bl,Cl      ; 77
 Bswap Ecx
 Add Bx,Bx
 Or Bl,Cl      ; 80
 Mov Gs:[Bac_Direct],Bl

 Add Bx,Bx
 Add Bx,Offset Key_Proc
 Shl Edx,04
 Add Edx,Ebx
 Jmp [Edx]
@Back_Key:
 Movsx Eax,Word Ptr Gs:[Bp]            ; yYy Sin
 Movsx Ebx,Word Ptr Gs:[Bp+(64*2)]     ; xXx Cos
 Sar Eax,02
 Sar Ebx,02
 Add Gs:[HeroStr.M_Y_Pos],Eax
 Add Gs:[HeroStr.M_X_Pos],Ebx

 Push Eax
 Push Ebx
 Mov Edi,Gs:[Radar.Xms_Ptr]
 Mov Ecx,012600d
 Add Edi,(024336d+016384d)

 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Xor Edx,Edx
 Mov Eax,Ebp
 Sub Eax,Gs:[HeroStr.M_X_Pos]
 Div Ebx

 Mov Edx,Dword Ptr Gs:[HeroStr.M_X_Pos]
 Sub Edx,Ecx
 Js @No_Bound_xXx
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[HeroStr.M_X_Pos],Edx
@No_Bound_xXx:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @NB_xXx        ; Right
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[HeroStr.M_X_Pos],Edx
@Nb_xXx:

 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[HeroStr.M_Y_Pos]
 Div Ebx

 Mov Edx,Dword Ptr Gs:[HeroStr.M_Y_Pos]
 Sub Edx,Ecx
 Js @No_Bound_yYy
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[HeroStr.M_Y_Pos],Edx
@No_Bound_yYy:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @NB_yYy        ; Right
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[HeroStr.M_Y_Pos],Edx
@Nb_yYy:

 Shl Eax,07
 Add Edi,Eax
 Mov Gs:[D_Gps_Pos],Edi
 Mov Cl,[Edi]
 Pop Ebx
 Pop Eax
 Test Cl,Cl
 Jz @No_Block

;=- Detection de Collision =-
 Inc Cl
 Jnz @No_Hit_Block
 Sub Gs:[HeroStr.M_X_Pos],Ebx
 Sub Gs:[HeroStr.M_Y_Pos],Eax
 Jmp @No_Block
@No_Hit_Block:
 Dec Cl

 Mov Si,Offset Table_3d_Objects + 04d  ; Enleve l'Hero
 Mov Dl,Const_Nbr_Objects-1
 Mov Bp,04d

Even
@Loop_Detection_Objects:
 Mov Al,Gs:[Si+1]
 Sub Al,Cl
 Jnz @No_Hit

 Shr Cl,05
 Xor Edx,Edx
 Xor Ebx,Ebx
 Mov Dx,Cs
 Dec Cl
 Mov Bl,Cl
 Add Bx,Bx
 Add Bx,Offset C_T
 Shl Edx,04
 Add Edx,Ebx
 Jmp [Edx]

@No_Hit:
 Add Si,Bp
 Dec Dl
 Jnz @Loop_Detection_Objects
@End_Of_Detection:
@No_Block:

 Mov Eax,Gs:[Frame]    ; Pour un Meilleur Controle, Durant l'animation,
 Test Eax,Eax          ; Le joueur peut se promener.
 Jnz @No_New_Frame
 Mov Dword Ptr Gs:[Pos],1
 Mov Eax,016d
@No_New_Frame:
 Mov Dword Ptr Gs:[Frame],Eax
 Jmp @Key_Frame

@No_Key:
 Mov Dword Ptr Gs:[Frame],00h  ; Arreter l'Animation
@Key_Frame:
 Push Eax
 Push Ebx
 Mov Edi,Gs:[Radar.Xms_Ptr]
 Mov Ecx,012600d
 Add Edi,(024336d+016384d)

 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Xor Edx,Edx
 Mov Eax,Ebp
 Sub Eax,Gs:[HeroStr.M_X_Pos]
 Div Ebx

 Mov Edx,Dword Ptr Gs:[HeroStr.M_X_Pos]
 Sub Edx,Ecx
 Js @No_Bound_xXxz
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[HeroStr.M_X_Pos],Edx
@No_Bound_xXxz:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @NB_xXxz        ; Right
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[HeroStr.M_X_Pos],Edx
@Nb_xXxz:

 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[HeroStr.M_Y_Pos]
 Div Ebx

 Mov Edx,Dword Ptr Gs:[HeroStr.M_Y_Pos]
 Sub Edx,Ecx
 Js @No_Bound_yYyz
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[HeroStr.M_Y_Pos],Edx
@No_Bound_yYyz:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @NB_yYyz        ; Right
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[HeroStr.M_Y_Pos],Edx
@Nb_yYyz:

 Shl Eax,07
 Add Edi,Eax
 Mov Cl,[Edi]
 Pop Ebx
 Pop Eax
 Test Cl,Cl
 Jz @No_Blockz

;=- Detection de Collision =-
 Inc Cl
 Jnz @No_Hit_Blockz
 Sub Gs:[HeroStr.M_X_Pos],Ebx
 Sub Gs:[HeroStr.M_Y_Pos],Eax
 Jmp @No_Blockz
@No_Hit_Blockz:
 Dec Cl

 Mov Si,Offset Table_3d_Objects + 04d  ; Enleve l'Hero
 Mov Dl,Const_Nbr_Objects-1
 Mov Bp,04d

Even
@Loop_Detection_Objectsz:
 Mov Al,Gs:[Si+1]
 Sub Al,Cl
 Jnz @No_Hitz

 Shr Cl,05
 Xor Edx,Edx
 Xor Ebx,Ebx
 Mov Dx,Cs
 Dec Cl
 Mov Bl,Cl
 Add Bx,Bx
 Add Bx,Offset C_T
 Shl Edx,04
 Add Edx,Ebx
 Jmp [Edx]

@No_Hitz:
 Add Si,Bp
 Dec Dl
 Jnz @Loop_Detection_Objectsz
@End_Of_Detectionz:
@No_Blockz:

 Mov Dl,Gs:[Key_Hit]
 Mov Eax,Gs:[Frame]
 Test Eax,Eax
 Jz @End_Frame
 Xor Dl,01
 Dec Eax
@End_Frame:
 Xor Dl,01
 Mov Gs:[Frame],Eax
 Mov Gs:[Key_Hit],Dl

 Mov Ebx,Gs:[Frame]
 Mov Esi,Gs:[HeroSp.Xms_Ptr]
 Mov Ecx,Gs:[Pos]
 Test Ebx,Ebx
 Jz @No_Anim
 Xor Ebx,015d
@No_Anim:
 Add Ecx,Ebx
 Imul Ecx,012372d
 Add Esi,Ecx
 Mov Edi,Gs:[HeroStr.M_V3d_Src]
 Mov Ecx,(012372d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
Ret

@Key_72:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],00h
 Mov Al,0192d
 Add Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

@Key_75:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],040h
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Mov Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

@Key_7275:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],020h
 Mov Al,0224d
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Add Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

@Key_77:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],0C0h
 Mov Al,0128d
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Add Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

@Key_7277:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],0E0h
 Mov Al,0160d
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Add Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

@Key_80:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],080h
 Mov Al,064d
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Add Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

@Key_7580:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],060h
 Mov Al,0032d
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Add Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

@Key_7780:
 Mov Al,Gs:[Bac_Direct]
 Mov Gs:[Direction],Al
 Mov Byte Ptr Gs:[HeroStr.M_Z_Rot],0A0h
 Mov Al,0096d
 Mov Bp,Offset Sinus_3d
 Xor Ah,Ah
 Add Al,Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Add Ax,Ax
 Add Bp,Ax
 Jmp @Back_Key

C_T  Dw Offset @Contact_Teleport,Offset @Contact_EnemyC,Offset @Contact_EnemyB
     Dw Offset @Contact_EnemyA,Offset @End_Of_Detection,Offset @Contact_Crest
     Dw Offset @Contact_Energy

@Contact_Crest:
 Or Byte Ptr Gs:[Si+1],01h
 Jmp @End_Of_Detection

@Contact_Energy:
 Mov Bl,01
 Mov Al,Gs:[Life]
 Add Al,Al
 Or Al,Bl
 Or Byte Ptr Gs:[Si+1],Bl
 And Al,07h
 Mov Gs:[Life],Al
 Jmp @End_Of_Detection

@Contact_EnemyA:
 Mov Al,Gs:[Life]
 Shr Al,01
 Mov Gs:[Life],Al
 Or Byte Ptr Gs:[Si+1],01h
 Test Al,Al
 Jz @Player_Die
 Jmp @End_Of_Detection

@Contact_EnemyB:
 Mov Al,Gs:[Life]
 Shr Al,01
 Mov Gs:[Life],Al
 Or Byte Ptr Gs:[Si+1],01h
 Test Al,Al
 Jz @Player_Die
 Jmp @End_Of_Detection

@Contact_EnemyC:
 Mov Al,Gs:[Life]
 Shr Al,01
 Mov Gs:[Life],Al
 Or Byte Ptr Gs:[Si+1],01h
 Test Al,Al
 Jz @Player_Die
 Jmp @End_Of_Detection

@Contact_Teleport:
 Call Clear
 Hero_Walk Equ 015d*04d
 Mov Dword Ptr Gs:[Dead_Frame],Hero_Walk
 Mov Dword Ptr Gs:[Frame],016d
 Mov Dword Ptr Gs:[Pos],01d
 Or Byte Ptr Gs:[Si+1],01h
 Mov Eax,Dword Ptr Gs:[HeroStr.M_X_Rot]
 Mov Al,040h
 Mov Ah,-060h
 Bswap Eax
 Xor Ah,Ah
 Bswap Eax
 Mov Dword Ptr Gs:[HeroStr.M_X_Rot],Eax
 Jmp @End_Of_Detection
EndP

@Player_Die:
 Call Clear
 Mov Dword Ptr Gs:[Dead_Frame],016d*04d
 Mov Dword Ptr Gs:[Frame],016d
 Mov Dword Ptr Gs:[Pos],034d

 Xor Ebx,Ebx
 Mov Gs:[World_Mesh.W_X_Cam],Ebx
 Mov Gs:[World_Mesh.W_Y_Cam],Ebx
 Mov Gs:[World_Mesh.W_Z_Cam],Ebx
 Mov Gs:[HeroStr.M_X_Pos],Ebx
 Mov Gs:[World_Mesh.W_X_Pos],Ebx
 Mov Gs:[HeroStr.M_Y_Pos],Ebx
 Mov Gs:[HeroStr.M_Z_Pos],Ebx
 Mov Gs:[World_Mesh.W_Y_Pos],Ebx
 Mov Dword ptr Gs:[World_Mesh.W_X_Rot],Ebx
 Mov Edx,01024d
 Mov Gs:[World_Mesh.W_Z_Pos],Edx

 Mov Eax,Dword Ptr Gs:[HeroStr.M_X_Rot]
 Mov Al,040h
 Mov Ah,-060h
 Bswap Eax
 Xor Ah,Ah
 Bswap Eax
 Mov Dword Ptr Gs:[HeroStr.M_X_Rot],Eax
 Jmp @End_Of_Detection

Table_Ai Dw Offset @Technik_01,Offset @Technik_02,Offset @Technik_03
         Dw Offset @Technik_04,Offset @Technik_05,Offset @Technik_06 
Even
Control_Objects Proc Near
;****************************************************************************
;*                      C o n t r o l _ O b j e c t s                       *
;****************************************************************************
;=- Copie de la Map
 Mov Esi,Gs:[Radar.Xms_Ptr]
 Add Esi,024336d
 Mov Edi,Esi
 Add Edi,016384d
 Mov Ecx,016384d/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

;=-
 Mov Si,Offset Table_3d_Objects + 06d
 Mov Cx,Const_Nbr_Objects-1
 Mov Bp,Offset Table_Ai
 Mov Edi,Gs:[Radar.Xms_Ptr]
 Add Edi,(024336d+016384d)
Even
@Loop_All_Ai_Objects:
 Push Edi
 Push Si
 Push Cx
 Push Bp

 Mov Cl,Gs:[Si-01]
 Test Cl,01h
 Jnz @Back_Ai

 Mov Si,Gs:[Si]
 Xor Ah,Ah
 Mov Al,Gs:[Si.M_Ia]
 Add Ax,Ax
 Mov Bx,Bp
 Add Bx,Ax
 Jmp Cs:[Bx]

@Back_Ai:
 Pop Bp
 Pop Cx
 Pop Si
 Pop Edi
 Add Si,04
 Dec Cx
 Jnz @Loop_All_Ai_Objects

; -= Les Positionnes dans le Gps_Buffers

Ret
@Technik_01:
 Jmp @Back_Ai

@Technik_02:   ; Crest
 Mov Eax,Dword Ptr Gs:[Si.M_X_Rot]
 Mov Ebx,Dword Ptr Gs:[Si.M_X_Inc_Rot]  ; Les ++

 Add Ax,Bx
 Bswap Eax
 Bswap Ebx
 Add Ah,Bh
 Bswap Eax
 Mov Dword Ptr Gs:[Si.M_X_Rot],Eax

Even
@Sim_With_Crest:
 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d

 Xor Edx,Edx
 Mov Eax,Ebp
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx

 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Shl Eax,07
 Add Edi,Eax
 Mov [Edi],Cl
 Jmp @Back_Ai

@Technik_03:   ; Energy
 Mov Al,Gs:[Si.M_Z_Rot]
 Sub Al,05
 Mov Gs:[Si.M_Z_Rot],Al

 Mov Eax,Dword Ptr Gs:[Si.M_X_Rot]
 Mov Ebx,Dword Ptr Gs:[Si.M_X_Inc_Rot]  ; Les ++
 Jmp @Sim_With_Crest

@Technik_04:   ; Ennemy_A1
 Push Cx
 Mov Al,Gs:[Si.M_Z_Rot]
 Sub Al,03 
 Mov Gs:[Si.M_Z_Rot],Al

 Mov Eax,Gs:[HeroStr.M_X_Pos]
 Mov Ebx,Gs:[HeroStr.M_Y_Pos]
 Mov Ecx,Gs:[Si.M_X_Pos]
 Mov Edx,Gs:[Si.M_Y_Pos]
 Push Ecx
 Push Edx
 Sub Eax,Ecx
 Jns @No_T4_Abs1
 Neg Eax
@No_T4_Abs1:

 Sub Ebx,Edx
 Jns @No_T4_Abs2
 Neg Ebx
@No_T4_Abs2:
 Add Eax,Ebx
 Rcr Eax,01

 Sub Eax,02048d        ; Seek
 Jns @No_Seek_T4
 Mov Eax,Gs:[HeroStr.M_X_Pos]
 Mov Ebx,Gs:[HeroStr.M_Y_Pos]
 Mov Ecx,Gs:[Si.M_X_Pos]
 Mov Edx,Gs:[Si.M_Y_Pos]

 EnemyA_Speed Equ 040d         ; (032d+048d)/02d
 Sub Eax,Ecx
 Js @NT4_X
 Add Ecx,02d*EnemyA_Speed
 Neg Eax
@NT4_X:
 Sub Ecx,EnemyA_Speed
 Neg Eax

 Sub Eax,EnemyA_Speed
 Jns @N1_T4
 Mov Eax,Gs:[HeroStr.M_X_Pos]
 Add Eax,Gs:[Si.M_X_Pos]
 Rcr Eax,01
 Mov Gs:[Si.M_X_Pos],Eax
@N1_T4:

 Sub Ebx,Edx
 Js @NT4_Y
 Add Edx,02d*EnemyA_Speed
 Neg Ebx
@NT4_Y:
 Sub Edx,EnemyA_Speed
 Neg Ebx
@No_Seek_T4:

 Sub Ebx,EnemyA_Speed
 Jns @N2_T4
 Mov Ebx,Gs:[HeroStr.M_Y_Pos]
 Add Ebx,Gs:[Si.M_Y_Pos]
 Rcr Ebx,01
 Mov Gs:[Si.M_Y_Pos],Ebx
@N2_T4:

 Mov Ax,Gs:[Si.M_Ia_Move]
 Dec Ax
 Jnz @NoChange_Move_T4
 Add Ax,Cx
 Add Ax,Dx
 Add Ax,Fs:[040h*016d+06Ch]    ; Random (24 heures = 0)
 Shr Ax,02

 Test Ax,Ax
 Jnz @Nc_M_T4
 Mov Ax,0100h
@Nc_M_T4:

 Bswap Eax
 Add Ax,Cx
 Sub Ax,Bx
 Sub Ax,Word Ptr Gs:[HeroStr.M_X_Pos]
 Add Ax,Word Ptr Gs:[HeroStr.M_Y_Pos]
 Add Ax,Fs:[040h*016d+06Ch]    ; Random (24 heures = 0)
 Mov Gs:[Si.M_Ia_Move_Const],Ax
 Bswap Eax
@NoChange_Move_T4:
 Mov Gs:[Si.M_Ia_Move],Ax

 Mov Bp,Offset Sinus_3d
 Mov Bl,Ah
 Xor Ah,Ah
 Xor Bh,Bh
 Add Ax,Ax
 Add Bx,Bx
 Add Bx,Bp
 Add Bp,Ax

 Movsx Eax,Word Ptr Gs:[Bp]
 Movsx Ebx,Word Ptr Gs:[Bx]
 Sar Eax,03
 Sar Ebx,03
 Sub Ecx,Eax
 Add Edx,Ebx

 Mov Ax,Gs:[Si.M_Ia_Move_Const]
 Mov Bl,Ah
 Movsx Eax,Al
 Movsx Ebx,Bl
 Sar Eax,02
 Sar Ebx,02
 Add Ecx,Eax
 Add Edx,Ebx
 Mov Gs:[Si.M_X_Pos],Ecx
 Mov Gs:[Si.M_Y_Pos],Edx

 Mov Eax,Gs:[Si.M_Z_Inc_Pos]
 Mov Bx,Offset Sinus_3d
 Mov Dl,Gs:[Si.M_Ia_Var_TzZz]
 Add Dl,05
 Mov Gs:[Si.M_Ia_Var_TzZz],Dl
 Xor Dh,Dh
 Add Dx,Dx
 Add Bx,Dx
 Movsx Ebx,Word Ptr Gs:[Bx]
 Add Eax,Ebx
 Mov Gs:[Si.M_Z_Pos],Eax

 Mov Ecx,012600d
 Mov Edx,Dword Ptr Gs:[Si.M_X_Pos]
 Sub Edx,Ecx
 Js @T4_No_Bound_xXx   ; Left
 Push Ax
 Mov Ax,Gs:[Si.M_Ia_Move_Const]
 Add Ax,Fs:[040h*016d+06Ch]    ; Random (24 heures = 0)
 Mov Gs:[Si.M_Ia_Move_Const],Ax
 Pop Ax
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[Si.M_X_Pos],Edx
 Xor Edx,Edx
@T4_No_Bound_xXx:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @T4_NB_xXx        ; Right
 Push Ax
 Mov Ax,Gs:[Si.M_Ia_Move_Const]
 Add Ax,Fs:[040h*016d+06Ch]    ; Random (24 heures = 0)
 Mov Gs:[Si.M_Ia_Move_Const],Ax
 Pop Ax
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[Si.M_X_Pos],Edx
@T4_Nb_xXx:

 Mov Edx,Dword Ptr Gs:[Si.M_Y_Pos]
 Sub Edx,Ecx
 Js @T4_No_Bound_yYy
 Push Ax
 Mov Ax,Gs:[Si.M_Ia_Move_Const]
 Add Ax,Fs:[040h*016d+06Ch]    ; Random (24 heures = 0)
 Mov Gs:[Si.M_Ia_Move_Const],Ax
 Pop Ax
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[Si.M_Y_Pos],Edx
 Xor Edx,Edx
@T4_No_Bound_yYy:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @T4_NB_yYy        ; Right
 Push Ax
 Mov Ax,Gs:[Si.M_Ia_Move_Const]
 Add Ax,Fs:[040h*016d+06Ch]    ; Random (24 heures = 0)
 Mov Gs:[Si.M_Ia_Move_Const],Ax
 Pop Ax
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[Si.M_Y_Pos],Edx
@T4_Nb_yYy:

 Pop Ebx
 Pop Eax
 Pop Cx
 Push Eax
 Push Ebx

@Hit_T4:
 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Mov Eax,Ebp
 Xor Edx,Edx
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx
 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Shl Eax,07
 Add Edi,Eax

 Mov Ch,[Edi]
 Test Ch,Ch
 Jnz @Hit_With_Allies_Or_Block
 Mov [Edi],Cl

 Pop Ebx
 Pop Eax
 Jmp @Back_Ai

Even
@Hit_With_Allies_Or_Block:
 Mov Ax,Gs:[Si.M_Ia_Move_Const]
 Add Al,080h
 Add Ah,080h
 Add Ax,Word Ptr Gs:[Si.M_X_Pos]
 Sub Ax,Word Ptr Gs:[Si.M_Y_Pos]
 Mov Gs:[Si.M_Ia_Move_Const],Ax
 Mov Gs:[Si.M_Ia_Move],0300h
 Pop Ebx
 Pop Eax
 Mov Gs:[Si.M_X_Pos],Eax
 Mov Gs:[Si.M_Y_Pos],Ebx
 
 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Mov Eax,Ebp
 Xor Edx,Edx
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx
 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Shl Eax,07
 Add Edi,Eax
 Mov [Edi],Cl
 Jmp @Back_Ai

@Technik_05:   ; Enemy_B
 Push Cx
 Mov Eax,Gs:[Si.M_X_Pos]
 Mov Ebx,Gs:[Si.M_Y_Pos]
 Mov Ecx,Gs:[Si.M_X_Inc_Pos]
 Mov Edx,Gs:[Si.M_Y_Inc_Pos]
 Push Eax
 Push Ebx
 Add Eax,Ecx
 Add Ebx,Edx
 Mov Gs:[Si.M_X_Pos],Eax
 Mov Gs:[Si.M_Y_Pos],Ebx

 Mov Ecx,012600d
 Mov Edx,Dword Ptr Gs:[Si.M_X_Pos]
 Sub Edx,Ecx
 Js @T5_No_Bound_xXx   ; Left
 Neg Dword Ptr Gs:[Si.M_X_Inc_Pos]
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[Si.M_X_Pos],Edx
 Xor Edx,Edx
@T5_No_Bound_xXx:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @T5_NB_xXx        ; Right
 Neg Dword Ptr Gs:[Si.M_X_Inc_Pos]
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[Si.M_X_Pos],Edx
@T5_Nb_xXx:
 Mov Eax,Edx
 Mov Edx,Dword Ptr Gs:[Si.M_Y_Pos]
 Sub Edx,Ecx
 Js @T5_No_Bound_yYy
 Neg Dword Ptr Gs:[Si.M_Y_Inc_Pos]
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[Si.M_Y_Pos],Edx
 Xor Edx,Edx
@T5_No_Bound_yYy:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @T5_NB_yYy        ; Right
 Neg Dword Ptr Gs:[Si.M_Y_Inc_Pos]
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[Si.M_Y_Pos],Edx
@T5_Nb_yYy:
 Pop Ebx
 Pop Eax
 Pop Cx
 Push Eax
 Push Ebx

 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Mov Eax,Ebp
 Xor Edx,Edx
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx
 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Shl Eax,07
 Add Edi,Eax

 Mov Ch,[Edi]
 Test Ch,Ch
 Jnz @Hit_With_Allies_Or_Block_T5
 Mov [Edi],Cl

 Pop Ebx
 Pop Eax
 Jmp @Back_Ai

@Hit_With_Allies_Or_Block_T5:
 Pop Ebx
 Pop Eax
 Mov Gs:[Si.M_X_Pos],Eax
 Mov Gs:[Si.M_Y_Pos],Ebx
 Neg Dword Ptr Gs:[Si.M_X_Inc_Pos]
 Neg Dword Ptr Gs:[Si.M_Y_Inc_Pos]

 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Mov Eax,Ebp
 Xor Edx,Edx
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx
 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Shl Eax,07
 Add Edi,Eax
 Mov [Edi],Cl
 Jmp @Back_Ai

@Technik_06:
 Push Cx
 Mov Al,Gs:[Si.M_Z_Rot]
 Inc Al
 Mov Gs:[Si.M_Z_Rot],Al
 Mov Cl,Al

 Mov Al,Byte Ptr Gs:[Si.M_Ia_Var_TzZz]
 Test Al,Al
 Jz @N_H_T6
 Dec Al
 Mov Byte Ptr Gs:[Si.M_Ia_Var_TzZz],Al

 Mov Bp,Offset Sinus_3d
 Mov Bx,Word Ptr Gs:[EnemyC1.M_Ia_Var_RxXx]    ; Boule de Mouvement
 Xor Ah,Ah
 Mov Al,Bh
 Xor Bh,Bh
 Add Ax,Ax
 Add Bx,Bx
 Add Bx,Bp
 Add Bp,Ax
 Movsx Ecx,Word Ptr Gs:[Bp]
 Movsx Edx,Word Ptr Gs:[Bx]
 Mov Eax,Gs:[Si.M_X_Pos]
 Mov Ebx,Gs:[Si.M_Y_Pos]
 Push Eax
 Push Ebx
 Add Eax,Ecx
 Add Ebx,Edx
 Add Eax,Gs:[Si.M_X_Inc_Pos]
 Add Ebx,Gs:[Si.M_Y_Inc_Pos]
 Jmp @Back_T6
@N_H_T6:
 Xor Al,Al
 Mov Byte Ptr Gs:[Si.M_Ia_Var_TzZz],Al

 Mov Eax,Gs:[Si.M_X_Pos]
 Mov Ebx,Gs:[Si.M_Y_Pos]
 Push Eax
 Push Ebx
 Push Di 

 Push Ax
 Push Bx
 Mov Bp,Offset Sinus_3d
 Mov Bl,Cl
 Mov Al,Cl
 Add Bl,064d
 Xor Ah,Ah
 Xor Bh,Bh
 Add Ax,Ax
 Add Bx,Bx
 Add Bx,Bp
 Add Bp,Ax
 Movsx Ecx,Word Ptr Gs:[Bp]
 Movsx Edx,Word Ptr Gs:[Bx]
 Pop Bx
 Pop Ax
 Sar Ecx,03
 Sar Edx,03
 Sub Eax,Ecx
 Add Ebx,Edx

 Mov Bp,Word Ptr Gs:[Si.M_Ia_Move_Const]       ; Enemy Type B
 Mov Di,Word Ptr Gs:[Si.M_Ia_Var_TxXx]         ; Enemy Type A
 Speed_T6 Equ 08d

 Mov Ecx,Eax
 Mov Edx,Ebx
 Sub Ecx,Gs:[Bp.M_X_Pos]
 Jns @NT6_01
 Add Eax,Speed_T6*02d
@NT6_01:
 Sub Eax,Speed_T6
 Sub Edx,Gs:[Bp.M_Y_Pos]
 Jns @NT6_02
 Add Ebx,Speed_T6*02d
@NT6_02:
 Sub Ebx,Speed_T6

 Mov Ecx,Eax
 Mov Edx,Ebx
 Sub Ecx,Gs:[Di.M_X_Pos]
 Jns @NT6_03
 Add Eax,Speed_T6*02d
@NT6_03:
 Sub Eax,Speed_T6
 Sub Edx,Gs:[Bp.M_Y_Pos]
 Jns @NT6_04
 Add Ebx,Speed_T6*02d
@NT6_04:
 Sub Ebx,Speed_T6

 Mov Ecx,Eax
 Mov Edx,Ebx
 Sub Ecx,Gs:[HeroStr.M_X_Pos]
 Jns @NT6_05
 Add Eax,Speed_T6*02d
@NT6_05:
 Sub Eax,Speed_T6
 Sub Edx,Gs:[HeroStr.M_Y_Pos]
 Jns @NT6_06
 Add Ebx,Speed_T6*02d
@NT6_06:
 Sub Ebx,Speed_T6

 Mov Bp,Word Ptr Gs:[EnemyC1.M_Ia_Move]        ; Crest
 Mov Ecx,Eax
 Mov Edx,Ebx
 Sub Ecx,Gs:[Bp.M_X_Pos]
 Jns @NT7_01
 Add Eax,Speed_T6*02d
@NT7_01:
 Sub Eax,Speed_T6
 Sub Edx,Gs:[Bp.M_Y_Pos]
 Jns @NT8_02
 Add Ebx,Speed_T6*02d
@NT8_02:
 Sub Ebx,Speed_T6

 Mov Gs:[Si.M_X_Pos],Eax
 Mov Gs:[Si.M_Y_Pos],Ebx
 Pop Di

@Back_T6:

 Mov Ecx,012600d
 Mov Edx,Dword Ptr Gs:[Si.M_X_Pos]
 Sub Edx,Ecx
 Js @T6_No_Bound_xXx   ; Left
 Neg Dword Ptr Gs:[Si.M_X_Inc_Pos]
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[Si.M_X_Pos],Edx
 Xor Edx,Edx
@T6_No_Bound_xXx:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @T6_NB_xXx        ; Right
 Neg Dword Ptr Gs:[Si.M_X_Inc_Pos]
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[Si.M_X_Pos],Edx
@T6_Nb_xXx:
 Mov Eax,Edx
 Mov Edx,Dword Ptr Gs:[Si.M_Y_Pos]
 Sub Edx,Ecx
 Js @T6_No_Bound_yYy
 Neg Dword Ptr Gs:[Si.M_Y_Inc_Pos]
 Mov Edx,Ecx
 Mov Dword Ptr Gs:[Si.M_Y_Pos],Edx
 Xor Edx,Edx
@T6_No_Bound_yYy:
 Add Edx,Ecx
 Add Edx,Ecx
 Jns @T6_NB_yYy        ; Right
 Neg Dword Ptr Gs:[Si.M_Y_Inc_Pos]
 Mov Edx,Ecx
 Neg Edx
 Mov Dword Ptr Gs:[Si.M_Y_Pos],Edx
@T6_Nb_yYy:

 Mov Eax,Gs:[Si.M_X_Pos]
 Mov Ebx,Gs:[Si.M_Y_Pos]
 Add Eax,Gs:[Si.M_X_Inc_Pos]
 Add Ebx,Gs:[Si.M_Y_Inc_Pos]
 Mov Gs:[Si.M_X_Pos],Eax
 Mov Gs:[Si.M_Y_Pos],Ebx

 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Mov Eax,Ebp
 Xor Edx,Edx
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx
 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Shl Eax,07
 Add Edi,Eax
 Pop Ebx
 Pop Eax
 Pop Cx
 Push Eax
 Push Ebx
 Mov Ch,[Edi]
 Test Ch,Ch
 Jnz @Hit_With_Allies_Or_Block_Last
 Mov [Edi],Cl

 Pop Ebx
 Pop Eax
 Jmp @Back_Ai

@Hit_With_Allies_Or_Block_Last:
 Pop Ebx
 Pop Eax
 Mov Gs:[Si.M_X_Pos],Eax
 Mov Gs:[Si.M_Y_Pos],Ebx
 Neg Gs:[Si.M_X_Inc_Pos]
 Neg Gs:[Si.M_Y_Inc_Pos]
 Mov Ax,Word Ptr Gs:[EnemyC1.M_Ia_Var_RxXx]    ; Boule de Mouvement
 Add Ax,0A0Fh
 Mov Word Ptr Gs:[EnemyC1.M_Ia_Var_RxXx],Ax
 Mov Al,0100d
 Mov Byte Ptr Gs:[Si.M_Ia_Var_TzZz],Al

 Mov Ebp,(03200d*08d)/02d
 Mov Ebx,0200d
 Mov Eax,Ebp
 Xor Edx,Edx
 Sub Eax,Gs:[Si.M_X_Pos]
 Div Ebx
 Add Edi,Eax
 Xor Edx,Edx
 Mov Eax,Ebp
 Add Eax,Gs:[Si.M_Y_Pos]
 Div Ebx
 Shl Eax,07
 Add Edi,Eax
 Mov [Edi],Cl
 Jmp @Back_Ai

Ret
EndP

Even
Hero_Die Proc Near
;****************************************************************************
;*                             H e r o _ D i e                              *
;****************************************************************************
 Mov Eax,Dword Ptr Gs:[Dead_Frame]
 Test Eax,Eax
 Jnz @N_End
 Inc Eax
 Inc Eax
@N_End:
 Dec Eax
 Mov Dword Ptr Gs:[Dead_Frame],Eax
 Add Byte Ptr Gs:[Go_Inc],02

 Shr Eax,02
 Sub Eax,03
 Jns @N_End2
 Mov Eax,-1
@N_End2:
 Add Eax,03
 Mov Dword Ptr Gs:[Frame],Eax

 Xor Edx,Edx
 Mov Dx,Offset HeroStr
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Eax,Eax
 Mov Ecx,(640*480/4)/04
 Rep Stos Dword Ptr Es:[Edi] 

 Mov Ecx,((640*480)/04)-((640*480/4)/04)
 Mov Esi,01F1F1F1Fh
 Mov Ebp,0E0E0E0E0h
 Mov Edx,04d
Even
@Loop_Blur_Dead:
 Mov Eax,[Edi]
 Test Eax,Eax          ; Petite Optimisation
 Jz @No_Hero_Go
 Mov Ebx,Eax
 And Eax,Esi
 And Ebx,Ebp

 Dec Al
 Jns @BP1
 Inc Al
@BP1:
 Dec Ah
 Jns @BP2
 Inc Ah
@BP2:
 Bswap Eax
 Dec Al
 Jns @BP3
 Inc Al
@BP3:
 Dec Ah
 Jns @BP4
 Inc Ah
@BP4:
 Bswap Eax

 Or Ebx,Eax
 Mov [Edi],Ebx
@No_Hero_Go:
 Add Edi,Edx
 Dec Ecx
 Jnz @Loop_Blur_Dead

 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[GOver.Xms_Ptr]
 Add Edi,(640*480/16)+(640-2*196)/2
 Mov Bp,Offset Sinus_3d
 Mov Dx,(0196d*256)+(024d/02)
 Mov Ch,Gs:[Go_Inc]
Even
@Loop_Go_X:
 Push Esi
 Push Edi
 Mov Bl,Ch
 Xor Bh,Bh
 Add Bx,Bx
 Add Bx,Bp
 Movsx Ebx,Word Ptr Gs:[Bx]
 Sar Ebx,04
 Imul Ebx,0640d
 Mov Cl,Dl
 Add Edi,Ebx
Even
@Loop_Go_Y:
 Mov Al,[Esi]
 Test Al,Al
 Jz @Nlg_1
 Xor Al,Ch
 Mov [Edi],Al
@Nlg_1:
 Add Edi,0640d*2
 Add Esi,0196d
 Mov Al,[Esi]
 Test Al,Al
 Jz @Nlg_2
 Mov [Edi+1],Al
@Nlg_2:
 Add Edi,0640d*2
 Add Esi,0196d
 Dec Cl
 Jnz @Loop_Go_Y
 Pop Edi
 Pop Esi
 Inc Edi
 Inc Esi
 Inc Edi
 Inc Ch
 Dec Dh
 Jnz @Loop_Go_X

Ret
EndP

Even
Check_Win Proc Near
;****************************************************************************
;*                           C h e c k _ W i n                              *
;****************************************************************************
 Mov Bx,Offset Table_3d_Objects+05     ; Check la Mission
 Mov Al,Gs:[Bx]
 And Al,Gs:[Bx+04d]
 And Al,Gs:[Bx+08d]
 And Al,Gs:[Bx+012d]
 Add Ebx,024d
 Mov Cl,012d
@Loop_Kill_All_Enemys:
 And Al,Gs:[Bx]
 Add Ebx,04d
 Dec Cl
 Jnz @Loop_Kill_All_Enemys
 Test Al,01
 Jz @No_Win
 Or Byte Ptr Gs:[Offset Table_3d_Objects+(24+1)],01h
 Or Byte Ptr Gs:[Offset Table_3d_Objects+(20+1)],01h
 And Byte Ptr Gs:[Offset Table_3d_Objects+019d*04+1],0FEh
 Mov Word Ptr Cs:[@Call_2_Nop],09090h
 Mov Byte Ptr Cs:[@Call_2_Nop+02],090h
 Mov Gs:[End_Mission],0FFh
 Mov Gs:[WMusic],016d
 Call Load_Music
 Call Play_It 
@No_Win:
Ret
EndP

Even
The_End Proc Near
;****************************************************************************
;*                           T h e _ E n d                                  *
;****************************************************************************
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Ecx,Ecx
 Mov Ebp,(0640d-0275d)
 Mov Dx,(068d*0256d)+036d
 Mov Esi,Gs:[TheEnd.Xms_Ptr]
 Add Edi,(0640d-0275d)/02d+(0640d*08d)
Even
@LThe_End:
 Mov Cl,Dh
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Db 067h
 Movsw
 Db 067h
 Movsb
 Add Edi,Ebp
 Dec Dl
 Jnz @LThe_End

 Xor Ebx,Ebx
 Mov Gs:[World_Mesh.W_X_Cam],Ebx
 Mov Gs:[World_Mesh.W_Y_Cam],Ebx
 Mov Gs:[World_Mesh.W_Z_Cam],Ebx
 Mov Gs:[World_Mesh.M_X_Pos],Ebx
 Mov Gs:[HeroStr.M_X_Pos],Ebx
 Mov Gs:[HeroStr.M_Y_Pos],Ebx
 Mov Gs:[HeroStr.M_Z_Pos],Ebx
 Mov Gs:[World_Mesh.W_Y_Pos],Ebx
 Mov Dword ptr Gs:[World_Mesh.W_X_Rot],Ebx
 Mov Edx,0768d
 Mov Gs:[World_Mesh.W_Z_Pos],Edx

 Mov Eax,Dword Ptr Gs:[HeroStr.M_X_Rot]
 Mov Al,040h
 Bswap Eax
 Xor Ah,Ah
 Bswap Eax
 Mov Dword Ptr Gs:[HeroStr.M_X_Rot],Eax

 Mov Eax,Dword Ptr Gs:[Dead_Frame]
 Test Eax,Eax
 Jnz @TN_End
 Mov Eax,Hero_Walk
@TN_End:
 Dec Eax
 Mov Dword Ptr Gs:[Dead_Frame],Eax
 
 Shr Eax,02
 Inc Eax
 Mov Dword Ptr Gs:[Frame],Eax

 Xor Edx,Edx
 Mov Dx,Offset HeroStr
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Ecx,((640*480)/04)-((640*480/4)/04)
 Add Edi,(640*480/4)
 Mov Esi,01F1F1F1Fh
 Mov Ebp,0E0E0E0E0h
 Mov Edx,04d
Even
@TLoop_Blur_Dead:
 Mov Eax,[Edi]
 Mov Ebx,Eax
 And Eax,Esi
 And Ebx,Ebp

 Dec Al
 Jns @TBP1
 Inc Al
@TBP1:
 Dec Ah
 Jns @TBP2
 Inc Ah
@TBP2:
 Bswap Eax
 Dec Al
 Jns @TBP3
 Inc Al
@TBP3:
 Dec Ah
 Jns @TBP4
 Inc Ah
@TBP4:
 Bswap Eax

 Or Ebx,Eax
 Mov [Edi-640],Ebx
@TNo_Hero_Go:
 Add Edi,Edx
 Dec Ecx
 Jnz @TLoop_Blur_Dead

 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

Ret
EndP

Play_It Proc Near
 Cli
 Mov Dword Ptr Gs:[Music_Counter],1
 Call Stop_Music
 Mov Eax,Gs:[MH8]
 Mov Gs:[Music_Pos],00h
 Mov Fs:[08h*04h],Eax
 Sti
Ret
EndP

Stop_It Proc Near
 Cli
 Mov Eax,Gs:[NH8]
 Mov Fs:[08h*04h],Eax
 Sti
 Call Stop_Music
Ret
EndP

Load_Music Proc Near
 Push Es
 Xor Eax,Eax
 Mov Ecx,(0900d*1024d)/04d
 Mov Edi,Gs:[MusicX.Xms_Ptr]
 Mov Es,Ax
 Dec Eax
 Rep Stos Dword Ptr Es:[Edi]
 Pop Es

 Push Gs
 Pop Ds
 Mov Ax,03D00h
 Mov Dx,Offset I_Name_Temp
 Add Dx,Gs:[WMusic]
 Int 021h
 Mov Bp,Ax
 Jc @File_Not_Found

 Mov Ax,03F00h
 Mov Bx,Bp
 Mov Cx,08h
 Mov Dx,Offset Check_Id
 Int 021h

 Mov Ax,03F00h
 Mov Bx,Bp
 Mov Cx,02h
 Mov Dx,Offset Speed
 Int 021h

 Mov Ax,03F00h
 Mov Bx,Bp
 Mov Cx,09216d
 Mov Dx,Offset Instruments_Table
 Int 021h

 Mov Ax,03F00h
 Mov Bx,Bp
 Mov Cx,0256d
 Mov Dx,Offset Pattern_Table
 Int 021h

 Mov Ax,03F00h
 Mov Bx,Bp
 Mov Cx,01d
 Mov Dx,Offset Nbr_Pattern
 Int 021h

 Mov Cl,Gs:[Nbr_Pattern]
 Push Bp
@Loop_Loading:
 Push Cx

 Mov Ax,03F00h
 Mov Bx,Bp
 Mov Cx,01d
 Mov Dx,Offset Nbr_Pattern
 Int 021h

 Mov Ax,03F00h
 Mov Bx,Bp
 Mov Cx,(018d*03d*064d)
 Mov Dx,Offset M_Pat
 Int 021h

 Push Ds
 Push Es
 Push Gs
 Xor Esi,Esi
 Pop Ds
 Mov Es,Si
 Mov Si,Offset M_Pat
 Xor Ecx,Ecx
 Mov Cl,Gs:[Nbr_Pattern]
 Mov Edi,Gs:[MusicX.Xms_Ptr]
 Imul Ecx,((018d*03d)*064d)    ; Longueur d'un Pattern
 Add Edi,Ecx

 Mov Ecx,(018d*03d*064d)/04d
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Pop Es
 Pop Ds

 Pop Cx
 Dec Cl
 Jnz @Loop_Loading
 Pop Bp

 Mov Ax,03E00h
 Mov Bx,Bp
 Int 021h
 Mov Byte Ptr Gs:[Pattern],00h

 Xor Ax,Ax
 Mov Ds,Ax
@File_Not_Found:
Ret
EndP


;-=([    S t a r t   ])=-

Even
Start Proc Near
 Push Ss
 Push Sp    
 Mov Ax,MyStack
 Mov Ss,Ax
 Mov Sp,1000h-04
 Mov Ax,Data                   ; Ds = Adresse debut des donnees
 Mov Ds,Ax
 Mov Ax,03h                    ; 80*25 Mode Texte
 Int 10h

;=- Init Sequence
 Call Check_Xms
;[DosBox] Call Get_Free_Xms
;[DosBox] Call Check_Flat_Mode
 Call Install_Vesa                              
;[DosBox] Call Install_Flat_Mode
 Call Install_New_Handler

 Call Get_Mem_Xms
 Call Clear
 Call Set_Pal

 Mov Byte Ptr Gs:[Direction],01h
 Mov Di,Offset VesaInfo_Table_F1
 Mov Edi,Dword Ptr Gs:[Di+028h]                ; Pointeur a access direct
 Mov Gs:[Vesa_Ptr],Edi

 Call Reset
 Mov Ax,0FF02h
 Call Output_Fm
 Mov Ax,08004h
 Call Output_Fm
 Mov Ax,00104h
 Call Output_Fm
 Mov Ax,0BDh           ; Neuf Canaux Independant
 Call Output_Fm
 Mov Ax,0105h          ; Application Stereo
 Call Output_Fm2


;=- Logo Sequence
 Mov Ax,Seg Jsr_Logo
 Mov Fs,Ax
 Mov Dx,03438d
 Mov Bp,08d
 Xor Bx,Bx
@Swap:
 Mov Ax,Fs:[Bx+02d]
 Mov Cx,Fs:[Bx+06d]
 Add Ax,020d
 Add Cx,020d
 Xchg Al,Ah
 Xchg Cl,Ch
 Mov Fs:[Bx+02d],Ax
 Mov Fs:[Bx+06d],Cx
 Add Bx,Bp
 Dec Dx
 Jnz @Swap
 Call Clear

 Mov Cx,0512d
Even
@Global_Logo_Loop:
 Push Cx
 Mov Ax,Seg Jsr_Logo
 Mov Fs,Ax
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Bx,Bx
 Xor Bp,Bp
 Mov Dx,03438d
 Dec Bp
 Mov Ax,Offset Sinus_32
 Mov Si,Ax
 Bswap Esi
 Mov Si,Ax
 Inc Byte Ptr Gs:[Logo_JsrS]

Even
@M1:
 Push Edi
 Push Esi
 Push Dx
 Mov Cx,Word Ptr Fs:[Bx+06d]
 Xchg Ch,Cl
 Movsx Ecx,Cx
 Mov Ax,Cx
 Shr Ax,01
 Add Al,Gs:[Logo_JsrS]
 Xor Ah,Ah
 Add Ax,Ax
 Add Si,Ax
 Movsx Edx,Word Ptr Gs:[Si]
 Add Ecx,Edx
 Movsx Eax,Word Ptr Fs:[Bx+04d]

 Push Ecx
 Bswap Esi
 Add Cx,Ax
 Shr Cx,01
 Add Cl,Gs:[Logo_JsrS]
 Xor Ch,Ch
 Add Cx,Cx
 Add Si,Cx
 Movsx Edx,Word Ptr Gs:[Si]
 Add Eax,Edx
 Pop Ecx

 Imul Ecx,640
 Add Ecx,Eax
 Shl Ecx,01
 Add Edi,Ecx
 Mov [Edi],Bp
 Inc Bp
 Mov [Edi+640],Bp
 Dec Bp

 Add Bx,08d
 Pop Dx
 Pop Esi
 Pop Edi
 Dec Dx
 Jnz @M1

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Ecx,0640d*02d
 Xor Eax,Eax
 Rep Stos Dword Ptr Es:[Edi]

 Mov Ecx,((0640d*0480d)-(0640d*04d))/04d
 Mov Edx,0FEFEFEFEh
@Loop_Logo_Blur:
 Mov Eax,[Edi+1]
 Mov Ebx,[Edi-1]
 And Eax,Edx
 And Ebx,Edx
 Add Eax,Ebx
 Rcr Eax,01

 Mov Ebx,[Edi-640]
 And Eax,Edx
 And Ebx,Edx
 Add Eax,Ebx
 Rcr Eax,01
 Mov Ebx,[Edi+640]
 And Eax,Edx
 And Ebx,Edx
 Add Eax,Ebx
 Rcr Eax,01

 Mov [Edi],Eax
 Add Edi,04d
 Dec Ecx
 Jnz @Loop_Logo_Blur

 Mov Ecx,0640d*02d
 Xor Eax,Eax
 Rep Stos Dword Ptr Es:[Edi]

 Call Show

 Mov Dx,03438d
 Xor Bx,Bx
Even
@Loop_Morph_Logo:
 Mov Eax,Fs:[Bx+04d]
 Mov Ecx,Fs:[Bx]
 Mov Edi,Eax

 Sub Di,Cx
 Jz @No_Morph
 Js @Morph_Inc
 Dec Ax
 Dec Ax
@Morph_Inc:
 Inc Ax
@No_Morph:
 Bswap Edi
 Bswap Ecx
 Bswap Eax

 Sub Di,Cx
 Jz @No_Morph2
 Js @Morph_Inc2
 Dec Ax
 Dec Ax
@Morph_Inc2:
 Inc Ax
@No_Morph2:
 Bswap Eax
 Mov Fs:[Bx+04d],Eax
 Add Bx,08d

 Dec Dx
 Jnz @Loop_Morph_Logo
 Pop Cx
 Dec Cx
 Jnz @Global_Logo_Loop                         

 Mov Dx,03438d
 Mov Bp,08d
 Xor Bx,Bx
@Swap2:
 Mov Eax,Fs:[Bx]
 Mov Ax,0160d
 Bswap Eax
 Mov Ax,0120d
 Bswap Eax
 Mov Fs:[Bx],Eax
 Add Bx,Bp
 Dec Dx
 Jnz @Swap2

 Mov Cx,0192d
Even
@LGlobal_Logo_Loop:
 Push Cx
 Mov Ax,Seg Jsr_Logo
 Mov Fs,Ax
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Bx,Bx
 Xor Bp,Bp
 Mov Dx,03438d
 Dec Bp
 Mov Ax,Offset Sinus_32
 Mov Si,Ax
 Bswap Esi
 Mov Si,Ax
 Inc Byte Ptr Gs:[Logo_JsrS]

Even
@LM1:
 Push Edi
 Push Esi
 Push Dx
 Mov Cx,Word Ptr Fs:[Bx+06d]
 Xchg Ch,Cl
 Movsx Ecx,Cx
 Mov Ax,Cx
 Shr Ax,01
 Add Al,Gs:[Logo_JsrS]
 Xor Ah,Ah
 Add Ax,Ax
 Add Si,Ax
 Movsx Edx,Word Ptr Gs:[Si]
 Add Ecx,Edx
 Movsx Eax,Word Ptr Fs:[Bx+04d]

 Push Ecx
 Bswap Esi
 Add Cx,Ax
 Shr Cx,01
 Add Cl,Gs:[Logo_JsrS]
 Xor Ch,Ch
 Add Cx,Cx
 Add Si,Cx
 Movsx Edx,Word Ptr Gs:[Si]
 Add Eax,Edx
 Pop Ecx

 Imul Ecx,640
 Add Ecx,Eax
 Shl Ecx,01
 Add Edi,Ecx
 Mov [Edi],Bp
 Mov [Edi+640],Bp

 Add Bx,08d
 Pop Dx
 Pop Esi
 Pop Edi
 Dec Dx
 Jnz @LM1

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Ecx,0640d*02d
 Xor Eax,Eax
 Rep Stos Dword Ptr Es:[Edi]

 Mov Ecx,((0640d*0480d)-(0640d*04d))/04d
 Mov Edx,0FEFEFEFEh
@LLoop_Logo_Blur:
 Mov Eax,[Edi+1]
 Mov Ebx,[Edi-1]
 And Eax,Edx
 And Ebx,Edx
 Add Eax,Ebx
 Rcr Eax,01

 Mov Ebx,[Edi-640]
 And Eax,Edx
 And Ebx,Edx
 Add Eax,Ebx
 Rcr Eax,01
 Mov Ebx,[Edi+640]
 And Eax,Edx
 And Ebx,Edx
 Add Eax,Ebx
 Rcr Eax,01

 Mov [Edi],Eax
 Add Edi,04d
 Dec Ecx
 Jnz @LLoop_Logo_Blur

 Mov Ecx,0640d*02d
 Xor Eax,Eax
 Rep Stos Dword Ptr Es:[Edi]

 Call Show

 Mov Dx,03438d
 Xor Bx,Bx
Even
@LLoop_Morph_Logo:
 Mov Eax,Fs:[Bx+04d]
 Mov Ecx,Fs:[Bx]
 Mov Edi,Eax

 Sub Di,Cx
 Jz @LNo_Morph
 Js @LMorph_Inc
 Dec Ax
 Dec Ax
@LMorph_Inc:
 Inc Ax
@LNo_Morph:
 Bswap Edi
 Bswap Ecx
 Bswap Eax

 Sub Di,Cx
 Jz @LNo_Morph2
 Js @LMorph_Inc2
 Dec Ax
 Dec Ax
@LMorph_Inc2:
 Inc Ax
@LNo_Morph2:
 Bswap Eax
 Mov Fs:[Bx+04d],Eax
 Add Bx,08d

 Dec Dx
 Jnz @LLoop_Morph_Logo
 Pop Cx
 Dec Cx
 Jnz @LGlobal_Logo_Loop                        
 Xor Ax,Ax
 Mov Fs,Ax

 Mov Gs:[WMusic],016d
 Call Load_Music
 Call Play_It 

 Call Clear
 Call Show
 Call Copy_Pal
 Call Set_Pal
 Call Get_Mem
 Call Load_File
 Call Setting_All_Meshs
 Call Intro                                    ; Introduction
 Call Clear
 Call Show
 Call Copy_Pal
 Call Set_Pal
 Call Sort_yYy_3d_World                        ; Optimization du Monde
 Call Preface
 Call Clear
 Call Show
 Call Copy_Pal
 Call Set_Pal
 Mov Dword Ptr Gs:[World_Mesh.W_Z_Pos],016384d

 Mov Gs:[WMusic],00d
 Call Load_Music
 Call Play_It 
Even
@Main_Loop:                                    ; Repeat 

;=---- Mission Completed [Y/N]
 Mov Al,Gs:[End_Mission]                       ; Finish ?
 Test Al,Al
 Jz @No_Finish
 Mov Al,Byte Ptr Gs:[Offset Table_3d_Objects+019d*04+1]
 Test Al,01
 Jz @No_Finish
@The_End:

 Call The_End
 Call Control_Player
 Call Show
 Mov Bl,Gs:[Key_Table[1]]
 Dec Bl
 Jns @The_End                                  ; Until Key is Esc
 Jmp @Erreur
@No_Finish:

;=---- Game Over [Y/N]
 Mov Al,Gs:[Life]
 Test Al,Al
 Jnz @Hero_No_Die
 Call Hero_Die
 Call Control_Player
 Call Show
 Mov Bl,Gs:[Key_Table[1]]
 Dec Bl
 Jns @Main_Loop                                ; Until Key is Esc
 Jmp @Erreur
@Hero_No_Die:

;=---- Cameras Setting
 Mov Eax,Gs:[HeroStr.M_X_Pos]
 Mov Ebx,Gs:[HeroStr.M_Y_Pos]
 Neg Ebx
 Mov Gs:[World_Mesh.W_X_Pos],Eax
 Mov Gs:[World_Mesh.W_Y_Pos],Ebx
 Mov Gs:[World_Mesh.W_Y_Cam],Ebx
 Mov Gs:[World_Mesh.W_X_Cam],Eax

 Mov Eax,Dword Ptr Gs:[Key_Table[59]]
 Mov Ebx,Dword Ptr Gs:[Key_Table[63]]
 Mov Cl,04d
 Mov Ch,-01d
 Xor Dl,Dl
@LF14:
 Test Al,Al
 Jnz @No_PF
 Mov Ch,Dl 
@No_PF:
 Shr Eax,08
 Inc Dl
 Dec Cl
 Jnz @LF14
 Test Ch,Ch
 Js @No_PresF14
 Mov Gs:[Camera_Select],Ch
@No_PresF14:

 Mov Cl,04d
 Mov Ch,-01d
@LF58:
 Test Bl,Bl
 Jnz @No_PF2
 Mov Ch,Dl 
@No_PF2:
 Shr Ebx,08
 Inc Dl
 Dec Cl
 Jnz @LF58
 Test Ch,Ch
 Js @No_PresF58
 Mov Gs:[Camera_Select],Ch
@No_PresF58:

 Mov Al,Gs:[Camera_Select]
 Mov Bx,Offset Camera_Type
 Xor Ah,Ah
 Shl Ax,05
 Add Bx,Ax
 Mov Eax,Gs:[Bx]
 Mov Ecx,Gs:[Bx+04d]
 Mov Gs:[World_Mesh.W_Z_Pos],Eax
 Mov Dword Ptr Gs:[World_Mesh.W_X_Rot],Ecx
 Mov Eax,Gs:[Bx+08d]
 Mov Ecx,Gs:[Bx+012d]
 Add Gs:[World_Mesh.W_X_Cam],Eax
 Add Gs:[World_Mesh.W_Y_Cam],Ecx
 Mov Eax,Gs:[Bx+016d]
 Mov Gs:[World_Mesh.W_Z_Cam],Eax

 Mov Ax,Word Ptr Gs:[Key_Table[67]]           ; [0C3h:Ret,090h:Nop]
 Test Al,Al
 Jnz @No_Disable_Floors
 Mov Byte Ptr Cs:[@ED_F9F10],090h
@No_Disable_Floors:
 Test Ah,Ah
 Jnz @No_Enable_Floors
 Mov Byte Ptr Cs:[@ED_F9F10],0C3h
@No_Enable_Floors:

;=---- Cheat
 Mov Al,Gs:[Key_Table[36]]                     ; Cheat !!! (JSR)
 Or Al,Gs:[Key_Table[31]]
 Or Al,Gs:[Key_Table[19]]
 Test Al,Al
 Jnz @No_Full_Life
 Mov Byte Ptr Gs:[Life],0111b
@No_Full_Life:
 Call Clear
 Call Control_Objects
 Call Math_Gps_Mesh
 Call Math_World                               ; Matrice de transformation
 Call Sort_3d_World
 Call Draw_Floors
 Call Draw_World
 Call Show_All_Item
 Call Control_Player
 Call Attack_Collision
 Call Show

@Call_2_Nop:                   ; Verifie si la Mission est Termin‚e
 Call Check_Win

;=---- Die
 Mov Al,Gs:[Key_Table[32]]                     ; Game_Over (DIE)
 Or Al,Gs:[Key_Table[23]]
 Or Al,Gs:[Key_Table[18]]
 Test Al,Al
 Jnz @No_Game_Over
 Mov Byte Ptr Gs:[Life],00b
 Call Clear
 Mov Dword Ptr Gs:[Dead_Frame],016d*04d
 Mov Dword Ptr Gs:[Frame],016d
 Mov Dword Ptr Gs:[Pos],034d

 Xor Ebx,Ebx
 Mov Gs:[World_Mesh.W_X_Cam],Ebx
 Mov Gs:[World_Mesh.W_Y_Cam],Ebx
 Mov Gs:[World_Mesh.W_Z_Cam],Ebx
 Mov Gs:[HeroStr.M_X_Pos],Ebx
 Mov Gs:[World_Mesh.W_X_Pos],Ebx
 Mov Gs:[HeroStr.M_Y_Pos],Ebx
 Mov Gs:[HeroStr.M_Z_Pos],Ebx
 Mov Gs:[World_Mesh.W_Y_Pos],Ebx
 Mov Dword ptr Gs:[World_Mesh.W_X_Rot],Ebx
 Mov Edx,01024d
 Mov Gs:[World_Mesh.W_Z_Pos],Edx

 Mov Eax,Dword Ptr Gs:[HeroStr.M_X_Rot]
 Mov Al,040h
 Mov Ah,-060h
 Bswap Eax
 Xor Ah,Ah
 Bswap Eax
 Mov Dword Ptr Gs:[HeroStr.M_X_Rot],Eax
@No_Game_Over:


;=---- Win
 Mov Al,Gs:[Key_Table[34]]                     ; The_End (GOD)
 Or Al,Gs:[Key_Table[24]]
 Or Al,Gs:[Key_Table[32]]
 Test Al,Al
 Jnz @No_Win_Game
 Call Clear
 Mov Bx,Offset Table_3d_Objects+04d
 Mov Cl,Const_Nbr_Objects-01d
@Loop_E:
 Or Byte Ptr Gs:[Bx+01d],01d
 Add Bx,04d
 Dec Cl
 Jnz @Loop_E
 And Byte Ptr Gs:[Bx+01d],0FEh
@No_Win_Game:

 Mov Bl,Gs:[Key_Table[1]]
 Dec Bl
 Jns @Main_Loop                                ; Until Key is Esc

@Erreur:
 Call Stop_It
 Call Remove_New_Handler
 Call Free_Mem_Xms
 Call Free_Mem 

 Pop Sp
 Pop Ss

 Mov Ax,03h
 Int 10h
 Mov Ax,4C00h
 Int 21h
Start EndP

Even
Intro Proc Near
;****************************************************************************
;*                             I n t r o                                    *
;****************************************************************************
 Call Clear
 Call Show
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[TitleK.Xms_Ptr]
 Add Edi,036d
 T_Larg Equ 71*4
 Mov Bx,T_Larg
 Mov Dx,47
@Loop_IY:
 Mov Cx,Bx
@Loop_IX:
 Mov Al,[Esi]
 Mov Ah,Al
 And Ah,011111100b
 Mov [Edi],Ax
 Xchg Al,Ah
 Mov [Edi+640],Ax
 Inc Esi
 Inc Edi
 Inc Edi
 Dec Cx
 Jnz @Loop_IX
 Add Edi,(640-(2*T_Larg))+640
 Dec Dl
 Jnz @Loop_IY

 Xor Edx,Edx
 Mov Dx,Offset Energ_1 
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]

 Xor Ebx,Ebx
 Mov Gs:[Bac_Mesh.M_X_Pos],Ebx
 Mov Gs:[Bac_Mesh.M_Y_Pos],Ebx
 Mov Gs:[Bac_Mesh.M_Z_Pos],Ebx
 Mov Edx,0480d
 Mov Gs:[World_Mesh.W_Z_Pos],Edx
 Mov Eax,Dword Ptr Gs:[Bac_Mesh.M_X_Rot]
 Xor Al,Al
 Bswap Eax
 Mov Ah,040h 
 Bswap Eax
 Mov Ah,05h
 Mov Dword Ptr Gs:[Bac_Mesh.M_X_Rot],Eax

 Mov Ecx,0160d
 Mov Edx,(640*479)
Even
@BIntro:
 Push Ecx
 Push Edx

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Eax,Eax
 Add Edi,(0640d*0128d)
 Mov Ecx,(0640d*0350d)/04d
 Rep Stos Dword Ptr Es:[Edi]

 Mov Al,Gs:[Bac_Mesh.M_X_Rot]
 Inc Al
 Mov Gs:[Bac_Mesh.M_X_Rot],Al
 Shr Al,04

 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh
 Pop Eax
 Pop Ecx
 Push Ecx
 Push Eax
 Mov Edi,Gs:[Vesa_Ptr]
 Mov Esi,Gs:[Screen.Xms_Ptr]
 Add Esi,Eax
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Mov Bx,Offset Key_Table

 Pop Edx
 Pop Ecx
 Add Ecx,0160d
 Sub Edx,0640d
 Test Edx,Edx
 Jnz @BIntro

Even
@Intro:
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Eax,Eax
 Add Edi,(0640d*0128d)
 Mov Ecx,(0640d*0350d)/04d
 Rep Stos Dword Ptr Es:[Edi]

 Mov Al,Gs:[Bac_Mesh.M_X_Rot]
 Inc Al
 Mov Gs:[Bac_Mesh.M_X_Rot],Al
 Shr Al,04
 Jc @No_Start
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[PStart.Xms_Ptr]
 Add Edi,(0640d-0128d)/02d+(0420d*0640d)
 Mov Dl,016d
@LPS:
 Mov Cx,0128d/04
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Add Edi,0640d-0128d
 Dec Dl
 Jnz @LPS
@No_Start:

 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh
 Call Show

 Mov Bx,Offset Key_Table
 Mov Eax,Gs:[Bx]
 Mov Ecx,Gs:[Bx+04]
 Mov Dx,(0128d/08d)-08d
 Mov Bp,08d
@Loop_KeyPressed:
 And Eax,Gs:[Bx+8]
 And Ecx,Gs:[Bx+012d]
 Add Bx,Bp
 Dec Dx
 Jnz @Loop_KeyPressed
 And Eax,Ecx
 Mov Cx,Ax
 Bswap Eax
 And Ax,Cx
 And Al,Ah
 Test Al,Al
 Jnz @Intro

 Mov Cx,064d
@Intro_Fade:
 Push Cx
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Xor Eax,Eax
 Add Edi,(0640d*0128d)
 Mov Ecx,(0640d*0350d)/04d
 Rep Stos Dword Ptr Es:[Edi]

 Mov Al,Gs:[Bac_Mesh.M_X_Rot]
 Inc Al
 Mov Gs:[Bac_Mesh.M_X_Rot],Al

 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh
 Call Show
 Mov Dx,03DAh
 Mov Bl,08h
@V1:
 In Al,Dx
 Test Al,Bl
 Jnz @V1
@V2:
 In Al,Dx
 Test Al,Bl
 Jz @V2
 Call Set_Pal

 Mov Si,Offset Dest_Pal
 Mov Dl,0192d
 Mov Bp,04d
@Loop_Pal_Dec:
 Mov Eax,Gs:[Si]
 Test Al,Al
 Jz @NP1
 Dec Al
@NP1:
 Test Ah,Ah
 Jz @NP2
 Dec Ah
@NP2:
 Bswap Eax
 Test Al,Al
 Jz @NP3
 Dec Al
@NP3:
 Test Ah,Ah
 Jz @NP4
 Dec Ah
@NP4:
 Bswap Eax
 Mov Gs:[Si],Eax
 Add Si,Bp
 Dec Dl
 Jnz @Loop_Pal_Dec

 Pop Cx
 Dec Cx
 Jnz @Intro_Fade

Ret
EndP

Even
Attack_Collision Proc Near
;****************************************************************************
;*                       A t t a c k _ C o l l i s i o n                    *
;****************************************************************************
 Mov Dl,Byte Ptr Gs:[Pos]
 Mov Al,Byte Ptr Gs:[Frame]
 Test Dl,00010000b             ; [17,49] Attacks Frames
 Jz @NAttack
 Test Al,Al
 Jz @NAttack
 Sub Al,07d                    ; Extension de L'Epee, Blessure a la Mi
 Jns @NAttack

 Xor Ah,Ah
 Mov Al,Gs:[Direction]
 Add Ax,Ax
 Mov Edi,Gs:[D_Gps_Pos]
 Mov Bx,Offset CKey_Proc
 Add Bx,Ax
 Mov Bx,Gs:[Bx]
 Mov Cx,06d
 Mov Bp,04d
 Mov Si,Offset Table_3d_Objects + 04d  ; Enleve l'Hero
Even
@L:
 Push Cx
 Push Edi
 Push Bx
 Push Si
 Movsx Eax,Word Ptr Gs:[Bx]
 Add Edi,Eax
 Mov Cl,[Edi]
 Inc Cl
 Jz @ANo_Hit           ; Block
 Dec Cl
 Jz @ANo_Hit           ; Vide
 Mov Dl,Const_Nbr_Objects-1

 Mov Ch,Cl             ; Determine L'Ennemies
 Shr Ch,06
 Test Ch,Ch            ; Teleport
 Jz @ANo_Hit          
 Sub Ch,03
 Jns @ANo_Hit
Even
@Loop_Detection_Objects_Attack:
 Mov Al,Gs:[Si+1]
 Sub Al,Cl
 Jnz @No_Hit_Attack
 Or Byte Ptr Gs:[Si+1],01h
 Jmp @Enemie_Hurt
@No_Hit_Attack:
 Add Si,Bp
 Dec Dl
 Jnz @Loop_Detection_Objects_Attack

@Enemie_Hurt:
@ANo_Hit:
 Pop Si
 Pop Bx
 Pop Edi
 Inc Bx
 Pop Cx
 Inc Bx
 Dec Cx
 Jnz @L
@NAttack:

Ret
EndP

Even
Preface Proc Near
;****************************************************************************
;*                             P r e f a c e                                *
;****************************************************************************
 Push Gs
 Xor Bx,Bx
 Pop Es
 Mov Di,Offset Dest_Pal
 Mov Eax,03F3F3F3Fh
 Mov Ecx,0768d/04d
 Rep Stosd
 Mov Es,Bx
 Call Set_Pal

 Xor Edx,Edx
 Mov Dx,Offset Crest_1 
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_01
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Xor Ebx,Ebx
 Mov Gs:[Bac_01.M_X_Pos],Ebx
 Mov Gs:[Bac_01.M_Z_Pos],Ebx
 Mov Edx,0768d
 Mov Gs:[World_Mesh.W_Z_Pos],Edx
 Mov Eax,Dword Ptr Gs:[Bac_01.M_X_Rot]
 Xor Al,Al
 Bswap Eax
 Mov Ah,040h 
 Bswap Eax
 Mov Ah,05h
 Mov Dword Ptr Gs:[Bac_01.M_X_Rot],Eax
 Mov Ebx,-0300d
 Mov Gs:[Bac_01.M_Y_Pos],Ebx

 Xor Edx,Edx
 Mov Dx,Offset EnemyA1 
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_02
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Xor Ebx,Ebx
 Mov Gs:[Bac_02.M_X_Pos],Ebx
 Mov Gs:[Bac_02.M_Z_Pos],Ebx
 Mov Eax,Dword Ptr Gs:[Bac_02.M_X_Rot]
 Xor Al,Al
 Bswap Eax
 Mov Ah,040h
 Bswap Eax
 Mov Ah,010h
 Mov Dword Ptr Gs:[Bac_02.M_X_Rot],Eax
 Mov Dword Ptr Gs:[Bac_02.M_Y_Pos],0180h
 Mov Dword Ptr Gs:[Bac_02.M_X_Pos],0280h

 Xor Edx,Edx
 Mov Dx,Offset EnemyB1
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_03
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Xor Ebx,Ebx
 Mov Gs:[Bac_03.M_X_Pos],Ebx
 Mov Gs:[Bac_03.M_Z_Pos],Ebx
 Mov Dword Ptr Gs:[Bac_03.M_Z_Pos],Ebx
 Mov Eax,Dword Ptr Gs:[Bac_03.M_X_Rot]
 Xor Al,Al
 Bswap Eax
 Mov Ah,040h
 Bswap Eax
 Mov Ah,010h
 Mov Dword Ptr Gs:[Bac_03.M_X_Rot],Eax
 Mov Dword Ptr Gs:[Bac_03.M_Y_Pos],0180h
 Mov Dword Ptr Gs:[Bac_03.M_X_Pos],00h

 Xor Edx,Edx
 Mov Dx,Offset EnemyC1
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_04
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Xor Ebx,Ebx
 Mov Gs:[Bac_04.M_X_Pos],Ebx
 Mov Dword Ptr Gs:[Bac_04.M_Z_Pos],Ebx
 Mov Eax,Dword Ptr Gs:[Bac_04.M_X_Rot]
 Mov Ax,020h
 Bswap Eax
 Xor Ah,Ah
 Bswap Eax
 Mov Dword Ptr Gs:[Bac_04.M_X_Rot],Eax
 Mov Dword Ptr Gs:[Bac_04.M_Y_Pos],0180h
 Mov Dword Ptr Gs:[Bac_04.M_X_Pos],-0280h

 Mov Cx,0192d
Even
@MLoop:
 Push Cx
 Call Clear
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[EnLogo.Xms_Ptr]
 Add Edi,((0640d-0196d)/02d)+((0480d-020d)/02d)*0640d
 Ene_Larg Equ 0196d
 Mov Ebx,Ene_Larg/04d
 Mov Ebp,(0640d-Ene_Larg)
 Mov Dl,17
Even
@WE:
 Mov Ecx,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Add Edi,Ebp
 Mov Ecx,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Add Edi,Ebp
 Dec Dl
 Jnz @WE

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[Treasu.Xms_Ptr]
 Add Edi,(0640d-Tre_Larg)/02d
 Tre_Larg Equ 0103d
 Mov Ebx,Tre_Larg
 Mov Ebp,(0640d-Tre_Larg)
 Mov Dl,18
Even
@WE2:
 Mov Ecx,Ebx
 Rep Movs Byte Ptr Es:[Edi],Ds:[Esi]
 Add Edi,Ebp
 Mov Ecx,Ebx
 Rep Movs Byte Ptr Es:[Edi],Ds:[Esi]
 Add Edi,Ebp
 Dec Dl
 Jnz @WE2

 Mov Eax,Dword Ptr Gs:[Bac_01.M_X_Rot]
 Mov Bl,Gs:[Bac_02.M_Z_Rot]
 Inc Al
 Inc Bl
 Inc Ah
 Bswap Eax
 Inc Ah
 Bswap Eax
 Mov Gs:[Bac_02.M_Z_Rot],Bl
 Mov Dword Ptr Gs:[Bac_01.M_X_Rot],Eax

 Mov Bl,Gs:[Bac_03.M_Z_Rot]
 Mov Al,Gs:[Bac_04.M_Z_Rot]
 Dec Bl
 Inc Al
 Mov Gs:[Bac_03.M_Z_Rot],Bl
 Mov Gs:[Bac_04.M_Z_Rot],Al

 Xor Edx,Edx
 Mov Dx,Offset Bac_01
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Xor Edx,Edx
 Mov Dx,Offset Bac_02
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Xor Edx,Edx
 Mov Dx,Offset Bac_03
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Xor Edx,Edx
 Mov Dx,Offset Bac_04
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh
 Call Show
 Mov Dx,03DAh
 Mov Bl,08h
@PV1:
 In Al,Dx
 Test Al,Bl
 Jnz @PV1
@PV2:
 In Al,Dx
 Test Al,Bl
 Jz @PV2
 Call Set_Pal

 Mov Si,Offset Dest_Pal
 Mov Di,Offset Palette
 Mov Bp,04d
 Mov Cl,0192d
Even
@Loop_Morph_Pal:
 Mov Eax,Gs:[Si]
 Mov Ebx,Gs:[Di]
 Mov Edx,Eax
 Add Eax,Eax
 Add Edx,Ebx
 Shr Eax,01
 Shr Edx,01
 Add Eax,Edx
 Shr Eax,01
 And Eax,03F3F3F3Fh
 Mov Gs:[Si],Eax
 Add Si,Bp
 Add Di,Bp
 Dec Cl
 Jnz @Loop_Morph_Pal
 Pop Cx
 Dec Cx
 Jnz @MLoop

 Mov Cx,0256d
Even
@PMLoop:
 Push Cx
 Call Clear
 Mov Eax,Dword Ptr Gs:[Bac_01.M_X_Rot]
 Mov Bl,Gs:[Bac_02.M_Z_Rot]
 Inc Al
 Inc Bl
 Inc Ah
 Bswap Eax
 Inc Ah
 Bswap Eax
 Mov Gs:[Bac_02.M_Z_Rot],Bl
 Mov Dword Ptr Gs:[Bac_01.M_X_Rot],Eax

 Mov Bl,Gs:[Bac_03.M_Z_Rot]
 Mov Al,Gs:[Bac_04.M_Z_Rot]
 Dec Bl
 Inc Al
 Mov Gs:[Bac_03.M_Z_Rot],Bl
 Mov Gs:[Bac_04.M_Z_Rot],Al

 Xor Edx,Edx
 Mov Dx,Offset Bac_01
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Xor Edx,Edx
 Mov Dx,Offset Bac_02
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Xor Edx,Edx
 Mov Dx,Offset Bac_03
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Xor Edx,Edx
 Mov Dx,Offset Bac_04
 Xor Esi,Esi
 Xor Edi,Edi
 Mov Si,Gs
 Mov Ecx,068d/04d      ; SizeOf(Mesh_3d_Struc)
 Shl Esi,04
 Xor Ebx,Ebx
 Mov Edi,Esi
 Mov Bx,Offset Bac_Mesh
 Add Esi,Edx
 Add Edi,Ebx
 Rep Movs Dword Ptr Es:[Edi],Ds:[Esi]
 Call Math_Mesh
 Call Sort_3d_Mesh 
 Call Draw_Mesh

 Pop Cx
 Push Cx
 Mov Bx,Cx
 Mov Bp,256d
 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[EnLogo.Xms_Ptr]
 Add Edi,((0640d-0196d)/02d)+((0480d-020d)/02d)*0640d
 Ene_Larg Equ 0196d
 Mov Dl,034d
Even
@PWE:
 Sub Bp,Bx        ; 256-Bx
 Jns @Pm1
 Mov Ecx,Ene_Larg/04d
@Pm1_X:
 Mov Eax,[Esi]
 Test Eax,Eax
 Jz @Pm1_X_Black
 Mov [Edi],Eax
@Pm1_X_Black:
 Add Edi,04d
 Add Esi,04d
 Dec Ecx
 Jnz @Pm1_X
 Add Edi,(0640d-Ene_Larg)
 Add Bp,0256d
 Jmp @Pm2
@Pm1:
 Add Esi,(Ene_Larg)
 Add Edi,0640d
@Pm2:
 Dec Dl
 Jnz @PWE

 Mov Edi,Gs:[Screen.Xms_Ptr]
 Mov Esi,Gs:[Treasu.Xms_Ptr]
 Add Edi,(0640d-Tre_Larg)/02d
 Tre_Larg Equ 0103d
 Pop Cx
 Push Cx
 Mov Bx,Cx
 Mov Bp,256d
 Mov Dl,036d 
Even
@PWE2:
 Sub Bp,Bx        ; 256-Bx
 Jns @WPm1
 Mov Ecx,Tre_Larg
 Rep Movs Byte Ptr Es:[Edi],Ds:[Esi]
 Add Edi,(0640d-Tre_Larg)
 Add Bp,0256d
 Jmp @WPm2
@WPm1:
 Add Esi,(Tre_Larg)
 Add Edi,0640d
@WPm2:
 Dec Dl
 Jnz @PWE2
 Call Show

 Mov Edx,Gs:[World_Mesh.W_Z_Pos]
 Sub Edx,032768/04d
 Jns @NZ
 Add Edx,032768/04d+256d/04d
 Mov Gs:[World_Mesh.W_Z_Pos],Edx
@NZ:

 Inc Byte Ptr Gs:[World_Mesh.W_Z_Rot]
 Pop Cx
 Dec Cx
 Jnz @PMLoop

Ret
EndP
Code Ends

Jsr_Logo Segment Para Public Use16 'Data'
;=-  Xto  Yto  Xfr  Yfr
 Dw   93, 104,   0,   6
 Dw   93, 105, 275,  40
 Dw   93, 106,  87, 134
 Dw   93, 107, 101,  32
 Dw   93, 108, 119,  85
 Dw   93, 109,  26,  94
 Dw   93, 110,  22, 168
 Dw   93, 111,  19,  58
 Dw   93, 112, 293,  73
 Dw   93, 113, 247,  65
 Dw   93, 114, 223, 168
 Dw   93, 115, 229,  61
 Dw   93, 116,  52,  65
 Dw   94, 104, 149,  49
 Dw   94, 105, 264,  55
 Dw   94, 106, 154,  29
 Dw   94, 107, 279,  57
 Dw   94, 108, 247, 195
 Dw   94, 109, 157, 177
 Dw   94, 110, 264,   4
 Dw   94, 111,  45,  28
 Dw   94, 112, 160,   4
 Dw   94, 113, 189,   1
 Dw   94, 114, 247, 130
 Dw   94, 115, 246, 141
 Dw   94, 116, 178,  41
 Dw   94, 117, 217, 118
 Dw   95, 104, 305, 128
 Dw   95, 105, 319,  48
 Dw   95, 106, 216,  59
 Dw   95, 107,  27, 154
 Dw   95, 108, 158, 176
 Dw   95, 109, 163, 114
 Dw   95, 110, 305, 136
 Dw   95, 111, 108,   1
 Dw   95, 112, 225, 197
 Dw   95, 113, 247, 149
 Dw   95, 114,  63,  28
 Dw   95, 115, 292, 156
 Dw   95, 116, 188, 172
 Dw   95, 117, 220,  57
 Dw   95, 118,  29, 125
 Dw   96, 104,  89, 175
 Dw   96, 105,  51,  54
 Dw   96, 106, 173, 192
 Dw   96, 107,  55,  31
 Dw   96, 108,  85,  35
 Dw   96, 109, 184,  99
 Dw   96, 110,  91,  31
 Dw   96, 111, 195, 147
 Dw   96, 112, 238,  16
 Dw   96, 113,  24,  11
 Dw   96, 114,  34, 159
 Dw   96, 115, 257,  76
 Dw   96, 116, 195,  87
 Dw   96, 117, 237,  98
 Dw   96, 118, 109, 163
 Dw   96, 119, 261,  28
 Dw   97, 104,  29,  13
 Dw   97, 105,  19,  38
 Dw   97, 106, 215,  45
 Dw   97, 107, 182,  50
 Dw   97, 108, 117, 167
 Dw   97, 109, 100,  62
 Dw   97, 110, 210, 138
 Dw   97, 111, 288,  63
 Dw   97, 112, 153,  59
 Dw   97, 113, 245, 148
 Dw   97, 114, 176, 144
 Dw   97, 115, 131, 108
 Dw   97, 116, 190, 176
 Dw   97, 117, 214,  22
 Dw   97, 118, 150,  80
 Dw   97, 119,  36,  10
 Dw   97, 120, 175, 134
 Dw   98, 104,  25, 184
 Dw   98, 105, 268, 136
 Dw   98, 106, 296,  55
 Dw   98, 107, 224, 146
 Dw   98, 114, 159, 132
 Dw   98, 115,  50,  46
 Dw   98, 116, 302,  72
 Dw   98, 117,  40, 197
 Dw   98, 118,  98,  10
 Dw   98, 119,  32, 173
 Dw   98, 120, 177, 139
 Dw   98, 121,  32, 133
 Dw   99, 104,   5,  61
 Dw   99, 105, 289, 107
 Dw   99, 106, 104,  88
 Dw   99, 107, 288,  69
 Dw   99, 115, 113,  97
 Dw   99, 116,  22, 170
 Dw   99, 117, 243,  36
 Dw   99, 118, 295,  98
 Dw   99, 119,  40, 178
 Dw   99, 120, 129,  41
 Dw   99, 121, 258, 117
 Dw   99, 122,  35, 124
 Dw  100, 104, 296, 108
 Dw  100, 105, 104,  89
 Dw  100, 106,  72,  36
 Dw  100, 107, 220, 199
 Dw  100, 116, 201, 138
 Dw  100, 117, 173,  19
 Dw  100, 118, 239,  29
 Dw  100, 119,  74, 176
 Dw  100, 120, 228,  87
 Dw  100, 121, 313,  30
 Dw  100, 122,  12,  36
 Dw  100, 123,   3,  75
 Dw  101, 104, 126,  72
 Dw  101, 105,  26,  90
 Dw  101, 106, 161,  92
 Dw  101, 107, 216, 163
 Dw  101, 117, 181,  50
 Dw  101, 118, 119, 116
 Dw  101, 119, 279, 121
 Dw  101, 120,  82, 139
 Dw  101, 121, 178, 175
 Dw  101, 122, 115,  72
 Dw  101, 123, 198, 156
 Dw  101, 124, 146,  41
 Dw  102, 104, 223, 167
 Dw  102, 105, 240, 180
 Dw  102, 106,  59, 155
 Dw  102, 107,  85,  59
 Dw  102, 108, 224,  91
 Dw  102, 109, 308,  37
 Dw  102, 110,   3,  44
 Dw  102, 111, 287,  64
 Dw  102, 112, 276, 152
 Dw  102, 113, 309,  54
 Dw  102, 118, 126, 167
 Dw  102, 119,   6,  49
 Dw  102, 120,  16, 101
 Dw  102, 121, 135,   0
 Dw  102, 122,  48, 141
 Dw  102, 123,  99,  79
 Dw  102, 124, 175,  52
 Dw  103, 104,  48,  58
 Dw  103, 105,  24, 141
 Dw  103, 106, 105, 157
 Dw  103, 107, 209, 113
 Dw  103, 108, 286,   4
 Dw  103, 109,  81, 176
 Dw  103, 110, 219,   6
 Dw  103, 111,  50,  31
 Dw  103, 112, 132,  83
 Dw  103, 113,  45,   0
 Dw  103, 119, 169, 152
 Dw  103, 120, 182,  46
 Dw  103, 121, 275,  12
 Dw  103, 122, 155,  15
 Dw  103, 123, 117, 132
 Dw  103, 124,  65, 160
 Dw  104, 104, 166,  83
 Dw  104, 105,  12, 198
 Dw  104, 106,  51,   9
 Dw  104, 107,  18,  20
 Dw  104, 108, 257, 190
 Dw  104, 109,  36,  42
 Dw  104, 110, 244, 196
 Dw  104, 111, 159,   6
 Dw  104, 112, 189, 160
 Dw  104, 113, 295, 102
 Dw  104, 114, 211, 199
 Dw  104, 120, 246, 143
 Dw  104, 121, 286, 198
 Dw  104, 122, 234, 156
 Dw  104, 123,   5,  73
 Dw  104, 124, 102,  14
 Dw  105, 104, 250,  52
 Dw  105, 105, 273, 183
 Dw  105, 106,  15, 178
 Dw  105, 107, 295,  97
 Dw  105, 108, 220,  75
 Dw  105, 109, 135, 149
 Dw  105, 110, 222,  68
 Dw  105, 111, 201, 101
 Dw  105, 112, 310,  20
 Dw  105, 113, 316,   4
 Dw  105, 114, 197,  71
 Dw  105, 115, 163, 129
 Dw  105, 120, 259, 127
 Dw  105, 121, 304,  99
 Dw  105, 122, 155, 199
 Dw  105, 123,  76,  39
 Dw  105, 124, 140, 137
 Dw  106,  75, 242,   6
 Dw  106,  76, 196, 160
 Dw  106,  77, 148,  33
 Dw  106,  78, 203,  14
 Dw  106,  79, 307, 157
 Dw  106,  80, 278,  86
 Dw  106,  81,   1,  44
 Dw  106,  82, 184, 176
 Dw  106,  83,  18,  94
 Dw  106,  84, 298, 173
 Dw  106,  85, 275, 144
 Dw  106,  86, 313,  42
 Dw  106,  87,  49, 132
 Dw  106,  88, 264,  37
 Dw  106, 104,   5, 163
 Dw  106, 105, 179,  93
 Dw  106, 106, 140,  29
 Dw  106, 107, 255, 174
 Dw  106, 108,  30, 119
 Dw  106, 109, 255,  43
 Dw  106, 110, 151,  80
 Dw  106, 111, 160, 140
 Dw  106, 112, 249,  63
 Dw  106, 113,  11, 120
 Dw  106, 114,  93,  11
 Dw  106, 115, 149,  43
 Dw  106, 120,  26, 131
 Dw  106, 121, 273,  68
 Dw  106, 122,  97,  94
 Dw  106, 123, 293, 144
 Dw  106, 124, 131,  16
 Dw  107,  75, 258,  50
 Dw  107,  76,  11,  69
 Dw  107,  77, 283, 172
 Dw  107,  78, 140,  50
 Dw  107,  79, 134,  73
 Dw  107,  80, 208,  85
 Dw  107,  81, 203, 151
 Dw  107,  82, 260,  91
 Dw  107,  83, 171, 123
 Dw  107,  84,  98,  48
 Dw  107,  85, 130, 144
 Dw  107,  86, 209,  35
 Dw  107,  87, 307,   7
 Dw  107,  88, 103, 178
 Dw  107, 104, 149, 102
 Dw  107, 105, 280, 134
 Dw  107, 106, 132, 116
 Dw  107, 107,  46, 195
 Dw  107, 110, 150,  30
 Dw  107, 111, 100, 122
 Dw  107, 112, 261,  96
 Dw  107, 113,  43,  93
 Dw  107, 114,  46,  66
 Dw  107, 115, 211, 164
 Dw  107, 120, 274,  31
 Dw  107, 121,  56, 149
 Dw  107, 122,  88,  68
 Dw  107, 123,  79,   7
 Dw  107, 124, 288, 137
 Dw  108,  75,  25, 132
 Dw  108,  76,   4, 123
 Dw  108,  77, 186, 154
 Dw  108,  78,  61, 178
 Dw  108,  79, 259, 128
 Dw  108,  80, 156, 156
 Dw  108,  81, 239,  38
 Dw  108,  82, 120, 181
 Dw  108,  83, 168, 174
 Dw  108,  84, 232,  59
 Dw  108,  85, 189,  21
 Dw  108,  86, 110,  70
 Dw  108,  87, 135, 114
 Dw  108,  88, 292, 135
 Dw  108, 111, 236, 199
 Dw  108, 112, 114,  19
 Dw  108, 113, 128,  55
 Dw  108, 114, 295,  47
 Dw  108, 115, 124,  16
 Dw  108, 120, 169, 102
 Dw  108, 121, 171,  44
 Dw  108, 122,  62,  83
 Dw  108, 123, 310, 100
 Dw  108, 124, 185,  74
 Dw  109,  75, 120, 157
 Dw  109,  76, 292, 136
 Dw  109,  77, 183, 105
 Dw  109,  78, 297,  45
 Dw  109,  79,   7, 195
 Dw  109,  80, 158, 194
 Dw  109,  81,  66, 165
 Dw  109,  82,  30,  86
 Dw  109,  83,  19, 199
 Dw  109,  84, 123, 140
 Dw  109,  85, 276, 164
 Dw  109,  86, 126, 131
 Dw  109,  87,  88, 173
 Dw  109,  88,  58,  73
 Dw  109, 111, 131,  16
 Dw  109, 112, 309,   1
 Dw  109, 113,  59,  20
 Dw  109, 114,  20, 127
 Dw  109, 115,  87, 160
 Dw  109, 120,  37, 138
 Dw  109, 121, 130,  97
 Dw  109, 122, 166,  20
 Dw  109, 123, 300,  64
 Dw  109, 124, 304,  54
 Dw  110,  75, 253, 171
 Dw  110,  76, 134, 100
 Dw  110,  77,  91, 145
 Dw  110,  78, 107,  85
 Dw  110,  79, 138, 194
 Dw  110,  80, 115, 117
 Dw  110,  81, 227,  96
 Dw  110,  82,  56,  64
 Dw  110,  83, 133,  96
 Dw  110,  84, 113,  93
 Dw  110,  85,  20,  36
 Dw  110,  86, 319, 110
 Dw  110,  87, 146, 178
 Dw  110,  88, 262, 118
 Dw  110,  89, 133,  59
 Dw  110,  90, 269, 115
 Dw  110,  91,  90, 128
 Dw  110,  92, 281,  50
 Dw  110,  93, 199,   9
 Dw  110,  94, 151, 164
 Dw  110,  95, 277,  44
 Dw  110,  96, 312, 133
 Dw  110,  97, 224,  53
 Dw  110,  98, 289,  47
 Dw  110,  99, 153,  70
 Dw  110, 100, 258, 121
 Dw  110, 101,   7,  83
 Dw  110, 102,  73,  98
 Dw  110, 103, 163,  50
 Dw  110, 104, 177, 120
 Dw  110, 105, 107, 114
 Dw  110, 106, 244, 140
 Dw  110, 107,  51, 184
 Dw  110, 108, 141, 142
 Dw  110, 109, 178, 109
 Dw  110, 110, 164, 146
 Dw  110, 111, 286, 109
 Dw  110, 112, 193, 169
 Dw  110, 113, 136,   4
 Dw  110, 114, 302,   7
 Dw  110, 115, 234, 181
 Dw  110, 120,  83, 128
 Dw  110, 121, 298, 156
 Dw  110, 122,  18,  19
 Dw  110, 123, 114, 176
 Dw  110, 124,  65, 188
 Dw  111,  75, 187, 197
 Dw  111,  76, 253,  77
 Dw  111,  77,   8,   4
 Dw  111,  78, 194, 157
 Dw  111,  79, 150, 101
 Dw  111,  84, 236, 186
 Dw  111,  85,  89,  32
 Dw  111,  86,  43, 198
 Dw  111,  87,  42,  67
 Dw  111,  88,  49,  83
 Dw  111,  89, 159,  20
 Dw  111,  90, 121,  59
 Dw  111,  91,  87,  13
 Dw  111,  92,  95, 168
 Dw  111,  93,  77,  74
 Dw  111,  94, 187,  11
 Dw  111,  95,  84,  78
 Dw  111,  96,  24, 152
 Dw  111,  97, 132,   6
 Dw  111,  98, 228, 103
 Dw  111,  99, 141, 145
 Dw  111, 100,   1,  19
 Dw  111, 101,  76, 105
 Dw  111, 102, 258, 124
 Dw  111, 103,  84, 167
 Dw  111, 104, 152,  91
 Dw  111, 105,  13, 133
 Dw  111, 106, 213,  85
 Dw  111, 107,  74, 115
 Dw  111, 108, 112,  18
 Dw  111, 109, 273, 116
 Dw  111, 110, 268,   4
 Dw  111, 111, 214, 133
 Dw  111, 112, 270,  72
 Dw  111, 113, 265, 160
 Dw  111, 114, 294,  15
 Dw  111, 115,  84, 103
 Dw  111, 120, 238, 155
 Dw  111, 121, 144,  77
 Dw  111, 122,  54, 178
 Dw  111, 123, 151,  28
 Dw  111, 124, 297, 124
 Dw  112,  75, 189,  17
 Dw  112,  76, 142,   7
 Dw  112,  77, 223,  27
 Dw  112,  78,  61,  19
 Dw  112,  79, 111, 124
 Dw  112,  84, 139, 114
 Dw  112,  85,  96, 138
 Dw  112,  86, 131,  18
 Dw  112,  87, 228, 193
 Dw  112,  88,  69, 160
 Dw  112,  89, 136, 140
 Dw  112,  90, 314,  85
 Dw  112,  91,  11, 147
 Dw  112,  92,  34, 118
 Dw  112,  93, 196, 179
 Dw  112,  94, 194, 154
 Dw  112,  95, 102, 125
 Dw  112,  96, 278,  54
 Dw  112,  97,  83,  14
 Dw  112,  98, 120,   2
 Dw  112,  99, 104, 177
 Dw  112, 100,  56,  14
 Dw  112, 101, 278,  75
 Dw  112, 102,  50,  51
 Dw  112, 103, 151, 182
 Dw  112, 104, 134,  30
 Dw  112, 105,  38, 126
 Dw  112, 106,  97,  78
 Dw  112, 107, 182, 170
 Dw  112, 108, 267,  33
 Dw  112, 109, 237, 152
 Dw  112, 110, 221,  32
 Dw  112, 111, 114,  59
 Dw  112, 112, 295,  83
 Dw  112, 113,  69,  48
 Dw  112, 114,  11, 172
 Dw  112, 115, 268,   2
 Dw  112, 120,  58, 104
 Dw  112, 121,  90, 125
 Dw  112, 122, 174, 112
 Dw  112, 123, 148, 157
 Dw  112, 124,  57, 145
 Dw  113,  75,  78,  32
 Dw  113,  76, 282, 179
 Dw  113,  77,  29,  51
 Dw  113,  78, 286, 138
 Dw  113,  79,  38,  83
 Dw  113,  84, 138,  86
 Dw  113,  85, 250, 177
 Dw  113,  86, 132, 178
 Dw  113,  87, 181,   2
 Dw  113,  88, 281, 116
 Dw  113,  89, 126, 185
 Dw  113,  90, 292, 115
 Dw  113,  91, 207,  77
 Dw  113,  92,  39,  17
 Dw  113,  93, 318, 102
 Dw  113,  94, 309,  55
 Dw  113,  95, 128, 134
 Dw  113,  96, 150,  12
 Dw  113,  97,  26, 151
 Dw  113,  98,  47, 175
 Dw  113,  99,  67, 110
 Dw  113, 100,  50, 122
 Dw  113, 101, 204, 190
 Dw  113, 102, 313,  53
 Dw  113, 103,   3,  52
 Dw  113, 104,  63, 196
 Dw  113, 105, 306, 162
 Dw  113, 106,  47, 104
 Dw  113, 107,  91, 120
 Dw  113, 108, 162,  62
 Dw  113, 109, 104, 155
 Dw  113, 110,  26, 136
 Dw  113, 111, 285,   9
 Dw  113, 112, 124, 181
 Dw  113, 113, 153,  82
 Dw  113, 114, 255,  18
 Dw  113, 115, 217, 173
 Dw  113, 120,  90,  25
 Dw  113, 121, 290, 162
 Dw  113, 122,  27,  48
 Dw  113, 123, 305,  78
 Dw  113, 124, 273, 155
 Dw  114,  75, 302,  21
 Dw  114,  76,   0,  56
 Dw  114,  77, 227,  47
 Dw  114,  78, 128,  20
 Dw  114,  79, 216,   6
 Dw  114,  84, 211, 195
 Dw  114,  85, 230, 138
 Dw  114,  86, 176,  66
 Dw  114,  87, 216, 111
 Dw  114,  88, 117,  65
 Dw  114,  89, 126,  19
 Dw  114,  90,  93, 158
 Dw  114,  91, 171, 109
 Dw  114,  92,   9, 134
 Dw  114,  93, 160,  63
 Dw  114,  94,  94, 112
 Dw  114,  95,  69, 105
 Dw  114,  96, 290,  86
 Dw  114,  97, 205,  54
 Dw  114,  98, 183, 144
 Dw  114,  99,  67,  98
 Dw  114, 100, 210,  64
 Dw  114, 101, 190, 106
 Dw  114, 102, 139,  26
 Dw  114, 103, 164, 156
 Dw  114, 104, 226,  44
 Dw  114, 105, 138, 193
 Dw  114, 106, 240, 161
 Dw  114, 107, 132,   1
 Dw  114, 108, 298, 108
 Dw  114, 109, 149,  92
 Dw  114, 110, 174, 165
 Dw  114, 111,  31,  10
 Dw  114, 112, 202,  35
 Dw  114, 113,   2, 140
 Dw  114, 114, 283, 162
 Dw  114, 120,  16,  28
 Dw  114, 121, 274,   5
 Dw  114, 122, 299,   1
 Dw  114, 123,  33, 197
 Dw  114, 124,  92, 190
 Dw  115,  75,   0,  12
 Dw  115,  76,  21,  48
 Dw  115,  77,  97, 154
 Dw  115,  78, 126, 161
 Dw  115,  79, 237, 194
 Dw  115,  84, 116, 156
 Dw  115,  85,  64, 190
 Dw  115,  86, 116, 185
 Dw  115,  87,  88,  74
 Dw  115,  88, 299, 108
 Dw  115,  89,  86,  84
 Dw  115,  90,  88, 144
 Dw  115,  91, 281, 107
 Dw  115,  92, 272,  13
 Dw  115,  93,  64,  95
 Dw  115,  94, 241,  38
 Dw  115,  95, 242, 152
 Dw  115,  96, 247, 136
 Dw  115,  97, 215, 132
 Dw  115,  98,  87,  66
 Dw  115,  99,  77,  48
 Dw  115, 100, 130, 145
 Dw  115, 101, 142,  40
 Dw  115, 102,  76, 131
 Dw  115, 103,  83, 100
 Dw  115, 104, 240, 163
 Dw  115, 105, 234, 195
 Dw  115, 106, 290, 150
 Dw  115, 107,  52,  88
 Dw  115, 108,  51,  35
 Dw  115, 109, 300,  13
 Dw  115, 110,  36, 178
 Dw  115, 111, 260, 178
 Dw  115, 112,  76,  16
 Dw  115, 113, 211, 172
 Dw  115, 120, 259, 144
 Dw  115, 121,  10, 150
 Dw  115, 122, 167,  56
 Dw  115, 123,  11, 149
 Dw  115, 124, 129,   5
 Dw  116,  75, 107, 141
 Dw  116,  76, 317, 113
 Dw  116,  77, 118,  59
 Dw  116,  78, 297, 103
 Dw  116,  79, 313,  95
 Dw  116, 119, 124,  65
 Dw  116, 120,  38,  21
 Dw  116, 121,   7, 142
 Dw  116, 122, 107, 129
 Dw  116, 123, 110,  46
 Dw  116, 124,  46,  27
 Dw  117,  75, 227, 178
 Dw  117,  76, 178,  11
 Dw  117,  77, 105, 187
 Dw  117,  78,  97, 126
 Dw  117,  79, 317,  13
 Dw  117, 118, 186, 150
 Dw  117, 119, 126, 170
 Dw  117, 120, 110, 119
 Dw  117, 121,  88,   9
 Dw  117, 122, 137, 100
 Dw  117, 123, 243,   2
 Dw  118,  75,  36, 170
 Dw  118,  76, 189, 116
 Dw  118,  77, 260, 173
 Dw  118,  78,  58, 191
 Dw  118,  79,  25, 129
 Dw  118, 117, 202, 104
 Dw  118, 118,  22, 168
 Dw  118, 119,  49, 138
 Dw  118, 120,  53, 160
 Dw  118, 121, 188,  17
 Dw  118, 122, 130,  11
 Dw  118, 123, 287, 150
 Dw  119,  75, 288,  95
 Dw  119,  76, 266,  33
 Dw  119,  77, 140, 107
 Dw  119,  78,  64,  51
 Dw  119,  79, 279,  87
 Dw  119, 116, 123, 136
 Dw  119, 117,  23,   9
 Dw  119, 118,  13,  16
 Dw  119, 119, 159, 186
 Dw  119, 120,  60,  10
 Dw  119, 121, 214, 188
 Dw  119, 122,   8,  16
 Dw  119, 123,  36,  17
 Dw  120,  75,  74, 133
 Dw  120,  76, 174, 133
 Dw  120,  77, 206,  69
 Dw  120,  78, 117, 186
 Dw  120,  79, 141,  88
 Dw  120, 115, 244, 146
 Dw  120, 116, 110, 116
 Dw  120, 117, 298, 178
 Dw  120, 118, 132,  94
 Dw  120, 119,  84,  59
 Dw  120, 120, 134,  91
 Dw  120, 121, 165, 186
 Dw  120, 122, 305, 138
 Dw  121,  75,  87,  66
 Dw  121,  76, 217,  27
 Dw  121,  77,  69,  43
 Dw  121,  78, 134, 126
 Dw  121,  79,  19,  56
 Dw  121, 114, 313, 150
 Dw  121, 115,  45,  68
 Dw  121, 116, 286,  44
 Dw  121, 117, 315,  74
 Dw  121, 118, 168,   7
 Dw  121, 119, 126,  25
 Dw  121, 120,  48, 134
 Dw  121, 121, 275,  78
 Dw  122,  75,   3, 189
 Dw  122,  76, 104, 195
 Dw  122,  77, 140,  83
 Dw  122,  78, 199,  22
 Dw  122,  79, 176,  82
 Dw  122,  84,  38, 160
 Dw  122,  85,  30,  18
 Dw  122,  86, 111,  47
 Dw  122,  87, 145,  16
 Dw  122,  88, 226,  97
 Dw  122,  89, 300, 121
 Dw  122,  90, 166, 178
 Dw  122,  91, 249,  37
 Dw  122,  92, 305, 192
 Dw  122,  93, 165,  53
 Dw  122,  94, 214, 146
 Dw  122,  95, 228,  86
 Dw  122,  96,  61, 158
 Dw  122,  97,  39, 193
 Dw  122,  98,  97, 110
 Dw  122,  99, 249, 197
 Dw  122, 100,  17,  68
 Dw  122, 101, 209,  83
 Dw  122, 102,  39, 101
 Dw  122, 103, 263,  95
 Dw  122, 104, 198, 105
 Dw  122, 105,  88,  95
 Dw  122, 106, 192, 174
 Dw  122, 107, 271,  21
 Dw  122, 108, 278,  19
 Dw  122, 109, 284, 102
 Dw  122, 110, 265,  72
 Dw  122, 111, 204, 160
 Dw  122, 112, 148,  96
 Dw  122, 113, 137, 169
 Dw  122, 114, 227,   5
 Dw  122, 115,  65,  87
 Dw  122, 116, 262,  48
 Dw  122, 117, 304,  47
 Dw  122, 118, 140, 140
 Dw  122, 119,  11,  16
 Dw  122, 120, 164,   4
 Dw  123,  75, 177,  92
 Dw  123,  76,  95,   3
 Dw  123,  77,  55,  78
 Dw  123,  78, 315,  22
 Dw  123,  79,  30, 184
 Dw  123,  84, 255, 194
 Dw  123,  85,  27, 194
 Dw  123,  86, 181, 109
 Dw  123,  87, 236,  65
 Dw  123,  88,  25,  17
 Dw  123,  89, 119, 173
 Dw  123,  90, 256, 156
 Dw  123,  91,  93,  92
 Dw  123,  92, 213,  17
 Dw  123,  93,  81,  14
 Dw  123,  94,  34, 183
 Dw  123,  95, 121, 195
 Dw  123,  96, 163,  37
 Dw  123,  97, 289,  30
 Dw  123,  98, 232, 100
 Dw  123,  99, 133,  55
 Dw  123, 100, 118, 177
 Dw  123, 101, 182, 172
 Dw  123, 102,   0, 176
 Dw  123, 103, 121,  88
 Dw  123, 104, 151,  79
 Dw  123, 105, 170, 178
 Dw  123, 106, 306,  27
 Dw  123, 107, 138,  49
 Dw  123, 108, 164, 111
 Dw  123, 109, 268, 126
 Dw  123, 110,  60, 108
 Dw  123, 111, 101,  36
 Dw  123, 112, 307,  74
 Dw  123, 113, 284,   2
 Dw  123, 114,  28, 125
 Dw  123, 115, 187, 125
 Dw  123, 116, 211,  15
 Dw  123, 117, 257,  83
 Dw  123, 118, 113, 153
 Dw  123, 119, 205,   0
 Dw  124,  75, 247, 155
 Dw  124,  76, 204, 130
 Dw  124,  77, 264,  76
 Dw  124,  78, 187,   5
 Dw  124,  79,   4, 129
 Dw  124,  84, 114, 190
 Dw  124,  85, 202, 127
 Dw  124,  86, 279,   3
 Dw  124,  87,  63, 142
 Dw  124,  88, 218,  22
 Dw  124,  89, 208, 151
 Dw  124,  90, 254,  58
 Dw  124,  91,  36,  29
 Dw  124,  92, 225, 118
 Dw  124,  93,  90, 175
 Dw  124,  94, 244, 114
 Dw  124,  95, 223,  35
 Dw  124,  96, 108, 157
 Dw  124,  97, 167,  93
 Dw  124,  98, 133,  99
 Dw  124,  99, 167, 108
 Dw  124, 100, 183,  51
 Dw  124, 101, 122,  61
 Dw  124, 102, 164,  37
 Dw  124, 103, 193,  96
 Dw  124, 104, 172,  21
 Dw  124, 105, 181,   8
 Dw  124, 106, 218, 169
 Dw  124, 107, 163,  69
 Dw  124, 108, 124,  72
 Dw  124, 109, 166,  54
 Dw  124, 110, 299,  97
 Dw  124, 111, 254, 140
 Dw  124, 112, 319,  93
 Dw  124, 113, 239,  48
 Dw  124, 114,  12, 125
 Dw  124, 115, 236,  10
 Dw  124, 116, 147, 154
 Dw  124, 117, 150,  13
 Dw  124, 118, 210,  30
 Dw  125,  75, 124,  20
 Dw  125,  76, 134,  33
 Dw  125,  77, 183, 104
 Dw  125,  78, 109,  28
 Dw  125,  79, 304, 113
 Dw  125,  84,  57, 143
 Dw  125,  85, 284,  81
 Dw  125,  86,  97, 168
 Dw  125,  87, 139, 116
 Dw  125,  88, 215,  73
 Dw  125,  89, 246,  90
 Dw  125,  90,   9, 128
 Dw  125,  91, 213, 128
 Dw  125,  92,  62, 148
 Dw  125,  93, 319, 163
 Dw  125,  94, 217,  28
 Dw  125,  95, 188,  24
 Dw  125,  96, 315, 197
 Dw  125,  97, 313,  28
 Dw  125,  98, 103,  56
 Dw  125,  99, 276,  67
 Dw  125, 100, 193, 130
 Dw  125, 101,  89,  25
 Dw  125, 102, 308, 100
 Dw  125, 103, 261,  40
 Dw  125, 104,  41, 136
 Dw  125, 105, 141, 143
 Dw  125, 106, 130,   6
 Dw  125, 107, 211,  83
 Dw  125, 108,  48,  86
 Dw  125, 109,  47, 169
 Dw  125, 110, 287,  32
 Dw  125, 111,  21,  49
 Dw  125, 112, 193, 152
 Dw  125, 113, 216, 144
 Dw  125, 114, 199, 128
 Dw  125, 115,   4, 165
 Dw  125, 116, 125,  38
 Dw  125, 117, 212, 133
 Dw  126,  75, 310,  21
 Dw  126,  76, 310,  14
 Dw  126,  77, 266,  25
 Dw  126,  78,  60, 113
 Dw  126,  79, 208, 112
 Dw  126,  80, 125,  21
 Dw  126,  81, 290,  23
 Dw  126,  82,  59, 167
 Dw  126,  83, 191, 195
 Dw  126,  84, 165,  62
 Dw  126,  85, 109,  42
 Dw  126,  86,  43, 194
 Dw  126,  87, 223, 175
 Dw  126,  88, 154, 169
 Dw  126,  89, 151,  75
 Dw  126,  90,  29, 130
 Dw  126,  91, 103,   8
 Dw  126,  92, 240, 171
 Dw  126,  93, 305, 185
 Dw  126,  94,   7,  81
 Dw  126,  95, 220,  50
 Dw  126,  96, 275,  21
 Dw  126,  97,  81,  17
 Dw  126,  98, 142, 171
 Dw  126,  99,   1,  21
 Dw  126, 100, 147,  59
 Dw  126, 101, 311, 115
 Dw  126, 102, 126, 101
 Dw  126, 103, 144, 176
 Dw  126, 104, 220, 171
 Dw  126, 105, 315,  49
 Dw  126, 106, 221,  20
 Dw  126, 107, 315,  94
 Dw  126, 108, 271,  70
 Dw  126, 109, 118, 164
 Dw  126, 110, 168, 108
 Dw  126, 111, 290,  80
 Dw  126, 112, 126,  85
 Dw  126, 113,  54, 131
 Dw  126, 114, 111,  73
 Dw  126, 115,  96, 171
 Dw  126, 116,  77,  64
 Dw  127,  75, 310, 120
 Dw  127,  76,  28, 164
 Dw  127,  77,  79, 167
 Dw  127,  78, 119, 187
 Dw  127,  79,  84, 175
 Dw  127,  80, 215,  84
 Dw  127,  81, 275,  66
 Dw  127,  82, 246, 100
 Dw  127,  83, 208,  14
 Dw  127,  84, 275,  31
 Dw  127,  85,  44, 111
 Dw  127,  86, 209, 147
 Dw  127,  87, 272,  29
 Dw  127,  88, 123,  45
 Dw  128,  75, 201,  55
 Dw  128,  76,  14, 129
 Dw  128,  77, 164, 110
 Dw  128,  78, 131,  59
 Dw  128,  79, 287,  36
 Dw  128,  80, 195, 166
 Dw  128,  81, 272,  69
 Dw  128,  82, 102,  81
 Dw  128,  83, 262,  61
 Dw  128,  84, 275,  77
 Dw  128,  85,  26,  89
 Dw  128,  86, 247,  69
 Dw  128,  87, 216, 109
 Dw  128,  88, 200,  67
 Dw  129,  75, 220, 180
 Dw  129,  76,  42, 133
 Dw  129,  77,  24,  40
 Dw  129,  78, 278, 135
 Dw  129,  79, 154,  41
 Dw  129,  80,  47,  44
 Dw  129,  81, 213, 123
 Dw  129,  82, 255, 182
 Dw  129,  83, 157, 150
 Dw  129,  84, 316,  49
 Dw  129,  85, 215, 171
 Dw  129,  86,  91,  45
 Dw  129,  87, 205,  48
 Dw  129,  88, 185,  15
 Dw  130,  75,  84,  91
 Dw  130,  76, 199,  35
 Dw  130,  77,  88,  53
 Dw  130,  78,  77,  67
 Dw  130,  79, 220,  43
 Dw  130,  80, 177, 189
 Dw  130,  81, 148, 174
 Dw  130,  82, 210, 151
 Dw  130,  83,  87,  24
 Dw  130,  84, 213,  37
 Dw  130,  85,  42,  40
 Dw  130,  86,  41, 105
 Dw  130,  87,  62,  42
 Dw  130,  88,  15,  76
 Dw  136,  83,   6,  51
 Dw  136,  85,  57,  42
 Dw  136,  86,  28, 127
 Dw  136,  87,  90, 167
 Dw  136,  88, 133, 124
 Dw  136,  89, 142,  49
 Dw  136,  90, 146, 137
 Dw  136,  91, 242,  29
 Dw  136,  92, 237,  69
 Dw  136,  93, 279, 192
 Dw  136,  94, 284, 184
 Dw  136,  95,  86,  63
 Dw  136,  96, 297, 167
 Dw  136,  97,  80,  41
 Dw  136,  98,  34,  71
 Dw  137,  82, 310,  72
 Dw  137,  83, 193, 162
 Dw  137,  84,  15, 101
 Dw  137,  85, 259, 142
 Dw  137,  86, 185, 108
 Dw  137,  87,  35,  69
 Dw  137,  88, 175, 163
 Dw  137,  89, 107, 145
 Dw  137,  90, 309,  19
 Dw  137,  91,  99, 194
 Dw  137,  92, 100, 158
 Dw  137,  93,  45, 104
 Dw  137,  94, 318, 118
 Dw  137,  95,  72, 158
 Dw  137,  96, 307, 130
 Dw  137,  97,  27,   9
 Dw  137,  98, 225, 160
 Dw  137,  99, 155, 148
 Dw  137, 107,  76, 122
 Dw  137, 108, 167, 113
 Dw  137, 109, 260,  31
 Dw  137, 110, 179, 170
 Dw  137, 111, 139, 171
 Dw  137, 112,  72,  46
 Dw  137, 113, 161, 151
 Dw  137, 114, 275, 116
 Dw  137, 115,  22,  16
 Dw  137, 116,  35, 139
 Dw  138,  81, 175, 191
 Dw  138,  82, 188,  45
 Dw  138,  83, 296, 122
 Dw  138,  84, 242, 161
 Dw  138,  85, 235,  99
 Dw  138,  86, 147,  80
 Dw  138,  87, 123,  11
 Dw  138,  88, 250,  69
 Dw  138,  89, 194,  39
 Dw  138,  90,  57, 110
 Dw  138,  91,  23, 111
 Dw  138,  92, 315, 169
 Dw  138,  93, 164,  48
 Dw  138,  94, 252, 107
 Dw  138,  95, 260, 114
 Dw  138,  96, 103,  94
 Dw  138,  97, 312, 197
 Dw  138,  98, 248,  65
 Dw  138,  99, 289,  46
 Dw  138, 107, 227, 184
 Dw  138, 108, 119,  71
 Dw  138, 109,   8, 131
 Dw  138, 110, 223,  54
 Dw  138, 111, 192,  94
 Dw  138, 112, 293, 159
 Dw  138, 113, 185, 174
 Dw  138, 114, 161, 101
 Dw  138, 115, 134,   0
 Dw  138, 116, 309, 156
 Dw  138, 117,  63, 143
 Dw  139,  80, 254, 174
 Dw  139,  81, 245,  29
 Dw  139,  82, 206, 178
 Dw  139,  83, 238,  54
 Dw  139,  84, 231,   7
 Dw  139,  85, 151,  88
 Dw  139,  86, 240,  91
 Dw  139,  87, 122, 178
 Dw  139,  88, 308, 114
 Dw  139,  89, 140, 124
 Dw  139,  90,   7, 151
 Dw  139,  91, 182,  54
 Dw  139,  92, 271, 136
 Dw  139,  93,  93, 176
 Dw  139,  94, 214, 155
 Dw  139,  95, 284, 102
 Dw  139,  96, 269, 101
 Dw  139,  97, 282,  57
 Dw  139,  98,  79, 108
 Dw  139,  99, 214,  54
 Dw  139, 100,  95, 191
 Dw  139, 107, 173,  38
 Dw  139, 108, 269,   1
 Dw  139, 109, 140,   0
 Dw  139, 110, 175,  33
 Dw  139, 111,  66, 148
 Dw  139, 112, 172,  99
 Dw  139, 113,  56,  43
 Dw  139, 114,  97,  91
 Dw  139, 115, 102,  85
 Dw  139, 116,  80, 148
 Dw  139, 117, 118, 164
 Dw  139, 118, 115, 173
 Dw  140,  80, 177, 144
 Dw  140,  81, 261,  85
 Dw  140,  82, 293, 110
 Dw  140,  83, 195,  60
 Dw  140,  84, 112, 150
 Dw  140,  85, 139,  68
 Dw  140,  86, 256,  80
 Dw  140,  87, 127,  31
 Dw  140,  88,  88,   9
 Dw  140,  89, 128,  18
 Dw  140,  90, 196,  35
 Dw  140,  91,  47, 115
 Dw  140,  92,  54,  73
 Dw  140,  93,  53,  70
 Dw  140,  94, 271,  15
 Dw  140,  95, 105,  51
 Dw  140,  96,  41, 110
 Dw  140,  97, 223, 137
 Dw  140,  98,  18,  70
 Dw  140,  99, 234, 154
 Dw  140, 100,  96,  93
 Dw  140, 101,  49, 190
 Dw  140, 107, 249,   4
 Dw  140, 108,  12, 105
 Dw  140, 109, 149,   3
 Dw  140, 110, 281,  49
 Dw  140, 111,  98, 131
 Dw  140, 112, 235,  41
 Dw  140, 113, 147,  35
 Dw  140, 114, 226,  81
 Dw  140, 115,  75,  41
 Dw  140, 116, 101, 171
 Dw  140, 117, 130,  25
 Dw  140, 118, 184,  21
 Dw  140, 119, 277, 184
 Dw  141,  79, 256,  94
 Dw  141,  80, 236,  92
 Dw  141,  81, 144,  94
 Dw  141,  82, 124,  61
 Dw  141,  83, 181,  31
 Dw  141,  84,  16,  78
 Dw  141,  85, 181,  63
 Dw  141,  86, 283,  33
 Dw  141,  87, 160, 175
 Dw  141,  88, 247,  20
 Dw  141,  89, 316, 172
 Dw  141,  90,  48, 133
 Dw  141,  91, 147, 148
 Dw  141,  92, 203,  17
 Dw  141,  93, 147,  20
 Dw  141,  94, 105, 106
 Dw  141,  95,  13, 175
 Dw  141,  96, 307, 121
 Dw  141,  97, 193, 133
 Dw  141,  98, 110,  44
 Dw  141,  99, 211, 163
 Dw  141, 100, 241,  37
 Dw  141, 101, 124,  57
 Dw  141, 102,  57,  46
 Dw  141, 107, 304, 103
 Dw  141, 108, 201,  32
 Dw  141, 109, 303, 160
 Dw  141, 110, 291,  86
 Dw  141, 111, 153, 176
 Dw  141, 112, 166,  63
 Dw  141, 113, 219, 147
 Dw  141, 114, 198,  93
 Dw  141, 115, 242, 173
 Dw  141, 116,  72, 111
 Dw  141, 117, 229,  88
 Dw  141, 118,  22,  46
 Dw  141, 119, 186,  34
 Dw  141, 120, 244, 134
 Dw  142,  78, 189, 159
 Dw  142,  79,  70,  78
 Dw  142,  80, 217,  91
 Dw  142,  81, 164,  27
 Dw  142,  82, 114,  91
 Dw  142,  83, 171, 195
 Dw  142,  84, 213,  24
 Dw  142,  96,  69, 195
 Dw  142,  97, 294, 143
 Dw  142,  98,  41,   6
 Dw  142,  99, 102, 142
 Dw  142, 100, 237, 144
 Dw  142, 101, 233, 170
 Dw  142, 102, 219,  68
 Dw  142, 103,  51, 154
 Dw  142, 107, 225,  78
 Dw  142, 108, 243,  22
 Dw  142, 109,  79,  42
 Dw  142, 110, 112,  79
 Dw  142, 114, 274, 113
 Dw  142, 115, 262,  40
 Dw  142, 116, 241,  61
 Dw  142, 117, 288,  44
 Dw  142, 118, 106,  97
 Dw  142, 119,  50,  75
 Dw  142, 120, 141, 106
 Dw  142, 121,  61,  12
 Dw  143,  77, 214,  55
 Dw  143,  78, 129,  17
 Dw  143,  79,   6,  10
 Dw  143,  80, 261,  12
 Dw  143,  81, 213,  30
 Dw  143,  82, 256,  29
 Dw  143,  83, 224,  53
 Dw  143,  84, 228,  89
 Dw  143,  97,  16, 152
 Dw  143,  98, 242, 107
 Dw  143,  99, 317, 186
 Dw  143, 100, 201, 162
 Dw  143, 101, 298, 108
 Dw  143, 102, 229, 141
 Dw  143, 103, 111,  62
 Dw  143, 107, 289, 193
 Dw  143, 108,  38,  33
 Dw  143, 109, 105,  94
 Dw  143, 110, 192,  77
 Dw  143, 115, 171,  73
 Dw  143, 116,  61,   4
 Dw  143, 117, 303,  91
 Dw  143, 118,  70,  28
 Dw  143, 119, 187,  20
 Dw  143, 120, 137, 160
 Dw  143, 121, 137,  24
 Dw  143, 122, 122, 178
 Dw  144,  76, 284,  84
 Dw  144,  77, 170,  19
 Dw  144,  78,  79,  65
 Dw  144,  79, 271, 142
 Dw  144,  80,  23, 173
 Dw  144,  81,  50,  19
 Dw  144,  82, 295,  96
 Dw  144,  83, 212, 177
 Dw  144,  98, 285, 183
 Dw  144,  99,  85,  69
 Dw  144, 100, 244,  47
 Dw  144, 101, 209,  88
 Dw  144, 102, 280,  47
 Dw  144, 103,  93, 105
 Dw  144, 104, 293, 149
 Dw  144, 107, 242, 145
 Dw  144, 108,  91,  94
 Dw  144, 109,  33,  73
 Dw  144, 110, 233, 101
 Dw  144, 116,  43,  19
 Dw  144, 117, 123, 118
 Dw  144, 118, 259, 109
 Dw  144, 119, 140, 146
 Dw  144, 120,  45, 121
 Dw  144, 121,   9, 165
 Dw  144, 122, 109, 143
 Dw  144, 123,  46,  63
 Dw  145,  75,  17, 157
 Dw  145,  76, 179,  27
 Dw  145,  77, 281, 109
 Dw  145,  78,  42,  68
 Dw  145,  79, 209, 100
 Dw  145,  80,   1,  54
 Dw  145,  81,  20, 168
 Dw  145,  82, 150,  28
 Dw  145,  99, 196, 169
 Dw  145, 100, 195,  71
 Dw  145, 101,  13, 151
 Dw  145, 102, 303, 194
 Dw  145, 103, 216,  22
 Dw  145, 104, 217,  19
 Dw  145, 107, 101,   2
 Dw  145, 108,  99,  35
 Dw  145, 109, 213, 163
 Dw  145, 110, 222,  91
 Dw  145, 117, 127,  45
 Dw  145, 118, 261, 196
 Dw  145, 119, 100, 159
 Dw  145, 120, 259,   3
 Dw  145, 121,  93,  54
 Dw  145, 122,  32, 157
 Dw  145, 123, 282,  71
 Dw  145, 124, 191, 156
 Dw  146,  75, 251, 145
 Dw  146,  76, 112,  19
 Dw  146,  77, 193,  99
 Dw  146,  78,  44, 124
 Dw  146,  79, 172,  73
 Dw  146,  80, 257, 187
 Dw  146,  81, 304,  37
 Dw  146, 100, 134,  51
 Dw  146, 101, 318, 142
 Dw  146, 102, 170, 175
 Dw  146, 103, 218, 140
 Dw  146, 104,  16, 160
 Dw  146, 107,  37, 135
 Dw  146, 108, 187, 125
 Dw  146, 109, 240,   6
 Dw  146, 110,  86, 171
 Dw  146, 118, 294,  47
 Dw  146, 119, 124,  27
 Dw  146, 120, 313,  71
 Dw  146, 121,  94,  38
 Dw  146, 122, 260,  35
 Dw  146, 123, 161,  68
 Dw  146, 124, 180, 111
 Dw  147,  75, 303, 197
 Dw  147,  76, 248, 181
 Dw  147,  77, 218,  78
 Dw  147,  78, 129, 165
 Dw  147,  79, 206, 121
 Dw  147,  80, 101,  67
 Dw  147,  86,  67,  96
 Dw  147,  87,  74,  60
 Dw  147,  88, 202, 195
 Dw  147,  89,  87, 163
 Dw  147,  90, 196,  54
 Dw  147,  91, 173, 161
 Dw  147,  92, 193,  96
 Dw  147,  93, 129,  21
 Dw  147,  94, 198, 160
 Dw  147,  95, 117, 123
 Dw  147, 100, 183,  95
 Dw  147, 101, 257,  95
 Dw  147, 102, 155,   1
 Dw  147, 103, 266,  58
 Dw  147, 104,  28,  61
 Dw  147, 107,  41, 161
 Dw  147, 108, 192, 166
 Dw  147, 109, 171, 121
 Dw  147, 110, 245, 184
 Dw  147, 111, 202, 153
 Dw  147, 112, 132, 163
 Dw  147, 119, 240,  97
 Dw  147, 120,  35,  12
 Dw  147, 121,   5,  18
 Dw  147, 122, 217,  68
 Dw  147, 123, 137,  12
 Dw  147, 124, 211, 191
 Dw  148,  75,  28, 172
 Dw  148,  76, 319,  74
 Dw  148,  77,   4, 150
 Dw  148,  78, 148, 131
 Dw  148,  79,  77, 178
 Dw  148,  86, 224, 154
 Dw  148,  87,  24,  80
 Dw  148,  88, 265, 174
 Dw  148,  89, 236,  33
 Dw  148,  90,   3,  44
 Dw  148,  91, 241, 108
 Dw  148,  92, 136,  76
 Dw  148,  93, 261,  66
 Dw  148,  94, 173, 130
 Dw  148,  95,   4, 122
 Dw  148, 100, 213,   9
 Dw  148, 101, 190,  52
 Dw  148, 102,  30,  50
 Dw  148, 103, 227,  69
 Dw  148, 104, 136,  64
 Dw  148, 107, 253, 135
 Dw  148, 108, 250,  12
 Dw  148, 109, 153,  33
 Dw  148, 110,  20,  77
 Dw  148, 111,  90, 168
 Dw  148, 112, 142,  18
 Dw  148, 113, 132, 126
 Dw  148, 120, 239, 160
 Dw  148, 121, 136,  56
 Dw  148, 122, 127,   9
 Dw  148, 123, 190, 198
 Dw  148, 124,  35, 150
 Dw  149,  75,  77, 128
 Dw  149,  76, 156, 114
 Dw  149,  77, 121, 151
 Dw  149,  78,  66, 167
 Dw  149,  79, 121, 102
 Dw  149,  85, 144,  16
 Dw  149,  86, 179,  76
 Dw  149,  87, 249,  83
 Dw  149,  88, 290,  78
 Dw  149,  89, 188,  31
 Dw  149,  90,  93, 188
 Dw  149,  91, 270, 110
 Dw  149,  92, 291, 135
 Dw  149,  93, 246,  97
 Dw  149,  94, 269, 189
 Dw  149,  95, 192,  94
 Dw  149,  96, 288, 146
 Dw  149, 100, 229,  76
 Dw  149, 101,  59,  34
 Dw  149, 102, 197, 127
 Dw  149, 103,  15, 199
 Dw  149, 104, 204, 173
 Dw  149, 107, 112, 110
 Dw  149, 108, 118,  61
 Dw  149, 109,  68,  36
 Dw  149, 110,  46,  59
 Dw  149, 111, 206,  32
 Dw  149, 112,  23, 152
 Dw  149, 113, 254, 101
 Dw  149, 114, 158, 113
 Dw  149, 120, 204,  48
 Dw  149, 121, 262,   0
 Dw  149, 122, 126,   7
 Dw  149, 123,  44, 177
 Dw  149, 124, 316,  57
 Dw  150,  75,  16,   9
 Dw  150,  76,  95,   3
 Dw  150,  77, 192,  18
 Dw  150,  78,  25,  39
 Dw  150,  79, 100, 159
 Dw  150,  84, 239,  68
 Dw  150,  85, 204, 106
 Dw  150,  86, 143, 102
 Dw  150,  87, 115,  91
 Dw  150,  88,  17,   7
 Dw  150,  89, 239, 107
 Dw  150,  90,  19, 131
 Dw  150,  91, 170, 103
 Dw  150,  92, 161, 163
 Dw  150,  93, 304,  84
 Dw  150,  94, 116,  65
 Dw  150,  95, 151,  57
 Dw  150,  96,  27, 143
 Dw  150, 100, 297,  12
 Dw  150, 101,  55, 171
 Dw  150, 102,  50,   2
 Dw  150, 103,   6, 155
 Dw  150, 104, 138,   3
 Dw  150, 107, 118, 141
 Dw  150, 108,  67, 109
 Dw  150, 109,  40, 157
 Dw  150, 110,  10,  55
 Dw  150, 111, 126, 196
 Dw  150, 112, 182, 118
 Dw  150, 113, 307,  19
 Dw  150, 114,  56,  94
 Dw  150, 115, 185,   4
 Dw  150, 120, 138,  91
 Dw  150, 121, 260,  99
 Dw  150, 122, 171, 145
 Dw  150, 123,  87,  15
 Dw  150, 124, 169,  93
 Dw  151,  75, 155,  27
 Dw  151,  76, 225,  12
 Dw  151,  77, 250, 199
 Dw  151,  78, 228, 167
 Dw  151,  79, 283, 109
 Dw  151,  84,  57,  60
 Dw  151,  85,  40,   4
 Dw  151,  86, 274,  36
 Dw  151,  87, 142, 135
 Dw  151,  88, 210, 129
 Dw  151,  89, 196, 125
 Dw  151,  90,  16, 112
 Dw  151,  91, 110,   7
 Dw  151,  92, 212, 137
 Dw  151,  93,  68,  85
 Dw  151,  94,  43,  13
 Dw  151,  95, 177, 171
 Dw  151,  96, 151,  18
 Dw  151, 100, 243,  27
 Dw  151, 101, 169,   1
 Dw  151, 102, 214,  75
 Dw  151, 103, 109, 157
 Dw  151, 104, 301, 120
 Dw  151, 107, 123, 129
 Dw  151, 108, 190,  23
 Dw  151, 109,  24, 142
 Dw  151, 110,  44, 180
 Dw  151, 111,  10,  96
 Dw  151, 112, 317,  54
 Dw  151, 113, 284,  34
 Dw  151, 114,  12,  96
 Dw  151, 115, 243,  22
 Dw  151, 120, 188,  26
 Dw  151, 121, 184, 140
 Dw  151, 122,  27,  79
 Dw  151, 123, 288, 130
 Dw  151, 124,  87, 120
 Dw  152,  75,   2, 104
 Dw  152,  76, 237, 113
 Dw  152,  77,  73, 145
 Dw  152,  78,   0, 148
 Dw  152,  79, 300, 114
 Dw  152,  84, 173,  26
 Dw  152,  85, 209,   0
 Dw  152,  86, 165,  81
 Dw  152,  87,  34,  11
 Dw  152,  88, 317, 169
 Dw  152,  89,  85,  58
 Dw  152,  90, 290, 182
 Dw  152,  91, 218, 120
 Dw  152,  92,  77, 114
 Dw  152,  93, 208,  48
 Dw  152,  94, 299, 160
 Dw  152,  95, 317, 192
 Dw  152,  96, 196, 153
 Dw  152, 100, 173, 111
 Dw  152, 101,  66, 128
 Dw  152, 102, 183,  52
 Dw  152, 103, 289,  21
 Dw  152, 104, 250, 156
 Dw  152, 107,  46, 183
 Dw  152, 108, 175, 170
 Dw  152, 109, 165,  27
 Dw  152, 110, 191, 136
 Dw  152, 111, 250, 185
 Dw  152, 112,  94, 132
 Dw  152, 113, 132, 193
 Dw  152, 114,  54,  27
 Dw  152, 115, 112, 166
 Dw  152, 120, 139,  37
 Dw  152, 121, 276,  15
 Dw  152, 122, 175, 131
 Dw  152, 123, 226, 136
 Dw  152, 124,  47, 194
 Dw  153,  75,   4,  30
 Dw  153,  76, 271,  77
 Dw  153,  77, 174, 106
 Dw  153,  78, 245, 143
 Dw  153,  79,  86, 194
 Dw  153,  84, 245, 150
 Dw  153,  85, 138, 134
 Dw  153,  86, 234, 176
 Dw  153,  87, 157,  78
 Dw  153,  88, 141, 120
 Dw  153,  93, 215, 163
 Dw  153,  94, 258, 184
 Dw  153,  95, 317,  76
 Dw  153,  96, 180, 189
 Dw  153, 100, 306,  94
 Dw  153, 101, 206,   4
 Dw  153, 102, 116,  16
 Dw  153, 103, 277,  54
 Dw  153, 104, 269,  52
 Dw  153, 111, 208,  89
 Dw  153, 112,  33,   0
 Dw  153, 113, 281,  73
 Dw  153, 114,  11,  78
 Dw  153, 115,  49,  81
 Dw  153, 120,  20,  39
 Dw  153, 121,   4, 154
 Dw  153, 122, 159,  27
 Dw  153, 123, 290, 107
 Dw  153, 124, 224, 116
 Dw  154,  75, 310, 146
 Dw  154,  76, 113,  82
 Dw  154,  77, 284, 175
 Dw  154,  78,  45,  49
 Dw  154,  79, 138, 153
 Dw  154,  84, 196,  73
 Dw  154,  85, 130,  95
 Dw  154,  86,  23, 176
 Dw  154,  87,  32, 155
 Dw  154,  88, 230,  23
 Dw  154,  93, 172, 104
 Dw  154,  94, 138,  44
 Dw  154,  95,   7, 136
 Dw  154,  96, 282,  89
 Dw  154, 100, 276,   6
 Dw  154, 101, 289, 119
 Dw  154, 102,  74, 140
 Dw  154, 103,  81, 129
 Dw  154, 104, 167,  27
 Dw  154, 111,  80, 101
 Dw  154, 112, 229,  22
 Dw  154, 113, 286,  77
 Dw  154, 114, 185, 176
 Dw  154, 115, 141,  59
 Dw  154, 120, 221, 123
 Dw  154, 121, 182, 125
 Dw  154, 122, 222, 129
 Dw  154, 123, 188, 168
 Dw  154, 124,  56,  53
 Dw  155,  75, 107, 130
 Dw  155,  76,  40,  12
 Dw  155,  77, 226,  72
 Dw  155,  78, 285, 190
 Dw  155,  79, 309,  21
 Dw  155,  84,   6, 109
 Dw  155,  85,  92,  47
 Dw  155,  86, 150,  85
 Dw  155,  87,  54,  22
 Dw  155,  88,  10,  77
 Dw  155,  93, 214, 185
 Dw  155,  94, 314, 184
 Dw  155,  95, 198,  96
 Dw  155,  96,  84,  69
 Dw  155, 100,  76, 186
 Dw  155, 101, 245,  68
 Dw  155, 102, 262, 189
 Dw  155, 103, 153, 181
 Dw  155, 104, 138, 164
 Dw  155, 111, 182, 191
 Dw  155, 112, 242,  93
 Dw  155, 113, 218,   0
 Dw  155, 114, 178,  64
 Dw  155, 115,   5, 143
 Dw  155, 120, 119, 122
 Dw  155, 121, 310,  68
 Dw  155, 122, 135,  97
 Dw  155, 123, 121,  24
 Dw  155, 124, 274, 199
 Dw  156,  75, 227,  67
 Dw  156,  76, 250, 179
 Dw  156,  77, 209, 122
 Dw  156,  78, 239, 153
 Dw  156,  79,  11, 101
 Dw  156,  84, 188, 188
 Dw  156,  85, 308, 116
 Dw  156,  86, 267,  36
 Dw  156,  87, 205, 103
 Dw  156,  88,  20,  35
 Dw  156,  93,  85, 179
 Dw  156,  94, 287,  43
 Dw  156,  95, 291, 150
 Dw  156,  96, 183, 140
 Dw  156, 100, 119,   4
 Dw  156, 101,  72,  50
 Dw  156, 102, 105,  90
 Dw  156, 103, 107, 129
 Dw  156, 104,  92, 135
 Dw  156, 111, 316, 167
 Dw  156, 112,  73,  83
 Dw  156, 113, 290, 141
 Dw  156, 114, 273,  17
 Dw  156, 115, 120,  95
 Dw  156, 120, 274,  52
 Dw  156, 121, 165, 143
 Dw  156, 122, 224, 150
 Dw  156, 123, 188, 104
 Dw  156, 124, 227,  50
 Dw  157,  75,  62,  60
 Dw  157,  76, 169, 165
 Dw  157,  77, 199,  20
 Dw  157,  78,  77, 137
 Dw  157,  79, 224, 123
 Dw  157,  84, 222,   5
 Dw  157,  85, 275,  24
 Dw  157,  86, 267, 171
 Dw  157,  87,  97,  22
 Dw  157,  88,  29,  24
 Dw  157,  93, 158,  64
 Dw  157,  94,  35, 109
 Dw  157,  95, 106,  75
 Dw  157,  96, 121, 194
 Dw  157, 100, 237,  77
 Dw  157, 101, 175,  25
 Dw  157, 102, 178,   8
 Dw  157, 103, 156,  26
 Dw  157, 104, 284,  32
 Dw  157, 111, 127,  34
 Dw  157, 112, 127, 148
 Dw  157, 113, 149,   8
 Dw  157, 114,  44, 175
 Dw  157, 115, 301, 135
 Dw  157, 120, 291,  33
 Dw  157, 121, 195, 145
 Dw  157, 122,  85,  93
 Dw  157, 123,   7, 164
 Dw  157, 124, 198,  23
 Dw  158,  75, 302,  25
 Dw  158,  76,  34, 187
 Dw  158,  77, 299,  58
 Dw  158,  78,  46, 139
 Dw  158,  79, 313, 185
 Dw  158,  84, 266, 162
 Dw  158,  85, 185,  32
 Dw  158,  86, 205,  99
 Dw  158,  87, 252, 197
 Dw  158,  88,  16, 121
 Dw  158,  93, 311,  72
 Dw  158,  94,  18, 179
 Dw  158,  95, 135,  67
 Dw  158,  96, 231,  86
 Dw  158, 100,  10, 134
 Dw  158, 101,  65,  80
 Dw  158, 102, 197, 137
 Dw  158, 103, 285, 114
 Dw  158, 104, 226,  62
 Dw  158, 111, 204,   8
 Dw  158, 112, 254, 116
 Dw  158, 113,  65,  38
 Dw  158, 114, 125,  16
 Dw  158, 115, 112, 168
 Dw  158, 120, 132,   6
 Dw  158, 121,  88,  18
 Dw  158, 122, 218,   9
 Dw  158, 123,  88,  69
 Dw  158, 124, 198, 152
 Dw  159,  75, 270,  98
 Dw  159,  76, 131, 165
 Dw  159,  77, 193,  43
 Dw  159,  78,  60,   1
 Dw  159,  79, 239, 188
 Dw  159,  84,   9,  78
 Dw  159,  85, 295, 178
 Dw  159,  86, 261, 173
 Dw  159,  87, 227,  44
 Dw  159,  88,  86,  94
 Dw  159,  89,  48,  56
 Dw  159,  90, 218,  44
 Dw  159,  91, 303,  72
 Dw  159,  93,  47, 101
 Dw  159,  94,  96, 115
 Dw  159,  95, 116,  44
 Dw  159,  96, 179, 138
 Dw  159, 100,  83,  31
 Dw  159, 101,  14,  13
 Dw  159, 102,  11,  67
 Dw  159, 103, 252, 195
 Dw  159, 104, 126,  73
 Dw  159, 105,  27,  10
 Dw  159, 106, 319, 187
 Dw  159, 107,   5, 115
 Dw  159, 108, 152,   4
 Dw  159, 109, 118, 164
 Dw  159, 110, 161, 100
 Dw  159, 111, 208, 146
 Dw  159, 112, 249,  30
 Dw  159, 113,  25, 131
 Dw  159, 114, 288,  64
 Dw  159, 115, 244, 169
 Dw  159, 120, 160, 134
 Dw  159, 121, 145, 191
 Dw  159, 122,  36, 161
 Dw  159, 123, 183, 171
 Dw  159, 124, 201, 144
 Dw  160,  75, 134,  71
 Dw  160,  76, 121,  68
 Dw  160,  77, 234, 140
 Dw  160,  78,  32, 114
 Dw  160,  79,  11, 195
 Dw  160,  84, 118, 140
 Dw  160,  85, 136, 155
 Dw  160,  86,  98,   7
 Dw  160,  87, 239, 136
 Dw  160,  88, 179,   9
 Dw  160,  89,  92, 104
 Dw  160,  90, 286, 104
 Dw  160,  91, 148,  84
 Dw  160,  93, 302,  89
 Dw  160,  94,  38,   9
 Dw  160,  95, 281, 117
 Dw  160,  96, 133, 131
 Dw  160, 100,  23,   3
 Dw  160, 101, 135, 160
 Dw  160, 102,  21,  16
 Dw  160, 103, 281, 159
 Dw  160, 104, 113, 109
 Dw  160, 105, 245,  65
 Dw  160, 106, 256, 170
 Dw  160, 107, 210, 150
 Dw  160, 108, 236, 157
 Dw  160, 109, 298,  14
 Dw  160, 110,   7,   0
 Dw  160, 111, 130, 102
 Dw  160, 112, 207,  36
 Dw  160, 113, 287,  53
 Dw  160, 114, 199, 144
 Dw  160, 115, 248, 162
 Dw  160, 120,  84,  58
 Dw  160, 121, 196, 170
 Dw  160, 122,  37, 134
 Dw  160, 123, 108, 166
 Dw  160, 124,  32, 131
 Dw  161,  75, 198,  97
 Dw  161,  76, 208, 187
 Dw  161,  77, 112, 198
 Dw  161,  78, 293,  62
 Dw  161,  79, 141, 118
 Dw  161,  84,  95, 109
 Dw  161,  85, 103, 158
 Dw  161,  86, 289, 163
 Dw  161,  87, 265,  99
 Dw  161,  88, 212, 106
 Dw  161,  89, 128, 140
 Dw  161,  90,  71, 177
 Dw  161,  91, 247, 119
 Dw  161,  93, 265, 118
 Dw  161,  94, 177,  30
 Dw  161,  95, 268, 105
 Dw  161,  96, 121, 125
 Dw  161, 100, 185,  53
 Dw  161, 101, 187, 107
 Dw  161, 102, 208, 157
 Dw  161, 103, 165, 192
 Dw  161, 104, 306, 144
 Dw  161, 105, 304,  66
 Dw  161, 106, 312,  11
 Dw  161, 107,  92, 197
 Dw  161, 108,  45,  13
 Dw  161, 109, 125,  44
 Dw  161, 110,  96, 183
 Dw  161, 111, 105, 107
 Dw  161, 112, 194,  47
 Dw  161, 113, 116,  68
 Dw  161, 114, 117, 111
 Dw  161, 115, 288,  77
 Dw  161, 120, 200,  91
 Dw  161, 121, 100, 108
 Dw  161, 122, 186, 154
 Dw  161, 123, 257, 164
 Dw  161, 124,  22,  50
 Dw  162,  75, 236, 145
 Dw  162,  76, 228,  96
 Dw  162,  77,  33,  53
 Dw  162,  78, 164,   1
 Dw  162,  79,  17,  56
 Dw  162,  85, 294, 174
 Dw  162,  86, 211, 189
 Dw  162,  87, 219,  27
 Dw  162,  88, 101, 100
 Dw  162,  89,  23,   6
 Dw  162,  90, 156, 131
 Dw  162,  91,  57, 152
 Dw  162,  93, 223,  33
 Dw  162,  94, 134,  41
 Dw  162,  95, 293, 114
 Dw  162,  96, 170, 195
 Dw  162, 100, 264,  18
 Dw  162, 101, 171, 116
 Dw  162, 102, 179,  21
 Dw  162, 103, 184, 136
 Dw  162, 104, 289, 160
 Dw  162, 105, 186, 130
 Dw  162, 106,  32, 172
 Dw  162, 107,  37, 194
 Dw  162, 108, 211,  51
 Dw  162, 109, 292,  26
 Dw  162, 110, 288, 122
 Dw  162, 111, 298,  16
 Dw  162, 112,  31, 120
 Dw  162, 113, 307,  86
 Dw  162, 114, 132,  76
 Dw  162, 120,  20, 180
 Dw  162, 121,  21,   9
 Dw  162, 122, 140, 145
 Dw  162, 123, 124, 112
 Dw  162, 124, 140,  12
 Dw  163,  75, 208, 146
 Dw  163,  76, 279, 108
 Dw  163,  77, 298,  16
 Dw  163,  78, 254, 111
 Dw  163,  79, 110, 146
 Dw  163,  86, 137, 184
 Dw  163,  87, 112, 135
 Dw  163,  88, 296, 190
 Dw  163,  89,  24,   9
 Dw  163,  90,  23,  35
 Dw  163,  91, 256,  38
 Dw  163,  93,  71,  32
 Dw  163,  94,   5, 146
 Dw  163,  95,   0,  36
 Dw  163,  96, 248, 189
 Dw  163, 101, 178, 150
 Dw  163, 102,  67,   5
 Dw  163, 103, 143,  41
 Dw  163, 104, 127,  36
 Dw  163, 105, 139, 168
 Dw  163, 106,   8, 115
 Dw  163, 107, 236,  71
 Dw  163, 108, 159, 111
 Dw  163, 109, 165, 111
 Dw  163, 110, 129, 143
 Dw  163, 111, 225, 112
 Dw  163, 112, 175, 139
 Dw  163, 113, 124,   6
 Dw  163, 120, 296, 161
 Dw  163, 121, 122,  19
 Dw  163, 122, 118, 167
 Dw  163, 123, 224,   0
 Dw  163, 124, 225, 131
 Dw  164,  75,  15, 142
 Dw  164,  76, 220,  98
 Dw  164,  77, 186, 185
 Dw  164,  78,  20, 191
 Dw  164,  79, 169,  58
 Dw  164,  80, 148,  41
 Dw  164,  87, 126, 141
 Dw  164,  88,  16, 167
 Dw  164,  89, 281,  17
 Dw  164,  90,  22,  73
 Dw  164,  93, 245, 185
 Dw  164,  94, 243,  88
 Dw  164,  95, 100, 102
 Dw  164,  96,  82,  16
 Dw  164, 119, 311, 140
 Dw  164, 120, 145, 122
 Dw  164, 121, 155, 102
 Dw  164, 122, 302,  22
 Dw  164, 123, 194,  10
 Dw  164, 124, 164, 109
 Dw  165,  75,  26,  91
 Dw  165,  76, 261, 171
 Dw  165,  77, 184, 173
 Dw  165,  78,  61, 130
 Dw  165,  79, 227, 130
 Dw  165,  80, 237,  86
 Dw  165,  81, 126,  80
 Dw  165,  87,  56,  65
 Dw  165,  88,  33,  74
 Dw  165,  89, 316, 159
 Dw  165,  90, 258,  75
 Dw  165,  91, 315, 178
 Dw  165,  93, 210,  90
 Dw  165,  94,  86, 181
 Dw  165,  95, 228, 118
 Dw  165,  96,  46, 110
 Dw  165, 118,  77,  98
 Dw  165, 119, 187,   0
 Dw  165, 120, 130,  27
 Dw  165, 121,  64,  86
 Dw  165, 122, 119, 111
 Dw  165, 123, 284, 179
 Dw  165, 124,  44,  33
 Dw  166,  75, 174, 131
 Dw  166,  76, 207,  98
 Dw  166,  77, 181,  69
 Dw  166,  78, 307,  41
 Dw  166,  79,   9, 103
 Dw  166,  80, 170, 153
 Dw  166,  81, 228, 101
 Dw  166,  82, 295,  12
 Dw  166,  87, 135, 135
 Dw  166,  88, 141, 181
 Dw  166,  89,  76,  80
 Dw  166,  90, 179,  51
 Dw  166,  91, 212,  89
 Dw  166,  93,  42,  94
 Dw  166,  94, 251, 103
 Dw  166,  95, 220,   9
 Dw  166,  96, 297,  32
 Dw  166,  97, 131, 118
 Dw  166, 117, 140,  77
 Dw  166, 118, 166, 199
 Dw  166, 119, 164, 105
 Dw  166, 120,  53,  16
 Dw  166, 121,  88,  61
 Dw  166, 122,  32,  26
 Dw  166, 123, 165,  28
 Dw  166, 124, 220,  24
 Dw  167,  76, 228,  17
 Dw  167,  77,  12, 122
 Dw  167,  78, 115, 199
 Dw  167,  79, 104,  94
 Dw  167,  80, 212, 164
 Dw  167,  81, 181,   5
 Dw  167,  82,  34,  12
 Dw  167,  87, 141,  55
 Dw  167,  88, 165, 163
 Dw  167,  89, 289,  40
 Dw  167,  90, 184, 194
 Dw  167,  93, 218,  83
 Dw  167,  94, 295,  95
 Dw  167,  95, 296, 117
 Dw  167,  96,  96, 140
 Dw  167,  97, 180,  87
 Dw  167,  98, 125,  67
 Dw  167, 116,  54,  44
 Dw  167, 117,  89,  76
 Dw  167, 118, 118,   4
 Dw  167, 119, 226,  22
 Dw  167, 120,  39,  46
 Dw  167, 121, 175,  24
 Dw  167, 122, 115,   9
 Dw  167, 123,  50, 162
 Dw  168,  77, 272, 182
 Dw  168,  78, 177, 182
 Dw  168,  79,  92,  34
 Dw  168,  80, 178, 186
 Dw  168,  81, 292,  76
 Dw  168,  82, 112, 121
 Dw  168,  83,  75,   7
 Dw  168,  87,  34, 143
 Dw  168,  88, 195, 149
 Dw  168,  89, 195, 186
 Dw  168,  90, 244, 193
 Dw  168,  91,  18,  88
 Dw  168,  93, 171, 182
 Dw  168,  94, 139, 119
 Dw  168,  95, 120,  56
 Dw  168,  96,  56, 162
 Dw  168,  97, 140, 172
 Dw  168,  98, 316,  87
 Dw  168,  99,  86,  30
 Dw  168, 115,  14,  75
 Dw  168, 116, 129, 117
 Dw  168, 117, 303, 125
 Dw  168, 118, 141,   3
 Dw  168, 119,  47,   9
 Dw  168, 120, 111,  99
 Dw  168, 121, 238, 196
 Dw  168, 122,  25, 111
 Dw  169,  78, 254, 128
 Dw  169,  79, 257,  95
 Dw  169,  80, 206,  54
 Dw  169,  81,  83,  54
 Dw  169,  82, 267, 104
 Dw  169,  83,  19,  85
 Dw  169,  84, 200, 127
 Dw  169,  87, 315, 108
 Dw  169,  88,  65,  52
 Dw  169,  89, 182,  85
 Dw  169,  90,  23,  12
 Dw  169,  91, 161,  67
 Dw  169,  93,  84,  83
 Dw  169,  94, 222,  82
 Dw  169,  95,  89, 178
 Dw  169,  96, 309,  85
 Dw  169,  97, 311,  61
 Dw  169,  98, 246,  93
 Dw  169,  99, 244,  88
 Dw  169, 100, 122,  35
 Dw  169, 114, 275, 183
 Dw  169, 115, 144, 124
 Dw  169, 116, 132, 126
 Dw  169, 117, 282, 184
 Dw  169, 118, 257, 163
 Dw  169, 119, 129,  52
 Dw  169, 120, 132, 141
 Dw  169, 121, 103, 174
 Dw  170,  79, 206,  34
 Dw  170,  80,  94,  15
 Dw  170,  81,   4,   6
 Dw  170,  82,  50, 118
 Dw  170,  83, 186, 156
 Dw  170,  84,  28, 112
 Dw  170,  85,  25, 184
 Dw  170,  86, 214,  12
 Dw  170,  87, 133,  45
 Dw  170,  88, 211,  19
 Dw  170,  89, 160, 108
 Dw  170,  90, 152,  52
 Dw  170,  94, 181,   6
 Dw  170,  95, 235, 120
 Dw  170,  96, 115, 177
 Dw  170,  97, 118,  74
 Dw  170,  98, 300, 188
 Dw  170,  99,  38, 143
 Dw  170, 100, 303, 157
 Dw  170, 101, 147,  95
 Dw  170, 102, 183,  40
 Dw  170, 103,  80, 116
 Dw  170, 104, 187,   8
 Dw  170, 105, 206, 173
 Dw  170, 106,  42, 190
 Dw  170, 107,  24,  30
 Dw  170, 108,  78, 104
 Dw  170, 109, 116, 184
 Dw  170, 110,  54, 132
 Dw  170, 111,  69,  16
 Dw  170, 112,   0,  86
 Dw  170, 113, 223,  96
 Dw  170, 114,  80, 120
 Dw  170, 115, 147,  40
 Dw  170, 116,  93, 112
 Dw  170, 117, 243, 175
 Dw  170, 118, 272,  90
 Dw  170, 119, 184, 100
 Dw  170, 120, 310, 127
 Dw  171,  80, 126,  89
 Dw  171,  81,  27, 173
 Dw  171,  82, 131, 144
 Dw  171,  83,  63, 145
 Dw  171,  84,  70, 129
 Dw  171,  85,  77,  44
 Dw  171,  86, 105,  98
 Dw  171,  87,  43, 140
 Dw  171,  88, 302, 148
 Dw  171,  89,  43,  62
 Dw  171,  90, 304,   7
 Dw  171,  95, 144, 154
 Dw  171,  96,   6, 199
 Dw  171,  97,  86,  36
 Dw  171,  98,  66,  83
 Dw  171,  99, 202,  14
 Dw  171, 100, 190, 104
 Dw  171, 101, 258,   0
 Dw  171, 102, 224,  76
 Dw  171, 103,  38,  65
 Dw  171, 104, 256, 117
 Dw  171, 105, 116,   1
 Dw  171, 106, 122, 151
 Dw  171, 107,  82, 111
 Dw  171, 108, 101, 114
 Dw  171, 109, 192,  95
 Dw  171, 110, 173,  72
 Dw  171, 111,  12, 169
 Dw  171, 112,  90,  84
 Dw  171, 113, 204, 163
 Dw  171, 114,  39, 114
 Dw  171, 115, 215,  45
 Dw  171, 116, 158, 144
 Dw  171, 117,  91, 131
 Dw  171, 118, 102,  71
 Dw  171, 119, 313, 105
 Dw  172,  81, 299,  54
 Dw  172,  82,  23,  13
 Dw  172,  83, 164, 187
 Dw  172,  84, 183,  76
 Dw  172,  85, 193,  58
 Dw  172,  86,  34, 157
 Dw  172,  87, 166, 195
 Dw  172,  88, 277,  49
 Dw  172,  89, 214,  25
 Dw  172,  90, 229, 107
 Dw  172,  91,  39,  71
 Dw  172,  96, 286,  96
 Dw  172,  97, 293, 110
 Dw  172,  98, 305,  78
 Dw  172,  99, 307,  99
 Dw  172, 100, 300, 103
 Dw  172, 101, 170, 124
 Dw  172, 102, 275,  44
 Dw  172, 103, 221,  47
 Dw  172, 104, 314,  15
 Dw  172, 105,  55,  23
 Dw  172, 106, 181,  37
 Dw  172, 107, 156,  60
 Dw  172, 108, 305,  84
 Dw  172, 109, 121,  96
 Dw  172, 110,  72,  60
 Dw  172, 111, 267,  59
 Dw  172, 112, 256, 149
 Dw  172, 113,  87,  83
 Dw  172, 114, 226,   8
 Dw  172, 115, 208,  61
 Dw  172, 116, 118, 107
 Dw  172, 117, 185, 190
 Dw  173,  82,  52,  11
 Dw  173,  83, 227,   2
 Dw  173,  84,  31,  10
 Dw  173,  85, 309,  26
 Dw  173,  86, 113, 178
 Dw  173,  87, 125,  82
 Dw  173,  88, 168, 173
 Dw  173,  89, 220,  49
 Dw  173,  90, 265, 163
 Dw  173,  91, 230,  11
 Dw  173,  97, 194,  89
 Dw  173,  98, 173, 123
 Dw  173,  99, 284, 139
 Dw  173, 100, 237, 184
 Dw  173, 101, 270, 162
 Dw  173, 102,  46, 193
 Dw  173, 103, 120, 182
 Dw  173, 104,  61, 149
 Dw  173, 105,  73,  48
 Dw  173, 106, 163,  67
 Dw  173, 107,  90,  74
 Dw  173, 108, 159,   1
 Dw  173, 109,   0,  13
 Dw  173, 110, 304, 113
 Dw  173, 111,  47, 115
 Dw  173, 112,  21,  89
 Dw  173, 113,  70, 103
 Dw  173, 114,  93,  65
 Dw  173, 115,  93, 144
 Dw  173, 116, 292,  25
 Dw  173, 117,  43, 119
 Dw  174,  82, 118, 151
 Dw  174,  83, 272, 182
 Dw  174,  84, 187,  12
 Dw  174,  85, 124,  17
 Dw  174,  86, 289, 121
 Dw  174,  87, 202,  76
 Dw  174,  88, 126,  90
 Dw  174,  89,   3, 108
 Dw  174,  90, 193, 196
 Dw  174,  91, 243, 163
 Dw  174,  98, 315,  83
 Dw  174,  99,  83,  82
 Dw  174, 100, 209, 126
 Dw  174, 101,  54, 149
 Dw  174, 102,  57,  67
 Dw  174, 103,  72,  34
 Dw  174, 104, 153, 163
 Dw  174, 105, 284, 186
 Dw  174, 106,  54, 146
 Dw  174, 107,  93, 110
 Dw  174, 108, 264, 143
 Dw  174, 109,  39, 184
 Dw  174, 110,   4, 145
 Dw  174, 111, 123, 162
 Dw  174, 112,  48,  85
 Dw  174, 113,  61, 112
 Dw  174, 114, 134,   9
 Dw  174, 115,  13,  19
 Dw  174, 116, 113,  98
 Dw  175,  99,  73, 131
 Dw  175, 100, 278, 123
 Dw  175, 101,  94, 161
 Dw  175, 102, 247,   2
 Dw  175, 103, 237, 125
 Dw  175, 104,  17, 133
 Dw  175, 105, 116,  21
 Dw  175, 106, 170,  64
 Dw  175, 107, 301,  54
 Dw  175, 108, 193,  93
 Dw  175, 109,  49,  85
 Dw  175, 110,  60,  44
 Dw  175, 111, 295, 117
 Dw  175, 112,  45, 115
 Dw  175, 113, 188,  11
 Dw  175, 114, 219, 152
 Dw  175, 115, 198, 122
 Dw  175, 116, 210, 133
 Dw  182,  75, 233, 163
 Dw  182,  76, 200, 122
 Dw  182,  77, 197,  79
 Dw  182,  79,  55, 182
 Dw  182,  80, 231, 150
 Dw  182,  81, 275, 195
 Dw  182,  82, 229, 194
 Dw  182,  83, 237, 189
 Dw  182,  85, 178, 187
 Dw  182,  86, 121,  15
 Dw  182,  87, 123,  86
 Dw  182,  88, 240,  73
 Dw  182, 111, 200,  59
 Dw  182, 112, 167,  38
 Dw  182, 113, 306,   8
 Dw  182, 114, 170, 166
 Dw  182, 115,  37, 101
 Dw  182, 116, 159,  55
 Dw  182, 117, 215,  85
 Dw  182, 118,  91, 132
 Dw  182, 119,  64, 198
 Dw  182, 120,  72,  24
 Dw  182, 121, 172, 166
 Dw  182, 122, 108,  14
 Dw  182, 123,  10, 185
 Dw  182, 124, 151,  18
 Dw  183,  75, 311,  82
 Dw  183,  76, 215, 187
 Dw  183,  77, 186,  64
 Dw  183,  78, 101,  83
 Dw  183,  79,  96, 125
 Dw  183,  80, 260,  18
 Dw  183,  81,  80,  43
 Dw  183,  82, 295,  10
 Dw  183,  83,   9, 131
 Dw  183,  84, 316,  48
 Dw  183,  85, 103, 170
 Dw  183,  86, 197,  18
 Dw  183,  87, 301, 183
 Dw  183,  88, 200,  81
 Dw  183, 111,  72, 194
 Dw  183, 112,  92, 153
 Dw  183, 113,   6, 121
 Dw  183, 114,  53, 186
 Dw  183, 115, 188,  35
 Dw  183, 116,  32, 193
 Dw  183, 117,  54,  66
 Dw  183, 118,  49,  15
 Dw  183, 119,  39,  57
 Dw  183, 120, 164,  75
 Dw  183, 121, 239, 160
 Dw  183, 122, 222,  25
 Dw  183, 123, 104, 172
 Dw  183, 124, 193,  22
 Dw  184,  75, 295, 114
 Dw  184,  76,  55,  27
 Dw  184,  77, 314, 138
 Dw  184,  78, 233, 195
 Dw  184,  79, 263, 169
 Dw  184,  80,  98,  29
 Dw  184,  81, 152,  79
 Dw  184,  82, 155,  52
 Dw  184,  83, 170,  73
 Dw  184,  84, 170,   8
 Dw  184,  85, 297,  17
 Dw  184,  86, 306,  15
 Dw  184,  87, 272,  65
 Dw  184,  88, 210, 186
 Dw  184, 111,  45,  17
 Dw  184, 112, 106,  58
 Dw  184, 113, 296,  79
 Dw  184, 114, 277,  20
 Dw  184, 115, 111, 139
 Dw  184, 116, 248,   1
 Dw  184, 117, 200, 150
 Dw  184, 118,   5, 102
 Dw  184, 119, 251,   9
 Dw  184, 120, 208, 122
 Dw  184, 121, 258,  45
 Dw  184, 122,  81, 180
 Dw  184, 123,  24, 198
 Dw  184, 124,   9,  75
 Dw  185,  75, 100,  96
 Dw  185,  76, 304,  81
 Dw  185,  77, 132,  19
 Dw  185,  78, 170, 127
 Dw  185,  79, 271,  51
 Dw  185,  80, 297, 154
 Dw  185,  81, 185, 126
 Dw  185,  82, 156, 102
 Dw  185,  83, 202, 137
 Dw  185,  84,   8,  20
 Dw  185,  85, 242, 142
 Dw  185,  86, 117,  42
 Dw  185,  87, 279, 131
 Dw  185,  88, 305,  39
 Dw  185, 111,  51,  80
 Dw  185, 112, 182, 177
 Dw  185, 113,  18,  53
 Dw  185, 114, 152,  89
 Dw  185, 115, 153, 193
 Dw  185, 116, 162,   9
 Dw  185, 117,  14,  59
 Dw  185, 118, 291,  53
 Dw  185, 119,  41,  29
 Dw  185, 120, 319, 111
 Dw  185, 121, 317, 158
 Dw  185, 122, 290,  25
 Dw  185, 123, 107,  95
 Dw  185, 124, 312,  31
 Dw  186,  75,  18, 136
 Dw  186,  76, 189,  23
 Dw  186,  77, 319, 143
 Dw  186,  78, 162, 120
 Dw  186,  79, 307,  90
 Dw  186,  80, 310,  16
 Dw  186,  81, 123,  62
 Dw  186,  82,  44,  61
 Dw  186,  83, 102, 181
 Dw  186,  84, 218,  69
 Dw  186,  85, 210, 180
 Dw  186,  86, 167, 115
 Dw  186,  87, 258, 194
 Dw  186,  88,  18, 189
 Dw  186,  89,  53, 190
 Dw  186,  90, 127,  85
 Dw  186,  91,  45, 115
 Dw  186,  92, 146,  97
 Dw  186,  93, 189,  74
 Dw  186,  94, 271, 184
 Dw  186,  95, 276, 115
 Dw  186,  96, 315,  98
 Dw  186,  97, 282,  47
 Dw  186,  98, 283,  17
 Dw  186,  99, 297, 151
 Dw  186, 100, 145,  80
 Dw  186, 101,   8, 118
 Dw  186, 102, 113,  83
 Dw  186, 103,  46, 180
 Dw  186, 104, 222,  11
 Dw  186, 105, 191,  53
 Dw  186, 106,  43, 179
 Dw  186, 107, 116, 179
 Dw  186, 108,  55, 154
 Dw  186, 109,  49, 160
 Dw  186, 110, 214, 124
 Dw  186, 111, 173, 188
 Dw  186, 112, 293, 198
 Dw  186, 113, 134,  76
 Dw  186, 114, 252, 192
 Dw  186, 115, 188, 156
 Dw  186, 116, 242,  95
 Dw  186, 117,  95, 182
 Dw  186, 118, 275,  60
 Dw  186, 119,   3,   1
 Dw  186, 120, 280,  17
 Dw  186, 121, 220,  12
 Dw  186, 122,  84,  64
 Dw  186, 123, 129,  90
 Dw  186, 124, 218,  16
 Dw  187,  75,  34,  93
 Dw  187,  76,  42, 175
 Dw  187,  77, 237, 124
 Dw  187,  78, 312,   6
 Dw  187,  79,  49, 178
 Dw  187,  80, 147,  77
 Dw  187,  81, 146,  34
 Dw  187,  82, 144,  49
 Dw  187,  83, 238, 114
 Dw  187,  84, 158, 169
 Dw  187,  85, 119,  98
 Dw  187,  86, 154, 163
 Dw  187,  87,  60,  98
 Dw  187,  88, 140,  72
 Dw  187,  89, 132,  65
 Dw  187,  90,  84,  34
 Dw  187,  91,  22, 167
 Dw  187,  92, 151,  49
 Dw  187,  93,  48,  88
 Dw  187,  94,  67,  42
 Dw  187,  95, 301,  87
 Dw  187,  96,  32, 141
 Dw  187,  97,  50,  78
 Dw  187,  98, 231,   6
 Dw  187,  99, 266,  61
 Dw  187, 100, 249,  13
 Dw  187, 101,  47,  65
 Dw  187, 102,  70,  32
 Dw  187, 103, 178,  45
 Dw  187, 104, 285, 112
 Dw  187, 105, 312, 172
 Dw  187, 106, 164,  84
 Dw  187, 107, 275,  80
 Dw  187, 108,   3, 138
 Dw  187, 109, 133,   1
 Dw  187, 110, 157,  53
 Dw  187, 111, 110,  38
 Dw  187, 112, 153,  33
 Dw  187, 113, 241,  35
 Dw  187, 114,  30, 157
 Dw  187, 115,  76, 172
 Dw  187, 116, 103,  71
 Dw  187, 117,  66,  49
 Dw  187, 118, 200,  36
 Dw  187, 119, 308,  90
 Dw  187, 120, 140,  69
 Dw  187, 121,  47, 134
 Dw  187, 122, 118, 173
 Dw  187, 123, 162, 133
 Dw  187, 124,  43, 111
 Dw  188,  75,  43, 135
 Dw  188,  76, 166,  16
 Dw  188,  77, 200, 169
 Dw  188,  78, 303, 179
 Dw  188,  79, 249, 102
 Dw  188,  84, 129,  24
 Dw  188,  85, 269, 199
 Dw  188,  86, 257, 101
 Dw  188,  87, 121, 148
 Dw  188,  88,  20,  15
 Dw  188,  89,  85, 175
 Dw  188,  90, 149,  10
 Dw  188,  91, 135, 126
 Dw  188,  92,  28,  35
 Dw  188,  93,  76,  30
 Dw  188,  94, 102, 114
 Dw  188,  95, 275, 118
 Dw  188,  96, 263, 133
 Dw  188,  97, 240, 124
 Dw  188,  98, 139, 182
 Dw  188,  99,  64, 132
 Dw  188, 100, 266,  53
 Dw  188, 101, 229,  98
 Dw  188, 102, 315, 140
 Dw  188, 103, 140,  15
 Dw  188, 104, 232,  35
 Dw  188, 105,  12, 142
 Dw  188, 106, 303, 177
 Dw  188, 107, 243, 176
 Dw  188, 108,  82, 132
 Dw  188, 109, 156,  77
 Dw  188, 110,  37, 173
 Dw  188, 111,  29, 128
 Dw  188, 112, 242,  37
 Dw  188, 113, 125,  47
 Dw  188, 114, 144,  25
 Dw  188, 115, 146,  30
 Dw  188, 120, 280,  22
 Dw  188, 121,  49,  27
 Dw  188, 122, 227, 101
 Dw  188, 123,  37,  56
 Dw  188, 124, 203, 194
 Dw  189,  75, 176, 140
 Dw  189,  76, 135, 192
 Dw  189,  77, 179, 167
 Dw  189,  78, 253,  56
 Dw  189,  84, 284, 185
 Dw  189,  85,  48, 190
 Dw  189,  86,  93,  97
 Dw  189,  87, 163, 187
 Dw  189,  88, 295, 188
 Dw  189,  89,  24,  68
 Dw  189,  90, 136, 153
 Dw  189,  91, 117,  35
 Dw  189,  92, 203, 149
 Dw  189,  93, 285, 176
 Dw  189,  94,  30,  31
 Dw  189,  95, 205,  14
 Dw  189,  96, 249,  17
 Dw  189,  97,   6,  54
 Dw  189,  98, 219,  33
 Dw  189,  99, 298, 123
 Dw  189, 100,  89,  67
 Dw  189, 101,  42, 148
 Dw  189, 102, 278, 111
 Dw  189, 103,  30,  72
 Dw  189, 104, 135,  96
 Dw  189, 105, 312,  50
 Dw  189, 106, 142, 114
 Dw  189, 107, 147, 125
 Dw  189, 108, 272,  27
 Dw  189, 109, 168,  38
 Dw  189, 110,   4,  50
 Dw  189, 111, 134,  49
 Dw  189, 112, 127, 127
 Dw  189, 113, 141, 141
 Dw  189, 114, 144, 161
 Dw  189, 115,  82, 181
 Dw  189, 120, 224,  40
 Dw  189, 121, 270, 106
 Dw  189, 122,  59,   9
 Dw  189, 123, 111,   8
 Dw  189, 124, 212,  28
 Dw  190,  75, 126,  86
 Dw  190,  76,  97, 177
 Dw  190,  77, 206,  52
 Dw  190,  78, 223,  30
 Dw  190,  79, 219,  33
 Dw  190,  84, 148, 181
 Dw  190,  85, 152,  78
 Dw  190,  86, 253, 126
 Dw  190,  87, 309,   7
 Dw  190,  88, 198, 193
 Dw  190,  89, 211,   5
 Dw  190,  90, 128,  22
 Dw  190,  91,  47,   2
 Dw  190,  92, 178, 182
 Dw  190,  93, 302, 139
 Dw  190,  94,  43, 141
 Dw  190,  95,  47,  73
 Dw  190,  96,  78,  59
 Dw  190,  97, 234, 105
 Dw  190,  98,  85, 129
 Dw  190,  99, 168, 189
 Dw  190, 100, 315,  40
 Dw  190, 101,  45, 109
 Dw  190, 102,  13, 174
 Dw  190, 103, 145, 188
 Dw  190, 104, 132,  24
 Dw  190, 105, 119,  98
 Dw  190, 106, 263, 137
 Dw  190, 107, 315,  50
 Dw  190, 108,  83, 176
 Dw  190, 109, 121,  37
 Dw  190, 110,   7,  96
 Dw  190, 111, 203,  82
 Dw  190, 112, 308, 130
 Dw  190, 113, 276, 101
 Dw  190, 114, 275,  98
 Dw  190, 115,  87,  10
 Dw  190, 120,  25, 199
 Dw  190, 121, 186, 180
 Dw  190, 122, 301, 133
 Dw  190, 123, 109, 194
 Dw  190, 124, 160, 199
 Dw  191,  75, 303,  90
 Dw  191,  76, 198, 111
 Dw  191,  77, 120, 146
 Dw  191,  78, 163,  88
 Dw  191,  79, 312, 103
 Dw  191, 120,  67,  56
 Dw  191, 121, 266, 164
 Dw  191, 122, 194,  16
 Dw  191, 123, 163, 186
 Dw  191, 124, 313, 114
 Dw  192,  75,  75,  80
 Dw  192,  76,  60, 183
 Dw  192,  77, 250, 155
 Dw  192,  78, 312, 168
 Dw  192,  79, 206, 117
 Dw  192, 120,   3, 120
 Dw  192, 121,  87, 141
 Dw  192, 122, 206,  71
 Dw  192, 123, 133,  62
 Dw  192, 124, 156, 170
 Dw  193,  75, 285, 166
 Dw  193,  76,  94,  90
 Dw  193,  77,  94, 150
 Dw  193,  78, 250, 192
 Dw  193,  79, 151,  31
 Dw  193, 120, 106, 158
 Dw  193, 121, 257,  60
 Dw  193, 122, 231,  70
 Dw  193, 123, 180, 127
 Dw  193, 124, 108, 148
 Dw  194,  75, 306,  23
 Dw  194,  76, 166,  40
 Dw  194,  77, 178, 138
 Dw  194,  78, 306, 151
 Dw  194,  79,  90,  47
 Dw  194, 120, 103,  25
 Dw  194, 121,  34,  82
 Dw  194, 122, 182, 166
 Dw  194, 123,  49,  45
 Dw  194, 124, 173, 188
 Dw  195,  75, 279,  40
 Dw  195,  76, 263,  13
 Dw  195,  77, 139,  88
 Dw  195,  78,  10,  90
 Dw  195,  79, 183,  15
 Dw  195, 120, 298,  46
 Dw  195, 121, 143, 160
 Dw  195, 122,  19,  65
 Dw  195, 123, 110,  97
 Dw  195, 124, 260,  85
 Dw  196,  75,  72,  29
 Dw  196,  76,  30,  12
 Dw  196,  77, 138, 137
 Dw  196,  78,  11, 160
 Dw  196,  79,  38,  35
 Dw  196, 120, 125, 189
 Dw  196, 121,  54, 141
 Dw  196, 122, 181,  67
 Dw  196, 123, 217, 183
 Dw  196, 124, 137,  27
 Dw  197,  75,  89, 171
 Dw  197,  76, 112, 136
 Dw  197,  77, 277, 151
 Dw  197,  78,  37, 156
 Dw  197,  79, 160, 161
 Dw  197,  84, 217,  12
 Dw  197,  85, 184,  16
 Dw  197,  86, 268,  40
 Dw  197,  87, 161,  43
 Dw  197,  88, 124,  47
 Dw  197,  89, 153,  85
 Dw  197,  90,  94,  29
 Dw  197,  91,  45, 191
 Dw  197,  92, 280, 108
 Dw  197,  93,  47,  39
 Dw  197,  94,  56,  19
 Dw  197,  95, 316, 170
 Dw  197,  96, 287, 196
 Dw  197,  97, 173,   0
 Dw  197, 102, 201, 125
 Dw  197, 103,  71,   1
 Dw  197, 104,  69,  72
 Dw  197, 105, 239,  92
 Dw  197, 106, 174, 174
 Dw  197, 107, 253, 142
 Dw  197, 108,  13, 106
 Dw  197, 109,  32, 134
 Dw  197, 110, 213,   0
 Dw  197, 111, 288, 177
 Dw  197, 112,  86, 131
 Dw  197, 113, 175,  31
 Dw  197, 114, 155, 155
 Dw  197, 115, 265,  17
 Dw  197, 120, 187, 107
 Dw  197, 121, 120,  86
 Dw  197, 122, 314,  38
 Dw  197, 123,  11,  17
 Dw  197, 124,  97,  11
 Dw  198,  75,  72,  19
 Dw  198,  76,  50,  30
 Dw  198,  77, 186,   3
 Dw  198,  78,  30, 122
 Dw  198,  79, 137, 103
 Dw  198,  84, 119,  42
 Dw  198,  85, 284,  13
 Dw  198,  86, 150, 130
 Dw  198,  87, 209,  10
 Dw  198,  88, 169,  79
 Dw  198,  89, 244, 148
 Dw  198,  90,  37,  55
 Dw  198,  91, 275, 169
 Dw  198,  92,   8,  15
 Dw  198,  93, 254, 138
 Dw  198,  94,   1, 177
 Dw  198,  95, 185,  38
 Dw  198,  96, 181, 178
 Dw  198,  97,   2,  24
 Dw  198, 102, 115, 179
 Dw  198, 103, 156,  90
 Dw  198, 104, 235, 152
 Dw  198, 105, 277, 140
 Dw  198, 106, 128, 105
 Dw  198, 107, 101, 106
 Dw  198, 108, 135, 188
 Dw  198, 109, 183,  21
 Dw  198, 110, 289, 125
 Dw  198, 111,  16, 185
 Dw  198, 112,  18,  27
 Dw  198, 113, 216,  20
 Dw  198, 114, 192, 119
 Dw  198, 115, 142,  69
 Dw  198, 120, 199, 141
 Dw  198, 121,   4,  30
 Dw  198, 122, 114,  67
 Dw  198, 123, 280, 171
 Dw  198, 124, 168, 179
 Dw  199,  75, 299, 128
 Dw  199,  76,  60,  59
 Dw  199,  77, 151, 126
 Dw  199,  78,  79,  31
 Dw  199,  79, 279, 128
 Dw  199,  84,  21, 109
 Dw  199,  85, 188,  50
 Dw  199,  86, 263, 101
 Dw  199,  87,  61,  46
 Dw  199,  88, 182, 191
 Dw  199,  89, 176, 107
 Dw  199,  90,  41, 196
 Dw  199,  91, 120,  74
 Dw  199,  92,  95,  77
 Dw  199,  93, 247, 199
 Dw  199,  94, 312,  25
 Dw  199,  95, 165,  76
 Dw  199,  96,  52, 196
 Dw  199,  97,  43, 158
 Dw  199, 102,   9, 110
 Dw  199, 103,  35, 187
 Dw  199, 104, 135, 101
 Dw  199, 105, 221,  57
 Dw  199, 106, 170, 113
 Dw  199, 107,  57, 129
 Dw  199, 108, 188, 152
 Dw  199, 109, 222,  29
 Dw  199, 110, 267, 171
 Dw  199, 111, 226,  39
 Dw  199, 112,  34,   6
 Dw  199, 113, 300,   8
 Dw  199, 114, 243,  44
 Dw  199, 115, 115,  10
 Dw  199, 120, 274, 126
 Dw  199, 121, 124, 165
 Dw  199, 122, 238,  82
 Dw  199, 123, 176, 142
 Dw  199, 124, 158,  98
 Dw  200,  75,  49,  76
 Dw  200,  76, 267, 197
 Dw  200,  77, 257, 108
 Dw  200,  78, 176, 161
 Dw  200,  79, 242, 188
 Dw  200,  84, 145,  48
 Dw  200,  85, 140,  34
 Dw  200,  86, 128, 151
 Dw  200,  87, 225,   7
 Dw  200,  88,   5,  45
 Dw  200,  89, 174,  84
 Dw  200,  90,   3,  60
 Dw  200,  91, 129, 190
 Dw  200,  92, 107, 156
 Dw  200,  93,  94, 168
 Dw  200,  94, 161, 199
 Dw  200,  95, 114, 158
 Dw  200,  96, 270, 137
 Dw  200,  97, 179, 154
 Dw  200, 102, 172, 180
 Dw  200, 103, 221,  15
 Dw  200, 104, 205, 164
 Dw  200, 105, 267, 198
 Dw  200, 106, 164, 115
 Dw  200, 107, 315, 184
 Dw  200, 108, 104,  89
 Dw  200, 109, 154, 182
 Dw  200, 110, 180,  13
 Dw  200, 111, 135, 152
 Dw  200, 112, 217,  93
 Dw  200, 113,  87,  67
 Dw  200, 114, 121,   7
 Dw  200, 115,  79, 129
 Dw  200, 116,  39, 170
 Dw  200, 117,  85, 162
 Dw  200, 118, 270, 177
 Dw  200, 119, 170,  19
 Dw  200, 120,   3,   7
 Dw  200, 121, 316,  96
 Dw  200, 122, 150,   1
 Dw  200, 123,  87, 107
 Dw  200, 124, 235,  90
 Dw  201,  75, 289, 113
 Dw  201,  76, 209,   3
 Dw  201,  77, 247,  52
 Dw  201,  78, 200,   9
 Dw  201,  79,  75,  70
 Dw  201,  84, 241,  29
 Dw  201,  85, 114, 196
 Dw  201,  86, 220, 188
 Dw  201,  87,  24, 157
 Dw  201,  88, 308, 121
 Dw  201,  89, 126, 189
 Dw  201,  90,  42,  20
 Dw  201,  91, 261, 124
 Dw  201,  92,   1,  17
 Dw  201,  93, 204, 120
 Dw  201,  94, 233,  17
 Dw  201,  95, 280,  16
 Dw  201,  96, 202,  51
 Dw  201,  97, 272, 164
 Dw  201, 102, 307, 172
 Dw  201, 103, 246,  34
 Dw  201, 104, 308,  74
 Dw  201, 105, 254, 142
 Dw  201, 106,   2, 134
 Dw  201, 107, 149,  93
 Dw  201, 108, 190, 185
 Dw  201, 109, 150, 190
 Dw  201, 110, 168, 195
 Dw  201, 111,  21, 103
 Dw  201, 112, 176,  75
 Dw  201, 113, 232, 146
 Dw  201, 114,  82,  89
 Dw  201, 115, 252, 160
 Dw  201, 116,  15, 181
 Dw  201, 117,  46,  45
 Dw  201, 118, 139,   4
 Dw  201, 119,  91,  47
 Dw  201, 120,  14,  55
 Dw  201, 121,  79, 129
 Dw  201, 122,   0,   7
 Dw  201, 123,  77,  49
 Dw  201, 124, 204, 145
 Dw  202,  75,   8, 166
 Dw  202,  76, 211,  83
 Dw  202,  77, 100,  84
 Dw  202,  78,  81, 189
 Dw  202,  79, 245,  86
 Dw  202,  84, 230, 181
 Dw  202,  85, 116, 138
 Dw  202,  86, 208,  21
 Dw  202,  87,  65, 128
 Dw  202,  88, 238,  78
 Dw  202,  89,   7,  22
 Dw  202,  90, 234, 186
 Dw  202,  91, 313,  97
 Dw  202,  92,  15,  56
 Dw  202,  93, 171,  36
 Dw  202,  94,  62, 178
 Dw  202,  95, 130, 139
 Dw  202,  96, 309, 183
 Dw  202,  97, 307, 146
 Dw  202, 102, 304,  75
 Dw  202, 103, 179,  18
 Dw  202, 104, 309,  19
 Dw  202, 105, 208,  74
 Dw  202, 106, 126,   0
 Dw  202, 113, 214, 122
 Dw  202, 114, 175, 124
 Dw  202, 115,  15, 103
 Dw  202, 116, 153, 188
 Dw  202, 117, 267, 165
 Dw  202, 118, 312, 185
 Dw  202, 119, 260, 190
 Dw  202, 120, 184,  68
 Dw  202, 121,  13,   9
 Dw  202, 122, 263, 151
 Dw  202, 123,  78, 195
 Dw  202, 124,  60, 154
 Dw  203,  75, 157,   1
 Dw  203,  76,  96, 184
 Dw  203,  77,   7,  19
 Dw  203,  78, 142, 153
 Dw  203,  79,  82,  19
 Dw  203,  84, 142,  22
 Dw  203,  85,  82,  61
 Dw  203,  86, 136,  82
 Dw  203,  87,  76,  28
 Dw  203,  88,  21, 150
 Dw  203,  93, 275, 177
 Dw  203,  94,  92, 199
 Dw  203,  95, 138, 154
 Dw  203,  96, 178, 193
 Dw  203,  97,  70, 167
 Dw  203, 102,  68, 149
 Dw  203, 103, 165,  69
 Dw  203, 104, 155, 109
 Dw  203, 105,  59, 153
 Dw  203, 106,  50, 116
 Dw  203, 112, 241,  84
 Dw  203, 113, 319,   5
 Dw  203, 114, 120,  93
 Dw  203, 115, 135, 192
 Dw  203, 116,  58, 161
 Dw  203, 117,  17, 162
 Dw  203, 118, 256, 191
 Dw  203, 119,  15, 160
 Dw  203, 120,  51,  32
 Dw  203, 121, 147,  70
 Dw  203, 122, 248,  24
 Dw  203, 123, 313,  88
 Dw  203, 124,  57,  36
 Dw  204,  75, 233,  79
 Dw  204,  76,  54, 183
 Dw  204,  77,  31, 129
 Dw  204,  78,  10,  64
 Dw  204,  79, 229,  61
 Dw  204,  84, 306,  29
 Dw  204,  85,   8, 147
 Dw  204,  86,  79,  16
 Dw  204,  87,  39,  83
 Dw  204,  88,  25, 153
 Dw  204,  93, 246, 143
 Dw  204,  94, 282, 176
 Dw  204,  95, 246,  96
 Dw  204,  96, 202, 158
 Dw  204,  97,  44,  99
 Dw  204, 102, 190,  94
 Dw  204, 103, 222,  35
 Dw  204, 104, 109, 145
 Dw  204, 105,  11,  35
 Dw  204, 106,  13, 182
 Dw  204, 112,  21, 130
 Dw  204, 113, 121, 122
 Dw  204, 114, 157,  78
 Dw  204, 115, 189,  24
 Dw  204, 116, 294,  28
 Dw  204, 117, 150, 113
 Dw  204, 118, 183, 140
 Dw  204, 119, 109, 199
 Dw  204, 120, 216, 137
 Dw  204, 121, 105, 187
 Dw  204, 122,  17,  15
 Dw  204, 123, 146,  11
 Dw  204, 124, 160, 169
 Dw  205,  75, 123,   3
 Dw  205,  76, 301,  80
 Dw  205,  77, 259, 139
 Dw  205,  78, 150, 105
 Dw  205,  79, 272,  57
 Dw  205,  84, 248,  19
 Dw  205,  85, 302, 195
 Dw  205,  86, 172, 168
 Dw  205,  87,  24,  48
 Dw  205,  88, 249, 151
 Dw  205,  93, 112, 192
 Dw  205,  94, 104,  14
 Dw  205,  95,  76, 161
 Dw  205,  96, 250, 172
 Dw  205,  97,  12, 137
 Dw  205, 102, 230, 127
 Dw  205, 103, 101,  49
 Dw  205, 104, 316, 113
 Dw  205, 105, 140, 117
 Dw  205, 106,  94,  33
 Dw  205, 107, 130, 144
 Dw  206,  75, 174, 109
 Dw  206,  76, 199, 113
 Dw  206,  77, 167, 125
 Dw  206,  78, 105,  66
 Dw  206,  79, 293, 176
 Dw  206,  84, 257, 125
 Dw  206,  85, 260, 100
 Dw  206,  86, 181, 153
 Dw  206,  87,  27,  10
 Dw  206,  88,  60, 197
 Dw  206,  93, 120,   7
 Dw  206,  94, 155, 103
 Dw  206,  95, 177, 187
 Dw  206,  96,  36, 172
 Dw  206,  97, 277, 113
 Dw  206, 102, 293, 124
 Dw  206, 103,  51, 187
 Dw  206, 104, 164, 146
 Dw  206, 105, 279, 173
 Dw  206, 106, 316, 199
 Dw  206, 107, 228,  19
 Dw  206, 108, 215,  43
 Dw  206, 109,  61, 120
 Dw  207,  75, 107,  68
 Dw  207,  76, 139,  70
 Dw  207,  77, 108,  94
 Dw  207,  78, 301, 162
 Dw  207,  79, 180, 113
 Dw  207,  84,  70, 157
 Dw  207,  85,  31,  40
 Dw  207,  86, 148,  99
 Dw  207,  87,  21, 163
 Dw  207,  88, 221, 197
 Dw  207,  93,  26,  35
 Dw  207,  94,  14,  42
 Dw  207,  95,  45,  11
 Dw  207,  96,  32,  86
 Dw  207,  97,   3,  72
 Dw  207, 102, 150, 153
 Dw  207, 103, 129,  38
 Dw  207, 104,   0, 198
 Dw  207, 105, 159, 112
 Dw  207, 106, 112, 196
 Dw  207, 107, 175, 155
 Dw  207, 108, 246,  81
 Dw  207, 109, 232, 137
 Dw  207, 110, 100,  95
 Dw  207, 112, 122,  59
 Dw  207, 113, 293, 186
 Dw  207, 114, 121, 103
 Dw  207, 115, 302, 112
 Dw  207, 116,  64, 191
 Dw  207, 117,  68, 189
 Dw  207, 118, 300,  15
 Dw  207, 119, 191,  33
 Dw  207, 120, 147,  22
 Dw  207, 121, 209, 142
 Dw  207, 122,  79, 111
 Dw  207, 123, 316, 168
 Dw  207, 124, 248,  35
 Dw  208,  75,  60,  22
 Dw  208,  76, 133, 154
 Dw  208,  77, 193, 161
 Dw  208,  78,  67,  35
 Dw  208,  79,  96, 104
 Dw  208,  84,   9,  48
 Dw  208,  85, 298,  19
 Dw  208,  86, 291, 159
 Dw  208,  87, 126, 140
 Dw  208,  88, 214, 155
 Dw  208,  89, 156, 145
 Dw  208,  90,   4,   8
 Dw  208,  91, 312, 153
 Dw  208,  92, 241, 128
 Dw  208,  93, 219, 189
 Dw  208,  94, 287,  84
 Dw  208,  95, 213,  43
 Dw  208,  96, 212,  62
 Dw  208,  97, 150, 110
 Dw  208, 102, 234, 142
 Dw  208, 103,   9,   4
 Dw  208, 104,  74, 148
 Dw  208, 105, 261,  51
 Dw  208, 106, 111,  61
 Dw  208, 107,  57, 156
 Dw  208, 108, 156,  49
 Dw  208, 109,   3,  27
 Dw  208, 110, 130,  13
 Dw  208, 111,  76, 187
 Dw  208, 112, 241, 181
 Dw  208, 113, 235,  23
 Dw  208, 114, 288, 163
 Dw  208, 115, 192,  14
 Dw  208, 116,  15, 109
 Dw  208, 117,   1, 105
 Dw  208, 118, 303,  62
 Dw  208, 119, 314,  42
 Dw  208, 120, 246,  59
 Dw  208, 121, 278, 148
 Dw  208, 122, 289, 171
 Dw  208, 123, 100,  55
 Dw  208, 124, 241, 137
 Dw  209,  75, 311, 172
 Dw  209,  76, 259,  82
 Dw  209,  77, 137, 102
 Dw  209,  78, 184,  64
 Dw  209,  79, 281,  88
 Dw  209,  84,  32,  61
 Dw  209,  85, 185,   4
 Dw  209,  86,  68,  22
 Dw  209,  87,  79,  66
 Dw  209,  88, 221, 103
 Dw  209,  89, 237,  79
 Dw  209,  90,   0,  14
 Dw  209,  91, 259, 105
 Dw  209,  92, 101,  93
 Dw  209,  93, 238,  62
 Dw  209,  94, 290, 134
 Dw  209,  95,  48,  23
 Dw  209,  96,  69,  85
 Dw  209,  97,  75,  57
 Dw  209, 104,  34, 151
 Dw  209, 105,  99,  55
 Dw  209, 106,  45,  95
 Dw  209, 107, 131,  89
 Dw  209, 108, 285,   7
 Dw  209, 109,  62,  64
 Dw  209, 110, 200,   1
 Dw  209, 111, 190,  75
 Dw  209, 112, 276,  26
 Dw  209, 113, 257, 169
 Dw  209, 114, 202, 157
 Dw  209, 115, 200,   1
 Dw  209, 116, 150,  33
 Dw  209, 117,  84, 180
 Dw  209, 118, 146, 125
 Dw  209, 119,  13, 117
 Dw  209, 120, 266, 191
 Dw  209, 121, 218,  47
 Dw  209, 122, 316, 111
 Dw  209, 123,  28, 146
 Dw  209, 124, 285, 145
 Dw  210,  75, 256, 123
 Dw  210,  76,  77, 121
 Dw  210,  77, 171,  97
 Dw  210,  78, 278,  84
 Dw  210,  79, 154,  40
 Dw  210,  84,  77,  23
 Dw  210,  85,  99, 101
 Dw  210,  86,  12, 107
 Dw  210,  87, 317, 193
 Dw  210,  88,  59, 129
 Dw  210,  89, 302,  50
 Dw  210,  90, 256, 115
 Dw  210,  91,  30,  41
 Dw  210,  92, 301,  81
 Dw  210,  93, 263,  54
 Dw  210,  94,  32, 199
 Dw  210,  95, 308,  22
 Dw  210,  96, 273,  55
 Dw  210,  97,  81, 114
 Dw  210, 106,  37, 156
 Dw  210, 107, 295,  72
 Dw  210, 108, 272,  78
 Dw  210, 109, 113, 195
 Dw  210, 110,  91, 106
 Dw  210, 111, 308, 166
 Dw  210, 112, 280,  55
 Dw  210, 113, 235, 125
 Dw  210, 114, 207,  29
 Dw  210, 115,  32,  68
 Dw  210, 116, 201, 106
 Dw  210, 117,   7,  98
 Dw  210, 118, 154,   7
 Dw  210, 119, 173,  90
 Dw  210, 120, 196,  25
 Dw  210, 121,  48, 197
 Dw  210, 122,  86, 189
 Dw  210, 123, 210,  71
 Dw  210, 124, 162,  38
 Dw  211,  75, 165, 117
 Dw  211,  76, 309,  59
 Dw  211,  77, 242, 157
 Dw  211,  78, 271,  87
 Dw  211,  79, 293, 116
 Dw  211,  84, 186,  18
 Dw  211,  85, 227,  10
 Dw  211,  86,   0,  17
 Dw  211,  87,  95, 165
 Dw  211,  88,  25,  87
 Dw  211,  89, 110,  13
 Dw  211,  90, 156,  79
 Dw  211,  91, 103, 121
 Dw  211,  92, 187, 107
 Dw  211,  93, 213,  97
 Dw  211,  94, 184, 146
 Dw  211,  95, 244, 106
 Dw  211,  96, 292,  71
 Dw  211, 108, 292, 177
 Dw  211, 109,  75,  39
 Dw  211, 110, 220,  99
 Dw  211, 111, 125, 147
 Dw  211, 112, 124,   5
 Dw  211, 113, 110, 171
 Dw  211, 114, 148, 143
 Dw  211, 115,   3,  33
 Dw  211, 116,  42,  27
 Dw  211, 117,  90,  95
 Dw  211, 118, 183, 165
 Dw  211, 119, 283,  13
 Dw  211, 120, 125,  63
 Dw  211, 121, 241, 173
 Dw  211, 122,  83,   4
 Dw  211, 123,  11, 127
 Dw  211, 124, 293, 189
 Dw  212,  75,   0, 151
 Dw  212,  76, 305,  55
 Dw  212,  77, 141,  56
 Dw  212,  78,  13,  40
 Dw  212,  79,  86,  53
 Dw  212,  85, 171, 127
 Dw  212,  86, 151, 121
 Dw  212,  87, 198, 122
 Dw  212,  88, 200, 178
 Dw  212,  89, 131, 110
 Dw  212,  90, 185, 187
 Dw  212,  91, 232, 135
 Dw  212,  92,  21,  19
 Dw  212,  93, 119,  54
 Dw  212,  94, 101,  90
 Dw  212,  95,  67, 110
 Dw  212,  96, 302,  94
 Dw  212, 110, 102,  65
 Dw  212, 111, 217, 166
 Dw  212, 112,  14, 160
 Dw  212, 113, 228,  77
 Dw  212, 114, 237,  12
 Dw  212, 115, 239, 101
 Dw  212, 120, 152,  42
 Dw  212, 121, 314,  60
 Dw  212, 122,  13,  39
 Dw  212, 123, 208,  89
 Dw  212, 124,   2, 132
 Dw  213,  75, 277, 113
 Dw  213,  76, 217, 104
 Dw  213,  77, 265, 101
 Dw  213,  78,  61,   9
 Dw  213,  79, 220, 164
 Dw  213,  80,  32, 117
 Dw  213,  86, 200,  74
 Dw  213,  87,  68,  59
 Dw  213,  88, 302, 186
 Dw  213,  89, 159,  97
 Dw  213,  90,  60,   4
 Dw  213,  91, 103,  83
 Dw  213,  92, 201, 105
 Dw  213,  93, 122, 141
 Dw  213,  94, 210, 154
 Dw  213,  95,  12, 126
 Dw  213, 101, 266,  11
 Dw  213, 112, 305,   6
 Dw  213, 113, 227, 179
 Dw  213, 114,  65, 110
 Dw  213, 115, 217,  87
 Dw  213, 120,  99,  98
 Dw  213, 121, 123, 156
 Dw  213, 122, 264,  86
 Dw  213, 123, 178,  49
 Dw  213, 124, 140,  84
 Dw  214,  75,  72, 137
 Dw  214,  76, 235,  95
 Dw  214,  77, 220, 101
 Dw  214,  78,  14, 106
 Dw  214,  79, 237, 198
 Dw  214,  80,  22,  43
 Dw  214,  81, 313, 195
 Dw  214, 100,  55,  12
 Dw  214, 101,  60,  20
 Dw  214, 102, 177, 190
 Dw  214, 103,  63,  16
 Dw  214, 114, 212,   1
 Dw  214, 115, 203, 167
 Dw  214, 120, 193,  44
 Dw  214, 121, 151,  65
 Dw  214, 122, 125,  80
 Dw  214, 123, 119,  86
 Dw  214, 124,  76,  80
 Dw  215,  75,  32,  66
 Dw  215,  76, 111, 128
 Dw  215,  77, 200,  14
 Dw  215,  78, 256,  62
 Dw  215,  79, 203,  80
 Dw  215,  80, 167, 180
 Dw  215,  81, 179,   0
 Dw  215,  82, 157, 176
 Dw  215,  99, 111, 134
 Dw  215, 100, 185, 122
 Dw  215, 101, 201,  38
 Dw  215, 102, 234, 187
 Dw  215, 103, 303, 159
 Dw  215, 104, 124, 192
 Dw  215, 105,  70, 116
 Dw  215, 120, 101, 195
 Dw  215, 121, 203,  45
 Dw  215, 122, 101, 103
 Dw  215, 123, 191, 174
 Dw  215, 124, 124,  13
 Dw  216,  76, 152,   5
 Dw  216,  77, 122, 171
 Dw  216,  78,  64, 172
 Dw  216,  79,  72, 152
 Dw  216,  80,  23,  51
 Dw  216,  81,  59,  59
 Dw  216,  82,  66,  80
 Dw  216,  99, 269,  23
 Dw  216, 100, 178, 188
 Dw  216, 101, 213, 133
 Dw  216, 102, 137, 169
 Dw  216, 103, 129, 148
 Dw  216, 104, 285, 114
 Dw  216, 105, 215,  32
 Dw  216, 106, 172,  26
 Dw  216, 107, 143, 181
 Dw  216, 120, 155,  38
 Dw  216, 121, 110,  47
 Dw  216, 122, 183,  67
 Dw  216, 123, 293, 153
 Dw  216, 124,  40,   3
 Dw  217,  77,  98, 112
 Dw  217,  78, 249, 181
 Dw  217,  79,   6, 115
 Dw  217,  80,  66, 132
 Dw  217,  81, 213,  17
 Dw  217,  82, 240,  66
 Dw  217,  83, 283,   1
 Dw  217,  98,  95, 174
 Dw  217,  99, 271,  18
 Dw  217, 100, 287,  98
 Dw  217, 101,  11, 105
 Dw  217, 102, 318, 177
 Dw  217, 103,  64,  74
 Dw  217, 104,  67,  96
 Dw  217, 105, 217, 168
 Dw  217, 106,  33,  59
 Dw  217, 107, 151,  88
 Dw  217, 108, 109,   7
 Dw  217, 109, 257,  75
 Dw  217, 120,  44, 103
 Dw  217, 121,  10, 162
 Dw  217, 122,   3, 105
 Dw  217, 123,  32, 169
 Dw  217, 124,  34, 155
 Dw  218,  78, 309,  67
 Dw  218,  79, 227,  97
 Dw  218,  80, 214, 175
 Dw  218,  81, 206, 146
 Dw  218,  82, 302, 123
 Dw  218,  83, 231, 146
 Dw  218,  84, 184, 139
 Dw  218,  97, 136, 112
 Dw  218,  98, 292,  94
 Dw  218,  99, 146,   5
 Dw  218, 100,  60, 173
 Dw  218, 101, 291, 139
 Dw  218, 102, 195,  89
 Dw  218, 103,  33,  63
 Dw  218, 104, 110,  22
 Dw  218, 105, 130,  16
 Dw  218, 106, 278,  88
 Dw  218, 107, 185, 105
 Dw  218, 108, 103,  36
 Dw  218, 109, 134, 198
 Dw  218, 110, 247,  66
 Dw  218, 111, 256, 182
 Dw  218, 120, 203, 160
 Dw  218, 121, 107,  84
 Dw  218, 122, 182, 140
 Dw  218, 123,  90, 195
 Dw  218, 124, 198, 127
 Dw  219,  78, 134,   8
 Dw  219,  79, 142, 123
 Dw  219,  80,   5, 195
 Dw  219,  81, 276,  79
 Dw  219,  82,  34, 143
 Dw  219,  83,  30,  94
 Dw  219,  84, 221, 185
 Dw  219,  85, 132, 185
 Dw  219,  86, 199, 114
 Dw  219,  87,  28, 178
 Dw  219,  88,  68,  49
 Dw  219,  89, 262,  79
 Dw  219,  90, 292, 126
 Dw  219,  91,  24, 141
 Dw  219,  92, 171, 180
 Dw  219,  93, 318, 113
 Dw  219,  94, 282,   5
 Dw  219,  95, 254, 190
 Dw  219,  96, 256,  33
 Dw  219,  97, 273,  17
 Dw  219,  98, 302, 151
 Dw  219,  99, 281,   0
 Dw  219, 100, 261, 176
 Dw  219, 101, 261, 171
 Dw  219, 102, 284,   3
 Dw  219, 103, 157, 139
 Dw  219, 104, 259,  68
 Dw  219, 105,  20,  98
 Dw  219, 106,  19,  16
 Dw  219, 107, 249, 113
 Dw  219, 108, 167, 139
 Dw  219, 109, 213, 158
 Dw  219, 110, 271, 152
 Dw  219, 111,  35,  21
 Dw  219, 112, 191, 189
 Dw  219, 113, 152,  62
 Dw  219, 120, 156,  83
 Dw  219, 121,  53,  26
 Dw  219, 122,  94,  97
 Dw  219, 123, 275,   0
 Dw  219, 124,  57, 103
 Dw  220,  79, 253,  31
 Dw  220,  80, 165,  39
 Dw  220,  81,  77, 171
 Dw  220,  82, 162, 162
 Dw  220,  83, 230, 178
 Dw  220,  84,  41,  28
 Dw  220,  85, 140, 140
 Dw  220,  86,  62,   2
 Dw  220,  87,  17, 150
 Dw  220,  88, 197, 153
 Dw  220,  89, 265, 196
 Dw  220,  90,  43,   8
 Dw  220,  91, 193,  92
 Dw  220,  92,  15, 144
 Dw  220,  93, 106, 126
 Dw  220,  94, 251, 179
 Dw  220,  95,   0, 138
 Dw  220,  96, 106,  42
 Dw  220,  97,  60,   5
 Dw  220,  98, 261, 199
 Dw  220,  99, 207, 158
 Dw  220, 100, 259, 182
 Dw  220, 101, 182, 194
 Dw  220, 103,  39,  33
 Dw  220, 104, 155, 114
 Dw  220, 105,  50,  90
 Dw  220, 106, 311, 152
 Dw  220, 107,  35,  28
 Dw  220, 108, 173,  24
 Dw  220, 109, 184,  91
 Dw  220, 110, 147,  61
 Dw  220, 111, 104, 124
 Dw  220, 112, 104, 149
 Dw  220, 113, 109,  33
 Dw  220, 114, 221,  61
 Dw  220, 115, 120, 189
 Dw  220, 120,   5, 181
 Dw  220, 121, 195, 117
 Dw  220, 122, 247, 106
 Dw  220, 123,  53,  54
 Dw  220, 124, 150,  52
 Dw  221,  80, 186,  48
 Dw  221,  81, 294,  18
 Dw  221,  82, 148,  68
 Dw  221,  83,  11, 151
 Dw  221,  84, 306,  91
 Dw  221,  85, 298, 166
 Dw  221,  86, 239, 160
 Dw  221,  87,  61, 155
 Dw  221,  88, 224,  45
 Dw  221,  89, 154, 153
 Dw  221,  90, 128,  24
 Dw  221,  91, 314,  75
 Dw  221,  92,  45, 122
 Dw  221,  93,  67, 115
 Dw  221,  94,  61,   0
 Dw  221,  95,  88, 106
 Dw  221,  96, 110, 149
 Dw  221,  97, 204,  33
 Dw  221,  98,  24,  83
 Dw  221,  99, 268, 102
 Dw  221, 100, 270,  75
 Dw  221, 105, 286,  58
 Dw  221, 106, 104,  38
 Dw  221, 107,  67,  51
 Dw  221, 108, 209, 192
 Dw  221, 109,  83,  47
 Dw  221, 110, 299,  23
 Dw  221, 111, 126, 174
 Dw  221, 112, 191,  68
 Dw  221, 113, 160, 114
 Dw  221, 114, 121, 134
 Dw  221, 115, 119,  25
 Dw  221, 120, 310, 196
 Dw  221, 121,  13, 191
 Dw  221, 122, 210,  58
 Dw  221, 123, 132,  13
 Dw  221, 124, 151, 151
 Dw  222,  81, 300,   6
 Dw  222,  82, 211,  34
 Dw  222,  83,  67, 135
 Dw  222,  84, 163,  64
 Dw  222,  85, 213,  62
 Dw  222,  86, 272, 133
 Dw  222,  87, 263, 113
 Dw  222,  88, 242,   2
 Dw  222,  89, 228,  48
 Dw  222,  90,  80,  50
 Dw  222,  91, 139, 155
 Dw  222,  92,  20,  67
 Dw  222,  93,   1,  39
 Dw  222,  94, 237,   4
 Dw  222,  95, 294, 122
 Dw  222,  96, 209,   6
 Dw  222,  97,  35, 132
 Dw  222,  98, 219, 154
 Dw  222,  99,  68, 107
 Dw  222, 107, 213, 131
 Dw  222, 108,  95,  73
 Dw  222, 109, 272, 130
 Dw  222, 110, 169,  32
 Dw  222, 111, 309, 150
 Dw  222, 112, 120, 116
 Dw  222, 113, 208,  66
 Dw  222, 114, 109,  50
 Dw  222, 115,  98, 122
 Dw  222, 120, 112,  76
 Dw  222, 121, 222, 159
 Dw  222, 122,  71, 168
 Dw  222, 123, 249, 106
 Dw  222, 124, 292,  11
 Dw  223,  82, 211, 134
 Dw  223,  83, 144,  71
 Dw  223,  84, 190, 139
 Dw  223,  85, 227, 106
 Dw  223,  86, 147,  17
 Dw  223,  87, 153, 172
 Dw  223,  88,  49, 117
 Dw  223,  89, 147, 170
 Dw  223,  90, 240,  31
 Dw  223,  91,  55,  66
 Dw  223,  92, 148, 196
 Dw  223,  93, 275, 155
 Dw  223,  94, 226, 193
 Dw  223,  95, 285, 195
 Dw  223,  96, 261,  92
 Dw  223,  97,  94,  73
 Dw  223,  98,  54,  35
 Dw  223, 109, 112, 134
 Dw  223, 110, 270, 113
 Dw  223, 111, 129, 139
 Dw  223, 112,  13,  28
 Dw  223, 113, 109,  80
 Dw  223, 114, 266,  85
 Dw  223, 115, 128, 116
 Dw  223, 120,  17, 122
 Dw  223, 121,  67, 160
 Dw  223, 122, 118,   3
 Dw  223, 123,  83,  81
 Dw  223, 124, 257,   1
 Dw  224,  83,  63, 151
 Dw  224,  84,  99, 188
 Dw  224,  85, 214, 198
 Dw  224,  90,  41,  48
 Dw  224,  91, 177,   6
 Dw  224,  92,  14, 158
 Dw  224,  93, 268, 104
 Dw  224,  94, 247,  20
 Dw  224,  95, 158,   2
 Dw  224,  97,  26,  14
 Dw  224,  98,  25, 111
 Dw  224, 111, 124,  42
 Dw  224, 112, 302,  95
 Dw  224, 113, 302, 136
 Dw  224, 114,  75,  14
 Dw  224, 115, 266, 107
 Dw  224, 116,  38,  85
 Dw  224, 117, 123, 191
 Dw  224, 118, 285, 122
 Dw  224, 119, 251,  91
 Dw  224, 120, 286,   0
 Dw  224, 121, 288,  53
 Dw  224, 122, 134,  89
 Dw  224, 123, 215,  83
 Dw  224, 124,   3,  92
 Dw  225, 111, 181,  42
 Dw  225, 112, 265, 166
 Dw  225, 113, 292,  25
 Dw  225, 114,  19,  35
 Dw  225, 115,  59,  66
 Dw  225, 116, 135,  66
 Dw  225, 117, 150,  63
 Dw  225, 118, 106, 150
 Dw  225, 119, 239,  80
 Dw  225, 120,  88,  32
 Dw  225, 121, 226,  11
 Dw  225, 122, 133,  34
 Dw  225, 123,  63,  60
 Dw  225, 124, 166, 130
 Dw  226, 111, 185, 133
 Dw  226, 112, 214,   3
 Dw  226, 113, 169,  87
 Dw  226, 114, 142, 147
 Dw  226, 115,  36,  32
 Dw  226, 116, 145, 148
 Dw  226, 117,  52, 140
 Dw  226, 118, 133, 101
 Dw  226, 119,  70,  49
 Dw  226, 120,  69,   3
 Dw  226, 121, 215,   9
 Dw  226, 122, 187, 169
 Dw  226, 123, 254, 182
 Dw  226, 124, 115,  26
 Dw  227, 111, 256, 115
 Dw  227, 112, 143,  21
 Dw  227, 113,  52, 114
 Dw  227, 114, 305,  94
 Dw  227, 115, 252,  42
 Dw  227, 116,  52, 171
 Dw  227, 117, 257, 150
 Dw  227, 118,  70,   5
 Dw  227, 119,   9, 186
 Dw  227, 120, 241, 139
 Dw  227, 121, 133,  73
 Dw  227, 122, 274,   2
 Dw  227, 123,   7, 114
 Dw  227, 124,  14,  28
Jsr_Logo Ends

End Start
