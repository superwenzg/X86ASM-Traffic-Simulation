DATAS SEGMENT
;*********************************
;		   MESS DATA PART
;*********************************
MESS1 DB 0DH,0AH,"Traffic Simulation V0.1 $"
MESS2 DB 0DH,0AH,"Press enter to start simulation $"
MESS3 DB 0DH,0AH,"WTF,the key is not enter. $"
MESSS DB 20 DUP(0)

;*********************************
;		   LINE DATA PART
;		1. 四条公路的路线画图起点
;		2. 图画中，两个矩阵的画图起点
;		3. 程序中，用于保存待写像素
;*********************************
LINES1_SX DW 250D
LINES1_SY DW 170D
LINES2_SX DW 250D
LINES2_SY DW 310D
LINES3_SX DW 390D
LINES3_SY DW 170D
LINES4_SX DW 390D
LINES4_SY DW 310D

;*********************************
;		   ROADM DATA PART
;		1. 两个矩形的像素起点
;		2. 矩形的长宽
;		3. 保持当前画图时矩形的当前坐标
;*********************************
ROADM1_SX DW 20D
ROADM1_SY DW 220D
ROADM2_SX DW 410D
ROADM2_SY DW 220D
ROADMX_L DW 210D
ROADMX_W DW 40D

;*********************************
;		LIGHT DATA PART[Matrix]
;*********************************
L1_SX DW 255D
L1_SY DW 165D
L2_SX DW 245D
L2_SY DW 300D
L3_SX DW 390D
L3_SY DW 175D
L4_SX DW 380D
L4_SY DW 310D

L4_L DW 5
L4_W DW 5

;*********************************
;	   LIGHT LOGIC DATA PART
;		1.GCNT: GREEN Count 
;		2.RCNT: RED Count
;		3.YCNT: YELLOW Count
;		4.STATE:
;       1.GR 2.Y
;		DES SHOW THE STATE OF THE Simulation
;		5.NSOREW:
;		THE LAST GREEN LIGHT OWS OWN BY NS OR EW
;*********************************
GRCNT DW 15
YCNT DW 10

L1_COLOR DB 0AH ;GR
L2_COLOR DB 04H ;RD
L3_COLOR DB 04H ;RD
L4_COLOR DB 0AH	;GR

STATE DW 1
NSOREW DW 1

;*********************************
;		  CAR DATA PART
;			1. Each X,Y Point
;			2. Each Cars States
;			3. All Cars Number
;			4. The Max Number: 5
;*********************************
STNX DW 350,350,350
STNY DW 340,360,380
STNS DW 5 DUP (?)
STNN DW 3

NTSX DW 280,280,280
NTSY DW 140,120,100
NTSS DW 5 DUP (?)
NTSN DW 3

WTEX DW 100,120,140
WTEY DW 280,280,280
WTES DW 5 DUP (?)
WTEN DW 3

ETWX DW 400,420,440
ETWY DW 190,190,190
ETWS DW 5 DUP (?)
ETWN DW 3

;*********************************
;	  UNIVERSE CAR STATE DATA PART
;		1. COLOR THAT SHOULD FOLLOW
;		2. CARSTATE POINER
;		3. CARPOSITION POINTER
;		4. CAR RUNNING BOUNDRY
;		5. CAR NUMBER
;*********************************
N_COLOR DB ?
CARS_P DW ?
CARP_P DW ?
CARR_B DW ?
CAR_N DW ?

;*********************************
;	CAR INTIAL POS DATA PART
;		1. CONST CAR POSITION
;		2. CAR RUNNING POSITION
;		3. CONST CAR POSTION NUMBER
;		4. CAR POSTION CROSSING NUMBER
;*********************************
CCAR_P DW ?
CARR_P DW ?
CONST_N DW ?
CAR_C DW ?

;*********************************
;		Drawing DATA PART
;*********************************
COLOR DB ?
BKCOLOR DB 00H
YLCOLOR DB 0EH
GRCOLOR DB 0AH
RDCOLOR DB 04H
WHCOLOR DB 0FH

MATRIX1_SX DW ?
MATRIX1_SY DW ?
MATRIXX_L DW ?
MATRIXX_W DW ?

PIXELW_X DW ?
PIXELW_Y DW ?

;*********************************
;		 OTHER DATA PART
;*********************************
RRES DB ?
RANGE DB ?
;********OTHER DATA PART**********

DATAS ENDS

STACKS SEGMENT
	DW 100 DUP(0)
STACKS ENDS

CODES SEGMENT
	ASSUME CS:CODES, DS:DATAS, SS:STACKS

