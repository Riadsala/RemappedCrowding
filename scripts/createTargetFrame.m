function [stim gaborLR targOri] = createTargetFrame(params, targetSide, isSaccade, flankerCond)



stim = params.bkgrndColour * ones(params.height, params.width, 3);

%% create target frame
if isSaccade == 1
    % remove fixation dot to indicate a saccade should be made
    stim = params.bkgrndColour * ones(params.height, params.width, 3);
else
    % keep displaying fixation dot
    stim((params.midY-5):(params.midY+5),(params.midX-5):(params.midX+5), :) = 50;
end

%% draw target frame
% draw fixation target
gaborLR = (rand<0.5)+1;
g = GenGabor(params.boxN, params.gaborAngles(gaborLR));
g = repmat(250*g + params.bkgrndColour, [1 1 3]);
stim = drawItem2Box(stim, g, targetSide, 4, params);
clear g

% draw crosses
letter = drawCross(params.boxN, params.flankerIntensity,  0, params);
if isSaccade == 1
    if strcmp(flankerCond, 'inner')
        stim = drawItem2Box(stim, letter, -targetSide, 3, params);
    elseif strcmp(flankerCond, 'outer')
        stim = drawItem2Box(stim, letter, -targetSide, 1, params);
    elseif strcmp(flankerCond, 'both')
        stim = drawItem2Box(stim, letter, -targetSide, 3, params);
        stim = drawItem2Box(stim, letter, -targetSide, 1, params);
    else
%         leave blank
    end
else
    if strcmp(flankerCond, 'inner')
        stim = drawItem2Box(stim, letter, targetSide, 1, params);
    elseif strcmp(flankerCond, 'outer')
        stim = drawItem2Box(stim, letter, targetSide, 3, params);
    elseif strcmp(flankerCond, 'both')
        stim = drawItem2Box(stim, letter, targetSide, 1, params);
         stim = drawItem2Box(stim, letter, targetSide, 3, params);
    else
%         leave blank
    end
end

letter = drawCross(params.boxN,  params.flankerIntensity, params.offset,  params);

[targOri, letter] = rotateTarget(letter);

% letter is up by default

stim = drawItem2Box(stim, letter, targetSide, 2, params);
% draw boxes
stim = drawAllBoxes(stim, params, isSaccade, targetSide);


clear tmp letter