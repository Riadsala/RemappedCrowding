function Experiment1_2


addpath('scripts/');


trialsPerCondition = 12;

% get subject number and randomise random seed
subjNum = input('input subject number: ');
RandStream('mt19937ar', 'Seed', subjNum);

% open file for writing results
fid = fopen(['results/' int2str(subjNum) '_results.txt'], 'w');
fprintf(fid, 'person, block, trial, flankerSide, targetSide, respG, respC, targOri, saccStart\n');

% get parameters for experiment
getParams;

%% Set-up stuff!
% set up screen
stimuliScrn = Screen('OpenWindow', 1, params.bkgrndColour);%
[params.width, params.height]=Screen('WindowSize', stimuliScrn);%screen returns the size of the window
params.midX = round(params.width/2);
params.midY = round(params.height/2);
% set up eyelink
iLink.edfdatafilename = strcat('cwdrmp', int2str(subjNum), '.edf');
iLink = InitEyeLink(iLink, stimuliScrn);
% change font
Screen('TextFont', stimuliScrn, 'Helvetica');
Screen('TextSize', stimuliScrn, 30);
Screen('TextColor', stimuliScrn, [255 255 255]);

%% some information and practise
RunIntro(params, iLink, stimuliScrn);


%% RUN BLOCKS
blocks = [1 2 1 2 1 2 1 2 1 2]; % saccade - no saccade

for blk = blocks
    %% introduce and initalise block
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,2) = 100;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    
    % display block intro message
    if blk == 1
        DrawFormattedText(stimuliScrn, 'Block condition: please fixate the target when dot vanishes', 'center', 'center');
    else
        DrawFormattedText(stimuliScrn, 'Block condition: please keep fixating the fixation dot', 'center', 'center');
    end
    Screen(stimuliScrn, 'flip');
    Screen('Close', tex);
    WaitSecs(1);
    KbWait;
    % calibrate eyetracker
    EyelinkDoTrackerSetup(iLink.el);
    
    % create list of flanker condition for each trial
    flankerCond = repmat({'inner', 'outer', 'none'}, [1, trialsPerCondition]);
    flankerCond = flankerCond(randperm(length(flankerCond)));
    
    % create empty arry af saccadic start times for this block
    saccStartTimes = [];
    
    %% Run a block
    for trl = 1:length(flankerCond)
        
        % run a trial
        [targSide, respG, respC, targOri, saccStart] = doATrial(blk, params, flankerCond{trl}, stimuliScrn, iLink);
        
        % update estimate of saccadic latency based on trial
        if isfinite(saccStart)
            saccStartTimes = [saccStartTimes, saccStart]; %#ok<AGROW>
            params.targetDisplayLatency = median(saccStartTimes)-0.1;
        end
        
        % save trial data
        fprintf(fid, '%d %d %d %s %s %d %s %s %f\n', subjNum, blk, trl, flankerCond{trl}, targSide, respG, respC, targOri, saccStart);
        
    end
    
end

stim = 50 * ones(params.height, params.width, 3);
tex = Screen('MakeTexture', stimuliScrn, stim);
Screen('DrawTexture', stimuliScrn, tex);
DrawFormattedText(stimuliScrn, 'Thank you for your time!', 'center', 'center');
Screen(stimuliScrn, 'flip');
Screen('Close', tex);
WaitSecs(5);

%% clean-up
Eyelink('ReceiveFile',[iLink.edfdatafilename]);
fclose(fid);
Eyelink('Shutdown')
sca

end

function [targSide, gaborCorrect, respC, targOri, saccLat] = doATrial(isSaccade, params, flankerCond, stimuliScrn, iLink)
%% a trial
% isSaccade = 1 if it's a saccade trial, 2 if it is a fixation trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% randomly decide which side the target will be on
if rand<0.5
    targetSide = -1;
    targSide = 'left';
else
    targetSide = 1;
    targSide = 'right';
end

%% create target frame
[stim gaborLR targOri] = createTargetFrame(params, targetSide, isSaccade, flankerCond);
% make texture
targetFrame = Screen('MakeTexture', stimuliScrn, stim);


