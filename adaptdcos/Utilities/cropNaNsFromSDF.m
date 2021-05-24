function croppedSDF = cropNaNsFromSDF(SDF)
croppedSDF = nan(size(SDF,1),size(SDF,2)-2,size(SDF,3));
for i = 1:size(SDF,1)
    for j = 1:size(SDF,3)
       clear holder
       holder = SDF(i,:,j);
       nanCount(i,j) = sum(isnan(holder));
       croppedSDF(i,:,j) = holder(1,1:end-2);
    end

end

lengthOut = find(nanCount > 3);
if ~isempty(lengthOut)
    error('Too many NaNs')
end

end