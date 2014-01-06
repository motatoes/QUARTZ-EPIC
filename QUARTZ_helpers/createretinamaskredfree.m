function mask = createretinamaskredfree(img)
% mask = createretinamaskredfree(img)
%
% Creates a region of interest indicating the area inside the camera's
% aperture. This function is for use with red-free images.

%
% Copyright (C) 2006  João Vitor Baldini Soares
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301, USA.
%

[l,c] = size(img);

img = double(img);

% Normalizes the image values.
mean = mean2(img);%mean(img(:));
std = std2(img);%std(img(:));
img = (img - mean) / std;

% Finding the threshold through the histogram.
range = -2.2:0.05:2.2;

h = hist(img(:), range);

% Finds a maximum at the beginning of the histogram (which should
% correspond to the pixels in the region outside the aperture).
[ignore, lower] = max(h(1:35));

% Finds the threshold as a minimum in the histogram that is after the
% dark pixels of the outside region.
[ignore, t] = min(h(lower:lower+25));
t = range(t + lower - 1);

% Thresholds.
mask = img > t;

% Makes mask larger before applying closing (so we don't get weird
% border effects).
largemask = logical(zeros(l + 30, c + 30));

largemask(15:(15 + l - 1), 15:(15 + c - 1)) = mask(:,:);

% Closing the mask.
largemask = imclose(largemask, strel('disk', 15));

%figure; imshow(largemask);
%input('asd');

% Fills in small holes.
largemask = bwareaclose(largemask, round(l * c / 40));

%figure; imshow(largemask);
%input('asd');

largemask = imopen(largemask, strel('disk', 50));

%figure; imshow(largemask);
%input('asd');

% Back to small size.
mask = largemask(15:(15 + l - 1), 15:(15 + c - 1));

% Erosion
mask = imerode(mask, strel('disk', 3));

% Removes spurious regions.
mask = bwareaopen(mask, round(l * c / 5));

%figure; imshow(mask);
%input('asd');

function bw2 = bwareaclose(bw1, n)

bw2 = ~bwareaopen(~bw1, n);