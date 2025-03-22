ORG 0x0000
    IN r1   ; 03
    IN r2	; 05
    LOADIMM.LOWER 4
    LOADIMM.UPPER 4
    NOP
    NOP
    NOP
    NOP
    MOV R3, R7 ; move 0x0404 to R3
    NOP
    NOP
    NOP
    NOP
    STORE R3, R1 ; store 03 to 0x0404
    NOP
    NOP
    NOP
    NOP
    LOAD R4, R3 ; load 03 from 0x0404 into R4
    ADD R5, R2, R4 ; add 03 to 05 = 8
    NOP
    NOP
    NOP
    NOP
    OUT R5 
END