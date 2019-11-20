;               ADRESSES

ACELERO         EQU     FFEBh
IO_READ         EQU     FFFFh
IO_WRITE        EQU     FFFEh
IO_STATUS       EQU     FFFDh
IO_CTRL         EQU     FFFCh
IO_COLOR        EQU     FFFBh
                
                ORIG    1000h
RESULT_X        TAB     100
RESULT_VX       TAB     100
                ORIG    0000h
                
DIVISAO         WORD    0001H ; 1/255
RESSALTO        WORD    0
CONT_X          WORD    0
CONT_VX         WORD    0
SPI_INI         EQU     7fffh
ANGULO          WORD    45
GRAV            EQU     09CCh
V_INI           WORD    0100h
POSICAO_INI     WORD    0100H
TEMPO           WORD    0000H
INTERVALO_TEMPO WORD    0100H
TIME_LIMIT      WORD    F000h
TAB_SIN         STR     0000h,0004h,0008h,000dh,0011h,0016h,001ah,001fh,0023h,0028h,002ch,0030h,0035h,0039h,003dh,0042h,0046h,004ah,004fh,0053h,0057h,005bh,005fh,0064h,0068h,006ch,0070h,0074h,0078h,007ch,007fh,0083h,0087h,008bh,008fh,0092h,0096h,009ah,009dh,00a1h,00a4h,00a7h,00abh,00aeh,00b1h,00b5h,00b8h,00bbh,00beh,00c1h,00c4h,00c6h,00c9h,00cch,00cfh,00d1h,00d4h,00d6h,00d9h,00dbh,00ddh,00dfh,00e2h,00e4h,00e6h,00e8h,00e9h,00ebh,00edh,00eeh,00f0h,00f2h,00f3h,00f4h,00f6h,00f7h,00f8h,00f9h,00fah,00fbh,00fch,00fch,00fdh,00feh,00feh,00ffh,00ffh,00ffh,00ffh,00ffh,0100h


                ORIG    0000h
                MVI     R1,'*'
                MVI     R2,81
                JAL     TEXT_WINDOW
                MVI     R1,0000000101001111b
                JAL     TEXT_CURSOR
                MVI     R1,'*'
                MVI     R2,81
                JAL     TEXT_WINDOW
                MVI     R1,0000000100000001b
                JAL     TEXT_CURSOR
                MVI     R1,'o'
                MVI     R2, 1
                JAL     TEXT_WINDOW
                MVI     R6,SPI_INI
                MVI     R4,TEMPO 
                LOAD    R1,M[R4]
                
;TESTE: Funcao que corre o programa no intervalo de tempo determinado
;Argumentos:---
;Return:----
;Efeitos: Funcao Recursiva que corre o programa
TESTE:          MVI     R5,TIME_LIMIT
                LOAD    R2,M[R5]
                CMP     R2,R1
                BR.NN    FIM                ;Para intervalos de tempo arbitrarios

                MVI     R5,INTERVALO_TEMPO
                LOAD    R2,M[R5]
                ADD     R1,R1,R2
                STOR    M[R4],R1

                STOR    M[R6],R1
                DEC     R6
                STOR    M[R6],R4
                DEC     R6
                
                JAL     .main
                
                INC     R6
                LOAD    R4,M[R6]
                INC     R6
                LOAD    R1,M[R6]
                BR      TESTE

.main:          STOR    M[R6],R7
                DEC     R6
                MVI     R4,POSICAO_INI
                LOAD    R1,M[R4]
                MVI     R5,V_INI
                LOAD    R2,M[R5]
                JAL     POSICAOX
                JAL     ADD_TO_WINDOW
                MVI     R4,POSICAO_INI
                STOR    M[R4],R3
                MVI     R1,RESULT_X
                MVI     R5,CONT_X
                LOAD    R2,M[R5]
                JAL     .addToMem
                STOR    M[R5],R2
                MVI     R4,ANGULO
                LOAD    R1,M[R4]
                JAL     ACELEROMETRO
                JAL     ACELERACAOX
                MVI     R4,V_INI
                LOAD    R1,M[R4]
                MOV     R2,R3
                JAL     VELOCIDADEX
                MVI     R5,V_INI
                STOR    M[R5],R3
                MVI     R1,RESULT_VX
                MVI     R5,CONT_VX
                LOAD    R2,M[R5]
                JAL     .addToMem
                STOR    M[R5],R2
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7
                
