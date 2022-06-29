function BatchDichysto
% Apply LocalWhitBalance & concatenate DAPI image in HiLF.tif file
% Hilf = Histo1,Histo2,Lum,DAPI

    Par=struct;
    Par.LocWB=3;% Number of measure for Local White Balance
    Par.ModalGray=128;% Set the modal gray value Luminosity
    Par.MedFilter=3;% Filter for Histo Map selection
    Par.ToShow=true; % To show intermediate results  
    
% NOT for control images
    Par.HueVal=[130,150;240,25];% Hue range per histo staining [cyan;magenta] 11.5
    Par.HueVal=[128,168;190,240];% Hue range per histo staining [cyan;magenta] 12.5
    Par.LumThresh=50;% Below Threshold, Histo is fixed =0
    Par.LumSlope=25;% 
    Par.SatThresh=30;% Below Threshold, no staining is considered, only luminance    
    Par.SatSlope=[200,100];% Slope per histo staining
    
% for control images
    Par.HueVal=[128,158;190,15];% Hue range per histo staining [cyan;magenta]
    Par.LumThresh=50;% Below Threshold, Histo is fixed =0
    Par.LumSlope=25;% 
    Par.SatThresh=30;% Below Threshold, no staining is considered, only luminance    
    Par.SatSlope=[150,80];% Slope per histo staining    
    
    selpath=uigetdir('F:\Noyau Elo\2022-02 - Copie\XX 11.5');    
    SubBatch(selpath,Par)
end

function SubBatch(tmppath,Par)
%[~,k]=fileparts(tmppath)
    LDir=dir(tmppath);
    i1=1;
    while i1<=length(LDir)
        if startsWith(LDir(i1).name,'.')
            LDir(i1)=[];
        else
            i1=i1+1;
        end
    end
    for i1=1:length(LDir)
        if LDir(i1).isdir
            SubBatch(fullfile(LDir(i1).folder,LDir(i1).name),Par)
        end
    end
    TreateFolder(tmppath,Par);
end

function TreateFolder(path,Par)
%% = Load RGB or create it as XYCZT========================================
    IsR=dir(fullfile(path,'*Trans Red*'));
    IsG=dir(fullfile(path,'*Trans Green*'));
    IsB=dir(fullfile(path,'*Trans Blue*'));
    IsCB=dir(fullfile(path,'*ColorCombine.tif*'));
    if ~isempty(IsR) && ~isempty(IsG) &&~isempty(IsB) && IsR.name(1)~='.'
       R=loadtiff(fullfile(IsR.folder,IsR.name)) ;
       G=loadtiff(fullfile(IsG.folder,IsG.name)) ;
       B=loadtiff(fullfile(IsB.folder,IsB.name)) ;
       Stk=permute(cat(4,R,G,B),[1,2,4,3]);
       clear R G B IsR IsG IsB
    end
    if ~isempty(IsCB)
        Stk=loadtiff(fullfile(IsCB.folder,IsCB.name)) ;
    end
    if ~exist('Stk','var')
        return
    end
    [~,currdir]=fileparts(path);
    disp(['Analyzing ',currdir,'...']);
    
%% = Get White Balance ====================================================
    StkProj=mean(double(Stk),4);
    if Par.ToShow
        figure(1);clf;
        Mx=median((double(StkProj(:))))/Par.ModalGray;
        subplot 231
            imshow(uint8(StkProj./Mx));
            title('Raw Image') 
            drawnow
        subplot 232
    end

    [StkProjWB,BGD]=LocalWhiteBalance(StkProj,Par.LocWB,1);
    StkWB=LocalWhiteBalance(Stk,Par.LocWB,1,BGD,Par.ToShow);
    if Par.ToShow
        subplot 232
            k=1./BGD;
            imshow(k./max(k(:)))
            title('Image inhomogeneity') 
        subplot 233
            imshow(uint8(double(StkProjWB)./Mx))
            title('Whit Balanced')
            drawnow
    end

%% = Get F-Histo ==========================================================

    [Histo,Lum,HistCol]=getFHisto(StkWB,Par);
    FluoCh=[];
    IsDAPI=dir(fullfile(path,'*DAPI*'));
    if ~isempty(IsDAPI)
        DAPI=permute(loadtiff(fullfile(IsDAPI.folder,IsDAPI.name)),[1,2,4,3]) ;
        Mx=max(DAPI(:));
        k=round(double(Mx)/256);
        DAPI=uint8(DAPI/k);
        FluoCh=DAPI;
    end
    IsMnKTS=dir(fullfile(path,'*-KTS*'));
    if ~isempty(IsMnKTS)
        MnKTS=permute(loadtiff(fullfile(IsMnKTS.folder,IsMnKTS.name)),[1,2,4,3]) ;
        Mx=5000;%fixed by default
        k=round(double(Mx)/256);
        MnKTS=uint8(MnKTS/k);
        
        if size(MnKTS,4)==size(FluoCh,4)
            FluoCh=cat(3,FluoCh,MnKTS);
        else
            IsMnKTS=[];
        end
    end
    StkOut=cat(3,Histo,Lum,FluoCh);
    imgFlRGB=[];
    if Par.ToShow
        ZMid=ceil(size(Lum,4)/2);
        subplot 234
        imshow(Lum(:,:,1,ZMid));
        title('Luminance')

        subplot 235
        imshow(HistCol);
        title('Histo Stainings')

        if ~isempty(IsDAPI)
            imgFlRGB=zeros([size(DAPI(:,:,1)),3],'uint8');
            imgFlRGB(:,:,2:3)=repmat(DAPI(:,:,1,ZMid),[1,1,2]);
        end
        if ~isempty(IsMnKTS)
            if isempty(ilgFlRGB)
                imgFlRGB=zeros([size(MnKTS(:,:,1)),3],'uint8');
            end
            imgFlRGB(:,:,1)=MnKTS(:,:,1,ZMid);
        end        
        subplot 236
        imagesc(imgFlRGB);
        axis image
        colormap(gca,'gray');
        title('DAPI')
        set(gca,'XTick',[],'YTick',[]);
        drawnow;
    end    
    if exist(fullfile(path,'StkOut.tif'),'file')
        delete(fullfile(path,'StkOut.tif'))
    end
    if exist(fullfile(path,'HiLF.tif'),'file')
        delete(fullfile(path,'HiLF.tif'))
    end
    bfsave(StkOut,fullfile(path,'HiLF.tif'),'dimensionOrder', 'XYCZT');
end

