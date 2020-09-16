% visIDX_2x2Summary
% from visIDX_summaryPlot_SDF


%%
% Find a way to average the 2x2 plot across every day. This should be done
% with the new IDX var that allows for even BRFS trials to give monocualr
% stim.





%%
clear
close all

flag_savefigs = 0;

IDXdir = 'G:\LaCie\Adaptdcos figs\adaptdcosCompareConditions';

IDXtextStr = 'IDX_FULLUnitAna_longSDF.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = 'G:\LaCie\Adaptdcos figs';
figName = strcat('summary_2x2_SDF.pdf'); 

cd(figDir)
if isfile(figName) && flag_savefigs
    error('figure already exists')        
end

TM = IDX.tm;

monocSDF = nan(size(IDX(1).monocSDF,1),size(IDX(1).monocSDF,2),uctLength);
for uct = 1:uctLength
    monocSDF(:,:,uct) = IDX(uct).monocSDF; 
end
% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
clear IDX



%% Sum
MonocSDF = squeeze(nanmean(monocSDF,3));
MonocSEM = (nanstd(monocSDF,[],3))./sqrt(uctLength); 
MonocSTD = nanstd(monocSDF,[],3);

%% Get out variance lines
for a = 1:4
    SEMline(a,:,1) = MonocSDF(a,:) + MonocSEM(a,:);
    SEMline(a,:,2) = MonocSDF(a,:) - MonocSEM(a,:);
end

for a = 1:4
    STDline(a,:,1) = MonocSDF(a,:) + MonocSTD(a,:);
    STDline(a,:,2) = MonocSDF(a,:) - MonocSTD(a,:);
end



%% Set Parameters for Plot
maxYval = max(max(MonocSDF));
conditName = {'PS,DE','NS,DE','PS,NDE','NS,NDE'};


%% Plot
close all
%STD plot
figure
for i = 1:4
    subplot(2,2,i)
    plot(TM(1:400),MonocSDF(i,1:400),'-b','LineWidth',2); hold on
    plot(TM(1:400),STDline(i,1:400,1),':m','LineWidth',1); hold on
    plot(TM(1:400),STDline(i,1:400,2),':m','LineWidth',1)                  
    
    ylim([0 maxYval*1.1]);
    xlim([-.05 .350])
    title(conditName{i})
    
    if i == 3
    ylabel('impulses/sec')
    xlabel('sec')
    end   
end

%SEM plot
figure
for i = 1:4
    subplot(2,2,i)
    plot(TM(1:400),MonocSDF(i,1:400),'-b','LineWidth',2); hold on
    plot(TM(1:400),SEMline(i,1:400,1),':m','LineWidth',1); hold on
    plot(TM(1:400),SEMline(i,1:400,2),':m','LineWidth',1)                  
    
    ylim([0 maxYval*1.1]);
    xlim([-.05 .350])
    title(conditName{i})
    
    if i == 3
    ylabel('impulses/sec')
    xlabel('sec')
    end   
end


% overlapping SEM line
figure
p(1:4) = plot(TM(1:400),MonocSDF(:,1:400)); hold on
plot(TM(1:400),SEMline(:,1:400,1),':','LineWidth',1); hold on
plot(TM(1:400),SEMline(:,1:400,2),':','LineWidth',1) 
legend([p(1) p(2) p(3) p(4)],conditName,'Location','northeast','Orientation','vertical')


        









