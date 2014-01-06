function Ih = prehomogenized(img , ch , avMaskSize , mask)   
    
    G = im2double(img(:,:,ch));
    %Go = imopen(G,strel('disk',1,8));
    
    h = fspecial('average',3);
    
    %Gof = filter2(h,Go);
    Gf = filter2(h,G);
    %uncomment below two lines to get Morph only
    %Ih = Gof;
    %return ;
    hg = fspecial('gaussian',[9 9] , 1.8);
    
    
    Gf = filter2(hg,Gf);
    
    Gf = fpad( (Gf) , mask);

    h = fspecial('average',avMaskSize);
    Gb = filter2(h,Gf);
    Gb = Gb(51:(50+size(G,1)), (51:50+size(G,2)));
    
    %for NOT using the morphological opening as pre processing
    GfnotO = fpad( (G) , mask);%filter2(hg,Gf);
    GfnotO = GfnotO(51:(50+size(G,1)), (51:50+size(G,2)));
    Is = im2double(GfnotO) - Gb;
    %for using the morphological opening as pre processing
    %Is = im2double(Gof) - Gb;
    
    Is = Is .* mask;
    Isu = to_uint8(Is);
    Isu(~mask) = 0;
    %uncomment below 2 lines to get Morph Norm
    %Ih = Isu;
    %return;
    
    %for Morph Norm and Homo
    [count,p] = imhist(Isu);
    count(1) = [];
    [c , ind ]= max(count);

    c1 = (Isu==0);
    c2 = (Isu==255);

    Ih = Isu + (128 - ind);
    Ih(c1) = 0;
    Ih(c2) = 0;
end
