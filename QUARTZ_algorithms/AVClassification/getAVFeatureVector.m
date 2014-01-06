function [cent_coord  fv_vess] = getAVFeatureVector(vessel_data)
        vessel_list = vessel_data.vessel_list;
        RGBo = im2double(vessel_data.im_orig);
        preprocessedName = [vessel_data.file_path '\Processed\' vessel_data.file_name '.mat'];
        isEx = exist(preprocessedName);
        if(isEx ==2)
            load([ vessel_data.file_path '\Processed\' vessel_data.file_name '.mat'] , 'RGB');
            RGB = im2double(RGB);
        else
            avgMaskSize = 151;
            R = prehomogenized(RGBo,1 , avgMaskSize , vessel_data.bw_mask) ;
            G = prehomogenized(RGBo,2 , avgMaskSize , vessel_data.bw_mask) ;
            B = prehomogenized(RGBo,3 , avgMaskSize , vessel_data.bw_mask) ; 
            RGB(:,:,1) = R;
            RGB(:,:,2) = G;
            RGB(:,:,3) = B;
        end
        %load(['C:\D\Quartz\EPIC' '\Processed\' vessel_data.file_name '.mat'] , 'RGB');
        %RGB = im2double(RGB);
%         RGBp(:,:,1) = adapthisteq(RGB(:,:,1));
%         RGBp(:,:,2) = adapthisteq(RGB(:,:,2));
%         RGBp(:,:,3) = adapthisteq(RGB(:,:,3));
        
        HSI = HSIConv( RGBo );
        
        HSI(:,:,1) = HSI(:,:,1) .* double(vessel_data.bw_mask);
        HSI(:,:,3) = HSI(:,:,2) .* double(vessel_data.bw_mask);
        HSI(:,:,2) = HSI(:,:,3) .* double(vessel_data.bw_mask);
        
%         HSIp(:,:,1) = adapthisteq(HSI(:,:,1)) ;
%         HSIp(:,:,2) = adapthisteq(HSI(:,:,2)) ;
%         HSIp(:,:,3) = adapthisteq(HSI(:,:,3)) ;
        RGB = RGB; HSI = HSI;
        %
        fv_vess = [];
        cent_coord = [];
        for nVessIdx=1:length(vessel_list)
            current_vessel = vessel_list(nVessIdx);
            %if( isempty(current_vessel.AV) )
            %    continue;
            %end
           
            cent  = round(current_vessel.centre);
            %cent2 = current_vessel.orig_centre;
            side1 = round(current_vessel.side1);
            side2 = round(current_vessel.side2);
            nans1 = isnan(side1(:,1));
            
            if(~isempty(nans1))
                side1(nans1,:)=[];
                side2(nans1,:)=[];
                cent(nans1,:)=[];
            end
            nans2 = isnan(side2(:,1));
            if(~isempty(nans2))
                side1(nans2,:)=[];
                side2(nans2,:)=[];
                cent (nans2,:)=[];
            end
            
            if(current_vessel.num_diameters <=50 || size(side1,1) <=50 || size(side2,1) <=50)
                continue;
            end
            fv = double.empty(size(cent,1),0);
            
            
%             sub_fv = getCentPixelIntensity(RGB , HSI , cent);
%             fv = cat(2,fv ,sub_fv);
%                         
%             sub_fv =  getVesselPartFeatures(RGB , HSI, side1, side2, cent);
%             fv = cat(2,fv ,sub_fv);
%                         
%             sub_fv =  getVesselProfile(RGB , HSI, side1, side2);
%             fv = cat(2,fv ,sub_fv);
            
            sub_fv =  getVesselFeatures(RGB , HSI, side1, side2, cent);
            fv = cat(2,fv ,sub_fv);
            
            %vessel_label = double.empty(size(fv,1),0);
            %vessel_label(:,1) = current_vessel.AV;
            %fv = cat(2, vessel_label, fv);
            if ( isempty(fv_vess) )
                fv_vess = fv ;
                cent_coord(1:size(cent,1),1) = current_vessel.vesID;
                cent_coord(:,2:3) = cent;
            else
            try
                fv_vess = cat(1 , fv_vess , fv) ;
                cur_cent_coord(1:size(cent,1),1) = current_vessel.vesID;
                cur_cent_coord(:,2:3) = cent;
                cent_coord = cat(1,cent_coord , cur_cent_coord);
                cur_cent_coord = [];
            catch E
                n=0;
            end
                    
            end
            clear fv; clear sub_fv; clear vessel_label;
        end
end

function sub_fv =  getVesselFeatures(RGB , HSI, side1, side2, cent)
    R=RGB(:,:,1);
    G=RGB(:,:,2);
    B=RGB(:,:,3);
    H=HSI(:,:,1);
    S=HSI(:,:,2);
    I=HSI(:,:,3);
    
    aa = side1(: ,1)';
    aa = [aa fliplr(side2(: ,1)')];
    bb =side1(: ,2)';
    bb = [bb fliplr(side2(: ,2)')];
    vessel_pixels = roipoly(R,bb,aa);
    
    sub_fv = double.empty(size(cent,1),0);
    featCount = 1;
    
    sub_fv(:,featCount) = mean(R(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = mean(G(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = mean(B(vessel_pixels)); featCount = featCount + 1;
    %comment below 3 for LDA
    sub_fv(:,featCount) = mean(H(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = mean(S(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = mean(I(vessel_pixels)); featCount = featCount + 1;
    
    sub_fv(:,featCount) = std(R(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = std(G(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = std(B(vessel_pixels)); featCount = featCount + 1;
    %comment below 3 for lda
    sub_fv(:,featCount) = std(H(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = std(S(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = std(I(vessel_pixels)); featCount = featCount + 1;
    
    sub_fv(:,featCount) = max(R(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = max(G(vessel_pixels)); featCount = featCount + 1;
       
    sub_fv(:,featCount) = min(R(vessel_pixels)); featCount = featCount + 1;
    sub_fv(:,featCount) = min(G(vessel_pixels)); featCount = featCount + 1;
    clear R; clear G; clear B; clear H; clear S; clear I;
end

