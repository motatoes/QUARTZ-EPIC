
function uImg = to_uint8(img)
    minVal = min(min(img));
    maxVal = max(max(img));
    uImg = uint8(255 * (img-minVal) / (maxVal - minVal));
end
