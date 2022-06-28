function [trimGammaBand,trimSdftm] = trimGammaBand(GammaBand,croppedSdftm)
% Trim to only see the transient window [50 to 150 ms based on croppedSdftm]
startTm = find(croppedSdftm == .050);
stopTm  = find(croppedSdftm == .150);
trimSdftm = croppedSdftm(1,startTm:stopTm);
trimGammaBand.data = GammaBand.data(:,startTm:stopTm,:);
trimGammaBand.highGamma_pwr = GammaBand.highGamma_pwr(:,startTm:stopTm,:);


end