;.addToMem: Adiciona na memoria os valores de posicao ou velocidade obtidos
;Argumentos: R1(Tabela correspondente) R2(Contador Correspondente)
;Return:----
;Efeitos: Incrementa o contador de posicao da tabela e coloca o valor 
;        da posicao/velocidade na memoria
.addToMem:      ADD     R1,R1,R2
                STOR    M[R1],R3
                INC     R2
                JMP     R7

FIM:            BR      FIM

;PosicaoX: Calcula a posicao atual do corpo
;Argumentos: R1(posicao_inicial) e R2(velocidade_inicial)
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
                JAL     ACELEROMETRO
                JAL     ACELERACAOX
                MVI     R4,INTERVALO_TEMPO
                LOAD    R1,M[R4]
                MOV     R2,R3
                JAL     PRODUTO
                MVI     R4,INTERVALO_TEMPO
                LOAD    R1,M[R4]
                MOV     R2,R3
                JAL     PRODUTO
                SHR     R3        ;(aceleracao)(tempo)^2/2
                INC     R6
                LOAD    R1,M[R6] ;Vai buscar a v_inicial a stack
                JAL     .getV_Inicial
                ADD     R3,R3,R1
                INC     R6
                LOAD    R1,M[R6] ;Vai buscar a posicao_inicial a stack
                ADD     R3,R3,R1
                MVI     R1,4F00h
                CMP     R3,R1
                JAL.P    .p_ressalto
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7

.p_ressalto:    MVI     R2,RESSALTO
                MVI     R1,1
                STOR    M[R2],R1
.loop_ressalto: MVI     R1,4E00h
                CMP     R3,R1
                BR.N    .retn_ressalto
                SUB     R3,R3,R1
                BR      .loop_ressalto
.retn_ressalto: SUB     R3,R1,R3
                JMP     R7

;getV_Inicial: Calcula v_inicial*tempo da equacao de posicao
;Argumentos: R1(Velocidade Inicial)
;Return: R1(Distancia percorrida)
;Efeito:-----
.getV_Inicial:  STOR    M[R6],R7
                DEC     R6
                STOR    M[R6],R3
                DEC     R6
                STOR    M[R6],R4
                DEC     R6
                STOR    M[R6],R2
                DEC     R6
                MVI     R4, INTERVALO_TEMPO
                LOAD    R2,M[R4]
                JAL     PRODUTO
                MOV     R1,R3
                INC     R6
                LOAD    R2,M[R6]
                INC     R6
                LOAD    R4,M[R6]
                INC     R6
                LOAD    R3,M[R6]
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7
                
;ACELERACAOX: Calcula a aceleracao do corpo
;Argumentos: R1(Angulo em graus) e R2 (Aceleracao gravitica)
;Return: R3 (Aceleracao do corpo)
;Efeito: -----
ACELERACAOX:    MVI     R4,TAB_SIN
                ADD     R4,R4,R1
                LOAD    R1,M[R4]
                STOR    M[R6],R7
                DEC     R6
                JAL     PRODUTO
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7


;VELOCIDADEX: Calcula a velocidade atual do corpo
;Agumentos: R1(Velocidade-inicial) e R2(aceleracao do corpo)
;Return: R3(Velocidade atual)
;Efeitos: -----
VELOCIDADEX:    STOR    M[R6],R7
                DEC     R6
                STOR    M[R6],R1 ;Push velocidade inicial
                DEC     R6
                MVI     R4,INTERVALO_TEMPO
                LOAD    R1,M[R4]
                JAL     PRODUTO
                INC     R6
                LOAD    R1,M[R6] ;Pop velocidade inicial
                JAL     .SUB_V
                MVI     R5,RESSALTO
                LOAD    R1,M[R5]
                MVI     R2,1
                CMP     R1,R2
                JAL.Z   .v_ressalto
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7

