function Experiment1
addpath('scripts/');


params.usePregenCs = 1;
%% get subject number and randomise random seed
subjNum = input('input subject number: ');
RandStream('mt19937ar', 'Seed', subjNum);
% RandStream.setDefaultStream(stream);

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

stimuliScrn = Screen('OpenWindow', 0, params.bkgrndColour, [001 01 1600 900]);%
[params.width, params.height]=Screen('WindowSize', stimuliScrn);%screen returns the size of the window
params.midX = round(params.width/2);
params.midY = round(params.height/2);

params.blockLength = 16;

% change font
Screen('TextFont', stimuliScrn, 'Helvetica');
Screen('TextSize', stimuliScrn, 30);
Screen('TextColor', stimuliScrn, [255 255 255]);


params.gaborAngles = [-pi/4, pi/4];


if params.usePregenCs
   load stimuli/c_.mat
end

fid = fopen(['results/' int2str(subjNum) '_results.txt'], 'w');
fprintf(fid, 'person, block, trial, targetSide, respG, respC, c_angleT, c_angleI, c_angle_outer\n');

blk=1;
completedTrials = 0;
trl = 0;
%% Run a block
while completedTrials < params.blockLength
    [targSide, respG, respC, cAngles] = doATrial(-1, params, stimuliScrn, landoltC);
    trl = trl + 1;
    fprintf(fid, '%d %d %d %s %d %s %s %s %s\n', subjNum, blk, trl, targSide, respG, respC, cAngles.targetLabel, cAngles.innerLabel, cAngles.outerLabel);
    completedTrials = completedTrials + respG;
end
clear trl completedTrials

%% clean-up
fclose(fid);
sca

end

function [targSide, gaborCorrect, respC, cAngles] = doATrial(isSaccade, params, stimuliScrn, landoltC)
%% a trial
% isSaccade = 1 if it's a saccade trial, -1 if it is a fixation trial

% randomly decide which side the target will be on
if rand<0.5
    targetSide = -1;
else
    targetSide = 1;
end

stim = params.bkgrndColour * ones(params.height, params.width, 3);


%% draw target frame
% draw fixation target
gaborLR = (rand<0.5)+1;
g = GenGabor(params.boxN, params.gaborAngles(gaborLR));
g = repmat(100*g + params.bkgrndColour, [1 1 3]);
stim = drawItem2Box(stim, g, targetSide, 4, params);
clear g

tmp = randperm(4);
cAngles.inner = params.Cphi(tmp(1));
cAngles.innerLabel = params.CphiLabels{tmp(1)};
cAngles.outer = params.Cphi(tmp(2));
cAngles.outerLabel = params.CphiLabels{tmp(1)};
cAngles.target = params.Cphi(tmp(3));
cAngles.targetLabel = params.CphiLabels{tmp(3)};


% draw letters
if params.usePregenCs==1
    letter = drawLandoltC(params.boxN, tmp(1), params.flankerIntensity,  params);
    stim = drawItem2Box(stim, letter, -targetSide*isSaccade, 1, params);
    
    letter = drawLandoltC(params.boxN, tmp(2), params.flankerIntensity,  params);
    stim = drawItem2Box(stim, letter, -targetSide*isSaccade, 3, params);
    
    letter = drawLandoltC(params.boxN, tmp(3), params.targetIntensity,  params);
    stim = drawItem2Box(stim, letter, targetSide, 2, params);
else
    letter = drawLandoltC(params.boxN, cAngles.inner, params.flankerIntensity,  params);
    stim = drawItem2Box(stim, letter, -targetSide*isSaccade, 1, params);
    
    letter = drawLandoltC(params.boxN, cAngles.outer, params.flankerIntensity,  params);
    stim = drawItem2Box(stim, letter, -targetSide*isSaccade, 3, params);
    
    letter = drawLandoltC(params.boxN, cAngles.target, params.targetIntensity,  params);
    stim = drawItem2Box(stim, letter, targetSide, 2, params);
end
clear tmp letter

% draw boxes
stim = drawAllBoxes(stim, params, isSaccade, targetSide);

% make texture
targetFrame = Screen('MakeTexture', stimuliScrn, stim);

%% now carry out trial
% draw fix dot
stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;
% apply dymanic white noise to target squares
whiteNoiseDur = 0.5*rand+0.75;
dynamicWhiteNoise(whiteNoiseDur, stim, isSaccade, targetSide, params, stimuliScrn);

