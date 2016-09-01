function heldCentralGaze = Check4CentralGz(gzData)

%  mean(gzData)
%  std(gzData)
if mean(abs(gzData(:,1)))<40 && mean(gzData(:,2))<40 &&  ...
        std(gzData(:,1))<60 &&  std(gzData(:,2))<60
    heldCentralGaze = true;
else
    heldCentralGaze = false;
end