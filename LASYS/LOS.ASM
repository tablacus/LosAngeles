;
;	L-os Angeles OS
;
;
PRINTS:
	PUSH	AF
	LD	A,$20
LTNL1:
	CALL	_PRINT
	POP	AF
	RET
;
LTNL:
	PUSH	AF
	LD	A,$0D
	JR	LTNL1
;
CHKATT:
	PUSH	HL
	LD	DE,$0B
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	AND	$1F
	RET	Z
	PUSH	HL
	LD	HL,_FILEN
	DEC	(HL)
	POP	HL
	SCF
	RET
;
MSG:
	PUSH	HL
	LD	H,$0D
	JR	MSG1
;
MSX:
	PUSH	HL
	LD	H,0
MSG1:
	PUSH	AF
	PUSH	DE
MSX1:
	LD	A,(DE)
	CP	H
	JR	Z,MSX2
	CALL	_PRINT
	INC	DE
	JR	MSX1
MSX2:
	POP	DE
	POP	AF
	POP	HL
	RET
;
SDVSW:
	CALL	_CHGDRV
	RET	C
	LD	(_DVSW),A
	RET
;
CAP4:
	CP	5
	RET	NZ
	LD	A,$E5
	RET

MPRINT:
	EX	(SP),HL
MPRNT1:
	LD	A,(HL)
	INC	HL
	OR	A
	CALL	NZ,_PRINT
	OR	A
	JR	NZ,MPRNT1
	EX	(SP),HL
	RET
;
BRKEY:
	CALL	_GETKY
BRKEY1:
	CP	$1B
	RET	Z
	CP	3
	RET

	DS	1
;
;
START:		;X1 START $1500
;
;
COLD:
	LD	HL,(_USR)
	JP	(HL)
;
INKEY:
	CALL	_GETKY
	OR	A
	JR	Z,INKEY
	RET

PAUSE:
	CALL	_BRKEY
	JR	Z,PAUSE2
	CP	$20
	JR	NZ,PAUSE1
;
NULL:
	CALL	_GETKY
	OR	A
	JR	NZ,NULL
	CALL	_INKEY
	CALL	BRKEY1
	JR	Z,PAUSE2
;
PAUSE1:
	EX	(SP),HL
	INC	HL
	INC	HL
	EX	(SP),HL
	RET
;
PAUSE2:
	EX	(SP),HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	EX	(SP),HL
	RET
;
PRTDHL:
	INC	HL
	EX	DE,HL
	CALL	_HLHEX
;
PRTHL:
	LD	A,H
	CALL	PRTHX
	LD	A,L
;
PRTHX:
	PUSH	AF
	RLCA
	RLCA
	RLCA
	RLCA
	CALL	PRTA2
	POP	AF
PRTA2:
	CALL	ASC
	JP	_PRINT
;
HEXHL:
	LD	A,H
	CALL	HEXHX
	LD	A,L
;
HEXHX:
	PUSH	AF
	RLCA
	RLCA
	RLCA
	RLCA
	CALL	HEXA2
	POP	AF
HEXA2:
	CALL	ASC
	LD	(DE),A
	INC	DE
	RET
;
ASC:
	AND	$0F
	OR	$30
	CP	$3A
	RET	C
	ADD	A,7
	RET
;
HEX:
	CALL	_CAP
	SUB	$30
	RET	C
	CP	$0A
	CCF
	RET	NC
	CP	$11
	RET	C
	SUB	7
	CP	$10
	CCF
	RET
;
WOPEN:
	LD	HL,0
	LD	(_SIZEH),HL
;
WOPENH:
	CALL	CHKWT
	RET	C
;
	LD	HL,FNAME+$0B
	LD	(HL),$20
	LD	B,20
WOPS1:
	INC	HL
	LD	(HL),A		;A=0
	DJNZ	WOPS1
;
WOPENX:
	CALL	_SOPEN
	JR	C,WOPEN1
	CALL	_KILLS
	JR	WOPEN1X
WOPEN1:
	CALL	NZ,_COPEN
WOPEN1X:
	RET	C
WOPEN2:
	LD	HL,(_SIZE)	;SIZE SET
	LD	(FNAME+$1C),HL
	LD	HL,(_SIZEH)
	LD	(FNAME+$1E),HL
	LD	HL,0
	LD	(_CLPS),HL
	CALL	_SETTMS