% remove fixation dot to indicate a saccade should be made
stim = params.bkgrndColour * ones(params.height, params.width, 3);
t0 = GetSecs;
% display white noise until target frame
dynamicWhiteNoise(params.targetDisplayLatency, stim, isSaccade, targetSide, params, stimuliScrn);
% draw to screen
Screen('DrawTexture', stimuliScrn, targetFrame);
% display!
Screen(stimuliScrn, 'flip');
Screen('Close', targetFrame);
WaitSecs(params.targDisplayTime);

% display white noise again
dynamicWhiteNoise(0.5, stim, isSaccade, targetSide, params, stimuliScrn);

%% get response
stim = params.bkgrndColour * ones(params.height, params.width, 3);
tex = Screen('MakeTexture', stimuliScrn, stim);
Screen('DrawTexture', stimuliScrn, tex);
DrawFormattedText(stimuliScrn, 'Which way was the target tilted?', 'center', 'center');
Screen(stimuliScrn, 'flip');
Screen('clear', 'tex')
WaitSecs(0.1);
respG = getObserverInput('gabor');

if (strcmp(respG, 'left') && (gaborLR == 1)) || (strcmp(respG, 'right') && (gaborLR == 2))
    gaborCorrect = 1;
    % trial was correct! now asking about crowding target
    stim = params.bkgrndColour * ones(params.height, params.width, 3);
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.2);
    Screen('clear', 'tex');
    
    stim = params.bkgrndColour * ones(params.height, params.width, 3);
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Which way round was the C?', 'center', 'center');
    Screen(stimuliScrn, 'flip');
    Screen('clear', 'tex');
    WaitSecs(0.1);
    Screen('clear', 'tex')
    respC = getObserverInput('landoltC');
else
    gaborCorrect = 0;
    % Gabor query incorrect. Provide negative feedback
    stim = 100 * ones(params.height, params.width, 3);
    stim(:,:,1) = 175;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Sorry, that was incorrect', 'center', 'center');
    Screen(stimuliScrn, 'flip');
    WaitSecs(1);
    Screen('clear', 'tex')
    
    respC = NaN;
end

if targetSide == -1
    targSide = 'left';
else
    targSide = 'right';
end

end

function dynamicWhiteNoise(duration, stim, isSaccade, targetSide, params, stimuliScrn)
tic
while toc< duration
    stimNoise = stim;
    for boxPosition = 1:4
        noise = repmat(round(255*rand(params.boxN, params.boxN)), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, 1, boxPosition, params);
        noise = repmat(round(255*rand(params.boxN, params.boxN)), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, -1, boxPosition, params);
    end
    stimNoise = drawAllBoxes(stimNoise, params, isSaccade, targetSide);
    % make texture
    tex = Screen('MakeTexture', stimuliScrn, stimNoise);
    clear stimNoise;
    Screen('DrawTexture', stimuliScrn, tex);
    Screen(stimuliScrn, 'flip');
    Screen('Close', tex);
    WaitSecs(0.001);
end

end

function im = drawItem2Box(im, letter, side, box, params)
if side == 1
    box = box + 1;
else
    box = 5-box;
end
x1 = params.midX - params.boxN/2 + side*params.delta - 2*params.N + (box-1)*params.N+ 1;
x2 = params.midX + params.boxN/2 + side*params.delta - 2*params.N + (box-1)*params.N;
y1 = params.midY - params.boxN/2 + 1;
y2 = params.midY + params.boxN/2;
im(y1:y2,x1:x2,:) = letter;

end

function stim = drawAllBoxes(stim, params, isSaccade, targSide)

stim  = drawBox(stim, params.midY, params.midX - params.delta-params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX - params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX - params.delta+params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX - params.delta-2*params.N, params.boxColour, params);

stim  = drawBox(stim, params.midY, params.midX + params.delta-params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX + params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX + params.delta+params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX + params.delta+2*params.N, params.boxColour, params);

% colour in target box!
if isSaccade==1
    stim  = drawBox(stim, params.midY, params.midX + targSide*(params.delta+2*params.N), params.tboxColourSacc, params);
else
    stim  = drawBox(stim, params.midY, params.midX + targSide*(params.delta+2*params.N), params.tboxColourFix, params);
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