;----------------------;
; IAC 2017/2018 LEIC-A ;
; Projeto MASTERMIND   ;
;----------------------;

;------------;
; CONSTANTES ;
;------------;
IO                      EQU         FFFEh
TOPOPILHA               EQU         FDFFh
MASCARA                 EQU         8016h
MASC_INTERRUPCOES       EQU         FFFAh
MASC_BOTOES_I1_I6_TEMPO EQU         1000000001111110b
MASC_BOTAO_IA           EQU         0000010000000000b
MASC_LEDS               EQU         1111111111111111b
CARATERE_CONTROLO       EQU         '@'
CURSOR_TEXTO            EQU         FFFCh
TEMPO_PORTO_FREQ        EQU         FFF6h
TEMPO_PORTO_ATIVA       EQU         FFF7h
LEDS                    EQU         FFF8h
SETE_SEGM_DIREITA       EQU         FFF0h
SETE_SEGM_ESQUERDA      EQU         FFF1h
TEMPO_FREQUENCIA        EQU         5
LCD_PORTO_CONTROLO      EQU         FFF4h
LCD_PORTO_ESCRITA       EQU         FFF5h
LCD_CARATERE_DIREITA    EQU         1000000000000000b
LCD_CARATERE_ESQUERDA   EQU         1000000000000001b

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

ORIG        FE0Fh ; zona da interrupcao do temporizador

INT_15             WORD        TEMPO

;-------;
; DADOS ;
;-------;
ORIG        8000h ; zona de dados

ALEAT_INIC         WORD        0000h
ALEAT              WORD        0000h
CONTA_TENTATIVAS   WORD        0000h
CONTA_CARATERES    WORD        0000h
CONTA_INTRO        WORD        0000h
MELHOR_PONTUACAO   WORD        0000h
POSICAO_CURSOR     WORD        0000h
TEXTO_TITULO       STR         'MASTERMIND@'
TEXTO_INICIO       STR         'Carregue no botao IA para iniciar o jogo@'
TEXTO_REINICIO     STR         'Carregue no botao IA para reiniciar o jogo@'
TEXTO_TEMPO        STR         'Acabou o tempo!@'
TEXTO_VITORIA      STR         'PARABENS! Acertou na chave@'
TEXTO_GAMEOVER     STR         'GAMEOVER@'
TEXTO_SEPARADOR    STR         ': @'

ORIG        0000h
MOV         R7, FFFFh
MOV         M[CURSOR_TEXTO], R7 ; inicializar cursor
JMP         INICIO

;-------------------------;
; ROTINAS DE INTERRUPCOES ;
;-------------------------;
; ler tentativa
BOTAO1: INC         M[CONTA_INTRO]
        MOV         R4, '1'
        CALL        IMPRIME_CARATERE
        ADD         R2, 0001h
        ROL         R2, 4
        RTI

BOTAO2: INC         M[CONTA_INTRO]
        MOV         R4, '2'
        CALL        IMPRIME_CARATERE
        ADD         R2, 0002h
        ROL         R2, 4
        RTI

BOTAO3: INC         M[CONTA_INTRO]
        MOV         R4, '3'
        CALL        IMPRIME_CARATERE
        ADD         R2, 0003h
        ROL         R2, 4
        RTI

BOTAO4: INC         M[CONTA_INTRO]
        MOV         R4, '4'
        CALL        IMPRIME_CARATERE
        ADD         R2, 0004h
        ROL         R2, 4
        RTI

BOTAO5: INC         M[CONTA_INTRO]
        MOV         R4, '5'
        CALL        IMPRIME_CARATERE
        ADD         R2, 0005h
        ROL         R2, 4
        RTI

BOTAO6: INC         M[CONTA_INTRO]
        MOV         R4, '6'
        CALL        IMPRIME_CARATERE
        ADD         R2, 0006h
        ROL         R2, 4
        RTI

; alterar valor de r4 para sair do ciclo ESPERA_INICIO
BOTAO_IA: INC         R4
          RTI

; ativar o temporizador e definir o intervalo de tempo entre interrupcoes
TEMPO: PUSH        R5
       MOV         R4, 1
       MOV         R5, TEMPO_FREQUENCIA
       MOV         M[TEMPO_PORTO_FREQ], R5 ; definir a frequencia com que o temporizador gera uma nova interrupcao
       MOV         R5, 1
       MOV         M[TEMPO_PORTO_ATIVA], R5
       POP         R5
       RTI

; leitura da tentativa
LEITURA_TENTA: PUSH        R5
               PUSH        R6
               MOV         R6, MASC_LEDS
LEITURA_CICLO: MOV         R5, M[CONTA_INTRO]
               CMP         R5, 4
               BR.Z        LEITURA_SUCESSO
               MOV         M[LEDS], R6
               CMP         R6, R0 ; verificar se os leds estao todos apagados
               BR.Z        LEITURA_FIM_TEMPO
               CMP         R4, 1 ; verificar se a interrupcao do temporizador foi ativada
               BR.NZ       LEITURA_CICLO
               SHL         R6, 1
               MOV         R4, 0
               BR          LEITURA_CICLO

