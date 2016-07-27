
function gzData = dynamicWhiteNoise(duration, stim, isSaccade, targetSide, params, stimuliScrn, iLink)
duration
t0 = GetSecs;

gzData = [];
while GetSecs-t0 < duration

    evt = Eyelink('NewestFloatSample');
    x = round(max(evt.gx)) - params.midX;
    y = round(max(evt.gy)) - params.midY;
    t = GetSecs;
    gzData = [gzData; x y t];
 
    stimNoise = stim;
    
%      clear x y t    
    for boxPosition = 1:4
        noise =  repmat(127 + params.noiseMaskStd * randn(params.boxN), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, 1, boxPosition, params);
        noise =  repmat(127 + params.noiseMaskStd * randn(params.boxN), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, -1, boxPosition, params);
    end
    clear noise
    stimNoise = drawAllBoxes(stimNoise, params, isSaccade, targetSide);
    
%     x = x + params.midX;
%     x = y + params.midY;
%     stimNoise((x-5):(x+5), (y-5):(y+5),:) = 0;
    
    % make texture
    tex = Screen('MakeTexture', stimuliScrn, stimNoise);
    clear stimNoise;
    Screen('DrawTexture', stimuliScrn, tex);
    Screen(stimuliScrn, 'flip');
    Screen('Close', tex);
    WaitSecs(0.001);
   
end

end