;
	LD	A,(FTYPE)
	RRA
	RET	NC
	LD	DE,FNAME+$0C
	LD	HL,(_DTADR)
	CALL	_HEXHL
	LD	A,$A0
	LD	(DE),A
	INC	DE
	LD	HL,(_EXADR)
	CALL	_HEXHL
	XOR	A
	LD	(DE),A
WRTA0:
	LD	A,(FNAME+$10)
	LD	BC,$08A0
	CP	C
	JR	NZ,WRTA3
	LD	A,$20
	LD	HL,FNAME
WRTA1:
	CP	(HL)
	JR	NZ,WRTA2
	LD	(HL),C
WRTA2:
	INC	HL
	DJNZ	WRTA1
WRTA3:
	XOR	A		;CF=0 ZF=1
	RET
;
FSIZE:
	LD	HL,(_SIZE)
	DEC	HL
	SRL	H
	SRL	H
	INC	H
	LD	B,H
	RET
;
WRD:
	CALL	FSIZE
;
	CALL	_WRDF
	CALL	NC,_WTFAT
	CALL	NC,_WTDIRX
	RET	C
WRDX2:
	LD	DE,(FNAME+$1A)
	JR	WRD1
;
WRDF:
	LD	DE,2
WRDF1:
	PUSH	BC		;FAT
	PUSH	DE
	CALL	_GNCL
	JR	C,WRDF3
	LD	A,D
	OR	E
	JR	NZ,WRDF4
	POP	HL		;HL=DE
	PUSH	HL
	LD	DE,(_CLPS)
	LD	(_CLPS),HL
	LD	A,D
	OR	E
	JR	NZ,WRDF2
	LD	(FNAME+$1A),HL
	JR	WRDF3
WRDF2:
	CALL	_SNCL
WRDF3:
	POP	DE
	POP	BC
	RET	C
	DJNZ	WRDF5
	LD	DE,(_CLPS)
	LD	HL,$FFFF
	JP	_SNCL
;
WRDF4:
	POP	DE
	POP	BC
WRDF5:
	INC	DE
	CALL	_ENDCL
	JR	C,WRDF1
EMTOFF:
	SCF
	JR	MOTOF2
;
WRDX:
	LD	HL,(_CLPS)
	PUSH	HL
	CALL	_WRDF
	POP	DE
	RET	C
	LD	A,D
	OR	E
	JR	Z,WRDX2
	CALL	_GNCL
	RET	C
;
WRD1:
	LD	B,0
WRDD:
	LD	HL,(_DTADR)
WRD3:
	LD	(_CLPS),DE
	PUSH	BC
	PUSH	DE
	CALL	_CLUST
	CALL	_DWTC
	POP	DE
	JR	C,RDD3		;MOTOFF&POP BC
	PUSH	HL
	CALL	ENDSDI
	POP	HL
	POP	BC
	JR	NC,WRDE
	DJNZ	WRD3
	LD	(_CLPS),DE
MOTOF3:
	XOR	A
MOTOF2:
	JP	_MOTOFF
;
RDD:
	LD	A,(FNAME+$0B)
	BIT	4,A
	JR	NZ,CHDIR
;
	LD	HL,(_SIZEH)
	LD	A,H
	OR	L
	SCF
	RET	NZ
	LD	HL,(_DTADR)
	LD	DE,(_SIZE)
	ADD	HL,DE
	RET	C
	EX	DE,HL
	LD	HL,(_MEMAX)
	SBC	HL,DE
	RET	C
;
	CALL	FSIZE
;
RDDX:
	LD	HL,(_DTADR)
;
RDD1:
	LD	DE,(_CLPS)
	PUSH	BC
	PUSH	HL
	PUSH	DE
	CALL	ENDSDI
	LD	(_CLPS),DE
	POP	DE
	JR	NC,RDD2
	POP	HL
;
	CALL	_CLUST
	CALL	_DRDC
;
RDD3:
	POP	BC		;CF=1 POP BC JP	MOTOFF
	JR	C,MOTOF2	;MOTOF2
	DJNZ	RDD1
	XOR	A
	JR	MOTOF2		;ZF=1	 CONT.OK
;
RDD2:
	LD	HL,(_DTBUF)
	PUSH	HL
	CALL	_CLUST
	CALL	_DRDC
	POP	HL
	POP	DE
	JR	C,RDD3		;POP BC&JP MOTOFF
	LD	BC,(_SIZE)
	DEC	BC
	LD	A,B
	AND	3
	LD	B,A
	INC	BC
	LDIR
	POP	BC
WRDE:
	OR	$FF		;CF=0 ZF=0	END
	JR	MOTOF2
;
CHDIR:
	LD	HL,(FNAME+$1A)
CHDIR2:
	PUSH	IY
	CALL	_DEVADR
	LD	(IY+DPB_SDIR),L
	LD	(IY+DPB_SDIR+1),H
	POP	IY
	RET
;
FILE6:
	XOR	A
	LD	(_WILD),A
	LD	A,$20
	LD	B,8+3
	LD	HL,FNAME
	PUSH	HL
	CALL	FILE7
	POP	HL
	SCF
	RET
;
FILE:
	LD	(FTYPE),A
;
	CALL	_RDVSW
	LD	(_DSK),A
	JP	_FILEX
;
FILEX:
	CALL	_SPSK
	CALL	CCHK3
	JR	Z,DEVI1
	INC	DE
	LD	A,(DE)
	DEC	DE
	CP	":"
	JR	NZ,DEVI1
	LD	A,(DE)		;DRIVE
	INC	DE
	INC	DE
	JR	DEVI2
;
DEVI1:
	LD	A,(_DSK)
;
DEVI2:
	CALL	_CHGDRV
	JR	C,FILE6
;
	PUSH	IY
	CALL	_DEVADR
	LD	L,(IY+DPB_SDIR)
	LD	H,(IY+DPB_SDIR+1)
	POP	IY
;
	LD	A,(DE)
	CP	$5C		;???[?g
	LD	A,$20		;????(SAVE)
	JR	NZ,FILE1X
	INC	DE
	LD	A,$10		;DIR
	LD	HL,0
;
FILE1X:
	LD	(FNAME+$0B),A
;
FILE1:
	LD	(_NDIRP),HL
;
	PUSH	DE
FILE1L:
	LD	A,(DE)
	CP	$5C
	JP	Z,FILECD	;?K?w?f?B???N?g??
	INC	DE
	CALL	CCHK3
	JR	NZ,FILE1L
	POP	DE
	JP	_FILED
;
FILED:
	CALL	FILE6
	LD	B,8
;
	LD	A,(DE)		;$E5??????
	CP	$E5
	JR	NZ,FILE3
	LD	A,5
	INC	DE
	JR	FILE2
;
FILE3:
	CALL	CCHKF
	RET	Z
	CP	"*"
	JR	Z,FILE9
	CP	"."
	JR	Z,FILE4
FILE2:
	LD	(HL),A
	INC	HL
	DJNZ	FILE3
;
FILE3L:
	CALL	CCHKF
	RET	Z
	CP	"."
	JR	NZ,FILE3L
;
FILE4:
	LD	HL,FNAME+8
	LD	B,3
;
FILE4L:
	CALL	CCHKF
	RET	Z
	CP	"."
	JR	NZ,FILE12
	LD	(FNAME),A	;..??????
	LD	(FNAME+1),A
	LD	A,$20
FILE12:
	CP	"*"
	JR	Z,FILE10
	LD	(HL),A
	INC	HL
	DJNZ	FILE4L
FILENE:
	AND	A
	RET
;
FILE9:
	CALL	FILE10
	JR	FILE3L
;
FILE10:
	LD	A,"?"
	CALL	FILE11
;
FILE7:
	LD	(HL),A
	INC	HL
	DJNZ	FILE7
	RET
;
CCHKF:
	LD	A,(DE)
	CALL	CCHK2
	RET	Z
	CALL	_CAP
	CP	$A0
	JR	NZ,CCHKF2
	LD	A,$20
CCHKF2:
	INC	DE
	CP	"?"
	RET	NZ
;
FILE11:
	LD	(_WILD),A
	AND	A		;ZF=0	CF=0
	RET
;
FILECD:
	POP	DE
	CALL	_FILED
	PUSH	DE
	CALL	_SOPEN
	POP	DE
	CCF
	RET	NC
	LD	BC,$1A
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	INC	DE
	JP	FILE1
;
FPRINT2:
	LD	B,8		;FILENAME
	CALL	MSN
	LD	A,"."
	CALL	_PRINT
	LD	B,3
MSN:
	LD	A,(HL)
	CALL	CAP3
	CALL	_PRINT
	INC	HL
	DJNZ	MSN
	RET
;
DIR:
	LD	DE,DIRW
	CALL	_FILEX
DIRX:
	CALL	_RDFAT
	RET	C
	CALL	_DSKF
	CALL	_PRTHLX
	CALL	_MPRNT
	DB	" K Bytes Free",9,0
	LD	A,(_DSK)
	CALL	_PRINT
	CALL	_MPRNT
	DB	":",$5C,0
;
	CALL	_SOPENX
	PUSH	AF
	PUSH	HL
;
	LD	HL,(_NDIRP)
	LD	A,H
	OR	L
	CALL	NZ,_PRTHL
;
DIRT2:
	CALL	_LTNL
	POP	HL
	POP	AF
;
DIRS1:
	JR	C,NCLOSES
;
DIRS2:
	CALL	FNAMEX
	CCF
	RET	NC
	CALL	_NOPENX
	JR	DIRS1
;
RCLOSE:
	PUSH	AF
	CALL	_MOTOFF
	LD	A,(_FILEN)
	OR	A
	JR	Z,POPSCF
	POP	AF
NCLOSES:
	SCF
	RET	Z		;ZF=1 ERROR
	CCF			;CF=0
	RET
POPSCF:
	POP	AF
	SCF
	RET
;
DSKF:
	LD	DE,2
	LD	L,D
	LD	H,D		;LD HL,0
DSKF1:
	PUSH	DE
	PUSH	HL
	CALL	_GNCL
	POP	HL
	JR	C,POPSCF
	LD	A,D
	OR	E
	JR	NZ,DSKF2
	INC	HL
DSKF2:
	POP	DE
	INC	DE
	CALL	_ENDCL
	JR	C,DSKF1
	RET
;
FNAMEX:
	PUSH	IY
	PUSH	HL
	POP	IY
	LD	A,(IY+$0B)
	LD	C,A
	AND	$0E
	JR	NZ,FNAMEE
	LD	A,";"
	BIT	0,C
	JR	Z,DIR1
	LD	A,"*"
DIR1:
	CALL	_PRINT
	LD	B,9
DIR1L:
	CALL	_PRNTS
	DJNZ	DIR1L
;
	LD	A,(_DSK)	;DEVICE
	CALL	_PRINT
	CALL	PRNTC
	CALL	_NFPRT		;FILENAME PRINT
	CALL	PRNTC
	LD	A,(IY+$10)	;LA?o?C?i???
	CP	$A0
	JR	Z,DIR4
	LD	B,6
DIR2:
	CALL	PRNTC
	DJNZ	DIR2
	BIT	4,C		;?f?B???N?g???
	JR	Z,DIR3
	CALL	_MPRNT
	DB	"<dir>   ",0
	JR	DIR6
DIR3:
	LD	L,(IY+$1E)	;?T?C?Y??????16bit
	LD	H,(IY+$1F)
	CALL	_PRTHL
	LD	DE,0
	CALL	DIR7
	JR	DIR6
DIR4:
	CALL	PRTDHL
	EX	DE,HL
	DEC	DE
	CALL	PRNTC
DIR5:
	PUSH	HL
	CALL	DIR7
	POP	HL
	CALL	PRNTC
	CALL	PRTDHL
DIR6:
	CALL	_PRTTMS
	CALL	_LTNL
FNAMEE:
	POP	IY
NFPRTX:
	CALL	_PAUSE		;-NFPRT	?????????o??
	DW	EBELL
	AND	A
	RET
;
DIR7:
	LD	L,(IY+$1C)	;?T?C?Y??????16bit
	LD	H,(IY+$1D)
	ADD	HL,DE
	JP	_PRTHL
;
PRNTC:
	LD	A,":"
	JP	_PRINT
;
NROPEN:
	CALL	_NOPEN
	JR	ROPEN2
;
ROPEN:
	LD	A,(FNAME+$0B)
	BIT	4,A
	JR	Z,ROPEN1
	LD	A,(FNAME)
	CP	$20
	JR	Z,ROPENR
;
ROPEN1:
	CALL	_SOPEN		;READ OPEN
ROPEN2:
	JR	C,ROPENE
;
	LD	DE,FNAME
	LD	BC,$20
	LDIR
	LD	HL,(FNAME+$1A)
	LD	(_CLPS),HL
	LD	HL,(FNAME+$1C)
	LD	(_SIZE),HL
	LD	HL,(FNAME+$1E)
	LD	(_SIZEH),HL
;
	LD	DE,FNAME+$0C
	LD	HL,$FFFF
	LD	(_GCAD),HL
	CALL	_HLHEX
	LD	(_DTADR),HL
	LD	DE,FNAME+$11
	CALL	_HLHEX
	LD	(_EXADR),HL
	XOR	A
	RET
;
ROPENR:
	LD	HL,(_NDIRP)
	LD	(FNAME+$1A),HL
	LD	HL,0
	LD	(FNAME+$1C),HL
	RET
;
ROPENE:
	LD	A,8
	RET
;
COPEN:
	LD	HL,(_NSEA)
	JR	SOPEN0
;
SOPEN:
	CALL	_RDFAT		;SEARCH OPEN
	JR	C,RDDERR
;
SOPENX:
	XOR	A
	LD	(_FILEN),A
	LD	HL,(_FSEA)
SOPEN0:
	LD	(OPENPAT+1),HL
;
	LD	DE,(_NDIRP)
	LD	A,D
	OR	E
	LD	(_DIRF),A
	JR	Z,SDIRX1
;
	CALL	DC		;???DIR
	JR	C,SDIRX0
	LD	HL,(_DIRBF)
	LD	A,(HL)
	CP	"."
	JR	Z,SDIRX2
SDIRX0:
	XOR	A
	LD	(_DIRF),A
	LD	L,A
	LD	H,A
	LD	(_NDIRP),HL	;HL=0
	CALL	CHDIR2
SDIRX1:
	LD	DE,(_DIRPS)	;?T?uDIR
;
SOPEN1:
	CALL	DC		;FILE SEARCH
	JR	C,RDDERR
;
SDIRX2:
	LD	C,32
	LD	HL,(_DIRBF)
SOPEN2:
	PUSH	DE
OPENPAT:CALL	FILESE		;????????????
	POP	DE
	JR	C,SOPENE
	JR	Z,NOTSE
SOPEN3:
	LD	A,(_DIRF)
	OR	A
	JR	NZ,SOPEN5
;
	LD	A,(DBLPAT)	;A=$29 or 0
	AND	1
	LD	C,A
	INC	A
	ADD	A,E
	LD	E,A
RTEPAT:	SUB	12		;????????????
	BIT	0,C
	JR	Z,SOPEN6
	INC	A
	JR	NZ,SOPEN6
	DEC	DE
	CALL	DC
	JR	C,RDDERR
	LD	C,16
	LD	HL,(_DIRBF)
	INC	H
	INC	H
	JR	SOPEN2
SOPEN5:
	CALL	ENDSDI
SOPEN6:
	JR	C,SOPEN1
;
NOTSE:
	OR	8		;ZF=0
	JR	EMTOF2		;CF=1 ZF=0
;
RDDERR:
	CP	A		;READ ERR CF=1 ZF=1
EMTOF2:
	JP	EMTOFF
;
NOPEN:
	CALL	_RDFAT
	JR	C,RDDERR
	LD	DE,(_FBPS)
	CALL	DC
	JR	C,RDDERR
;
NOPENX:
	LD	HL,(_FSEA)
	LD	(OPENPAT+1),HL
;
	LD	DE,(_FBPS)
	LD	A,(_FBCNT)
	DEC	A
	JR	Z,SOPEN3
NOPEN2:
	LD	HL,(_FBAD)
	LD	BC,$20
	ADD	HL,BC
	LD	C,A
	JR	SOPEN2
;
DC:
	PUSH	DE
	CALL	DCPAT
	CALL	_DRDC
	POP	DE
	RET
;
SOPENE:
	LD	(_FBAD),HL
	LD	A,C
	LD	(_FBCNT),A
	LD	(_FBPS),DE
	LD	HL,_FILEN
	INC	(HL)
	LD	HL,(_FBAD)
	JP	MOTOF3		;OK	CF=0
;
FILESE:
	LD	A,(HL)
	OR	A
	RET	Z		;END:ZF=1 CF=0
	CP	$E5
	JR	Z,FILESE1
	LD	DE,FNAME
	LD	B,11
	PUSH	HL
	CALL	CPSTR
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
;
NEXTSE:
	LD	A,(HL)
	OR	A
	SCF
	RET	Z		;!!!:ZF=1 CF=1
	CP	$E5
	SCF
	RET	Z		;!!!:(ZF=1) CF=1
	LD	DE,$20
	ADD	HL,DE
	DEC	C
	JR	NZ,NEXTSE
	JR	ZFCF0
;
CPSTR:
	LD	A,(DE)
	CP	"?"		;???C???h?J?[?h
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
;
NAME:
	CALL	_SPSK
	PUSH	DE
	CALL	_ROPEN
	POP	DE
	CALL	NC,_FILED
	CALL	NC,CHKWT
	RET	C
	CALL	WRTA0
	LD	BC,11
	CALL	WTDX2
MOTOF5:
	JP	_MOTOFF
;
CHKWT:
	LD	A,(FNAME)
	ADD	A,-$20
	RET	Z
	LD	A,(_WILD)	;(_WILD)<>0 THEN CF=1
	OR	A
	RET	Z
	SCF
	RET
;
WCLOSE:
	CALL	_RCLOSE
	RET	C
WCLOSE2:
	CALL	_WTFAT
	JR	MOTOF5
;
WTDIRX:
	LD	BC,$20
WTDX2:
	LD	HL,FNAME
	LD	DE,(_FBAD)
	LDIR
;
WTDIR:
	LD	DE,(_FBPS)
	CALL	DCPAT
	JP	_DWTC
;
KILL:
	CALL	_SOPEN
KILLW1:
	JP	C,_WCLOSE
;
	CALL	_CHKATT
	JR	C,KILLW2
	CALL	NFPRT
	JR	C,KILLW1
	CALL	_KILLSX
	CALL	_WTDIR
	JP	C,WCLOSE2
;
KILLW2:
	LD	A,(_WILD)
	SUB	$01
	JR	C,KILLW1
	CALL	_NOPENX
	JR	KILLW1
;
KILLS:
	CALL	_CHKATT
	RET	C
;
KILLSX:
	LD	(HL),$E5	;DIR
	LD	DE,$1A
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	JR	KILLS2
KILLS1:
	LD	DE,(_CLPS)	;FAT
KILLS2:
	CALL	_ENDCL
	RET	NC		;CF=0
	LD	HL,-2
	ADD	HL,DE
	RET	NC		;DE= 0 or 1
	PUSH	DE
	CALL	_GNCL
	LD	(_CLPS),DE
	POP	DE
	LD	HL,0
	CALL	NC,_SNCL
	JR	NC,KILLS1
	RET
;
RDVSW:
	LD	A,(_DVSW)
	RET
;
FATS:
	LD	DE,(_FATPS)
	LD	HL,(_FATBF)
	LD	B,(IY+DPB_FATLN)
	RET
;
WTFAT:
	PUSH	IY
	CALL	WTFAT0
	POP	IY
	RET
;
WTFAT0:
	CALL	_DEVADR		;WRITE FAT
	RET	C
	CALL	FATS
WTFAT1:
	PUSH	BC
	CALL	_DWTC
	POP	BC
	RET	C
	DJNZ	WTFAT1
	RET
;
DCPAT:
	LD	HL,(_DIRBF)
	LD	A,(_DIRF)
	OR	A
	RET	Z
;
CLUST:
	EX	DE,HL
CLSPAT:	LD	A,8	;DE=DE+8 (2D)  DPB_ADDCL ????????
DBLPAT:	ADD	HL,HL	;DE=DE*2 (512) DPB_DBLCL ????????
	EX	DE,HL
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	RET
;
FGETC:
	PUSH	HL		;CF=0 Ok!
	LD	HL,(_GCAD)	;CF=1 Z=1 ERROR
	LD	A,(_GCEH)	;CF=1 Z=0 EOF
	CP	H
	JR	C,GETC2
;
GETC1:
	PUSH	HL
	LD	HL,(_GCLN)
	LD	A,H
	OR	L
	JR	Z,GETCE2
	DEC	HL
	LD	(_GCLN),HL
	POP	HL
	LD	A,(HL)
	INC	HL
	LD	(_GCAD),HL
	POP	HL
	RET
;
GETCE2:
	POP	HL
	POP	HL
	SUB	$01		;CF=1 ZF=0 A=$FF
	RET
;
GETC2:
	PUSH	DE
	PUSH	BC
	LD	DE,(_CLPS)
	CALL	_ENDCL
	JR	NC,GETC3
	LD	A,(_CLLN)
	LD	B,A
	LD	HL,(_GCBUF)
	PUSH	BC
	CALL	RDD1
	POP	DE
	JR	C,GETCER
	LD	HL,(_SIZE)
	DEC	HL
	LD	A,H
	AND	3
	LD	H,A
	INC	HL
	LD	A,D
	SUB	B
	ADD	A,A
	ADD	A,A
	ADD	A,H
	LD	H,A
	LD	(_GCLN),HL
GETC3:
	POP	BC
	POP	DE
	LD	HL,(_GCBUF)
	JR	GETC1
;
GETCER:
	POP	BC
	POP	DE
	POP	HL
EBELL:
	XOR	A		;CF=1 ZF=1
	SCF
	RET
;
GNCL:
	LD	L,E		;GET NEXT CLUSTER
	LD	H,D
	SRL	H
	RR	L
	LD	BC,(_FATBF)
	JR	C,GNC1
	ADD	HL,DE
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	A,(HL)
	AND	$0F
	LD	D,A
	RET
GNC1:
	ADD	HL,DE
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	D,(HL)
	LD	B,4
GNC1L:
	SRL	D
	RRA
	DJNZ	GNC1L
;
	LD	E,A
	AND	A
	RET
;
SNCL:
	PUSH	HL
	LD	L,E		;SET NEXT CLUSTER
	LD	H,D
	SRL	H
	RR	L
	LD	BC,(_FATBF)
	JR	C,SNC1
	ADD	HL,DE
	ADD	HL,BC
	POP	DE
	LD	(HL),E
	INC	HL
	LD	A,D
	AND	$0F
	LD	D,A
	LD	A,(HL)
	AND	$F0
	OR	D
	LD	(HL),A
	RET
SNC1:
	ADD	HL,DE
	ADD	HL,BC
	POP	DE
	EX	DE,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	EX	DE,HL
	LD	A,(HL)
	AND	$0F
	OR	E
	LD	(HL),A
	INC	HL
	LD	(HL),D
	RET
;
CAP2:
	CALL	_CAP
CAP3:
	CALL	CAP4
	CP	$21
	RET	NC
	LD	A,$A0
	RET
;
FPRINT:
	LD	HL,FNAME
	JP	_NFPRT
;
FPRNTW:
	LD	HL,FNAME
NFPRT:
	CALL	NFPRTX
	RET	C
	LD	A,(_WILD)
	OR	A
	RET	Z
	PUSH	HL
	CALL	_NFPRT
	POP	HL
	XOR	A
	JP	_LTNL
;
ENDSDI:
	CALL	_GNCL	;END DIR
;
ENDCL:
	LD	A,D	;END CLUSTER
CLPAT1:	CP	1	;164=356	????????
	RET	NZ
	LD	A,E
CLPAT2:	CP	$64	;		????????
	RET
;
DEVADR:
	LD	A,(_DSK)
DEVADX:
	DEC	A
	AND	$1F
	CP	MAXDRV
	CCF
	RET	C
	ADD	A,A	;*2
	ADD	A,A	;*4
	ADD	A,A	;*8
	ADD	A,A	;*16
	ADD	A,A	;*32
	LD	IYL,A
	LD	IYH,DEVICE/256
	LD	A,(IY+0)
	CP	$01		;A=0 THEN CF=1
	RET
;
CCHK2:
	CP	$5C
	RET	Z
;
CCHK3:
	CP	$20
	JR	NC,CCHK
;
	CP	A		;Z=1
	RET
;
CCHECK:
	LD	A,(DE)
	INC	DE
;
CCHK:
	CP	":"
	RET	Z
	CP	$20
	RET
;
DIRW:	DB	"*.*"
;
M2D:	DB	1,$FD
	DW	_DRDW,_DWTW,$2908,356
	DB	$FF,12,40,9,1,2,5,1
;
M2HD:	DB	2,$FE
	DW	_DRD,_DWT,9,1223
	DB	$FE,11,77,8,1,4,5,1
;
