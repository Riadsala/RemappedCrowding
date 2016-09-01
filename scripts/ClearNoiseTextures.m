function ClearNoiseTextures(pregennoise)

for ii = 1:length(pregennoise.dot)
   Screen('Close', pregennoise.dot(ii).tex);
   Screen('Close', pregennoise.nodot(ii).tex);
end