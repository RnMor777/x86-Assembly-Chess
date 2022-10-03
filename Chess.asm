%define BOARD_FILE   'media/board.txt'
%define INTRO_FILE   'media/intro.txt'
%define STRUC_FILE   'media/instructions.txt'
%define FEN_FILE     'saves/saves.fen'
%define INIT_FILE    'media/.init'
%define WEIGHT_FILE  'media/.weights'
%define HEIGHT       15
%define WIDTH        73
%define TOPVERT      4  
%define TOPHORZ      20
%define ENDVERT      12
%define ENDHORZ      36 
%define ENDHORZ2     37

segment .data
    board_file          db  BOARD_FILE, 0
    intro_file          db  INTRO_FILE, 0
    struc_file          db  STRUC_FILE, 0
    init_file           db  INIT_FILE, 0
    fen_file            db  FEN_FILE, 0
    weight_file         db  WEIGHT_FILE, 0
    mode_r              db  "r", 0
    mode_w              db  "w", 0
    raw_mode_on_cmd     db  "stty raw -echo", 0
    raw_mode_off_cmd    db  "stty -raw echo", 0
    initSys             db  "stty -echo -icanon", 0 
    initMouse      db  "echo '",0x1b,"[?1003h",0x1b,"[?1015h",0x1b,"[?1006h'",0x1b,"[?25l",0
    resSys              db  "stty echo icanon", 0 
    resMouse       db  "echo '",0x1b,"[?1003l",0x1b,"[?1015l",0x1b,"[?1006l'",0x1b,"[?25h",0
    clear_screen_cmd    db  "clear", 0
    color_normal        db  0x1b, "[0;24m", 0
    color_square1       db  0x1b, "[104m", 0, 0
    color_square2       db  0x1b, "[44m", 0, 0, 0
    color_edge          db  0x1b, "[100m", 0, 0
    color_move          db  0x1b, "[42m", 0
    color_white         db  0x1b, "[97m", 0, 0, 0
    color_black         db  0x1b, "[30m", 0
    color_hover         db  0x1b, "[44;4m", 0

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
    UNICSPACE           dw  __utf32__(" "), 0, 0
    CORNDOWN            dw  __utf32__("┬"), 0, 0
    copysymbol          dw  __utf32__("©"), 0, 0
    frmt_unic           db  "%ls", 0
    frmt_reg            db  "%s", 0
    newline             db  10, 0
    frmt_locale         db  "", 0
    frmt_delim          db  ";", 0
    frmt_Mm             db  "Mm", 0
    frmt_space          db  " ", 0
    frmt_spacesave      db  "%36s", 0
    frmt_spacecheck     db  "%42s", 0
    frmt_spacemate      db  "%46s", 0
    frmt_pgn            db  " %s", 0
    frmt_int            db  "%2d", 0
    frmt_regint         db  "%d", 0
    frmt_print          db  "Enter a move: ", 0
    frmt_print2         db  "Enter a destination: ", 0
    frmt_bcheck         db  "White in Check", 10, 13, 0
    frmt_wcheck         db  "Black in Check", 10, 13, 0
    frmt_turn           db  "WhiteBlack"
    frmt_saved          db  "Saved",0
    frmt_mate           db  "Checkmate - Game Over!", 10, 13, 0
    frmt_again          db  "Play again? (y/n): ", 0
    frmt_capture1       db  " Captured by white: ", 0
    frmt_capture2       db  " Captured by black: ", 0
    frmt_promote        db  "Enter a promotion Bishop(b), Rook(r), Knight(n), or Queen (q): ", 0
    frmt_intro          db  "Enter an option: ", 0
    frmt_cont           db  "---- Right Click or z to continue ----", 0
    memjumparr          db  3,0,0,0,0,0,0,0,0,5,0,0,2,0,0,4,1
    pieceWeights        dd  300,0,0,0,0,0,0,0,0,9000,0,0,300,0,100,900,500
    knightarr           dd  -1,-2,1,-2,2,-1,2,1,-1,2,1,2,-2,1,-2,-1
    depth               dd  3

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
    xyposCur    resd    1
    round       resd    1
    sStruct     resd    1
    captureB    resb    5
    captureW    resb    5
    playerTurn  resb    1
    inCheck     resb    2
    fen         resb    90
    inGame      resb    1
    didMove     resb    1
    castleInf   resb    1
    enPasTarget resb    1
    halfMove    resb    1
    pawnEval    resd    64
    rookEval    resd    64
    knightEval  resd    64
    bishEval    resd    64
    queenEval   resd    64
    kingEval    resd    64

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
    extern  fclose
    extern  fgetc
    extern  fscanf
    extern  setlocale
    extern  malloc
    extern  free
    extern  strtok
    extern  atoi
    extern  fcntl
    extern  usleep

; main()
main:
    enter   0, 0
    pusha
	; ********** CODE STARTS HERE **********

    ; scans in all of the files, sets up unicode, and defaults
    ; prepares the terminal for mouse input
    ; creates the doubly linked list which holds all previous moves
    call    init_intro    	
    call    seed_start
    
    push    frmt_locale
    push    0x6
    call    setlocale
    add     esp, 8
    push    initSys
    call    system
    add     esp, 4
    push    initMouse
    call    system
    add     esp, 4

    ; REMOVE
    ;jmp     game_loop

    ; runs the initial start screen and takes in clicks or keyboard
    ; input to do the selected menu item
    start_intro:
    push    introboard 
    call    render_intro
    add     esp, 4

    call    getUserIn2

    cmp     BYTE[userin], 5
    je      game_loop
    cmp     BYTE[userin], 'p'
    je      game_loop
    cmp     BYTE[userin], 6
    je      struc_loop
    cmp     BYTE[userin], 'i'
    je      struc_loop
    cmp     BYTE[userin], 8
    je      again_loop_end
    cmp     BYTE[userin], "q"
    je      again_loop_end
    jmp     start_intro

    ; runs the instruction screen and waits until q or click to move on
    struc_loop:
    mov     BYTE[userin], 0
    push    strucboard
    call    render_intro
    add     esp, 4
    push    frmt_cont
    call    printf
    add     esp, 4
    topStructWait: 
    call    getUserIn
    cmp     BYTE[userin], 'z'
    jne     topStructWait
    cmp     BYTE[inGame], 1
    je      game_loop
    jmp     start_intro

    ; This is where the main game actually starts
    game_loop:

        ; sets gameStatus and waits on the user to do something
        mov     BYTE[inGame], 1
        mov     BYTE[didMove], 0
        call    render
        call    clearmoves
        ;cmp     DWORD[playerTurn], 1
        ;je      aiTurn
            ;push    userin
            ;push    frmt_reg
            ;call    scanf
            ;add     esp, 8
            call    getUserIn
            jmp     regTurn
        aiTurn:
            call    minimaxRoot
            push    ebx
            push    eax
            push    DWORD[sStruct]
            call    pushBack
            add     esp, 12
            jmp     game_bottom
        regTurn:
    
        ; If the user pressed q then quits
        mov     al, BYTE[userin]
        cmp     al, 'q'
        je      again_loop_end

        ; If the user press i then loads Instruction page
        cmp     al, 'i'
        je      struc_loop

        ; If the user press s then saves the game state
        cmp     al, 's'
        jne      save_func2
            mov     DWORD[errorflag], 0x777
            call    save_fen
            jmp     game_bottom
        save_func2:

        ; If the user pressed u then runs an undo function for the last move
        cmp     al, 'u'
        jne     end_undo
            push    DWORD[sStruct]
            call    popBack
            add     esp, 4
            ;push    DWORD[sStruct]
            ;call    popBack
            ;add     esp, 4
        end_undo:

        ; Converts the entered points into integer values in the array
        ; STEP 1: Get the initial move square
        call    convertpoint
        cmp     eax, 0x420
        je      game_bottom

        ; stores the location of the piece that the user input, if the piece
        ; was just a blank spot then skips, otherwise if processes the turn for the
        ; input piece and sieves off any moves that result in check
        mov     DWORD[xyposCur], eax
        xor     ebx, ebx
        mov     bl, BYTE[pieces+eax]
        cmp     bl, "-"
        je      game_bottom
            push    ebx
            call    procTurns
            add     esp, 4
        call    sieve_check
        call    sieve_castle
        call    calcnumbmoves
        cmp     eax, 0x69
        je      game_bottom

        ; STEP 2: Get the destination square
        game_next:
        call    render
        call    getUserIn
        ;push    userin
        ;push    frmt_reg
        ;call    scanf
        ;add     esp, 8

        ; If the user pressed z then exit out of the piece selection
        cmp     BYTE[userin], 'z'
        je      game_bottom

        ; Convert to integer values and then does the moving/loading
        ; pushBack is used to handle all the moving and saving the move in a node
        call    convertpoint
        cmp     eax, 0x420
        je      game_next
        mov     bl, BYTE[markarr+eax]
        cmp     bl, "+"
        jne     game_next
            push    eax
            push    DWORD[xyposCur]
            push    DWORD[sStruct]
            call    pushBack
            add     esp, 12
        game_bottom:

        ; cleans up the move array and checks for checkmate
        call    clearmoves
        cmp     DWORD[errorflag], 0xAA
        je      again_loop
        jmp     game_loop

    ; when checkmate occurs, the user is prompted to play again or not
    again_loop:
    call    render
    push    frmt_again
    call    printf
    add     esp, 4
    call    getUserIn
    cmp     BYTE[userin], "y"
    je      start_game
    cmp     BYTE[userin], "n"
    je      again_loop_end
    jmp     again_loop
    start_game:
    call    seed_start
    jmp     game_loop

    ; when ever the game is exited or quit, runs these function to clean up the bash
    ; shell and restore normal defaults
    again_loop_end:
    push    resSys
    call    system
    add     esp, 4
    push    resMouse
    call    system
    add     esp, 4

	; *********** CODE ENDS HERE ***********
    popa
    mov     eax, 0
    leave
	ret

