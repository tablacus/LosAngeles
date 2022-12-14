;
;	TOUCH by Larn M.R.
;
	$INCLUDE	LA.DEF
;
	ORG	$3000
;
;
SW1:
	CALL	#SPSK
	LD	A,(DE)
	CP	"-"
	JR	Z,SWI
	CP	"/"
	JP	NZ,MAIN
SWI:
	INC	DE
SWX:
	LD	A,(DE)
	CALL	#CAP
	INC	DE
	CP	"D"
	JR	NZ,SW2
	CALL	HLDECX
	LD	A,L
	SUB	80
	JR	NC,S80
	ADD	A,100
S80:
	LD	B,A
	CALL	HLDECX
	LD	C,L
	CALL	HLDEC
	JP	C,USAGE
	LD	A,L		;DAY
	AND	$1F
	LD	L,A
	LD	A,C		;MONTH
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	RL	B		;YEAR
	OR	L
	LD	L,A
	LD	H,B
	LD	(DATE),HL
	JR	SWE
SW2:
	CP	"T"
	JR	NZ,SW3
	CALL	HLDECX
	LD	B,L
	CALL	HLDECX
	LD	C,L
	CALL	HLDEC
	JP	C,USAGE
	LD	A,L		;SEC
	RRA
	AND	$1F
	LD	L,A
	LD	A,C		;MIN
	ADD	A,A
	ADD	A,A
	ADD	A,A
	RL	B
	ADD	A,A
	RL	B
	ADD	A,A
	RL	B
	OR	L
	LD	L,A
	LD	H,B
	LD	(TIME),HL
	JR	SWE
SW3:
	CP	"Q"
	JR	NZ,SW4
	LD	(SW_Q+1),A
	JR	SWE
SW4:
	CP	"S"
	JR	NZ,SW5
	LD	(SW_S+1),A
	JR	SWE
SW5:
	CP	"V"
	JR	NZ,SW6
	LD	(SW_V+1),A
	JR	SWE
SW6:
	CP	"A"
	JR	NZ,SW7
	LD	(SW_A+1),A
	JR	SWE
SW7:
	JP	USAGE
SWE:
	LD	A,(DE)
	CP	$21
	JP	C,SW1
	JP	SWX
;
MAIN:
	CALL	#FILE
	JP	C,USAGE
	LD	IX,(#IBFAD)
	LD	A,(IX+1)
	CP	$20
	JP	Z,USAGE
	LD	A,(#WILD)
	LD	A,$1A
	CALL	NZ,#PRINT
;
	CALL	#RDFAT
	CALL	#MOTOFF
	CALL	NC,#SOPENX
MAIN2:
	JP	C,#RCLOSE
;
	PUSH	HL
	POP	IY
;
	CALL	PAUSE
;
	LD	B,(IY+$0B)
	LD	A,B
	AND	7		;shr
	JP	NZ,MAIN7
;
SW_A:	LD	A,$00
	OR	A
	JR	NZ,CSWE
;
SW_S:	LD	A,$00
	OR	A
	JR	Z,CSW1
	BIT	4,B
	JR	CSWX
CSW1:
SW_V:	LD	A,$00
	OR	A
	JR	Z,CSW3
	BIT	3,B
	JR	CSWX
CSW3:
	LD	A,B
	AND	$18
	JP	NZ,MAIN7
	JR	CSWE
CSWX:
	JP	Z,MAIN7
CSWE:
SW_Q:	LD	L,$00
	LD	A,(#WILD)
	OR	L
	JR	Z,MAIN5
	LD	HL,(#FBAD)
	CALL	#NFPRT
	CALL	#PRNTS
	LD	A,(SW_Q+1)
	OR	A
	JR	Z,MAIN5
	CALL	#MPRNT
	DB	"<y/n>?",0
	CALL	SURE
	CALL	C,#LTNL
	JR	C,MAIN7
	CALL	#PRNTS
MAIN5:
	LD	HL,(TIME)
	LD	A,H
	AND	L
	INC	A
	JR	Z,MAIN3
;
	LD	(IY+$16),L
	LD	(IY+$17),H
MAIN3:
	LD	HL,(DATE)
	LD	A,H
	AND	L
	INC	A
	JR	Z,MAIN4
;
	LD	(IY+$18),L
	LD	(IY+$19),H
MAIN4:
	CALL	#WTDIR
	CALL	#MOTOFF
	RET	C
MAIN6:
	CALL	#MPRNT
	DB	"Ok",$0D,0
MAIN7:
	LD	A,(#WILD)
	OR	A
	RET	Z
	CALL	#NOPENX
	JP	MAIN2
;
QUIT:
	POP	AF
	CALL	#RCLOSE
	XOR	A
	RET
;
HLDEC:
	CALL	#SPSK
	CALL	DEC
	RET	C
	LD	L,A
	INC	DE
HLDEC1:
	CALL	DEC
	CCF
	RET	NC
	LD	H,A
	LD	A,L
HLDEC2:
	CP	10
	JR	C,HLDEC3
	SUB	10
	JR	HLDEC2
HLDEC3:
	LD	L,A
	ADD	A,A
	ADD	A,A
	ADD	A,L
	ADD	A,A
	ADD	A,H
	LD	L,A
	INC	DE
	JR	HLDEC1
DEC:
	LD	A,(DE)
	SUB	"0"
	RET	C
	CP	10
	CCF
	RET
;
HLDECX:
	CALL	HLDEC
	JR	C,HLDECE
	LD	A,(DE)
	INC	DE
	CP	"-"
	RET	Z
	CP	"/"
	RET	Z
	CP	":"
	RET	Z
HLDECE:
	POP	AF
	XOR	A
;
PAUSE:
	CALL	#BRKEY
	JP	Z,#HOT
	CALL	#GETKY
	CP	$20
	RET	NZ
	LD	(SW_Q+1),A
	RET
;
SURE:			;Yes CF=0 , No CF=1
	CALL	#KYBFC
	CALL	#FLGET
	CALL	#CAP
	CP	"A"
	JR	Z,ALL
	CP	"?"
	JR	Z,ALL
	CP	"Y"
	JR	Z,YES
	CP	"?"
	JR	Z,YES
	CP	"N"
	JR	Z,NO
	CP	"?"
	JR	Z,NO
	CP	3
	JR	Z,BREAK
	CP	$1B
	JR	NZ,SURE
BREAK:
	CALL	#LTNL
	JP	#HOT
ALL:
	XOR	A
	LD	(SW_Q+1),A
YES:
	LD	A,"y"
PRTYN:
	JP	#PRINT
NO:
	LD	A,"n"
	SCF
	JR	PRTYN
;
USAGE:
	CALL	#MPRNT
	DB	"touch v1.00"
	DB	" Lovers",$0D
	DB	"usage:",$0D
	DB	" TOUCH ???? ???????",$0D
	DB	$0D
	DB	9,"/Dyy-mm-dd ????????",$0D
	DB	9,"/Thh:ss:mm ????????",$0D
	DB	9,"/A ???",$0D
	DB	9,"/Q ????",$0D
	DB	9,"/S ???????",$0D
	DB	9,"/V ??????????",$0D
	DB	0
	AND	A
	RET
;
DATE:	DW	$FFFF
TIME:	DW	$FFFF
;
