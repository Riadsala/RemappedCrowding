function  doATrial(isSaccade, params, flankerCond, stimuliScrn, iLink)
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


%% now carry out trial
Eyelink('StartRecording')

% draw fix dot
stim = params.bkgrndColour * ones(params.height, params.width, 3);
stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;
tex = Screen('MakeTexture', stimuliScrn, stim);

Screen('DrawTexture', stimuliScrn, tex);
Screen(stimuliScrn, 'flip');
Screen('Close', tex);
WaitSecs(0.5);

% start clock
trialStartTime = GetSecs;
Eyelink('message', 'start_trial');
% apply dymanic white noise to target squares
gzData = dynamicWhiteNoise(0.5*rand+0.75, stim, isSaccade, targetSide, params, stimuliScrn, iLink);

% check that gaze was on central point, otherwise reject
if Check4CentralGz(gzData)
    
    % gaze was central, so carry on...
    failedCentral = 0;
    
    
    % remove fixation dot to indicate a saccade should be made
    stim = params.bkgrndColour * ones(params.height, params.width, 3);
    
    Eyelink('message', 'remove_dot');
    % display white noise until target frame
    gz = dynamicWhiteNoise(0.5, stim, isSaccade, targetSide, params, stimuliScrn, iLink);
    
    
    Eyelink('message', 'stimulus_end');
    Eyelink('Stoprecording');
    
    
    gz(:,3) = gz(:,3) - trialStartTime;
    
    
    % in SACCADE condition, so check observer fixated target
    [gazeOK saccLat]  = checkGz(gz, targetSide, params);
    
    
    clear gz gzData gzData1 gzData2 gzData3 t t0 x y
    
else
    Eyelink('message', 'stimulus_end');
    Eyelink('Stoprecording');
    failedCentral = 1;
    saccLat = NaN;
end

if ~failedCentral && gazeOK
    
    %% Trial was ok, so get responses!
    stim = 50 * ones(params.height, params.width, 3);
    stim(:,:,3) = 175;
    tex = Screen('MakeTexture', stimuliScrn, stim);
    Screen('DrawTexture', stimuliScrn, tex);
    DrawFormattedText(stimuliScrn, 'Well done!', 'center', 'center');
    Screen(stimuliScrn, 'flip');
    WaitSecs(1);
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
    
    gaborCorrect = 0;
    respC = NaN;
end

end