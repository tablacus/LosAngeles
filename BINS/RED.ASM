;
;	RED by Larn M.R.
;
	$INCLUDE	LA.DEF
;
	ORG	$D000
;
REDID	EQU	$0A
ADDR	EQU	$4000
DATA	EQU	$3000
;
START:
	CALL	TITLE
	LD	A,16
	LD	(SIZE),A
	CALL	#SPSK
	LD	A,(DE)
	CP	"/"
	JR	Z,SW
	CP	"-"
	JR	NZ,MAIN
SW:
	INC	DE
	LD	A,(DE)
	CALL	#CAP
	CP	"M"
	JP	NZ,USAGE
	INC	DE
	CALL	#2HEX
	JP	C,USAGE
	LD	B,A
	AND	$0F
	LD	C,A
	LD	A,B
	AND	$F0
	RRCA
	LD	B,A
	RRCA
	RRCA
	ADD	A,B
	ADD	A,C
	JP	Z,USAGE
	CP	64
	JP	NC,USAGE
	LD	(SIZE),A
MAIN:
	LD	(DEBUF),DE
 	DB	$3E
	AND	A
	LD	(PRTF),A
RED1:
	LD	A,(DE)
	INC	DE
	CP	$20
	JP	C,USAGE
	CP	">"
	JR	NZ,RED1
;
	XOR	A
	DEC	DE
	LD	(DE),A
	INC	DE
	LD	A,(DE)
	CP	"?"
	JR	NZ,NPRT
	DB	$3E
	SCF
	LD	(PRTF),A
	INC	DE
NPRT:
	LD	HL,FNAME
FILE:
	LD	A,(DE)
	INC	DE
	LD	(HL),A
	INC	HL
	CP	$20
	JR	NC,FILE
