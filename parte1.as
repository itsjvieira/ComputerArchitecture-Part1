;--------------------------------------;
; IAC 2017/2018 LEIC-A                 ;
; Primeira parte do projeto MASTERMIND ;
;--------------------------------------;

;------------;
; CONSTANTES ;
;------------;
IO                 EQU         FFFEh
NL                 EQU         000Ah
TOPOPILHA          EQU         FDFFh
MASCARA            EQU         8016h
MASC_INTERRUPCOES  EQU         FFFAh
MASC_BOTOES_I1_I6  EQU         0000000001111110b
MASC_BOTAO_IA      EQU         0000010000000000b

;---------------------------;
; DEFINICAO DE INTERRUPCOES ;
;---------------------------;
ORIG        FE01h ; zona das interrupcoes dos botoes i1-i6

INT_1              WORD        BOTAO1
INT_2              WORD        BOTAO2
INT_3              WORD        BOTAO3
INT_4              WORD        BOTAO4
INT_5              WORD        BOTAO5
INT_6              WORD        BOTAO6

ORIG        FE0Ah ; zona da interrupcao do botao iA

INT_A              WORD        BOTAO_IA

;-------;
; DADOS ;
;-------;
ORIG        8000h ; zona de dados

ALEAT_INIC         WORD        3124h
ALEAT              WORD        0000h
CONTA_TENTATIVAS   WORD        0000h
CONTA_CARATERES    WORD        0000h
CONTA_INTRO        WORD        0000h

ORIG        0000h
JMP         INICIO

;-------------------------;
; ROTINAS DE INTERRUPCOES ;
;-------------------------;
; ler tentativa
BOTAO1: INC         M[CONTA_INTRO]
        MOV         R4, '1'
        MOV         M[IO], R4
        ADD         R2, 0001h
        ROL         R2, 4
        RTI

BOTAO2: INC         M[CONTA_INTRO]
        MOV         R4, '2'
        MOV         M[IO], R4
        ADD         R2, 0002h
        ROL         R2, 4
        RTI

BOTAO3: INC         M[CONTA_INTRO]
        MOV         R4, '3'
        MOV         M[IO], R4
        ADD         R2, 0003h
        ROL         R2, 4
        RTI

BOTAO4: INC         M[CONTA_INTRO]
        MOV         R4, '4'
        MOV         M[IO], R4
        ADD         R2, 0004h
        ROL         R2, 4
        RTI

BOTAO5: INC         M[CONTA_INTRO]
        MOV         R4, '5'
        MOV         M[IO], R4
        ADD         R2, 0005h
        ROL         R2, 4
        RTI

BOTAO6: INC         M[CONTA_INTRO]
        MOV         R4, '6'
        MOV         M[IO], R4
        ADD         R2, 0006h
        ROL         R2, 4
        RTI

; alterar valor de r4 para sair do ciclo ESPERA_INICIO
BOTAO_IA: INC         R4
          RTI

;---------------------------------------;
; IMPRIMIR CARATERES NA JANELA DE TEXTO ;
;---------------------------------------;
; imprime para a consola os 'x'
OUT_X: MOV         R4, 'x'
       MOV         M[IO], R4
       RET

; imprime para a consola os 'o'
OUT_O: MOV         R4, 'o'
       MOV         M[IO], R4
       RET

; imprime para a consola os '-'
OUT_HIFEN: MOV         R4, '-'
           MOV         M[IO], R4
           INC         M[CONTA_CARATERES]
           JMP         VAL_HIFENS

;--------------------------------------;
; PROCESSAR SEMELHANCA CHAVE/TENTATIVA ;
;--------------------------------------;
PROC_X1: ADD        R3, 1000h
         INC        M[CONTA_CARATERES]
         CALL       OUT_X
         RET
PROC_X2: ADD        R3, 0100h
         INC        M[CONTA_CARATERES]
         CALL       OUT_X
         RET
