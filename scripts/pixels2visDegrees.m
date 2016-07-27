function vd = pixels2visDegrees(px, params)




widthOfDisplay  = 545;
% first turn pixels into mm
pixelsOnScreen = 1680; %params.width;

sizeOfPx = widthOfDisplay / pixelsOnScreen

pxDistance = px * sizeOfPx;

vd = 180*atan2(pxDistance, params.chinrestDist)/pi;