;
	LD	A,(SIZE)
	ADD	A,A
	ADD	A,A
	LD	D,A
	LD	E,0
	LD	HL,(#WKSIZ)
	AND	A
	SBC	HL,DE
	JR	C,WKERR
	LD	(ADDRX),HL
	INC	HL
	LD	(POINT),HL
	LD	DE,-1024
	ADD	HL,DE
	JR	C,WKOK
WKERR:
	CALL	#MPRNT
	DB	"ĸ??ܰ? ?? ??Ų?!",7,$0D,0
	AND	A
	RET
WKOK:
	LD	HL,(#WKSIZ)
	LD	(WKSIZ+1),HL
	LD	HL,(ADDRX)
	LD	(#WKSIZ),HL
	LD	HL,(#PRINT+1)
	LD	(PRINT+1),HL
	LD	HL,(#PRNT0+1)
	LD	(PRNT0+1),HL
	LD	HL,RED
	LD	(#PRINT+1),HL
	LD	HL,PRNT0X
	LD	(#PRNT0+1),HL
	LD	HL,(#GETL+1)
	LD	(GETL+1),HL
	LD	HL,GETL
	LD	(#GETL+1),HL
	LD	HL,(#NL+1)
	LD	(NL+1),HL
	LD	HL,NLX
	LD	(#NL+1),HL
	LD	HL,(#MEMAX1)
	LD	(MEMAX1),HL
	LD	HL,START
	LD	(#MEMAX1),HL
	LD	HL,(#HOT+1)
	LD	(HOT),HL
	LD	HL,REREASE
	LD	(#HOT+1),HL
;
	LD	HL,(ADDRX)
	LD	A,REDID
	CALL	#POKE
	LD	DE,(DEBUF)
	CALL	#CMDANL
	DB	$3E
REREASE:
	LD	SP,(#STKAD)
	LD	HL,#HOT
	PUSH	HL
;
	AND	A
	PUSH	AF
	LD	HL,(#PRINT+1)
 	LD	BC,RED
	LD	DE,MESRED
	CALL	CPVEC
	JR	C,RERE1
	LD	HL,(PRINT+1)
	LD	(#PRINT+1),HL
RERE1:
	LD	HL,(#PRNT0+1)
 	LD	BC,PRNT0X
	LD	DE,MESP0
	CALL	CPVEC
	JR	C,RERE1X
	LD	HL,(PRNT0+1)
	LD	(#PRNT0+1),HL
RERE1X:
	LD	HL,(#GETL+1)
	LD	BC,GETL
	LD	DE,MESGET
	CALL	CPVEC
	JR	C,RERE5
	LD	HL,(GETL+1)
	LD	(#GETL+1),HL
RERE5:
	LD	HL,(#NL+1)
	LD	BC,NLX
	LD	DE,MESNL
	CALL	CPVEC
	JR	C,RERE6
	LD	HL,(NL+1)
	LD	(#NL+1),HL
RERE6:
	LD	HL,(#HOT+1)
	LD	BC,REREASE
	LD	DE,MESHOT
	CALL	CPVEC
	JR	C,RERE3
	LD	HL,(HOT)
	LD	(#HOT+1),HL
RERE3:
	LD	HL,(#MEMAX1)
	LD	BC,START
	LD	DE,MESMEM
	CALL	CPVEC
	JR	C,RERE2
	LD	HL,(MEMAX1)
	LD	(#MEMAX1),HL
RERE2:
	LD	HL,(#WKSIZ)
	LD	BC,(ADDRX)
	LD	DE,MESWKS
	CALL	CPVEC
	JR	C,RERE4
	LD	HL,(WKSIZ+1)
	LD	(#WKSIZ),HL
RERE4:
	POP	AF
	CALL	C,#ERROR
;
	LD	HL,(ADDRX)
	CALL	#PEEK
	CP	REDID
	SCF
	CCF
	RET	NZ
	LD	HL,(POINT)
	DEC	HL
	CALL	#PEEK
	DEC	HL
	CP	$0A
	JR	Z,CRLF
	INC	HL
	INC	HL
CRLF:
	LD	DE,(ADDRX)
	SCF
	SBC	HL,DE
	RET	Z
;
	PUSH	HL
	LD	B,H
	LD	C,L
	INC	HL
	INC	HL
	INC	HL
	LD	(#SIZE),HL
	LD	HL,DATA
	LD	(#DTADR),HL
	PUSH	HL
	LD	DE,(ADDRX)
	INC	DE
	CALL	#PEEK@
	POP	DE
	POP	HL
	ADD	HL,DE
	LD	(HL),$0D
	INC	HL
	LD	(HL),$0A
	INC	HL
	LD	(HL),$1A
RETRY:
	LD	A,4
	LD	DE,FNAME
	CALL	#FILE
	JR	C,WERR
	CALL	#WOPEN
	JR	C,WERR
	CALL	#WRD
	RET	NC
WERR:
	CALL	#MPRNT
	DB	"??޲ڸ?̧?? ? ???خ? ?޷Ų?!",$0D
	DB	"?޳???? <A>???? <R>ӳ????",0
	CALL	#FLGET
	CALL	#LTNL
	CALL	#CAP
	CP	$03
	RET	Z
	CP	$1B
	RET	Z
	CP	"A"
	RET	Z
	CP	"R"
	JR	Z,RETRY
	JR	WERR
CPVEC:
	AND	A
	SBC	HL,BC
	RET	Z
	PUSH	DE
	CALL	#MPRNT
	DB	"Warning! ",0
	POP	DE
	CALL	#MSX
	CALL	#MPRNT
	DB	" ?? ??????ò?ܡ",$0D,0
	SCF
	RET
;
TITLE:
	PUSH	DE
	CALL	#MPRNT
	DB	$1A
	DB	"redirection v1.01"
	DB	" Lovers",$0D
	DB	0
	POP	DE
	RET
USAGE:
	CALL	#MPRNT
	DB	"usage:",$0D
	DB	" RED [????] command >filename",$0D
	DB	" RED [????] command >?filename",$0D
	DB	$0D,"????:",9
	DB	"/Mn ????(n:1-63)",$0D
	DB	0
	AND	A
	RET
;
NLX:
	PUSH	AF
	PUSH	HL
	CALL	PRTF
NL:	CALL	C,0
	LD	HL,(POINT)
	DEC	HL
	CALL	#PEEK
	POP	HL
	CP	$0A
	JR	NZ,NL1
	POP	AF
	RET
NL1:
	LD	A,$0D
	JR	NL2
;
GETL:	CALL	0
	PUSH	AF
	DB	$3E
	AND	A
	LD	(PRTF),A
	PUSH	HL
	PUSH	DE
	LD	HL,(POINT)
	PUSH	HL
	LD	DE,(WKSIZ+1)
	AND	A
	SBC	HL,DE
	POP	HL
	JR	Z,GETL3
GETL1:
	DEC	HL
	CALL	#PEEK
	CP	$0A
	JR	NZ,GETL1
	INC	HL
	LD	(POINT),HL
	POP	DE
	PUSH	DE
GETL2:
	LD	A,(DE)
	INC	DE
	OR	A
	JR	Z,GETL3
	CALL	RED
	JR	GETL2
GETL3:
	POP	DE
	POP	HL
	LD	A,$0D
	CALL	RED
	DB	$3E
	SCF
	LD	(PRTF),A
	POP	AF
	RET
PRNT0X:
	PUSH	AF
	CALL	PRTF
PRNT0:	CALL	C,0
	CP	$20
	JR	NC,REDB
	POP	AF
	LD	A,"."
	JR	REDC
;
RED:
	PUSH	AF
	CALL	PRTF
PRINT:	CALL	C,0
;
	CP	$09
	JR	Z,REDB
	CP	$0D
	JR	NZ,REDA
NL2:
	CALL	REDC
	LD	A,$0A
	CALL	REDC
REDA:
	CP	$20
	JR	C,REDF
REDB:
	POP	AF
REDC:
	PUSH	HL
	PUSH	AF
	LD	HL,(ADDRX)
	CALL	#PEEK
	CP	REDID
	JR	NZ,REDE
	LD	HL,(POINT)
	PUSH	DE
	PUSH	HL
WKSIZ:	LD	DE,0
	AND	A
	SBC	HL,DE
	POP	HL
	POP	DE
	JR	Z,REDE
	POP	AF
	PUSH	AF
	CALL	#POKE
	INC	HL
	LD	(POINT),HL
REDE:
	POP	AF
	POP	HL
	RET
REDF:
	POP	AF
	RET
;
PRTF:	AND	A
	RET
;
MESRED:	DB	"#PRINT ",0
MESP0:	DB	"#PRNT0 ",0
MESGET:	DB	"#GETL  ",0
MESNL:	DB	"#NL    ",0
MESHOT:	DB	"#HOT   ",0
MESMEM:	DB	"#MEMAX1",0
MESWKS:	DB	"#WKSIZ ",0
;
HOT:	DW	0
MEMAX1:	DW	0
;
ADDRX:	DW	0
;
SIZE:	DB	16
DEBUF:	DW	0
POINT:	DW	ADDR+1
FNAME:
