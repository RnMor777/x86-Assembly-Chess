%define BOARD_FILE 'media/board.txt'
%define INTRO_FILE 'media/intro.txt'
%define STRUC_FILE 'media/instructions.txt'
%define SAVE_FILE  'saves/saves.txt'
%define INIT_FILE  'media/.init'
%define EXITCHAR   'x'
%define BACKCHAR   'z'
%define UNDOCHAR   'u'
%define HEIGHT     15
%define WIDTH      72 
%define TOPVERT    4  
%define TOPHORZ    25
%define ENDVERT    12
%define ENDHORZ    41 
%define ENDHORZ2   42
%define TURNLOC    99

segment .data
    board_file          db  BOARD_FILE, 0
    intro_file          db  INTRO_FILE, 0
    struc_file          db  STRUC_FILE, 0
    save_file           db  SAVE_FILE, 0
    init_file           db  INIT_FILE, 0
    mode_r              db  "r", 0
    mode_w              db  "w", 0
    raw_mode_on_cmd     db  "stty raw -echo", 0
    raw_mode_off_cmd    db  "stty -raw echo", 0
    clear_screen_cmd    db  "clear", 0
    color_normal        db  0x1b, "[0m", 0
    color_square1       db  0x1b, "[104m", 0, 0
    color_square2       db  0x1b, "[44m", 0, 0, 0
    color_edge          db  0x1b, "[100m", 0, 0
    color_move          db  0x1b, "[42m", 0
    color_black         db  0x1b, "[30m", 0, 0, 0
    color_white         db  0x1b, "[97m", 0

    BPAWN               dw  __utf32__("♟"), 0, 0
    BROOK               dw  __utf32__("♜"), 0, 0
    BKNIGHT             dw  __utf32__("♞"), 0, 0
    BBISH               dw  __utf32__("♝"), 0, 0
    BQUEEN              dw  __utf32__("♛"), 0, 0
    BKING               dw  __utf32__("♚"), 0, 0
    WPAWN               dw  __utf32__("♙"), 0, 0
    WROOK               dw  __utf32__("♖"), 0, 0
    WKNIGHT             dw  __utf32__("♘"), 0, 0
    WBISH               dw  __utf32__("♗"), 0, 0
    WQUEEN              dw  __utf32__("♕"), 0, 0
    WKING               dw  __utf32__("♔"), 0, 0
    VERT                dw  __utf32__("│"), 0, 0
    HORIZ               dw  __utf32__("─"), 0, 0
    CORNUL              dw  __utf32__("┌"), 0, 0
    CORNUR              dw  __utf32__("┐"), 0, 0
    CORNLL              dw  __utf32__("└"), 0, 0
    CORNLR              dw  __utf32__("┘"), 0, 0
    UNICSPACE           dw  __utf32__(" "), 0, 0
    copysymbol          dw  __utf32__("©"), 0, 0
    frmt_unic           db  "%ls", 0
    frmt_reg            db  "%s", 0
    newline             db  10, 0
    frmt_locale         db  "", 0
    frmt_scan           db  "%c%d", 0
    frmt_space          db  " ", 0
    frmt_space18        db  "%54s", 0
    frmt_spacesave      db  "%36s", 0
    frmt_spacecheck     db  "%42s", 0
    frmt_spacemate      db  "%46s", 0
    frmt_print          db  "Enter a move: ", 0
    frmt_print2         db  "Enter a destination: ", 0
    frmt_bcheck         db  "Black in Check", 10, 13, 0
    frmt_wcheck         db  "White in Check", 10, 13, 0
    frmt_turn           db  "White",0,0,0,"Black"
    frmt_saved          db  "Saved",0
    frmt_mate           db  "Checkmate - Game Over!", 10, 13, 0
    frmt_again          db  "Play again? (y/n): ", 0
    frmt_instructions   db  "u - undo, z - back, x - exit, s - save",10,13,0
    frmt_capture1       db  " Captured by white: ", 0
    frmt_capture2       db  " Captured by black: ", 0
    frmt_promote        db  "Enter a promotion Bishop(B), Rook(R), Knight(K), or Queen (Q): ", 0
    frmt_intro          db  "Enter an option: ", 0
    frmt_cont           db  "---- Press any key to continue ----", 0
    memjumparr          db  3,0,0,0,0,0,2,0,0,5,0,0,0,0,0,4,1
    knightarr           dd  -1,-2,1,-2,2,-1,2,1,-1,2,1,2,-2,1,-2,-1

segment .bss
    board       resb    (HEIGHT*WIDTH)
    introboard  resb    (HEIGHT*WIDTH)
    strucboard  resb    (HEIGHT*WIDTH)
    pieces      resb    (8*8)
    markarr     resb    (8*8)
    userin      resb    4
    xpos        resd    1
    ypos        resd    1
    select      resb    1
    selectFlag  resb    1
    errorflag   resd    1
    prevChar    resb    1
    currChar    resb    1
    xyposCur    resd    1
    xyposLast1  resd    1
    xyposLast2  resd    1
    captureW    resb    5
    captureB    resb    5
    playerTurn  resb    1
    canCastleW  resb    2
    canCastleB  resb    2
    prevCastle  resb    4
    wasCastle   resb    1
    inCheck     resb    2

segment .text
	global  main
    extern  system
    extern  putchar
    extern  getchar
    extern  printf
    extern  scanf
    extern  fopen
    extern  fread
    extern  fwrite
    extern  fgetc
    extern  fclose
    extern  setlocale

