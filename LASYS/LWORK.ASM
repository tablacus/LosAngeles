;
;	L-os Angeles WORK
;
;	LA WORKS
;
	ORG	$1F00
;
_CYL0:	DB	$FF	;シリンダ
_CYL1:	DB	$FF	;シリンダ
_CYL2:	DB	$FF	;シリンダ
_CYL3:	DB	$FF	;シリンダ
_DRIVE:	DB	0	;unit no.
_WK1FD0:DB	0	;=PORT$1FD0
_SIZEH:	DW	0	;REAL SIZE=_SIZEH*65536+_SIZE
_MSEC:	DB	9	;MAX SECTOR
_ISEC:	DB	$FF	;
_SECADD:DW	SECPAT+1;for 2HS
_CLPS:	DW	0	;CLUSTER POSITION
_GCAD:	DW	0	;シーケンシャル(_FGETC)
_GCLN:	DW	0	;    //
_GCEH:	DB	GCEH	;    //
_CLLN:	DB	1	;    //
_FBPS:	DW	0	;WILD CARD関係
_FBAD:	DW	0	;    //
_FBCNT:	DB	0	;    //
_WILD:	DB	0	;WILD CARDｼﾖｳ?
_FILEN:	DB	0	;Search	Files
_DIRF:	DB	0
_NDIRP:	DW	0	;現在のDIRの位置
_DIRBF:	DW	DTBUF	;ディレクトリバッファ
_DRDA:	DW	_DRD	;1SEC=1024byte
_DWTA:	DW	_DWT	;     //
_DRDWA:	DW	_DRDW	;1SEC=512byte
_DWTWA:	DW	_DWTW	;     //
_MTOFFA:DW	_FDMOFF	;FLOPPY DISK MOTOR OFF
_GNCLA:	DW	GNCL	;GET Cluster from FAT
_SNCLA:	DW	SNCL	;SET Cluster to FAT
_M2D:	DW	M2D
_M2HD:	DW	M2HD
_FSEA:	DW	FILESE
_NSEA:	DW	NEXTSE
_FATBF1:DW	FATBF
_MEMAX1:DW	MEMAX
_CONYS:	DW	CONYS
_CONYE:	DW	CONYE
_CONXS:	DW	CONXS
_CONXE:	DW	CONXE
_COLORF:DW	COLORF
_MAXDRV:DB	MAXDRV
_GCBUF:	DW	DTBUF
_KYBFX:	DB	KYBFX	;ｾﾝｺｳﾆｭｳﾘｮｸﾉｻｲﾀﾞｲﾓｼﾞｽｳ
_SEEKSP:DB	0	;ｼｰｸｽﾋﾟｰﾄﾞ
_LVER:	DB	VH,VL	;LAﾊﾞｰｼﾞｮﾝ
;
DMAD:	DB	$C3,$7D,$FB,$0F,$FF,$FF,$2C,$10		;X1turbo
	DB	$80,$92,$8D,$00,$00,$CF,$01,$CF		;DISK DMA
;
LWORKEND:
;
;	S-OS WORKS
;
	ORG	$1F5B
;
_MAXLN:	DB	MAXLN
_WIDTH:	DB	WIDTH
_DSK:	DB	"A"
_FATPS:	DW	1
_DIRPS:	DW	5
_FATBF:	DW	FATBF
_DTBUF:	DW	DTBUF
_MXTRK:	DB	40
_DIRNO:	DB	0	;No Use
_WKSIZ:	DW	WKSIZ
_MEMAX:	DW	MEMAX
_STKAD:	DW	STKAD
_EXADR:	DW	0
_DTADR:	DW	0
_SIZE:	DW	0
_IBFAD:	DW	FTYPE
_KBFAD:	DW	KBFAD
_XYADR:	DW	XYADR
_PRCNT:	DW	XYADR	;???
_LPSW:	DB	0	;No Use
_DVSW:	DB	"A"	;カレントドライブ
_USR:	DW	INIT
;
