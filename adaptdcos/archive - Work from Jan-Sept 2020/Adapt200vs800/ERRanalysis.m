clear
cd('C:\Users\Brock\Documents\MATLAB\diIDXdirectory')
load('ERR.mat')

clear uct hld
for uct = 1:size(ERR,2)
    hld(uct,:) = convertCharsToStrings(ERR(uct).reason);
    
end

allReasons = unique(hld);
clear i
for i = 1:size(allReasons,1)
    Reason(i).text = allReasons(i);
    Reason(i).count = sum(hld(:,:) == allReasons(i,:));
end
    