/*

Interactive Nuclear Contour 2.0
this program let to draw easily from tablet, mouse or interactive board the contour fo Nuclei to estimate in a second step the number of BaseScope Staining per cell and nucleus.
This program is linked to the publication ...
contact : sebastien.schaub@imev-mer.fr
The program use the Action Bar from J.Mutterer: https://dx.doi.org/10.6084/m9.figshare.3397603.v3

Update : adapt to image from DICHisto Core
*/

var mydir="undef";
var myfile="undef";
var mycorename="undef";
var FinishedROI=true;
var StopNavigate=true;
var SelectedType=true;

var StrType=newArray("Nucleus","Weird");
var NType=newArray(0,0);
var MyCol=newArray("red","green");
var ExtraROI="Weird";
var IDRawImg=0;
var ButStep=0;
var Contrast="2x";
var ZoomMode="full";//["normal","full"]

var LImage=newArray("DAPI","DIC","RGB-Stain");
var PxlSzeRaw="6.5";
var MyMag="10x";
var ListMag=newArray("5x", "10x", "20x","40x","63x");
var ThickSlice=10;// Specific INC : the thickness of stack to keep

macro "Reboot [0]" {
	run("Close All");
	run("Install...", "install=["+getDirectory("macros")+"MICA\\Quantif_INC_v2r0.ijm]");
//	eval("js","IJ.getInstance().setLocation(192, 0);//IJ.getInstance().toBack();");
//	eval("js","IJ.getInstance().setLocation(0, 0);//IJ.getInstance().toFront();");
	run("ROI Manager...");
	roiManager("reset");
	print("\\Clear");
	print("[0] Reboot");
	print("[I] Import Image");
//	print("[1] Add New "+StrType[0]);
//	print("[2] Add New "+StrType[1]);
//	print("[3] Add New "+StrType[2]);
	print("[X] Remove Last ROI");
	print("[L] Load ROI");
	print("[S] Save ROI");
	print("[G] Global Analysis");	
	print("======================================");	
	print("contact : sebastien.schaub@imev-mer.fr");
	run("Action Bar","/plugins/ActionBar/INC_v2r0.txt");
	wait(50);
}


//======================================================================
// Sub macros
//======================================================================
macro "All in Front" {
//	eval("js","frame = WindowManager.getWindow('Log');if(frame!=undefined){frame.setSize(168, 300);frame.setLocation("+screenWidth-168+", 5);};");
//	eval("js","frame = WindowManager.getWindow('ROI Manager');if(frame!=undefined){frame.setSize(200, 350);frame.setLocation("+screenWidth-200+", 530);};");
//	eval("js","frame = WindowManager.getWindow('Channels');if(frame!=undefined){frame.setSize(200, 230);frame.setLocation("+screenWidth-200+", 880);};");
	if (nImages==0){
		eval("js","frame = WindowManager.getWindow('INC v2r0');frame.setSize(100, 400);frame.setLocation(0, 0);frame.toFront();");
	}
	eval("js","IJ.getInstance().setLocation(0, 0)");
}

//======================================================================
macro "Import Image [i]" {
	FinishedROI=true;
	
	while (nImages>0) { 
		selectImage(nImages); 
    	close(); 
	}
	open();
	mydir=getInfo("image.directory");
	myfile=getInfo("image.filename");
	roiManager("reset");
	run("Labels...", "color=black font=12 show use bold");
	roiManager("Show All with labels");
	
// Special INC : selectionne les plans à observer H1,H2,Lum,DAPI
	IDOrg=getImageID();
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.setChannel(1);
	run("Cyan");
	Stack.setChannel(2);
	run("Magenta");
	Stack.setChannel(4);
	run("Green");
	ValMed=getValue("Median");
	ValStD=getValue("StdDev");
	setMinAndMax(ValMed-0.5*ValStD, ValMed+5*ValStD);
	Stack.setChannel(3);
	ValMed=getValue("Median");
	ValStD=getValue("StdDev");
	ValMin=getValue("Min");
	ValMax=getValue("Max");
	run("Grays");	
	setMinAndMax(maxOf(ValMin,ValMed-3*ValStD), maxOf(ValMax,ValMed+3*ValStD));
	

//	run("Arrange Channels...", "new=125678");
	SetThickSlice();
	setLocation(190, 2, screenWidth-190, screenHeight-2);
	
	
	BackToSingleImage();
	run("Scale to Fit");
//	run("All in Front");
	setOption("DisablePopupMenu", true); 
	run("Global Analysis [g]");
	
	run("Select All");
//	setSlice(6);
//	getRawStatistics(nPixels, mean, min, max, std, histogram);
//	setMinAndMax(min, max*1.5);
	run("Select None");
//	run("Channels Tool...");
}

