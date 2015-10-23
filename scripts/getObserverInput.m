
function [resp, responseKeyHit] = getObserverInput

% check if a key has been pressed
[keyIsDown, ~, keyCode] = KbCheck;
% wait for keypress
while ~keyIsDown
    [keyIsDown, ~, keyCode] = KbCheck;
end
% check what key was pressed
if find(keyCode) == KbName('uparrow');
    responseKeyHit = 1;
    resp = 'up';
elseif find(keyCode) == KbName('rightarrow');
    responseKeyHit = 1;
    resp = 'right';
elseif find(keyCode) == KbName('downarrow');
    responseKeyHit = 1;
    resp = 'down';
elseif find(keyCode) == KbName('leftarrow');
    responseKeyHit = 1;
    resp = 'left';
elseif  find(keyCode) == KbName('q');
    responseKeyHit = 1;
    resp = -1;
else
    resp = 0;
    responseKeyHit = 0;
end
end
