function bigimg = fpad(img,mask)
    % Makes the image larger before creating artificial extension, so the
    % wavelet doesn't have border effects
    [sizey, sizex] = size(img);

    paderosionsize = round((sizex + sizey) / 250);
    
    bigimg = zeros(sizey + 100, sizex + 100);
    bigimg(51:(50+sizey), 51:(50+sizex)) = img;

    bigmask = logical(zeros(sizey + 100, sizex + 100));
    bigmask(51:(50+sizey), (51:50+sizex)) = mask;

    % Creates artificial extension of image.
    bigimg = fakepad(bigimg, bigmask, paderosionsize, 80);

    
end