; main()
main:
    enter   0, 0
    pusha
	; ********** CODE STARTS HERE **********

    ; scans in all of the files
    push    1
    call    init_intro    	
    add     esp, 4

    push    2 
    call    init_intro
    add     esp, 4

    push    3
    call    init_intro
    add     esp, 4

    ; sets up unicode support
    push    frmt_locale
    push    0x6
    call    setlocale
    add     esp, 8

    call    seed_start

    ; runs the initial start screen
    start_intro:
    push    introboard 
    call    render_intro
    add     esp, 4

    push    frmt_intro
    call    printf
    add     esp, 4
    
    push    userin
    push    frmt_reg
    call    scanf
    add     esp, 8

    mov     ebx, 0
    mov     bl, BYTE[userin]
    cmp     bl, '1'
    je      game_loop
    cmp     bl, '2'
    je      struc_loop
    cmp     bl, '3'
    je      game_load      
    cmp     bl, '4'
    je      game_loop_end
    jmp     start_intro

    ; loads a saved game
    game_load:
        call    save_intro
        jmp     game_bottom

    ; runs the instruction screen
    struc_loop:
    push    strucboard
    call    render_intro
    add     esp, 4

    push    frmt_cont
    call    printf
    add     esp, 4

    push    raw_mode_on_cmd
    call    system
    add     esp, 4

    call    getchar
    call    getchar

    push    raw_mode_off_cmd
    call    system
    add     esp, 4

    jmp     start_intro

    game_loop:
        ; prints the game board
        call    render
        call    clearmoves

        push    frmt_print
        call    printf
        add     esp, 4
   
        push    userin
        push    frmt_reg
        call    scanf
        add     esp, 8
    
        ; Exit function by entering an x
        mov     eax, 0
        mov     al, BYTE[userin]
        cmp     al, EXITCHAR
        je      again_loop_end

        ; Just clears the board
        cmp     al, BACKCHAR
        je      game_bottom

        cmp     al, 's'
        jne      save_func2
            mov     DWORD[errorflag], 0x777
            call    save_current
            jmp     game_bottom
        save_func2:

        ; runs an undo function for the last move
        cmp     al, UNDOCHAR
        jne     end_undo
        cmp     DWORD[xyposLast1], -1
        je      end_undo
        cmp     BYTE[wasCastle], 1
        je      undocastle1
        cmp     BYTE[wasCastle], 2
        je      undocastle2
        cmp     BYTE[wasCastle], 3
        je      undocastle3
        cmp     BYTE[wasCastle], 4
        je      undocastle4
        jmp     botundocastle
            undocastle1:
            mov     BYTE[pieces], "R"
            mov     BYTE[pieces+4], "K"
            mov     BYTE[pieces+2], "-"
            mov     BYTE[pieces+3], "-"
            jmp     botundocastle
            undocastle2:
            mov     BYTE[pieces+7], "R"
            mov     BYTE[pieces+4], "K"
            mov     BYTE[pieces+5], "-"
            mov     BYTE[pieces+6], "-"
            jmp     botundocastle
            undocastle3:
            mov     BYTE[pieces+56], "r"
            mov     BYTE[pieces+60], "k"
            mov     BYTE[pieces+58], "-"
            mov     BYTE[pieces+59], "-"
            jmp     botundocastle
            undocastle4:
            mov     BYTE[pieces+63], "r"
            mov     BYTE[pieces+60], "k"
            mov     BYTE[pieces+61], "-"
            mov     BYTE[pieces+62], "-"

            botundocastle:
            mov     bl, BYTE[prevCastle]
            mov     BYTE[canCastleW], bl
            mov     bl, BYTE[prevCastle+1]
            mov     BYTE[canCastleW+1], bl
            mov     bl, BYTE[prevCastle+2]
            mov     BYTE[canCastleB], bl
            mov     bl, BYTE[prevCastle+3]
            mov     BYTE[canCastleB+1], bl
            endundocastle:

            mov     edx, 0
            mov     ebx, DWORD[xyposLast1]
            mov     ecx, DWORD[xyposLast2]
            mov     dl, BYTE[currChar]
            mov     BYTE[pieces+ebx], dl
            mov     dl, BYTE[prevChar]
            mov     BYTE[pieces+ecx], dl
            mov     DWORD[xyposLast1], -1
            xor     BYTE[playerTurn], 1
    
            push    -1
            push    edx
            call    fill_capture
            add     esp, 8 
    
            jmp     game_bottom
        end_undo:

        ; Converts the entered points into integer values in the array
        call    convertpoint

        cmp     eax, 0x420
        je      game_bottom

        mov     DWORD[xyposCur], eax
        xor     ebx, ebx
        mov     bl, BYTE[pieces+eax]
    
        cmp     bl, "-"
        je      game_bottom
            push    ebx
            call    procTurns
            add     esp, 4
        game_next:

        call    sieve_check

        ; Calculates the number of moves for the selected piece
        call    calcnumbmoves
        cmp     eax, 0
        je      game_bottom

        ; Re-renders showing highlighted move spaces
        call    render

        push    frmt_print2
        call    printf
        add     esp, 4

        push    userin
        push    frmt_reg
        call    scanf
        add     esp, 8

        mov     eax, 0
        mov     al, BYTE[userin]

        ; Just clears the board
        cmp     al, BACKCHAR
        je      game_bottom

        ; Converts the entered points into integer values in the array
        call    convertpoint

        cmp     eax, 0x420
        je      game_next

        mov     ecx, eax
        xor     ebx, ebx
        mov     bl, BYTE[markarr+eax]

        mov     eax, DWORD[xyposCur]

        ; Does the moving of the pieces
        cmp     bl, "+"
        jne     game_next
            ; Moves the game piece
            ; dl is the current moving piece
            ; bl is the character being overwritten
            mov     dl, BYTE[pieces+eax] 
            mov     bl, BYTE[pieces+ecx]
            mov     BYTE[pieces+ecx], dl
            mov     BYTE[pieces+eax], "-"

            mov     DWORD[xyposLast1], eax
            mov     DWORD[xyposLast2], ecx
            mov     BYTE[prevChar], bl
            mov     BYTE[currChar], dl

            ; Changes the player turn marker
            xor     BYTE[playerTurn], 1

            ; Castling Function
            ; Stores current castle info 
            mov     esi, ebx
            mov     bl, BYTE[canCastleW]
            mov     BYTE[prevCastle], bl
            mov     bl, BYTE[canCastleW+1]
            mov     BYTE[prevCastle+1], bl
            mov     bl, BYTE[canCastleB]
            mov     BYTE[prevCastle+2], bl
            mov     bl, BYTE[canCastleB+1]
            mov     BYTE[prevCastle+3], bl
            mov     ebx, esi

            ; Changes castling information depending on move piece
            cmp     dl, "k"
            jne     next_castle
                mov     BYTE[canCastleW], 0
                mov     BYTE[canCastleW+1], 0
                jmp     next_castle2
            next_castle:
            cmp     dl, "K"
            jne     next_castle2
                mov     BYTE[canCastleB], 0
                mov     BYTE[canCastleB+1], 0
                jmp     next_castle2
            next_castle2:
            cmp     BYTE[pieces], "R"
            je      next_castle3
                mov     BYTE[canCastleB], 0
            next_castle3:
            cmp     BYTE[pieces+7], "R"
            je      next_castle4
                mov     BYTE[canCastleB+1], 0
            next_castle4:
            cmp     BYTE[pieces+56], "r"
            je      next_castle5
                mov     BYTE[canCastleW], 0
            next_castle5:
            cmp     BYTE[pieces+63], "r"
            je      next_castle6
                mov     BYTE[canCastleW+1], 0
            next_castle6:

            ; Does the castling
            cmp     dl, "K"
            je      upper_castle
            cmp     dl, "k"
            je      lower_castle
            mov     BYTE[wasCastle], 0
            jmp     end_castle_func

            upper_castle:
            mov     esi, ecx
            sub     esi, eax

                cmp     esi, -2
                je      upper_castle_queen
                cmp     esi, 2
                je      upper_castle_king
                jmp     end_castle_func

                upper_castle_queen:
                mov     BYTE[pieces+3], "R"
                mov     BYTE[pieces+0], "-"
                mov     BYTE[wasCastle], 1
                jmp     end_castle_func

                upper_castle_king:
                mov     BYTE[pieces+5], "R"
                mov     BYTE[pieces+7], "-"
                mov     BYTE[wasCastle], 2
            jmp     end_castle_func
            lower_castle:
            mov     esi, ecx
            sub     esi, eax
                cmp     esi, -2
                je      lower_castle_queen
                cmp     esi, 2
                je      lower_castle_king
                jmp     end_castle_func

                lower_castle_queen:
                mov     BYTE[pieces+59], "r"
                mov     BYTE[pieces+56], "-"
                mov     BYTE[wasCastle], 3
                jmp     end_castle_func

                lower_castle_king:
                mov     BYTE[pieces+61], "r"
                mov     BYTE[pieces+63], "-"
                mov     BYTE[wasCastle], 4

            end_castle_func:

            ; Keeps track of captured pieces
            push    1
            push    ebx
            call    fill_capture
            add     esp, 8

            mov     dl, BYTE[currChar]

            ; Promote Pawn
            cmp     dl, "P"
            je      promote_pawn1
            cmp     dl, "p"
            je      promote_pawn2

            jmp     game_bottom

            promote_pawn1:
            cmp     DWORD[xyposLast2], 56
            jl      game_bottom
                prom_top:
                push    frmt_promote
                call    printf
                add     esp, 4
           
                push    userin
                push    frmt_reg
                call    scanf
                add     esp, 8

                cmp     BYTE[userin], "R"
                jne     prom_next1
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "R"
                    jmp     game_bottom
                prom_next1:
                cmp     BYTE[userin], "K"
                jne     prom_next2
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "K"
                    jmp     game_bottom
                prom_next2:
                cmp     BYTE[userin], "B"
                jne     prom_next3
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "B"
                    jmp     game_bottom
                prom_next3:
                cmp     BYTE[userin], "Q"
                jne     prom_top
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "Q"
                    jmp     game_bottom

            promote_pawn2:
            cmp     DWORD[xyposLast2], 8
            jge     game_bottom
                prom_top2:
                push    frmt_promote
                call    printf
                add     esp, 4
           
                push    userin
                push    frmt_reg
                call    scanf
                add     esp, 8

                cmp     BYTE[userin], "R"
                jne     prom_next21
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "r"
                    jmp     game_bottom
                prom_next21:
                cmp     BYTE[userin], "K"
                jne     prom_next22
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "k"
                    jmp     game_bottom
                prom_next22:
                cmp     BYTE[userin], "B"
                jne     prom_next23
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "b"
                    jmp     game_bottom
                prom_next23:
                cmp     BYTE[userin], "Q"
                jne     prom_top2
                    mov     eax, DWORD[xyposLast2]
                    mov     BYTE[pieces+eax], "q"
                    jmp     game_bottom

        game_bottom:
        ; Calc Check Function
        push    0
        call    bwcalc_check
        add     esp, 4

        push    32
        call    bwcalc_check
        add     esp, 4

        call    clearmoves

        cmp     BYTE[inCheck], 0
        je      skip_mate
            push    0 
            call    procCheckmate
            add     esp, 4
        skip_mate:
        cmp     BYTE[inCheck+1], 0
        je      skip_mate2
            push    32
            call    procCheckmate
            add     esp, 4
        skip_mate2:

        cmp     DWORD[errorflag], 0xAA
        je      game_loop_end

        jmp     game_loop
    game_loop_end:

    again_loop:
        call    render
        push    frmt_again
        call    printf
        add     esp, 4
        push    userin
        push    frmt_reg
        call    scanf
        add     esp, 8
    cmp     BYTE[userin], "y"
    je      start_game
    cmp     BYTE[userin], "n"
    je      again_loop_end
    jmp     again_loop
    start_game:
        call    seed_start
        jmp     game_loop
    again_loop_end:

	; *********** CODE ENDS HERE ***********
    popa
    mov     eax, 0
    leave
	ret

