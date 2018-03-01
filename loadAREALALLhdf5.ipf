﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function doALL(fnam)
	string fnam
	
	string efGRP = fnam[0,3]+"_ef"
	string rbsGRP = fnam[0,3]+"_rbs"
	string simmsGRP = fnam[0,3]+"_simms"
	string arealGRP = fnam[0,3]+"_arealF"
	getDATAhdf(fnam, efGRP,0)
	getDATAhdf(fnam, rbsGRP,0)
	getDATAhdf(fnam, simmsGRP,0)
	getDATAhdf(fnam, arealGRP,0)
	
	SetDataFolder simmsGRP
	Wave table_Ffloor_8682, table_Ffloor_8482, table_Ffloor_8382
	Wave table_Fshelf_8682, table_Fshelf_8482, table_Fshelf_8382
	Wave table_err_Fshelf_8682, table_err_Fshelf_8482, table_err_Fshelf_8382
	Wave table_err_Ffloor_8682, table_err_Ffloor_8482, table_err_Ffloor_8382
	Duplicate/O table_Ffloor_8682, Ffloor_AVG, Fshelf_AVG, err_Ffloor_AVG, err_Fshelf_AVG
	Ffloor_AVG = (table_Ffloor_8682 + table_Ffloor_8482 + table_Ffloor_8382)/3.
	Fshelf_AVG = (table_Fshelf_8682 + table_Fshelf_8482 + table_Fshelf_8382)/3.
	err_Fshelf_AVG = sqrt(table_err_Fshelf_8682^2 + table_err_Fshelf_8482^2 + table_err_Fshelf_8382^2)
	err_Ffloor_AVG = sqrt(table_err_Ffloor_8682^2 + table_err_Ffloor_8482^2 + table_err_Ffloor_8382^2)
	SetDataFolder ::
	
	string efPLOT_str = "EF_PLOT(\""+efGRP+"\",\""+fnam+"\")"
	Execute efPLOT_str
	
	string simmPLOT_str = "SIMMS_PLOT(\""+simmsGRP+"\")"
	Execute simmPLOT_str
	
	string arealPLOT_str = "AREALfrac_PLOT(\""+arealGRP+"\")"
	Execute arealPLOT_str
End

Function getDATAhdf(fnam, grpnam, quiet)
	string fnam
	string grpnam
	variable quiet
	
	string/G neuPath
	variable fileID
	
	PathInfo DropboxSIMMS
	if(V_flag == 0)
		makeDROPBOXpmi(neuPAth)
	endif
	String unixPath
	unixPath = ParseFilePath(5,S_path,"/",0,0)
	
	if(quiet == 1)
		print "Loading Data into IGOR"
		print "From:"+unixPath+fnam
	endif
	
	HDF5OpenFile/P=DropboxSIMMS/R/Z fileID as fnam
	HDF5LoadGroup/T/O/R/IGOR=-1 :, fileID, grpnam
	HDF5CloseFile/A/Z fileID
End
	
Function makeDROPBOXpmi(neuPATH)
   string neuPATH
   NewPath/Q/M="Made new IgorPro path to Dropbox SIMMS folder" DropboxSIMMS, neuPATH
End
   
Window EF_PLOT(efGRP, fnam)
	string efGRP
	string fnam
		PauseUpdate; Silent 1		// building window...
	SetDataFolder efGRP
	Display /W=(110,70,570,254)/T table_EF186,table_EF180,table_EF182,table_EF183,table_EF184 vs table_index
	ErrorBars/T=0/Y=1 table_EF186 Y,wave=(table_EF186err,table_EF186err)
	ErrorBars/T=0/Y=1 table_EF180 Y,wave=(table_EF180err,table_EF180err)
	ErrorBars/T=0/Y=1 table_EF182 Y,wave=(table_EF180err,table_EF180err)
	ErrorBars/T=0/Y=1 table_EF183 Y,wave=(table_EF183err,table_EF183err)
	ErrorBars/T=0/Y=1 table_EF184 Y,wave=(table_EF184err,table_EF184err)
	SetDataFolder ::
	ModifyGraph margin(left)=73,margin(bottom)=10,margin(top)=35,margin(right)=40
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph rgb(table_EF186)=(61680,58596,16962,32767),rgb(table_EF180)=(37522,0,0,26214)
	ModifyGraph rgb(table_EF182)=(0,28013,56283,26214),rgb(table_EF183)=(54741,24158,0,26214)
	ModifyGraph rgb(table_EF184)=(18761,0,37522,26214)
	ModifyGraph msize=2
	ModifyGraph mrkThick(table_EF186)=1,mrkThick(table_EF180)=0.25,mrkThick(table_EF182)=0.25
	ModifyGraph mrkThick(table_EF183)=0.25,mrkThick(table_EF184)=0.25
	ModifyGraph gaps=0
	ModifyGraph useMrkStrokeRGB=1
	ModifyGraph mrkStrokeRGB(table_EF186)=(61680,58596,16962),mrkStrokeRGB(table_EF180)=(37522,0,0)
	ModifyGraph mrkStrokeRGB(table_EF182)=(0,28013,56283),mrkStrokeRGB(table_EF183)=(54741,24158,0)
	ModifyGraph mrkStrokeRGB(table_EF184)=(18761,0,37522)
	ModifyGraph log(left)=1
	ModifyGraph tick=2
	ModifyGraph mirror=1
	ModifyGraph fSize=14
	ModifyGraph fStyle=1
	ModifyGraph lblMargin(left)=25
	ModifyGraph standoff=0
	ModifyGraph logHTrip(left)=1
	ModifyGraph logLTrip(left)=0.01
	ModifyGraph axisOnTop=1
	Label left "enrichment fractor, EF"
	Label top "probe distance [mm]"
	SetAxis left 0.0001,1
	string probeTXT= fnam[0,3]
	TextBox/C/N=text1/H=12/A=MC/X=40.00/Y=-37.50 "\\Z12\\f01probe\r\\Z16"+probeTXT
	TextBox/C/N=text1_1/LS=-1/F=0/H=12/A=MC/X=57.00/Y=44.00 "\\Z12\\f01W182"
	TextBox/C/N=text1_2/LS=-1/F=0/H=12/A=MC/X=57.00/Y=27.00 "\\Z12\\f01W186"
	TextBox/C/N=text1_3/LS=-1/F=0/H=12/A=MC/X=57.00/Y=33.00 "\\Z12\\f01W184"
	TextBox/C/N=text1_4/LS=-1/F=0/H=12/A=MC/X=57.00/Y=-5.00 "\\Z12\\f01W180"
	TextBox/C/N=text1_5/LS=-1/F=0/H=12/A=MC/X=57.00/Y=20.00 "\\Z12\\f01W183"
