%define BOARD_FILE 'media/board.txt'
%define INTRO_FILE 'media/intro.txt'
%define STRUC_FILE 'media/instructions.txt'
%define EXITCHAR 'x'
%define BACKCHAR 'z'
%define UNDOCHAR 'u'
%define HEIGHT   15
%define WIDTH    72 
%define TOPVERT  4  
%define TOPHORZ  25
%define ENDVERT  12
%define ENDHORZ  41 
%define ENDHORZ2 42

segment .data
    board_file          db  BOARD_FILE, 0
    intro_file          db  INTRO_FILE, 0
    struc_file          db  STRUC_FILE, 0
    mode_r              db  "r", 0
    raw_mode_on_cmd     db  "stty raw -echo", 0
    raw_mode_off_cmd    db  "stty -raw echo", 0
    clear_screen_cmd    db  "clear", 0
    color_normal        db  0x1b, "[0m", 0
    color_black         db  0x1b, "[104m", 0
    color_white         db  0x1b, "[44m", 0
    color_edge          db  0x1b, "[100m", 0
    color_move          db  0x1b, "[42m", 0
    color_foreground    db  0x1b, "[30m", 0
    color_foreground2   db  0x1b, "[97m", 0

    WPAWN               dw  __utf32__("♙"), 0, 0
    WROOK               dw  __utf32__("♖"), 0, 0
    WKNIGHT             dw  __utf32__("♘"), 0, 0
    WBISH               dw  __utf32__("♗"), 0, 0
    WQUEEN              dw  __utf32__("♕"), 0, 0
    WKING               dw  __utf32__("♔"), 0, 0
    BPAWN               dw  __utf32__("♟"), 0, 0
    BROOK               dw  __utf32__("♜"), 0, 0
    BKNIGHT             dw  __utf32__("♞"), 0, 0
    BBISH               dw  __utf32__("♝"), 0, 0
    BQUEEN              dw  __utf32__("♛"), 0, 0
    BKING               dw  __utf32__("♚"), 0, 0
    VERT                dw  __utf32__("│"), 0, 0
    HORIZ               dw  __utf32__("─"), 0, 0
    CORNUL              dw  __utf32__("┌"), 0, 0
    CORNUR              dw  __utf32__("┐"), 0, 0
    CORNLL              dw  __utf32__("└"), 0, 0
    CORNLR              dw  __utf32__("┘"), 0, 0
    frmt_unic           db  "%ls", 0
    frmt_reg            db  "%s", 0
    copysymbol          dw  __utf32__("©"), 0, 0
    newline             db  10, 0
    frmt_locale         db  "", 0
    frmt_space          db  " ", 0
    frmt_scan           db  "%c%d", 0
    frmt_space27        db  "%41s", 0
    frmt_space18        db  "%49s", 0
    frmt_print          db  "Enter a move: ", 0
    frmt_print2         db  "Enter a destination: ", 0
    error_moves         db  "No possible moves for piece",10, 13, 0
    frmt_turn_white     db  "White's Turn",10,13,0
    frmt_turn_black     db  "Black's Turn",10,13,0
    frmt_instructions   db  "u - undo, z - back, x - exit",10,10,13,0
    frmt_capture1       db  " Captured by white: ", 0
    frmt_capture2       db  " Captured by black: ", 0
    frmt_promote        db  "Enter a promotion Bishop(B), Rook(R), Knight(K), or Queen (Q): ", 0
    frmt_intro          db  "Enter an option: ", 0
    frmt_cont           db  "---- Press any key to continue ----", 0

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
    tmp         resd    1
    selectFlag  resb    1
    errorflag   resd    1
    playerTurn  resd    1
    prevChar    resb    1
    currChar    resb    1
    xyposCur    resd    1
    xyposLast1  resd    1
    xyposLast2  resd    1
    captureW    resd    5
    captureB    resd    5
    canCastleW  resb    2
    canCastleB  resb    2
    prevCastle  resb    4
    wasCastle   resb    1
    

segment .text
	global  asm_main
    global  render

    extern  system
    extern  putchar
    extern  getchar
    extern  printf
    extern  scanf
    extern  fopen
    extern  fread
    extern  fgetc
    extern  fclose
    extern  fcntl
    extern  setlocale