//======================================================================
// Selection macros
//======================================================================
macro "Select [s]" {
	FinishedROI=((nImages==0) | (toolID==12));
	if (FinishedROI) {
		waitForUser("Pas de selection");
		return;
	}
	setMetadata("Label", "SELECTING...");
	leftclick=16;
	noclick=0;
	rightclick=4;
	x0=0;
	y0=0;
	run("Select None");
	while (!FinishedROI){
		getCursorLoc(x, y, z, flags);
		if (flags==leftclick){
//On commence la ROI
			 xs = newArray(1);
			 ys = newArray(1);
			 xs[0]=x;
			 ys[0]=y;
			 while (flags==leftclick) {
	 			getCursorLoc(x, y, z, flags);
			    if ((x!=x0)||(y!=y0)) {
			    	xs = Array.concat(xs,x);
			     	ys = Array.concat(ys,y);
				    x0=x;y0=y;
			 	}
			 	wait(5);
			 }
			 if ((lengthOf(xs)>3) & (toolID!=12)){
				makeSelection ("freehand",xs,ys);
// on est ok
				SelectedType=false;
				run("Action Bar","/plugins/ActionBar/INC_Select_v2r0.txt");
				while(!SelectedType) {
					wait(50);
				}
				roiManager("Show All with labels");
				run("Labels...", "color=black font=12 show use bold");
			}
		}
		
		if (flags==rightclick) FinishedROI=true;
	}
	setMetadata("Label", "");
}

//======================================================================
macro "Add To Type I"{
	SelectedType=true;
	AddROI(0);
	while (isOpen('INC_Select_2r0')){
		eval("js","frame = WindowManager.getWindow('INC_Select_2r0');frame.close;")
	}
	SelectedType=true;
}
macro "Add To Type II"{
	AddROI(1);
	while (isOpen('INC_Select_2r0')){
		eval("js","frame = WindowManager.getWindow('INC_Select_2r0');frame.close;")
	}
	SelectedType=true;
}
macro "Redo Selection"{
	run("Select None");
	while (isOpen('INC_Select_2r0')){
		eval("js","frame = WindowManager.getWindow('INC_Select_2r0');frame.close;")
	}
	SelectedType=true;
	FinishedROI=true;
	run("Select [s]");
}macro "Cancel Selection"{
	run("Select None");
	while (isOpen('INC_Select_1r0')){
		eval("js","frame = WindowManager.getWindow('INC_Select_2r0');frame.close;")
	}
	SelectedType=true;
	FinishedROI=true;
	setTool("hand");
}
//========================================================================
function AddROI(iType){
	if (selectionType()!=-1) {
		roiManager("Add");
		wait(50);

		NROI=roiManager("count");

		roiManager("select",NROI-1);
		NType[iType]++;
//		roiManager("Rename", StrType[iType]+"-"+ NType[iType]);
		roiManager("Rename", StrType[iType]);
		roiManager("Set Color", MyCol[iType]);
		roiManager("Set Line Width", 3);
	}
	RecountROI();
	run("All in Front");
}
//========================================================================
function RecountROI(){
	NType=newArray(lengthOf(StrType));
	Array.fill(NType,1);
	NROI=roiManager("count");
	for (iROI=0;iROI<NROI;iROI++){
		TmpName=RoiManager.getName(iROI);
		for (iType=0;iType<lengthOf(StrType);iType++){
			TmpName2=StrType[iType]+"-"+ NType[iType];
			if (startsWith(TmpName,StrType[iType])){
				if (TmpName!=TmpName2){
					roiManager("select",iROI);
					roiManager("Rename", StrType[iType]+"-"+ NType[iType]);
				}
				NType[iType]=NType[iType]+1;
			}
		}		
	}
	roiManager("select",NROI-1);
}
//======================================================================
// ROI macros
//======================================================================
macro "Kill ROIs [k]" {
	FinishedROI=true;
	iROI=roiManager("index");
	NROI=roiManager("count");
	if ((iROI==-1) & (NROI>0)) {		
		roiManager("select",NROI-1);
		iROI=NROI-1;
	}
	if (NROI>0) {
	    k= call("ij.plugin.frame.RoiManager.getName", iROI);
		k1=indexOf(k,"-");
		
		Prefix=substring(k,0,k1);
		for (iType=0;iType<NType.length;iType++){
			if (Prefix==StrType[iType]) NType[iType]--;
		}
		NewIndex=parseFloat(substring(k,k1+1,lengthOf(k)));
		roiManager("Delete");
		NROI=roiManager("count");
	
		for (i1=iROI;i1<NROI;i1++){
			roiManager("select",i1);
		    k= call("ij.plugin.frame.RoiManager.getName", i1);
			TestPre=substring(k,0,lengthOf(Prefix));
			if (Prefix==TestPre) {
				roiManager("Rename", Prefix+"-"+NewIndex);
				NewIndex++;			
			}
		}
	}
	run("All in Front");
	wait(50);
	roiManager("Show All with labels");
	run("Labels...", "color=black font=12 show use bold");
}
macro "Save ROI [s]" {
	FinishedROI=true;
	mycorename=FnCoreName();
	roiManager("Save", mydir+"\\"+mycorename+"ROI.zip");	
//	print("ROI saved");
	run("All in Front");
}

