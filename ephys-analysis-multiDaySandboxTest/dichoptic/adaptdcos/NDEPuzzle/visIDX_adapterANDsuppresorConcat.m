%% visIDX_adapterANDsuppresorConcat
% from visIDX_fullTime


%%
% Find a way to take the first triggered stim and the second triggered and
% knit them together. This will need to be taken from the new IDX variable
% that I just made



%%
clear
close all

flag_savefigs   = 1;
norm            = 0;

IDXdir = 'C:\Users\Brock\Documents\MATLAB\GitHub\ephys-analysis\dichoptic\adaptdcos\NDEPuzzle';

IDXtextStr = 'diIDX_AandS_norm.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = IDXdir;
figName = strcat('diIDX_AandS_norm.pdf'); 

if flag_savefigs
    cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end
end

TM = IDX.tm;

SDFbyUnit_A = nan(size(IDX(1).SDF_A,1),size(IDX(1).SDF_A,2),uctLength);
SDFbyUnit_S = nan(size(IDX(1).SDF_S,1),size(IDX(1).SDF_S,2),uctLength);

for uct = 1:uctLength
    SDFbyUnit_A(:,:,uct) = IDX(uct).SDF_A(:,:);
    SDFbyUnit_S(:,:,uct) = IDX(uct).SDF_S(:,:);    
end
% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
clear IDX

%% Normalize


%% Sum
SDFavg_A = squeeze(nanmean(SDFbyUnit_A,3));
SDFavg_S = squeeze(nanmean(SDFbyUnit_S,3));

STD_A = nanstd(SDFbyUnit_A,[],3); 
STD_S = nanstd(SDFbyUnit_S,[],3); 

%% Get out variance lines
for a = 1:size(SDFavg_A,1)
    SEMline_Up_A(a,:) = SDFavg_A(a,:) + STD_A(a,:);
    SEMline_Down_A(a,:) = SDFavg_A(a,:) - STD_A(a,:);
    SEMline_Up_S(a,:) = SDFavg_S(a,:) + STD_S(a,:);
    SEMline_Down_S(a,:) = SDFavg_S(a,:) - STD_S(a,:);
end




%% Set Parameters for Plot
maxYval_A = max(max(SDFavg_A));
maxYval_S = max(max(SDFavg_S));
maxYval = max(maxYval_A,maxYval_S);

conditNameA = {...
    'adpDExPS_flC',...
    'adpNDExPS_flC',...
    'adpDExNS_flC',...
    'adpNDExNS_flC',...
    'adpDExPS_flIC',...
    'adpNDExPS_flIC',...
    'adpDExNS_flIC',...
    'adpNDExNS_flIC',...
    };

conditNameS = {...
    'adpC_flNDExPS',...
    'adpC_flDExPS',...
    'adpC_flNDExNS',...
    'adpC_flDExNS',...
    'adpIC_flNDExNS',...
    'adpIC_flDExNS',...
    'adpIC_flNDExPS',...
    'adpIC_flDExPS_flIC',...
    };


%% Plot
subplotdim = [2 1 4 3 8 7 6 5];
count = 0;
%SEM   
figure
clear i
for i = 1:8
count = count + 1;
subplot(4,4,count)
plot(TM,SDFavg_A(subplotdim(i),:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up_A(subplotdim(i),:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down_A(subplotdim(i),:),':m','LineWidth',1); hold on
ylim([0 1]);
xlim([-.05 .8]);
title(conditNameA(subplotdim(i)), 'interpreter', 'none')

count = count + 1;
subplot(4,4,count)
plot(TM,SDFavg_S(subplotdim(i),:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up_S(subplotdim(i),:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down_S(subplotdim(i),:),':m','LineWidth',1); hold on
ylim([0 1]);
xlim([-.05 .8]);
title(conditNameS(subplotdim(i)), 'interpreter', 'none')
end


    




        








     
 