function ListFullPath=MultiCreateStat(mydir,rule)
    clc
    if ~exist('mydir','var')
        mydir='C:\Users\schaub\Documents\MATLAB\2021 - Synthese Gregoire\Data Brutes\set 2022-05-20';
%         mydir='F:\Noyau Elo\2021-10';
    end
    if ~exist('rule','var')
        rule='HiLFMask.tif';
    end
    ListFullPath={};
    ListFullPath=getList(mydir,rule,ListFullPath);
    for i1=1:size(ListFullPath,1)
        StatDichysto2(ListFullPath{i1,2}, ListFullPath{i1,1});
        drawnow;
    end
end


function ListFullPath=getList(mydir,rule,ListFullPath)
    tmpdir=dir(mydir);
    i1=1;
    while i1<=length(tmpdir)
        if startsWith(tmpdir(i1).name,'.')
            tmpdir(i1)=[];
        else
            i1=i1+1;
        end
    end
    for i1=1:length(tmpdir)
        if tmpdir(i1).isdir
            k=size(ListFullPath,1);
            ListFullPath=getList(fullfile(mydir,tmpdir(i1).name),rule,ListFullPath);
        elseif ~isempty(strfind(tmpdir(i1).name,rule))
            ListFullPath=cat(1,ListFullPath,{mydir,tmpdir(i1).name});
        end
    end
end
