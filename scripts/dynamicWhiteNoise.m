function gzData = dynamicWhiteNoise(duration,  pregennoise,  params, stimuliScrn)

duration = min(duration, 1.500);
t0 = GetSecs;

gzData = [];
while GetSecs-t0 < duration

    if Eyelink('NewFloatSampleAvailable')
    evt = Eyelink('NewestFloatSample');
    
        x = round(max(evt.gx)) - params.midX;
        y = round(max(evt.gy)) - params.midY;
        t = GetSecs;
        gzData = [gzData; x y t];
    end
    Screen('DrawTexture', stimuliScrn, pregennoise(randi(10)).tex);
    Screen(stimuliScrn, 'flip');
    WaitSecs(0.001);

end

end