; void seed_start()
seed_start:
    push    ebp
    mov     ebp, esp

    lea     esi, [init_file]
    lea     edi, [pieces]

    push    mode_r
    push    esi
    call    fopen
    add     esp, 8

    push    eax
    push    64
    push    1
    push    edi
    call    fread
    add     esp, 16

    mov     BYTE[playerTurn], 0
    mov     DWORD[xyposLast1], -1
    mov     BYTE[inCheck], 0
    mov     BYTE[inCheck+1], 0
    mov     DWORD[captureW], 0
    mov     BYTE[captureW+4], 0
    mov     DWORD[captureB], 0
    mov     BYTE[captureB+4], 0
    mov     BYTE[canCastleW], 1
    mov     BYTE[canCastleW+1], 1
    mov     BYTE[canCastleB], 1
    mov     BYTE[canCastleB+1], 1
    mov     BYTE[wasCastle], 0
    mov     DWORD[errorflag], 0 

    call    clearmoves

    mov     esp, ebp
    pop     ebp
    ret

; void render()
render:
    push    ebp
    mov     ebp, esp

    sub     esp, 12
    push    clear_screen_cmd
    call    system
    add     esp, 4

    mov     DWORD[ebp-4], 0
    push    newline
    call    printf
    add     esp, 4

    push    frmt_instructions
    push    frmt_space18
    call    printf
    add     esp, 8

    ; prints the turn marker
    xor     eax, eax
    mov     al, BYTE[playerTurn]
    lea     ebx, [frmt_turn+eax*8]
    mov     ecx, 0
    top_turn_mark:
    cmp     ecx, 5
    je      end_turn_mark
        mov     al, BYTE[ebx]
        mov     BYTE[board+TURNLOC+ecx], al 
    inc     ebx
    inc     ecx
    jmp     top_turn_mark
    end_turn_mark:

    mov     DWORD[ebp-4], 0
    y_loop_start:
    cmp     DWORD[ebp-4], HEIGHT
    je      y_loop_end
        mov     DWORD[ebp-8], 0
        x_loop_start:
        cmp     DWORD[ebp-8], WIDTH
        je      x_loop_end
            ; Colors the board
            ; makes sure the color is within the board location
            cmp     DWORD[ebp-8], TOPHORZ
            jl      endprintboard
            cmp     DWORD[ebp-8], ENDHORZ
            jge     endprintboard
            cmp     DWORD[ebp-4], TOPVERT
            jl      endprintboard
            cmp     DWORD[ebp-4], ENDVERT
            jge     endprintboard
                ; ((2*(row%2) + xpos%4)%4)/2 
                ; this assigns a square either 0 or 1 to print color box
                mov     ecx, DWORD[ebp-4]
                sub     ecx, TOPVERT 
                and     ecx, 0x1
                shl     ecx, 1
                mov     edx, DWORD[ebp-8]
                sub     edx, TOPHORZ
                and     edx, 0x3
                add     ecx, edx
                and     ecx, 0x3

                ; does some stupid contiguous memory things to load proper color
                shr     ecx, 1
                or      cl, BYTE[selectFlag]
                lea     edx, [color_square1+ecx*8]
                push    edx
                call    printf
                add     esp, 4

                shr     BYTE[selectFlag], 2

                ; this will only print the character once in a square
                mov     edx, DWORD[ebp-8]
                sub     edx, TOPHORZ
                test    edx, 1
                jnz     endprintboard

                ; edx will be 0-7
                ; ecx will be location within the board
                mov     ecx, DWORD[ebp-4]
                sub     ecx, TOPVERT
                shr     edx, 1
                shl     ecx, 3
                add     ecx, edx
                mov     DWORD[ebp-12], ecx

                ; sets the color is the square is to be highlighted
                cmp     BYTE[markarr+ecx], "+"
                jne     selectedcolorend
                    push    color_move
                    call    printf
                    add     esp, 4
                    mov     BYTE[selectFlag], 0x3
                selectedcolorend: 

                ; prints the chess pieces and proper colors
                mov     ecx, DWORD[ebp-12]
                mov     al, BYTE[pieces+ecx]

                cmp     al, "-"
                je      endprintboard

                ; this converts the character to 14, 16, 6, 0, 15, 9
                ; points to an array which redirects to the proper memory address
                sub     al, 66
                mov     ebx, 32
                cdq
                div     ebx
                mov     ebx, 0
                mov     bl, BYTE[memjumparr+edx]
                lea     ecx, [eax*8]
                shl     eax, 1
                sub     ecx, eax
                add     ebx, ecx
                lea     ebx, [BPAWN+ebx*8]

                ; prints either the char in black or white
                mov     DWORD[ebp-12], ebx
                shr     ecx, 2
                lea     ebx, [color_black+ecx*8]
                push    ebx
                call    printf
                add     esp, 4
                mov     ebx, DWORD[ebp-12]
                
                ; prints the unicode chess piece
                push    ebx
                push    frmt_unic
                call    printf
                add     esp, 8
                jmp     piece_end
            endprintboard:

            ; Gets the board character at the location
            ; eax is offset from 0 to the current piece
            ; bl is the piece itself
            mov     eax, [ebp-4]
            mov     ebx, WIDTH
            mul     ebx
            add     eax, [ebp-8]
            mov     ebx, 0
            mov     bl, BYTE[board+eax]
            mov     DWORD[ebp-12], ebx

            ; This sets all the special unicode board characters
            cmp     bl, "M"
            jl      endspecial
            cmp     bl, "S"
            jg      endspecial

            push    color_edge
            call    printf
            add     esp, 4

            push    color_white
            call    printf
            add     esp, 4

            mov     ebx, DWORD[ebp-12]
            sub     ebx, 77
            lea     eax, [VERT+ebx*8]
            push    eax
            push    frmt_unic
            call    printf
            add     esp, 8
            jmp     piece_end
            endspecial:
            
            ; Default regular character
            push    ebx     
            call    putchar
            add     esp, 4

            piece_end:
            push    color_normal
            call    printf
            add     esp, 4
        inc     DWORD[ebp-8]
        jmp     x_loop_start

        x_loop_end:
        push    0x0d
        call    putchar
        add     esp, 4
        push    0x0a
        call    putchar
        add     esp, 4
    inc     DWORD[ebp-4]
    jmp     y_loop_start
    y_loop_end:

    cmp     DWORD[errorflag], 0xAA
    jne     err_next
        push    frmt_mate
        push    frmt_spacemate
        call    printf
        add     esp, 8
        jmp     err_next3
    err_next:
    cmp     BYTE[inCheck], 1
    jne     err_next1
        push    frmt_bcheck
        push    frmt_spacecheck
        call    printf
        add     esp, 8
    err_next1:
    cmp     BYTE[inCheck+1], 1
    jne     err_next2
        push    frmt_wcheck
        push    frmt_spacecheck
        call    printf
        add     esp, 8
    err_next2:
    cmp     DWORD[errorflag], 0x777
    jne     err_next3
        push    frmt_saved
        push    frmt_spacesave
        call    printf
        add     esp, 8
        mov     DWORD[errorflag], 0
    err_next3:

    push    newline
    call    printf
    add     esp, 4
    call    func_print_captured
    push    newline
    call    printf
    add     esp, 4
    
    mov     esp, ebp
    pop     ebp
    ret

