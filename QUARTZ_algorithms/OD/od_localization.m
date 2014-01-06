function [x_cord,y_cord ] = od_localization(img)

    f=imresize(img,0.25);
    fg=f(:,:,2);
    sm2=medfilt2(fg,[13 13]);
    max_int = max(max(sm2));         %max values of the smoothed image
    L=find(sm2 == max_int);
    [x,y] = ind2sub(size(sm2),L);   %taking thr indices of the max values of smoothed image
    x=ceil(median(x));
    y=ceil(median(y));
    x1=x;y1=y;
%%%2nd part

    B = medfilt2(fg, [50 50]);
    img=imsubtract(B,fg);

    img1=img>9;
    img2 = deleteextra(img1, 270);
    BW2 = bwmorph(img2,'skel',Inf);
 
    long = 25; wide = 25;
    for kk = 1:50
        if isPtonImgBoundary(x,y,long,wide,BW2)
            sm2(L) = 0;
            max_int = max(max(sm2));         %max values of the smoothed image
            L=find(sm2 == max_int);
            [x,y] = ind2sub(size(sm2),L);
            x=ceil(median(x));
            y=ceil(median(y));
        elseif isNearBloodVessel(x,y,long,wide,BW2)
            break;
        else
            sm2(L) = 0;
            max_int = max(max(sm2));         %max values of the smoothed image
            L=find(sm2 == max_int);
            [x,y] = ind2sub(size(sm2),L);
            x=ceil(median(x));
            y=ceil(median(y));
        end
    end
    % kkk(k)=kk;
    if kk == 50, x = x1; y =y1; end
    x_cord = x*4;
    y_cord = y*4;
end



function out = isPtonImgBoundary( x,y,leng,widt,img)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
imgrc = size(img);
    if (x-leng > 0 && x + leng < imgrc(1) && y - widt > 0 && y+widt < imgrc(2))
        out = 0;
    else
        out = 1;
    end

end


function outNearBloodVessel = isNearBloodVessel(xin,yin, len,wid, BWimg  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if sum(sum(BWimg(xin-len:xin+len,yin-wid:yin+wid)))
    outNearBloodVessel = 1;
else
    outNearBloodVessel = 0;

end
end

function outbw = deleteextra(inbw, leng)
outbw = inbw;
[L num] = bwlabel(inbw);
for i = 1:num
    if length(find(L==i)) < leng
        outbw(find(L==i))=0;
    end
end
end   