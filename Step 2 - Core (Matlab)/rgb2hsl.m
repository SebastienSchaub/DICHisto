function [Hue,Sat,Lum]=rgb2hsl(Stk)
% Hue,Sat are 8bit images
% Lum has same class as Stk
    Sze=size(Stk);%Stk is XYCZ
    Sze2=Sze;Sze2(3)=1;
    Lum=zeros(Sze2,class(Stk));
    [Hue,Sat]=deal(zeros(Sze2,'uint8'));
    for iz=1:Sze(4)
        ImgTmp=double(Stk(:,:,:,iz));
        MX=max(ImgTmp,[],3);
        MN=min(ImgTmp,[],3);
        Lum(:,:,1,iz)=(MX+MN)/2;
        HSV=rgb2hsv(ImgTmp);
        HSV(:,:,3)=HSV(:,:,3)./max(HSV(:,:,3),[],'all');
        L=HSV(:,:,3)-HSV(:,:,3).*HSV(:,:,2)/2;
        k=L>0 & L<1;
        S=k.*(2-2*L./HSV(:,:,3));
        Sat(:,:,1,iz)=uint8(255*S);
        H1=HSV(:,:,1);
        H2=mod(HSV(:,:,1)+.5,1);
        f=HSV(:,:,1)>=.25 & H1<=.75;
        Hue(:,:,1,iz)=uint8(255*(H1.*f+(1-f).*mod(H2+.5,1)));
        end

end