; void seed_start()
seed_start:
    push    ebp
    mov     ebp, esp

    sub     esp, 8
    mov     DWORD[ebp-4], 0

    ; opens the file called init in the media folder
    ; this is used to scan in the starting positions into the pieces array
    lea     esi, [init_file]
    lea     edi, [pieces]
    push    mode_r
    push    esi
    call    fopen
    add     esp, 8
    mov     DWORD[ebp-8], eax
    push    eax
    push    64
    push    1
    push    edi
    call    fread
    add     esp, 16
    push    DWORD[ebp-8]
    call    fclose
    add     esp, 4

    ; opens the file called .weights in the media folder
    push    mode_r
    lea     esi, [weight_file]
    push    esi
    call    fopen
    add     esp, 8
    mov     DWORD[ebp-8], eax

    ; this is used to store the ai value weights in their arrays
    weightsLoop:
    mov     eax, DWORD[ebp-4]
    cmp     eax, 320
    je      endWeights
        lea     edi, [pawnEval+eax*4]
        push    edi
        push    frmt_regint
        push    DWORD[ebp-8]
        call    fscanf
        add     esp, 12
    inc     DWORD[ebp-4]
    jmp     weightsLoop
    endWeights:
    push    DWORD[ebp-8]
    call    fclose
    add     esp, 4

    ; initializes all the variables necessary to their starting values
    call    clearmoves
    call    makestack
    mov     DWORD[sStruct], eax
    mov     BYTE[playerTurn], 0
    mov     WORD[inCheck], 0
    mov     DWORD[captureW], 0
    mov     BYTE[captureW+4], 0
    mov     DWORD[captureB], 0
    mov     BYTE[captureB+4], 0
    mov     DWORD[errorflag], 0 
    mov     DWORD[round], 1
    mov     BYTE[inGame], 0
    mov     BYTE[castleInf], 15
    mov     BYTE[halfMove], 0

    mov     esp, ebp
    pop     ebp
    ret

; void render()
render:
    push    ebp
    mov     ebp, esp

    ; clears the command line screen so nothing is left on it
    sub     esp, 12
    push    clear_screen_cmd
    call    system
    add     esp, 4

    ; prints the turn marker by finding the word black or white in frmt_turn and
    ; overwritting the position on the board to be that new word
    xor     eax, eax
    mov     ebx, 5
    mov     al, BYTE[playerTurn]
    mul     ebx
    mov     ebx, DWORD[frmt_turn+eax]
    mov     DWORD[board+95], ebx
    mov     bl, BYTE[frmt_turn+eax+4]
    mov     BYTE[board+99], bl 
    xor     ecx, ecx

    ; goes into a double for loop that traverses the entire board array while printing it
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

                ; sets the color if the square is to be highlighted
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

                ; this converts the character to a number and then points
                ; to an array which redirects to the proper memory address
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
                lea     ebx, [WPAWN+ebx*8]

                ; prints either the char in black or white
                mov     DWORD[ebp-12], ebx
                shr     ecx, 2
                lea     ebx, [color_white+ecx*8]
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

            ; this prints the color of the edge and the character to white
            to_color:
            push    color_edge
            call    printf
            add     esp, 4
            push    color_white
            call    printf
            add     esp, 4

            ; prints the unique unicode character based on an offset from VERT character
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
                mov     ebx, DWORD[ebp-4]
                sub     ebx, 3
                push    ebx
                call    printPGN
                add     esp, 4
                add     DWORD[ebp-8], eax
                jmp     x_loop_start
            endtrack:
            
        ; Default regular character
        push    ebx     
        call    putchar
        add     esp, 4

        ; resets the color to normal
        piece_end:
        push    color_normal
        call    printf
        add     esp, 4
        inc     DWORD[ebp-8]
        jmp     x_loop_start

    ; when the x position is done, print a newline
    x_loop_end:
    push    0x0a
    call    putchar
    add     esp, 4
    inc     DWORD[ebp-4]
    jmp     y_loop_start
    y_loop_end:

    ; prints special messages after words like: checkmate, in check, saved
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

    ; prints all the captured pieces by calling a print captured function
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
    
        ; puts into eax the value of the xy combined position, aka the array offset
        add     eax, DWORD[ebp-4]
        jmp     regEnd

    ; returns 0x420 if the square is not valid
    errSquare:
    mov     eax, 0x420
    regEnd:

    mov     esp, ebp
    pop     ebp
    ret

; void clearmoves()
clearmoves:
    push    ebp
    mov     ebp, esp

    ; loops over the markarr and sets it all to 0, clearing possible moves
    mov     BYTE[selectFlag], 0x0
    xor     ecx, ecx
    startclear:
    cmp     ecx, 64
    jge     endclear
        mov     BYTE[markarr+ecx], ""
        inc     ecx
        jmp     startclear
    endclear:
    mov     esp, ebp
    pop     ebp
    ret

