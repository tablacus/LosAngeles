;
;	MWORK by Larn M.R.
;
	$INCLUDE	LA.DEF
;
	ORG	$3000
;
	PUSH	DE
	CALL	#MPRNT
	DB	$1A,"mwork v1.00 Lovers"
	DB	$0D,0
	POP	DE
;
	CALL	#SPSK
	LD	A,(DE)
	CP	"/"
	JR	Z,SW2
	CP	"-"
	JR	Z,SW2
	JP	DBEX
;
SW2:	INC	DE
	LD	A,(DE)
	CALL	#CAP
	CP	"R"
	JP	Z,REMOVE
	CP	"Z"
	JP	NZ,USAGE
;
DBEX:	CALL	PRO
	RET	C
;
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
	LD	BC,1024*16
	LD	(#WKSIZ),BC
	AND	A
	SBC	HL,BC
	LD	(PATCH1+1),HL
	LD	(PATCH2+1),HL
	LD	(PATCH3+1),HL
	LD	(PATCH4+1),HL
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
	LD	HL,START
	LD	BC,LAST-START
	LDIR
	LD	H,D
	LD	L,E
	INC	DE
	LD	(HL),0
	LD	BC,(#WKSIZ)
	DEC	BC
	LDIR
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
	AND	A
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
	DB	"???ޮ?޷Ͼ?!",7,$0D,0
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
	DB	" MWORK    ?ޮ????",$0D
	DB	" MWORK /R  ???ޮ",$0D
	DB	0
	AND	A
	RET
;
;
;		 012345	 6 7
START:	DB	"[MWORK",0,0
;
POKE:	DW	0
PEEK:	DW	0
POKE@:	DW	0
PEEK@:	DW	0
WKSIZ:	DW	0
;
_POKE:
	PUSH	DE
	PUSH	HL
PATCH1:	LD	DE,0
	ADD	HL,DE
	LD	(HL),A
	POP	HL
	POP	DE
	RET
;
_PEEK:
	PUSH	DE
	PUSH	HL
PATCH2:	LD	DE,0
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	POP	DE
	RET
;
_POKE@:
	PUSH	HL
PATCH3:	LD	HL,0
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	LDIR
	RET
;
_PEEK@:
	PUSH	HL
PATCH4:	LD	HL,0
	ADD	HL,DE
	POP	DE
	LDIR
	RET
LAST:
