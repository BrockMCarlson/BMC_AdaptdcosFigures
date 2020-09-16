%% visIDX_PairwiseComp
% from visIDX_NDEPuzzle


%%
% Find a way to take the first triggered stim and the second triggered and
% knit them together. This will need to be taken from the new IDX variable
% that I just made



%%
clear
close all

flag_savefigs   = 1;
variance = 'SEM';

IDXdir = 'C:\Users\Brock\Documents\MATLAB\diIDXdirectory';

IDXtextStr = 'diIDX_PairwiseComp.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = IDXdir;
figName = strcat('diIDX_PairwiseComp.pdf'); 

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



%% Sum
SDFavg_A = squeeze(nanmean(SDFbyUnit_A,3));
SDFavg_S = squeeze(nanmean(SDFbyUnit_S,3));

%% STD
STD_A = nanstd(SDFbyUnit_A,[],3); 
STD_S = nanstd(SDFbyUnit_S,[],3); 

%% SEM
SEM_A = (nanstd(SDFbyUnit_A,[],3))./sqrt(uctLength);
SEM_S = (nanstd(SDFbyUnit_S,[],3))./sqrt(uctLength);

%% Confidence interval calculation - for both adapter and suppressor
clear x 
for x = 1:2
    if x == 1
        SEM = nanstd(SDFbyUnit_A,[],3)/sqrt(uctLength);	% Standard Error
        ts = tinv(0.99,uctLength-1);                   % T-Score at the 99th percentile
        CI = squeeze(nanmean(SDFbyUnit_A,3))+ ts*SEM;          % Confidence Intervals
        CI_A(:,:) = CI;
    else
        SEM = nanstd(SDFbyUnit_S,[],3)/sqrt(uctLength);	% Standard Error
        ts = tinv(0.99,uctLength-1);                   % T-Score at the 99th percentile
        CI = squeeze(nanmean(SDFbyUnit_S,3))+ ts*SEM;          % Confidence Intervals
        CI_S(:,:) = CI;
    end
  
end


%% Get out variance lines
switch variance
    case 'STD'
        varUsedA = STD_A;
        varUsedS = STD_S;
    case 'SEM'
        varUsedA = SEM_A;
        varUsedS = SEM_S;        
    case 'CI'
        varUsedA = CI_A;
        varUsedS = CI_S;
end
for a = 1:size(SDFavg_A,1)
    SEMline_Up_A(a,:) = SDFavg_A(a,:) + varUsedA(a,:);
    SEMline_Down_A(a,:) = SDFavg_A(a,:) - varUsedA(a,:);
    SEMline_Up_S(a,:) = SDFavg_S(a,:) + varUsedS(a,:);
    SEMline_Down_S(a,:) = SDFavg_S(a,:) - varUsedS(a,:);
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
% Every comparison
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
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
title(conditNameA(subplotdim(i)), 'interpreter', 'none')

count = count + 1;
subplot(4,4,count)
plot(TM,SDFavg_S(subplotdim(i),:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up_S(subplotdim(i),:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down_S(subplotdim(i),:),':m','LineWidth',1); hold on
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
title(conditNameS(subplotdim(i)), 'interpreter', 'none')
end

%same stim diff history comparison - dont isolate eye
PS_A = (SDFavg_A(6,:) + SDFavg_A(5,:))./2;
NS_S = (SDFavg_S(6,:) + SDFavg_S(5,:))./2;
NS_A = (SDFavg_A(8,:) + SDFavg_A(7,:))./2;
PS_S = (SDFavg_S(8,:) + SDFavg_S(7,:))./2;

figure
subplot(1,2,1)
plot(TM,PS_A,'-b','LineWidth',2); hold on
% % plot(TM,SEMline_Up_A(5,:),':b','LineWidth',1); hold on
% % plot(TM,SEMline_Down_A(5,:),':b','LineWidth',1); hold on
plot(TM,NS_A,'-m','LineWidth',2); hold on
% % plot(TM,SEMline_Up_A(8,:),':m','LineWidth',1); hold on
% % plot(TM,SEMline_Down_A(8,:),':m','LineWidth',1); hold on
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
legend('PS-A','NS-A')

subplot(1,2,2)
plot(TM,NS_S,'-b','LineWidth',2); hold on
% % plot(TM,SEMline_Up_A(5,:),':b','LineWidth',1); hold on
% % plot(TM,SEMline_Down_A(5,:),':b','LineWidth',1); hold on
plot(TM,PS_S,'-m','LineWidth',2); hold on
% % plot(TM,SEMline_Up_A(8,:),':m','LineWidth',1); hold on
% % plot(TM,SEMline_Down_A(8,:),':m','LineWidth',1); hold on
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
legend('NS-S','PS-S')


% same stim diff history comparison - isolate eye - 2x2 comparison
 
figure
subplot(2,2,1)
plot(TM,SDFavg_A(5,:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up_A(5,:),':b','LineWidth',1); hold on
plot(TM,SEMline_Down_A(5,:),':b','LineWidth',1); hold on
plot(TM,SDFavg_A(8,:),'-m','LineWidth',2); hold on
plot(TM,SEMline_Up_A(8,:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down_A(8,:),':m','LineWidth',1); hold on
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
legend('DE-PS','NDE-NS')

subplot(2,2,2)
plot(TM,SDFavg_S(5,:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up_S(5,:),':b','LineWidth',1); hold on
plot(TM,SEMline_Down_S(5,:),':b','LineWidth',1); hold on
plot(TM,SDFavg_S(8,:),'-m','LineWidth',2); hold on
plot(TM,SEMline_Up_S(8,:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down_S(8,:),':m','LineWidth',1); hold on
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
legend('NDE-NS','DE-PS')

subplot(2,2,3)
plot(TM,SDFavg_A(6,:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up_A(6,:),':b','LineWidth',1); hold on
plot(TM,SEMline_Down_A(6,:),':b','LineWidth',1); hold on
plot(TM,SDFavg_A(7,:),'-m','LineWidth',2); hold on
plot(TM,SEMline_Up_A(7,:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down_A(7,:),':m','LineWidth',1); hold on
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
legend('NDE-PS','DE-NS')

subplot(2,2,4)
plot(TM,SDFavg_S(6,:),'-b','LineWidth',2); hold on
plot(TM,SEMline_Up_S(6,:),':b','LineWidth',1); hold on
plot(TM,SEMline_Down_S(6,:),':b','LineWidth',1); hold on
plot(TM,SDFavg_S(7,:),'-m','LineWidth',2); hold on
plot(TM,SEMline_Up_S(7,:),':m','LineWidth',1); hold on
plot(TM,SEMline_Down_S(7,:),':m','LineWidth',1); hold on
ylim([0 1.1]);
xlim([-.05 .8]);
vline(0)
legend('DE-NS','NDE-PS')







     
 