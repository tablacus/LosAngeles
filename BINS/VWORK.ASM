;
;	MSX2 VWORK by Larn M.R. and Aleph
;
	$INCLUDE	LA.DEF
;
PORT0:	EQU	$98
PORT1:	EQU	$99
;
	ORG	$3000
;
	PUSH	DE
	CALL	#MPRNT
	DB	$1A,"MSX2 vwork v1.02 Lovers & VERNET"
	DB	$0D,0
	POP	DE
;
	CALL	#SPSK
	LD	A,(DE)
	CP	"/"
	JR	Z,SW2
	CP	"-"
	JR	Z,SW2
	JP	TSR
;
SW2:	INC	DE
	LD	A,(DE)
	CALL	#CAP
	CP	"R"
	JP	Z,REMOVE
	CP	"I"
	JR	NZ,SW3
	LD	(FORMAT),A
	JR	TSR
SW3:
	CP	"Z"
	JP	NZ,USAGE
;
TSR:
	CALL	PRO
	JR	NC,TSR1
	LD	A,(FORMAT)
	OR	A
	JP	NZ,INIT
	SCF
	RET
TSR1:
	LD	HL,(#POKE+1)
	LD	(POKE),HL
	LD	HL,(#PEEK+1)
	LD	(PEEK),HL
	LD	HL,(#POKE@+1)
	LD	(POKE@),HL
	LD	HL,(#PEEK@+1)
	LD	(PEEK@),HL
	LD	HL,(#WKSIZ)
	LD	(WKSIZ),HL
;
	LD	HL,(#MEMAX)
	LD	(START+6),HL
	LD	BC,LAST-START
	AND	A
	SBC	HL,BC
	LD	(#MEMAX),HL
;
	EX	DE,HL
;
	LD	HL,_POKE-START
	ADD	HL,DE
	LD	(#POKE+1),HL
;
	LD	HL,_PEEK-START
	ADD	HL,DE
	LD	(#PEEK+1),HL
;
	LD	HL,_POKE@-START
	ADD	HL,DE
	LD	(#POKE@+1),HL
;
	LD	HL,_PEEK@-START
	ADD	HL,DE
	LD	(#PEEK@+1),HL
;
	LD	HL,ADR-START
	ADD	HL,DE
	LD	(PATCH1+1),HL
	LD	(PATCH2+1),HL
;
	LD	HL,START
	LD	BC,LAST-START
	LDIR
;
	LD	HL,$C000
	LD	(#WKSIZ),HL
;
	CALL	MESSAGE
;
INIT:
	LD	A,(FORMAT)
	OR	A
	RET	Z
	CALL	#MPRNT
	DB	"initlialize",$0D,0
	LD	HL,(#WKSIZ)
CLEAR:
	DEC	HL
	XOR	A
	CALL	#POKE
	LD	A,H
	OR	L
	JR	NZ,CLEAR
	RET
;
MESSAGE:
	CALL	#MPRNT
	DB	"MEMAX:",0
	LD	HL,(#MEMAX)
	CALL	#PRTHL
	CALL	#LTNL
	CALL	#MPRNT
	DB	"WKSIZ:",0
	LD	HL,(#WKSIZ)
	CALL	#PRTHL
	XOR	A
	JP	#LTNL
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
	LD	B,6
	CALL	CPSTR
	JR	Z,REM2
REME:	CALL	#MPRNT
	DB	"???ޮ?޷Ų?!",7,$0D,0
	AND	A
	RET
;
REM2:	CALL	#MPRNT
	DB	'realese',$0D,0
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#MEMAX),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#POKE+1),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#PEEK+1),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#POKE@+1),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(#PEEK@+1),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(#WKSIZ),DE
	JP	MESSAGE
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
	LD	DE,START+1
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
USAGE:	CALL	#MPRNT
	DB	"usage:",$0D
	DB	" VWORK    ?ޮ????",$0D
	DB	" VWORK /I ܰ?????",$0D
	DB	" VWORK /R  ???ޮ",$0D
	DB	0
	XOR	A
	RET
;
FORMAT:	DB	0
;
;		 012345	 6 7
START:	DB	"[VWORK",0,0
;
POKE:	DW	0
PEEK:	DW	0
POKE@:	DW	0
PEEK@:	DW	0
WKSIZ:	DW	0
;
_POKE:
	PUSH	BC
	LD	B,$40		;write
PATCH1:	CALL	ADR
	OUT	(PORT0),A
	JR	POKE1
;
_PEEK:
	PUSH	BC
	LD	B,0		;read
PATCH2:	CALL	ADR
	IN	A,(PORT0)
POKE1:
	POP	BC
	PUSH	AF
	LD	A,($FFED)
	OUT	(PORT1),A
	LD	A,$80+14
	OUT	(PORT1),A
	POP	AF
	AND	A
	EI
	RET
;
ADR:			; read B=$40 : write B=$00
	PUSH	AF
	LD	A,H
	ADD	A,$40		;use $4000-
	LD	C,A
	RLCA
	RLCA
	AND	$03		;bit16-14
	DI
	OUT	(PORT1),A
	LD	A,$80+14	;R#14
	OUT	(PORT1),A
	NOP			;wait
	NOP
	NOP
	NOP
	LD	A,L		;bit7-0
	OUT	(PORT1),A
	LD	A,C
	AND	$3F
	OR	B
	OUT	(PORT1),A	;bit13-8 and flag
	POP	AF
	RET
;
_POKE@:
	EX	DE,HL
_POKE@1:
	LD	A,(DE)
	INC	DE
	CALL	#POKE
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,_POKE@1
	RET
;
_PEEK@:
	EX	DE,HL
_PEEK@1:
	CALL	#PEEK
	INC	HL
	LD	(DE),A
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,_PEEK@1
	RET
;
LAST:
