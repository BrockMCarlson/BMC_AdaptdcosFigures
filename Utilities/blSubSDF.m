function blSDF = blSubSDF(SDF,sdftm)

startTm = find(sdftm == -.05);
stopTm  = find(sdftm == 0);
for i = 1:size(SDF,1) % ch loop
    clear holder
    holder = squeeze(SDF(i,startTm:stopTm,:));
    blSubThis(i) = nanmean(holder,'all');
    blSDF(i,:,:) = SDF(i,:,:) - blSubThis(i);

end


end