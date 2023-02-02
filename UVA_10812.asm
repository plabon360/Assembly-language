;UVA 10812
;Beat the Spread! 
.MODEL SMALL
.STACK 100H
.DATA 
     T DW ?
     A DW ?
     B DW ?
     C DW ?
     D DW ?
     I DW ?    
     INPUT DB 'INPUT : $'
     OUTPUT DB 'OUTPUT : $' 
     IMPOS DB 'impossible $'  
     SPACE DB ' $'
.CODE
MAIN PROC 
     MOV AX,@DATA
     MOV DS,AX  
     
     CALL DECIMEL_INPUT     ;input test case T
     MOV T,AX
     CALL NEWLINE
     
     MOV I,0      ;for(i=0;i<T;i++)
     MOV AX,I     
     CMP AX,T
     JL TOP
     JMP EXIT
     
     TOP:
                     
     LEA DX,INPUT
     MOV AH,9
     INT 21H 
     CALL NEWLINE
     
     CALL DECIMEL_INPUT   ;input A
     MOV A,AX
     CALL NEWLINE 
     
     CALL DECIMEL_INPUT   ;input B
     MOV B,AX
     CALL NEWLINE
     
     MOV AX,A      ;AX=A
     MOV BX,B      ;BX=B
     
     CMP BX,AX     ;if(B>A !! (A-B)%2!=0)
     JG IMPOSSIBLE ; then print impossible
     
     XOR DX,DX     
     SUB AX,BX     ;A-B
     MOV BX,2
     DIV BX        ;AX=(A-B)%2  ,  DX=remainder
     
     CMP DX,0
     JNE IMPOSSIBLE
     JMP ELSE
     
     IMPOSSIBLE:
             LEA DX,IMPOS
             MOV AH,9
             INT 21H 
             CALL NEWLINE
             JMP END_WORK
             
     ELSE:         ;else of previous if
         MOV AX,A  ;{ 
         MOV BX,B  ;  C=(A-B)/2
         XOR DX,DX ;  D=C+B   
         SUB AX,BX ;  print D && C
         MOV BX,2  ;}
         DIV BX
         
         MOV C,AX  ;C=(A-B)/2
         
         MOV BX,B  ;BX=B
         ADD AX,BX ;AX contains C,
         
         MOV D,AX  ;D=C+B
         
         MOV AX,D  ;print D
         PUSH AX
         POP AX
         CALL DECIMEL_OUTPUT
         
         LEA DX,SPACE
         MOV AH,9
         INT 21H
         
         MOV AX,C  ;Print C
         PUSH AX
         POP AX
         CALL DECIMEL_OUTPUT 
         CALL NEWLINE
                 
     END_WORK:   
             CALL NEWLINE  ;continue outer while loop
             MOV C,0
             MOV D,0
             INC I
             MOV AX,I
             CMP AX,T
             JL TOP
     EXIT:
     MOV AH,4CH
     INT 21H
MAIN ENDP 
     
         
         
DECIMEL_INPUT PROC
        
            PUSH BX    ;SAVE THE REGISTERS
            PUSH CX
            PUSH DX
        
        @BEGIN:
              XOR BX,BX ;BX=TOTAL
              XOR CX,CX ;CX HOLDS SIGN
              
              MOV AH,1 ;READ A CHARACTER
              INT 21H  ;CHARACTER IN AL
              
              CMP AL,'-'
              JE @MINUS
              
              CMP AL,'+'
              JE @PLUS
              JMP @REPEAT2
              
        @MINUS:
              MOV CX,1  ;NEGATIVE = TRUE
              
        @PLUS:
             INT 21H
             
        @REPEAT2:
                CMP AL,'0'
                JNGE @NOT_DIGIT ;if(AL>=0 && AL<=0)
                
                CMP AL,'9'
                JNLE @NOT_DIGIT  
                
                AND AX,000FH ; CONVERT TO DIGIT
                PUSH AX      ;EKTA DIGIT STACK EE SAVE KORE RAKHTESI AX DIA , ABAR PORE SETA RETRIEVE KORTESI BX DIA
                
                ;BX HOLDS THE PREVIOUS VALUE 
                ;AX HOLDS THE CURRENT VALUE
                ;AT LAST THE SUM IS IN BX
                
                MOV AX,10  ;GET 10
                MUL BX     ;TOTAL = TOTAL * 10
                POP BX     ;RETRIEVE DIGIT
                ADD BX,AX  ;TOTAL = TOTAL * 10 + DIGIT
                
                MOV AH,1
                INT 21H
                CMP AL,0DH ;CARRIAGE RETURN
                JNE @REPEAT2
                
                
              MOV AX,BX ;STORE NUM IN AX
              
              ;if(cx is negative)
              OR CX,CX 
              JE @EXIT  ;POSITIVE ER JONNO EXIT EE JABE
                                   
              NEG AX    ;NEGATIVE KORE DIBE TOTAL NUMBER K JOKHON (JE) FALSE HOBE
              ;end if  
              
         @EXIT:
              POP DX
              POP CX
              POP BX
              RET
              
         @NOT_DIGIT:
                   MOV AH,2    ;NEW LINE
                   MOV DL,13
                   INT 21H
                   MOV DL,10
                   INT 21H
                   JMP @BEGIN 
                  
DECIMEL_INPUT ENDP
     
     


DECIMEL_OUTPUT PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
     ;if AX<0
        OR AX,AX     ;AX < 0
        JGE @END_IF1 ;NO , > 0
     ;Then
        PUSH AX   ;SAVE NUMBER
        MOV DL,'-'
        MOV AH,2
        INT 21H
        POP AX
        NEG AX                
        
        @END_IF1:
                XOR CX,CX ;CX Counts digits
                MOV BX,10D ;BX has dividor
                
        @REPEAT1:
                XOR DX,DX
                DIV BX    ;AX=quotient , DX = Remainder
                PUSH DX   ;Save remainder on stack
                INC CX
                
                OR AX,AX     ;MOV AX,0
                JNE @REPEAT1 ;JNE @REPEAT1 
                
         ;convert digits to character and print
                 
                   MOV AH,2
         @PRINT_LOOP:
                    POP DX     ;LAST ER TAA AGEI PRINT HOBE. STACK ER SYSTEM ANUJAYI
                    OR DL,30H  ;ADD DL,48
                    INT 21H
                    LOOP @PRINT_LOOP  
                    
                    POP DX
                    POP CX
                    POP BX
                    POP AX 
                    
                    
                    RET
                    
DECIMEL_OUTPUT ENDP 
            
            
            
NEWLINE PROC  
        
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        MOV AH,2
        MOV DL,10
        INT 21H
        MOV DL,13
        INT 21H 
        
        POP DX
        POP CX
        POP BX
        POP AX
        
        
        RET
        
NEWLINE ENDP 
   

END MAIN