%% now carry out trial
Eyelink('StartRecording')
% draw fix dot
stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;

% start clock
trialStartTime = GetSecs;
Eyelink('message', 'start_trial');
% apply dymanic white noise to target squares
gzData = dynamicWhiteNoise(0.5*rand+0.75, stim, isSaccade, targetSide, params, stimuliScrn, iLink);

% check that gaze was on central point, otherwise reject
if Check4CentralGz(gzData)
   
    % gaze was central, so carry on...
    failedCentral = 0;
    
    if isSaccade == 1
        % remove fixation dot to indicate a saccade should be made
        stim = params.bkgrndColour * ones(params.height, params.width, 3);
    else
        % keep displaying fixation dot
        stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;
    end
    Eyelink('message', 'remove_dot');
    % display white noise until target frame
    gzData1 = dynamicWhiteNoise(params.targetDisplayLatency, stim, isSaccade, targetSide, params, stimuliScrn, iLink);
    gzData1(:,4) = 1;
    
    t0 = GetSecs;
    
    % Display Target Frame!!!    
    Screen('DrawTexture', stimuliScrn, targetFrame);
    Eyelink('message', 'target_on');
    Screen(stimuliScrn, 'flip');
    Screen('Close', targetFrame);
    
    % display target while collecting gaze data
    gzData2 = [];
    while GetSecs-t0 < params.targDisplayTime        
        evt = Eyelink('NewestFloatSample');
        x = round(max(evt.gx)) - params.midX;
        y = round(max(evt.gy)) - params.midY;
        t = GetSecs;
        gzData2 = [gzData2; x y t, 2];
        clear x y t
        WaitSecs(0.01);
    end
    Eyelink('message', 'target_off');
    % display white noise again
    gzData3 = dynamicWhiteNoise(0.5, stim, isSaccade, targetSide, params, stimuliScrn, iLink);
    gzData3(:,4) = 3;
    Eyelink('message', 'stimulus_end');
    Eyelink('Stoprecording');
    
    gz = [gzData1; gzData2; gzData3];
    gz(:,3) = gz(:,3) - trialStartTime;
    
    if isSaccade == 1
        % in SACCADE condition, so check observer fixated target
        [gazeOK saccLat]  = checkGz(gz, targetSide, params);
    else
        % in NO SACCADE condition, check central fixation was mantained
        gazeOK = Check4CentralGz(gz);
        saccLat = NaN;
    end
    
    clear gz gzData gzData1 gzData2 gzData3 t t0 x y
    
else
    failedCentral = 1;
    saccLat = NaN;
end

if ~failedCentral && gazeOK   
    
    %% Trial was ok, so get responses!
    DisplayMessage('Which way was the target tilted?', params, stimuliScrn);
    
    respG = getObserverInput('gabor');
    
    if (strcmp(respG, 'left') && (gaborLR == 1)) || (strcmp(respG, 'right') && (gaborLR == 2))
        gaborCorrect = 1;
    else
        gaborCorrect = 0;
    end
    % trial was correct! now asking about crowding target
    stim = params.bkgrndColour * ones(params.height, params.width, 3);
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.2);
    Screen('Close', tex);
    
    stim = 50 * ones(params.height, params.width, 3);
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Which way round was the cross?', 'center', 'center');
    Screen(stimuliScrn, 'flip');
    Screen('Close', tex);
    WaitSecs(0.1);
    
    respC = getObserverInput('cross');
else
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,1) = 175;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    if failedCentral
        DrawFormattedText(stimuliScrn, 'Please mantain central fixation', 'center', 'center');
    else
        if isSaccade == 1
            DrawFormattedText(stimuliScrn, 'Please move your eyes to the target', 'center', 'center');
        else
            DrawFormattedText(stimuliScrn, 'Please mantain central fixation', 'center', 'center');
        end
    end
    Screen(stimuliScrn, 'flip');
    WaitSecs(1);
    Screen('Close', tex)
    
    gaborCorrect = 0;
    respC = NaN;
end

end
