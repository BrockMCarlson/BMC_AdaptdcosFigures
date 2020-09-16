% test
clear
close all
IDXdir = 'C:\Users\Brock\Documents\adaptdcos figs';
IDXtextStr = 'IDX_FULLUnitAna.mat';
cd(IDXdir)
load('IDX_FULLUnitAna.mat')

count = 0;
for i = 1:size(IDX,2)
    if ~isnan(IDX(i).CondMeanSDF(10,1,1))
        count = count + 1;
        AvgThis(count,:) = IDX(i).CondMeanSDF(10,:,1);
    end
end

% % Result = nanmean(AvgThis,1);
% % plot(Result)

for j = 30:82
    figure
    plot(AvgThis(j,:))
end
