function heldCentralGaze = Check4CentralGz(gzData)

%  mean(gzData)
%  std(gzData)
if mean(abs(gzData(:,1)))<120 && mean(gzData(:,2))<120 &&  ...
        std(gzData(:,1))<120 &&  std(gzData(:,2))<120
    heldCentralGaze = true;
else
    heldCentralGaze = false;
end