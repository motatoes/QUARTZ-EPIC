function [pointsX,pointsY] = circlePTS(cx,cy, radius, numPoints)
    ts = linspace(0,2*pi,numPoints);
    pointsX = radius*cos(ts)+cx;
    pointsY = radius*sin(ts)+cy;
end