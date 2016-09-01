function DisplayMessage(message, params, stimuliScrn)
%% simple function that displays a text message on a blank background
stim = params.bkgrndColour * ones(params.height, params.width, 3);
tex = Screen('MakeTexture', stimuliScrn, stim);
Screen('DrawTexture', stimuliScrn, tex);
DrawFormattedText(stimuliScrn, message, 'center', 'center');
Screen(stimuliScrn, 'flip');
Screen('Close', tex)
WaitSecs(0.05);