macro "Load ROI [l]" {
	FinishedROI=true;
	mycorename=FnCoreName();
	roiManager("reset") ;
//	roiManager("Open", mydir+"\\"+mycorename+"ROI.zip");
	roiManager("Open", mydir+"\\ROI.zip");
	NROI=roiManager("Count");
	NType=Array.fill(NType,0);
	for (i1=0;i1<NROI;i1++){
		roiManager("select",i1);
	    MyLabel= call("ij.plugin.frame.RoiManager.getName", i1);	    
		for (iType=0;iType<NType.length;iType++){
			mn=minOf(lengthOf(MyLabel),lengthOf(StrType[iType]));
			if (substring(MyLabel,0,mn)==substring(StrType[iType],0,mn)) {
				NType[iType]++;
				roiManager("Rename", StrType[iType]+"-"+NType[iType]);
				Roi.setStrokeColor(MyCol[iType]);
				Roi.setStrokeWidth(5);
			}
		}
	}
//	print("ROI loaded");
	roiManager("Show All with labels");
	wait(50);
	run("Labels...", "color=black font=12 show use bold");
	run("All in Front");
}

function FnCoreName(){	
	k1=lastIndexOf(myfile,'.');
	k2=substring(myfile,0,k1);
	return k2;
}
//======================================================================
// macros ZOOM
//======================================================================

macro "ZoomPlus"{
	BackToSingleImage();
	selectImage(IDRawImg);
	RawImgName=getTitle();
	myzoom=getZoom();
//	waitForUser(myzoom);
	getLocationAndSize(x0, y0, w0, h0);
//i	waitForUser(x0+"/"+ y0+"/"+ w0+"/"+ h0);
	run("Set... ", "zoom="+round(myzoom*200)+" width="+w0+" height="+h0);
//	BackToSingleImage();
}
macro "ZoomMinus"{
	BackToSingleImage();
	selectImage(IDRawImg);
	RawImgName=getTitle();
	myzoom=getZoom();
//	waitForUser(myzoom);
	getLocationAndSize(x0, y0, w0, h0);
//	print(x0+"-"+x0+" / "+w0+"-"+h0);
	run("Set... ", "zoom="+round(myzoom*50)+" width="+w0+" height="+h0);
//	print(x0+"-"+x0+" / "+w0+"-"+h0);
//	setLocation(x0, y0, w0, h0);
//	print(x0+"-"+x0+" / "+w0+"-"+h0);
//	getLocationAndSize(x1, y1, w1, h1);
//	if ((w1!=w0)|(h1!=h0)) {
//		setLocation(x0, y0, w0, h0);
//	}
	BackToSingleImage();
}

