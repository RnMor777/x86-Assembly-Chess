%define BOARD_FILE 'media/board.txt'
%define INTRO_FILE 'media/intro.txt'
%define STRUC_FILE 'media/instructions.txt'
%define SAVE_FILE  'saves/saves.txt'
%define FEN_FILE   'saves/saves.fen'
%define INIT_FILE  'media/.init'
%define EXITCHAR   'x'
%define BACKCHAR   'z'
%define UNDOCHAR   'u'
%define HEIGHT     15
%define WIDTH      72 
%define TOPVERT    4  
%define TOPHORZ    20
%define ENDVERT    12
%define ENDHORZ    36 
%define ENDHORZ2   37
%define TURNLOC    94

segment .data
    board_file          db  BOARD_FILE, 0
    intro_file          db  INTRO_FILE, 0
    struc_file          db  STRUC_FILE, 0
    save_file           db  SAVE_FILE, 0
    init_file           db  INIT_FILE, 0
    fen_file            db  FEN_FILE, 0
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
    CORNDOWN            dw  __utf32__("┬"), 0, 0
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
    frmt_moves          db  "%.8s", 0
    frmt_moves2         db  "%.6s", 0
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
    frmt_promote        db  "Enter a promotion Bishop(b), Rook(r), Knight(h), or Queen (q): ", 0
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
    fen         resb    90
    round       resd    1
    inGame      resb    1
    pgn         resb    1600 
    moves       resb    4
    didMove     resb    1

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

    ; scans in all of the files, sets up unicode, and defaults
    call    init_intro    	
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
    je      again_loop_end
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
    
    cmp     BYTE[inGame], 1
    je      game_loop
    jmp     start_intro

    ; actual game start
    game_loop:
        mov     BYTE[inGame], 1
        mov     BYTE[didMove], 0
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
        mov     al, BYTE[userin]
        cmp     al, EXITCHAR
        je      again_loop_end

        ; Just clears the board
        cmp     al, BACKCHAR
        je      game_bottom

        cmp     al, '?'
        je      struc_loop

        cmp     al, 's'
        jne      save_func2
            mov     DWORD[errorflag], 0x777
            call    save_current
            call    save_fen
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
            mov     ebx, DWORD[prevCastle]
            mov     DWORD[canCastleW], ebx
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

            mov     eax, DWORD[round]
            dec     eax
            shl     eax, 4
            cmp     BYTE[playerTurn], 1
            je      undoBlack
                mov     DWORD[pgn+eax], 0
                mov     DWORD[pgn+eax+4], 0
                jmp     undocap
            undoBlack:
                mov     DWORD[pgn+eax-4], 0
                mov     DWORD[pgn+eax-8], 0
                dec     DWORD[round]
            undocap:
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
        call    sieve_castle

        ; Calculates the number of moves for the selected piece
        call    calcnumbmoves
        cmp     eax, 0
        je      game_bottom

        ; Re-renders showing highlighted move spaces
        call    render

        push    frmt_print2
        call    printf
        add     esp, 4

        mov     ax, WORD[userin]
        mov     WORD[moves], ax 

        push    userin
        push    frmt_reg
        call    scanf
        add     esp, 8

        ; Just clears the board
        cmp     BYTE[userin], BACKCHAR
        je      game_bottom

        ; Converts the entered points into integer values in the array
        call    convertpoint
        cmp     eax, 0x420
        je      game_next

        mov     dx, WORD[userin]
        mov     WORD[moves+2], dx

        mov     ecx, eax
        mov     bl, BYTE[markarr+eax]
        mov     eax, DWORD[xyposCur]

        ; Does the moving of the pieces
        cmp     bl, "+"
        jne     game_next
            ; dl is the current moving piece
            ; bl is the character being overwritten
            xor     edx, edx
            mov     dl, BYTE[pieces+eax] 
            mov     bl, BYTE[pieces+ecx]
            mov     BYTE[pieces+ecx], dl
            mov     BYTE[pieces+eax], "-"

            mov     DWORD[xyposLast1], eax
            mov     DWORD[xyposLast2], ecx
            mov     BYTE[prevChar], bl
            mov     BYTE[currChar], dl
            mov     BYTE[didMove], 1

            ; Changes the player turn marker
            xor     BYTE[playerTurn], 1

            ; Stores current castle info 
            mov     esi, DWORD[canCastleW]
            mov     DWORD[prevCastle], esi

            ; Changes castling information on piece movement
            cmp     dl, "k"
            jne     next_castle
                mov     WORD[canCastleW], 0
            next_castle:
            cmp     dl, "K"
            jne     next_castle2
                mov     WORD[canCastleB], 0
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
            je      castle_move
            cmp     dl, "k"
            je      castle_move
            mov     BYTE[wasCastle], 0
            jmp     end_castle_func
    
            castle_move:
            mov     esi, ecx
            sub     esi, eax
            sub     dl, "K"
            mov     al, dl
            xor     al, 32
            mov     cl, "r"
            sub     cl, al
            shr     al, 4
            shr     dl, 5
            xor     al, 2
            imul    edx, 56
                cmp     esi, -2
                je      castle_queen
                cmp     esi, 2
                je      castle_king
                jmp     end_castle_func
            
                castle_queen:
                mov     BYTE[pieces+edx], "-"
                mov     BYTE[pieces+edx+3], cl
                mov     BYTE[wasCastle], 1
                add     BYTE[wasCastle], al
                jmp     end_castle_func

                castle_king:
                mov     BYTE[pieces+edx+5], cl
                mov     BYTE[pieces+edx+7], "-"
                mov     BYTE[wasCastle], 2
                add     BYTE[wasCastle], al
                jmp     end_castle_func
            end_castle_func:

            ; Keeps track of captured pieces
            push    1
            push    ebx
            call    fill_capture
            add     esp, 8

            ; Promote Pawn
            cmp     BYTE[currChar], "P"
            je      start_prom
            cmp     BYTE[currChar], "p"
            je      start_prom
            jmp     end_prom_pawn
            start_prom:
            mov     eax, DWORD[xyposLast2]
            mov     ebx, 56
            cdq
            div     ebx
            cmp     edx, 8
            jge     end_prom_pawn

            prom_pawn:
                call    render

                push    frmt_promote
                call    printf
                add     esp, 4
           
                push    userin
                push    frmt_reg
                call    scanf
                add     esp, 8
                
                mov     bl, BYTE[userin]
                cmp     bl, "r"
                je      do_prom
                cmp     bl, "h"
                je      do_prom
                cmp     bl, "q"
                je      do_prom
                cmp     bl, "b"
                je      do_prom
                jmp     prom_pawn

                do_prom:
                mov     eax, DWORD[xyposLast2]
                mov     ecx, eax
                and     ecx, 32
                sub     bl, cl
                mov     BYTE[pieces+eax], bl
                end_prom_pawn:


        game_bottom:
        ; Calc Check Function
        push    0
        call    bwcalc_check
        add     esp, 4

        push    32
        call    bwcalc_check
        add     esp, 4

        call    clearmoves
        cmp     BYTE[didMove], 0
        je      nolog
            call    log_moves 
        nolog:

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
    mov     WORD[inCheck], 0
    mov     DWORD[captureW], 0
    mov     BYTE[captureW+4], 0
    mov     DWORD[captureB], 0
    mov     BYTE[captureB+4], 0
    mov     DWORD[canCastleW], 0x01010101
    mov     BYTE[wasCastle], 0
    mov     DWORD[errorflag], 0 
    mov     DWORD[round], 1
    mov     BYTE[inGame], 0

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

    ;mov     DWORD[ebp-4], 0
    ;push    newline
    ;call    printf
    ;add     esp, 4

    ;push    frmt_instructions
    ;push    frmt_space18
    ;call    printf
    ;add     esp, 8

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
            xor     ebx, ebx
            mov     bl, BYTE[board+eax]
            mov     DWORD[ebp-12], ebx

            ; This sets all the special unicode board characters
            cmp     DWORD[ebp-4], 2
            jl      endspecial  
            cmp     bl, "M"
            jl      endspecial
            cmp     bl, "V"
            jg      endspecial
            cmp     bl, "T"
            je      colorless
            cmp     bl, "U"
            jl      to_color     
                sub     DWORD[ebp-12], 8 
                jmp     colorless
            to_color:
            push    color_edge
            call    printf
            add     esp, 4

            push    color_white
            call    printf
            add     esp, 4

            colorless:
            mov     ebx, DWORD[ebp-12]
            sub     ebx, 77
            lea     eax, [VERT+ebx*8]
            push    eax
            push    frmt_unic
            call    printf
            add     esp, 8
            jmp     piece_end
            endspecial:

            ; prints the log of previous moves
            cmp     bl, "w"
            jne     endtrack
                mov     bl, ' '
                mov     eax, DWORD[ebp-4]
                sub     eax, 3
                mov     ecx, DWORD[round] 
                cmp     ecx, 10
                jle     noscroll
                    add     eax, DWORD[round]
                    sub     eax, 10
                    dec     ecx
                    shl     ecx, 4
                    cmp     BYTE[pgn+ecx+1], 48
                    jge     noscroll
                        dec     eax
                noscroll:
                mov     ecx, eax
                shl     ecx, 4
                mov     DWORD[ebp-12], ecx
                cmp     BYTE[pgn+ecx+1], 48
                jl      endtrack
                    lea     edx, [pgn+ecx]
                    push    edx
                    push    frmt_moves
                    call    printf
                    add     esp, 8
                    add     DWORD[ebp-8], 7
                mov     ecx, DWORD[ebp-12]
                cmp     BYTE[pgn+ecx+9], '|'
                jne     endtrack_in
                    push    frmt_space
                    call    printf
                    add     esp, 4

                    push    VERT
                    push    frmt_unic
                    call    printf
                    add     esp, 8

                    mov     ecx, DWORD[ebp-12]
                    lea     edx, [pgn+ecx+10]
                    push    edx
                    push    frmt_moves2
                    call    printf
                    add     esp, 8
                    add     DWORD[ebp-8], 8
            endtrack_in:
                jmp     piece_end
            endtrack:
            
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

    ; checks for castling
    mov     eax, DWORD[ebp+8]
    sub     eax, "A"
    shr     eax, 5
    mov     ebx, eax
    xor     ebx, 1
    imul    ebx, 7

    cmp     BYTE[canCastleW+(eax*2)], 1
    jne     kingside
        cmp     BYTE[pieces+(ebx*8)+1], "-"
        jne     kingside
        cmp     BYTE[pieces+(ebx*8)+2], "-"
        jne     kingside
        cmp     BYTE[pieces+(ebx*8)+3], "-"
        jne     kingside
            mov     BYTE[markarr+(ebx*8)+2], "+" 
    kingside:
        cmp     BYTE[canCastleW+(eax*2)+1], 1
        jne     endCastle
            cmp     BYTE[pieces+(ebx*8)+5], "-"
            jne     endCastle
            cmp     BYTE[pieces+(ebx*8)+6], "-"
            jne     endCastle
                mov     BYTE[markarr+(ebx*8)+6], "+"
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

            ;cmp     bl, '?'
            ;je      intro_x_loop_end

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

    sub     esp, 12
    mov     DWORD[ebp-12], 0 
    lea     esi, [board_file]
    lea     edi, [board]

    top_intro_loop:
    cmp     DWORD[ebp-12], 2
    jg      end_intro_loop

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

    add     esi, 16
    add     edi, 1080
    inc     DWORD[ebp-12]

    push    DWORD[ebp-4]
    call    fclose
    add     esp, 4

    jmp     top_intro_loop
    end_intro_loop:
    
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
        mov     ebx, DWORD[ebp+8]
        add     ebx, DWORD[ebp+12]
        xor     ecx, ecx

        mov     cl, "q"
        sub     ecx, DWORD[ebp+16]
        cmp     BYTE[pieces+eax], cl
        je      needcheck

        cmp     ebx, 1
        je      r_c
        cmp     ebx, -1
        je      r_c
        mov     cl, "b"
        sub     ecx, DWORD[ebp+16]
        cmp     BYTE[pieces+eax],cl
        je      needcheck
        jmp     endprocesscheck

        r_c:
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
; void sieve_castle ()
sieve_castle:
    push    ebp
    mov     ebp, esp

    mov     ebx, DWORD[xyposCur]
    xor     eax, eax
    mov     al, BYTE[pieces+ebx]
    sub     eax, 91

    cdq
    xor     eax, edx
    sub     eax, edx

    cmp     eax, 16
    jne     end_castle_sieve
        cmp     BYTE[markarr+ebx+1], ""
        jne     next_c_s
            mov     BYTE[markarr+ebx+2], "" 
        next_c_s:
        cmp     BYTE[markarr+ebx-1], ""
        jne     next_c_s2
            mov     BYTE[markarr+ebx-2], ""
        next_c_s2:
    end_castle_sieve:

    mov     esp, ebp
    pop     ebp
    ret
