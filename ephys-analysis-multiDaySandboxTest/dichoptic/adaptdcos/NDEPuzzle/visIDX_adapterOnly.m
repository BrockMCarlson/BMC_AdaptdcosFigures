%% visIDX_adapterOnly
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

IDXdir = 'C:\Users\Brock\Documents\MATLAB\GitHub\ephys-analysis\dichoptic\adaptdcos\NDEPuzzle';

IDXtextStr = 'diIDX_adapterOnly.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = IDXdir;
figName = strcat('adapterOnly.pdf'); 

if flag_savefigs
    cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end
end

TM = IDX.tm;

SDFbyUnit = nan(size(IDX(1).CondMeanSDF,1),size(IDX(1).CondMeanSDF,2),uctLength);
for uct = 1:uctLength
    SDFbyUnit(:,:,uct) = IDX(uct).CondMeanSDF(:,:); 
end
% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
clear IDX

%% Normalize


%% Sum
SDFavg = squeeze(nanmean(SDFbyUnit,3));
STD = nanstd(SDFbyUnit,[],3); 

%% Get out variance lines
for a = 1:size(SDFavg,1)
    SEMline_Up(a,:) = SDFavg(a,:) + STD(a,:);
    SEMline_Down(a,:) = SDFavg(a,:) - STD(a,:);
end




%% Set Parameters for Plot
maxYval = max(max(SDFavg));
conditName = {...
    'adpDExPS_flC',...
    'adpNDExPS_flC',...
    'adpDExNS_flC',...
    'adpNDExNS_flC',...
    'adpDExPS_flIC',...
    'adpNDExPS_flIC',...
    'adpDExNS_flIC',...
    'adpNDExNS_flIC',...
    };


%% Plot

%SEM
figure
clear i
for i = 1:8
%'Adapter:NE,PS...
subplot(4,2,i)
plot(TM,SDFavg(i,:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up(i,:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down(i,:),':m','LineWidth',1); hold on
ylim([0 maxYval*1.5]);
xlim([-.05 1.6]);
title(conditName(i), 'interpreter', 'none')
end


    




        