LEITURA_FIM_TEMPO: POP         R6
                   POP         R5
                   MOV         R4, 0 ; o registo r4 indicara se a leitura foi ou nao bem sucedida
                   RET

LEITURA_SUCESSO: POP         R6
                 POP         R5
                 MOV         R4, 1 ; o registo r4 indicara se a leitura foi ou nao bem sucedida
                 RET

; escrita da pontuacao atual no display de sete segmentos
ESCRITA_PONTUACAO: PUSH        R4
                   PUSH        R5
                   MOV         R4, M[CONTA_TENTATIVAS]
                   MOV         R5, 10
                   DIV         R4, R5
                   MOV         M[SETE_SEGM_DIREITA], R5 ; resto da divisao, algarismo das unidades
                   MOV         M[SETE_SEGM_ESQUERDA], R4 ; resultado da divisao, algarismo das dezenas
                   POP         R5
                   POP         R4
                   RET

; verificar se a pontuacao obtida e a melhor ate ao momento e se for atualiza no LCD
VERIFICAR_MELHOR_PONTUACAO: PUSH        R4
                            PUSH        R5
                            PUSH        R6
                            MOV         R4, M[MELHOR_PONTUACAO]
                            MOV         R5, M[CONTA_TENTATIVAS]
                            CMP         R4, R0
                            BR.Z        ATUALIZA_PONTUACAO
                            CMP         R4, R5
                            BR.P        ATUALIZA_PONTUACAO
                            POP         R6
                            POP         R5
                            POP         R4
                            RET

ATUALIZA_PONTUACAO:         MOV         M[MELHOR_PONTUACAO], R5
                            MOV         R6, 10
                            DIV         R5, R6
                            ADD         R5, 0030h ; codigo ascii para os carateres dos numeros situam-se entre 0030h e 0039h
                            ADD         R6, 0030h
                            MOV         R4, LCD_CARATERE_DIREITA ; posicao do cursor
                            MOV         M[LCD_PORTO_CONTROLO], R4
                            MOV         M[LCD_PORTO_ESCRITA], R5
                            MOV         R4, LCD_CARATERE_ESQUERDA ; posicao do cursor
                            MOV         M[LCD_PORTO_CONTROLO], R4
                            MOV         M[LCD_PORTO_ESCRITA], R6
                            POP         R6
                            POP         R5
                            POP         R4
                            RET

;-------------------------------------;
; MUDANCA DE LINHA NA JANELA DE TEXTO ;
;-------------------------------------;
NOVALINHA: MOV         R4, M[POSICAO_CURSOR]
           AND         R4, FF00h
           ADD         R4, 0100h
           MOV         M[POSICAO_CURSOR], R4
           MOV         M[CURSOR_TEXTO], R4
           RET

;---------------------------------------;
; IMPRIMIR CARATERES NA JANELA DE TEXTO ;
;---------------------------------------;
IMPRIME_CARATERE: PUSH        R5
                  MOV         R5, M[POSICAO_CURSOR]
                  MOV         M[CURSOR_TEXTO], R5
                  MOV         M[IO], R4
                  INC         M[POSICAO_CURSOR]
                  POP         R5
                  RET

;-------------------------------------;
; IMPRIMIR STRINGS NA JANELA DE TEXTO ;
;-------------------------------------;
IMPRIME_STRING: PUSH        R4
                PUSH        R7
CICLO_IMPRIME: MOV         R4, M[R7]
               CMP         R4, CARATERE_CONTROLO
               BR.Z        FIM_IMPRIME
               CALL        IMPRIME_CARATERE
               INC         R7
               BR          CICLO_IMPRIME
FIM_IMPRIME: POP         R7
             POP         R4
             RET

;------------------------;
; LIMPAR JANELA DE TEXTO ;
;------------------------;
LIMPA_JANELA: PUSH        R7
              PUSH        R5
              MOV         R5, 10000
              MOV         M[CURSOR_TEXTO], R0
              MOV         M[POSICAO_CURSOR], R0
LIMPA_JANELA_CICLO: MOV         R4, ' '
                    CALL        IMPRIME_CARATERE
                    DEC         R5
                    BR.NZ       LIMPA_JANELA_CICLO
LIMPA_JANELA_FIM: MOV         M[CURSOR_TEXTO], R0
                  MOV         M[POSICAO_CURSOR], R0
                  POP         R5
                  POP         R7
                  RET

;---------------------------------------;
; IMPRIMIR CARATERES NA JANELA DE TEXTO ;
;---------------------------------------;
; imprime para a consola os 'x'
OUT_X: MOV         R4, 'x'
       CALL        IMPRIME_CARATERE
       RET

; imprime para a consola os 'o'
OUT_O: MOV         R4, 'o'
       CALL        IMPRIME_CARATERE
       RET

; imprime para a consola os '-'
OUT_HIFEN: MOV         R4, '-'
           CALL        IMPRIME_CARATERE
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
       JMP.Z       VITORIA
       JMP         VAL_X1_O2

