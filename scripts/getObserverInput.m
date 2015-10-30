
function [resp, responseKeyHit] = getObserverInput(resp_mode)

responseKeyHit = 0;
while responseKeyHit == 0
    % check if a key has been pressed
    [keyIsDown, ~, keyCode] = KbCheck;
    % wait for keypress
    while ~keyIsDown
        [keyIsDown, ~, keyCode] = KbCheck;
    end
    % check what key was pressed
    if strcmp(resp_mode, 'gabor')
        if find(keyCode) == KbName('f');
            responseKeyHit = 1;
            resp = 'left';
        elseif find(keyCode) == KbName('j');
            responseKeyHit = 1;
            resp = 'right';
        else
            resp = 0;
            responseKeyHit = 0;
        end
        %        we are waiting for an arrow
    else
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
        else
            resp = 0;
            responseKeyHit = 0;
        end
    end
end
