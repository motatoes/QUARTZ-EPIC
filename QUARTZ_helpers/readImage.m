function curImg = readImage(imName , imgDir, maskDir,bCreateMask )
    
    [pathstr , StemName , ext ] = fileparts(imName);
    if( ~isempty(imgDir) )
        ImageName = strcat(imgDir , imName);
    else
        ImageName = imName;
    end
    
    img = imread(ImageName);
    
    %disp([sprintf('%d-',idx),StemName,' ...working']);
    
    maskName = [maskDir,StemName,'.png'];
    if(exist(maskName , 'file')==2)
    
    else
        bCreateMask = true;
    end
    if (bCreateMask)
        [x y z] = size(img);
        if(z==3)
            im = img(:,:,2);
        else
            im = img;
        end
        maskW = createretinamaskredfree(im);
        %maskW=createretinamaskcolored(img);
        clear im;
        mkdir(maskDir);
        imwrite(maskW,maskName,'png');    
        %mask = imerode(maskW , strel('disk',1));
        mask = maskW;
    else
        mask = imread(maskName); 
        %mask = imerode(mask , strel('disk',1));
    end
    clear name;

    curImg.StemName = StemName;
    curImg.img = img;
    curImg.mask = mask; 
    curImg.ext = ext;
    curImg.path = [pathstr '\'];
end