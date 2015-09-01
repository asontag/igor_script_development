pro writeigorbinary, WroteIt, Var, WaveName, $  WAVENOTE = WaveNote, WAVESCALEA = WaveScaleA, WAVESCALEB = WaveScaleB, $  FILEPATH = FilePath, TIMEFLAG = TimeFlag;; DMM 20010102;  Writes version 5 IGOR binary waves from inside IDL;  does not support all the functions of IGOR binary waves.;;  returns a 1 or 0 in WroteIt to tell if it tried to write file;  Var is an IDL array of dimension 1 to 4;  WaveName is a string to contain the name of the IGOR wave (and of the file);; supported:;    lots of data types (float, double, long, complex, ...);    multi-dimensional waves;    wave note;    string waves;    creation date (modification date set equal to creation date);; not supported:;   data units;   dimension units;   extended data units;   extended dimension units;   wave dependency formula;;; WaveScaleA and WaveScaleB should be vectors with the;   number of elements equal to the number of dimensions of Var;; The WaveName is not checked for legal characters or to see if it is a legal IGOR name;; Don't guarantee that this works for weird combinations (e.g. multidimensional string waves...) ;WroteIt = 0LBinHeader5 = { $  versionsum: INTARR(2), $    ; Version number for backwards compatibility.                              ; Checksum over this header and the wave header.                              ; (combine these to get a 4 byte unit)  wfmSize: 0L, $       ; The size of the WaveHeader5 data structure plus the wave data.  formulaSize: 0L, $          ; The size of the dependency formula, if any.  noteSize: 0L, $             ; The size of the note text.  dataEUnitsSize: 0L, $       ; The size of optional extended data units.  dimEUnitsSize: LONARR(4), $ ; The size of optional extended dimension units.  dimLabelsSize: LONARR(4), $ ; The size of optional dimension labels.  sIndicesSize: 0L, $         ; The size of string indicies if this is a text wave.  optionsSize: LONARR(2)}     ; Reserved. Write zero. Ignore on read.    ; 64 bytes;; Have to break up WaveHeader5 and restructure it a bit so that it is all;  in 4 byte units or explicit variables: otherwise can't depend on IDL;  not to change size with byte alignment.;WaveHeader5 = { $  next: 0L, $               ; link to next wave in linked list.  creationDate: ULONG(0), $ ; DateTime of creation.  modDate: ULONG(0), $      ; DateTime of last modification.  npnts: 0L, $              ; Total number of points (multiply dimensions up to first zero).  typeDlock: INTARR(2)}     ; See types (e.g. NT_FP64) above. Zero for text waves.                            ; dlock Reserved. Write zero. Ignore on read.  ; {20 bytes}                            whpad1= BYTARR(6)           ; Reserved. Write zero. Ignore on read. {26 bytes}whVersion = 1S              ; Write 1. Ignore on read. {28 bytes}WaveHeader5B = { $  bname: BYTARR(31+1), $    ; Name of wave plus trailing null. {60 bytes}  whpad2:0L, $              ; Reserved. Write zero. Ignore on read.  dFolder:0L, $             ; Used in memory only. Write zero. Ignore on read.  {68 bytes}  ; Dimensioning info. [0] == rows, [1] == cols etc  nDim:LONARR(4), $         ; Number of of items in a dimension -- 0 means no data.  {84 bytes}  sfA: DBLARR(4), $         ; Index value for element e of dimension d = sfA[d]*e + sfB[d].  sfB: DBLARR(4), $         ;  {148 bytes}  ; SI units  dataUnits:BYTARR(3+1), $  ; Natural data units go here - null if none.  {152 bytes}  dimUnits:BYTARR(4,3+1), $ ; Natural dimension units go here - null if none.  {168 bytes}  fsValidWhpad3:INTARR(2), $  ; TRUE if full scale values have meaning.  {170 bytes}                              ; Reserved. Write zero. Ignore on read.  {172 bytes}  topFullScale:0D, $  botFullScale:0D, $        ; The max and max full scale value for wave.  {188 bytes}  ; the rest of the IGOR header structure is all reserved with instructions to write zeros.  EndReserved: BYTARR(132)} ;   {320 bytes}SizeData = SIZE(Var)VarDim = SizeData[0]IF VarDim LT 1 THEN BEGIN  PRINT,'Array dimension less than 1 in WriteIgorBinary  RETURN  ; WroteIt is still zero!ENDIFIF VarDim GT 4 THEN BEGIN  PRINT,'Array dimension greater than 4 in WriteIgorBinary  RETURN  ; WroteIt is still zero!ENDIFVarType = SIZE(Var, /Type)StringFlag = 0CASE VarType OF  0: BEGIN    PRINT,'Bad Variable Type'    RETURN  END   7: BEGIN  ; string    StringFlag = 1    StrLens = STRLEN(Var)    StrPositions = LONG(TOTAL(StrLens,/CUM))    IgorType = 0  END   8: BEGIN    PRINT,'Cannot support structure variable type'    RETURN  END   10: BEGIN    PRINT,'Cannot support pointer variable type'    RETURN  END   11: BEGIN     PRINT,'Cannot support object variable type'    RETURN  END   14: BEGIN     PRINT,'Cannot support 64 bit variable type'    RETURN  END   15: BEGIN     PRINT,'Cannot support U64 variable type'    RETURN  END   ELSE: BEGIN    IgorTypes = [0, 8, 16, 32, 2, 4, 3, 0, 0, 5, 0, 0, 64+16, 64+32, 0, 0]    BytesPer =  [0L,1L,2L, 4L,4L,8L,8L,0L,0L,16L,0L,0L,   2L,    4L,0L,0L]     ;define NT_CMPLX 1		// Complex numbers.    ;define NT_FP32 2			// 32 bit fp numbers.    ;define NT_FP64 4			// 64 bit fp numbers.    ;define NT_I8 8			// 8 bit signed integer. Requires Igor Pro 2.0 or later.    ;define NT_I16 	0x10		// 16 bit integer numbers. Requires Igor Pro 2.0 or later.    ;define NT_I32 	0x20		// 32 bit integer numbers. Requires Igor Pro 2.0 or later.    ;define NT_UNSIGNED 0x40	// Makes above signed integers unsigned. Requires Igor Pro 3.0 or later.    IgorType = IgorTypes[VarType]  ENDENDCASE;; set up header;BinHeader5.VersionSum[0] = 5FileTime = ULONG(SYSTIME(1) +  ULONG(2082844800))  ; latter is DCode2Time('19700101')WaveHeader5.creationDate = FileTimeWaveHeader5.modDate = WaveHeader5.creationDateWaveHeader5.npnts = N_ELEMENTS(Var)WaveHeader5.typeDlock[0] = IgorType;; wave name;  trim leading and trailing spaces but other no checking of characters;TrimWaveName = STRTRIM(STRMID(WaveName,0,31),2)WaveHeader5B.bname[0L:STRLEN(TrimWaveName)-1L] = BYTE(TrimWaveName)WaveHeader5B.nDim[0L:VarDim-1L] = SizeData[1L:VarDim] IF KEYWORD_SET(WaveScaleA) THEN WaveHeader5B.sfA[0L:VarDim-1L] = DOUBLE(WaveScaleA) ELSE $  WaveHeader5B.sfA[0L:VarDim-1L] = 1.0EIF KEYWORD_SET(WaveScaleB) THEN WaveHeader5B.sfB[0L:VarDim-1L] = DOUBLE(WaveScaleB)IF StringFlag THEN BEGIN  BinHeader5.wfmsize = 320L+StrPositions[N_ELEMENTS(Var)-1L]  BinHeader5.sIndicesSize = 4L*N_ELEMENTS(Var)ENDIF ELSE BEGIN  BinHeader5.wfmsize = 320L+N_ELEMENTS(Var)*BytesPer[VarType]ENDELSE;; set up wave note; HaveNoteFlag = 0IF KEYWORD_SET(WaveNote) THEN BEGIN  NoteLen = STRLEN(WaveNote)  IF NoteLen GT 0 THEN BEGIN    ; pad notes to multiple of 8 bytes    NeedMore = 8-(NoteLen MOD 8)    IF NeedMore GT 0 THEN BEGIN      FOR iC = 0,NeedMore-1 DO WaveNote = WaveNote + ' '      NoteLen = NoteLen+NeedMore    ENDIF    BinHeader5.noteSize = LONG(NoteLen)    HaveNoteFlag = 1  ENDIFENDIFIF KEYWORD_SET(TimeFlag) THEN BEGIN  IF TimeFlag EQ 1 THEN WaveHeader5B.dataunits[0:2] = [BYTE('dat')]ENDIF;; write to disk;IF KEYWORD_SET(FilePath) THEN ThisFilePath = FilePath ELSE ThisFilePath = ''OPENW,OutLUN,ThisFilePath+TrimWaveName+'.ibw',/GET_LUN , MACTYPE = 'IGBW' WRITEU,OutLUN,BinHeader5,WaveHeader5,whpad1, whVersion, WaveHeader5B,VarIF HaveNoteFlag THEN WRITEU,OutLUN,WaveNoteIF StringFlag THEN WRITEU,OutLUN,StrPositionsCLOSE,OutLUN;; reopen file and read in header as integers to do checksum;OPENU,OutLUN,ThisFilePath+TrimWaveName+'.ibw'ArrForCheck = INTARR(192)READU,OutLUN, ArrForCheckCheckSum = 0SFOR i = 0,191 DO CheckSum = CheckSum+ArrForCheck(i) ; explicit loops keeps integer typePOINT_LUN,OutLUN,0LWRITEU,OutLUN,[5S,-CheckSum]  ; 5 is for version 5FREE_LUN,OutLUN;; finished;WroteIt = 1LRETURNEND