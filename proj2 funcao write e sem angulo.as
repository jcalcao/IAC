;ADRESSES

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
                
RESSALTO        WORD    0
CONT_X          WORD    0
CONT_VX         WORD    0
SPI_INI         EQU     7fffh
GRAV            EQU     09CCh
GRAVDIV         EQU     0009h    ;grav dividida por 255
V_INI           WORD    0000h
POSICAO_INI     WORD    0100H
TEMPO           WORD    0000H
INTERVALO_TEMPO WORD    0A00H
TIME_LIMIT      WORD    FA00h ;250

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
                MVI     R4,TEMPO 
                LOAD    R1,M[R4]
                
;TESTE: Funcao que corre o programa no intervalo de tempo determinado
;Argumentos:---
;Return:----
;Efeitos: Funcao Recursiva que corre o programa
TESTE:          MVI     R5,TIME_LIMIT
                LOAD    R2,M[R5]
                CMP     R2,R1
                BR.N    FIM                ;Para intervalos de tempo arbitrarios

                MVI     R5,INTERVALO_TEMPO   
                LOAD    R2,M[R5]
                ADD     R1,R1,R2
                STOR    M[R4],R1           ;Atualiza TEMPO = TEMPO+INTERVALO_TEMPO

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
ACELERACAOX:   
                STOR    M[R6],R7
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
;TEXT_WRITE: Escreve na janela de texto
;Argumentos; R1(Posicao do cursor) R2(carater a escrever), R3(nr de carateresa escrever)
;Retorno: ---------------
;Efeitos: Janela de Texto

TEXT_WRITE:     MVI      R4,IO_CTRL
                STOR     M[R4],R1 
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
                SHR     R3
                BR      .loop
