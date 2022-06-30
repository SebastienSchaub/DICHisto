function StatDichysto(file, path)
    if file==0
        return;
    end

    %% block1
    

    par.PathName=path;
    par.CoreName=file(1:length(file)-8);

    Mask=loadtiff(fullfile(par.PathName,file));
    par.Sze=size(Mask);

    BFData=bfopen(fullfile(par.PathName,[par.CoreName,'.tif']));
    Stk=BuiltBFHStack(BFData);
    ZProj=squeeze(mean(Stk,4));%XYCT

    ZipFile=fullfile(par.PathName,'ROI.zip');
    if exist(ZipFile,'file')
        MyROI=ReadImageJROI(ZipFile);
        MyRegions=ROIs2Regions(MyROI,par.Sze(1:2));
    else
        MyROI=[];
    end
  

    MaskNucl=zeros(par.Sze(1:2),'uint16');
    IndNucl=1;
    MaskWeird=zeros(par.Sze(1:2),'uint16');
    IndWeird=1;
    for i1=1:length(MyROI)
        nucl=false(par.Sze(2:-1:1));
        nucl(MyRegions.PixelIdxList{i1})=true;
        nucl=nucl.';
        if ~isempty(strfind(MyROI{i1}.strName,'Nucleus'))
            MaskNucl(nucl)=IndNucl;
            IndNucl=IndNucl+1;
%             disp(['Nucl',num2str(i1)])
        elseif ~isempty(strfind(MyROI{i1}.strName,'Weird'))
            MaskWeird(nucl)=IndWeird;
            IndWeird=IndWeird+1;
        end
    end

    clear BFPData Stk IndNucl IndWeird
    %% Graphics 1
    if max(MaskNucl(:))>0
        mycol=MyColMap(max(MaskNucl(:)),'patchwork');
    else
        mycol=gray(3);
    end
    subplot 211
    imagesc(MaskNucl)
    colormap(gca,mycol)
    colorbar
    axis image

    if max(MaskWeird(:))>0
        mycol=MyColMap(max(MaskWeird(:)),'patchwork');
    else
        mycol=gray(3);
    end
    subplot 212
    imagesc(MaskWeird)
    axis image
    colorbar
    colormap(gca,mycol)

    drawnow;
    
    %% Block 2
    % STAT per nucl
    disp('Stat per nucl...');
    clear AllNucl;
    MaskGlobal=Mask(:,:,1)>0;
    MaskHisto1=Mask(:,:,2)>0;
    MaskHisto2=Mask(:,:,3)>0;
    t1=tic;t0=tic;
    for i1=1:length(MyROI)+3
        if i1<=length(MyROI)
            nucl=false(par.Sze(2:-1:1));
            nucl(MyRegions.PixelIdxList{i1})=true;
            nucl=nucl.';
        elseif i1==length(MyROI)+1
            nucl=MaskGlobal & (MaskNucl>0 | MaskWeird>0);
            subplot 131;imagesc(nucl);axis image;title('All Nuclei');
        elseif i1==length(MyROI)+2
            nucl=MaskGlobal & ~(MaskNucl>0 | MaskWeird>0);
            subplot 132;imagesc(nucl);axis image;title('All Cytoplasms');
        elseif i1==length(MyROI)+3
            nucl=MaskGlobal;
            subplot 133;imagesc(nucl);axis image;title('All Gonad');
        end
        
        if i1<=length(MyROI)
            test=~isempty(strfind(MyROI{i1}.strName,'Nucleus')) && all(MaskGlobal(nucl));
        else
            test=true;
        end
        
        if test
    % Test if in the Global ROI
            TmpNucl=struct('Name','','NDotScore',[],'AreaScore',[],'IntScore',[],'NDotBleu',[],'IntBleu',[],'AreaBleu',[],'NDotMagenta',[],'IntMagenta',[],'AreaMagenta',[],'DAPI',[],'Ind',[],'MaskArea',[]);
            TmpNucl.MaskArea=sum(nucl,'all');
            if TmpNucl.MaskArea>0
                if i1<=length(MyROI)
                    TmpNucl.Name=MyROI{i1}.strName;
                elseif i1==length(MyROI)+1
                    TmpNucl.Name='All Nuclei';
                elseif i1==length(MyROI)+2
                    TmpNucl.Name='All Cytoplasms';
                elseif i1==length(MyROI)+3
                    TmpNucl.Name='Gonad';
                end
                TmpNucl.Ind=i1;
                
                TmpMask=nucl&MaskHisto1;
                Stat=regionprops(TmpMask);
                TmpNucl.NDotBleu=length(Stat);
                k=ZProj(:,:,1);
                TmpNucl.IntBleu=sum(k(TmpMask));
                TmpNucl.AreaBleu=sum(k(TmpMask)>0);
                TmpMask=nucl&MaskHisto2;
                Stat=regionprops(TmpMask);
                TmpNucl.NDotMagenta=length(Stat);
                k=ZProj(:,:,2);
                TmpNucl.IntMagenta=sum(k(TmpMask));            
                TmpNucl.AreaMagenta=sum(k(TmpMask)>0);

    %             TmpNucl.NDotScore=round(100*TmpNucl.NDotBleu/(TmpNucl.NDotBleu+TmpNucl.NDotMagenta));
    %             TmpNucl.IntScore=round(100*TmpNucl.IntBleu/(TmpNucl.IntBleu+TmpNucl.IntMagenta));
    %             TmpNucl.AreaScore=round(100*TmpNucl.AreaBleu/(TmpNucl.AreaBleu+TmpNucl.AreaMagenta));
                TmpNucl.NDotScore=100*TmpNucl.NDotBleu/(TmpNucl.NDotBleu+TmpNucl.NDotMagenta);
                TmpNucl.IntScore=100*TmpNucl.IntBleu/(TmpNucl.IntBleu+TmpNucl.IntMagenta);
                TmpNucl.AreaScore=100*TmpNucl.AreaBleu/(TmpNucl.AreaBleu+TmpNucl.AreaMagenta);

                if size(ZProj,3)>=4
                    k=ZProj(:,:,4);
                else
                    k=ones(size(ZProj(:,:,1)),class(ZProj));
                end
                TmpNucl.DAPI=sum(k(nucl));
                if ~exist('AllNucl','var')
                    AllNucl=TmpNucl;
                else
                    AllNucl=cat(1,AllNucl,TmpNucl);
    %                 disp(TmpNucl.Name)
                end
            end
        end

        if toc(t1)>5
            disp([num2str(i1),'/',num2str(length(MyROI)),': ',num2str(toc(t0),2),'s']);
            t1=tic;
        end
    end
