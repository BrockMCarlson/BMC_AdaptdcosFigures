% visIDX_1600ms
% from visIDX_fullTime


%%
% Find a way to take the first triggered stim and the second triggered and
% knit them together. This will need to be taken from the new IDX variable
% that I just made



%%
clear
close all

flag_savefigs   = 0;
norm            = 0;

IDXdir = 'C:\Users\Brock\Documents\adaptdcos figs';

IDXtextStr = 'IDX_FULLUnitAna_1600sdf.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = 'G:\LaCie\Adaptdcos figs';
figName = strcat('summary_1600ms.pdf'); 

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
conditName = {'Adapter:NE,PS-Suppresor:PE,PS... Cong',...
    'Adapter:PE,PS-Suppresor:NE,PS... Cong',...
    'Adapter:NE,NS-Suppresor:PE,NS... Cong',...    
    'Adapter:PE,NS-Suppresor:NE,NS... Cong',...
    'Adapter:NE,NS-Suppresor:PE,PS... Incong',...
    'Adapter:PE,PS-Suppresor:NE,NS... Incong',... 
    'Adapter:NE,PS-Suppresor:PE,NS... Incong',... 
    'Adapter:PE,NS-Suppresor:NE,PS... Incong'};

%%%%%%%%%%%%% DEV ---- BMC --- MAKE SURE YOU HAVE THE RIGHT ADAPTER
condDim      = [2 1 4 3 6 5 8 7 ];


%% Plot
close all
spDim = [1 3 5 7 2 4 6 8];

%SEM
figure
clear i
for i = 1:8
%'Adapter:NE,PS...
subplot(4,2,spDim(i))
plot(TM,CondSDF(condDim(i),:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up(condDim(i),:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down(condDim(i),:),':m','LineWidth',1); hold on
ylim([0 maxYval*1.1]);
xlim([-.05 1.6]);
title(conditName(i))
end


    




        