asm_main:
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

    ; sets up initial game settings and placements
    call    seed_start
    call    clearmoves

    mov     DWORD[playerTurn], 0
    mov     DWORD[xyposLast1], -1
    mov     DWORD[captureW], 0
    mov     DWORD[captureW+4], 0
    mov     DWORD[captureW+8], 0
    mov     DWORD[captureW+16], 0
    mov     DWORD[captureW+20], 0
    mov     DWORD[captureB], 0
    mov     DWORD[captureB+4], 0
    mov     DWORD[captureB+8], 0
    mov     DWORD[captureB+16], 0
    mov     DWORD[captureB+20], 0
    mov     BYTE[canCastleW], 1
    mov     BYTE[canCastleW+1], 1
    mov     BYTE[canCastleB], 1
    mov     BYTE[canCastleB+1], 1
    mov     BYTE[wasCastle], 0

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
    je      game_loop_end

    jmp     start_intro

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
        je      game_loop_end

        ; Just clears the board
        cmp     al, BACKCHAR
        je      game_bottom

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
        jmp     endundocastle
            undocastle1:
            mov     BYTE[pieces], "R"
            mov     BYTE[pieces+4], "K"
            mov     BYTE[pieces+2], ""
            mov     BYTE[pieces+3], ""
            jmp     botundocastle
            undocastle2:
            mov     BYTE[pieces+7], "R"
            mov     BYTE[pieces+4], "K"
            mov     BYTE[pieces+5], ""
            mov     BYTE[pieces+6], ""
            jmp     botundocastle
            undocastle3:
            mov     BYTE[pieces+56], "r"
            mov     BYTE[pieces+60], "k"
            mov     BYTE[pieces+58], ""
            mov     BYTE[pieces+59], ""
            jmp     botundocastle
            undocastle4:
            mov     BYTE[pieces+63], "r"
            mov     BYTE[pieces+60], "k"
            mov     BYTE[pieces+61], ""
            mov     BYTE[pieces+62], ""

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
            xor     DWORD[playerTurn], 1
    
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
        mov     bl, BYTE[pieces+eax]
    
        ; At this point ypos contains the y pos and xpos the x pos. bl/select is the character
        cmp     bl, ""
        je      game_bottom
    
        cmp     DWORD[playerTurn], 1
        je      upper_turn
            ; Lowercase Pawn
            cmp     bl, "p"
            jne     next_type2
                push    "A"
                call    processpawn
                add     esp, 4
                jmp     game_next

            ; Lowercase Rook
            next_type2:
            cmp     bl, "r"
            jne     next_type3
                push    "A"
                call    processrook
                add     esp, 4
                jmp     game_next

            ; Lowercase Bishop
            next_type3:
            cmp     bl, "b"
            jne     next_type4
                push    "A"
                call    processbishop
                add     esp, 4
                jmp     game_next

            ; Lowercase Knight
            next_type4:
            cmp     bl, "h"
            jne     next_type5
                push    "A"
                call    processknight
                add     esp, 4
                jmp     game_next

            ; Lowercase Queen
            next_type5:
            cmp     bl, "q"
            jne     next_type6
                push    "A"
                call    processrook
                add     esp, 4
                push    "A"
                call    processbishop
                add     esp, 4
                jmp     game_next

            ; Lowercase King
            next_type6:
            cmp     bl, "k"
            jne     end_turns
                push    "A"
                call    processking
                add     esp, 4
                jmp     game_next

        upper_turn:
        ; Uppercase Pawn
        cmp     bl, "P"
        jne     alt_type2
            push    "a"
            call    processpawn
            add     esp, 4
            jmp     game_next

        ; Uppercase Rook
        alt_type2:
        cmp     bl, "R"
        jne     alt_type3
            push    "a"
            call    processrook
            add     esp, 4
            jmp     game_next

        ; Uppercase Bishop
        alt_type3:
        cmp     bl, "B"
        jne     alt_type4
            push    "a"
            call    processbishop
            add     esp, 4
            jmp     game_next

        ; Uppercase Knight
        alt_type4:
        cmp     bl, "H"
        jne     alt_type5
            push    "a"
            call    processknight
            add     esp, 4
            jmp     game_next

        ; Uppercase Queen
        alt_type5:
        cmp     bl, "Q"
        jne     alt_type6
            push    "a"
            call    processrook
            add     esp, 4
            push    "a"
            call    processbishop
            add     esp, 4
            jmp     game_next

        ; Uppercase King
        alt_type6:
        cmp     bl, "K"
        jne     end_turns
            push    "a"
            call    processking
            add     esp, 4
            jmp     game_next
        end_turns:
        jmp     game_bottom

        game_next:
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
        mov     ebx, 0
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
            mov     BYTE[pieces+eax], ""

            mov     DWORD[xyposLast1], eax
            mov     DWORD[xyposLast2], ecx
            mov     BYTE[prevChar], bl
            mov     BYTE[currChar], dl

            ; Changes the player turn marker
            xor     DWORD[playerTurn], 1

            ; Calc Check Function

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
                jmp     next_castle6
            next_castle:
            cmp     dl, "K"
            jne     next_castle2
                mov     BYTE[canCastleB], 0
                mov     BYTE[canCastleB+1], 0
                jmp     next_castle6
            next_castle2:
            cmp     eax, 0
            jne     next_castle3
                mov     BYTE[canCastleB], 0
                jmp     next_castle6
            next_castle3:
            cmp     eax, 7
            jne     next_castle4
                mov     BYTE[canCastleB+1], 0
                jmp     next_castle6
            next_castle4:
            cmp     eax, 54
            jne     next_castle5
                mov     BYTE[canCastleW], 0
                jmp     next_castle6
            next_castle5:
            cmp     eax, 63
            jne     next_castle6
                mov     BYTE[canCastleW+1], 0
            next_castle6:

            ; Does the castling
            cmp     dl, "K"
            je      upper_castle
            cmp     dl, "k"
            je      lower_castle
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
                mov     BYTE[pieces+0], ""
                mov     BYTE[wasCastle], 1
                jmp     end_castle_func

                upper_castle_king:
                mov     BYTE[pieces+5], "R"
                mov     BYTE[pieces+7], ""
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
                mov     BYTE[pieces+56], ""
                mov     BYTE[wasCastle], 3
                jmp     end_castle_func

                lower_castle_king:
                mov     BYTE[pieces+61], "r"
                mov     BYTE[pieces+63], ""
                mov     BYTE[wasCastle], 4

            end_castle_func:

            ; Keeps track of captured pieces
            push    1
            push    ebx
            call    fill_capture
            add     esp, 8


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
        call    clearmoves
        jmp     game_loop
    game_loop_end:

	; *********** CODE ENDS HERE ***********
    popa
    mov     eax, 0
    leave
	ret