; int calc_square (pos x, pos y, offset x, offset y)
calc_square:
    push    ebp
    mov     ebp, esp    

    sub     esp, 4

    mov     eax, DWORD[ebp+12]
    add     eax, DWORD[ebp+20]

    ; This makes sure the move is within the y values of the square
    cmp     eax, 0
    jl      errSquare
    cmp     eax, 7
    jg      errSquare    

    shl     eax, 3
    mov     DWORD[ebp-4], eax
    mov     eax, DWORD[ebp+8]
    add     eax, DWORD[ebp+16]
    
    ; Makes sure the move is within the x bounds
    cmp     eax, 0
    jl      errSquare
    cmp     eax, 7
    jg      errSquare
    
    add     eax, DWORD[ebp-4]
    jmp     regEnd

    errSquare:
    mov     eax, 0x420
    regEnd:

    mov     esp, ebp
    pop     ebp
    ret

; void clearmoves() - clears the possible moves array
clearmoves:
    push    ebp
    mov     ebp, esp

    mov     BYTE[selectFlag], 0x0
    mov     eax, 0
    startclear:
    cmp     eax, 64
    jge     endclear
        mov     BYTE[markarr+eax], ""
        inc     eax
        jmp     startclear
    endclear:
    mov     esp, ebp
    pop     ebp
    ret

; void processlines(increment x, increment y, opponent marker (A or a))
processlines:
    push    ebp
    mov     ebp, esp

    ; Checks the line until hits a stoping point
    mov     ecx, 1
    mov     esi, DWORD[ebp+8]
    mov     edi, DWORD[ebp+12]
    topprocess:
    push    edi
    push    esi
    push    DWORD[ypos]
    push    DWORD[xpos]
    call    calc_square
    add     esp, 16

    ; calculates until square does not exist
    cmp     eax, 0x420
    je      endprocess2

    ; if the space is open
    cmp     BYTE[pieces+eax], "-"
    je      bottomprocess

    ; jumps if its a uppercase piece being moved
    cmp     BYTE[ebp+16], "A"
    jne     processupper

        ; compares with it's own pieces (lowercase)
        cmp     BYTE[pieces+eax], "Z"
        jg      endprocess2
        ; if the piece is able to be captured. Then also end the function
        cmp     BYTE[pieces+eax], "A"
        jg      endprocess1

        jmp     bottomprocess

    processupper:
    ; compares with its own pieces (uppercase)
    cmp     BYTE[pieces+eax], "Z"
    jl      endprocess2 
    ; if the piece is able to be captured. Then also end the function
    cmp     BYTE[pieces+eax], "a"
    jg      endprocess1

    bottomprocess:
    mov     BYTE[markarr+eax], "+"

    inc     ecx
    add     esi, DWORD[ebp+8]
    add     edi, DWORD[ebp+12]
    jmp     topprocess
    endprocess1:
    mov     BYTE[markarr+eax], "+"
    endprocess2:

    mov     esp, ebp
    pop     ebp
    ret

; void processknight (opponent marker (A or a))
processknight:
    push    ebp
    mov     ebp, esp

    mov     ebx, 0
    top_kloop:
    cmp     ebx, 16
    jge     end_kloop
        mov     ecx, DWORD[knightarr+4*ebx]
        mov     edx, DWORD[knightarr+4*(ebx+1)]
        push    DWORD[ebp+8]
        push    ecx
        push    edx
        call    processmove
        add     esp, 12
    add     ebx, 2
    jmp     top_kloop
    end_kloop:

    mov     esp, ebp
    pop     ebp
    ret