.SUB_V:         MVI     R5,RESSALTO
                LOAD    R2,M[R5]
                MVI     R4,2
                CMP     R2,R4
                BR.NZ   .ADD_V
                NEG     R1
                SUB     R3,R3,R1
                JMP     R7

.ADD_V:         ADD     R3,R3,R1
                JMP     R7
                
.v_ressalto:    NEG     R3
                MVI     R5,RESSALTO
                MVI     R2,2
                STOR    M[R5],R2
                JMP     R7
                
ACELEROMETRO:   STOR    M[R6],R1
                DEC     R6
                STOR    M[R6],R7
                DEC     R6
                MVI     R4,ACELERO
                LOAD    R2,M[R4]
                MVI     R5,GRAV
                LOAD    R1,M[R5]
                JAL     PRODUTO; a = x/255 * g
                MOV     R1,R3
                MVI     R2,DIVISAO
                JAL     PRODUTO
                MOV     R2,R3
                INC     R6
                LOAD    R7,M[R6]
                INC     R6
                LOAD    R1,M[R6]
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

                
                
;----------------------------------------------------------------
;TEXT_WINDOW: Escreve na janela de texto
;Argumentos: R1 (caracter a escrever), R2(Numero de caracteres a escrever)
;Retorno: -----
;Efeitos: Janela de texto


TEXT_WINDOW:    MVI     R4,IO_WRITE
                STOR    M[R4],R1
                DEC     R2
                CMP     R2,R0
                BR.NZ   TEXT_WINDOW
                JMP     R7
;-----------------------------------------------------------------------------
;TEXT_CURSOR: Coloca o cursor na posicao pretendida
;Argumentos; R1(Posicao do cursor)
;Retorno: ---------------
;Efeitos: Cursor Janela de Texto

TEXT_CURSOR:    MVI     R4,IO_CTRL
                STOR    M[R4],R1
                JMP     R7

;--------------------------------------------------------------------------
;ADD_TO_WINDOW: Atualiza a posicao da bola na janela de texto
;Argumentos: R1(Posicao em virgula fixa)
;Retorno: --------------
;Efeitos: Janela de Texto

ADD_TO_WINDOW:  STOR    M[R6],R7
                DEC     R6
                STOR    M[R6],R4
                DEC     R6
                STOR    M[R6],R3
                DEC     R6
                STOR    M[R6],R2
                DEC     R6
                
                MVI     R2,FF00h
                AND     R3,R3,R2
                JAL     .fixedpoint
                

.atualiza:      STOR    M[R6],R3
                DEC     R6
                MVI     R4,POSICAO_INI
                LOAD    R3,M[R4]
                JAL     .fixedpoint
                MOV     R1,R3
                INC     R6
                LOAD    R3,M[R6]
                
                MVI     R2,0000000100000000b
                ADD     R1,R2,R1
                JAL     TEXT_CURSOR
                MVI     R1,' '
                MVI     R2,1
                JAL     TEXT_WINDOW
                

                
.return:        MVI     R4,IO_CTRL
                MVI     R2,0000000100000000b
                ADD     R3,R2,R3
                STOR    M[R4],R3
                MVI     R1,'o'
                MVI     R2,1
                JAL     TEXT_WINDOW
                INC     R6
                LOAD    R2,M[R6]
                INC     R6
                LOAD    R3,M[R6]
                INC     R6
                LOAD    R4,M[R6]
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7
                
.fixedpoint:    MVI     R2,8
.loop:          CMP     R2,R0
                JMP.Z   R7
                DEC     R2
                SHR     R3
                BR      .loop