;void save_fen()
save_fen: 
    push    ebp
    mov     ebp, esp
    
    ; position, count, iteration
    xor     eax, eax
    xor     ebx, ebx
    xor     ecx, ecx

    top_fen:
    cmp     ecx, 64 
    je      end_fen
        test    ecx, 7
        jnz     not_slash
        cmp     ecx, 0
        je      not_slash
            cmp     ebx, 0
            je      not_numb
                mov     BYTE[fen+eax], bl
                add     BYTE[fen+eax], 48
                inc     eax
            not_numb:
            mov     BYTE[fen+eax], '/'
            inc     eax
            xor     ebx, ebx
        not_slash: 
        cmp     BYTE[pieces+ecx], '-'
        jne     not_empty
            inc     ebx
            jmp     bot_fen
        not_empty:
        cmp     ebx, 0
        je      fen_ord
            mov     BYTE[fen+eax], bl
            add     BYTE[fen+eax], 48
            inc     eax
            xor     ebx, ebx
        fen_ord:
        mov     dl, BYTE[pieces+ecx]
        cmp     dl, "h"
        jne     fen_h1
            mov     dl, "n"
        fen_h1:
        cmp     dl, "H"
        jne     fen_h2
            mov     dl, "N" 
        fen_h2:
        cmp     dl, 96
        jle     fen_swap
            sub     dl, 32
            jmp     fen_swap2
        fen_swap:
            add     dl, 32
        fen_swap2:
        mov     BYTE[fen+eax], dl
        inc     eax
    bot_fen:
    inc     ecx
    jmp     top_fen
    end_fen:

    cmp     BYTE[playerTurn], 1
    je      fen_black
        mov     DWORD[fen+eax], ' w  '
        jmp     fen_color
    fen_black:
        mov     bl, 'b'
        mov     DWORD[fen+eax], ' b  '
    fen_color:
    add     eax, 3

    xor     ebx, ebx
    cmp     BYTE[canCastleW+1], 1
    jne     fen_castle1
        mov     BYTE[fen+eax], "K"
        inc     eax
        inc     ebx
    fen_castle1:
    cmp     BYTE[canCastleW], 1
    jne     fen_castle2
        mov     BYTE[fen+eax], "Q"
        inc     eax
        inc     ebx
    fen_castle2:
    cmp     BYTE[canCastleB+1], 1
    jne     fen_castle3
        mov     BYTE[fen+eax], "k"
        inc     eax
        inc     ebx
    fen_castle3:
    cmp     BYTE[canCastleB], 1
    jne     fen_castle4
        mov     BYTE[fen+eax], "q"
        inc     eax
        inc     ebx
    fen_castle4:
    cmp     ebx, 0
    jne     fen_castle5
        mov     BYTE[fen+eax], "-"
        inc eax
    fen_castle5:
    mov     DWORD[fen+eax], " - 0"
    mov     WORD[fen+eax], ' 0'
    mov     BYTE[fen+eax+6], 0

    ; saves fen to file
    lea     esi, [fen_file]
    push    mode_w
    push    esi
    call    fopen
    add     esp, 8
    lea     ebx, [fen]
    push    eax
    push    90
    push    1
    push    ebx
    call    fwrite
    add     esp, 16

    mov     esp, ebp
    pop     ebp
    ret
