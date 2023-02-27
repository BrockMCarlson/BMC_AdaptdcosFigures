function [croppedSDFforSimult,croppedSdftmforSimult] = cropSDF_getSimultBRFS(SDF,STIM,sdftm)
% Crop dow to [-150 to 200 ms based on sdftm]
startTm = find(sdftm == -.050);
stopTm  = find(sdftm == .500);
croppedSdftmforSimult = sdftm(1,startTm:stopTm);
croppedSDFforSimult = SDF(:,startTm:stopTm,:);


end