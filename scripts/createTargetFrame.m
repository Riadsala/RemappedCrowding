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

end

function c = drawCross(n, col, offset, params)
% n = dimension of output element
% w = width 
w = params.w;
c = params.bkgrndColour * ones(n,n);
c((round((n-1)/2-w/2):round(n/2+w/2))+offset, :) = col;
c(:, round((n-1)/2-w/2):round(n/2+w/2)) = col;

% c = imrotate(c, phi, 'nearest', 'crop');
% c = imfilter(c, fspecial('gaussian', 5, 1), 'replicate');
c = repmat(c, [1 1 3]);
end

function c = drawLandoltC(n, phi, col, params)
% n = dimension of output element
% r1 = outer radius
% r2 = inner radius
% w = width of cut-out
% phi = angle of cut-out
x = repmat((-n/2+1):(n/2), [n,1]);
d = x.^2 + x'.^2;
c = (d<params.Cr1^2) .* (d>params.Cr2^2);
c(1:(n/2), (n/2-params.Cw/2):(n/2+params.Cw/2)) = 0;
c(c==0) = params.bkgrndColour;
c(c==1) = col;

c = imrotate(c, phi, 'nearest', 'crop');
c = imfilter(c, fspecial('gaussian', 5, 1), 'replicate');
c = repmat(c, [1 1 3]);
end

function g = GenGabor(n, theta)
x = repmat(1:n, [n,1])-round(n/2);
y = x';

lambda =7;

phi = 0;
sigma = 4;
psi = 1;

x1 =  x.*cos(theta) + y.*sin(theta);
y1 = -x.*sin(theta) + y.*cos(theta);

z1 = x1.^2 + (psi.^2).*(y1.^2);
z2 = 2*pi*(x1./lambda) + phi;

g = exp(-(z1)./(2*sigma.^2)) .* cos(z2);
g  = 0.5*g./max(abs(g(:)));
end

function [targOri, letter] = rotateTarget(letter)
r = randi(4);
switch r
    case 1
        targOri = 'up';
    case 2
        targOri = 'left';
        for d = 1:3
            letter(:,:,d) = letter(:,:,d)';
        end
    case 3
        targOri = 'down';
        for d = 1:3
            letter(:,:,d) = letter(end:-1:1,:,d);
        end
    case 4
        targOri = 'right';
        for d = 1:3
            letter(:,:,d) = letter(end:-1:1,:,d)';
        end
end
end