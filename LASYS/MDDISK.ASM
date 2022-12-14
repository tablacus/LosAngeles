;
;	L-os Angeles
;
;	DISK I/O
;
VER:
	LD	HL,$A081
	RET
;
DWT:
	LD	BC,$0130
	JR	DWT1
;
DRD:
	LD	BC,$012F
DWT1:
	CALL	DWT1S
INCDW:	INC	H
	INC	H
	RET
DWT1S:
	PUSH	HL
	CALL	DTA
	PUSH	DE
	CALL	SYSTEM
	XOR	A
	POP	DE
	POP	HL
	INC	DE
	INC	H
	INC	H
	RET
;
DWTW:
	LD	BC,$0230
	JR	DWTW1
DRDW:
	LD	BC,$022F
DWTW1:
	CALL	DWT1S
	INC	DE
	INC	H
	INC	H
	RET

DWTQ:
	LD	BC,$0430
	JR	DWTQ1
DRDQ:
	LD	BC,$042F
DWTQ1:
	CALL	DWTW1
	INC	DE
	INC	DE
	INC	DE
	INC	H
	INC	H
	RET
;
DTA:
	PUSH	BC
	PUSH	DE
	EX	DE,HL
	LD	C,$1A
	CALL	SYSTEM
	POP	DE
	POP	BC
	LD	A,(_DRIVE)
	LD	L,A
	LD	H,B
	RET
;
RDFAT:
	PUSH	IY
	CALL	RDFAT0
	POP	IY
	RET
;
RDFAT0:
	CALL	_DEVADR
	RET	C
	LD	A,(IY+DPB_DEVNO)
	CP	$87
	JR	NZ,RDFATX
;
	LD	A,(IY+DPB_UNITNO)
	INC	A
	LD	E,A
	LD	C,$1B
	CALL	SYSTEM
	OR	A
	SCF
	RET	Z
	CP	3
	CCF
	RET	C
	LD	A,E
;
	LD	HL,MMPD
	CP	$5D
	JR	Z,RDFAT1
	LD	HL,M2D
	CP	$62
	JR	Z,RDFAT1
	LD	HL,M2DE
	CP	$89
	JR	Z,RDFAT1
	LD	HL,M2DD8
	CP	$7A
	JR	Z,RDFAT1
	LD	HL,M2DD
	CP	$C9
	JR	Z,RDFAT1
	LD	HL,M2HD
	CP	$C5
	JR	Z,RDFAT1
	LD	HL,M2HDE
	CP	$93
	JR	Z,RDFAT1
	LD	A,D
	CP	5
	RET	C
	CP	6+1
	JR	NC,XMSX
	LD	HL,M2HS
	INC	DE
	INC	DE
	LD	(M2HS+8),DE
	JR	RDFAT1
XMSX:
	CP	8
	SCF
	RET	NZ
	LD	HL,MSXH
RDFAT1:
	PUSH	DE
	PUSH	IY
	POP	DE
	LD	BC,18
	LDIR
	LD	A,(_DSK)
	CALL	_CHGDRV
	POP	DE
;
	LD	HL,(3)
	LD	A,H
	CP	$DD
	JR	NZ,RDFATX
	LD	A,L
	CP	$21
	JR	Z,RDFATX2
RDFATX:
	CALL	RDFATS
	RET	C
RDFATX1:
	LD	HL,(_FATBF)
	LD	A,(HL)
	CP	(IY+DPB_FATID)
	RET	Z
	SCF
	RET
;
RDFATX2:
	LD	HL,$EE00
	LD	DE,(_FATBF)
	LD	BC,$0C00
	LDIR
	JR	RDFATX1
;
RDFATS:
	CALL	FATS
RDFATL:
	PUSH	BC
	CALL	_DRDC
	POP	BC
	RET	C
	DJNZ	RDFATL
	RET
;
M2DD8:	DB	1,$FB
	DW	_DRDW,_DWTW,$2908,636
	DB	$FF,12,80,8,1,2,5,1
;
M2DD:	DB	2,$F9
	DW	_DRDW,_DWTW,$290A,715
	DB	$FF,14,80,9,1,2,7,1
;
M2DE:	DB	1,$F5
	DW	_DRD,_DWT,5,395
	DB	$FF,7,40,5,1,4,3,1
;
MMPD:	DB	1,$FD
	DW	_DRDW,_DWTW,$2911,356-5
	DB	$FF,12+9,40,9,1+9,2,5+9,1
;
M2HDE:	DB	3,$F8
	DW	_DRD,_DWT,11,1429
	DB	$FE,13,80,9,1,4,7,1
;
M2HS:	DB	3,$FB
	DW	_DRD,_DWT,8,1432
	DB	$FE,10,80,9,1,4,4,10
;
MSXH:	DB	3,$FF
	DB	_DRDW,_DWTW,$2930,2047
	DB	0,52,0,1,1,2,15,1
;
RETRY:	DB	3
;