; void processmove (offset x, offset y, opponent marker (A or a))
processmove:
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+12]
    push    DWORD[ebp+8]
    push    DWORD[ypos]
    push    DWORD[xpos]
    call    calc_square
    add     esp, 16

    ; checks if it's a valid movement
    cmp     eax, 0x420
    je      end_processmove
    cmp     BYTE[pieces+eax], "-"
    je      move_add

    cmp     BYTE[ebp+16], "A"
    jne     processmove_upper
        cmp     BYTE[pieces+eax], "Z"
        jg      end_processmove
        jmp     move_add
    processmove_upper:
        cmp     BYTE[pieces+eax], "Z"
        jl      end_processmove

    move_add:
    mov     BYTE[markarr+eax], "+"
    end_processmove:

    mov     esp, ebp
    pop     ebp
    ret

; void processrook (opponent marker (A or a))
processrook:
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+8]
    push    -1
    push    0
    call    processlines
    add     esp, 12

    push    DWORD[ebp+8]
    push    1
    push    0
    call    processlines
    add     esp, 12

    push    DWORD[ebp+8]
    push    0
    push    -1
    call    processlines
    add     esp, 12

    push    DWORD[ebp+8]
    push    0
    push    1
    call    processlines
    add     esp, 12

    mov     esp, ebp
    pop     ebp
    ret

; void processpawn (opponent marker (A or a))
processpawn:
    push    ebp
    mov     ebp, esp
    
    sub     esp, 12

    ; switch to either negative or positive
    cmp     BYTE[ebp+8], "A"
    jne     pawnpositive
        mov     DWORD[ebp-4], -1
        mov     dWORD[ebp-12], -1
        mov     DWORD[ebp-8], 6
        jmp     pawnnegative
    pawnpositive:
        mov     DWORD[ebp-4], 1
        mov     DWORD[ebp-8], 1
        mov     DWORD[ebp-12], 1
    pawnnegative:

    push    DWORD[ebp+8]
    push    DWORD[ebp-4]
    push    0
    call    processpawn2
    add     esp, 12
        
    ; If position is initial then can move y-2
    cmp     eax, 0x420
    je      endpawngame
    mov     ecx, DWORD[ypos]
    cmp     ecx, DWORD[ebp-8]
    jne     endpawngame
        push    DWORD[ebp+8]
        shl     DWORD[ebp-12], 1
        push    DWORD[ebp-12]
        push    0
        call    processpawn2
        add     esp, 12
    endpawngame:
    
    ; If enemy is at either (x+/-1, y-1) then can move there. Need to do taking
    push    DWORD[ebp+8]
    push    DWORD[ebp-4]
    push    1
    call    processpawn2
    add     esp, 12
    
    push    DWORD[ebp+8]
    push    DWORD[ebp-4]
    push    -1
    call    processpawn2
    add     esp, 12

    ; Check en passant?
    
    mov     esp, ebp
    pop     ebp
    ret

; int processpawn2 (offset x, offset y, opponent marker (A or a))
processpawn2:
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+12]
    push    DWORD[ebp+8]
    push    DWORD[ypos]
    push    DWORD[xpos]
    call    calc_square
    add     esp, 16

    ; Checks for actual moveable space on the board
    cmp     eax, 0x420
    je      endpawn
    ; checks if it is moving forward spaces
    cmp     DWORD[ebp+8], 0
    je      pawnstraight
        cmp     BYTE[ebp+16], "A"
        jne     pawnopp
            ; checks to see if it can take a piece in the diagonals
            cmp     BYTE[pieces+eax], "A"
            jl      endpawn
            cmp     BYTE[pieces+eax], "Z"
            jg      endpawn
                mov     BYTE[markarr+eax], "+"
                jmp     endpawn
        pawnopp:
            cmp     BYTE[pieces+eax], "a"
            jl      endpawn
                mov     BYTE[markarr+eax], "+"
                jmp     endpawn

    pawnstraight:
    ; default moving straight
    cmp     BYTE[pieces+eax], "-"
    jne     endpawn2
        mov     BYTE[markarr+eax], "+"
        jmp     endpawn
    endpawn2:
    ; sets error so won't jump twice if it can't move once
    mov     eax, 0x420
    endpawn:

    mov     esp, ebp
    pop     ebp
    ret

; void processbishop (opponent marker (A or a))
processbishop:
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+8]
    push    -1
    push    -1
    call    processlines
    add     esp, 12

    push    DWORD[ebp+8]
    push    -1
    push    1
    call    processlines
    add     esp, 12

    push    DWORD[ebp+8]
    push    1
    push    -1
    call    processlines
    add     esp, 12

    push    DWORD[ebp+8]
    push    1
    push    1
    call    processlines
    add     esp, 12

    mov     esp, ebp
    pop     ebp
    ret

; void processking (opponent marker (A or a))
processking:
    push    ebp
    mov     ebp, esp

    sub     esp, 8

    ; processes the king's move square
    mov     DWORD[ebp-4], 1
    top_proc_king:
    cmp     DWORD[ebp-4], -2
    je      end_proc_king
        mov     DWORD[ebp-8], 1
        top_inner_proc_king:
        cmp     DWORD[ebp-8], -2
        je      bot_proc_king
            push    DWORD[ebp+8]
            push    DWORD[ebp-4]
            push    DWORD[ebp-8]
            call    processmove
            add     esp, 12
            dec     DWORD[ebp-8]
            jmp     top_inner_proc_king
        bot_proc_king:
        dec     DWORD[ebp-4]
        jmp     top_proc_king
    end_proc_king:
    
    ; Check for castling
    cmp     DWORD[ebp+8], "A"
    jne     blackCastle
        cmp     BYTE[canCastleW], 1
        je      wqueenside
        jmp     wkingside

        wqueenside:
        cmp     BYTE[pieces+57], "-"
        jne     wkingside
        cmp     BYTE[pieces+58], "-"
        jne     wkingside
        cmp     BYTE[pieces+59], "-"
            mov     BYTE[markarr+58], "+"

        wkingside:
        cmp     BYTE[canCastleW+1], 1
        jne     endCastle

        cmp     BYTE[pieces+61], "-"
        jne     endCastle
        cmp     BYTE[pieces+62], "-"
        jne     endCastle
            mov     BYTE[markarr+62], "+"
        jmp     endCastle
    blackCastle:
        cmp     BYTE[canCastleB], 1
        je      bqueenside
        jmp     bkingside
        
        bqueenside:
        cmp     BYTE[pieces+1], "-"
        jne     bkingside
        cmp     BYTE[pieces+2], "-"
        jne     bkingside
        cmp     BYTE[pieces+3], "-"
        jne     bkingside
            mov     BYTE[markarr+2], "+"

        bkingside:
        cmp     BYTE[canCastleB+1], 1
        jne     endCastle

        cmp     BYTE[pieces+5], "-"
        jne     endCastle
        cmp     BYTE[pieces+6], "-"
        jne     endCastle
            mov     BYTE[markarr+6], "+"
    endCastle:

    mov     esp, ebp
    pop     ebp
    ret

