function mycol=MyColMap(n,type)
    if ~exist('type','var')
        type='patchwork';
    end
    
    switch type
        case 'patchwork'
            k=sqrt(double(n*1));
            ncol=double(floor(k^1.5));
            ngray=double(ceil(n/ncol));
            [mg,mc]=ndgrid((1:ngray)./ngray,(1:ncol)./ncol);
            hsv=double([mc(:),ones(numel(mg),1),mg(:)]);
            mycol=hsv2rgb(hsv);
            k=rand(numel(mg),1);
            [~,ind]=sort(k);
            mycol=mycol(ind,:);
            mycol(1,:)=0;
        case 'bluered'
    end
end