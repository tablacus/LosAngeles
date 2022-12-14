;
;	PRNDRV by Larn M.R.
;
	$INCLUDE	LA.DEF
;
	ORG	$3000
;
	CALL	#SPSK
	LD	A,(DE)
	CP	"/"
	JR	Z,SW2
	CP	"-"
	JR	Z,SW2
	JP	MAIN
;
SW2:	INC	DE
	LD	A,(DE)
	INC	DE
	CALL	#CAP
	CP	"R"
	JP	Z,REMOVE
	CP	"Z"
	JP	NZ,USAGE
MAIN:
	CALL	#SPSK
	LD	A,(DE)
	CP	"1"
	JR	NZ,MAIN2
	LD	A,$18		;JR
	LD	(CR),A
	JR	MAINX
MAIN2:
	CP	"2"
	JR	NZ,MAIN3
	LD	A,$C4		;CALL NZ,
	LD	(\LP),A
	JR	MAINX
MAIN3:
	CP	"3"
	JP	NZ,USAGE
MAINX:
	CALL	PRO
	RET	C
;
	CALL	TITLE
;
	CALL	#MPRNT
	DB	"MEMAX:",0
	LD	HL,(#MEMAX)
	LD	(START+8),HL
	LD	BC,LAST-START
	AND	A
	SBC	HL,BC
	LD	(#MEMAX),HL
	CALL	#PRTHL
	CALL	#LTNL
	EX	DE,HL
;
	LD	HL,(#PRINT+1)
	LD	(_PRINT),HL
	LD	(\PRINT+1),HL
	LD	HL,(#LPRNT+1)
	LD	(_LPRNT),HL
	LD	(\LPRNT+1),HL
	LD	HL,(#LPTON+1)
	LD	(_LPTON),HL
	LD	HL,(#LPTOF+1)
	LD	(_LPTOF),HL
;
	LD	HL,PRINT-START
	ADD	HL,DE
	LD	(#PRINT+1),HL
;
	LD	HL,LPRNT-START
	ADD	HL,DE
	LD	(#LPRNT+1),HL
;
	LD	HL,LPTON-START
	ADD	HL,DE
	LD	(#LPTON+1),HL
;
	LD	HL,LPTOF-START
	ADD	HL,DE
	LD	(#LPTOF+1),HL
;
	LD	HL,LP-START
	ADD	HL,DE
	LD	(\LP+1),HL
;
	LD	HL,START
	LDIR
	XOR	A
	RET
;
REMOVE:	LD	HL,(#MEMAX)
	LD	DE,(#MEMAX1)
	PUSH	HL
	AND	A
	SBC	HL,DE
	POP	HL
	JR	Z,REME
;
	LD	DE,START
	LD	B,8
	CALL	CPSTR
	JR	Z,REM2
REME:	CALL	#MPRNT
	DB	"???ޮ?޷Ų?!",7,$0D,0
	AND	A
	RET
;
REM2:
	CALL	TITLE
	CALL	#MPRNT
	DB	'release',$0D,'MEMAX:',0
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	EX	DE,HL
	LD	(#MEMAX),HL
	CALL	#PRTHL
	CALL	#LTNL
	EX	DE,HL
;
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#PRINT+1),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#LPRNT+1),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#LPTON+1),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#LPTOF+1),DE
	XOR	A
	RET
;
PRO:	LD	HL,(#MEMAX)
PRO1:	LD	DE,(#MEMAX1)
	AND	A
	EX	DE,HL
	SBC	HL,DE
	EX	DE,HL
	RET	Z
;
	LD	A,(HL)
	CP	'['
	SCF
	CCF
	RET	NZ
	LD	DE,START+2
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,$1F
	CP	B
	JR	NC,PRO2
	DEC	HL
	LD	B,5
PRO2:
	PUSH	BC
	PUSH	HL
	CALL	CPSTR
	POP	HL
	POP	BC
	SCF
	RET	Z
	LD	C,B
	LD	B,0
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	JR	PRO1
;
CPSTR:	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	DE
	INC	HL
	DJNZ	CPSTR
	RET
;
TITLE:
	CALL	#MPRNT
	DB	$1A,"prndrv v1.00 Lovers"
	DB	$0D,0
	RET
;
USAGE:
	CALL	TITLE
	CALL	#MPRNT
	DB	"usage:",$0D
	DB	" PRNDRV mode",$0D
	DB	" PRNDRV /R  ???ޮ",$0D
	DB	$0D,"mode"
	DB	9,"1 ... CR",$0D
	DB	9,"2 ... LF",$0D
	DB	9,"3 ... CR+LF",$0D
	DB	0
	XOR	A
	RET
;
;		 0  1  234567  8 9
START:	DB	"[",6,"PRNDRV",0,0
;
_PRINT:	DW	#HOT
_LPRNT:	DW	#HOT
_LPTON:	DW	#HOT
_LPTOF:	DW	#HOT
;
PRINT:
\PRINT:	CALL	#HOT
	PUSH	HL
	LD	HL,#LPSW
	INC	(HL)
	DEC	(HL)
	POP	HL
	RET	Z
LPRNT:
	CP	$0A
	RET	Z
	CP	$0D
CR:	JR	NZ,LP
\LP:	CALL	#HOT
	LD	A,$0A
LP:
	PUSH	AF
RETRY:
	POP	AF
	PUSH	AF
\LPRNT:	CALL	#HOT
	JR	C,LP1
	POP	AF
	AND	A
	RET
LP1:
	PUSH	HL
	CALL	#KYBFC
	LD	HL,(#LPSW)
	CALL	#LPTOF
	CALL	#NL
	CALL	#MPRNT
	DB	$1A,"      ???????װ",$0D
	DB	"????<A> ??ײ<R> Ѽ<I> ?",7,0
	CALL	#FLGET
	CALL	#LTNL
	CALL	#CAP
	CP	"A"
	JP	Z,#HOT
	INC	L
	DEC	L
	CALL	NZ,#LPTON
	POP	HL
	CP	"R"
	JR	Z,RETRY
	CP	"I"
	JR	NZ,LP1
	POP	AF
	SCF
LPTOF:
	PUSH	AF
	XOR	A
LPT1:
	LD	(#LPSW),A
	POP	AF
	RET
LPTON:
	PUSH	AF
	LD	A,1
	JR	LPT1
;
LAST:
