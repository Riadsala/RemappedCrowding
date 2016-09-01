function [targSide, gaborCorrect, respC, targOri, saccLat, t_targOn, t_targOff] = doATrialP(isSaccade, params, flankerCond, stimuliScrn, iLink)


pracTargDisplayTime = 1;


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
% make texture
targetFrame = Screen('MakeTexture', stimuliScrn, stim);


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
Eyelink('message', 'start_trial');
% apply dymanic white noise to target squares
gzData = dynamicWhiteNoise(0.5*rand+0.75, stim, isSaccade, targetSide, params, stimuliScrn, iLink);
    
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
    
    
    singleNoiseFrame;
    
    % Display Target Frame!!!
    Screen('DrawTexture', stimuliScrn, targetFrame);
    Eyelink('message', 'target_on');
    t0 = GetSecs;
    t_targOn = Screen(stimuliScrn, 'flip') - trialStartTime;
    Screen('Close', targetFrame);
    
    % display target while collecting gaze data
    gzData2 = [];
    tic
    while GetSecs-t0 < (pracTargDisplayTime-0.01)
        evt = Eyelink('NewestFloatSample');
        x = round(max(evt.gx)) - params.midX;
        y = round(max(evt.gy)) - params.midY;
        t = GetSecs;
        gzData2 = [gzData2; x y t, 2];
        clear x y t
        WaitSecs(0.001);
    end
    toc
    
    Screen('DrawTexture', stimuliScrn, texN);
    t_targOff = Screen(stimuliScrn, 'flip', t_targOn+trialStartTime+params.targDisplayTime) - trialStartTime;
    Screen('Close', texN);
    WaitSecs(0.001);
    
    Eyelink('message', 'target_off');
    % display white noise again
    gzData3 = dynamicWhiteNoise(0.5, stim, isSaccade, targetSide, params, stimuliScrn, iLink);
    gzData3(:,4) = 3;
    Eyelink('message', 'stimulus_end');
    Eyelink('Stoprecording');
    
    gz = [gzData1; gzData2; gzData3];
    gz(:,3) = gz(:,3) - trialStartTime;
    
%     if isSaccade == 1
%         % in SACCADE condition, so check observer fixated target
%         [gazeOK saccLat]  = checkGz(gz, targetSide, params);
%     else
%         % in NO SACCADE condition, check central fixation was mantained
%         gazeOK = Check4CentralGz(gz);
%         saccLat = NaN;
%     end
    
    clear gz gzData gzData1 gzData2 gzData3 t t0 x y
    




%% Trial was ok, so get responses!
DisplayMessage('Which way was the target tilted?', params, stimuliScrn);

respG = getObserverInput('gabor');

if (strcmp(respG, 'left') && (gaborLR == 1)) || (strcmp(respG, 'right') && (gaborLR == 2))
    gaborCorrect = 1;
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,3) = 175;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Yes!', 'center', 'center');   
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.25);
    Screen('Close', tex)
else
    gaborCorrect = 0;
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,1) = 175;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Sorry, incorrect.', 'center', 'center');
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.5);
    Screen('Close', tex)
end

stim = params.bkgrndColour * ones(params.height, params.width, 3);
tex = Screen('MakeTexture', stimuliScrn, stim);
Screen('DrawTexture', stimuliScrn, tex);
Screen(stimuliScrn, 'flip');
WaitSecs(0.5);
Screen('Close', tex);

% trial was correct! now asking about crowding target
DisplayMessage('Which way round was the cross?', params, stimuliScrn);

respC = getObserverInput('cross');

if strcmp(targOri, respC) 
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,3) = 175;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Yes!', 'center', 'center');   
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.5);
   
else
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,1) = 175;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Sorry, incorrect.', 'center', 'center');
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.5);
end
Screen('Close', tex);



end