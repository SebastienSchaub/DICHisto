function [WhiteBalanced,CorrMap]=LocalWhiteBalance(Stk,n,CurZ,CorrMap,ToShow)
% Create or apply CorrMap to get homogeneous white balance image
% IN:   Stk: in XYCZT image. CorrMap is estimated on CurZ and T=1
%       n: set the number of subimages (3x3,5x5,....)
%       CurZ: set the Z plan on which the correction is estimated
%       CorrMap: Correction map applied to the Stack. If not
% OUT:  WhiteBalanced: Stack corrected with same size and type as Stk
%       CorrMap: correction image [XYC]

    Sze=size(Stk);
    Sze(length(Sze)+1:5)=1;
    if ~exist('ToShow','var')
        ToShow=false;
    end
    if ~exist('n','var')
        n=1;
    end
    if ~exist('CurZ','var')
        CurZ=ceil(Sze(4)/2);
    end
   
%% CREATE CorrMap =========================================================
    if ~exist('CorrMap','var')

        Lx=round(linspace(1,Sze(1),n+1));
        Ly=round(linspace(1,Sze(2),n+1));
        MPar=zeros(n,n,3);
        for ix=1:n
            for iy=1:n
                Img=Stk(Lx(ix):Lx(ix+1),Ly(iy):Ly(iy+1),:,CurZ);
                LH=reshape(double(Img),size(Img,1)*size(Img,2),3);
                par0=[1,1];
                Range=linspace(min(LH,[],'all'),max(LH,[],'all'),256).';

            %     options = optimset('PlotFcns','optimplotfval','TolX',1e-7);
                options = optimset('TolX',1e-4,'Display','off');
                par=fminsearch(@(par) OptimHisto(par,LH,Range),par0,options);
                MPar(ix,iy,:)=[par,3-sum(par)];            

                if ToShow
                    imagesc(MPar);
                    axis image
                    drawnow;
                end
            end
        end

    %Resizing the CorrectionMap
        WhiteBalanced=zeros(size(Stk),class(Stk));
        CorrMap=zeros([size(Stk(:,:,1,1)),3]);
        for ic=1:3
            CorrMap(:,:,ic)=imresize(MPar(:,:,ic),size(Stk(:,:,1,1)));
        end
    end
    
%% APPLY CorrMap ==========================================================    
    for it=1:Sze(5)
        for ic=1:3
            k=double(Stk(:,:,ic,:,it)).*repmat(CorrMap(:,:,ic),[1,1,1,size(Stk,4)]);
            switch class(Stk)
                case 'uint8'
                    WhiteBalanced(:,:,ic,:,it)=uint8(round(k));
                case 'uint16'
                    WhiteBalanced(:,:,ic,:,it)=uint16(round(k));
                case 'double'
                    WhiteBalanced(:,:,ic,:,it)=k;
            end
        end
    end
        
end

%==========================================================================
% sub-functions
%==========================================================================

function Score=OptimHisto(par,LH,Range)
    par(3)=3-sum(par);
    hR=zeros(length(Range)-1,3);
    for i1=1:3
        hR(:,i1)=histcounts(par(i1)*LH(:,i1),Range);
    end  
    Score=sum(std(hR.').^1);
end