START:
;*********************************
;			INITIAL PART
;*********************************
	MOV AX,STACKS
	MOV SS,AX

	MOV AX,DATAS
	MOV DS,AX

;**********INITIAL PART***********

;*********************************
;			Main Part
;	1.MSS PART
;	2.DRAWING PART
;	3.LOGIC PART
;*********************************
;************PART 1***************
	MOV DX, offset MESS1
	CALL MESS_S
	MOV DX, offset MESS2
	CALL MESS_S
	CALL MESS_INPUT

;************PART 2***************
	CALL SETMODE
	CALL LINES_D
	CALL ROADM_D
	CALL LIGHT_D

;************PART 3***************
	CALL SIM

	CALL PROCESS_END
;**********MAIN PART**************



;*********************************
;			MSS_SHOW PART
;	 usage:Mov Mss Into DX Reg
;*********************************
MESS_S PROC NEAR
	PUSH AX
	MOV AH, 9h
	INT 21H
	POP AX
	ret
MESS_S ENDP
;**********MSS_SHOW PART**********

;*********************************
;			MSS_INPUT PART
;*********************************
MESS_INPUT PROC NEAR
	PUSH AX
	PUSH DX

	MESS_i:
		MOV AH, 1h
		INT 21H

		CMP AL,0DH
		JE MESS_r
		JNE MESS_e

	MESS_e:
		MOV DX,offset MESS3
		CALL MESS_S
		JMP MESS_i

	MESS_r:	
		POP DX
		POP AX
		RET
MESS_INPUT ENDP
;*********MSS_INPUT PART**********

;*********************************
;	  INT10H MODE SETTING PART
;*********************************
SETMODE PROC NEAR
	PUSH AX
	MOV AL,12H
	MOV AH,0H
	INT 10H
	POP AX
	RET
SETMODE ENDP
;****INT10H MODE SETTING PART*****

;*********************************
;		PIXEL Drawing Part
;		usage:
;		1.MOV Color Data INTO COLOR
;		2.Mov the Pixel Data Into
;		  PIXELW_X and PIXELW_Y
;*********************************
PIXEL_D PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX

	MOV AL, COLOR
	MOV BH, 00H
	MOV CX, PIXELW_X
	MOV DX, PIXELW_Y

	MOV AH, 0CH
	INT 10H

	POP DX
	POP CX
	POP BX
	POP AX
	RET
PIXEL_D ENDP
;*******PIXEL Drawing Part********


;*********************************
;		 Lines Drawing Part
;		   CX = x, DX = y
;*********************************
LINES_D PROC NEAR
	PUSH AX
	PUSH CX
	PUSH DX

	MOV AL, WHCOLOR
	MOV COLOR, AL

	;第一线条画线部分
	MOV CX, 0
	L1_S:
	MOV PIXELW_X, CX
	MOV DX, LINES1_SY
	MOV PIXELW_Y, DX
	CALL PIXEL_D
	MOV DX, LINES2_SY
	MOV PIXELW_Y, DX
	CALL PIXEL_D
	INC CX
	CMP CX,LINES1_SX
	JNA L1_S
	
	;第二线条画线部分
	MOV CX, 640
	L2_S:
	MOV PIXELW_X, CX
	MOV DX, LINES3_SY
	MOV PIXELW_Y, DX
	CALL PIXEL_D
	MOV DX,LINES4_SY
	MOV PIXELW_Y, DX
	CALL PIXEL_D
	DEC CX
	CMP CX, LINES3_SX
	JA L2_S

	;第三线条画线部分
	MOV DX, 0
	L3_S:
	MOV PIXELW_Y, DX
	MOV CX, LINES1_SX
	MOV PIXELW_X, CX
	CALL PIXEL_D
	MOV CX, LINES3_SX
	MOV PIXELW_X, CX
	CALL PIXEL_D
	INC DX
	CMP DX, LINES1_SY
	JNA L3_S

	;第四线条画线部分
	MOV DX, 480
	L4_S:
	MOV PIXELW_Y, DX
	MOV CX, LINES2_SX
	MOV PIXELW_X, CX
	CALL PIXEL_D
	MOV CX, LINES4_SX
	MOV PIXELW_X, CX
	CALL PIXEL_D
	DEC DX
	CMP DX, LINES2_SY
	JA L4_S

	POP DX
	POP CX
	POP AX
	RET
LINES_D ENDP
;********Lines Drawing Part*******