VITORIA: CALL        NOVALINHA
         MOV         R7, TEXTO_VITORIA ; passar o texto para a rotina de impressao atraves do registo r7
         CALL        IMPRIME_STRING
         CALL        NOVALINHA
         CALL        VERIFICAR_MELHOR_PONTUACAO
         POP         R4 ; remover tentativa antiga da pilha
         POP         R4
         POP         R4
         POP         R4
         MOV         R4, 0
         JMP         REINICIO

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
        CALL        ESCRITA_PONTUACAO
        MOV         R5, R0

; passar o texto para a rotina de impressao atraves do registo r7
MOV         R7, TEXTO_TITULO
CALL        IMPRIME_STRING
CALL        NOVALINHA

; passar o texto para a rotina de impressao atraves do registo r7
MOV         R7, TEXTO_INICIO
CALL        IMPRIME_STRING

MOV         R4, MASC_BOTAO_IA
MOV         M[MASC_INTERRUPCOES], R4
MOV         R4, R0
ENI

; ciclo enquanto a interrupcao do botao iA nao alterar valor de r4
ESPERA_INICIO: INC         M[ALEAT_INIC]
               CMP         R4, R0
               BR.Z        ESPERA_INICIO

DSI
CALL        LIMPA_JANELA

; geracao aleatoria de uma sequencia
MOV         R3, R0
MOV         R5, 4

ALEAT_CICLO: MOV         R1, M[ALEAT_INIC]
             ROL         R3, 4
             AND         R1, 0001h
             CMP         R5, R0
             JMP.Z       ALEAT_FIM
             CMP         R1, 0000h
             JMP.Z       SE_ZERO
             JMP         SE_UM

SE_ZERO: MOV         R1, M[ALEAT_INIC]
         ROR         R1, 0001h
         MOV         M[ALEAT_INIC], R1
         JMP         ALEAT_ALGS

SE_UM: MOV         R1, M[ALEAT_INIC]
       MOV         R2, M[MASCARA]
       XOR         R1, R2
       ROR         R1, 0001h
       MOV         M[ALEAT_INIC], R1

ALEAT_ALGS: MOV         R2, 0005h
            DIV         R1, R2
            INC         R2
            ADD         R3, R2
            DEC         R5
            JMP         ALEAT_CICLO

ALEAT_FIM: MOV         M[ALEAT], R3
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

; processar nova tentativa
PROC_TENTA: MOV         R2, R0
            INC         M[CONTA_TENTATIVAS] ; incrementa o contador de tentativas
            CALL        ESCRITA_PONTUACAO
            MOV         R4, MASC_BOTOES_I1_I6_TEMPO
            MOV         M[MASC_INTERRUPCOES], R4

; leitura da tentativa para r2
ENI ; ativar as interrupcoes para os botoes i1-i6
INT         15
CALL        LEITURA_TENTA

CMP         R4, 1
JMP.Z       FIM_PROC_TENTA ; se a jogado tiver sido feita antes do tempo acabar
; passar o texto para a rotina de impressao atraves do registo r7
MOV         R7, TEXTO_SEPARADOR
CALL        IMPRIME_STRING
; passar o texto para a rotina de impressao atraves do registo r7
MOV         R7, TEXTO_TEMPO
CALL        IMPRIME_STRING
PUSH        R0 ; preencher o espaco da pilha respetivo a tentativa
PUSH        R0 ; este sera descartado ao validar a nova tentativa
PUSH        R0
PUSH        R0
MOV         M[CONTA_INTRO], R0
JMP         VAL_TENTA

FIM_PROC_TENTA: ROR         R2, 4 ; desfazer a ultima rotacao para a esquerda
                DSI ; desativar as interrupcoes

                ; passar o texto para a rotina de impressao atraves do registo r7
                MOV         R7, TEXTO_SEPARADOR
                CALL        IMPRIME_STRING

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
           CALL        NOVALINHA
           MOV         M[CONTA_CARATERES], R0
           MOV         R4, M[CONTA_TENTATIVAS]
           CMP         R4, 12 ; validacao das doze tentativas
           JMP.NZ      PROC_TENTA

; passar o texto para a rotina de impressao atraves do registo r7
MOV         R7, TEXTO_GAMEOVER
CALL        IMPRIME_STRING
CALL        NOVALINHA

REINICIO: POP         R4 ; remover chave da pilha
          POP         R4
          POP         R4
          POP         R4
          MOV         M[ALEAT], R0
          MOV         M[ALEAT_INIC], R0
          MOV         M[CONTA_CARATERES], R0
          MOV         M[LEDS], R0 ; apagar todos os leds
          MOV         R4, MASC_BOTAO_IA
          MOV         M[MASC_INTERRUPCOES], R4
          ; passar o texto para a rotina de impressao atraves do registo r7
          MOV         R7, TEXTO_REINICIO
          CALL        IMPRIME_STRING
          MOV         R4, R0
          ENI
; ciclo enquanto a interrupcao do botao iA nao alterar valor de r4
ESPERA_REINICIO: CMP         R4, R0
                 BR.Z        ESPERA_REINICIO

DSI
CALL        LIMPA_JANELA
JMP         INICIO

;-----------------;
; FIM DO PROGRAMA ;
;-----------------;
FIM: BR          FIM