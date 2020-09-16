% visIDX_fullTime
% from visIDX_summaryPlot_SDF


%%
% Find a way to take the first triggered stim and the second triggered and
% knit them together. This will need to be taken from the new IDX variable
% that I just made



%%
clear
close all

flag_savefigs   = 0;
norm            = 1;

IDXdir = 'G:\LaCie\Adaptdcos figs\adaptdcosCompareConditions';

IDXtextStr = 'IDX_FULLUnitAna_longSDF.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = 'G:\LaCie\Adaptdcos figs';
figName = strcat('summary_fullTime_SDF_CSD.pdf'); 

if flag_savefigs
    cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end
end

TM = IDX.tm;

monocPExPS = nan(size(IDX(1).monocSDF(:,:),2),uctLength);
condMeanSDF = nan(size(IDX(1).CondMeanSDF(:,:,1),1),size(IDX(1).CondMeanSDF(:,:,1),2),uctLength);
for uct = 1:uctLength
    condMeanSDF(:,:,uct) = IDX(uct).CondMeanSDF(:,:,1); 
    monocPExPS(:,uct)    = IDX(uct).monocSDF(1,:);
end
% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
clear IDX

%% Normalize
if norm
maxMonoc = max(max(monocPExPS));
minMonoc = min(min(monocPExPS));
condMeanSDF = (condMeanSDF - minMonoc)./(maxMonoc - minMonoc);
end

%% Sum
CondSDF = squeeze(nanmean(condMeanSDF,3));
CondSEM = (nanstd(condMeanSDF,[],3))./sqrt(uctLength); 
CondSTD = nanstd(condMeanSDF,[],3);

%% Get out variance lines
for a = 1:size(CondSDF,1)
    SEMline_Up(a,:) = CondSDF(a,:) + CondSEM(a,:);
    SEMline_Down(a,:) = CondSDF(a,:) - CondSEM(a,:);
end

for a = 1:size(CondSDF,1)
    STDline_Up(a,:) = CondSDF(a,:) + CondSTD(a,:);
    STDline_Down(a,:) = CondSDF(a,:) - CondSTD(a,:);
end



%% Set Parameters for Plot
maxYval = max(max(CondSDF));
conditName = {'Adapter:NE,PS','Suppresor:PE,PS... Cong',...
    'Adapter:PE,PS','Suppresor:NE,PS... Cong',...
    'Adapter:NE,NS','Suppresor:PE,NS... Cong',...    
    'Adapter:PE,NS','Suppresor:NE,NS... Cong',...
    'Adapter:NE,NS','Suppresor:PE,PS... Incong',...
    'Adapter:PE,PS','Suppresor:NE,NS... Incong',... 
    'Adapter:NE,PS','Suppresor:PE,NS... Incong',... 
    'Adapter:PE,NS','Suppresor:NE,PS... Incong'};

%%%%%%%%%%%%% DEV ---- BMC --- MAKE SURE YOU HAVE THE RIGHT ADAPTER
condDim      = [2 9 1 10 4 11 3 12 6 13 5 14 8 15 7 16];


%% Plot
close all

%SEM
figure
t = tiledlayout(4,4);
clear i
for i = 1:16
%'Adapter:NE,PS...
nexttile
plot(TM,CondSDF(condDim(i),:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up(condDim(i),:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down(condDim(i),:),':m','LineWidth',1); hold on
ylim([0 maxYval*1.1]);
xlim([-.05 .850])
title(conditName(i))
end
t.TileSpacing = 'compact';
t.Padding = 'compact';

    
%STD
figure
t = tiledlayout(4,4);
clear i
for i = 1:16
%'Adapter:NE,PS...
nexttile
plot(TM,CondSDF(condDim(i),:),'-b','LineWidth',2); hold on
plot(TM,STDline_Up(condDim(i),:),':m','LineWidth',1); hold on
plot(TM,STDline_Down(condDim(i),:),':m','LineWidth',1); hold on
ylim([0 maxYval*1.1]);
xlim([-.05 .850])
title(conditName(i))
end
t.TileSpacing = 'compact';
t.Padding = 'compact';



        









