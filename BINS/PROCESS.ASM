;
;	PROCESS
;
	$INCLUDE	LA.DEF
;
	OFFSET	$C000-$3000
	ORG	$3000
;
	CALL	#MPRNT
	DB	$1A,'process v1.06'
	DB	' (C) 1994 by Larn M.R.',$0D
	DB	'addr size  owner',13
	DB	'---- ----- ------',13
	DB	0
;
	LD	HL,(#MEMAX)
;
PRO1:
	LD	DE,(#MEMAX1)
	LD	A,H
	AND	A
	RET	Z
	INC	A
	RET	Z
	PUSH	HL
	SBC	HL,DE
	POP	HL
	RET	Z
	CALL	#PRTHL
	CALL	#PRNTS
;
	LD	A,(HL)
	CP	'['
	JR	NZ,NOTLA
	INC	HL
	LD	B,(HL)
	LD	A,$1F
	CP	B
	JR	NC,PRON
	DEC	HL
	LD	B,5
PRON:
	PUSH	HL
	LD	E,B
	LD	D,0
	ADD	HL,DE
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL
	PUSH	HL
	EX	DE,HL
	AND	A
	SBC	HL,DE
	CALL	#PRTHLX
	CALL	#PRNTS
	LD	A,(#PRTHLX+2)
	CP	$30
	CALL	C,#PRNTS
	POP	HL
	INC	HL
PRO2:	LD	A,(HL)
	INC	HL
	CALL	#PRINT
	DJNZ	PRO2
	CALL	#LTNL
	CALL	#PAUSE
	DW	BREAK
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JR	PRO1
;
NOTLA:	CALL	#MPRNT
	DB	"????? ?????",$0D,0
BREAK:	AND	A
	RET
