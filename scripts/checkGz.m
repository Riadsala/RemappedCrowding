function [gazeOk saccadeLat] = checkGz(gz, targetSide, params);

% get centre of target (x) position
if targetSide == 1
    targetX = targetSide*params.delta - 2*params.N + 4*params.N + 1;
else
    targetX = targetSide*params.delta - 2*params.N + 0*params.N + 1;
end


lookingAtCentre = abs(gz(:,1)) < 100;
lookingAtTarget = 2*(abs((gz(:,1) - targetX)) < 100);

aoi = [max(lookingAtCentre, lookingAtTarget) gz(:,3)];

if aoi(1,1) == 1 && aoi(end,1) == 2
    gazeOk = true;
    saccadeLat = max(aoi(aoi==1,2)) - aoi(1,2);
else
    gazeOk = false;
    saccadeLat = NaN;
end