; int convertpoint ()
convertpoint:
    push    ebp
    mov     ebp, esp

    ; first letter entered is moved to al
    mov     eax, 0
    mov     al, BYTE[userin]

    ; Check to see if valid
    mov     ebx, eax
    sub     ebx, 97
    cmp     ebx, 0
    jl      failconvert
    cmp     ebx, 7
    jg      failconvert
        mov     DWORD[xpos], ebx

    mov     al, BYTE[userin+1]
    mov     ebx, eax
    sub     ebx, 49

    cmp     ebx, 0
    jl      failconvert
    cmp     ebx, 7
    jg      failconvert
        mov     ecx, 7
        sub     ecx, ebx
        mov     DWORD[ypos], ecx

    push    0
    push    0
    push    DWORD[ypos]
    push    DWORD[xpos]
    call    calc_square
    add     esp, 16

    cmp     eax, 0x420
    je      failconvert

    mov     bl, BYTE[pieces+eax]
    mov     BYTE[select], bl
    
    jmp     endconvert
    failconvert:
    mov     eax, 0x420
    endconvert:
    
    mov     esp, ebp
    pop     ebp
    ret

; int calcnumbmoves ()
calcnumbmoves:
    push    ebp
    mov     ebp, esp

    mov     ecx, 0
    mov     eax, 0
    top_calcloop:
    cmp     ecx, 64
    jge     end_calcloop
        cmp     BYTE[markarr+ecx], "+"
        jne     bot_calcloop
            inc     eax
    bot_calcloop:
    inc     ecx
    jmp     top_calcloop
    end_calcloop:

    cmp     eax, 0
    jne     endcalc0
        mov     DWORD[errorflag], 0x69
    endcalc0:

    mov     esp, ebp
    pop     ebp
    ret

; void func_print_captured ()
func_print_captured:
    push    ebp
    mov     ebp, esp

    sub     esp, 8

    push    frmt_capture1
    call    printf
    add     esp, 4

    mov     DWORD[ebp-4], 0
    top_captured:
    cmp     DWORD[ebp-4], 5
    jge     end_captured
        mov     ecx, DWORD[ebp-4]
        mov     ebx, 0
        mov     bl, BYTE[captureW+ecx]
        mov     DWORD[ebp-8], ebx
        loop_captured:
        mov     ebx, DWORD[ebp-8]
        cmp     ebx, 0
        je      bot_captured
            mov     ecx, DWORD[ebp-4]
            lea     eax, [BPAWN+ecx*8]
            push    eax
            push    frmt_unic
            call    printf
            add     esp, 8
        dec     DWORD[ebp-8]
        jmp     loop_captured
    bot_captured:
    inc     DWORD[ebp-4]
    jmp     top_captured
    end_captured:

    push    13
    push    newline
    call    printf
    add     esp, 8

    push    frmt_capture2
    call    printf
    add     esp, 4

    mov     DWORD[ebp-4], 0
    top_captured2:
    cmp     DWORD[ebp-4], 5
    jge     end_captured2
        mov     ecx, DWORD[ebp-4]
        mov     ebx, 0
        mov     bl, BYTE[captureB+ecx]
        mov     DWORD[ebp-8], ebx
        loop_captured2:
        mov     ebx, DWORD[ebp-8]
        cmp     ebx, 0
        je      bot_captured2
            mov     ecx, DWORD[ebp-4]
            lea     eax, [WPAWN+ecx*8]
            push    eax
            push    frmt_unic
            call    printf
            add     esp, 8
        dec     DWORD[ebp-8]
        jmp     loop_captured2
    bot_captured2:
    inc     DWORD[ebp-4]
    jmp     top_captured2
    end_captured2:

    push    13
    push    newline
    call    printf
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret

; void fill_capture (char a, int amount)
fill_capture:
    push    ebp
    mov     ebp, esp
    
    mov     eax, DWORD[ebp+8]

    sub     al, 66
    mov     ebx, 32
    cdq
    div     ebx
    mov     ebx, 0
    mov     bl, BYTE[memjumparr+edx]
    lea     ecx, [eax*8]
    lea     esi, [eax*4]
    sub     ecx, esi
    add     ecx, eax
    add     ebx, ecx
    lea     ebx, [captureW+ebx]
    mov     ecx, DWORD[ebp+12]
    add     BYTE[ebx], cl

    mov     esp, ebp
    pop     ebp
    ret

; void render_intro()
render_intro:
    push    ebp
    mov     ebp, esp

	sub		esp, 8

	push	clear_screen_cmd
	call	system
	add		esp, 4

	mov		DWORD [ebp-4], 0
	intro_y_loop_start:
	cmp		DWORD [ebp-4], HEIGHT
	je		intro_y_loop_end
		mov		DWORD [ebp-8], 0
		intro_x_loop_start:
		cmp		DWORD [ebp-8], WIDTH
		je 		intro_x_loop_end
            mov		eax, [ebp-4]
            mov		ebx, WIDTH
            mul		ebx
            add		eax, [ebp-8]
            mov		ebx, 0
            mov     esi, DWORD[ebp+8]
            lea     esi, [esi]
            mov		bl, BYTE [esi + eax] ;introboard + eax]

            cmp     bl, '?'
            je      intro_x_loop_end

            cmp     bl, '%'
            jne     intro_x_endif
                push    copysymbol
                push    frmt_unic
                call    printf
                add     esp, 8
                jmp     intro_x_bottom
            intro_x_endif:
            push	ebx
			call	putchar
			add		esp, 4

        intro_x_bottom:
		inc		DWORD [ebp-8]
		jmp		intro_x_loop_start
		intro_x_loop_end:

		; write a carriage return (necessary when in raw mode)
		push	0x0d
		call 	putchar
		add		esp, 4

		; write a newline
		push	0x0a
		call	putchar
		add		esp, 4

	inc		DWORD [ebp-4]
	jmp		intro_y_loop_start
    intro_y_loop_end:
    
    push    newline
    call    printf
    add     esp, 4    

    mov     esp, ebp
    pop     ebp
    ret

; void init_intro(int a)
init_intro:
    push    ebp
    mov     ebp, esp

    cmp     DWORD[ebp+8], 1
    jne     init_intro_if1
        lea     esi, [intro_file]
        lea     edi, [introboard]
        jmp     init_intro_endif

    init_intro_if1:
    cmp     DWORD[ebp+8], 2
    jne     init_intro_if2
        lea     esi, [struc_file]
        lea     edi, [strucboard]
        jmp     init_intro_endif

    init_intro_if2:
        lea     esi, [board_file]
        lea     edi, [board]
        jmp     init_intro_endif

    init_intro_endif:

    sub     esp, 8
    push    mode_r
    push    esi
    call    fopen
    add     esp, 8
    mov     DWORD[ebp-4], eax

    mov     DWORD[ebp-8], 0
    intro_read_loop:
    cmp     DWORD[ebp-8], HEIGHT
    je      intro_read_loop_end
        mov     eax, WIDTH
        mul     DWORD [ebp-8]
        lea     ebx, [edi+eax] 

        push    DWORD[ebp-4]
        push    WIDTH
        push    1
        push    ebx
        call    fread
        add     esp, 16

        push    DWORD[ebp-4]
        call    fgetc
        add     esp, 4
    inc     DWORD[ebp-8]
    jmp     intro_read_loop
    intro_read_loop_end:

    push    DWORD[ebp-4]
    call    fclose
    add     esp, 4
    
    mov     esp, ebp
    pop     ebp
    ret

