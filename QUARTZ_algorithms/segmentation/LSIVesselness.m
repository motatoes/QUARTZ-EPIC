function LSI = LSIVesselness(img,mask,W,step,path)
% img: original color image
% mask: mask of FOV
% W: window size which is chosen as double of typical vessel width
% step: step size for increasing the line length
    bWriteInterimImages = false;
    if nargin==5
        bWriteInterimImages = true;
        mkdir(path);
    end
    %img = im2double(img);
    mask = im2bw(mask);

    img = imcomplement(img);
    img = fakepad(img,mask);

    features = standardize(img,mask);

%     w=101;
%     H = fspecial('average' , [w w]);
%     Iav = filter2(H,img);
% 
%     Inorm = double(img) - double(Iav);
%     
%     features = features+Inorm;
    %features = 0;
    %Ls = 1:step:W;
    switch W
        case 15
            Ls = 11:step:13;
        case 17
            Ls = 13:step:15;
        case 19
            Ls = 13:step:15;
        case 21
            Ls = 13:step:15;
        case 23
            Ls = 13:step:17;
        case 25
            Ls = 15:step:19;
        case 27
            Ls = 15:step:21;
        case 29
            Ls = 15:step:21;
        case 31
            Ls = 15:step:23;
        case 33
            Ls = 15:step:23;
        case 35
            Ls = 15:step:25;
        case 37
            Ls = 15:step:25;
        case 39
            Ls = 17:step:29;
                
    end
    for j = 1:numel(Ls)
        L = Ls(j);  
        R = get_lineresponse(img,W,L); 
        R = R.*mask;
        R = standardize(R,mask);
        if( bWriteInterimImages )
            imgwrite(R,[path '\' num2str(W) '_LSI_' num2str(L) '.jpg']); 
            imwrite(R,[path '\' num2str(W) '_LSI__' num2str(L) '.jpg']);
        end
        features = features+R;
        disp(['L = ',num2str(L),' finished!']);       
    end     
    LSI = features/(1+numel(Ls));
    
    if( bWriteInterimImages )
        imgwrite(R,[path '\' num2str(W) '_LSI_COMBINED'  '.jpg']); 
        imwrite (R,[path '\' num2str(W) '_LSI__COMBINED' '.jpg']);
    end
    %t = 0.56;
    %segmentedimg = im2bw(segmentedimg,t);

end


function R = get_lineresponse(img,W,L)
% img: extended inverted gc
% W: window size, L: line length
% R: line detector response

avgmask = fspecial('average',W);
avgresponse = imfilter(img,avgmask,'replicate');

maxlinestrength = -Inf*ones(size(img));
for theta = 0:15:165
    linemask = get_linemask(theta,L);
    linemask = linemask/sum(linemask(:));
    imglinestrength = imfilter(img,linemask);    
    imglinestrength = imglinestrength - avgresponse;    
    maxlinestrength = max(maxlinestrength,imglinestrength);    
end
R = maxlinestrength;

end


function linemask = get_linemask(theta,masksize)
% (theta,masksize)
% Create a mask for line with angle theta
if theta > 90
   [oMask mask] = getbasemask(180- theta,masksize);
   linemask = rotatex(mask);
else
   [oMask linemask] = getbasemask(theta,masksize);
end
%fig = figure, imshow(linemask,'InitialMagnification','fit');
%print(fig,['im_' num2str(theta)],'-djpeg','-r300');
%linemask = linemask|oMask;
end

function rotatedmask = rotatex(mask)
[h,w] = size(mask);
rotatedmask = zeros(h,w);

for i = 1:h
    for j = 1:w
        rotatedmask(i,j) = mask(i,w-j+1);
    end
end
end

function [oMask, mask] = getbasemask(theta,masksize)

mask = zeros(masksize);
oMask = mask;
tMask = 0;
halfsize = (masksize-1)/2;
oSize = 2;
midR = halfsize+1; midC = midR;
if theta == 0
    mask(halfsize+1,:) = 1;
    oMask = mask;
    if (masksize>3)
        oMask( midR-oSize:midR+oSize, midC) = 1;
    end
elseif theta == 90
    mask(:,halfsize+1) = 1;
    oMask = mask;
    if (masksize>3)
        oMask( midR , midC-oSize:midC+oSize) = 1;
    end
else
    x0 = -halfsize;
    y0 = round(x0*(sind(theta)/cosd(theta)));

    if y0 < -halfsize
        y0 = -halfsize;
        x0 = round(y0*(cosd(theta)/sind(theta)));
    end

    r0 = -oSize;
    c0 = round(r0*(sind(theta)/cosd(theta)));
    if ( c0 < -oSize )
        c0 = -oSize;
        r0 = round(c0*(cosd(theta)/sind(theta)));
    end

    x1 = halfsize;
    y1 = round(x1*(sind(theta)/cosd(theta)));

    if y1 > halfsize
        y1 = halfsize;
        x1 = round(y1*(cosd(theta)/sind(theta)));
    end

    r1 = oSize;
    c1 = round(r1*(sind(theta)/cosd(theta)));
    if c1 > oSize
        c1 = oSize;
        r1 = round(c1*(cosd(theta)/sind(theta)));
    end

    pt0 = [halfsize-y0+1 halfsize+x0+1];
    pt1 = [halfsize-y1+1 halfsize+x1+1];

    mask = drawline(pt0,pt1,mask);

    pt00 = [midR-r0 midC+c0];
    pt11 = [midR-r1 midC+c1];
    %oMask = mask;
    if (masksize>3)
        oMask = drawline(pt00,pt11,oMask);
    end
end

end

function img = drawline(pt0,pt1,orgimg)
img = orgimg;
linepts = getlinepts(pt0,pt1);
for i = 1:size(linepts,1)
   img(linepts(i,1),linepts(i,2)) = 1; 
end

end

function [linepts] = getlinepts(pt0,pt1)
% Return the points along the straight line connecting pt1 and pt2
if pt0(2) < pt1(2)
    x0 = pt0(2);    y0 = pt0(1);
    x1 = pt1(2);    y1 = pt1(1);
else
    x0 = pt1(2);    y0 = pt1(1);
    x1 = pt0(2);    y1 = pt0(1);
end

dx = x1 - x0;   dy = y1 - y0;
ind = 1;
linepts = zeros(numel(x0:x1),2);
step = 1;
if dx == 0 
   x = x0;
   if dy < 0,   step = -1;  end
   for y = y0:step:y1
        linepts(ind,:) = [y,x];
        ind = ind + 1;
   end
elseif abs(dy) > abs(dx)
    if dy < 0,  step = -1;  end
    for y = y0:step:y1
       x = round((dx/dy)*(y - y0) + x0);
       linepts(ind,:) = [y,x];
       ind = ind + 1;
    end
else
    for x = x0:x1
        y = round((dy/dx)*(x - x0) + y0);
        linepts(ind,:) = [y, x]; 
        ind = ind + 1;
    end
end

end