;*********************************
;		 Matrix Padding Part
;		   CX = x, DX = y
;		 usage:
;		1. SX INTO MATRIXSX
;		2. SY INTO MATRIXSY
;		3. W INTO MATRIXX_W
;		4. L INTO MATRIXX_L
;		5. Color INTO COLOR
;*********************************
MATRIX_P PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	MOV CX, MATRIX1_SX
	MOV DX, MATRIX1_SY

	MOV AX, MATRIXX_L
	ADD  AX, CX
	MOV BX, MATRIXX_W
	ADD BX, DX

	;调用像素填充函数，进行色彩逐像素填充
	P:
	P1:
		MOV PIXELW_X, CX
		MOV PIXELW_Y, DX
		CALL PIXEL_D
		INC DX
		CMP DX, BX
		JNA P1
		INC CX
		MOV DX, MATRIX1_SY
		CMP CX, AX
		JNA P 
	POP DX
	POP CX
	POP BX
	POP AX
	RET
MATRIX_P ENDP
;******Martix Color Padding*******

;*********************************
;		 Matrix Drawing Part
;		   CX = x, DX = y
;		 usage:
;		1. SX INTO MATRIXSX
;		2. SY INTO MATRIXSY
;		3. W INTO MATRIXX_W
;		4. L INTO MATRIXX_L
;*********************************
MATRIX_D PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX


	MOV AL, WHCOLOR
	MOV COLOR, AL


	MOV CX, MATRIX1_SX
	MOV DX, MATRIX1_SY
	MOV AX, MATRIX1_SY
	MOV BX, MATRIXX_W
	ADD AX, BX
	;绘制矩阵左宽
	M1_leftW:
		MOV PIXELW_X, CX
		MOV PIXELW_Y, DX
		CALL PIXEL_D

		INC DX
		CMP DX, AX
		JNA M1_leftW

		MOV AX, MATRIX1_SX
		MOV BX,	MATRIXX_L
		ADD AX, BX
	;绘制矩阵下长
	M1_downL:
		MOV PIXELW_X, CX
		MOV PIXELW_Y, DX
		CALL PIXEL_D

		INC CX
		CMP CX, AX
		JNA M1_DownL

		MOV AX, DX
		SUB AX, MATRIXX_W
	;绘制矩阵右宽
	M1_rightW:
		MOV PIXELW_X, CX
		MOV PIXELW_Y, DX
		CALL PIXEL_D

		DEC DX
		CMP DX, AX
		JNB M1_rightW

		MOV AX, CX
		SUB AX, MATRIXX_L
	;绘制矩阵上长
	M1_upL:
		MOV PIXELW_X, CX
		MOV PIXELW_Y, DX
		CALL PIXEL_D

		DEC CX
		CMP CX, AX
		JNB M1_upL
		POP DX
		POP CX
		POP BX
		POP AX
		RET
MATRIX_D ENDP
;*******Matrix Drawing Part*******

;*********************************
;		Roadm Drawing Part
;*********************************
ROADM_D PROC NEAR
	PUSH CX
		;调用矩阵绘制部分绘制道路矩形
		MOV CX, ROADMX_L
		MOV MATRIXX_L, CX
		MOV CX, ROADMX_W
		MOV MATRIXX_W, CX

		;绘制左矩阵
		MOV CX, ROADM1_SX
		MOV MATRIX1_SX, CX
		MOV CX, ROADM1_SY
		MOV MATRIX1_SY, CX
		CALL MATRIX_D

		;绘制右矩阵
		MOV CX, ROADM2_SX
		MOV MATRIX1_SX, CX
		MOV CX, ROADM2_SY
		MOV MATRIX1_SY, CX
		CALL MATRIX_D
	POP CX
	RET
ROADM_D ENDP
;*********************************

;*********************************
;		Light Drawing Part
;*********************************
LIGHT_D PROC NEAR
	PUSH CX
	MOV CX, L4_L
	MOV MATRIXX_L, CX
	MOV CX, L4_W
	MOV MATRIXX_W, CX

	;调用矩阵绘制功能函数
	;绘制1号交通灯
	MOV CX, L1_SX
	MOV MATRIX1_SX, CX
	MOV CX, L1_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_D

	;绘制2号交通灯
	MOV CX, L2_SX
	MOV MATRIX1_SX, CX
	MOV CX, L2_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_D

	;绘制3号交通灯
	MOV CX, L3_SX
	MOV MATRIX1_SX, CX
	MOV CX, L3_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_D

	;绘制四号交通灯
	MOV CX, L4_SX
	MOV MATRIX1_SX, CX
	MOV CX, L4_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_D
	POP CX
	RET
LIGHT_D ENDP
;*******Light Drawing Part********