seed_start:
    push    ebp
    mov     ebp, esp

    mov     BYTE [pieces+0], "R"
    mov     BYTE [pieces+1], "H"
    mov     BYTE [pieces+2], "B"
    mov     BYTE [pieces+3], "Q"
    mov     BYTE [pieces+4], "K"
    mov     BYTE [pieces+5], "B"
    mov     BYTE [pieces+6], "H"
    mov     BYTE [pieces+7], "R"
    mov     BYTE [pieces+8], "P"
    mov     BYTE [pieces+9], "P"
    mov     BYTE [pieces+10], "P"
    mov     BYTE [pieces+11], "P"
    mov     BYTE [pieces+12], "P"
    mov     BYTE [pieces+13], "P"
    mov     BYTE [pieces+14], "P"
    mov     BYTE [pieces+15], "P"
    mov     BYTE [pieces+56], "r"
    mov     BYTE [pieces+57], "h"
    mov     BYTE [pieces+58], "b"
    mov     BYTE [pieces+59], "q"
    mov     BYTE [pieces+60], "k"
    mov     BYTE [pieces+61], "b"
    mov     BYTE [pieces+62], "h"
    mov     BYTE [pieces+63], "r"
    mov     BYTE [pieces+48], "p"
    mov     BYTE [pieces+49], "p"
    mov     BYTE [pieces+50], "p"
    mov     BYTE [pieces+51], "p"
    mov     BYTE [pieces+52], "p"
    mov     BYTE [pieces+53], "p"
    mov     BYTE [pieces+54], "p"
    mov     BYTE [pieces+55], "p"

    mov     esp, ebp
    pop     ebp
    ret