EndMacro
   
Window SIMMS_PLOT(simmsGRP)
	string simmsGRP
	
	PauseUpdate; Silent 1		// building window...
	SetDataFolder simmsGRP
	Display /W=(731,66,1339,482) Ffloor_AVG vs table_index
	AppendToGraph Fshelf_AVG vs table_index
	ErrorBars Ffloor_AVG SHADE= {0,0,(0,0,0,0),(0,0,0,0)},wave=(err_Ffloor_AVG,err_Ffloor_AVG)
	ErrorBars Fshelf_AVG SHADE= {0,0,(0,0,0,0),(0,0,0,0)},wave=(err_Fshelf_AVG,err_Fshelf_AVG)
	SetDataFolder ::
	ModifyGraph margin(left)=73,margin(bottom)=35,margin(top)=10,margin(right)=40
	ModifyGraph lSize(Ffloor_AVG)=2,lSize(Fshelf_AVG)=3
	ModifyGraph rgb(Ffloor_AVG)=(3077,24858,54102)
	ModifyGraph gaps=0
	ModifyGraph tick=2
	ModifyGraph mirror=1
	ModifyGraph noLabel(bottom)=2
	ModifyGraph fSize=14
	ModifyGraph fStyle=1
	ModifyGraph lblMargin(left)=25
	ModifyGraph standoff=0
	ModifyGraph axisOnTop=1
	Label left "SIMM fraction"
	SetAxis left -0.025,1.1
	SetAxis bottom*,102
	TextBox/C/N=text0/F=0/H=12/A=MC "\\Z18\\f01f\\Bfloor"
	TextBox/C/N=text1/F=0/H=12/A=MC "\\Z18\\f01f\\Bshelf"
EndMacro

Window AREALfrac_PLOT(arealFOLD)
	string arealFOLD
	
	PauseUpdate; Silent 1		// building window...
	SetDataFolder arealFOLD
	Display /W=(923,187,1440,746) table_arealFRAC_floor,table_arealFRAC_shelf vs table_frac_areal_rminrsep
	AppendToGraph/T table_arealFRAC_floor vs table_frac_areal_d_probe_mm
	ErrorBars/T=0/Y=1 table_arealFRAC_floor Y,wave=(table_err_arealFRAC_floor,table_err_arealFRAC_floor)
	ErrorBars/T=0/Y=1 table_arealFRAC_shelf Y,wave=(table_err_arealFRAC_shelf,table_err_arealFRAC_shelf)
	SetDataFolder ::
	ModifyGraph margin(left)=40,margin(bottom)=37,margin(top)=10,margin(right)=45
	ModifyGraph mode=3
	ModifyGraph marker(table_arealFRAC_floor#1)=23,marker(table_arealFRAC_floor)=23
	ModifyGraph marker(table_arealFRAC_shelf)=19
	ModifyGraph rgb(table_arealFRAC_floor#1)=(3307,27958,56280),rgb(table_arealFRAC_floor)=(3307,27958,56280)
	ModifyGraph rgb(table_arealFRAC_shelf)=(37469,0,673)
	ModifyGraph msize=4
	ModifyGraph gaps=0
	ModifyGraph useMrkStrokeRGB=1
	ModifyGraph mrkStrokeRGB=(65535,65535,65535)
	ModifyGraph tick=2
	ModifyGraph mirror(left)=1
	ModifyGraph noLabel(top)=2
	ModifyGraph fSize(left)=14,fSize(bottom)=14
	ModifyGraph fStyle(left)=1,fStyle(bottom)=1
	ModifyGraph standoff=0
	ModifyGraph prescaleExp(left)=-15
	ModifyGraph axisOnTop(bottom)=1
	ModifyGraph axisEnab(top)={0.115,1}
	Label left "\\Z12Fractional Areal Density [x10\\S15\\M\\Z12 atom/cm\\S2\\M\\Z12]"
	Label bottom "R - R\\Bsep \\M[cm]"
	SetAxis left -10000000000000,500000000000000
	SetAxis bottom 5,15.75
	SetAxis top 0,102
EndMacro

Window FULLLayout() : Macros
	PauseUpdate; Silent 1		// building window...
	NewLayout/W=(191,33,959,836)
	if (IgorVersion() >= 7.00)
		LayoutPageAction size=(612,792),margins=(18,18,18,18)
	endif
	ModifyLayout mag=1
	AppendLayoutObject/F=0/T=1/R=(36,36,360,252) Graph EF_PLOT
	AppendLayoutObject/F=0/T=1/R=(36,240,360,456) Graph SIMMS_PLOT
	AppendLayoutObject/F=0/T=1/R=(41,418,365,634) Graph AREALfrac_PLOT
EndMacro