;*********************************
;	  LIGHT COLOR PADDING PART
;		1. SX INTO MATRIXSX
;		2. SY INTO MATRIXSY
;		3. W INTO MATRIXX_W
;		4. L INTO MATRIXX_L
;		5. Color INTO COLOR
;*********************************
LIGHT_CP PROC NEAR
	PUSH CX
	MOV CX, L4_L
	MOV MATRIXX_L, CX
	MOV CX, L4_W
	MOV MATRIXX_W, CX

	;调用色彩填充部分
	;填充一号交通灯
	MOV CL, L1_COLOR
	MOV COLOR, CL
	MOV CX, L1_SX
	MOV MATRIX1_SX, CX
	MOV CX, L1_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_P

	;填充二号交通灯
	MOV CL, L2_COLOR
	MOV COLOR, CL
	MOV CX, L2_SX
	MOV MATRIX1_SX, CX
	MOV CX, L2_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_P

	;填充三号交通灯
	MOV CL, L3_COLOR
	MOV COLOR, CL
	MOV CX, L3_SX
	MOV MATRIX1_SX, CX
	MOV CX, L3_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_P

	;填充四号交通灯
	MOV CL, L4_COLOR
	MOV COLOR, CL
	MOV CX, L4_SX
	MOV MATRIX1_SX, CX
	MOV CX, L4_SY
	MOV MATRIX1_SY, CX
	CALL MATRIX_P
	POP CX
	RET
LIGHT_CP ENDP
;*****LIGHT COLOR PADDING PART****

;*********************************
;		Simulation PART
;*********************************
SIM PROC NEAR
	PUSH CX
	MOV CX, 0040H
	;CALL CAR_I
	CALL CAR_D

	;模拟循环部分
	S_RE:
	;道路清屏函数功能调用
	CALL CLEAR_R
	;延时功能调用
	CALL TIME_D
	;交通灯倒计时功能调用	
	CALL LIGHT_CA
	;交通灯色彩填充部分
	CALL LIGHT_CP
	;小车状态更新部分
	CALL CAR_S
	;小车运行部分
	CALL CAR_R
	;小车画图部分
	CALL CAR_D
	LOOP S_RE
	POP CX
	RET
SIM ENDP
;*******Simulation PART***********

;*********************************
;		LIGHT CNT ACTION
;*********************************
LIGHT_CA PROC NEAR
	PUSH CX

	;状态标记变量
	;若STATE为1，意味当前状态为红绿灯;为2，则当前状态为黄灯;
	MOV CX, STATE
	CMP CX, 1
	JE LGREEN
	CMP CX, 2
	JE LYELLOW

	LGREEN:
		MOV CX, GRCNT
		DEC CX
		MOV GRCNT, CX
		CMP CX, 0
		JNE LIGHT_COVERR
		;若绿灯倒计时完毕
		;初始化红绿灯倒计时变量，更新状态变量为2，进入黄灯状态
		MOV CX, 2
		MOV STATE, CX
		MOV CX, 10
		MOV GRCNT, CX

		;刷新所有灯变更为黄灯
		MOV CL, YLCOLOR
		MOV L1_COLOR, CL
		MOV L2_COLOR, CL
		MOV L3_COLOR, CL
		MOV L4_COLOR, CL
	LIGHT_COVERR:
		JMP LIGHT_COVER
		
	LYELLOW:
		MOV CX, YCNT
		DEC CX
		MOV YCNT, CX
		CMP CX, 0
		JNE LIGHT_COVER

		;黄灯状态结束，初始化黄灯倒计时变量，刷新变量为1，进入红绿灯状态
		MOV CX, 1
		MOV STATE, CX
		MOV CX, 5
		MOV YCNT, CX

		;根据最后绿灯标记变量，选择下一通行方向
		MOV CX, NSOREW
		CMP CX, 1
		JE NS
		JMP EW

		;若选择方向为南北，则下一方向变量更新为2。
		;若选择方向为东西，则下一方向变量更新为1。
		NS:
			MOV CX, 2
			MOV NSOREW, CX
			MOV CL, GRCOLOR
			MOV L2_COLOR, CL
			MOV L3_COLOR, CL
			MOV CL, RDCOLOR
			MOV L1_COLOR, CL
			MOV L4_COLOR, CL
			JMP LIGHT_COVER
		EW:
			MOV CX, 1
			MOV NSOREW, CX
			MOV CL, GRCOLOR
			MOV L1_COLOR, CL
			MOV L4_COLOR, CL
			MOV CL, RDCOLOR
			MOV L2_COLOR, CL
			MOV L3_COLOR, CL
	LIGHT_COVER:
	POP CX
	RET
LIGHT_CA ENDP
;*******LIGHT CNT ACTION**********

;*********************************
;		CAR INITIAL PART
;*********************************
CAR_I PROC NEAR
	CALL CARN_R
	CALL CARI_P
	RET
