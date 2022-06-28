function [croppedSDFforInteroc,croppedSdftmforInteroc] = cropSDF_getInteroc(SDF,STIM,sdftm)
% Find trials associated with non-brfs paradigms
interocTrials = contains(STIM.task,'interoc');
taskSDF = SDF(:,:,interocTrials);

% Crop dow to [-150 to 200 ms based on sdftm]
startTm = find(sdftm == -.150);
stopTm  = find(sdftm == .350);
croppedSdftmforInteroc = sdftm(1,startTm:stopTm);
croppedSDFforInteroc = taskSDF(:,startTm:stopTm,:);


end