; void processlines(increment x, increment y)
processlines:
    push    ebp
    mov     ebp, esp

    mov     esi, DWORD[ebp+8]
    mov     edi, DWORD[ebp+12]

    ; calculates the square (if possible) at that increment of x and y
    ; calls calc_square to figure this out 
    topprocess:
    push    edi
    push    esi
    push    DWORD[ypos]
    push    DWORD[xpos]
    call    calc_square
    add     esp, 16
    cmp     eax, 0x420
    je      endprocesslines

    ; if the space is open
    cmp     BYTE[pieces+eax], "-"
    je      bottomprocess

    ; if the space can be captured (an opponent's piece)
    xor     ebx, ebx
    mov     bl, BYTE[playerTurn]
    xor     ebx, 1
    shl     ebx, 5
    add     ebx, "A"
    mov     cl, BYTE[pieces+eax]
    sub     cl, bl
    cmp     cl, 0
    jl      endprocesslines
    cmp     cl, 26
    jge     endprocesslines

        mov     BYTE[markarr+eax], "+"
        jmp     endprocesslines

    bottomprocess:
    mov     BYTE[markarr+eax], "+"
    add     esi, DWORD[ebp+8]
    add     edi, DWORD[ebp+12]
    jmp     topprocess
    endprocesslines:

    mov     esp, ebp
    pop     ebp
    ret

; void processknight ()
processknight:
    push    ebp
    mov     ebp, esp

    ; process the move to a possible knight square
    ; a knight square is an L shape, so everything is held in an array
    ; to make it easier to keep track of where to check next
    mov     ebx, 0
    top_kloop:
    cmp     ebx, 16
    jge     end_kloop
        mov     ecx, DWORD[knightarr+4*ebx]
        mov     edx, DWORD[knightarr+4*(ebx+1)]
        push    ecx
        push    edx
        call    processmove
        add     esp, 8
    add     ebx, 2
    jmp     top_kloop
    end_kloop:

    mov     esp, ebp
    pop     ebp
    ret

; void processmove (offset x, offset y)
processmove:
    push    ebp
    mov     ebp, esp
    pusha

    ; checks if it's a valid movement (lands on the board)
    push    DWORD[ebp+12]
    push    DWORD[ebp+8]
    push    DWORD[ypos]
    push    DWORD[xpos]
    call    calc_square
    add     esp, 16
    cmp     eax, 0x420
    je      end_processmove
    cmp     BYTE[pieces+eax], "-"
    je      move_add

    ; compares with enemy pieces
    mov     bl, BYTE[playerTurn]
    xor     ebx, 1
    shl     ebx, 5
    add     ebx, "A"
    mov     cl, BYTE[pieces+eax]
    sub     cl, bl
    cmp     cl, 0
    jl      end_processmove
    cmp     cl, 26
    jge     end_processmove

    ; if it is a valid move to make, then mark it otherwise don't
    move_add:
    mov     BYTE[markarr+eax], "+"
    end_processmove:

    popa
    mov     esp, ebp
    pop     ebp
    ret

; void processrook ()
processrook:
    push    ebp
    mov     ebp, esp

    ; calculates 4 different lines (up, down, left, and right)

    push    -1
    push    0
    call    processlines
    add     esp, 8

    push    1
    push    0
    call    processlines
    add     esp, 8

    push    0
    push    -1
    call    processlines
    add     esp, 8

    push    0
    push    1
    call    processlines
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret

; void processpawn ()
processpawn:
    push    ebp
    mov     ebp, esp

    sub     esp, 8

    ; stores the pawn's target end row, either row 0 or 7
    mov     al, BYTE[playerTurn]
    xor     eax, 1 
    mov     ebx, 7
    lea     ecx, [eax*5]
    sub     ebx, ecx
    add     ebx, 48
    mov     DWORD[ebp-8], ebx
    xor     eax, 1

    ; puts into ebp-4 either 1 or -1, meaning which direction the pawn is to take
    mov     ebx, -1
    cmp     eax, 0
    cmove   eax, ebx    
    mov     DWORD[ebp-4], eax  

    ; outer lop checks -1, 0, 1 offset of x positions
    mov     ecx, -1
    neo_top:
    cmp     ecx, 2
    je      neo_end
        ; checks if move square is a valid position
        push    DWORD[ebp-4]
        push    ecx
        push    DWORD[ypos]
        push    DWORD[xpos]
        call    calc_square
        add     esp, 16
        cmp     eax, 0x420
        je      pawn_bot

        ; checks the square right above (x offset of 0)
        cmp     ecx, 0
        jne     diag_moves
        cmp     BYTE[pieces+eax], '-'
        jne     pawn_bot
            ; checks if moving from starting position
            mov     BYTE[markarr+eax], '+'   
            mov     ebx, DWORD[ebp-8]
            cmp     BYTE[userin+1], bl
            jne     pawn_bot

            ; checks if moving 2 spaces is a valid move
            mov     ebx, DWORD[ebp-4]
            shl     ebx, 1
            push    ebx
            push    0
            push    DWORD[ypos]
            push    DWORD[xpos]
            call    calc_square
            add     esp, 16
            cmp     eax, 0x420
            je      pawn_bot
            cmp     BYTE[pieces+eax], '-'
            jne     pawn_bot
            mov     BYTE[markarr+eax], '+'   
            jmp     pawn_bot

        ; checks diagonal move squares
        diag_moves:
        cmp     BYTE[markarr+eax], '-'
        je      pawn_bot
            ; checks for capturing enpassant on diagonal
            cmp     BYTE[enPasTarget], al
            jne     diag_cap
                mov     BYTE[markarr+eax], "+"
                jmp     pawn_bot

            ; checks for capturing opponent on diagonal
            diag_cap:
            xor     ebx, ebx
            mov     bl, BYTE[playerTurn]
            xor     ebx, 1
            shl     ebx, 5
            add     ebx, "A"
            mov     dl, BYTE[pieces+eax]
            sub     dl, bl
            cmp     dl, 0
            jl      pawn_bot
            cmp     dl, 26
            jge     pawn_bot
                mov     BYTE[markarr+eax], '+'
    pawn_bot:
    inc     ecx
    jmp     neo_top
    neo_end:

    mov     esp, ebp
    pop     ebp
    ret

; void processbishop ()
processbishop:
    push    ebp
    mov     ebp, esp

    ; process 4 move directions on all the diagonals

    push    -1
    push    -1
    call    processlines
    add     esp, 8

    push    -1
    push    1
    call    processlines
    add     esp, 8

    push    1
    push    -1
    call    processlines
    add     esp, 8

    push    1
    push    1
    call    processlines
    add     esp, 8

    mov     esp, ebp
    pop     ebp
    ret

; void processking ()
processking:
    push    ebp
    mov     ebp, esp

    sub     esp, 8

    ; processes the king's move square (a box)
    mov     DWORD[ebp-4], 1
    top_proc_king:
    cmp     DWORD[ebp-4], -2
    je      end_proc_king
        mov     DWORD[ebp-8], 1
        top_inner_proc_king:
        cmp     DWORD[ebp-8], -2
        je      bot_proc_king
            push    DWORD[ebp-4]
            push    DWORD[ebp-8]
            call    processmove
            add     esp, 8
            dec     DWORD[ebp-8]
            jmp     top_inner_proc_king
        bot_proc_king:
        dec     DWORD[ebp-4]
        jmp     top_proc_king
    end_proc_king:

    ; checks for castling, can't if in check
    ; passign through check is done separately later
    xor     eax, eax
    mov     al, BYTE[playerTurn]
    cmp     BYTE[inCheck+eax], 1
    je      endCastle

    ; finds offset to the castleInf bit 
    mov     ebx, eax
    xor     ebx, 1
    mov     ecx, ebx
    imul    ebx, 7
    mov     edx, 8
    lea     ecx, [ecx*2]
    shr     edx, cl

    ; goes to check both queen and king sides for catling openings
    test    BYTE[castleInf], dl
    jz      kingside
        cmp     BYTE[pieces+(ebx*8)+1], "-"
        jne     kingside
        cmp     BYTE[pieces+(ebx*8)+2], "-"
        jne     kingside
        cmp     BYTE[pieces+(ebx*8)+3], "-"
        jne     kingside
            mov     BYTE[markarr+(ebx*8)+2], "+" 

    kingside:
    shr     edx, 1
    test    BYTE[castleInf], dl
    jz      endCastle
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
    xor     eax, eax
    mov     al, BYTE[userin]

    ; Check to see if is a valid letter, stored in xpos
    mov     ebx, eax
    sub     ebx, 97
    cmp     ebx, 0
    jl      failconvert
    cmp     ebx, 7
    jg      failconvert
        mov     DWORD[xpos], ebx

    ; second number entered is moved into al
    mov     al, BYTE[userin+1]
    mov     ebx, eax
    sub     ebx, 49

    ; checks if that is a valid number, stores in ypos
    cmp     ebx, 0
    jl      failconvert
    cmp     ebx, 7
    jg      failconvert
        mov     ecx, 7
        sub     ecx, ebx
        mov     DWORD[ypos], ecx

    ; calculates the square to see if that is a valid square
    push    0
    push    0
    push    DWORD[ypos]
    push    DWORD[xpos]
    call    calc_square
    add     esp, 16
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

    ; loops through the markarr to determine if any possible moves
    ; stores 0x69 as the error flag if that't the case    
    xor     eax, eax
    xor     ecx, ecx

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

    mov     ecx, 0x69
    cmp     eax, 0
    cmove   eax, ecx
    mov     DWORD[errorflag], eax

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
    pusha
    
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
    lea     ebx, [captureB+ebx]
    mov     ecx, DWORD[ebp+12]
    add     BYTE[ebx], cl

    popa
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
            mov		bl, BYTE [esi + eax]

            mov     al, BYTE[userin]
            add     al, '0'
            cmp     al, bl
            jne     intro_x_endif1
                push    frmt_space
                call    printf
                add     esp, 4
                push    color_hover
                call    printf
                add     esp, 4
                jmp     intro_x_bottom
            intro_x_endif1:

            cmp     bl, '1'
            jl      intro_x_endif
            cmp     bl, '5'
            jg      intro_x_endif
                push    color_normal
                call    printf
                add     esp, 4
                push    frmt_space
                call    printf
                add     esp, 4
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
    add     edi, 1095
    inc     DWORD[ebp-12]

    push    DWORD[ebp-4]
    call    fclose
    add     esp, 4

    jmp     top_intro_loop
    end_intro_loop:
    
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
    
    ; stores into ebp-4, ebp-8 the y and x positions of the king
    mov     DWORD[ebp-4], eax
    mov     DWORD[ebp-8], ebx
    mov     esi, DWORD[ebp+8]
    mov     edi, DWORD[ebp+12]

    topprocesscheck:
    ; calculates valid move square of the offset
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
        ; checks condition if the piece is an enemy or not
        xor     ebx, ebx
        mov     ebx, "z"
        sub     ebx, DWORD[ebp+16]
        sub     bl, BYTE[pieces+eax]
        cmp     bl, 26
        jg      endprocesscheck
        cmp     bl, 0
        jl      endprocesscheck

        mov     ebx, DWORD[ebp+8]
        add     ebx, DWORD[ebp+12]
        xor     ecx, ecx

        ; if the piece was a queen
        mov     cl, "q"
        sub     ecx, DWORD[ebp+16]
        cmp     BYTE[pieces+eax], cl
        je      needcheck

        ; if the piece moving on a row (i.e. a rook)
        cmp     ebx, 1
        je      rookCheck
        cmp     ebx, -1
        je      rookCheck

        ; otherwise the piece will be a bishop 
        mov     cl, "b"
        sub     ecx, DWORD[ebp+16]
        cmp     BYTE[pieces+eax],cl
        je      needcheck
        jmp     endprocesscheck

        rookCheck:
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
        cmp     bl, "a"
        jge     white_check
            mov     BYTE[inCheck+1], 1
            jmp     endnext
        white_check:
            mov     BYTE[inCheck], 1
    endnext:

    mov     esp, ebp
    pop     ebp
    ret

; void bwcalc_check(int b_or_w)
bwcalc_check:
    push    ebp
    mov     ebp, esp

    ; ebp-4: loopvar 1, runs lines
    ; ebp-8: loopvar 2, runs lines
    ; ebp-12: stores the offset in pieces array of the king
    sub     esp, 12

    ; finds the location of either B or W king
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

    ; process lines to pieces from the king move spot
    mov     DWORD[ebp-4], 1
    check_loop_top:
    cmp     DWORD[ebp-4], -2
    je      check_loop_end
        mov     DWORD[ebp-8], 1
        check_loop_inner:
        cmp     DWORD[ebp-8], -2
        je      check_loop_bot
            ; process lines of check (Rook, Bishop, Queen, etc.)
            push    DWORD[ebp-12]
            push    DWORD[ebp+8]
            push    DWORD[ebp-8]
            push    DWORD[ebp-4]
            call    processlinescheck
            add     esp, 16
    
            ; if in check eax will be 0x800
            ; stores that value into the inCheck value 
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
    neg     edx

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

    mov     ebx, "n"
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
    ;xor     dl, 1
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
        ;xor     dl, 1
        shl     edx, 5

        push    edx
        call    bwcalc_check
        add     esp, 4

        ; see if check is still true after the movement
        xor     edx, edx
        mov     dl, BYTE[playerTurn]
        ;xor     dl, 1
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

    mov     al, BYTE[playerTurn]
    shl     eax, 5
    add     eax, "A"

    mov     ebx, 15
    add     ebx, eax
    cmp     ebx, DWORD[ebp+8]
    jne     proc_turn1
        call    processpawn
        jmp     proc_turn_end
    proc_turn1:
    
    mov     ebx, 17
    add     ebx, eax
    cmp     ebx, DWORD[ebp+8]
    jne     proc_turn2
        call    processrook
        jmp     proc_turn_end
    proc_turn2:

    mov     ebx, 1
    add     ebx, eax
    cmp     ebx, DWORD[ebp+8]
    jne     proc_turn3
        call    processbishop
        jmp     proc_turn_end
    proc_turn3:

    mov     ebx, 13
    add     ebx,eax
    cmp     ebx, DWORD[ebp+8]
    jne     proc_turn4
        call    processknight
        jmp     proc_turn_end
    proc_turn4:

    mov     ebx, 16
    add     ebx, eax
    cmp     DWORD[ebp+8], ebx
    jne     proc_turn5
        call    processrook
        call    processbishop
        jmp     proc_turn_end
    proc_turn5:

    mov     ebx, 10
    add     ebx, eax
    cmp     DWORD[ebp+8], ebx
    jne      proc_turn_end
        call    processking
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

        ; checks condition if the piece is an enemy or not
        xor     ebx, ebx
        mov     ebx, "z"
        mov     eax, DWORD[ebp+8]
        xor     eax, 32
        sub     ebx, eax
        sub     bl, BYTE[pieces+ecx]
        cmp     bl, 26
        jg      bot_mate_loop
        cmp     bl, 0
        jl      bot_mate_loop

            ; process the turn for that char
            mov     al, BYTE[pieces+ecx]
            push    eax
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

    ; retrieves the piece at the current location 
    ; converts eax to be be a positive number no matter what
    mov     ebx, DWORD[xyposCur]
    xor     eax, eax
    mov     al, BYTE[pieces+ebx]
    sub     eax, 91
    cdq
    xor     eax, edx
    sub     eax, edx

    ; compares with 16 which would indicate the move was a king
    ; sieves off the further move square so the king can't move through check
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

; void save_fen()
save_fen: 
    push    ebp
    mov     ebp, esp
    
    sub     esp, 8

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
        mov     BYTE[fen+eax], dl
        inc     eax
    bot_fen:
    inc     ecx
    jmp     top_fen
    end_fen:

    ; stores player turn in fen
    mov     ebx, ' w  '
    mov     ecx, ' b  '
    cmp     BYTE[playerTurn], 1
    cmove   ebx, ecx
    mov     DWORD[fen+eax], ebx
    add     eax, 3

    test    BYTE[castleInf], 1
    jz      fenCastleN1
        mov     BYTE[fen+eax], "K"
        inc     eax
    fenCastleN1:
    test    BYTE[castleInf], 2
    jz      fenCastleN2
        mov     BYTE[fen+eax], "Q"
        inc     eax
    fenCastleN2:
    test    BYTE[castleInf], 4
    jz      fenCastleN3
        mov     BYTE[fen+eax], "k"
        inc     eax
    fenCastleN3:
    test    BYTE[castleInf], 8
    jz      fenCastleN4
        mov     BYTE[fen+eax], "q"
        inc     eax
    fenCastleN4:
    test    BYTE[castleInf], 15
    jnz     fenCastleN5
        mov     BYTE[fen+eax], "-"
        inc     eax
    fenCastleN5:

    mov     BYTE[fen+eax], ' '
    inc     eax
    mov     ecx, eax
    mov     ebx, 8
    mov     al, BYTE[enPasTarget]
    cmp     eax, 0
    je      fenNoPass
        cdq
        div     ebx
        sub     ebx, eax
        add     ebx, "0"
        mov     BYTE[fen+ecx], dl
        add     BYTE[fen+ecx], "a"
        mov     BYTE[fen+ecx+1], bl
        add     ecx, 2
        jmp     fenEndPass
    fenNoPass:
        mov     BYTE[fen+ecx], '-'
        inc     ecx
    fenEndPass:
    mov     BYTE[fen+ecx], ' '
    inc     ecx

    mov     al, BYTE[halfMove]
    mov     ebx, 10
    cdq
    div     ebx
    cmp     eax, 0
    je      fenHalfMove
        add     al, 48
        mov     BYTE[fen+ecx], al
        inc     ecx
    fenHalfMove:
    add     dl, 48
    mov     BYTE[fen+ecx], dl
    mov     BYTE[fen+ecx+1], ' '
    add     ecx, 2

    mov     al, BYTE[round]
    mov     ebx, 10
    cdq
    div     ebx
    cmp     eax, 0
    je      fenRound
        add     al, 48
        mov     BYTE[fen+ecx], al
        inc     ecx
    fenRound:
    add     dl, 48
    mov     BYTE[fen+ecx], dl
    inc     ecx
    mov     DWORD[ebp-4], ecx

    ; saves fen to file
    lea     esi, [fen_file]
    push    mode_w
    push    esi
    call    fopen
    add     esp, 8
    mov     DWORD[ebp-8], eax
    lea     ebx, [fen]
    push    eax
    push    DWORD[ebp-4]
    push    1
    push    ebx
    call    fwrite
    add     esp, 16
    push    DWORD[ebp-8]
    call    fclose
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

; struct stackPointer *makestack()
makestack: 
    push    ebp
    mov     ebp, esp
    
    push    12
    call    malloc
    add     esp, 4
    mov     DWORD[eax], 0
    mov     DWORD[eax+4], 0
    mov     DWORD[eax+8], 0

    mov     esp, ebp
    pop     ebp
    ret

; struct snode *makenode()
makenode: 
    push    ebp
    mov     ebp, esp

    push    25
    call    malloc
    add     esp, 4

    mov     DWORD[eax], 0
    mov     DWORD[eax+4], 0
    mov     DWORD[eax+17], 0x20202020
    mov     DWORD[eax+21], 0x00202020
    
    mov     esp, ebp
    pop     ebp
    ret

; void pushBack (struct Stack *S, int currPos, int newPos)
pushBack: 
    push    ebp
    mov     ebp, esp

    sub     esp, 4

    ; inserts a new node at the end
    call    makenode
    mov     DWORD[ebp-4], eax
    
    mov     ebx, DWORD[ebp+8]
    mov     ecx, DWORD[ebx+8]
    cmp     ecx, 0
    jne     insBackElse
        mov     DWORD[ebx], eax
        mov     DWORD[ebx+4], eax
        jmp     insBackEnd
    insBackElse: 
        mov     ecx, DWORD[ebp+8]
        mov     ecx, DWORD[ecx+4]
        mov     DWORD[ecx], eax
        mov     ebx, DWORD[ebx+4]
        mov     DWORD[eax+4], ebx
        mov     ebx, DWORD[ebp+8]
        mov     DWORD[ebx+4], eax
    insBackEnd:
    mov     ebx, DWORD[ebp+8]
    inc     DWORD[ebx+8]

    ; increases the current round
    mov     ebx, DWORD[ebx+8]
    shr     ebx, 1
    inc     ebx
    mov     DWORD[round], ebx

    ; esi - *node
    ; edi - currPos
    ; ebx - newPos
    ; ch - currChar, cl - newChar
    mov     esi, eax
    mov     edi, DWORD[ebp+12]
    mov     ebx, DWORD[ebp+16]
    mov     ch, BYTE[pieces+edi] 
    mov     cl, BYTE[pieces+ebx]
    mov     BYTE[esi+8], 0
    mov     BYTE[esi+9], 0
    mov     BYTE[esi+10], 0
    mov     dh, BYTE[castleInf]
    mov     BYTE[esi+11], dh
    mov     edx, edi
    mov     BYTE[esi+12], dl
    mov     BYTE[esi+13], bl
    mov     BYTE[esi+14], ch
    mov     BYTE[esi+15], cl
    mov     al, BYTE[halfMove]
    mov     BYTE[esi+16], al
    inc     BYTE[halfMove]

    ; moves the pieces on the board
    mov     BYTE[pieces+edi], '-'
    mov     BYTE[pieces+ebx], ch

    ; Does the castling
    xor     eax, eax
    mov     al, ch
    sub     eax, 91
    mov     edx, eax
    neg     eax
    cmovl   eax, edx
    cmp     al, 16
    jne     endMoveCastle
    mov     eax, ebx
    sub     eax, edi
    cmp     eax, -2
    je      castleQueen
    cmp     eax, 2
    je      castleKing
    jmp     endMoveCastle
        castleQueen:
        mov     al, BYTE[pieces+ebx-2]
        mov     BYTE[pieces+ebx-2], "-"
        mov     BYTE[pieces+ebx+1], al
        mov     BYTE[esi+10], 1
        mov     BYTE[esi+9], al
        jmp     endMoveCastle
        castleKing:
        mov     al, BYTE[pieces+ebx+1]
        mov     BYTE[pieces+ebx+1], "-"
        mov     BYTE[pieces+ebx-1], al
        mov     BYTE[esi+10], 2
        mov     BYTE[esi+9], al
    endMoveCastle:

    ; updates castling information
    xor     eax, eax
    mov     al, BYTE[castleInf]
    mov     edx, 12
    cmp     ch, "K"
    cmove   eax, edx
    and     al, BYTE[castleInf]
    mov     BYTE[castleInf], al

    mov     edx, 3
    cmp     ch, "k"
    cmove   eax, edx
    and     al, BYTE[castleInf]
    mov     BYTE[castleInf], al

    mov     edx, 7
    cmp     BYTE[pieces], "r" 
    cmovne  eax, edx
    and     al, BYTE[castleInf]
    mov     BYTE[castleInf], al

    mov     edx, 11
    cmp     BYTE[pieces+7], "r" 
    cmovne  eax, edx
    and     al, BYTE[castleInf]
    mov     BYTE[castleInf], al
    
    mov     edx, 13
    cmp     BYTE[pieces+56], "R" 
    cmovne  eax, edx
    and     al, BYTE[castleInf]
    mov     BYTE[castleInf], al

    mov     edx, 14
    cmp     BYTE[pieces+63], "R" 
    cmovne  eax, edx
    and     al, BYTE[castleInf]
    mov     BYTE[castleInf], al

    ; Executes the EnPassant capturing on the board
    mov     eax, 1
    xor     edx, edx
    cmp     ch, "P"
    cmove   eax, edx
    cmp     ch, "p"
    cmove   eax, edx
    cmp     eax, 0
    jne     endPawnMoving
    cmp     BYTE[enPasTarget], 0
    je      tryEnPassant
    mov     al, BYTE[enPasTarget]
    cmp     bl, al
    jne     tryEnPassant
        mov     eax, ebx
        sub     eax, edi
        mov     edx, eax
        add     edx, 16
        cmp     eax, 0
        cmovl   eax, edx
        sub     eax, 8
        add     eax, edi
        mov     BYTE[esi+9], al
        mov     dl, BYTE[pieces+eax]  
        mov     BYTE[pieces+eax], '-'
        push    1
        push    edx 
        call    fill_capture
        add     esp, 8
        jmp     endPawnMoving
    tryEnPassant:
        mov     eax, ebx
        sub     eax, edi
        mov     edx, eax
        neg     edx
        cmp     eax, 0
        cmovl   eax, edx
        cmp     eax, 16
        jne     tryPromoting
            mov     eax, ebx
            sub     eax, edi
            sar     eax, 1
            add     eax, edi
            mov     BYTE[esi+8], al
            jmp     endPawnMoving
    tryPromoting:
        mov     eax, ebx
        mov     dl, 56
        div     dl
        cmp     ah, 8
        jge     endPawnMoving
            promPawnLoop:
            call    render
            push    frmt_promote
            call    printf
            add     esp, 4
            call    getUserIn
            
            mov     bl, BYTE[userin]
            cmp     bl, "r"
            je      promote
            cmp     bl, "n"
            je      promote
            cmp     bl, "q"
            je      promote
            cmp     bl, "b"
            je      promote
            jmp     promPawnLoop

            promote:
            mov     esi, DWORD[ebp-4]
            xor     eax, eax
            mov     al, BYTE[esi+13]
            mov     cl, BYTE[playerTurn]
            xor     ecx, 1
            shl     ecx, 5
            sub     bl, cl
            mov     BYTE[pieces+eax], bl
    endPawnMoving:
    mov     al, BYTE[esi+8]
    mov     BYTE[enPasTarget], al

    xor     eax, eax
    mov     al, BYTE[esi+15]

    mov     bl, BYTE[esi+14]
    cmp     bl, "p"
    je      zeroHalfMove
    cmp     bl, "P"
    je      zeroHalfMove

    cmp     al, '-'
    je      skipHalfMove
        zeroHalfMove:
        mov     BYTE[halfMove], 0
    skipHalfMove:

    ; Keeps track of captured pieces
    push    1
    push    eax
    call    fill_capture
    add     esp, 8

    mov     BYTE[didMove], 1
    xor     BYTE[playerTurn], 1

    ; Sees if the king for either side is in check
    ; Runs twice to calculate for both side 0 - white, 32 - black
    push    0
    call    bwcalc_check
    add     esp, 4
    push    32
    call    bwcalc_check
    add     esp, 4

    ; If the king is in check, then proceed to process checkmate if possible
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

    ; Makes PGN
    push    DWORD[ebp-4]
    call    makePGN
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret

; void popBack (struct Stack *S)
popBack: 
    push    ebp
    mov     ebp, esp

    mov     eax, DWORD[ebp+8]
    cmp     DWORD[eax+8], 0
    je      skipUndo

    ; ebx contains move node
    ; size--
    dec     DWORD[eax+8]
    mov     ebx, DWORD[eax+4]
    
    ; check if size is 0
    cmp     DWORD[eax+8], 0
    je      popEmpty
        mov     ecx, DWORD[ebx+4]
        ; back -> update to prevNode
        mov     DWORD[eax+4], ecx
        ; prevNode -> update next to 0
        mov     DWORD[ecx], 0
        jmp     popUndo
    popEmpty:
        ; front -> set to 0 if len(stack)=0
        mov     DWORD[eax], 0
        mov     DWORD[eax+4], 0
    popUndo:

    ; restores old game state
    xor     BYTE[playerTurn], 1
    mov     al, BYTE[ebx+11]
    mov     BYTE[castleInf], al
    mov     al, BYTE[ebx+16]
    mov     BYTE[halfMove], al

    mov     BYTE[enPasTarget], 0
    cmp     DWORD[ebx+4], 0
    je      skipUndoPass
        mov     eax, DWORD[ebx+4]
        mov     al, BYTE[eax+8]
        mov     BYTE[enPasTarget], al
    skipUndoPass:

    mov     eax, DWORD[round]
    mov     ecx, eax
    dec     ecx
    cmp     BYTE[playerTurn], 1
    cmove   eax, ecx
    mov     DWORD[round], eax

    ; undoes the move
    xor     eax, eax
    mov     al, BYTE[ebx+12]
    mov     cl, BYTE[ebx+14]
    mov     BYTE[pieces+eax], cl
    mov     al, BYTE[ebx+13]
    mov     cl, BYTE[ebx+15]
    mov     BYTE[pieces+eax], cl

    ; undoes the castle move
    cmp     BYTE[ebx+10], 0
    je      undoCastleEnd
        xor     edx, edx
        mov     eax, 1
        mov     ecx, -2
        cmp     BYTE[ebx+10], 1
        cmove   eax, ecx
        mov     ecx, eax
        or      ecx, 1
        mov     dl, BYTE[ebx+12]
        add     ecx, edx
        mov     BYTE[pieces+ecx], '-'
        mov     dl, BYTE[ebx+13]
        add     eax, edx
        mov     cl, BYTE[ebx+9]
        mov     BYTE[pieces+eax], cl
        mov     al, cl
        jmp     botUndo
    undoCastleEnd:

    cmp     BYTE[ebx+9], 0
    je      botUndo
        xor     eax, eax
        mov     al, BYTE[ebx+14]
        sub     eax, 96
        neg     eax
        add     eax, 96
        mov     cl, BYTE[ebx+9]
        mov     BYTE[pieces+ecx], al
        jmp     botUndo2
    botUndo:
    xor     eax, eax
    mov     al, BYTE[ebx+15]
    botUndo2:
    push    -1
    push    eax
    call    fill_capture
    add     esp, 8 

    push    ebx
    call    free
    add     esp, 4
    skipUndo:

    mov     esp, ebp
    pop     ebp
    ret

; void makePGN (struct snode *node)
makePGN:
    push    ebp
    mov     ebp, esp

    ; esi - node pointer
    ; edi - pgn offset
    sub     esp, 20
    mov     esi, DWORD[ebp+8]
    mov     edi, 17

    ; creates [ebp-4] storing uppercase letter which is the moving piece
    xor     eax, eax
    mov     ebx, 32
    cdq
    mov     al, BYTE[esi+14]
    sub     al, "A"
    div     ebx
    mov     ecx, edx
    add     cl, "A"
    mov     DWORD[ebp-4], ecx

    ; creates [ebp-20] storing initial move file (e.g a)
    mov     al, BYTE[esi+12]
    mov     ebx, 8
    cdq
    div     ebx
    add     ebx, "0"
    add     edx, "a"
    mov     bh, dl
    mov     DWORD[ebp-20], edx

    ; creates [ebp-8] storing move destination (e.g. e4)
    mov     al, BYTE[esi+13]
    mov     ebx, 8
    cdq
    div     ebx
    sub     ebx, eax
    add     ebx, "0"
    add     edx, "a"
    mov     bh, dl
    mov     DWORD[ebp-8], ebx

    ; checks if the move was castling for O-O or O-O-O
    cmp     BYTE[esi+10], 0
    je      notPGNCastle
        mov     BYTE[esi+edi], "O" 
        mov     BYTE[esi+edi+1], "-"
        mov     BYTE[esi+edi+2], "O" 
        add     edi, 3
        cmp     BYTE[esi+10], 1
        jne     PGNbot
            mov     BYTE[esi+edi], "-"
            mov     BYTE[esi+edi+1], "O" 
            add     edi, 2
            jmp     PGNbot
    notPGNCastle:

    ; checks if the move was a pawn (skips over regular move)
    cmp     cl, "P"
    je      PGNcap

    ; stores in PGN the piece letter moved
    mov     BYTE[esi+edi], cl
    inc     edi

    ; calls procTurns to check movement from new location
    ; this verifies if another piece in same file or another
    ; piece in different file can move to the same spot
    mov     DWORD[ebp-12], esi
    mov     DWORD[ebp-16], edi
    xor     BYTE[playerTurn], 1
    call    clearmoves
    mov     eax, DWORD[ebp-4]
    mov     bl, BYTE[playerTurn]
    shl     ebx, 5
    add     eax, ebx
    push    eax
    call    procTurns
    add     esp, 4
    mov     esi, DWORD[ebp-12]
    mov     edi, DWORD[ebp-16]
    xor     BYTE[playerTurn], 1

    ; need to fix to be the starting column not the ending column
    ; puts into cx the file (e.g. abcdefgh)
    mov     eax, 64
    sub     eax, DWORD[xpos]
    mov     ebx, 8
    cdq
    div     ebx
    mov     ecx, edx
    mov     dl, BYTE[esi+14]

    ; if another piece can move there too (same file)
    topPGNLoop1:
    cmp     ecx, 64
    jge     endPGNLoop1
        cmp     BYTE[markarr+ecx], "+" 
        jne     botPGNLoop1
        cmp     BYTE[pieces+ecx], dl
        jne     botPGNLoop1
            mov     ebx, DWORD[ebp-20]
            mov     BYTE[esi+edi], bh
            inc     edi
            jmp     PGNcap
    botPGNLoop1:
    add     ecx, 8
    jmp     topPGNLoop1
    endPGNLoop1:

    ; if another piece can move there too (not same file)
    xor     ecx, ecx
    topPGNLoop2:
    cmp     ecx, 64
    jge     endPGNLoop2
        cmp     BYTE[markarr+ecx], "+" 
        jne     botPGNLoop2
        cmp     BYTE[pieces+ecx], dl
        jne     botPGNLoop2
            mov     ebx, DWORD[ebp-20]
            mov     BYTE[esi+edi], bl
            inc     edi
            jmp     PGNcap
    botPGNLoop2:
    inc     ecx
    jmp     topPGNLoop2
    endPGNLoop2:

    ; if resulted in capturing another piece, put an x (includes enPassant cap)
    PGNcap:
    cmp     BYTE[esi+9], 0
    jne     pawnPGNcap
    cmp     BYTE[esi+15], '-'
    je      notPGNCap
        pawnPGNcap:
        mov     ecx, DWORD[ebp-4]
        cmp     cl, "P"
        jne     nopawnPGNcap
            mov     al, BYTE[esi+12]
            mov     ebx, 8
            cdq
            div     ebx
            add     edx, "a"
            mov     BYTE[esi+edi], dl
            inc     edi
        nopawnPGNcap:
        mov     BYTE[esi+edi], 'x'
        inc     edi
    notPGNCap:

    ; adds the destination move square to the pgn
    mov     ecx, DWORD[ebp-8]
    mov     BYTE[esi+edi], ch
    mov     BYTE[esi+edi+1], cl
    add     edi, 2
    
    ; if promoting a pawn (adds the =)
    xor     eax, eax
    mov     al, BYTE[esi+13]
    mov     bl, BYTE[pieces+eax]
    mov     al, BYTE[esi+14]
    cmp     al, bl
    je      PGNbot
        mov     BYTE[esi+edi], "="
        mov     BYTE[esi+edi+1], bl
        add     edi, 2
    PGNbot:

    ; adds + for check and # for checkmate to the pgn
    mov     eax, 0
    mov     ebx, "+"
    mov     ecx, "#"
    cmp     BYTE[inCheck], 1
    cmove   eax, ebx
    cmp     BYTE[inCheck], 1
    cmove   eax, ebx
    cmp     DWORD[errorflag], 0xAA
    cmove   eax, ecx
    cmp     eax, 0
    je      noCheckPGN
        mov     BYTE[esi+edi], al
        inc     edi
    noCheckPGN:

    ; cleans up moves just in case anything weird got done
    call    clearmoves

    mov     esp, ebp
    pop     ebp
    ret

; void printPGN (int lineNumb) 
printPGN:
    push    ebp
    mov     ebp, esp

    sub     esp, 8

    mov     ebx, DWORD[sStruct]
    mov     ebx, DWORD[ebx]
    mov     ecx, DWORD[round]
    dec     ecx
    cmp     DWORD[ebp+8], ecx
    jg      replaceW
    jmp     keepW
        replaceW:
        push    " "
        call    putchar
        add     esp, 4
        mov     eax, 1
        jmp     skipSecondPGN
    keepW:
    
    ; does scrolling, strips off the starting x amount of lines
    add     cl, BYTE[playerTurn]
    xor     edx, edx
    topScroll:
    cmp     ecx, 10
    jle     skipScroll
        mov     ebx, DWORD[ebx]
        mov     ebx, DWORD[ebx]
        dec     ecx
        inc     edx
        jmp     topScroll
    skipScroll:

    ; breaks off the lines before; gets the current line of objects
    mov     ecx, DWORD[ebp+8]
    topScroll2:
    cmp     ecx, 0
    je      skipScroll2
        mov     ebx, DWORD[ebx]
        mov     ebx, DWORD[ebx]
        dec     ecx
        jmp     topScroll2
    skipScroll2:
    cmp     ebx, 0
    je      replaceW    

    ; displays the proper turn number at the start of the line
    mov     DWORD[ebp-4], ebx
    mov     eax, DWORD[ebp+8]
    inc     eax
    add     eax, edx
    push    eax
    push    frmt_int
    call    printf
    add     esp, 8

    ; prints white's move pgn on that line
    mov     ebx, DWORD[ebp-4]
    add     ebx, 17
    push    ebx
    push    frmt_pgn
    call    printf
    add     esp, 8

    ; prints te vertical line down the middle
    push    VERT
    push    frmt_unic
    call    printf
    add     esp, 8

    ; checks if black has played a move or not
    ; if so it prints that out otherwise won't
    mov     eax, 11
    mov     ebx, DWORD[ebp-4]
    mov     ebx, DWORD[ebx]
    cmp     ebx, 0
    je      skipSecondPGN
        add     ebx, 17
        push    ebx
        push    frmt_reg
        call    printf
        add     esp, 8
        mov     eax, 18
    skipSecondPGN:

    mov     esp, ebp
    pop     ebp
    ret

; char nonblockgetchar ()
nonblockgetchar:
    push    ebp
    mov     ebp, esp

	sub		esp, 8

	push	0
	push	4
	push	0
	call	fcntl
	add		esp, 12
	mov		DWORD [ebp-4], eax

	or		DWORD [ebp-4], 2048
	push	DWORD [ebp-4]
	push	4
	push    0
	call	fcntl
	add		esp, 12

	call	getchar
	mov		DWORD [ebp-8], eax

	xor		DWORD [ebp-4], 2048
	push	DWORD [ebp-4]
	push	4
	push	0
	call	fcntl
	add		esp, 12

	mov		eax, DWORD [ebp-8]

    mov     esp, ebp
    pop     ebp
    ret

; int processgetchar (char* array)
processgetchar:
    push    ebp
    mov     ebp, esp

    sub     esp, 8
    mov     DWORD[ebp-4], 0
    
    topGetCharLoop:
    call    nonblockgetchar
    mov     DWORD[ebp-8], eax  

    xor     eax, eax
    mov     ebx, DWORD[ebp-8]
    cmp     bl, -1
    je      endGetCharLoop

    mov     ecx, DWORD[ebp+8]
    mov     edx, DWORD[ebp-4]
    mov     BYTE[ecx+edx], bl
    inc     DWORD[ebp-4]

    cmp     bl, 'M'
    je      returnGetChar
    cmp     bl, 'a'
    jl      topGetCharLoop
    cmp     bl, 'z'
    jg      topGetCharLoop
    returnGetChar:
        mov     eax, edx
        inc     eax
    endGetCharLoop:
    mov     esp, ebp
    pop     ebp
    ret

; void getUserIn ()
getUserIn:
    push    ebp
    mov     ebp, esp

    sub     esp, 32
    push    17
    call    malloc
    add     esp, 4

    mov     DWORD[ebp-4], eax
    mov     DWORD[ebp-8], eax
    add     DWORD[ebp-8], 3

    topScanLoop:
    push    500
    call    usleep
    add     esp, 4
    push    DWORD[ebp-4]
    call    processgetchar
    add     esp, 4
    mov     DWORD[ebp-16], eax
    cmp     eax, 0
    je      topScanLoop
    cmp     eax, 1
    jne     processMouse
        mov     ebx, DWORD[ebp-4]
        mov     al, BYTE[ebx]
        mov     BYTE[userin], al
        jmp     endScanLoop
    processMouse:
    mov     ebx, DWORD[ebp-4]
    xor     ecx, ecx
    mov     cl, BYTE[ebx+eax-1]
    mov     DWORD[ebp-32], ecx

    push    frmt_delim
    push    DWORD[ebp-8]
    call    strtok
    add     esp, 8
    push    eax
    call    atoi
    add     esp, 4
    mov     DWORD[ebp-20], eax

    push    frmt_delim
    push    0
    call    strtok
    add     esp, 8
    push    eax
    call    atoi
    add     esp, 4
    mov     DWORD[ebp-24], eax

    push    frmt_Mm
    push    0
    call    strtok
    add     esp, 8
    push    eax
    call    atoi
    add     esp, 4
    mov     DWORD[ebp-28], eax

    cmp     DWORD[ebp-20], 2
    jne     contMouseIf
        mov     BYTE[userin], 'z'
        jmp     endScanLoop
    contMouseIf:
    cmp     DWORD[ebp-20], 0
    jne     topScanLoop
    cmp     DWORD[ebp-32], "M"
    jne     topScanLoop
    cmp     DWORD[ebp-24], 21
    jl      topScanLoop
    cmp     DWORD[ebp-24], 36
    jg      topScanLoop
    cmp     DWORD[ebp-28], 5
    jl      topScanLoop
    cmp     DWORD[ebp-28], 12
    jg      topScanLoop
        mov     eax, DWORD[ebp-28]
        sub     eax, 5
        mov     ebx, 8
        sub     ebx, eax
        add     ebx, "0"
        mov     BYTE[userin+1], bl
        mov     eax, DWORD[ebp-24]
        sub     eax, 21
        shr     eax, 1
        add     eax, "a"
        mov     BYTE[userin], al
        mov     BYTE[userin+2], 0
    endScanLoop:
    push    DWORD[ebp-4]
    call    free
    add     esp, 4

    mov     esp, ebp
    pop     ebp
    ret
; void getUserIn2 ()
getUserIn2:
    push    ebp
    mov     ebp, esp

    sub     esp, 32
    push    17
    call    malloc
    add     esp, 4

    mov     DWORD[ebp-4], eax
    mov     DWORD[ebp-8], eax
    add     DWORD[ebp-8], 3

    topScanLoop2:
    push    500
    call    usleep
    add     esp, 4
    mov     BYTE[userin], 0
    push    DWORD[ebp-4]
    call    processgetchar
    add     esp, 4
    mov     DWORD[ebp-16], eax
    cmp     eax, 0
    je      topScanLoop2
    cmp     eax, 1
    jne     processMouse2
        mov     ebx, DWORD[ebp-4]
        mov     al, BYTE[ebx]
        mov     BYTE[userin], al
        jmp     endScanLoop2
    processMouse2:
    mov     ebx, DWORD[ebp-4]
    xor     ecx, ecx
    mov     cl, BYTE[ebx+eax-1]
    mov     DWORD[ebp-32], ecx

    push    frmt_delim
    push    DWORD[ebp-8]
    call    strtok
    add     esp, 8
    push    eax
    call    atoi
    add     esp, 4
    mov     DWORD[ebp-20], eax

    push    frmt_delim
    push    0
    call    strtok
    add     esp, 8
    push    eax
    call    atoi
    add     esp, 4
    mov     DWORD[ebp-24], eax

    push    frmt_Mm
    push    0
    call    strtok
    add     esp, 8
    push    eax
    call    atoi
    add     esp, 4
    mov     DWORD[ebp-28], eax

    cmp     DWORD[ebp-28], 9
    jle     endScanLoop2 
    cmp     DWORD[ebp-28], 14
    jge     endScanLoop2
    cmp     DWORD[ebp-24], 32
    jl      endScanLoop2
    cmp     DWORD[ebp-24], 43
    jg      endScanLoop2

    cmp     DWORD[ebp-20], 0
    je      clickIntro
    cmp     DWORD[ebp-20], 35
    je      hoverIntro
    jmp     topScanLoop2

    clickIntro:
    mov     eax, DWORD[ebp-28]
    sub     eax, 5
    mov     BYTE[userin], al
    jmp     endScanLoop2

    hoverIntro:
    mov     eax, DWORD[ebp-28]
    sub     eax, 9
    mov     BYTE[userin], al

    endScanLoop2:
    push    DWORD[ebp-4]
    call    free
    add     esp, 4

    mov     esp, ebp

    pop     ebp
    ret
; int minimaxRoot ()
minimaxRoot:
    push    ebp
    mov     ebp, esp

    ; ebp-4: int loop_iteration
    ; ebp-8: int bestmove
    ; ebp-12: startBestMove
    ; ebp-16: endBestMove
    ; ebp-80: copy of markArray
    ; ebp-84: tmp spot
    ; ebp-88: innerloop counter
    sub     esp, 88
    mov     DWORD[ebp-4], 0
    mov     DWORD[ebp-8], -9999

    ; clears any extra moved stored 
    call    clearmoves

    ; loops over all possible moves
    top_maxroot_loop:
    cmp     DWORD[ebp-4], 64
    je      end_maxroot_loop
        ; stores xpos, ypos, userin
        mov     eax, DWORD[ebp-16]
        shr     eax, 3
        mov     DWORD[ebp-24], eax
        mov     DWORD[ebp-27], 56
        sub     DWORD[ebp-27], eax
        shl     eax, 3
        sub     eax, DWORD[ebp-16]
        neg     eax
        mov     DWORD[ebp-20], eax
        mov     DWORD[ebp-28], 97
        add     DWORD[ebp-28], eax

        ; checks condition if the piece is playable for itself
        xor     eax, eax
        mov     al, "z"
        mov     ebx, DWORD[playerTurn]
        xor     bl, 1
        shl     ebx, 5
        sub     eax, ebx
        mov     ecx, DWORD[ebp-16]
        sub     al, BYTE[pieces+ecx]
        cmp     al, 26
        jg      bot_minimax_loop
        cmp     al, 0
        jl      bot_minimax_loop

            ; process the turn for that char
            mov     al, BYTE[pieces+ecx]
            push    eax
            call    procTurns
            add     esp, 4

            ; removes moves that cannot be used
            call    sieve_check
            call    sieve_castle

            ; stores the marked moves locally
            cld     
            ;lea     esi, markarr
            lea     edi, [ebp-80]
            mov     ecx, 64
            rep movsb

            ; while loop that goes through all moves in the markarr
            jmp     while_moves

            top_while_move:
                mov     DWORD[ebp-88], 0
                top_for_move:
                mov     ecx, DWORD[ebp-88]
                cmp     BYTE[markarr+ecx], "+"
                jne     bot_for_move
                    ; plays that move by calling pushBack
                    mov     BYTE[ebp-80+ecx], 0
                    mov     DWORD[ebp-84], ecx
                    push    ecx
                    push    DWORD[ebp-4]
                    push    DWORD[sStruct]
                    call    pushBack
                    add     esp, 12

                    ; make a call to minimax with params
                    push    0
                    push    10000
                    push    -10000
                    push    DWORD[depth]
                    call    minimax
                    add     esp, 16

                    ; look at outcome of return value
                    cmp     eax, DWORD[ebp-8]
                    jl      noUpdate
                        mov     DWORD[ebp-8], eax
                        mov     ebx, DWORD[ebp-4]
                        mov     DWORD[ebp-12], ebx
                        mov     ebx, DWORD[ebp-84]
                        mov     DWORD[ebp-16], ebx
                    noUpdate:

                    ; undo the move above
                    push    DWORD[sStruct]
                    call    popBack
                    add     esp, 4

                    jmp     while_moves
        
                bot_for_move:
                inc     DWORD[ebp-88]
                jmp     top_for_move

            while_moves:
            cld     
            ;lea     edi, markarr
            lea     esi, [ebp-80]
            mov     ecx, 64
            rep movsb
            call    calcnumbmoves
            cmp     eax, 0
            jne     top_while_move

    bot_maxroot_loop:
    call    clearmoves
    inc     DWORD[ebp-4]
    jmp     top_maxroot_loop
    end_maxroot_loop: 

    ; clears moves just in case
    call    clearmoves

    mov     eax, DWORD[ebp-12]
    mov     ebx, DWORD[ebp-16]

    mov     esp, ebp
    pop     ebp
    ret

; minimax (depth, alpha, beta, isMaximisingPlayer)
minimax:
    push    ebp
    mov     ebp, esp

    ; ebp-4: bestmove
    ; ebp-12: bit marked array
    ; ebp-16: saved xypos
    ; ebp-20: saved xpos
    ; ebp-24: saved ypos
    ; ebp-28: userin
    ; ebp-32: inner counter  
    ; ebp-96: stored mark array (deprecated)
    sub     esp, 96

    ; returns the -result of evaluateBoard
    cmp     DWORD[ebp+8], 0
    jne     minimax_rec
        call    evaluateBoard
        neg     eax
        jmp     bot_minimax
    minimax_rec: 

    ; stores bestMove 
    mov     eax, 9999
    mov     ebx, -9999
    cmp     DWORD[ebp+20], 0
    cmove   eax, ebx
    mov     DWORD[ebp-4], eax

    ; loops over all possible moves
    mov     DWORD[ebp-16], 0
    top_minimax_loop:
    cmp     DWORD[ebp-16], 64
    je      end_minimax_loop
        ; stores xpos, ypos, userin
        mov     eax, DWORD[ebp-16]
        shr     eax, 3
        mov     DWORD[ebp-24], eax
        mov     DWORD[ebp-27], 56
        sub     DWORD[ebp-27], eax
        shl     eax, 3
        sub     eax, DWORD[ebp-16]
        neg     eax
        mov     DWORD[ebp-20], eax
        mov     DWORD[ebp-28], 97
        add     DWORD[ebp-28], eax

        ; checks condition if the piece is playable for itself
        xor     eax, eax
        mov     al, "z"
        mov     ebx, DWORD[playerTurn]
        xor     bl, 1
        shl     ebx, 5
        sub     eax, ebx
        mov     ecx, DWORD[ebp-16]
        sub     al, BYTE[pieces+ecx]
        cmp     al, 26
        jg      bot_minimax_loop
        cmp     al, 0
        jl      bot_minimax_loop

            ; process the turn for that char, removing non-playable moves
            call    clearmoves
            mov     ecx, DWORD[ebp-16]
            mov     DWORD[xyposCur], ecx
            mov     eax, DWORD[ebp-20]
            mov     DWORD[xpos], eax 
            mov     eax, DWORD[ebp-24]
            mov     DWORD[ypos], eax
            mov     ax, WORD[ebp-28]
            mov     WORD[userin], ax
            mov     bl, BYTE[pieces+ecx]
            push    ebx
            call    procTurns
            add     esp, 4
            call    sieve_check
            call    sieve_castle

            ; stores the marked moves locally
            cld     
            ;lea     esi, markarr
            lea     edi, [ebp-96]
            mov     ecx, 64
            rep movsb

            ; while loop that goes through all moves in markarr
            jmp     mmwhile_moves
            top_mmwhile_move:
            mov     DWORD[ebp-32], 0
            top_mmfor_move:
            mov     ecx, DWORD[ebp-32]
            cmp     BYTE[markarr+ecx], "+"
            jne     bot_mmfor_move
                mov     BYTE[ebp-96+ecx], 0

                ; plays that move by calling pushback
                push    ecx
                push    DWORD[ebp-16]
                push    DWORD[sStruct]
                call    pushBack
                add     esp, 12

                ; make a recursive call to this function
                mov     eax, DWORD[ebp+20]
                xor     eax, 1
                push    eax
                push    DWORD[ebp+16]
                push    DWORD[ebp+12]
                mov     eax, DWORD[ebp+8]
                dec     eax
                push    eax
                call    minimax
                add     esp, 16

                ; update the alpha and beta
                cmp     DWORD[ebp+20], 0
                je      updateAlpha

                ; update bestMove to be the max between function and stored
                mov     ebx, DWORD[ebp-4]
                cmp     ebx, eax
                cmovl   eax, ebx
                mov     DWORD[ebp-4], eax

                ; update the alpha value
                mov     ebx, DWORD[ebp+16]
                cmp     ebx, eax
                cmovl   eax, ebx
                mov     DWORD[ebp+16], eax

                ; call the undo move function
                push    DWORD[sStruct]
                call    popBack
                add     esp, 4

                ; return if condition
                mov     eax, DWORD[ebp+12]
                cmp     DWORD[ebp+16], eax
                jle     end_minimax_loop
                jmp     mmwhile_moves

                updateAlpha:
                ; update bestMove to be the max between function and stored
                mov     ebx, DWORD[ebp-4]
                cmp     ebx, eax
                cmovg   eax, ebx
                mov     DWORD[ebp-4], eax

                ; update the alpha value
                mov     ebx, DWORD[ebp+12]
                cmp     ebx, eax
                cmovg   eax, ebx
                mov     DWORD[ebp+12], eax

                ; call the undo move function
                push    DWORD[sStruct]
                call    popBack
                add     esp, 4

                ; return if condition
                mov     eax, DWORD[ebp+12]
                cmp     DWORD[ebp+16], eax
                jle     end_minimax_loop
                jmp     mmwhile_moves

                bot_mmfor_move:
                inc     DWORD[ebp-32]
                jmp     top_mmfor_move
            mmwhile_moves:
            cld     
            ;lea     edi, markarr
            lea     esi, [ebp-96]
            mov     ecx, 64
            rep movsb
            call    calcnumbmoves
            cmp     eax, 0
            jne     top_mmwhile_move
    bot_minimax_loop:
    call    clearmoves
    inc     DWORD[ebp-16]
    jmp     top_minimax_loop
    end_minimax_loop: 

    call    clearmoves
    mov     eax, DWORD[ebp-4]

    bot_minimax:
    mov     esp, ebp
    pop     ebp
    ret

; int evaluateBoard()
evaluateBoard:
    push    ebp
    mov     ebp, esp
    
    ; ebp-4: counter1
    ; ebp-8: counter2
    ; ebp-12: evaluation
    sub     esp, 12
    mov     DWORD[ebp-4], 0
    mov     DWORD[ebp-8], 0
    mov     DWORD[ebp-12], 0

    topEval1:
    mov     ecx, DWORD[ebp-4]
    cmp     ecx, 8
    je      endEval
        topEval2:
        mov     edx, DWORD[ebp-8]
        cmp     edx, 8
        je      botEval
            ; if the piece is empty
            cmp     BYTE[pieces+8*ecx+edx], '-'
            je      botEval

            ; determine white (+) or black (-)
            xor     eax, eax
            xor     ebx, ebx
            mov     al, 96
            sub     al, BYTE[pieces+8*ecx+edx]
    
            ; store the location of eval in ebx
            mov     esi, 64
            cmp     eax, 0
            cmovl   ebx, esi
            mov     esi, ecx
            add     esi, edx
            mov     edi, esi
            neg     edi
            cmp     eax, 0
            cmovl   esi, edi
            add     ebx, esi

            ; get position in alphabet for pieceWeigt
            mov     al, BYTE[pieces+8*ecx+edx]
            sub     al, 65
            mov     esi, eax
            sub     esi, 32
            cmp     esi, 0
            cmovge  eax, esi
            dec     eax
            
            ; get the pieceWeight at that location
            mov     esi, DWORD[pieceWeights+eax*4]

            ; get the evalBoard at that location
            mov     al, BYTE[memjumparr+eax]
            shl     eax, 6
            add     esi, DWORD[pawnEval+eax+ebx]

            ; update the total
            add     DWORD[ebp-12], esi
    botEval:
    inc     DWORD[ebp-4]
    mov     DWORD[ebp-8], 0
    jmp     topEval1
    endEval:

    ; divide by 10 to get correct value
    mov     eax, DWORD[ebp-12]
    cdq
    mov     ebx, 10
    idiv    ebx

    mov     esp, ebp
    pop     ebp
    ret

; vim:ft=nasm
