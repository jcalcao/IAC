                ORIG    0000h
RESULT          TAB     10
SPI_INI         EQU     8000h
ANGULO          WORD    1
GRAV            EQU     9
V_INI           WORD    0
X               WORD    0
TEMPO           WORD    10
TAB_SIN         STR     0000h,0004h,0008h,000dh,0011h,0016h,001ah,001fh,0023h,0028h,002ch,0030h,0035h,0039h,003dh,0042h,0046h,004ah,004fh,0053h,0057h,005bh,005fh,0064h,0068h,006ch,0070h,0074h,0078h,007ch,007fh,0083h,0087h,008bh,008fh,0092h,0096h,009ah,009dh,00a1h,00a4h,00a7h,00abh,00aeh,00b1h,00b5h,00b8h,00bbh,00beh,00c1h,00c4h,00c6h,00c9h,00cch,00cfh,00d1h,00d4h,00d6h,00d9h,00dbh,00ddh,00dfh,00e2h,00e4h,00e6h,00e8h,00e9h,00ebh,00edh,00eeh,00f0h,00f2h,00f3h,00f4h,00f6h,00f7h,00f8h,00f9h,00fah,00fbh,00fch,00fch,00fdh,00feh,00feh,00ffh,00ffh,00ffh,00ffh,00ffh,0100h


                ORIG    0000h
                MVI     R6,SPI_INI
                MVI     R4,TEMPO
                MVI     R5,RESULT
                LOAD    R1,M[R4]
TESTE:          CMP     R1,R0
                BR.Z    FIM
                STOR    M[R6],R1
                DEC     R6
                STOR    M[R6],R4
                DEC     R6
                STOR    M[R6],R5
                DEC     R6
                MVI     R4,X
                LOAD    R1,M[R4]
                MVI     R5,V_INI
                LOAD    R2,M[R5]
                JAL     POSICAOX
                INC     R6
                LOAD    R5,M[R6]
                INC     R6
                LOAD    R4,M[R6]
                INC     R6
                LOAD    R1,M[R6]
                DEC     R1
                STOR    M[R5],R3
                INC     R5
                BR      TESTE
FIM:            BR      FIM

;PosicaoX: Calcula a posicao atual do corpo
;Argumentos; R1(posicao_inicial) e R2(velocidade_inicial)
;Retorno: R3(posica_atual)
;Efeitos:_____
POSICAOX:       STOR    M[R6],R7
                DEC     R6
                STOR    M[R6],R1
                DEC     R6
                STOR    M[R6],R2
                DEC     R6
                MVI     R4,ANGULO
                LOAD    R1,M[R4]
                MVI     R5,GRAV
                LOAD    R2,M[R5]
                JAL     ACELERACAOX
                INC     R6
                LOAD    R1,M[R6] ;Vai buscar a v_inicial a stack
                MOV     R2,R3
                JAL     VELOCIDADEX
                MOV     R2,R3
                MVI     R4,TEMPO
                LOAD    R1,M[R4]
                JAL     PRODUTO
                SHR     R3
                INC     R6
                LOAD    R1,M[R6] ;Vai buscar a posicao_inicial a stack
                ADD     R3,R1,R3
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7

ACELERACAOX:    MVI     R4,TAB_SIN
                ADD     R4,R4,R1
                LOAD    R1,M[R4]
                STOR    M[R6],R7
                DEC     R6
                JAL     PRODUTO
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7

VELOCIDADEX:    STOR    M[R6],R7
                DEC     R6
                STOR    M[R6],R1
                DEC     R6
                MVI     R4,TEMPO
                LOAD    R1,M[R4]
                JAL     PRODUTO
                INC     R6
                LOAD    R1,M[R6]
                ADD     R3,R3,R1
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7
                                
;
; Rotinas
;

; -----------------------------------------------------
; Produto: Calculo produto de dois valores em virgula fixa (8bits inteiros e 8
;        bits fracionarios)
; Argumentos: R1 e R2
; Retorno: R3
; Efeitos: -


PRODUTO:        MVI     R3, 0
                MVI     R4,0
                CMP     R2, R0
                BR.Z    .Fim
                
.add:           ADD     R3, R3, R1
                BR.NC   .Loop
                ADDC    R4,R4,R0
.Loop:          DEC     R2
                BR.NZ   .add

                MVI     R2,8
.fixedpoint:    CMP     R2,R0
                BR.Z    .Fim
                DEC     R2
                SHR     R3
                SHL     R4
                BR      .fixedpoint
                
.Fim:           ADD     R3,R3,R4
                JMP     R7
