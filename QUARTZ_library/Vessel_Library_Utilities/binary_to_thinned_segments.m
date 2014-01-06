function [bw_segments, bw_branches, dist , sls] = binary_to_thinned_segments(bw, spur_length, clear_branches_dist)
% Computes a binary image containing thinned centrelines from a segmented
% binary image containing vessels.  Branch points and short spurs are
% removed during the thinning.
% 
% Input:
%   BW - the original segmented image.
%   SPUR_LENGTH - the length of spurs that should be removed.
%   CLEAR_BRANCHES_DIST - TRUE if centre lines should be shortened
%   approaching branch points, so that any pixel is removed from the
%   centre line if it is closer to the branch than to the background
%   (i.e. FALSE pixels in BW).  If measurements do not need to be made
%   very close to branches (where they may be less accurate), this can
%   give a cleaner result (Default = TRUE).
%
% Output:
%   BW_SEGMENTS - another binary image (the same size as BW) containing
%   only the central pixels corresponding to segments of vessels
%   between branches.
%   BW_BRANCHES - the detected branch points that were removed from the
%   originally thinned image when generating BW_SEGMENTS.
%   DIST - the distance transform BWDIST(~BW).  If CLEAR_BRANCHES_DIST
%   is TRUE, then this is required - and given as an additional output
%   argument since it has other uses, and it can be time consuming to
%   recompute for very large images.  Even if CLEAR_BRANCHES_DIST is FALSE,
%   DIST is given if it is needed.
%
%
% Copyright © 2011 Peter Bankhead.
% See the file : Copyright.m for further details.

% Set up default if needed
if nargin < 3 || isempty(clear_branches_dist)
    clear_branches_dist = true;
end
bMoazam = 1;
if(bMoazam)
    %msgbox('b4 imdilate');
    toDraw = imdilate(bw,strel('disk',3));
    %msgbox('after imdilate');
    %figure,imshow(toDraw);
    skel = bwmorph(toDraw,'thin', Inf);
    %msgbox('after bwmorph')
    %figure,imshow(iov2);
    subwindow = 16;
    skel = spur_clearing(skel,subwindow);
    %msgbox('after spur_clearing')
    subwindow = 14;
    skel = spur_clearing(skel, subwindow);
    %msgbox('after spur_clearing2')
    skel = spur_clearing(skel, subwindow);
    %msgbox('after spur_clearing3')
    CC = bwconncomp(skel);
    %msgbox('after bwconncomp')
    numPixels = cellfun(@numel,CC.PixelIdxList);
    %msgbox('after cellfun')
    [ra,ca] = find(numPixels < 50);

    for idx=1:length(ca)
        skel(CC.PixelIdxList{ca(idx)}) = 0;
    end
    %msgbox('b4 findendsjunctions');
    [rb,cb , rj, cj, re, ce, junc , ends] = findendsjunctions(double(skel), 0);
    
    junc2 = imdilate(junc,strel('disk',3));
    skel_segments = skel & ~junc2;
    
    junc3 = imdilate(junc,strel('disk',16));
    
    sls = bw & ~junc3;
     CC = bwconncomp(skel_segments);
     numPixels = cellfun(@numel,CC.PixelIdxList);
     [ra,ca] = find(numPixels < 40);
     %msgbox('after imdilate and conn comp');
     for idx=1:length(ca)
        skel_segments(CC.PixelIdxList{ca(idx)}) = 0;
     end
     
     %bw_thin = bwmorph(bw_thin, 'spur');
     skel_segments = bwmorph(skel_segments, 'thin', Inf);
     
     
     bw_branches = junc;
     bw_segments = skel_segments;
     dist = bwdist(~bw);
