;
;	GRAPHIC	RAM DISK DRIVER
;	by Larn M.R.
;
	$INCLUDE	LA.DEF
;
DEID	EQU	5
;
;
	OFFSET	$C000-$3000
	ORG	$3000
;
;	INIT
;
	XOR	A
	LD	(FORMATS),A
	LD	(AUTOS),A
;
	PUSH	DE
	CALL	#MPRNT
	DB	$1A,"X1 graphic ram disk driver v1.14"
	DB	" Lovers",$0D,0
	POP	DE
GRAD1:	CALL	#SPSK
	LD	A,(DE)
	INC	DE
	CP	"-"
	JR	Z,SWI
	CP	"/"
	JR	NZ,GRAD2
SWI:
	LD	A,(DE)
	CALL	#CAP
	INC	DE
	CP	'F'
	JR	NZ,GRADS1
	LD	(FORMATS),A
GRADS1:	CP	'A'
	JR	NZ,GRADS2
	LD	(AUTOS),A
	JR	GRAD1
GRADS2:	CP	'R'
	JR	NZ,GRAD1
	JP	REMOVE
;
GRAD2:	LD	A,(DE)
	CP	':'
	JR	Z,GRAD3
GRADM:	CALL	#MPRNT
	DB	"usage:",$0D
	DB	" GRAD [????] drv:",$0D,$0D
	DB	9,"/A  ???Ӱ??",$0D
	DB	9,"/F  ̫?ϯ?",$0D
	DB	9,"/R  ???ޮ",$0D,0
	AND	A
	RET
