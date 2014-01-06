function Ibin = vessel_segmentation(vsSettings,cI)
    
    G = im2double(cI.img(:,:,2));
    idx = 1;
    for W = 29:2:29
            step = 2;
            LSI =  LSIVesselness(G,cI.mask,W,step);
            fv(:,:,idx) = LSI;
            idx=idx+1;
    end
    
    OpDir = vsSettings.segPath;
    mkdir(OpDir);
    %vsSettings.bWriteIntemediateImages = false;
    %vsSettings.interim_images_path = '';
    %vsSettings.mode = 'interactive';
    OutputDir = [OpDir ,cI.StemName '\'];
    mkdir(OutputDir);
    Ibin  = double_threshold3(fv(:,:,1) , 5 , OutputDir );
    %Ibin2 = double_threshold3(fv(:,:,1) , 3 , OutputDir );
    
    name = [OpDir, cI.StemName, '.',  vsSettings.segExt];
    imwrite(Ibin,name);

end

function Ibin = double_threshold3(I , nType , OutputDir )
     
        switch nType
            case 1
                MarkerPercent = 90; %10
                MaskPercent = 75;   %25

            case 2
                MarkerPercent = 90; %10
                MaskPercent =   80; %20    

            case 3
                MarkerPercent = 95; %5
                MaskPercent =   88; %15

            case 4
                MarkerPercent = 90; %1
                MaskPercent   = 85; %10
             case 5
                MarkerPercent = 95; %1
                MaskPercent   = 90; %10    
            case 6
            MarkerPercent = 99; %1
            MaskPercent   = 95; %10  
            case 7
            MarkerPercent = 90; %1
            MaskPercent   = 95; %10  
        end
    
    Iv = I(I ~= 0);
    Iv = sort(Iv);
    L = numel(Iv);
    %%
    nI = L*MaskPercent/100;
    nI=floor(nI);
    thv1 = Iv(nI);
    nI = L*MarkerPercent/100;
    nI=floor(nI);
    thv2 = Iv(nI);
    %%
    Mask = I>=thv1;
    Marker = I>=thv2;

    
    res = imreconstruct(Marker,Mask);
%     if nType == 1
%         res = bwareaopen(res, 15);
%     elseif nType > 2
%         res = bwareaopen(res, 25);
%     end
        
    %ImageNum=9;
    %name = sprintf('%s%s-%d.%s' ,OutputDir,'Marker' , nType,'jpg');
    %imwrite(Marker,name,'jpg');

    %name = sprintf('%s%s-%d.%s' ,OutputDir,'Mask' , nType,'jpg');
    %imwrite(Mask,name,'jpg');
       
    %% write in file
   % file_id = fopen('Image1\data.txt','a');
   % fprintf(file_id,' %s:%f\r\n %s:%f\r\n %s:%d\r\n %s:%d\r\n*****\r\n', 'tMask' , tMask , 'tMarker', tMarker , 'Threshold1' , thv2, 'Threshold2' , thv1);
   % fclose(file_id);
    Ibin = logical(res);
    name = sprintf('%s%s-%d.%s' ,OutputDir,'Recon' , nType,'jpg');
    imwrite(Ibin,name,'jpg');
end