; void save_intro() 
save_intro:
    push    ebp
    mov     ebp, esp

    lea     esi, [save_file]
    lea     edi, [pieces]

    sub     esp, 4

    push    mode_r
    push    esi
    call    fopen
    add     esp, 8
    mov     DWORD[ebp-4], eax

    ; loads in the pieces array
    push    DWORD[ebp-4]
    push    64
    push    1
    push    edi
    call    fread
    add     esp, 16

    ; loads in saved capture data for white
    lea     ebx, [captureW]

    push    DWORD[ebp-4]
    push    5
    push    1
    push    ebx
    call    fread
    add     esp, 16

    ; loads in saved capture data for black
    lea     ebx, [captureB]

    push    DWORD[ebp-4]
    push    5
    push    1
    push    ebx
    call    fread
    add     esp, 16
    ; loads in turn data and castling info
    ; takes advantage of how variables are stored in memory next to each other
    lea     ebx, [playerTurn] 

    push    DWORD[ebp-4]
    push    5
    push    1
    push    ebx
    call    fread
    add     esp, 16

    push    DWORD[ebp-4]
    call    fclose
    add     esp, 4

    mov     DWORD[xyposLast1], -1

    mov     esp, ebp
    pop     ebp
    ret

; void save_current ()
save_current:
    push    ebp
    mov     ebp, esp

    sub     esp, 4
    lea     esi, [save_file]

    push    mode_w
    push    esi
    call    fopen
    add     esp, 8
    mov     DWORD[ebp-4], eax

    ; writes the board to the file
    lea     ebx, [pieces]
    push    DWORD[ebp-4]
    push    64
    push    1
    push    ebx
    call    fwrite
    add     esp, 16

    lea     ebx, [captureW]
    push    DWORD[ebp-4]
    push    10
    push    1
    push    ebx
    call    fwrite
    add     esp, 16

    lea     ebx, [playerTurn]
    push    DWORD[ebp-4]
    push    5
    push    1
    push    ebx
    call    fwrite
    add     esp, 16

    push    DWORD[ebp-4]
    call    fclose
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret
; void processlinescheck(int inc_x, int inc_y, int mark_offset, int init_pos)
processlinescheck:
    push    ebp
    mov     ebp, esp

    ; calc (x,y) of the king location
    ; eax is y, ebx is x
    sub     esp, 8
    mov     eax, DWORD[ebp+20]
    shr     eax, 3
    mov     ebx, DWORD[ebp+20]
    lea     ecx, [eax*8]
    sub     ebx, ecx
    
    mov     DWORD[ebp-4], eax
    mov     DWORD[ebp-8], ebx
    mov     esi, DWORD[ebp+8]
    mov     edi, DWORD[ebp+12]

    topprocesscheck:
    push    edi
    push    esi
    push    DWORD[ebp-4]
    push    DWORD[ebp-8]
    call    calc_square
    add     esp, 16

    cmp     eax, 0x420
    je      endprocesscheck
    cmp     BYTE[pieces+eax], "-"
    je      botprocesscheck

        mov     ebx, "Z"
        add     ebx, DWORD[ebp+16]
        xor     ecx, ecx
        mov     cl, BYTE[pieces+eax]
        sub     ecx, ebx

        ; checks condition if the piece is an enemy or not
        cmp     ecx, 0
        jg      n_check
        cmp     ecx, -32
        jle     n_check
        jmp     endprocesscheck
        
        n_check:
        mov     ebx, DWORD[ebp-4]
        add     ebx, DWORD[ebp-8]
        xor     ecx, ecx

        mov     cl, "q"
        sub     ecx, DWORD[ebp+16]
        cmp     BYTE[pieces+eax], cl
        je      needcheck

        mov     cl, "b"
        sub     ecx, DWORD[ebp+16]
        cmp     BYTE[pieces+eax],cl
        je      needcheck

        mov     cl, "r"
        sub     ecx, DWORD[ebp+16]
        cmp     BYTE[pieces+eax], cl
        je      needcheck

        jmp     endprocesscheck

    botprocesscheck:
    add     esi, DWORD[ebp+8]
    add     edi, DWORD[ebp+12]
    jmp     topprocesscheck
    needcheck:
    mov     eax, 0x800
    endprocesscheck:

    mov     esp, ebp
    pop     ebp
    ret

; void processchecksquare(int x, int y, int inc_x, int inc_y, char piece)
processchecksquare:
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+20]
    push    DWORD[ebp+16]
    push    DWORD[ebp+12]
    push    DWORD[ebp+8]
    call    calc_square
    add     esp, 16

    cmp     eax, 0x420
    je      endnext
    mov     ebx, DWORD[ebp+24]
    cmp     BYTE[pieces+eax], bl
    jne     endnext
        cmp     bl, 97
        jge     black_check
            mov     BYTE[inCheck+1], 1
            jmp     endnext
        black_check:
            mov     BYTE[inCheck], 1
    endnext:

    mov     esp, ebp
    pop     ebp
    ret

; void bwcalc_check(int b_or_w)
bwcalc_check:
    push    ebp
    mov     ebp, esp

    sub     esp, 12

    ; finds the (x,y) of the king
    mov     eax, 0
    mov     ebx, "K"
    add     ebx, DWORD[ebp+8]
    top_bcheck:
    cmp     BYTE[pieces+eax], bl
    je      bot_bcheck
        inc     eax
        jmp     top_bcheck
    bot_bcheck:
    mov     DWORD[ebp-12], eax

    ; process lines to pieces
    mov     DWORD[ebp-4], 1
    check_loop_top:
    cmp     DWORD[ebp-4], -2
    je      check_loop_end
        mov     DWORD[ebp-8], 1
        check_loop_inner:
        cmp     DWORD[ebp-8], -2
        je      check_loop_bot
                                
            push    DWORD[ebp-12]
            push    DWORD[ebp+8]
            push    DWORD[ebp-8]
            push    DWORD[ebp-4]
            call    processlinescheck
            add     esp, 16
    
            shr     eax, 11
            mov     ebx, DWORD[ebp+8]
            shr     ebx, 5
            mov     BYTE[inCheck+ebx], al
            test    al, 1
            jnz     check_loop_end

            dec     DWORD[ebp-8]
            jmp     check_loop_inner
        check_loop_bot:
        dec     DWORD[ebp-4]
        jmp     check_loop_top
    check_loop_end:

    ; ebx is x pos and eax is y pos
    mov     eax, DWORD[ebp-12]
    shr     eax, 3
    mov     ebx, DWORD[ebp-12]
    lea     ecx, [eax*8]
    sub     ebx, ecx
    mov     DWORD[ebp-4], eax
    mov     DWORD[ebp-8], ebx

    mov     ebx, "p"
    sub     ebx, DWORD[ebp+8]
    mov     ecx, DWORD[ebp+8]
    shr     ecx, 4
    mov     edx, 1
    sub     edx, ecx

    push    ebx
    push    edx
    push    1
    push    DWORD[ebp-4]
    push    DWORD[ebp-8]
    call    processchecksquare
    add     esp, 20

    push    ebx
    push    edx
    push    -1
    push    DWORD[ebp-4]
    push    DWORD[ebp-8]
    call    processchecksquare
    add     esp, 20

    mov     ebx, "h"
    sub     ebx, DWORD[ebp+8]
    mov     DWORD[ebp-12], ebx

    mov     esi, 0
    top_k_check:
    cmp     esi, 16
    jge     end_k_check
        mov     ecx, DWORD[knightarr+4*esi]
        mov     edx, DWORD[knightarr+4*(esi+1)]

        push    DWORD[ebp-12]
        push    ecx
        push    edx
        push    DWORD[ebp-4]
        push    DWORD[ebp-8]
        call    processchecksquare
        add     esp, 20
    add     esi, 2
    jmp     top_k_check
    end_k_check:

    mov     esp, ebp
    pop     ebp
    ret
