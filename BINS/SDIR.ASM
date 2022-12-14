;
;	SDIR	by Larn M.R.
;
	$INCLUDE	LA.DEF

BASE	EQU	$000B
@FATBF	EQU	$4000
@DIRBF	EQU	@FATBF+$1000
@DTBUF	EQU	@DIRBF+$1000

	ORG	$3000

	CALL	#SPSK
	LD	A,(DE)
	CP	"/"
	JP	Z,USAGE
	CP	"-"
	JP	Z,USAGE

	CALL	#FILE
	RET	C
	PUSH	DE
	LD	IX,(#IBFAD)
	LD	A,(IX+1)
	LD	DE,WILD
	CP	$20
	CALL	Z,#FILED
	CALL	#RDFAT
	CALL	#MOTOFF
	JP	NC,DIRX
	CALL	#DEVADR
	POP	DE
	RET	C

	LD	A,(IY+!DEVNO)
	AND	$7F
	CP	7
	JR	NZ,CHKDSK

	CALL	#VER
	LD	A,H
	CP	$A2
	JR	NZ,FDMODE
				;for LAE on LSX-Dodgers
	LD	HL,(BASE-1)
	LD	L,$89
	LD	(HL),$FF

	LD	A,(IY+!UNITNO)
	LD	L,$DC		;GETDPB
	CALL	$000F
	PUSH	IX
	POP	IY

FDMODE:
	BIT	0,(IY+!FDMODE)
	JR	Z,HIGH
	LD	B,16
	JR	LOW
HIGH:
	LD	B,26
LOW:
;	CHANGE DPB(for S-OS)

	LD	A,(IY+!MAXSEC)
	LD	(DPBX),A
	LD	(IY+!MAXSEC),B
;
;	CHECK DISK
;
CHKDSK:
	LD	HL,$0E00
	LD	DE,$0000	;FAT
	CALL	@RDFAT
	JR	NC,DSKFRE1
	JP	Z,ERROR
	LD	HL,$0C00
	LD	DE,$0001
	CALL	@RDFAT
	JP	C,ERROR

DSKFRE1:
	LD	A,"$"
	CALL	#PRINT

	CALL	@DSKF
	LD	A,L
	CALL	#PRTHX

	CALL	#MPRNT
	DB	" Clusters Free",$0D,0
					;READ DIR
	LD	DE,(@FATPS)
	INC	DE
	LD	(@DIRPS),DE
	LD	HL,@DIRBF
	CALL	@DRDSB		;FILE SEARCH
	JP	C,ERROR

	CALL	@SOPEN
DIR1:
	JR	C,OK
	PUSH	HL
	POP	IX
	LD	DE,ATR
	LD	A,(HL)
	BIT	7,A
	JR	NZ,DIR2
	AND	7
	ADD	A,A
	ADD	A,A
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	CALL	#MSX
	JR	DIR3
DIR2:
	CALL	#MPRNT
	DB	"Dir",0
DIR3:
	LD	A,$20
	BIT	6,(HL)
	JR	Z,DIR4
	LD	A,"*"
DIR4:
	CALL	#PRINT
	CALL	#PRNTS

	INC	HL
	LD	A,(#DSK)
	CALL	#PRINT
	LD	A,":"
	CALL	#PRINT
	CALL	FPRNT

	LD	A,":"
	CALL	#PRINT
	LD	L,(IX+20)
	LD	H,(IX+21)
	CALL	#PRTHL

	LD	A,":"
	CALL	#PRINT
	LD	E,(IX+18)
	LD	D,(IX+19)
	ADD	HL,DE
	DEC	HL
	CALL	#PRTHL

	LD	A,":"
	CALL	#PRINT
	LD	L,(IX+22)
	LD	H,(IX+23)
	CALL	#PRTHL

	CALL	#PAUSE
	DW	OK
	CALL	#LTNL

	CALL	@NOPEN
	JR	DIR1
ERROR:
	SCF
	DB	$3E
OK:
	XOR	A

	LD	A,(DPBX)
	OR	A
	JR	Z,OK2
	LD	(IY+!MAXSEC),A
OK2:
	CALL	#MOTOFF
	JP	#NL

DIRX:
	CALL	#DIRX
	JP	#HOT
FPRNT:
	LD	B,13
	CALL	FPRNT1
	LD	A,"."
	CALL	#PRINT
	LD	B,3
FPRNT1:
	LD	A,(HL)
	INC	HL
	CP	$21
	JR	NC,FPRNT2
	LD	A,$A0
FPRNT2:
	CALL	#PRINT
	DJNZ	FPRNT1
	RET

@RDFAT:
	LD	(@FATPS),DE
	LD	BC,@FATBF
	ADD	HL,BC
	LD	(@FATAD),HL
	LD	A,(#DSK)
	CALL	#CHGDRV
	LD	HL,@FATBF
	CALL	@DRDSB
	JR	C,RDFAT1
	LD	HL,(@FATAD)
	LD	E,(HL)
	INC	L
	LD	D,(HL)

	LD	HL,$8F01
	AND	A
	SBC	HL,DE
	RET	Z
	SCF
	RET
RDFAT1:
	XOR	A
	SCF
	RET

@DRDSB:
	LD	A,(IY+!DEVNO)
	AND	$7F
	CP	7
	JR	NZ,DRDRAM

	PUSH	DE
	EX	DE,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	EX	DE,HL
	LD	B,$10
DRDSB1:
	PUSH	BC
	PUSH	HL
	CALL	#DRD
	POP	HL
	INC	H
	POP	BC
	JR	C,DRDSB2
	DJNZ	DRDSB1
DRDSB2:
	POP	DE
	RET

DRDRAM:
	PUSH	DE
	EX	DE,HL
	ADD	HL,HL
	ADD	HL,HL
	EX	DE,HL
	LD	B,4
DRDSB3:
	PUSH	BC
	CALL	#DRDC
	POP	BC
	JR	C,DRDSB4
	DJNZ	DRDSB3
DRDSB4:
	POP	DE
	RET

@DSKF:
	LD	A,(@FATPS)
	RRCA
	CPL
	AND	$80
	LD	B,A

	LD	HL,0
	LD	DE,0
DSKF1:
	PUSH	DE
	CALL	@GNCL
	LD	A,D
	OR	E
	JR	NZ,DSKF2
	INC	HL
DSKF2:
	POP	DE
	INC	E
	DJNZ	DSKF1
	RET

@GNCL:
	XOR	A
	OR	D
	RET	NZ
	PUSH	HL
	SLA	E
	RL	D
	SRL	E
	LD	A,(@FATAD+1)
	ADD	A,D
	LD	D,A
	EX	DE,HL
	LD	A,(HL)
	ADD	A,A
	JR	C,GNCL1
	SET	7,L
	LD	D,(HL)
	SRL	D
	RRA
	LD	E,A
	POP	HL
	RET
GNCL1:
	LD	D,$FF
	AND	A
	RRA
	LD	E,A
	POP	HL
	RET

@SOPEN:
	LD	HL,FILESE
SOPEN0:
	LD	(OPENPAT+1),HL

SOPEN1:
	LD	C,128
	LD	HL,@DIRBF
SOPEN2:
OPENPAT:CALL	FILESE		;????
	CCF
	RET	C
SOPENE:
	LD	(FBAD),HL
	LD	A,C
	LD	(FBCNT),A
	RET			;Ok	CF=0

@NOPEN:
	LD	HL,FILESE
	LD	(OPENPAT+1),HL

	LD	A,(FBCNT)
	DEC	A
	SCF
	RET	Z
NOPEN2:
	LD	HL,(FBAD)
	LD	BC,$20
	ADD	HL,BC
	LD	C,A
	JR	SOPEN2

FILESE:
	LD	A,(HL)
	CP	$FF
	RET	Z		;END:ZF=1 CF=0
	OR	A
	JR	Z,FILESE1
	LD	DE,(#IBFAD)
	INC	DE
	LD	B,8
	PUSH	HL
	INC	HL
	CALL	CPSTR
	JR	NZ,FILESE0
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	INC	HL
	LD	B,3
	CALL	CPSTR
FILESE0:
	POP	HL
	SCF
	RET	Z		;!!!:(ZF=1) CF=1
FILESE1:
	LD	DE,$20
	ADD	HL,DE
	DEC	C
	JR	NZ,FILESE
ZFCF0:
	OR	$FF		;ZF=0 CF=0
	RET

NEXTSE:
	LD	A,(HL)
	OR	A
	SCF
	RET	Z		;!!!:ZF=1 CF=1
	CP	$FF
	SCF
	RET	Z		;!!!:(ZF=1) CF=1
	LD	DE,$20
	ADD	HL,DE
	DEC	C
	JR	NZ,NEXTSE
	JR	ZFCF0

CPSTR:
	LD	A,(DE)
	CP	"?"		;?????????
	JR	Z,CPSTR2
	LD	A,(HL)
	CALL	CAP2
	PUSH	HL
	LD	H,A
	LD	A,(DE)
	CALL	CAP2
	CP	H		;CP (HL),(DE)
	POP	HL
	RET	NZ
CPSTR2:
	INC	DE
	INC	HL
	DJNZ	CPSTR
	RET

CAP2:
	CALL	#CAP
CAP3:
	CP	$21
	RET	NC
	LD	A,$A0
	RET

USAGE:
	CALL	#MPRNT
	DB	"sdir v1.00 Lovers",$0D
	DB	"usage:",$0D
	DB	" SDIR [??????:][???????]",$0D
	DB	$0D,0
	XOR	A
	RET

WILD:
	DB	"*.*",0
ATR:
	DB	"Nul",0
	DB	"Bin",0
	DB	"Bas",0
	DB	"???",0
	DB	"Asc",0
	DB	"???",0
	DB	"???",0
	DB	"???",0

DSK1:	DB	0
DSK2:	DB	0
DPBX:	DB	0
FBAD:	DW	0
FBCNT:	DB	0
@FATPS:	DW	0
@DIRPS:	DW	0
@FATAD:	DW	$0E00