render:
    push    ebp
    mov     ebp, esp

    sub     esp, 8
    push    clear_screen_cmd
    call    system
    add     esp, 4

    mov     DWORD[ebp-4], 0
    push    newline
    call    printf
    add     esp, 4

    ; Prints the player turn indicator
    cmp     DWORD[playerTurn], 1
    je      turnBlack
        push    frmt_turn_white
        push    frmt_space27
        call    printf
        add     esp, 8
        jmp     turn_print_end

    turnBlack:
    push    frmt_turn_black
    push    frmt_space27
    call    printf
    add     esp, 8
    turn_print_end:

    ;cmp     DWORD[errorflag], 0x69
    ;jne     errornext
    ;    push    error_moves
    ;    call    printf
    ;    add     esp, 4
    ;    mov     DWORD[errorflag], 0
    ;errornext:

    call    func_print_captured

    mov     DWORD[ebp-4], 0
    y_loop_start:
    cmp     DWORD[ebp-4], HEIGHT
    je      y_loop_end
        mov     DWORD[ebp-8], 0
        x_loop_start:
        cmp     DWORD[ebp-8], WIDTH
        je      x_loop_end
            print_board:

                ; Colors the board
                cmp     DWORD[ebp-8], TOPHORZ
                jl      endcolor
                cmp     DWORD[ebp-8], ENDHORZ
                jge     endcolor
                cmp     DWORD[ebp-4], TOPVERT
                jl      endcolor
                cmp     DWORD[ebp-4], ENDVERT
                jge     endcolor

                    cmp     BYTE[selectFlag], 0x1
                    jne     color1
                        push    color_move
                        call    printf
                        add     esp, 4                
                        mov     BYTE[selectFlag], 0x0
                        jmp     endcolor

                    color1:
                    mov     ecx, DWORD[ebp-4]
                    sub     ecx, TOPVERT 
                    and     ecx, 0x1
                    shl     ecx, 1
                    mov     edx, DWORD[ebp-8]
                    sub     edx, TOPHORZ
                    and     edx, 0x3
                    add     ecx, edx
                    and     ecx, 0x3

                    cmp     ecx, 2
                    jge     color2
                        push    color_white
                        call    printf 
                        add     esp, 4
                        jmp     endcolor
                    color2:
                        push    color_black
                        call    printf
                        add     esp, 4
                endcolor:

                ; Gets the board character at the location
                mov     eax, [ebp-4]
                mov     ebx, WIDTH
                mul     ebx
                add     eax, [ebp-8]
                mov     ebx, 0
                mov     bl, BYTE[board+eax]

                ; This sets all the special unicode board characters
                cmp     bl, '?'
                jne     notspecial0
                    push    frmt_space
                    call    printf
                    add     esp, 4
                    jmp     print_end3
                notspecial0:
                cmp     bl, '$'
                jne     notspecial1
                    push    color_edge
                    call    printf
                    add     esp, 4
                    push    CORNUL
                    push    frmt_unic
                    jmp     print_end
                notspecial1:
                cmp     bl, '&'
                jne     notspecial2
                    push    color_edge
                    call    printf
                    add     esp, 4
                    push    CORNUR
                    push    frmt_unic
                    jmp     print_end
                notspecial2:
                cmp     bl, '*'
                jne     notspecial3
                    push    color_edge
                    call    printf
                    add     esp, 4
                    push    CORNLL
                    push    frmt_unic
                    jmp     print_end
                notspecial3:
                cmp     bl, '%'
                jne     notspecial4
                    push    color_edge
                    call    printf
                    add     esp, 4
                    push    CORNLR
                    push    frmt_unic
                    jmp     print_end
                notspecial4:
                cmp     bl, '@'
                jne     notspecial5
                    push    color_edge
                    call    printf
                    add     esp, 4
                    push    HORIZ
                    push    frmt_unic
                    jmp     print_end
                notspecial5:
                cmp     bl, '#'
                jne     notspecial6
                    push    color_edge
                    call    printf
                    add     esp, 4
                    push    color_foreground2
                    call    printf
                    add     esp, 4
                    push    VERT
                    push    frmt_unic
                    jmp     print_end
                notspecial6:
                cmp     bl, '^'
                jne     notspecial7
                    push    color_edge
                    call    printf
                    add     esp, 4
                    push    frmt_space
                    push    frmt_reg
                    jmp     print_end 
                notspecial7:

                ; This sets the playing pieces
                cmp     DWORD[ebp-8], TOPHORZ
                jl      endpieces
                cmp     DWORD[ebp-8], ENDHORZ
                jge     endpieces
                cmp     DWORD[ebp-4], TOPVERT
                jl      endpieces
                cmp     DWORD[ebp-4], ENDVERT
                jge     endpieces

                    mov     edx, DWORD[ebp-8]
                    sub     edx, TOPHORZ

                    test    edx, 1
                    jnz     endpieces

                    mov     ecx, DWORD[ebp-4]
                    sub     ecx, TOPVERT
                    shr     edx, 1
                    shl     ecx, 3
                    add     ecx, edx
                    mov     DWORD[tmp], ecx

    
                    cmp     BYTE[markarr+ecx], "+"
                    jne     selectedcolorend
                        push    color_move
                        call    printf
                        add     esp, 4
                        mov     BYTE[selectFlag], 0x1
                    selectedcolorend: 

                    ; prints the chess pieces and proper colors
                    mov     ecx, DWORD[tmp]
                    mov     edx, 0
                    mov     dl, BYTE[pieces+ecx]
                    
                    cmp     edx, 97
                    jge     render_white
                    cmp     edx, 91
                    jge     render_regular
                    cmp     edx, 65
                    jl      render_regular
                        push    edx
                        call    func_print_black_char
                        add     esp, 4
                        jmp     print_end2

                    render_white:
                        push    edx
                        call    func_print_white_char
                        add     esp, 4
                        jmp     print_end2
            
                render_regular:
                endpieces:

                ; Default regular character
                push    ebx     
                call    putchar
                add     esp, 4
                jmp     print_end2
            print_end:
            call    printf
            add     esp, 8
            print_end2:

            cmp     DWORD[ebp-8], ENDHORZ2
            jne     print_end3
                push    color_normal
                call    printf
                add     esp, 4
            print_end3:

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

    push    frmt_instructions
    push    frmt_space18
    call    printf
    add     esp, 8
    
    mov     esp, ebp
    pop     ebp
    ret
; calc_square (pos x, pos y, offset x, offset y)
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
; clearmoves() - clears the possible moves array
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
;processlines(increment x, increment y, opponent marker (A or a))
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
    cmp     BYTE[pieces+eax], ""
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
;processknight (opponent marker (A or a))
processknight:
    push    ebp
    mov     ebp, esp

    push    DWORD[ebp+8]
    push    -2
    push    -1
    call    processmove
    add     esp, 12

    push    DWORD[ebp+8]
    push    -2
    push    1
    call    processmove
    add     esp, 12

    push    DWORD[ebp+8]
    push    -1
    push    2
    call    processmove
    add     esp, 12

    push    DWORD[ebp+8]
    push    1
    push    2
    call    processmove
    add     esp, 12
    
    push    DWORD[ebp+8]
    push    2
    push    -1
    call    processmove
    add     esp, 12

    push    DWORD[ebp+8]
    push    2
    push    1
    call    processmove
    add     esp, 12

    push    DWORD[ebp+8]
    push    1
    push    -2
    call    processmove
    add     esp, 12

    push    DWORD[ebp+8]
    push    -1
    push    -2
    call    processmove
    add     esp, 12

    mov     esp, ebp
    pop     ebp
    ret
;processmove (offset x, offset y, opponent marker (A or a))
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
    cmp     BYTE[pieces+eax], ""
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
;processrook (opponent marker (A or a))
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
;processpawn (opponent marker (A or a))
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
; processpawn2 (offset x, offset y, opponent marker (A or a))
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
    cmp     BYTE[pieces+eax], ""
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
; processbishop (opponent marker (A or a))
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
; processking (opponent marker (A or a))
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
        cmp     BYTE[pieces+57], ""
        jne     wkingside
        cmp     BYTE[pieces+58], ""
        jne     wkingside
        cmp     BYTE[pieces+59], ""
            mov     BYTE[markarr+58], "+"

        wkingside:
        cmp     BYTE[canCastleW+1], 1
        jne     endCastle

        cmp     BYTE[pieces+61], ""
        jne     endCastle
        cmp     BYTE[pieces+62], ""
        jne     endCastle
            mov     BYTE[markarr+62], "+"
        jmp     endCastle
    blackCastle:
        cmp     BYTE[canCastleB], 1
        je      bqueenside
        jmp     bkingside
        
        bqueenside:
        cmp     BYTE[pieces+1], ""
        jne     bkingside
        cmp     BYTE[pieces+2], ""
        jne     bkingside
        cmp     BYTE[pieces+3], ""
        jne     bkingside
            mov     BYTE[markarr+2], "+"

        bkingside:
        cmp     BYTE[canCastleB+1], 1
        jne     endCastle

        cmp     BYTE[pieces+5], ""
        jne     endCastle
        cmp     BYTE[pieces+6], ""
        jne     endCastle
            mov     BYTE[markarr+6], "+"
    endCastle:

    mov     esp, ebp
    pop     ebp
    ret
; convertpoint ()
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
; func_print_black_char (char a)
func_print_black_char:
    push    ebp
    mov     ebp, esp

    push    color_foreground
    call    printf
    add     esp, 4

    cmp     DWORD[ebp+8], "R"
    jne     p_next1
        push    BROOK
        jmp     print_black_end
    p_next1:
    cmp     DWORD[ebp+8], "H"
    jne     p_next2
        push    BKNIGHT
        jmp     print_black_end
    p_next2:
    cmp     DWORD[ebp+8], "B"
    jne     p_next3
        push    BBISH
        jmp     print_black_end
    p_next3:
    cmp     DWORD[ebp+8], "K"
    jne     p_next4
        push    BKING
        jmp     print_black_end
    p_next4:
    cmp     DWORD[ebp+8], "Q"
    jne     p_next5
        push    BQUEEN
        jmp     print_black_end
    p_next5:
    cmp     DWORD[ebp+8], "P"
    jne     print_black_end
        push    BPAWN

    print_black_end:
    push    frmt_unic
    call    printf
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret

; func_print_white_char (char a)
func_print_white_char:
    push    ebp
    mov     ebp, esp

    push    color_foreground2
    call    printf
    add     esp, 4

    cmp     DWORD[ebp+8], "r"
    jne     p_next6
        push    WROOK
        jmp     print_white_end
    p_next6:
    cmp     DWORD[ebp+8], "h"
    jne     p_next7
        push    WKNIGHT
        jmp     print_white_end
    p_next7:
    cmp     DWORD[ebp+8], "b"
    jne     p_next8
        push    WBISH
        jmp     print_white_end
    p_next8:
    cmp     DWORD[ebp+8], "k"
    jne     p_next9
        push    WKING
        jmp     print_white_end
    p_next9:
    cmp     DWORD[ebp+8], "q"
    jne     p_next10
        push    WQUEEN
        jmp     print_white_end
    p_next10:
    cmp     DWORD[ebp+8], "p"
    jne     print_white_end
        push    WPAWN

    print_white_end:
    push    frmt_unic
    call    printf
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret
; func_print_captured ()
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
        mov     ebx, DWORD[captureW+ecx*4]
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
    ;push    frmt_space
    ;call    printf
    ;add     esp, 4
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
        mov     ebx, DWORD[captureB+ecx*4]
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
    ;push    frmt_space
    ;call    printf
    ;add     esp, 4
    jmp     top_captured2
    end_captured2:

    push    13
    push    newline
    call    printf
    add     esp, 8


    mov     esp, ebp
    pop     ebp
    ret

; fill_capture (a)
fill_capture:
    push    ebp
    mov     ebp, esp
    
    mov     eax, DWORD[ebp+12]

    cmp     DWORD[ebp+8], "p"
    jne     fill_1
        add     DWORD[captureB], eax
        jmp     fill_end
    fill_1: 
    cmp     DWORD[ebp+8], "r"
    jne     fill_2
        add     DWORD[captureB+4], eax
        jmp     fill_end
    fill_2:
    cmp     DWORD[ebp+8], "h"
    jne     fill_3
        add     DWORD[captureB+8], eax
        jmp     fill_end
    fill_3:
    cmp     DWORD[ebp+8], "b"
    jne     fill_4
        add     DWORD[captureB+12], eax
        jmp     fill_end
    fill_4:
    cmp     DWORD[ebp+8], "q"
    jne     fill_5
        add     DWORD[captureB+16], eax
        jmp     fill_end
    fill_5:
    cmp     DWORD[ebp+8], "P"
    jne     fill_6
        add     DWORD[captureW], eax
        jmp     fill_end
    fill_6:
    cmp     DWORD[ebp+8], "R"
    jne     fill_7
        add     DWORD[captureW+4], eax
        jmp     fill_end
    fill_7:
    cmp     DWORD[ebp+8], "H"
    jne     fill_8
        add     DWORD[captureW+8], eax
        jmp     fill_end
    fill_8:
    cmp     DWORD[ebp+8], "B"
    jne     fill_9
        add     DWORD[captureW+12], eax
        jmp     fill_end
    fill_9:
    cmp     DWORD[ebp+8], "Q"
    jne     fill_end
        add     DWORD[captureW+16], eax
        jmp     fill_end
    fill_end:
    mov     esp, ebp
    pop     ebp
    ret
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

; vim:ft=nasm