;
GRAD3:	LD	A,(#MAXDRV)
	LD	B,A
	DEC	DE
	LD	A,(DE)
	CP	'0'
	JR	C,GRADM
	LD	(DRIVE),A
;
GRAD4:	LD	A,B
	CALL	#DEVAD2
	JR	C,GRAD42
	LD	A,(IY+$12)
	CP	DEID
	JR	NZ,GRAD42
	LD	A,(IY+$13)
	CP	1
	JP	Z,GRADZ
GRAD42:	DJNZ	GRAD4
;
	CALL	GRADP
	RET	NC
	CALL	#MPRNT
	DB	"MEMAX:",0
	LD	HL,(#MEMAX)
	LD	(START+6),HL
	AND	A
	LD	BC,LAST-START
	SBC	HL,BC
	LD	(#MEMAX),HL
	CALL	#PRTHL
	CALL	#LTNL
;
;	SOFT RELOCATE
;
	EX	DE,HL
	LD	HL,ADR-START
	ADD	HL,DE
	LD	(DRDC+1),HL
	LD	(DWTC+1),HL
;
	LD	HL,START
	PUSH	DE
	LDIR
	POP	DE
;
;	WRITE DEVICE TABLE
;
	LD	(IY+$00),1	;FATLN
	LD	(IY+$01),$F9	;FATID
	LD	HL,DRDC-START
	ADD	HL,DE
	LD	(IY+$02),L	;DRDC
	LD	(IY+$03),H
	LD	HL,DWTC-START
	ADD	HL,DE
	LD	(IY+$04),L	;DWTC
	LD	(IY+$05),H
	LD	(IY+$06),0	;ADDCL
	LD	(IY+$07),0
	LD	(IY+$08),48	;CLEND
	LD	(IY+$09),0
	LD	(IY+$0A),0	;FDMODE
	LD	(IY+$0B),2	;MAXDIR
	LD	(IY+$0C),0	;MAXCYL
	LD	(IY+$0D),1	;MAXSEC
	LD	(IY+$0E),0	;FATPS
	LD	(IY+$0F),4	;INCSEC(1024=4)
	LD	(IY+$10),1	;DIRPS
	LD	(IY+$11),1	;ADDSEC
	LD	(IY+$12),DEID	;DEVNO
	LD	(IY+$13),1	;UNITNO
	LD	HL,MOTOFF-START
	ADD	HL,DE
	LD	(IY+$14),L	;MOTOFF
	LD	(IY+$15),H
	LD	HL,(#GNCLA)
	LD	(IY+$16),L	;GNCL
	LD	(IY+$17),H
	LD	HL,(#SNCLA)
	LD	(IY+$18),L	;SNCL
	LD	(IY+$19),H
	LD	(IY+$1A),0	;SDIR
	LD	(IY+$1B),0
	LD	(IY+$1C),'G'
	LD	(IY+$1D),'R'
	LD	(IY+$1E),'A'
	LD	(IY+$1F),'M'
;
;	̫?ϯ?
;
GRADF:	LD	A,(FORMATS)
	OR	A
	RET	Z
;
	CALL	#MPRNT
	DB	"format",$0D,0
;
	LD	A,(DRIVE)
	CALL	#CHGDRV
	RET	C
	CALL	#DEVADR
	LD	HL,(#DTBUF)
	LD	E,L
	LD	D,H
	INC	DE
	XOR	A
	LD	(HL),A
	LD	BC,$03FF
	LDIR
;
	LD	HL,(#DTBUF)
	LD	A,(IY+$01)
	LD	(HL),A	;FATID
	INC	HL
	DEC	(HL)	;LD (HL),$FF
	INC	HL
	DEC	(HL)
	LD	E,(IY+$0E)
	LD	D,0
	LD	B,(IY)		;FATLN
FORMAT0:PUSH	BC
	LD	HL,(#DTBUF)
	CALL	#DWTC
	POP	BC
	RET	C
	LD	HL,(#DTBUF)
	XOR	A
	LD	(HL),A
	INC	HL
	LD	(HL),A
	INC	HL
	LD	(HL),A
	DJNZ	FORMAT0
;
	LD	E,(IY+$10)
	LD	D,0
FORMAT2:LD	HL,(#DTBUF)
	CALL	#DWTC
	RET	C
	LD	A,E
	CP	(IY+$0B)
	JR	C,FORMAT2
	RET
;
GRADZ:	PUSH	IY
	POP	HL
	CALL	GRADP
	RET	NC
	PUSH	IY
	POP	DE
	LD	BC,$0020
	LDIR
	JP	GRADF
;
GRADP:	LD	A,(DE)
	CALL	#DEVAD2
	RET	C
	LD	A,(IY+$12)
	CP	DEID
	SCF
	RET	Z
	LD	A,(AUTOS)
	OR	A
	SCF
	RET	NZ
;
	CALL	#MPRNT
	DB	'Now Drive "',0
	LD	A,(DE)
	CALL	#PRINT
	CALL	#MPRNT
	DB	":",$22," is ",$22,0
	LD	A,(IY+$1C)
	CALL	#PRINT
	LD	A,(IY+$1D)
	CALL	#PRINT
	LD	A,(IY+$1E)
	CALL	#PRINT
	LD	A,(IY+$1F)
	CALL	#PRINT
	CALL	#MPRNT
	DB	'"',$0D
	DB	'Do you want to change to "GRAD"? (Y/other):',0
	CALL	#FLGET
	CALL	#CAP
	CP	'Y'
	JR	Z,SURE1
	CP	'?'
	JR	Z,SURE1
;
	CALL	#MPRNT
	DB	'No.',$0D,0
	AND	A
	RET
;
SURE1:	CALL	#MPRNT
	DB	"Yes.",$0D,0
	SCF
	RET
;
REMOVE:	LD	HL,(#MEMAX)
	INC	H
	JR	Z,REME
	DEC	H
	LD	DE,START
	LD	B,6
	CALL	CPSTR
	JR	Z,REM1
REME:	CALL	#MPRNT
	DB	"???ޮ?޷Ų?!",7,$0D,0
	AND	A
	RET
REM1:	CALL	#MPRNT
	DB	'release',$0D,'MEMAX:',0
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	(#MEMAX),HL
	CALL	#PRTHL
	CALL	#LTNL
	LD	A,(#MAXDRV)
	LD	B,A
REM2:	LD	A,B
	CALL	#DEVAD2
	JR	C,REM3
	LD	A,(IY+$12)
	CP	DEID
	JR	NZ,REM3
	LD	(IY),0
REM3:	DJNZ	REM2
	CALL	#RDVSW
	CALL	#DEVAD2
	RET	NC
	LD	A,(#MAXDRV)
	LD	B,A
	LD	C,1
REM4:	LD	A,C
	CALL	#DEVAD2
	JR	NC,REM5
	INC	C
	DJNZ	REM4
	SCF
	RET
;
REM5:	LD	A,C
	ADD	A,$40
	JP	#SDVSW
;
CPSTR:	LD	A,(DE)
	CP	(HL)
	RET	NZ
	INC	DE
	INC	HL
	DJNZ	CPSTR
	RET
;
START:	DB	"[GRAD ",0,0
;
MOTOFF:	RET
;
DRDC:	CALL	ADR
	RET	C
	PUSH	DE
	LD	DE,$400
DRDC1:	INI
	INC	B
	INC	BC
	DEC	E
	JR	NZ,DRDC1
	DEC	D
	JR	NZ,DRDC1
DWTC2:	POP	DE
	AND	$EF
	JR	S1FD0
;
DWTC:	CALL	ADR
	RET	C
	PUSH	DE
	LD	DE,$400
DWTC1:	INC	B
	OUTI
	INC	BC
	DEC	E
	JR	NZ,DWTC1
	DEC	D
	JR	NZ,DWTC1
	JR	DWTC2
;
ADR:	XOR	A
	LD	C,A	;LD C,0
	CPL		;LD A,$FF
	ADD	A,D
	RET	C
	LD	A,$10	;$40/4
	ADD	A,E
	RET	C
	ADD	A,A
	RET	C
	ADD	A,A
	RET	C
	LD	B,A
	INC	DE
	LD	A,(#WK1FD0)
	OR	$10		;BANK1
S1FD0:	JP	#S1FD0
;
LAST
;
FORMATS:DB	0
AUTOS:	DB	0
DRIVE:	DB	0
;
