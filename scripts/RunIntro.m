function RunIntro(params, iLink, stimuliScrn)



targetSide = -1;
flankerCond = 'inner';
isSaccade = 1;

[stim gaborLR targOri] = createTargetFrame(params, targetSide, isSaccade, flankerCond);


targetFrame = Screen('MakeTexture', stimuliScrn, stim);


Screen('DrawTexture', stimuliScrn, targetFrame);


DrawFormattedText(stimuliScrn, ['Target 1 is on the left and rotated to left (press f)'], 'center', 400);

% display!
Screen(stimuliScrn, 'flip');
WaitSecs(1)
KbWait;

Screen('DrawTexture', stimuliScrn, targetFrame);
DrawFormattedText(stimuliScrn, ['Target 2 is pointing up (press up)'], 'center', 400);
Screen(stimuliScrn, 'flip');
WaitSecs(1)
KbWait;

