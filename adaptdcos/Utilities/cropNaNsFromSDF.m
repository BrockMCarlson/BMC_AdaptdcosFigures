function [croppedSDF,croppedSdftm] = cropNaNsFromSDF(SDF,STIM,sdftm)
% Find trials associated with non-brfs paradigms
nonBrfsTrials = ((~strcmp(STIM.task,'brfs')) & (~strcmp(STIM.task,'dbrfs')));
taskSDF = SDF(:,:,nonBrfsTrials);

% Crop dow to [-150 to 200 ms based on sdftm]
startTm = find(sdftm == -.150);
stopTm  = find(sdftm == .200);
croppedSdftm = sdftm(1,startTm:stopTm);
croppedSDF = taskSDF(:,startTm:stopTm,:);


end