CAR_I ENDP
;*******CAR INITIAL PART**********

;*********************************
;		CAR NUMBER RAND PART
;*********************************
CARN_R PROC NEAR
	PUSH AX

	;随机生成汽车数量部分，有问题，因而未使用。
	MOV AL, 5
	MOV RANGE, AL

	CALL GET_R
	MOV AL, RRES
	XOR AH, AH
	MOV NTSN, AX

	CALL GET_R
	MOV AL, RRES
	XOR AH, AH
	MOV WTEN, AX

	CALL GET_R
	MOV AL, RRES
	XOR AH, AH
	MOV STNN, AX

	CALL GET_R
	MOV AL, RRES
	XOR AH, AH
	MOV ETWN, AX
	POP AX
	RET
CARN_R ENDP
;*******CAR NUMBER RAND PART**********

;*********************************
;		CAR INITIAL POS PART
;*********************************
CARI_P PROC NEAR
	PUSH AX
	PUSH SI
	
	;随机生成汽车坐标部分，有问题，因而未使用。
	;NTS
	MOV AX, NTSN
	MOV CAR_N, AX
	MOV AX, 280D
	MOV CONST_N, AX
	MOV AX, 0D
	MOV CAR_C, AX
	MOV SI, offset NTSX
	MOV CCAR_P, SI
	MOV SI, offset NTSY
	MOV CARR_P, SI
	MOV AL, 170D
	MOV RANGE, AL
	CALL CARSI_P

	;WTE
	MOV AX, WTEN
	MOV CAR_N, AX
	MOV AX, 280D
	MOV CONST_N, AX
	MOV AX, 0D
	MOV CAR_C, AX
	MOV SI, offset WTEY
	MOV CCAR_P, SI
	MOV SI, offset WTEX
	MOV CARP_P, SI
	MOV AL, 250D
	MOV RANGE, AL
	CALL CARSI_P

	;STN
	MOV AX, STNN
	MOV CAR_N, AX
	MOV AX, 350D
	MOV CONST_N, AX
	MOV AX, 310D
	MOV CAR_C, AX
	MOV SI, offset STNX
	MOV CCAR_P, SI
	MOV SI, offset STNY
	MOV CARP_P, SI
	MOV AL, 170D
	MOV RANGE, AL
	CALL CARSI_P

	;ETW
	MOV AX, ETWN
	MOV CAR_N, AX
	MOV AX, 190D
	MOV CONST_N, AX
	MOV AX, 380D
	MOV CAR_C, AX
	MOV SI, offset ETWY
	MOV CCAR_P, SI
	MOV SI, offset ETWX
	MOV CARP_P, SI
	MOV AL, 250D
	MOV RANGE, AL
	CALL CARSI_P

	POP SI
	POP AX
	RET
CARI_P ENDP
;*******CAR INITIAL POS PART******

;*********************************
;		CARS INITIAL POS PART
;		usage:
;		1. Put Car Number Into CAR_N
;		2. Put Const Position Into 
;			CONST_N
;		3. Put Car Run Crossing Into 
;			CAR_C
;		4. Put Car Const Postion 
;			Address Into CCAR_P
;		5. Put Car Running Position
;			Address Into CARR_P
;		6. Put Rand Range Into RANGE
;*********************************
CARSI_P PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DI
	PUSH SI

	;上升序随机生成汽车部分，有问题因而未使用。
	MOV AX, CONST_N
	MOV BX, CAR_C
	MOV CX, CAR_N
	MOV SI, CCAR_P

	IRE:
	MOV [SI], AX
	INC SI
	INC SI
	DEC CX
	CMP CX, 0
	JNE IRE

	MOV CX, CAR_N
	MOV SI, CARR_P
	MOV DI, CARP_P

	XOR AH, AH
	CALL GET_R
	MOV AL, RRES
	ADD AX, BX
	MOV [SI], AX
	INC SI
	INC SI

	IRGEA:
	CALL GET_R
	MOV AL, RRES
	MOV DI, CARP_P
	IRGE:
	CMP [DI], AX
	JE IRGEA
	INC DI
	INC DI
	CMP DI, SI
	JNE IRGE
	MOV DI, CARR_P
	MOV [SI], AX
	INC SI
	INC SI

	DEC CX
	CMP CX, 0
	JNE IRGEA


	POP SI
	POP DI
	POP CX
	POP BX
	POP AX
	RET
CARSI_P ENDP
;******CARS INITIAL POS PART******

