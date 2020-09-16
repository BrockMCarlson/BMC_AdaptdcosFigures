%% visIDX_Adapt200vs800_diffSDF_CvsIC
% from visIDX_Adapt200vs800_monocX


%% Goal
% 1 diff plot - 3 lines
% Simult C - Simult IC
% 200 C - 200 IC
% 800 C - 800 IC

% not balanced to start?

%%
clear
close all

flag_savefigs   = 0;
variance = 'SEM';

IDXdir = 'C:\Users\Brock\Documents\MATLAB\diIDXdirectory';

IDXtextStr = 'diIDX_Adapt200vs800_monocX.mat';
figTitle  = 'diff plot -- C-IC';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);


if flag_savefigs
    cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end
end

TM = IDX.tm;
conditName = {'Simult','200','800'}';


%% Pull out SDF plot    
count = 0;
SDF = nan(size(IDX(1).SDF,1),size(IDX(1).SDF,2),uctLength);
CondTrialNum_SDF = nan(uctLength,size(IDX(1).SDF,1));
for uct = 1:uctLength
        count = count+1;
        SDF(:,:,count) = IDX(uct).SDF;
        CondTrialNum_SDF(count,:) = IDX(uct).CondTrialNum_SDF;
end
varianceLength = uctLength;
% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)



clear IDX

% % % %% Logicals for balanced conditions
% % % clear balanceSimult balance200 balance800
% % % balanceSimult   = ~any((CondTrialNum_SDF(:,[1 2]) == 0),2); %?? Not used for difference plots?
% % % balance200      = ~any((CondTrialNum_SDF(:,[3 4]) == 0),2);
% % % balance800      = ~any((CondTrialNum_SDF(:,[5 6]) == 0),2);



%% Diff Calc
clear DIFF
% Simult C - Simult IC
DIFF(1,:,:) = SDF(1,:,:) - SDF (2,:,:);
% 200 C - 200 IC
DIFF(2,:,:) = SDF(3,:,:) - SDF (4,:,:);

% 800 C - 800 IC
DIFF(3,:,:) = SDF(5,:,:) - SDF (6,:,:);



%% Sum
DIFFAvg      = squeeze(nanmean(DIFF,3));
 



%% Get out variance lines
switch variance
    case 'STD'
        error('not set up for balanced conditions')
        varUsed = nanstd(SDF,[],3);
    case 'SEM'
        varUsed      = (nanstd(DIFF,[],3))./sqrt(size(DIFF,3));
    case 'CI'
        error('not set up for balanced conditions')
        SEM = nanstd(SDF,[],3)/sqrt(varianceLength);	% Standard Error
        ts = tinv(0.99,varianceLength-1);               % T-Score at the 99th percentile
        varUsed = squeeze(nanmean(SDF,3))+ ts*SEM;          % Confidence Intervals
end

for a = 1:size(DIFFAvg,1)
    VARline_Up(a,:) = DIFFAvg(a,:) + varUsed(a,:);
    VARline_Down(a,:) = DIFFAvg(a,:) - varUsed(a,:);
end


%% Plot SDF

colorMain = {'-k','-b','-g'};
colorVar  = {':k',':b',':g'};

figure
clear i
for i = 1:3
p(i) = plot(TM,DIFFAvg(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,VARline_Up(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,VARline_Down(i,:),colorVar{i},'LineWidth',1); hold on
% ylim([-60 70]);
xlim([-.05 .35]);
end
vline(0)
hline(0)
legend([p(1) p(2) p(3)],conditName([1 2 3],:))
ylabel('impulses/sec')
xlabel('sec')
title(figTitle)






