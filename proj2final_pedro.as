TIMER_VALUE     EQU     FFF6h
TIMER_CONTROL   EQU     FFF7h
INT_MASK        EQU     FFFAh

ACELERO         EQU     FFEBh
IO_WRITE        EQU     FFFEh 
IO_CTRL         EQU     FFFCh
                
                ORIG    1000h
RESULT_X        TAB     100
RESULT_VX       TAB     100
               
                ORIG    0000h
                
FLAG_NEG        WORD    0
CONT_X          WORD    0
CONT_VX         WORD    0
SPI_INI         EQU     7fffh
GRAV            EQU     09CCh


GRAVDIV         EQU     0009h    ;grav dividida por 255
VALORTEMPO      EQU     1
V_INI           WORD    0000h
POSICAO_INI     WORD    0100H
INTERVALO_TEMPO WORD    0100H

                ORIG    0000h
                MVI     R2,'*'
                MVI     R3,81
                JAL     TEXT_WRITE
                MVI     R1,0000000101001111b
                MVI     R2,'*'
                MVI     R3,81
                JAL     TEXT_WRITE
                MVI     R1,0000000100000001b
                MVI     R2,'o'
                MVI     R3, 1
                JAL     TEXT_WRITE
                MVI     R6,SPI_INI
                MVI     R1,8000h
                MVI     R2,INT_MASK
                STOR    M[R2],R1
                ENI
                
Loop:           MVI     R1,TIMER_VALUE
                MVI     R2,VALORTEMPO
                STOR    M[R1],R2
                MVI     R1,TIMER_CONTROL
                MVI     R2,1
                STOR    M[R1],R2
                BR      Loop
                
                


Main:           STOR    M[R6],R7
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
                
                JAL     ACELERACAOX
                MVI     R4,INTERVALO_TEMPO
                LOAD    R1,M[R4]
                MOV     R2,R3
                JAL     PRODUTO
                MVI     R4,INTERVALO_TEMPO
                LOAD    R1,M[R4]
                MOV     R2,R3
                JAL     PRODUTO
                SHRA    R3        ;(aceleracao)(tempo)^2/2
                INC     R6
                LOAD    R1,M[R6] ;Vai buscar a v_inicial a stack
                JAL     .getV_Inicial
                ADD     R3,R3,R1
                INC     R6
                LOAD    R1,M[R6] ;Vai buscar a posicao_inicial a stack
                ADD     R3,R3,R1
                JAL.N   .ColisaoLow
                MVI     R1,4E00h
                CMP     R1,R3
                JAL.N   .ColisaoHigh
                
                INC     R6
                LOAD    R7,M[R6]
                JMP     R7

.ColisaoLow:    CMP     R3,R0
                BR.Z    .ColisaoLowZero   ;case 0
                NEG     R3
                BR      .ColisaoLowFim
.ColisaoLowZero:MVI     R3,1
.ColisaoLowFim: JMP     R7

.ColisaoHigh:   SUB     R3,R3,R1
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
;Argumentos:
;Return: R3 (Aceleracao do corpo)
;Efeito: -----
ACELERACAOX:    STOR    M[R6],R7
                DEC     R6
                MVI     R4,ACELERO
                LOAD    R2,M[R4]
                MVI     R1,GRAVDIV    ;0009h
                JAL     PRODUTO;
                INC     R6             ;R3=acelerometro*(grav/255)
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


PRODUTO:        STOR    M[R6],R7
                DEC     R7
                
                CMP     R1,R0
                JAL.N    .negative_flag
                CMP     R2,R0
                JAL.N    .negative_flag
                MVI     R3, 0
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
                MVI     R4,FLAG_NEG
                LOAD    R1,M[R4]
                MVI     R2,1
                CMP     R1,R2
                JAL.Z   .add_nBit
                INC     R7
                LOAD    R7,M[R6]
                JMP     R7

.add_nBit:      MVI     R2,1000000000000000b
                OR      R3,R2,R3
                MVI     R4,FLAG_NEG
                STOR    M[R4],R0
                JMP     R7
                
.negative_flag: MVI     R4,FLAG_NEG
                MVI     R3,1
                STOR    M[R4],R3
                JMP     R7
;----------------------------------------------------------------
;TEXT_WRITE: Escreve na janela de texto
;Argumentos; R1(Posicao do cursor) R2(carater a escrever), R3(nr de carateresa escrever)
;Retorno: ---------------
;Efeitos: Janela de Texto

TEXT_WRITE:     MVI     R4,IO_CTRL
                STOR    M[R4],R1 
.escreve:       MVI     R5,IO_WRITE
                STOR    M[R5],R2
                DEC     R3
                CMP     R3,R0
                BR.NZ   .escreve
                JMP     R7
;----------------------------------------------------------------
                
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
                
                
                MVI     R2,0000000100000000b
                ADD     R1,R2,R1
                MVI     R2,' '
                MVI     R3,1
                JAL     TEXT_WRITE
                INC     R6
                LOAD    R3,M[R6]

                
.return:        MVI     R2,0000000100000000b
                ADD     R1,R2,R3
                MVI     R2,'o'
                MVI     R3,1
                JAL     TEXT_WRITE
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
                SHRA    R3
                BR      .loop

                ORIG    7FF0h
                
                JAL     Main

                RTI