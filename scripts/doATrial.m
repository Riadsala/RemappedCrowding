function [targSide, gaborCorrect, respC, targOri, saccLat, t_dotRemove, t_targOn, t_targOff] = doATrial(isSaccade, tctr, params, flankerCond, stimuliScrn, iLink)
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

% init targ_on and targ_off in case they are not set during trial
t_targOn  = 0;
t_targOff = 0;

%% create target frame
[stim gaborLR targOri] = createTargetFrame(params, targetSide, isSaccade, flankerCond);

% pre-gen some noise frames
pregennoise = GenerateNoiseFrames(params, targetSide, isSaccade, stimuliScrn);

% make texture
targetFrame = Screen('MakeTexture', stimuliScrn, stim);
singleNoiseFrame;
%% now carry out trial
Eyelink('StartRecording')
% draw fix dot

stim = params.bkgrndColour * ones(params.height, params.width, 3);
stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;
tex = Screen('MakeTexture', stimuliScrn, stim);


Screen('DrawTexture', stimuliScrn, tex);
Screen(stimuliScrn, 'flip');
Screen('Close', tex);
WaitSecs(0.2);

% start clock
trialStartTime = GetSecs;
Eyelink('message', ['start_trial_', int2str(tctr)]);

% apply dymanic white noise to target squares
gzData = dynamicWhiteNoise(0.5*rand+0.75, pregennoise.dot,  params, stimuliScrn);

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
    t_dotRemove = GetSecs - trialStartTime;
    Eyelink('message', 'remove_dot');
    
    % display white noise until target frame
    if isSaccade == 1
    gzData1 = dynamicWhiteNoise(params.targetDisplayLatency, pregennoise.nodot, params, stimuliScrn);
    else
        gzData1 = dynamicWhiteNoise(params.targetDisplayLatency, pregennoise.dot, params, stimuliScrn);
    end
    gzData1(:,4) = 1;
    % Display Target Frame!!!
    Screen('DrawTexture', stimuliScrn, targetFrame);
    Eyelink('message', 'target_on');
    t0 = GetSecs;  
    t_targOn = Screen(stimuliScrn, 'flip') - trialStartTime;%
        
    % display target while collecting gaze data
    gzData2 = [];
    while GetSecs-t0 < (params.targDisplayTime)
        evt = Eyelink('NewestFloatSample');
        x = round(max(evt.gx)) - params.midX;
        y = round(max(evt.gy)) - params.midY;
        t = GetSecs;
        gzData2 = [gzData2; x y t, 2];
        clear x y t
        WaitSecs(0.001);
    end
    
    Screen('DrawTexture', stimuliScrn, texN);
    t_targOff = Screen(stimuliScrn, 'flip') - trialStartTime;
    Screen('Close', texN);
    WaitSecs(0.001);
    
    Eyelink('message', 'target_off');
    % display white noise again
    if isSaccade == 1
        gzData3 = dynamicWhiteNoise(0.5, pregennoise.nodot,  params, stimuliScrn);
    else
        gzData3 = dynamicWhiteNoise(0.5, pregennoise.dot,  params, stimuliScrn);
    end
    gzData3(:,4) = 3;
    Eyelink('message', ['stimulus_end_', int2str(tctr)]);
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
    Screen('Close', targetFrame);
else
    Eyelink('message', 'stimulus_end');
    Eyelink('Stoprecording');
    failedCentral = 1;
    saccLat = NaN;
    t_dotRemove = NaN;
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
    
    stim = params.bkgrndColour * ones(params.height, params.width, 3);
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.25);
    Screen('Close', tex);
    
    % trial was correct! now asking about crowding target
    DisplayMessage('Which way round was the cross?', params, stimuliScrn);
    
    respC = getObserverInput('cross');
    stim = params.bkgrndColour * ones(params.height, params.width, 3);
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.25);
    Screen('Close', tex);
    
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
    
    gaborCorrect = NaN;
    respC = NaN;
end
ClearNoiseTextures(pregennoise)
end