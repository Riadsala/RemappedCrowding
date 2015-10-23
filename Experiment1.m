function Experiment1
addpath('scripts/');



%% get subject number and randomise random seed
subjNum = input('input subject number: ');
RandStream('mt19937ar', 'Seed', subjNum);
% RandStream.setDefaultStream(stream);


params.bkgrndColour = 125;
params.delta = 280;
params.N = 32;
params.w = 6;
params.letterSpace = 15;
params.flankerSep = 48;
params.flankerIntensity = 225;
params.targetIntensity  = 175;

params.boxW = 2;
params.boxN = params.flankerSep;
params.boxColour = [50, 50, 50];
params.tboxColour = [25, 150, 50];

params.Cr1 = 12;
params.Cr2 = 8;
params.Cw = 8;
params.Cphi = [0 90, 180, 270];

stimuliScrn = Screen('OpenWindow', 0, params.bkgrndColour, [001 01 1600 900]);%
[params.width, params.height]=Screen('WindowSize', stimuliScrn);%screen returns the size of the window
params.midX = round(params.width/2);
params.midY = round(params.height/2);

params.gaborAngles = [-pi/4, pi/4];

%% a trial


stim = params.bkgrndColour * ones(params.height, params.width, 3);

% draw fix dot
stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;

% draw boxes
stim  = drawBox(stim, params.midY, params.midX-params.delta-params.boxN, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX-params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX-params.delta+params.boxN, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX-params.delta-2*params.boxN, params.boxColour, params);

stim  = drawBox(stim, params.midY, params.midX+params.delta-params.boxN, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX+params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX+params.delta+params.boxN, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX+params.delta+2*params.boxN, params.boxColour, params);

% colour in target box!
stim  = drawBox(stim, params.midY, params.midX+params.delta+2*params.boxN, params.tboxColour, params);


% make texture
tex = Screen('MakeTexture', stimuliScrn, stim);
% draw to screen
Screen('DrawTexture', stimuliScrn, tex);
% display!
Screen(stimuliScrn, 'flip');
WaitSecs(1);


% draw fixation target
gaborLR = (rand<0.5)+1;
g = GenGabor(params.N, params.gaborAngles(gaborLR));
g = repmat(100*g + params.bkgrndColour, [1 1 3]);
stim = drawItem2Box(stim, g, 1, 4, params);

% make texture
tex = Screen('MakeTexture', stimuliScrn, stim);
% draw to screen
Screen('DrawTexture', stimuliScrn, tex);
% display!
Screen(stimuliScrn, 'flip');
WaitSecs(0.5);

% draw flankers

letter = drawLandoltC(32, params.Cphi(4), params.flankerIntensity,  params);
stim = drawItem2Box(stim, letter, -1, 1, params);

letter = drawLandoltC(32, params.Cphi(3), params.flankerIntensity,  params);
stim = drawItem2Box(stim, letter, -1, 3, params);

letter = drawLandoltC(32, params.Cphi(2), params.targetIntensity,  params);
stim = drawItem2Box(stim, letter, 1, 2, params);

% make texture
tex = Screen('MakeTexture', stimuliScrn, stim);
% draw to screen
Screen('DrawTexture', stimuliScrn, tex);
% display!
Screen(stimuliScrn, 'flip');

[resp, responseKeyHit] = getObserverInput;
responseK


end

function im = drawItem2Box(im, letter, side, box, params)
if side == 1
    box = box + 1;
end
x1 = params.midX - params.N/2 + side*params.delta - 2*params.flankerSep + (box-1)*params.flankerSep+ 1;
x2 = params.midX + params.N/2 + side*params.delta - 2*params.flankerSep + (box-1)*params.flankerSep;
y1 = params.midY - params.N/2 + 1;
y2 = params.midY + params.N/2;
im(y1:y2,x1:x2,:) = letter;

end

function im = drawBox(im, x, y, c, params)

for k = 1:3
im((x-params.boxN/2):(x-params.boxN/2 + params.boxW), (y-params.boxN/2):(y+params.boxN/2), k) = c(k);
im((x+params.boxN/2 - params.boxW):(x+params.boxN/2), (y-params.boxN/2):(y+params.boxN/2), k) = c(k);
im((x-params.boxN/2):(x+params.boxN/2), (y-params.boxN/2):(y-params.boxN/2 + params.boxW), k) = c(k);
im((x-params.boxN/2):(x+params.boxN/2), (y+params.boxN/2 - params.boxW):(y+params.boxN/2), k) = c(k);
end
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