% Add the mask result in the table

    %% Colored Nucl
    disp('create colored images...');
    MaxSpot=max(cat(2,[AllNucl(:).NDotBleu],[AllNucl(:).NDotMagenta]));
    MaxInt=max(cat(2,[AllNucl(:).IntBleu],[AllNucl(:).IntMagenta]));
    ContourNuclA=zeros([par.Sze(1:2),3]);
    ContourNuclN=zeros([par.Sze(1:2),3]);
    ContourNucl0=false([par.Sze(1:2)]);
    ColoredNucl_Acont=zeros([par.Sze(1:2)]);%Area in continuous
    ColoredNucl_Ncont=zeros([par.Sze(1:2)]);%N Spot in continuous
    ColoredNucl_Icont=zeros([par.Sze(1:2)]);%Intensity in continuous
    AContCyan=zeros([par.Sze(1:2)]);%Absolute Area 
    AContMagenta=zeros([par.Sze(1:2)]);%Absolute Area
    
    mymap3=[0.5,0,0;1,0,0;1,0.5,0;1,1,0;0.5,1,0;0,1,0;0,.5,0];
    mymapcont=interp1(linspace(0,1,7),mymap3,linspace(0,1,255));
    mymapcont=cat(1,[0,0,0],mymapcont);
    
    mymap3=[1,0,1;1,.35,1;1,1,1;.65,1,1;0,1,1];
    mymapcont=interp1(linspace(0,1,length(mymap3)),mymap3,linspace(0,1,255));
    mymapcont=cat(1,[0,0,0],mymapcont);
