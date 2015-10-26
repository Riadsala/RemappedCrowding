function Experiment1
addpath('scripts/');



%% get subject number and randomise random seed
% subjNum = input('input subject number: ');
% RandStream('mt19937ar', 'Seed', subjNum);
% % RandStream.setDefaultStream(stream);


params.bkgrndColour = 125;
params.delta = 280;
params.N = 64; %determines spacing between adjacent boxes
params.w = 6;
params.letterSpace = 15;

params.flankerIntensity = 225;
params.targetIntensity  = 175;

params.boxW = 2;
params.boxN = 48;
params.boxColour = [50, 50, 50];
params.tboxColourSacc = [175, 25, 50];
params.tboxColourFix = [25, 50, 200];

params.Cr1 = 12;
params.Cr2 = 8;
params.Cw = 8;
params.Cphi = [0 90, 180, 270];

stimuliScrn = Screen('OpenWindow', 0, params.bkgrndColour, [001 01 1600 900]);%
[params.width, params.height]=Screen('WindowSize', stimuliScrn);%screen returns the size of the window
params.midX = round(params.width/2);
params.midY = round(params.height/2);

params.gaborAngles = [-pi/4, pi/4];

doATrial(1, params, stimuliScrn);
doATrial(0, params, stimuliScrn);


%% clean-up
sca

end

function doATrial(isSaccade, params, stimuliScrn)
%% a trial
% isSaccade = 1 if it's a saccade trial, 0 if it is a fixation tiral

stim = params.bkgrndColour * ones(params.height, params.width, 3);

% draw fix dot
stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;

% draw boxes
stim = drawAllBoxes(stim, params, isSaccade);

% make texture
tex = Screen('MakeTexture', stimuliScrn, stim);
% draw to screen
Screen('DrawTexture', stimuliScrn, tex);
% display!
Screen(stimuliScrn, 'flip');
WaitSecs(1);


% draw fixation target
gaborLR = (rand<0.5)+1;
g = GenGabor(params.boxN, params.gaborAngles(gaborLR));
g = repmat(100*g + params.bkgrndColour, [1 1 3]);
stim = drawItem2Box(stim, g, 1, 4, params);

% % make texture
% tex = Screen('MakeTexture', stimuliScrn, stim);
% % draw to screen
% Screen('DrawTexture', stimuliScrn, tex);
% % display!
% Screen(stimuliScrn, 'flip');
% WaitSecs(0.5);

% draw flankers

letter = drawLandoltC(params.boxN, params.Cphi(4), params.flankerIntensity,  params);
stim = drawItem2Box(stim, letter, -1, 1, params);

letter = drawLandoltC(params.boxN, params.Cphi(3), params.flankerIntensity,  params);
stim = drawItem2Box(stim, letter, -1, 3, params);

letter = drawLandoltC(params.boxN, params.Cphi(2), params.targetIntensity,  params);
stim = drawItem2Box(stim, letter, 1, 2, params);

% make texture
targetFrame = Screen('MakeTexture', stimuliScrn, stim);




% now apply dymanic white noise to target squares
dynamicWhiteNoise(0.5, stim, isSaccade, params, stimuliScrn);

% draw to screen
Screen('DrawTexture', stimuliScrn, targetFrame);
% display!
Screen(stimuliScrn, 'flip');
WaitSecs(0.17);


dynamicWhiteNoise(0.5, stim, isSaccade, params, stimuliScrn);

%% get response


[resp, responseKeyHit] = getObserverInput;
% 
% 

end

function dynamicWhiteNoise(duration, stim, isSaccade, params, stimuliScrn)
tic
while toc< duration
    stimNoise = stim;
    for boxPosition = 1:4
        noise = repmat(round(255*rand(params.boxN, params.boxN)), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, 1, boxPosition, params);
        noise = repmat(round(255*rand(params.boxN, params.boxN)), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, -1, boxPosition, params);
    end
    stimNoise = drawAllBoxes(stimNoise, params, isSaccade);
    % make texture
    tex = Screen('MakeTexture', stimuliScrn, stimNoise);
    Screen('DrawTexture', stimuliScrn, tex);
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.001);
end


end


function im = drawItem2Box(im, letter, side, box, params)
if side == 1
    box = box + 1;
end
x1 = params.midX - params.boxN/2 + side*params.delta - 2*params.N + (box-1)*params.N+ 1;
x2 = params.midX + params.boxN/2 + side*params.delta - 2*params.N + (box-1)*params.N;
y1 = params.midY - params.boxN/2 + 1;
y2 = params.midY + params.boxN/2;
im(y1:y2,x1:x2,:) = letter;

end

function stim = drawAllBoxes(stim, params, isSaccade)

stim  = drawBox(stim, params.midY, params.midX-params.delta-params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX-params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX-params.delta+params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX-params.delta-2*params.N, params.boxColour, params);

stim  = drawBox(stim, params.midY, params.midX+params.delta-params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX+params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX+params.delta+params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX+params.delta+2*params.N, params.boxColour, params);

% colour in target box!
if isSaccade
    stim  = drawBox(stim, params.midY, params.midX+params.delta+2*params.N, params.tboxColourSacc, params);
else
    stim  = drawBox(stim, params.midY, params.midX+params.delta+2*params.N, params.tboxColourFix, params);
end
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