macro "ZoomReset"{
	BackToSingleImage();
}
macro "ZoomNormal"{
	ZoomMode="normal";//["normal","full"]
	BackToSingleImage();
}
macro "ZoomFull"{
	ZoomMode="full";//["normal","full"]
	BackToSingleImage();
}
macro "ZoomCancel"{
}
//macro "Navigate [N]"{
//	setTool("hand");
//}
macro "ZoomSelection"{
	// NON FONCTIONNEL
	run("Select None");
	setTool("freehand");
	FinishedROI=false;
	leftclick=16;
	noclick=0;
	rightclick=4;
	x0=0;
	y0=0;
	while (!FinishedROI){
		getCursorLoc(x, y, z, flags);
		if (flags==leftclick){
//On commence la ROI
			 xs = newArray(2);
			 ys = newArray(2);
			 xs[0]=x;
			 ys[0]=y;
			 while (flags==leftclick) {
	 			getCursorLoc(x, y, z, flags);
			    if ((x!=x0)||(y!=y0)) {
			    	xs = Array.concat(xs,x);
			     	ys = Array.concat(ys,y);
				    x0=x;y0=y;
			 	}
			 	wait(5);
			 }
			 if ((lengthOf(xs)>1) & (toolID!=12)){
				FinishedROI=true;
				makeSelection ("freehand",xs,ys);
				run("To Selection");	
			}
		}
		if (flags==rightclick){
			FinishedROI=true;
		}
	}
	setMetadata("Label", "Navigating...");
	setTool("hand");
	run("Select None");
}

//======================================================================
function BackToSingleImage() {
// TODO : prévoir 2 modes : un FullScreen et un Normal
	for (i1=nImages;i1>0;i1--){
		selectImage(i1);
		if (getImageID!=IDRawImg) close();
	}
	selectImage(IDRawImg);
	RawImgName=getTitle();
	if (ZoomMode=="normal"){
		eval("js","frame = WindowManager.getWindow('Log');if(frame!=undefined){frame.setSize(168, 300);frame.setLocation("+screenWidth-168+", 5);};");
		eval("js","frame = WindowManager.getWindow('ROI Manager');if(frame!=undefined){frame.setSize(200, 350);frame.setLocation("+screenWidth-200+", 530);};");
		eval("js","frame = WindowManager.getWindow('Channels');if(frame!=undefined){frame.setSize(200, 230);frame.setLocation("+screenWidth-200+", 880);};");
		eval("js","IJ.getInstance().setLocation(0, 0);//IJ.getInstance().toFront();");
		eval("js","frame = WindowManager.getWindow('"+RawImgName+"');frame.setSize("+screenWidth-200+","+screenHeight-108+");frame.setLocation(0,108);frame.toFront();");
	}
	if (ZoomMode=="full"){
		eval("js","frame = WindowManager.getWindow('"+RawImgName+"');frame.setSize("+screenWidth-100+","+screenHeight+");frame.setLocation(0,0);frame.toFront();");
	}
//	eval("js","frame = WindowManager.getWindow('"+RawImgName+"');frame.setSize("+screenWidth-140+","+screenHeight-2+");frame.setLocation(2,2);frame.toFront();");

//	eval("js","IJ.getInstance().setLocation(192, 0);//IJ.getInstance().toBack();");
	
//	run("Scale to Fit");
}