; void log_moves
log_moves:
    push    ebp
    mov     ebp, esp

    sub     esp, 4

    mov     eax, DWORD[round]
    mov     ebx, eax
    dec     ebx
    shl     ebx, 4

    cmp     BYTE[playerTurn], 0
    je      log_turn
        cmp     eax, 9
        jg      log_10
            mov     BYTE[pgn+ebx], ' ' 
            mov     BYTE[pgn+ebx+1], al
            add     BYTE[pgn+ebx+1], 48
            jmp     log_10_end
        log_10:
            cdq
            mov     ecx, 10
            div     ecx
            mov     BYTE[pgn+ebx], al
            mov     BYTE[pgn+ebx+1], dl
            add     BYTE[pgn+ebx], 48
            add     BYTE[pgn+ebx+1], 48
        log_10_end:
        mov     BYTE[pgn+ebx+2], ' '
        add     ebx, 3
        jmp     log_turn_end
    log_turn:
    add     ebx, 8
    mov     BYTE[pgn+ebx], ' ' 
    mov     BYTE[pgn+ebx+1], "|"
    add     ebx, 2
    inc     BYTE[round]

    log_turn_end:
    push    ebx 
    call    move_to_text
    add     esp, 4
    mov     ecx, eax
    cdq
    mov     esi, 8
    div     esi
    
    top_log:
    cmp     edx, 8
    je      end_log
        mov     BYTE[pgn+ecx], ' '
        inc     edx
        inc     ecx
    jmp     top_log
    end_log:

    ;lea     esi, [fen_file]
    ;push    mode_w
    ;push    esi
    ;call    fopen
    ;add     esp, 8

    ;lea     ebx, [pgn]
    ;mov     DWORD[ebp-4], eax
    ;push    eax
    ;push    300
    ;push    1
    ;push    ebx
    ;call    fwrite
    ;add     esp, 16
        
    ;push    DWORD[ebp-4]    
    ;call    fclose
    ;add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

