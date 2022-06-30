function [Stk,par]=BuiltBFHStack(BFData)
    par.NXY=size(BFData{1,1}{1,1});
    par.NPlane=size(BFData{1,1},1);
    str1=[BFData{1,1}{1,2},';'];
    k1=strfind(str1,'Z?=');
    if ~isempty(k1)
        str2=str1(k1(1)+5:end);
        k2=strfind(str2,';');
        par.NZ=str2num(str2(1:k2-1));
    else
        par.NZ=1;
    end
    k1=strfind(str1,'C?=');
    if ~isempty(k1)
        str2=str1(k1(1)+5:end);
        k2=strfind(str2,';');
        par.NC=str2num(str2(1:k2-1));
    else
        par.NC=1;
    end
    k1=strfind(str1,'T?=');
    if ~isempty(k1)
        str2=str1(k1(1)+5:end);
        k2=strfind(str2,';');
        par.NT=str2num(str2(1:k2-1));
    else
        par.NT=1;
    end
    par.Sze=[par.NXY,par.NC,par.NZ,par.NT];
    Stk=zeros(par.Sze,class(BFData{1,1}{1,1}));
    
    for i1=1:par.NPlane
        img=BFData{1,1}{i1,1};
        str1=[BFData{1,1}{i1,2},';'];
        k1=strfind(str1,'Z?=');
        if ~isempty(k1)
            str2=str1(k1(1)+3:end);
            k2=strfind(str2,'/');
            iz=str2num(str2(1:k2-1));
        else
            iz=1;
        end
        k1=strfind(str1,'C?=');
        if ~isempty(k1)
            str2=str1(k1(1)+3:end);
            k2=strfind(str2,'/');
            ic=str2num(str2(1:k2-1));
        else
            ic=1;
        end
        k1=strfind(str1,'T?=');
        if ~isempty(k1)
            str2=str1(k1(1)+3:end);
            k2=strfind(str2,'/');
            it=str2num(str2(1:k2-1));
        else
            it=1;
        end
        Stk(:,:,ic,iz,it)=img;
    end
end