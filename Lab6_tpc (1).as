IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
IO_CTRL         EQU     FFFCh
IO_COLOR        EQU     FFFBh


LCD_WRITE       EQU     FFF5h
LCD_STATUS      EQU     FFF4h

SP_INIT         EQU     7000h
                
                ORIG    0000h
LCD_DIGITS      TAB     2
LCD_OPERATORS   TAB     2
LCD_RESULT      TAB     1

                ORIG    0000h
                MVI     R6,SP_INIT
AGAIN:          JAL     RESET_LCD
                MOV     R3,R0
                
WAIT_KEY:       MVI     R1,IO_STATUS
                LOAD    R1,M[R1]
                CMP     R1,R0
                BR.Z    WAIT_KEY

NEW_KEY:        MVI     R2,IO_READ
                LOAD    R1,M[R2]
                MVI     R4,LCD_DIGITS
                ADD     R4,R4,R3
                LOAD    R2,M[R4]
                CMP     R2,R0
                BR.Z    DIGITS
                CMP     R3,R0
                BR.Z    ADD_SUB
                MVI     R2,'='
                CMP     R1,R2
                BR.NZ   DIGITS
                MVI     R4,LCD_DIGITS
                ADD     R4,R4,R3
                LOAD    R2,M[R4]
                CMP     R2,R0
                BR.Z    WAIT_KEY
                MVI     R4,LCD_OPERATORS
                ADD     R4,R4,R3
                STOR    M[R4],R1
                JAL     OPERATION
                JAL     UPDATE_LCD
                BR      AGAIN

OPERATION:      DEC     R6
                STOR    M[R6],R7
                DEC     R6
                STOR    M[R6],R3
                MOV     R3,R0
                MVI     R4,LCD_OPERATORS
                LOAD    R1,M[R4]
                MVI     R2,'+'
                CMP     R1,R2
                JAL.Z   .ADD
                MVI     R2,'-'
                CMP     R1,R2
                JAL.Z   .SUBB
                MVI     R4,LCD_RESULT
                STOR    M[R4],R3
                LOAD    R3,M[R6]
                INC     R6
                LOAD    R7,M[R6]
                INC     R6
                JMP     R7

.ADD_SUB:       
                
                LOAD    R1,M[R4]
                SUB     R1,R1,R2
                INC     R4
                LOAD    R3,M[R4]
                SUB     R3,R3,R2
                MVI     R2,'+'
                CMP     R1,R2
                BR.Z    .ADD
                MVI     R2,'-'
                BR.Z    .SUBB
                

.ADD:           DEC     R6
                STOR    M[R6],R7
                MVI     R2,'0'
                MVI     R4,LCD_DIGITS
                LOAD    R1,M[R4]
                INC     R4
                LOAD    R3,M[R4]
                ADD     R3,R3,R1
                SUB     R3,R3,R2
                LOAD    R7,M[R6]
                INC     R6
                JMP     R7

.SUBB:          DEC     R6
                STOR    M[R6],R7
                MVI     R2,'0'
                MVI     R4,LCD_DIGITS
                LOAD    R1,M[R4]
                INC     R4
                LOAD    R3,M[R4]
                SUB     R3,R3,R1
                SUB     R3,R3,R2
                LOAD    R7,M[R6]
                INC     R6
                JMP     R7
                
         

ADD_SUB:        MVI     R2,'-'
                CMP     R2,R1
                BR.Z    .RETURN
                MVI     R2,'+'
                CMP     R2,R1
                BR.Z    .RETURN
                BR      DIGITS

.RETURN:        MVI     R4,LCD_OPERATORS
                STOR    M[R4],R1
                JAL     UPDATE_LCD
                INC     R3
                JMP      WAIT_KEY
                
DIGITS:         MVI     R2,'0'
                CMP     R1,R2
                JMP.N    WAIT_KEY
                MVI     R2,'9'
                CMP     R1,R2
                JMP.P    WAIT_KEY
                MVI     R4,LCD_DIGITS
                ADD     R4,R4,R3
                STOR    M[R4],R1
                JAL     UPDATE_LCD
                JMP     WAIT_KEY

UPDATE_LCD:     DEC     R6
                STOR    M[R6],R4
                DEC     R6
                STOR    M[R6],R5
                DEC     R6
                STOR    M[R6],R3
                
                ; LIGA O LCD, LIMPA-O E COLOCA O CURSOR NA PRIMEIRA POSIÃ‡ÃƒO
                MVI     R3,8020h
                MVI     R2,LCD_STATUS
                STOR    M[R2],R3
                
                MVI     R5,LCD_WRITE
                MOV     R3,R0
                
.LOOP:          MVI     R4,LCD_DIGITS
                ADD     R4,R4,R3
                LOAD    R2,M[R4]
                CMP     R2,R0
                BR.Z    .RETURN
                STOR    M[R5],R2
                MVI     R4,LCD_OPERATORS
                ADD     R4,R4,R3
                LOAD    R2,M[R4]
                CMP     R2,R0
                BR.Z    .RETURN
                STOR    M[R5],R2
                ; IF THERE ARE MORE DIGITS, GO FOR NEXT LOOP
                INC     R3
                MVI     R2,1
                CMP     R3,R2
                BR.Z   .LOOP
                
                MVI     R4,LCD_RESULT
                LOAD    R2,M[R4]
                CMP     R2,R0
                BR.Z    .RETURN
                MVI     R1,10
                CMP     R2,R1
                BR.N    .STOR
                SUB     R2,R2,R1
.STOR:          STOR    M[R5],R2


.RETURN:        LOAD    R3,M[R6]
                INC     R6
                LOAD    R5,M[R6]
                INC     R6
                LOAD    R4,M[R6]
                INC     R6
                JMP     R7

RESET_LCD:      MVI     R1,LCD_DIGITS
                MVI     R2,LCD_OPERATORS
                MVI     R3,2
.LOOP:          STOR    M[R1],R0
                STOR    M[R2],R0
                INC     R1
                INC     R2
                DEC     R3
                BR.NZ   .LOOP
                MVI     R1,LCD_RESULT
                STOR    M[R1],R0
                JMP     R7