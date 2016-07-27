function stim = drawAllBoxes(stim, params, isSaccade, targSide)

stim  = drawBox(stim, params.midY, params.midX - params.delta-params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX - params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX - params.delta+params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX - params.delta-2*params.N, params.boxColour, params);

stim  = drawBox(stim, params.midY, params.midX + params.delta-params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX + params.delta, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX + params.delta+params.N, params.boxColour, params);
stim  = drawBox(stim, params.midY, params.midX + params.delta+2*params.N, params.boxColour, params);

% colour in target box!
if isSaccade==1
    stim  = drawBox(stim, params.midY, params.midX + targSide*(params.delta+2*params.N), params.tboxColourSacc, params);
else
    stim  = drawBox(stim, params.midY, params.midX + targSide*(params.delta+2*params.N), params.tboxColourFix, params);
end

end


function im = drawBox(im, x, y, c, params)

for k = 1:3
    im((x-params.boxN/2):(x-params.boxN/2 + params.boxW), (y-params.boxN/2):(y+params.boxN/2), k) = c(k);
    im((x+params.boxN/2 - params.boxW):(x+params.boxN/2), (y-params.boxN/2):(y+params.boxN/2), k) = c(k);
    im((x-params.boxN/2):(x+params.boxN/2), (y-params.boxN/2):(y-params.boxN/2 + params.boxW), k) = c(k);
    im((x-params.boxN/2):(x+params.boxN/2), (y+params.boxN/2 - params.boxW):(y+params.boxN/2), k) = c(k);
end
end