;*********************************
;		CAR STATE PART
;		CAR STATE:
;		1. can pass
;		2. can't pass
;*********************************
CAR_S PROC NEAR
	;NTS
	PUSH CX
	PUSH SI

	;下降序随机生成汽车部分，有问题因而未使用。
	;NTS
	MOV CX, NTSN
	MOV CAR_N, CX
	MOV CX, L1_SY
	MOV CARR_B, CX
	MOV CL, L1_COLOR
	MOV N_COLOR, CL
	MOV SI, offset NTSY
	MOV CARP_P, SI
	MOV SI, offset NTSS
	MOV CARS_P, SI
	CALL CARS_IC

	;WTE
	MOV CX, WTEN
	MOV CAR_N, CX
	MOV CX, L2_SX
	MOV CARR_B, CX
	MOV CL, L2_COLOR
	MOV N_COLOR, CL
	MOV SI, offset WTEX
	MOV CARP_P, SI
	MOV SI, offset WTES
	MOV CARS_P, SI
	CALL CARS_IC

	MOV CX, STNN
	MOV CAR_N, CX
	MOV CX, L4_SY
	MOV CARR_B, CX
	MOV CL, L4_COLOR
	MOV N_COLOR, CL
	MOV SI, offset STNY
	MOV CARP_P, SI
	MOV SI, offset STNS
	MOV CARS_P, SI
	CALL CARS_DC

	MOV CX, ETWN
	MOV CAR_N, CX
	MOV CL, L3_COLOR
	MOV N_COLOR, CL
	MOV SI, offset ETWX
	MOV CARP_P, SI
	MOV SI, offset ETWS
	MOV CARS_P, SI
	CALL CARS_DC

	POP SI
	POP CX
	RET
CAR_S ENDP
;*********************************

;*********************************************
;		CAR STATE INCRE CHEACK PART
;		usage:
;		1.Put Car Determine State
;			Data Into CARS_P
;		2.Put Car Determine Pos Data
;			Into CARP_P
;		3.Put Light Color INTO N_COLOR
;		4.Put Car Number Data Into CAR_N
;		5.Put Car Running Boundry Into CARR_B
;*********************************************
CARS_IC PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	PUSH DI

	;汽车状态监察部分
	MOV AL, N_COLOR
	MOV BX, CARR_B
	MOV CX, CAR_N
	MOV SI, CARS_P
	MOV DI, CARP_P

	CMP AL, YLCOLOR
	JE IGRYL
	CMP AL, GRCOLOR
	JE IGRYL
	
	;判断当前交通灯灯色，若为绿黄灯直接通行。
	;设置所有汽车状态位为1.
	;若当前方向为红灯，判断汽车与边界位置对比。若超越边界位置，则让汽车通行。
	;意思就是，通过了汽车对应方向的交通灯的小车，不受交通灯管辖。
	IRD:
		CMP [DI], BX
		JNA IRDS
		MOV DX, 1D
		MOV [SI], DX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE IRD
		JE IRO
	IRDS:
		MOV DX, 2D
		MOV [SI], DX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE IRD
		JE IRO
	IGRYL:
		MOV DX, 1D
		MOV [SI], DX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE IGRYL
	IRO:
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX
	RET
CARS_IC ENDP
;***CAR STATE INCRE CHEACK PART***

;*********************************
;		CAR STATE DECRE CHEACK PART
;		usage:
;		1.put car determine State
;			DATA INTO CARS_P
;		2.put car determine pos Data
;			into CARP_P 
;*********************************
CARS_DC PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	PUSH DI

	;下降序汽车状态监察部分，基本逻辑与上方的上升序汽车状态监察部分基本一致。

	MOV AL, N_COLOR
	MOV BX, CARR_B
	MOV CX, CAR_N
	MOV SI, CARS_P
	MOV DI, CARP_P

	CMP AL, YLCOLOR
	JE DGRYL
	CMP AL, GRCOLOR
	JE DGRYL
	
	DRD:
		CMP [DI], BX
		JA DRDS
		MOV DX, 1D
		MOV [SI], DX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE DRD
		JE DRO
	DRDS:
		MOV DX, 2D
		MOV [SI], DX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE DRD
		JE DRO
	DGRYL:
		MOV DX, 1D
		MOV [SI], DX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE DGRYL

	DRO:
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX
	RET
CARS_DC ENDP
;***CAR STATE DECRE CHEACK PART***