; int move_to_text(int pgn_pos)
move_to_text:
    push    ebp
    mov     ebp, esp

    ; check castling

    mov     eax, DWORD[ebp+8]
    cmp     BYTE[currChar], 'p'
    je      convPawn
    cmp     BYTE[currChar], 'P'
    je      convPawn
        mov     bl, BYTE[currChar]
        cmp     bl, "h"
        jne     pgn_h1
            mov     bl, "N"
        pgn_h1:
        cmp     bl, "H"
        jne     pgn_h2
            mov     bl, "N" 
        pgn_h2:
        cmp     bl, 96
        jle     pgn_swap
            sub     bl, 32
        pgn_swap:
        mov     BYTE[pgn+eax], bl
        inc     eax
    convPawn:

    ; do interior stuff (capture, same file and spot, check)
    cmp     BYTE[prevChar], '-'
    je      convCapture
        cmp     BYTE[currChar], 'p'
        je      convCapP
        cmp     BYTE[currChar], 'P'
        je      convCapP
            mov     BYTE[pgn+eax], 'x'
            inc     eax
            jmp     convCapture
        convCapP:
            mov     bl, BYTE[moves]
            mov     BYTE[pgn+eax], bl
            mov     BYTE[pgn+eax+1], 'x'
            add     eax, 2
    convCapture:     
    ; do other interior stuff (move on same file)
    
    ; who is doing the moving
    mov     bx, WORD[moves+2]
    mov     BYTE[pgn+eax], bl
    mov     BYTE[pgn+eax+1], bh 
    add     eax, 2

    ; do inCheck
    cmp     BYTE[inCheck], 1
    je      convCheck
    cmp     BYTE[inCheck+1], 1
    je      convCheck    
        jmp     convCheckEnd
    convCheck:
        mov     BYTE[pgn+eax], '+'
        inc     eax
    convCheckEnd:

    mov     esp, ebp
    pop     ebp  
    ret
    
; vim:ft=nasm