; void sieve_check ()
sieve_check:
    push    ebp
    mov     ebp, esp

    sub     esp, 16

    ; stores the current inCheck in ebp-16
    xor     ebx, ebx
    xor     edx, edx
    mov     dl, BYTE[playerTurn]
    xor     dl, 1
    mov     bl, BYTE[inCheck+edx]
    mov     DWORD[ebp-16], ebx

    ; stores the current piece in ebp-4
    mov     eax, DWORD[xyposCur]     
    mov     bl, BYTE[pieces+eax]
    mov     DWORD[ebp-4], ebx

    mov     DWORD[ebp-8], 0
    mov     ecx, 0
    top_sieve:
    cmp     DWORD[ebp-8], 64
    jge     end_sieve
    mov     ecx, DWORD[ebp-8]
    cmp     BYTE[markarr+ecx], "+"
    jne     bot_sieve
        ; removes the piece
        mov     eax, DWORD[xyposCur]
        mov     BYTE[pieces+eax], "-"

        ; stores the piece currently there
        xor     edx, edx
        mov     dl, BYTE[pieces+ecx]
        mov     DWORD[ebp-12], edx

        ; moves into the pieces array the piece
        mov     ebx, DWORD[ebp-4]
        mov     BYTE[pieces+ecx], bl

        ; based on player turn to check function
        mov     dl, BYTE[playerTurn]
        xor     dl, 1
        shl     edx, 5

        push    edx
        call    bwcalc_check
        add     esp, 4

        ; see if check is still true after the movement
        xor     edx, edx
        mov     dl, BYTE[playerTurn]
        xor     dl, 1
        mov     ecx, DWORD[ebp-8]
        cmp     BYTE[inCheck+edx], 1
        jne     if_sieve
            mov     BYTE[markarr+ecx], ""
        if_sieve:

        ; resets the previous check
        mov     ebx, DWORD[ebp-16]
        mov     BYTE[inCheck+edx], bl

        ; resets the pieces array
        mov     edx, DWORD[ebp-12]
        mov     BYTE[pieces+ecx], dl
        mov     eax, DWORD[xyposCur]
        mov     edx, DWORD[ebp-4]
        mov     BYTE[pieces+eax], dl
      
    bot_sieve:
    inc     DWORD[ebp-8]
    jmp     top_sieve
    end_sieve:

    mov     esp, ebp
    pop     ebp
    ret
; void procTurns(char piece)
procTurns:
    push    ebp
    mov     ebp, esp

    sub     esp, 8

    xor     eax, eax
    mov     al, BYTE[playerTurn]
    xor     al, 1
    shl     eax, 5
    mov     DWORD[ebp-4], eax
    mov     al, BYTE[playerTurn]
    shl     eax, 5
    add     eax, "A"
    mov     DWORD[ebp-8], eax

    mov     eax, "P"
    add     eax, DWORD[ebp-4]
    cmp     DWORD[ebp+8], eax
    jne      proc_turn1
        push    DWORD[ebp-8] 
        call    processpawn
        add     esp, 4
        jmp     proc_turn_end
    proc_turn1:
    mov     eax, "R"
    add     eax, DWORD[ebp-4]
    cmp     DWORD[ebp+8], eax
    jne      proc_turn2
        push    DWORD[ebp-8] 
        call    processrook
        add     esp, 4
        jmp     proc_turn_end
    proc_turn2:
    mov     eax, "B"
    add     eax, DWORD[ebp-4]
    cmp     DWORD[ebp+8], eax
    jne      proc_turn3
        push    DWORD[ebp-8] 
        call    processbishop
        add     esp, 4
        jmp     proc_turn_end
    proc_turn3:
    mov     eax, "H"
    add     eax, DWORD[ebp-4]
    cmp     DWORD[ebp+8], eax
    jne      proc_turn4
        push    DWORD[ebp-8] 
        call    processknight
        add     esp, 4
        jmp     proc_turn_end
    proc_turn4:
    mov     eax, "Q"
    add     eax, DWORD[ebp-4]
    cmp     DWORD[ebp+8], eax
    jne      proc_turn5
        push    DWORD[ebp-8] 
        call    processrook
        add     esp, 4
        push    DWORD[ebp-8] 
        call    processbishop
        add     esp, 4
        jmp     proc_turn_end
    proc_turn5:
    mov     eax, "K"
    add     eax, DWORD[ebp-4]
    cmp     DWORD[ebp+8], eax
    jne      proc_turn_end
        push    DWORD[ebp-8] 
        call    processking
        add     esp, 4
        jmp     proc_turn_end
    proc_turn_end:
    mov     ebx, DWORD[ebp+8]

    mov     esp, ebp
    pop     ebp
    ret
; void procCheckmate(int player)
procCheckmate:
    push    ebp
    mov     ebp, esp

    sub     esp, 4
    mov     DWORD[ebp-4], 0
    call    clearmoves

    top_mate_loop:
    cmp     DWORD[ebp-4], 64
    je      end_mate_loop
        ; resets variable errorflag
        mov     DWORD[errorflag], 0

        ; sets the xyposcur, xpos, and ypos for processing the turns
        mov     ecx, DWORD[ebp-4]
        mov     DWORD[xyposCur], ecx
        mov     eax, ecx
        cdq
        mov     ebx, 8
        div     ebx
        mov     DWORD[xpos], edx
        mov     DWORD[ypos], eax

        ; moves the piece into ebx and finds difference between that and "Z"+piece
        mov     eax, DWORD[ebp+8]
        add     eax, "Z"
        xor     ebx, ebx
        mov     bl, BYTE[pieces+ecx]
        sub     eax, ebx

        cmp     eax, 0
        jl      bot_mate_loop
        cmp     eax, 26
        jg      bot_mate_loop

            ; process the turn for that char
            push    ebx
            call    procTurns
            add     esp, 4

            ; removes moves that could be used
            call    sieve_check

            ; calculates the amount of remaining moves
            call    calcnumbmoves
            cmp     DWORD[errorflag], 0x69 
            jne     not_mate

            call    clearmoves

    bot_mate_loop:
    inc     DWORD[ebp-4]
    jmp     top_mate_loop
    end_mate_loop: 

    mov     DWORD[errorflag], 0xAA
    not_mate:
    call    clearmoves

    mov     esp, ebp
    pop     ebp
    ret
; vim:ft=nasm