;*********************************
;		   CAR RUN PART
;*********************************
CAR_R PROC NEAR
	PUSH AX
	PUSH CX
	PUSH DI
	PUSH SI

	;汽车运行函数
	MOV CX, NTSN
	MOV SI, offset NTSS
	MOV DI, offset NTSY

	;NTS
	;北到南方向汽车部分，判断标志位，若标志位为1则运动变量。此处为Y，加20
	NTSCAR_RRE:
		MOV DX, 1D
		CMP [SI], DX
		JE NTSRUN
		JMP NTSSTOP
		NTSRUN:
		MOV AX, [DI]
		CMP AX, 460
		JA NTSSTOP
		ADD AX, 20D
		MOV [DI], AX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE NTSCAR_RRE
		JE NTSCARR_O
		NTSSTOP:
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE NTSCAR_RRE
		JE NTSCARR_O

	NTSCARR_O:

	;WTE
	;西到东方向汽车部分，判断标志位，若标志位为1则运动变量。此处为X，加20
	MOV CX, ETWN
	MOV SI, offset WTES
	MOV DI, offset WTEX
	WTECAR_RRE:
		MOV DX, 1D
		CMP [SI], DX
		JE WTERUN
		JMP WTESTOP
		WTERUN:
		MOV AX, [DI]
		CMP AX, 620D
		JA WTESTOP
		ADD AX, 20
		MOV [DI], AX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE WTECAR_RRE
		JE WTECARR_O
		WTESTOP:
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE WTECAR_RRE
		JE WTECARR_O
	WTECARR_O:

	;STN
	;南到北方向汽车部分，判断标志位，若标志位为1则运动变量。此处为Y，减20
	MOV CX, STNN
	MOV SI, offset STNS
	MOV DI, offset STNY
	STNCAR_RRE:
		MOV DX, 1D
		CMP [SI], DX
		JE STNRUN
		JMP STNSTOP
		STNRUN:
		MOV AX, [DI]
		CMP AX, 20
		JB STNSTOP
		SUB AX, 20D
		MOV [DI], AX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE STNCAR_RRE
		JE STNCARR_O
		STNSTOP:
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE STNCAR_RRE
		JE STNCARR_O

	STNCARR_O:
	;ETW
	;北到南方向汽车部分，判断标志位，若标志位为1则运动变量。此处为X，减20
	MOV CX, ETWN
	MOV SI, offset ETWS
	MOV DI, offset ETWX
	ETWCAR_REE:
		MOV DX, 1D
		CMP [SI], DX
		JE ETWRUN
		JMP ETWSTOP
		ETWRUN:
		MOV AX, [DI]
		CMP AX, 20D
		JB ETWSTOP
		SUB AX, 20D
		MOV [DI], AX
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE ETWCAR_REE
		JE ETWCAR_O
		ETWSTOP:
		INC SI
		INC SI
		INC DI
		INC DI
		DEC CX
		CMP CX, 0
		JNE ETWCAR_REE
		JE ETWCAR_O
	ETWCAR_O:
	POP SI
	POP DI
	POP CX
	POP AX
	RET
CAR_R ENDP
;**********CAR RUN PART***********

;*********************************
;		CAR DRAWING PART
;		usage:
;
;*********************************
CAR_D PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DI
	PUSH SI

	;汽车画图部分
	;调用MATRIX_D功能函数，绘制小车。
	MOV CL, WHCOLOR
	MOV COLOR, CL
	MOV CX, 10
	MOV MATRIXX_W, CX
	MOV MATRIXX_L, CX	

	;NTS
	;北到南方向，若汽车Y坐标大于450，则不对汽车进行绘制。
	MOV AX, NTSN
	MOV SI, offset NTSX
	MOV DI, offset NTSY

	NTS_DRE:
	MOV BX, [SI]
	MOV MATRIX1_SX, BX
	MOV BX, [DI]
	MOV MATRIX1_SY, BX
	CMP BX, 450D
	JA NTSN_D
	CALL MATRIX_D
	NTSN_D:
	INC SI
	INC SI
	INC DI
	INC DI
	DEC AX
	CMP AX, 0
	JNE NTS_DRE

	;WTE
	;西到东方向，若汽车坐标X大于610，则不对汽车进行绘制。
	MOV AX, WTEN
	MOV SI, offset WTEX
	MOV DI, offset WTEY

	WTE_DRE:
	MOV BX, [SI]
	MOV MATRIX1_SX, BX
	CMP BX, 610D
	JA WTEN_D
	MOV BX, [DI]
	MOV MATRIX1_SY, BX
	CALL MATRIX_D
	WTEN_D:
	INC SI
	INC SI
	INC DI
	INC DI
	DEC AX
	CMP AX, 0
	JNE WTE_DRE

	;STN
	;南到北方向，若汽车坐标Y小于20，则不对汽车进行绘制。
	MOV AX, STNN
	MOV SI, offset STNX
	MOV DI, offset STNY

	STN_DRE:
	MOV BX, [SI]
	MOV MATRIX1_SX, BX
	MOV BX, [DI]
	CMP BX, 20D
	JB STNN_D
	MOV MATRIX1_SY, BX
	CALL MATRIX_D
	STNN_D:
	INC SI
	INC SI
	INC DI
	INC DI
	DEC AX
	CMP AX, 0
	JNE STN_DRE

	;ETW
	;东到西方向，若汽车坐标X小于20，则不对汽车进行绘制。
	MOV AX, ETWN
	MOV SI, offset ETWX
	MOV DI, offset ETWY

	ETW_DRE:
	MOV BX, [SI]
	MOV MATRIX1_SX, BX
	CMP BX, 20
	JB ETWN_D
	MOV BX, [DI]
	MOV MATRIX1_SY, BX
	CALL MATRIX_D
	ETWN_D:
	INC SI
	INC SI
	INC DI
	INC DI
	DEC AX
	CMP AX, 0
	JNE ETW_DRE

	POP SI
	POP DI
	POP CX
	POP BX
	POP AX
	RET
