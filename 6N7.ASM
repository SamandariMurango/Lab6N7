DRB     EQU     $0001
DDRB    EQU     $0003
DDRP    EQU     $025A
DRP     EQU     $0258
DRJ     EQU     $0262
DDRJ    EQU     $026A


        ORG     $1000
        TPA
        ANDA    #%10101111                ; INITIALIZED BOTH XIRQ AND IRQ
        TAP
        LDAA    #$40
        STAA    $001E
        LDS     #$2000
GOBCK   LDAB    #$00
        LDD     #IRQISR
        STD     $3E72
        BEQ     COUNT                    ; BRANCH TO COUNT WHEN IRQISR IS CONNECTED TO GOUNT
        LDD     #XIRQ
        STD     $3E74
        BEQ     FINISH
        BRA     GOBCK
HERE    BRA     HERE


IRQISR  LDAA    #$FF                     ; OUTPUT PORT INITIALIZATION
        STAA    DDRB
        STAA    DDRP

COUNT   LDAA    #$FF
        STAA    DRP
        LDAA    #$FE                             ; SELECTED DIG3 AS THE DISPLAY
        STAA    DRP
        LDAB    $00


LOOP    LDX     #SEGDIS                   ; COUNTING CONTENT
        ABX                               ; ADD CONTENTS OF ACCU B TO THE CONTENT OF INDEX REGISTER X AND STORE THE RESULT IN INDEX REGISTER X
        LDAA    $00,X
        CMPA    #$12
        BEQ     GOBCK                     ; WHEN THE COUNTING BEGINS, THE INITIAL CONTENT IN THE INDEX X WILL BE LOADED ON ACCUMULATOR A AND COMPARED WITH 12
        STAA    DRB                       ; IT WILL BRANCH TO GOBCK WHERE IT WILL DISPLAY THE VALUE
        JSR     TIME250                   ; IN 250 MILLISECOND
        INCB                              ; INCREMENT B
        BRA     LOOP                      ; LOOP BACK TO SEGDIS, JUMP TO THE NEXT CONTENT.
        RTI                               ;ADD CONTENT AND STORE CONTENT OF ACCU B INTO INDEX REGISTER X , LOAD THE NEXT CONTENT INTO ACCU A AND COMPARE WITH 12
                                          ; LOOP AND DISPLAY FOR 250 MILLISECOND UNTIL THE LAST CONTENT AND RETURN TO INTERRUPT.


XIRQ    LDAA    #$FF
        STAA    DDRB                      ; OUTPUT PORT INITIALIZATION
        STAA    DDRP
        
        
AGAIN   LDAA    #$FF
        STAA    DRP
        STAA    DRB                       ; BAR-LED WILL BE THE OUPUT DISPLAY
        JSR     TIME250                   ; FOR 250 MILLISECOND
        LDAA    #$00
        STAA    DRB
        JSR     TIME250
        LDAB    COUNT2                    ; THE LEDs WILL BLINK ON AND OFF WITH COUNT2
        DECB                              ;  EACH TIME THE LED BLINK IT DECREMENT COUNT2
        BEQ     FINISH                    ; AFTER EACH DECREMENT IF COUNTER2 IS EQUAL TO ZERO , IT WILL BRANCH TO SOFTWARE INTERRUPT
        BRA     AGAIN                     ; OTHERWISE IT WILL ALWAYS BRANCH TO BAR-LED BLINKING ON AND OFF WITH 2Hz FREQUENCY.
        RTI

        

TIME250 PSHA
        PSHY
        LDAA    #250
BON     LDY     #12000                     ; 250 MILLISECOND DELAY WITH 2Hz FREQUENCY.
DELAY   DEY
        BNE     DELAY
        DECA
        BNE     BON
        PULY
        PULA
        RTS


FINISH  SWI

SEGDIS  FCB     $3F,$06,$5B,$4F,$66,$6D,$7D,$12    ; THE COUNTING FROM 0-6
COUNT2  FCB     $0A
        END