else
    % Thin the binary image
    bw_thin = bwmorph(bw, 'thin', Inf);
    %[skel, final] = skeleton_EPIC(bw, 0, bw);
    %bw_thin = skel;
    % Find the branch and end points based upon a count of 'on' neighbours
    neighbour_count = imfilter(uint8(bw_thin), ones(3));
    bw_branches = neighbour_count > 3 & bw_thin;
    bw_ends = neighbour_count <= 2 & bw_thin;

    % Remove the branches to get the segments
    bw_segments = bw_thin & ~bw_branches;

    % Find the terminal segments - i.e. those containing end points
    bw_terminal = imreconstruct(bw_ends, bw_segments);

    % Remove the terminal segments if they are too short
    bw_thin(bw_terminal & ~bwareaopen(bw_terminal, spur_length)) = false;

    % We might still have some single pixel spurs, so remove these
    bw_thin = bwmorph(bw_thin, 'spur');

    % Also need to apply a thinning, since we can have 8-connected pixels that
    % are nonetheless not branch points
    bw_thin = bwmorph(bw_thin, 'thin', Inf);

    % Remove the branches again to get the final segment
    neighbour_count = imfilter(uint8(bw_thin), ones(3));
    bw_branches = neighbour_count > 3 & bw_thin;
    bw_segments = bw_thin & ~bw_branches;

    % If necessary, remove more pixels at the branches(depending upon how edges
    % are set, these locations can be very problematic).
    % Use the distance transform to identify centreline pixels are closer to
    % the branch than to the background - and then get rid of these.
    if clear_branches_dist
        dist = bwdist(~bw);
        bw(bw_branches) = false;
        dist2 = bwdist(~bw);
        bw_segments = bw_thin & (dist == dist2);
    elseif nargout >= 3
        dist = bwdist(~bw);
    end
end
end
%------------------------------------

% The first version of the code looked more like this:
% % Default number of spur iterations
% if nargin < 3 || isempty(spur_iterations)
%     spur_iterations = 5;
% end
% 
% % Thin the segmented image to reduce vessels to a single (centre) line
% bw_thin = bwmorph(bw, 'thin', Inf);
% 
% % Remove some short spurs, which are little offsets that can arise through
% % the thinning.
% % NOTE: BWMORPH could be used, but is quite slow
% % bw_thin = bwmorph(bw_thin, 'spur', 4);
% % Alternative spur removal by shaving off end points -
% % not magnificently refined, but much faster than BWMORPH (for now)
% bw_thin2 = bw_thin;
% for ii = 1:spur_iterations
%     % Count the number of 'on' neighbours for each pixel, and remove if it
%     % is too few (i.e. we have an end point)
%     im_neighbours = imfilter(uint8(bw_thin2), ones(3));
%     bw_thin2 = bw_thin2 & im_neighbours >= 3;
% end
% 
% % Now apply some more thinning - the spur removal can result in some
% % 4-connected
% bw_thin = bwmorph(bw_thin2, 'spur', 1);
% bw_thin = bwmorph(bw_thin, 'thin', Inf);
% 
% 
% % Remove the branches - use a filter to count the number of 'on' neighbours
% % for each pixel (including itself), and remove if this is more than 3
% bw_branches = imfilter(uint8(bw_thin), ones(3)) > 3 & bw_thin;
% bw_segments = bw_thin & ~bw_branches;