PROC_X3: ADD        R3, 0010h
         INC        M[CONTA_CARATERES]
         CALL       OUT_X
         RET
PROC_X4: ADD        R3, 0001h
         INC        M[CONTA_CARATERES]
         CALL       OUT_X
         RET

PROC_O1: ADD        R3, 2000h
         INC        M[CONTA_CARATERES]
         CALL       OUT_O
         JMP        VAL_X2_O1
PROC_O2: ADD        R3, 0200h
         INC        M[CONTA_CARATERES]
         CALL       OUT_O
         JMP        VAL_X3_O1
PROC_O3: ADD        R3, 0020h
         INC        M[CONTA_CARATERES]
         CALL       OUT_O
         JMP        VAL_X4_O1
PROC_O4: ADD        R3, 0002h
         INC        M[CONTA_CARATERES]
         CALL       OUT_O
         JMP        VAL_HIFENS

;------------------------------------;
; VALIDAR SEMELHANCA CHAVE/TENTATIVA ;
;------------------------------------;
; validacao de numeros iguais nas mesmas posicoes
VAL_X: MOV         R5, M[SP+8]
       MOV         R6, M[SP+4]
       CMP         R5, R6
       CALL.Z      PROC_X4
       CMP         R5, R6

       MOV         R5, M[SP+7]
       MOV         R6, M[SP+3]
       CMP         R5, R6
       CALL.Z      PROC_X3
       CMP         R5, R6

       MOV         R5, M[SP+6]
       MOV         R6, M[SP+2]
       CMP         R5, R6
       CALL.Z      PROC_X2
       CMP         R5, R6

       MOV         R5, M[SP+5]
       MOV         R6, M[SP+1]
       CMP         R5, R6
       CALL.Z      PROC_X1
       CMP         R5, R6

       CMP         R3, 1111h
       JMP.Z       FIM

; validacao de numeros iguais mas em posicoes distintas
VAL_X1_O2: MOV         R5, R3
           AND         R5, F000h
           CMP         R5, 1000h
           JMP.Z       VAL_X2_O1
           MOV         R5, R3
           AND         R5, 0F00h
           CMP         R5, 0100h
           JMP.Z       VAL_X1_O3
           MOV         R5, M[SP+5]
           MOV         R6, M[SP+2]
           CMP         R5, R6
           JMP.Z       PROC_O1
VAL_X1_O3: MOV         R5, R3
           AND         R5, 00F0h
           CMP         R5, 0010h
           JMP.Z       VAL_X1_O4
           MOV         R5, M[SP+5]
           MOV         R6, M[SP+3]
           CMP         R5, R6
           JMP.Z       PROC_O1
VAL_X1_O4: MOV         R5, R3
           AND         R5, 000Fh
           CMP         R5, 0001h
           JMP.Z       VAL_X2_O1
           MOV         R5, M[SP+5]
           MOV         R6, M[SP+4]
           CMP         R5, R6
           JMP.Z       PROC_O1

VAL_X2_O1: MOV         R5, R3
           AND         R5, 0F00h
           CMP         R5, 0100h
           JMP.Z       VAL_X3_O1
           MOV         R5, R3
           AND         R5, F000h
           CMP         R5, 1000h
           JMP.Z       VAL_X2_O3
           MOV         R5, M[SP+6]
           MOV         R6, M[SP+1]
           CMP         R5, R6
           JMP.Z       PROC_O2
VAL_X2_O3: MOV         R5, R3
           AND         R5, 00F0h
           CMP         R5, 0010h
           JMP.Z       VAL_X2_O4
           MOV         R5, M[SP+6]
           MOV         R6, M[SP+3]
           CMP         R5, R6
           JMP.Z       PROC_O2
VAL_X2_O4: MOV         R5, R3
           AND         R5, 000Fh
           CMP         R5, 0001h
           JMP.Z       VAL_X3_O1
           MOV         R5, M[SP+6]
           MOV         R6, M[SP+4]
           CMP         R5, R6
           JMP.Z       PROC_O2

