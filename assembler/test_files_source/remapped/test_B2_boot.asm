	ORG  0x0410
		loadimm.upper 0x00
		loadimm.lower 0x02
		mov           r0,r7
		loadimm.lower 0x03
		mov           r1,r7
		loadimm.lower 0x05
		mov           r3,r7
		loadimm.upper 0x04
		loadimm.lower 0x10
		mov           r4,r7
		loadimm.upper 0x00
		loadimm.lower 0x01
		mov           r5,r7
		loadimm.lower 0x05
		mov           r6,r7
		loadimm.lower 0x00
		BR.SUB R4,18 ; Go to the subroutine		
		BRR 0     ; Infinite loop (the end of the program)
		ADD R2, R1, R5  ; Start of the subroutine. It runs for 5 times. R2 <-- R1 + 1
		MUL R1, R0, R2  ; R1 <-- R0 x R2
		SUB R6, R6, R5  ; R6 <-- R6 - 1   The counter for the loop.
		TEST R6         ; Set the z flag for the branch decision
		BRR.z 2     ; If r6 is zero, jump out of the loop. 
		BRR -5		; If not jump to the start of the subroutine.
		RETURN 	
	END
