
function fixCross = makeFixCross(N, grybk)
fixCross = grybk * ones(N);
fixCross(round(N/2), (round(N/2)-32):(round(N/2)+32)) = 0;
fixCross((round(N/2)-32):(round(N/2)+32), round(N/2)) = 0;
end