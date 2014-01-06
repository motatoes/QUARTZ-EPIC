function  imgwrite( img,name ,ext)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 
 minVal = min(min(img));
 maxVal = max(max(img));
 nImg = uint8(255 * (img-minVal) / (maxVal - minVal));
 if nargin == 3
    imwrite(nImg,[name, '.', ext],ext);
 else
    imwrite(nImg,name);
 end
 %imwrite(nImg,[name,'-n.',ext],ext);
 clear nImg;
end

