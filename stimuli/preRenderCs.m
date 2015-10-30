function preRenderCs


params.usePregenCs = 1;


params.targDisplayTime = 0.1;

params.bkgrndColour = 125;
params.delta = 280;
params.N = 64; %determines spacing between adjacent boxes
params.w = 6;
params.letterSpace = 15;

params.flankerIntensity = 225;
params.targetIntensity  = 225;

params.boxW = 2;
params.boxN = 48;
params.boxColour = [50, 50, 50];
params.tboxColourSacc = [175, 25, 50];
params.tboxColourFix = [25, 50, 200];

params.Cr1 = 12;
params.Cr2 = 8;
params.Cw = 8;
params.Cphi = [0 90, 180, 270];
params.CphiLabels = {'up', 'left','down', 'right'};

params.initSaccadeLatencyEst = 0.2;
params.targetDisplayLatency = params.initSaccadeLatencyEst - 0.1;



params.blockLength = 16;



params.gaborAngles = [-pi/4, pi/4];

ii = 0;
for phi = 0:90:270
    ii = ii + 1;
    landoltC{ii}  = drawLandoltC(params.boxN, phi, params.flankerIntensity,  params);
end
save(['c_.mat'], 'landoltC');
end



function c = drawLandoltC(n, phi, col, params)
% n = dimension of output element
% r1 = outer radius
% r2 = inner radius
% w = width of cut-out
% phi = angle of cut-out
x = repmat((-n/2+1):(n/2), [n,1]);
d = x.^2 + x'.^2;
c = (d<params.Cr1^2) .* (d>params.Cr2^2);
c(1:(n/2), (n/2-params.Cw/2):(n/2+params.Cw/2)) = 0;
c(c==0) = params.bkgrndColour;
c(c==1) = col;

c = imrotate(c, phi, 'nearest', 'crop');
c = imfilter(c, fspecial('gaussian', 5, 1), 'replicate');
c = repmat(c, [1 1 3]);
end