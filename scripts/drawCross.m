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