VAL_X3_O1: MOV         R5, R3
           AND         R5, 00F0h
           CMP         R5, 0010h
           JMP.Z       VAL_X4_O1
           MOV         R5, R3
           AND         R5, F000h
           CMP         R5, 1000h
           JMP.Z       VAL_X3_O2
           MOV         R5, M[SP+7]
           MOV         R6, M[SP+1]
           CMP         R5, R6
           JMP.Z       PROC_O3
VAL_X3_O2: MOV         R5, R3
           AND         R5, 0F00h
           CMP         R5, 0100h
           JMP.Z       VAL_X3_O4
           MOV         R5, M[SP+7]
           MOV         R6, M[SP+2]
           CMP         R5, R6
           JMP.Z       PROC_O3
VAL_X3_O4: MOV         R5, R3
           AND         R5, 000Fh
           CMP         R5, 0001h
           JMP.Z       VAL_X4_O1
           MOV         R5, M[SP+7]
           MOV         R6, M[SP+4]
           CMP         R5, R6
           JMP.Z       PROC_O3

VAL_X4_O1: MOV         R5, R3
           AND         R5, 000Fh
           CMP         R5, 0001h
           JMP.Z       VAL_HIFENS
           MOV         R5, R3
           AND         R5, F000h
           CMP         R5, 1000h
           JMP.Z       VAL_X4_O2
           MOV         R5, M[SP+8]
           MOV         R6, M[SP+1]
           CMP         R5, R6
           JMP.Z       PROC_O4
VAL_X4_O2: MOV         R5, R3
           AND         R5, 0F00h
           CMP         R5, 0100h
           JMP.Z       VAL_X4_O3
           MOV         R5, M[SP+8]
           MOV         R6, M[SP+2]
           CMP         R5, R6
           JMP.Z       PROC_O4
VAL_X4_O3: MOV         R5, R3
           AND         R5, 00F0h
           CMP         R5, 0010h
           JMP.Z       VAL_HIFENS
           MOV         R5, M[SP+8]
           MOV         R6, M[SP+3]
           CMP         R5, R6
           JMP.Z       PROC_O4

VAL_HIFENS: MOV         R4, M[CONTA_CARATERES]
            CMP         R4, 4
            JMP.NZ      OUT_HIFEN

JMP         VAL_TENTA

;--------------------;
; INICIO DO PROGRAMA ;
;--------------------;
INICIO: MOV         R1, TOPOPILHA
        MOV         SP, R1
        MOV         M[CONTA_TENTATIVAS], R0 ; inicializa o contador de tentativas

; geracao aleatoria de uma sequencia
VAL_ALEAT: MOV         R1, M[ALEAT_INIC]
           AND         R1, 0001h
           CMP         R1, 0000h
           JMP.Z       SE_ZERO
           JMP         SE_UM

SE_ZERO: MOV         R1, M[ALEAT_INIC]
         ROR         R1, 0001h
         JMP         CONTA_ALGARISMOS

SE_UM: MOV         R1, M[ALEAT_INIC]
       MOV         R2, M[MASCARA]
       XOR         R1, R2
       ROR         R1, 0001h

CONTA_ALGARISMOS: INC         R5
                  CMP         R5, 0001h
                  JMP.Z       ALEAT_INT_1
                  CMP         R5, 0002h
                  JMP.Z       ALEAT_INT_2
                  CMP         R5, 0003h
                  JMP.Z       ALEAT_INT_3
                  CMP         R5, 0004h
                  JMP.Z       ALEAT_INT_4

ALEAT_INT_1: MOV         R2, 0006h
             DIV         R1, R2
             INC         R2
             ADD         M[ALEAT], R2
             JMP         CONTA_ALGARISMOS

ALEAT_INT_2: MOV         R2, 0006h
             DIV         R1, R2
             INC         R2
             ROR         R2, 0004h
             ADD         M[ALEAT], R2
             JMP         CONTA_ALGARISMOS