function skel = spur_clearing(skel, subwindow)
 
    [rb,cb , rj, cj, re, ce, junc , ends] = findendsjunctions(double(skel), 0);

    %iov = cI.img;
    %iov(skel) = 0;
    %figure, imshow(iov);
    %hold on;    

    %for idx=1:length(rj)
    %disp('rj is not empty');
    %mouseX = cj(idx);
    %mouseY = rj(idx);
    %mR = 3;
    %[pointsX,pointsY] = circle(mouseX,mouseY,mR,50);
    %plot(pointsX,pointsY,'Color','blue','LineWidth',3);
    %plot([mouseX,mouseX],[mouseY-mR,mouseY+mR],'Color','blue','LineWidth',2);
    %plot([mouseX-mR,mouseX+mR],[mouseY,mouseY],'Color','blue','LineWidth',2);
    %end
    %         for idx=1:length(re)
    %             mouseX = ce(idx);
    %             mouseY = re(idx);
    %             mR = 3;
    %             [pointsX,pointsY] = circle(mouseX,mouseY,mR,50);
    %             plot(pointsX,pointsY,'Color','red','LineWidth',2);
    %         end   

    for idx=1:length(rb)
        cY=rb(idx);
        cX=cb(idx);
        %         radius = 10;
        %         [ptX,ptY] = circle(cX,cY,radius,2*pi*radius);
        %        
        %         ptX= round (ptX);
        %         ptY = round(ptY);
        %         plot(ptX,ptY,'Color','red','LineWidth',1);
        %         linIdx = sub2ind(size(skel) , ptX, ptY);
        %         kdx = find(skel(linIdx)==1);
        %         
        %         cY=rb(1);
        %         cX=cb(1);
        %         radius = 9;
        %         [ptX,ptY] = circle(cX,cY,radius,2*pi*radius);
        %         ptX= round (ptX);
        %         ptY = round(ptY);
        %         plot(ptX,ptY,'Color','green','LineWidth',1);
        %         %hold off;


        rad = subwindow;
        ptx1 = cX-rad:cX+rad;
        ptx2(1:rad*2) = cX+rad;
        ptx3 = cX+rad:-1:cX-rad;
        ptx4(1:rad*2)= cX-rad;

        ptX = [ptx1, ptx2,ptx3,ptx4];


        pty1(1:rad*2) = cY-rad;
        pty2 = cY-rad:cY+rad;
        pty3(1:rad*2) = cY+rad;
        pty4= cY+rad:-1:cY-rad;

        ptY = [pty1, pty2,pty3,pty4];

        %plot(ptX,ptY,'Color','blue','LineWidth',1);

        nCount = 0;
        lastIdxOne = 0;
        for idx=1:numel(ptX)
           if skel(ptY(idx) , ptX(idx)) == 1
               if(lastIdxOne == idx-1)
               aaa=0;
               else
                    nCount = nCount+1;
               end
               lastIdxOne = idx;
           end
        end


        if(nCount <= 2)
           %it is spur
           imgpart = skel(cY-rad:cY+rad,cX-rad:cX+rad);
        %                spr = imgpart;
        %                while(false)
        %                     spr1 = bwmorph(spr,'spur');
        %                     k = spr-spr1;
        %                     if(numel(find(k==1)) == 0)
        %                         break;
        %                     end
        %                     spr = spr1;
        %                end

        %                branchPt = bwmorph(imgpart,'branchpoints');
           centImgPart = rad+1;
           imgpart(centImgPart-1:centImgPart+1, centImgPart-1:centImgPart+1) = 0;
           CC = bwconncomp(imgpart);
           numPixels = cellfun(@numel,CC.PixelIdxList);
           [smallest,idx] = min(numPixels);
           imgpart(CC.PixelIdxList{idx}) = 0;
        %                a = ones(size(imgpart));
        %                linIdx = find(bwmorph(a,'remove')==1);clear a;

        %                for idx=2001:length(CC.PixelIdxList)
        %                    C = intersect(linIdx,CC.PixelIdxList{idx});
        %                    if(isempty(C))
        %                        imgpart(CC.PixelIdxList{idx}) = 0;
        %                    end
        %                end
           imgpart(centImgPart, centImgPart) =  1; clear CC:
           tmplte = [1,1,1,1,1;1,0,0,0,1;1,0,0,0,1;1,0,0,0,1;1,1,1,1,1];
           tmplte_img = imgpart(centImgPart-2:centImgPart+2, centImgPart-2:centImgPart+2);
           sidIdx = find((tmplte & tmplte_img)==1);
           todoIdx = 0;
           for idx = 1:length(sidIdx)
               if(sidIdx(idx) <= 2) todoIdx(idx) = 7; elseif(sidIdx(idx) == 3)  todoIdx(idx) = 8; elseif(sidIdx(idx) == 4 || sidIdx(idx) == 5)  todoIdx(idx) = 9 ; end 
               if(sidIdx(idx) ==  6 || sidIdx(idx) == 11 || sidIdx(idx) == 16) todoIdx(idx) = 12; elseif(sidIdx(idx) == 21)  todoIdx(idx) = 17; end
               if(sidIdx(idx) == 22 || sidIdx(idx) == 23 || sidIdx(idx) == 24) todoIdx(idx) = 18; elseif(sidIdx(idx) == 25)  todoIdx(idx) = 19; end
               if(sidIdx(idx) == 10 || sidIdx(idx) == 15 || sidIdx(idx) == 20) todoIdx(idx) = 14; end
           end
           if(todoIdx~=0)
               tmplte_img(todoIdx) = 1;
           end
           imgpart(centImgPart-2:centImgPart+2, centImgPart-2:centImgPart+2) = imgpart(centImgPart-2:centImgPart+2, centImgPart-2:centImgPart+2) | tmplte_img;
           skel(cY-rad:cY+rad,cX-rad:cX+rad) = skel(cY-rad:cY+rad,cX-rad:cX+rad) & imgpart;

        end
        if(nCount == 3)
           %it is branching
          % plot(ptX,ptY,'Color','black','LineWidth',1);
        end

        if(nCount > 3)
           %it is crossover
           %plot(ptX,ptY,'Color','green','LineWidth',1);
        end
    end
    
    %hold off;
end