CAR_D ENDP
;*******CAR DRAWING PART**********

;*********************************
;		GET RAND NUMBER
; 		usage:
;		1. put range into range
;		2. res was puted into RRES
;*********************************
GET_R PROC NEAR
	PUSH AX
	PUSH CX
	PUSH DX

	;调用时间服务中断下的0号功能端口
	;获取随机数
	MOV AH,0 
	INT 1AH
	MOV AX,DX
	AND AH,3
	MOV DL,RANGE 
	DIV DL
	INC AH
	MOV RRES,AH

	POP DX
	POP CX
	POP AX
	RET
GET_R ENDP
;*******GET RAND NUMBER***********

;*********************************
;		CLEAR ROAD SCREEN
;*********************************
CLEAR_R PROC NEAR
	PUSH CX

	;道路清屏功能函数

	;使用黑色像素填充东西方向一号道路
	MOV CL, BKCOLOR
	MOV COLOR, CL
	MOV CX, 11D
	MOV MATRIX1_SX, CX
	MOV CX, 190D
	MOV MATRIX1_SY, CX
	MOV CX, 11D
	MOV MATRIXX_W, CX
	MOV CX, 640D
	MOV MATRIXX_L, CX
	CALL MATRIX_P

	;使用黑色像素填充东西方向二号道路
	MOV CX, 0D
	MOV MATRIX1_SX, CX
	MOV CX, 280D
	MOV MATRIX1_SY, CX
	MOV CX, 11D
	MOV MATRIXX_W, CX
	MOV CX, 630D
	MOV MATRIXX_L, CX
	CALL MATRIX_P

	;使用黑色像素填充南北方向一号道路
	MOV CX, 280D
	MOV MATRIX1_SX, CX
	MOV CX, 0D
	MOV MATRIX1_SY, CX
	MOV CX, 11D
	MOV MATRIXX_L, CX
	MOV CX, 470D
	MOV MATRIXX_W, CX
	CALL MATRIX_P

	;使用黑色像素填充南北方向二号道路
	MOV CX, 350D
	MOV MATRIX1_SX, CX
	MOV CX, 10D
	MOV MATRIX1_SY, CX
	MOV CX, 11D
	MOV MATRIXX_L, CX
	MOV CX, 470D
	MOV MATRIXX_W, CX
	CALL MATRIX_P

	POP CX
	RET
CLEAR_R ENDP

;*********************************
;		TIME DELAY PART
;*********************************
TIME_D PROC NEAR
	PUSH AX
	PUSH CX
	;时间延迟部分
	;使用循环进行延时
	;AX寄存器控制内循环
	;BX寄存器控制外循环
	MOV AX, 00000H
	MOV CX, 00FFFH
	T_re:
	T_ree:
	DEC AX
	CMP AX, 0
	JNE T_ree
	MOV AX,000FH
	LOOP T_re
	POP CX
	POP AX
	RET
TIME_D ENDP
;*********************************

;*********************************
;		    CLEAR SCREEN
;*********************************
CLEAR PROC NEAR 
	MOV 	BX,0 
	CLR1: 	MOV ES:[BX],AL		;ES中放的是显存的地址 
	INC		BX 
	CMP 	BX,9600H			;80*480 
	JNB 	CLR2 
	JMP	    CLR1 
	CLR2:   RET 
CLEAR   ENDP
;**********CLEAR SCREEN***********

;*********************************
;		PROCESS END PART
;*********************************
PROCESS_END PROC NEAR
	MOV AH,4CH
	INT 21H
PROCESS_END ENDP
;********PROCESS END PART**********
CODES ENDS
END START