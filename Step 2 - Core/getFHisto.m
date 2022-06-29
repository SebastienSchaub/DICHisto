function [Histo,Lum,HistCol]=getFHisto(Stk,Par)
    Sze=size(Stk);
    Sze2=[Sze(1:2),1,Sze(4)];
    [Hue,Sat,Lum]=rgb2hsl(Stk);
%     DLum=double(Lum);
    Lum=uint8(double(Lum)./median(double(Lum),'all')*Par.ModalGray);
%     DHue=double(Hue);
%     DSat=double(Sat);
    NH=size(Par.HueVal,1);
%median filter of Hue & Sat
    for iz=1:Sze(4)
        Hue(:,:,iz) = medfilt2(Hue(:,:,iz),Par.MedFilter*[1,1]);
    end
    
% Filtering Lum,Sat,Hue
    Filt.Lum=zeros(Sze2,'uint8');
    [Histo,Filt.Sat]=deal(zeros([Sze(1:2),NH,Sze(4)],'uint8'));
    Filt.Hue=false([Sze(1:2),NH,Sze(4)]);
    for iz=1:Sze(4)
        LumM=medfilt2(Lum(:,:,iz),Par.MedFilter*[1,1]);
        k=uint8(255*min(1,max(0,(double(LumM)-Par.LumThresh)./Par.LumSlope)));
        Filt.Lum(:,:,1,iz)=uint8(255*min(max(0,double(LumM)-Par.LumThresh)./Par.LumSlope,1));
        SatM=medfilt2(double(Sat(:,:,iz)),Par.MedFilter*[1,1]);
        HueM=medfilt2(double(Hue(:,:,iz)),Par.MedFilter*[1,1]);
        for ih=1:NH
            if Par.HueVal(ih,1)<Par.HueVal(ih,2)
                Par.HueCenter(ih)=uint8(round(mean(Par.HueVal(ih,:))));
                Filt.Hue(:,:,ih,iz)=HueM>=Par.HueVal(ih,1) & HueM<=Par.HueVal(ih,2);
            else
                Filt.Hue(:,:,ih,iz)=HueM>=Par.HueVal(ih,1) | HueM<=Par.HueVal(ih,2);
                Par.HueCenter(ih)=uint8(round(mod(mean(Par.HueVal(ih,1),Par.HueVal(ih,2)+255),256)));
            end
            Filt.Sat(:,:,ih,iz)=uint8(255*min(max(0,SatM-Par.SatThresh)./(Par.SatSlope(ih)-Par.SatThresh),1));
        end
    end

    for ih=1:NH
        Histo(:,:,ih,:)=uint8(double(Filt.Hue(:,:,ih,:)).*double(Filt.Sat(:,:,ih,:)).*double(Filt.Lum)/255);
    end
    
% Show Raw mean
    ZMid=ceil(Sze(4)/2);
%     ToShowImg.Histo=
%     subplot 245
%         k=double(Stk);k=double(Stk(:,:,:,ZMid));
%         imshow(uint8(mean(k./median(k(:))*128,4)));
%         title('Raw')
%         xlim([90,260]);ylim([50,200]);
% 
%     subplot 246
%         k=double(Lum(:,:,:,ZMid));
%         imshow(uint8(min(k./median(k(:))*128,[],4)));
%         colormap(gca,'gray');
%         title('Lum')
%         xlim([90,260]);ylim([50,200]);
%     
%     subplot 247
%         k=double(Histo(:,:,1,ZMid));
%         imagesc(k);
%         colormap(gca,'gray');
%         colorbar('horz');
%         axis image
%         xlim([90,260]);ylim([50,200]);
%     
%     subplot 248
%         k=double(Histo(:,:,2,ZMid));
%         imagesc(k);
%         colormap(gca,'gray');
%         colorbar('horz');
%         axis image
%         xlim([90,260]);ylim([50,200]);
%     
%     subplot 241
%         k=double(Filt.Hue(:,:,1,ZMid)).*double(Filt.Sat(:,:,1,ZMid));
%         k=double(Filt.Hue(:,:,1,ZMid)).*double(Filt.Sat(:,:,1,ZMid));
%         imagesc(k);
%         colormap(gca,'gray');
%         colorbar('horz');
%         axis image
%         xlim([90,260]);ylim([50,200]);
%         
%     subplot 242
%         k=double(Filt.Hue(:,:,2,ZMid)).*double(Filt.Sat(:,:,2,ZMid));
%         imagesc(k);
%         colormap(gca,'gray');
%         axis image
%         colorbar('horz');   
%         xlim([90,260]);ylim([50,200]);
%         
%     subplot 243
%         k=mean(Filt.Sat(:,:,:,ZMid),3);
%         imagesc(k);
%         colormap(gca,'gray');
%         axis image
%         colorbar('horz');
%         xlim([90,260]);ylim([50,200]);
%         
%     subplot 244
%         k=Filt.Lum(:,:,:,ZMid);
%         imagesc(k);
%         colormap(gca,'gray');
%         axis image
%         colorbar('horz');
%         xlim([90,260]);ylim([50,200]);
    
    mycol=hsv(256);
    HistCol=zeros([Sze(1:2),3],class(Histo));
    ZMid=ceil(Sze(4)/2);
    for ic=1:3
        for ih=1:NH
            HistCol(:,:,ic)=HistCol(:,:,ic)+Histo(:,:,ih,ZMid)*mycol(Par.HueCenter(ih),ic);
        end
    end
%     subplot 247
%         k=HistCol;
%         imshow(k);
%         colormap(gca,'gray');
%         xlim([90,260]);ylim([50,200]);
end
