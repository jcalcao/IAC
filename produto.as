                ORIG    0000h

                MVI     R1,00B5h
                MVI     R2,0A00h
                JAL     PRODUTO
FIM:            BR      FIM


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
                BR.NO   .Loop
                STC
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