%     imagesc(rand(10));colormap(gca,mymapcont);colorbar
    t1=tic;t0=tic;
    AllContour=false(par.Sze(1:2));
    for i1=1:length(AllNucl)-3 %-3 car les derniers sont les masques globaux
        nucl=false(par.Sze(2:-1:1));
        nucl(MyRegions.PixelIdxList{AllNucl(i1).Ind})=true;
        nucl=nucl.';
        if ~isempty(strfind(MyROI{i1}.strName,'Nucleus'))
    % Test if in the Global ROI
            if all(MaskGlobal(nucl))
                Dnucl=double(nucl);
                
                AC=AllNucl(i1).AreaBleu; %Area cyan
                AM=AllNucl(i1).AreaMagenta; % AreaMagenta
                AContCyan=max(AContCyan,(AC+1)*Dnucl);
                AContMagenta=max(AContMagenta,(AM+1)*Dnucl);

%                 [AC,AM,max(nucl,[],'all'),mean(AContCyan(nucl),'all'),mean(AContMagenta(nucl),'all')]
                ratioC_CM=AC/(AC+AM)*Dnucl;
                if ~isnan(ratioC_CM)
                    ColoredNucl_Acont=max(ColoredNucl_Acont,floor(ratioC_CM*size(mymapcont,1)));
                else
                    k=nucl-imerode(nucl,strel('disk',3,8));
                    ColoredNucl_Acont=max(ColoredNucl_Acont,.5*double(k)*size(mymapcont,1));
                end

                NC=AllNucl(i1).NDotBleu; %NDots cyan
                NM=AllNucl(i1).NDotMagenta; % NDots Magenta
                ratioC_CM=NC/(NC+NM)*Dnucl;
                if ~isnan(ratioC_CM)
                    ColoredNucl_Ncont=max(ColoredNucl_Ncont,floor(ratioC_CM*size(mymapcont,1)));
                else
                   k=nucl-imerode(nucl,strel('disk',3,8));
                   ColoredNucl_Ncont=max(ColoredNucl_Ncont,.5*double(k)*size(mymapcont,1));
                end
                
                IC=AllNucl(i1).IntBleu; %Int cyan
                IM=AllNucl(i1).IntMagenta; % Int Magenta
                ratioC_CM=IC/(IC+IM)*Dnucl;
                if ~isnan(ratioC_CM)
                    ColoredNucl_Icont=max(ColoredNucl_Icont,floor(ratioC_CM*size(mymapcont,1)));
                else
                    k=nucl-imerode(nucl,strel('disk',3,8));
                    ColoredNucl_Icont=max(ColoredNucl_Icont,.5*double(k)*size(mymapcont,1));
                end
                
                k=imdilate(bwmorph(nucl,'remove'),strel('disk',1));
                G=double(k).*AllNucl(i1).NDotBleu;
                R=double(k).*AllNucl(i1).NDotMagenta;
                mx=max(max(R,[],'all'),max(G,[],'all'));
                R=R./mx;
                G=G./mx;
                ContourNuclN=max(ContourNuclN,cat(3,R,G,0.*G));
                G=double(k).*AllNucl(i1).AreaBleu;
                R=double(k).*AllNucl(i1).AreaMagenta;
                mx=max(max(R,[],'all'),max(G,[],'all'));
                R=R./mx;
                G=G./mx;
                ContourNuclA=max(ContourNuclA,cat(3,R,G,0.*G));
                
                k=bwmorph(nucl,'remove');
                ContourNucl0=ContourNucl0 | k;
            end
        end
        
        nucl2=nucl-imerode(nucl,strel('disk',3,8));
        AllContour=max(AllContour,nucl2);
        if toc(t1)>5
            subplot 221
            imagesc(Dnucl);axis image;colorbar
            subplot 222
            imagesc(AContCyan);axis image;colorbar
            title(AC)
            subplot 224
            imagesc(AContCyan);caxis([0,5]);axis image;colorbar
            title(AC)
            subplot 223
            imagesc(AContMagenta);axis image;colorbar
            title(AM)
            colormap(hot)
            pause(0.1)
            disp([num2str(i1),'/',num2str(length(AllNucl)),': ',num2str(toc(t0),2),'s']);
            t1=tic;
        end
    % creat contour around each nucleus)
    
    end
    mx=max(AContCyan,[],'all');
    AContCyan=max(max(0,AContCyan-1),double(AllContour)*mx);
    mx=max(AContMagenta,[],'all');
    AContMagenta=max(max(0,AContMagenta-1),double(AllContour)*mx);
    ColoredNucl_Icont(ContourNucl0)=0;
    ColoredNucl_Ncont(ContourNucl0)=0;
    ColoredNucl_Acont(ContourNucl0)=0;
    max(ColoredNucl_Acont(:)),min(ColoredNucl_Acont(:))
    ColoredNucl_Acont=round(ColoredNucl_Acont/2.56);
    ColoredNucl_Icont=round(ColoredNucl_Icont/2.56);
    ColoredNucl_Ncont=round(ColoredNucl_Ncont/2.56);   
    clear TmpNucl   

    %% Graphics 2
    clf
    disp('Export Images');
    mapCyan=cat(1,zeros(1,255),linspace(0,1,255),linspace(0,1,255)).';
    mapMag=cat(1,linspace(0,1,255),zeros(1,255),linspace(0,1,255)).';
    
    subplot 131
        imagesc(AContMagenta)
        axis image
        set(gca,'XTick',[],'YTick',[])
        title('Area continuous');
        colormap(gca,mapMag)
        colorbar
        fullpath=fullfile(par.PathName,[par.CoreName,'_AMag.tif']);
        if exist(fullpath,'file')
            disp(['deleting ',fullpath]);
            delete(fullpath);
        end
        imwrite(uint16(AContMagenta),fullpath);
        colorbar
    
    subplot 132
    class(AContCyan)
        imagesc(AContCyan)
        axis image
        set(gca,'XTick',[],'YTick',[])
        title('Area continuous');
        colormap(gca,mapCyan)
        colorbar
        fullpath=fullfile(par.PathName,[par.CoreName,'_ACyan.tif']);
        if exist(fullpath,'file')
            disp(['deleting ',fullpath]);
            delete(fullpath);
        end
        imwrite(uint16(round(AContCyan)),fullpath);
        colorbar
    

    subplot 133
    ShowImg=ColoredNucl_Acont;
    imagesc(ShowImg)
    axis image
    set(gca,'XTick',[],'YTick',[])
    title('Area continuous');
    colormap(gca,mymapcont)
    k=ind2rgb(uint8(ShowImg*2.55),mymapcont);
    fullpath=fullfile(par.PathName,[par.CoreName,'_Ac.tif']);
    if exist(fullpath,'file')
        disp(['deleting ',fullpath]);
        delete(fullpath);
    end
    imwrite(k,fullpath);
    colorbar
    