ALEAT_INT_3: MOV         R2, 0006h
             DIV         R1, R2
             INC         R2
             ROR         R2, 0008h
             ADD         M[ALEAT], R2
             JMP         CONTA_ALGARISMOS

ALEAT_INT_4: MOV         R2, 0006h
             DIV         R1, R2
             INC         R2
             ROR         R2, 000Ch
             ADD         M[ALEAT], R2
             MOV         R1, M[ALEAT]

; inicializar registos
MOV         R4, R0
MOV         R5, R0

; passagem da chave para a pilha
CHAVE_PILHA: MOV         R5, R1
             AND         R5, 000Fh
             PUSH        R5

             MOV         R5, R1
             AND         R5, 00F0h
             ROR         R5, 0004h
             PUSH        R5

             MOV         R5, R1
             AND         R5, 0F00h
             ROR         R5, 0008h
             PUSH        R5

             MOV         R5, R1
             AND         R5, F000h
             ROR         R5, 000Ch
             PUSH        R5

MOV         R4, MASC_BOTAO_IA
MOV         M[MASC_INTERRUPCOES], R4
MOV         R4, R0
ENI

; ciclo enquanto a interrupcao do botao iA nao alterar valor de r4
ESPERA_INICIO: CMP         R4, R0
               BR.Z        ESPERA_INICIO

DSI

; processar nova tentativa
PROC_TENTA: MOV         R2, R0
            INC         M[CONTA_TENTATIVAS] ; incrementa o contador de tentativas
            MOV         R4, MASC_BOTOES_I1_I6
            MOV         M[MASC_INTERRUPCOES], R4

; leitura da tentativa para r2
LEITURA_TENTA: ENI ; ativar as interrupcoes para os botoes i1-i6
               MOV         R4, M[CONTA_INTRO]
               CMP         R4, 4
               BR.NZ       LEITURA_TENTA

ROR         R2, 4 ; desfazer a ultima rotacao para a esquerda
DSI ; desativar as interrupcoes

MOV         R4, NL ; mudanca de linha
MOV         M[IO], R4

MOV         M[CONTA_INTRO], R0

; repor o registo r3 para guardar a nova semelhança chave/tentativa
MOV         R3, R0

; passagem da tentativa para a pilha
TENTATIVA_PILHA: MOV         R6, R2
                 AND         R6, 000Fh
                 PUSH        R6

                 MOV         R6, R2
                 AND         R6, 00F0h
                 ROR         R6, 0004h
                 PUSH        R6

                 MOV         R6, R2
                 AND         R6, 0F00h
                 ROR         R6, 0008h
                 PUSH        R6

                 MOV         R6, R2
                 AND         R6, F000h
                 ROR         R6, 000Ch
                 PUSH        R6

; validar semelhanca chave/tentativa
JMP         VAL_X

; pilha apos guardar chave e tentativa
; -------
; chave4  <- sp+8
; -------
; chave3  <- sp+7
; -------
; chave2  <- sp+6
; -------
; chave1  <- sp+5
; -------
; tenta4  <- sp+4
; -------
; tenta3  <- sp+3
; -------
; tenta2  <- sp+2
; -------
; tenta1  <- sp+1
; -------
;         <- stack pointer

; validacao de tentativas
VAL_TENTA: POP         R4 ; remover tentativa antiga da pilha
           POP         R4
           POP         R4
           POP         R4
           MOV         R4, NL ; mudanca de linha
           MOV         M[IO], R4
           MOV         M[IO], R4
           MOV         M[CONTA_CARATERES], R0
           MOV         R4, M[CONTA_TENTATIVAS]
           CMP         R4, 12 ; validacao das doze tentativas
           JMP.NZ      PROC_TENTA

;-----------------;
; FIM DO PROGRAMA ;
;-----------------;
FIM: BR          FIM