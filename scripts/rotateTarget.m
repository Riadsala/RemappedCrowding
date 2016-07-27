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