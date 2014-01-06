function [ vessel_data ] = AVClassification( ensName , vessel_data )
%AVCLASSIFICATION Summary of this function goes here
%   Detailed explanation goes here

        %#function TreeBagger
        tic
        ensName = [ '.\QUARTZ_AVClassifier\' 'classif_tree_bagger_t0_c1_16_feats.mat' ]; 
        
        load(ensName);

        [cent_coord  fv_vess] = getAVFeatureVector(vessel_data);
        %ppp = class(classif_tree_bagger);
        %msgbox([' class is ... ' ppp]);
        [yPredicted , postProb] = predict(classif_tree_bagger, fv_vess(:,:) );
        
        
        for nVessIdx=1:length(vessel_data.vessel_list)
            current_vessel = vessel_data.vessel_list(nVessIdx);
            
            try
                ind = find(cent_coord (:,1) == current_vessel.vesID );
                if(isempty(ind))
                    continue;
                end
                vessel_data.vessel_list(nVessIdx).AV = postProb(ind(1),:);
            catch E
                disp(E);
            end
        end
        s = toc;
        %disp(s);
end