%     subplot 132
%     ShowImg=ColoredNucl_Ncont;
%     imagesc(ShowImg)
%     axis image
%     set(gca,'XTick',[],'YTick',[])
%     title('NDots continuous');
%     colormap(gca,mymapcont)
%     k=ind2rgb(uint8(ShowImg*2.55),mymapcont);
%     fullpath=fullfile(par.PathName,[par.CoreName,'_Nc.tif']);
%     if exist(fullpath,'file')
%         delete(fullpath);
%         disp(['deleting ',fullpath]);
%     end
%     imwrite(k,fullpath);
%     colorbar
% 
%     subplot 133
%     ShowImg=ColoredNucl_Icont;
%     imagesc(ShowImg)
%     axis image
%     set(gca,'XTick',[],'YTick',[])
%     title('Signal continuous');
%     colormap(gca,mymapcont)
%     k=ind2rgb(uint8(ShowImg*2.55),mymapcont);
%     fullpath=fullfile(par.PathName,[par.CoreName,'_Ic.tif']);
%     if exist(fullpath,'file')
%         delete(fullpath);
%         disp(['deleting ',fullpath]);
%     end
%     imwrite(k,fullpath);
%     colorbar

    ExpTable=struct2table(AllNucl);
    fullpath=fullfile(par.PathName,[par.CoreName,'_Stat.xls']);
    if exist(fullpath,'file')
        delete(fullpath);
    end
    writetable(ExpTable,fullpath)
    
    drawnow;
end
