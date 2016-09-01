function pregennoise = GenerateNoiseFrames(params, targetSide, isSaccade, stimuliScrn)

nNoise = 10;


stim = params.bkgrndColour * ones(params.height, params.width, 3);
stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;

for ii = 1:nNoise
    stimNoise = stim;
     for boxPosition = 1:4
        noise =  repmat(127 + params.noiseMaskStd * randn(params.boxN), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, 1, boxPosition, params);
        noise =  repmat(127 + params.noiseMaskStd * randn(params.boxN), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, -1, boxPosition, params);
    end
    clear noise
    stimNoise = drawAllBoxes(stimNoise, params, isSaccade, targetSide);
    
    pregennoise.dot(ii).tex = Screen('MakeTexture', stimuliScrn, stimNoise);
end

stim = params.bkgrndColour * ones(params.height, params.width, 3);
for ii = 1:nNoise
    stimNoise = stim;
     for boxPosition = 1:4
        noise =  repmat(127 + params.noiseMaskStd * randn(params.boxN), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, 1, boxPosition, params);
        noise =  repmat(127 + params.noiseMaskStd * randn(params.boxN), [1 1 3]);
        stimNoise = drawItem2Box(stimNoise, noise, -1, boxPosition, params);
    end
    clear noise
    stimNoise = drawAllBoxes(stimNoise, params, isSaccade, targetSide);
    
    pregennoise.nodot(ii).tex = Screen('MakeTexture', stimuliScrn, stimNoise);
end