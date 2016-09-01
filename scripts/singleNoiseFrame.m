%% Create a single frame of noise for timestamping purposes

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


% make texture
texN = Screen('MakeTexture', stimuliScrn, stimNoise);
clear stimNoise;