//======================================================================
macro "Quit INC [q]" {
	FinishedROI=true;
	wait(50);
	if (nImages()>0) setOption("DisablePopupMenu", false);
	while (nImages>0) { 
		selectImage(nImages); 
    	close(); 
	}	
	run ("Close AB", "INC v2r0");	
}
//======================================================================
// Global Analysis
//======================================================================
macro "Global Analysis [g]"{
// PARAM
	MinArea=9;
	MinInt=10;
//======================================================================
//run ("Close AB", "INC v1r0");	
	IDOrg=getImageID();
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels("001100");
	roiManager("reset");
	run("Clear Results");
	run("Set Measurements...", "area integrated redirect=None decimal=3");
	if (File.exists(mydir+"\\StkOutMask.tif")) {
		open(mydir+"\\StkOutMask.tif");
		run("Create Selection");
		roiManager("Add");
		close();
		roiManager("Select", 0);
	}
	setTool("freehand");
	waitForUser("Keep previous gonad [OK]\n redraw gonad  [OK]\n No selection to cancel [OK]");
	if (selectionType()==-1) {
		return;
	}
	roiManager("reset");
	run("Clear Results");

	run("Create Mask");
	rename("MaskArea");
	//run("Divide...", "value=255");
	setMinAndMax(0, 4);
	getRawStatistics(FullArea);
	
	selectImage(IDOrg);
	Stack.setDisplayMode("grayscale");
	setSlice(1);
	setThreshold(MinInt, 65535);
	//run("Analyze Particles...", "size=9-Infinity show=Masks display clear add");
	run("Analyze Particles...", "size="+MinArea+"-Infinity show=Masks display add");
	rename("MaskCH1");
	//run("Divide...", "value=128");
	
	selectImage(IDOrg);
	setSlice(2);
	run("Restore Selection");
	setThreshold(MinInt, 65535);
	//run("Analyze Particles...", "size=9-Infinity show=Masks display clear add");
	run("Analyze Particles...", "size="+MinArea+"-Infinity show=Masks display add");
	rename("MaskCH2");
	//run("Divide...", "value=64");
	
	//imageCalculator("Add", "MaskArea","MaskCH1");
	//imageCalculator("Add", "MaskArea","MaskCH2");
	//close("MaskCH*");
	run("Merge Channels...", "c1=MaskArea c2=MaskCH1 c3=MaskCH2 create");
	rename("MaskArea");
	n=roiManager("count")-1;
	for (i=0;i<=n;i++){
		area=getResult("Area", i);
		radius=sqrt(area/3.14159);
		Volume=pow(radius,3)*4/3;
		setResult("Volume", i, Volume);
		LastName=RoiManager.getName(i);
		if (startsWith(LastName, "0001")){
			setResult("Channel", i, 1);
		}
		if (startsWith(LastName, "0002")){
			setResult("Channel", i, 2);
		}

	}
// Moyennes
	VolMean=newArray(2);
	IntMean=newArray(2);
	AreaMean=newArray(2);
	NObj=newArray(2);	
	for (i=0;i<nResults;i++){
		iCH=getResult("Channel", i);
		VolMean[iCH-1]=VolMean[iCH-1]+getResult("Volume", i);
		IntMean[iCH-1]=IntMean[iCH-1]+getResult("IntDen", i);
		AreaMean[iCH-1]=AreaMean[iCH-1]+getResult("Area", i);
		NObj[iCH-1]=NObj[iCH-1]+1;
	}
	n=nResults;
	for (i=0;i<=1;i++){
		VolMean[i]=VolMean[i]/NObj[i];
		IntMean[i]=IntMean[i]/NObj[i];
		AreaMean[i]=AreaMean[i]/NObj[i];
		setResult("Area", n+i, AreaMean[i]);
		setResult("IntDen", n+i, IntMean[i]);
		setResult("RawIntDen", n+i, NObj[i]/FullArea);
		setResult("Volume", n+i, VolMean[i]);
		setResult("Channel", n+i, i+1);
		setResult("Comment", n+i, "<Area>,<Int>,#Obj per pxl^2,<Volume>");
	}	
// Sauvegarde des images et données
	mycorename=FnCoreName();
	selectImage("MaskArea");
	saveAs("Tiff", mydir+"\\"+mycorename+"Mask.tif");
	close();
//	roiManager("Save", mydir+"\\"+mycorename+"ROI.zip");	
	saveAs("Results", mydir+"\\"+mycorename+"Global.csv");
	selectImage(IDOrg);
	roiManager("reset");

	Stack.setDisplayMode("composite");
	Stack.setActiveChannels("111000");
}

//======================================================================
function "Snapshot"{
	mycorename=FnCoreName();
	saveAs("Jpeg", mydir+"\\"+mycorename+".jpg");
}

//======================================================================
// Other Function
//======================================================================
function SetThickSlice(){
// Help to find start for ThickSlice
	Stack.getDimensions(width, height, channels, n, frames) 
	ThickSlice=minOf(n,ThickSlice);
	LStd=newArray(n);
	LZ=newArray(n);
	for (i=1;i<=n;i++){// get Std Image par slice
		setSlice(i);
		getRawStatistics(nPixels, k1,k2,k3, LStd[i-1]);
	}
	print(n);
	print(ThickSlice);
	LBest=newArray(n-ThickSlice);
	for (i=0;i<n-ThickSlice;i++){// get mean of Std per ThickSlice
		LTmp=Array.slice(LStd,i,i+ThickSlice);
		Array.getStatistics(LTmp, k1, k2, LBest[i]);
		print(i+"-"+LBest[i]);
	}
	k=Array.findMaxima(LBest,0);
	BestStart=k[0];
	BestEnd=BestStart+ThickSlice-1;
	Title2Trash=getTitle();
	run("Make Substack...", "channels=1-6 slices="+BestStart+"-"+BestEnd);
	run("Z Project...", "projection=[Average Intensity]");
	IDRawImg=getImageID();
	close(Title2Trash);
	
}

