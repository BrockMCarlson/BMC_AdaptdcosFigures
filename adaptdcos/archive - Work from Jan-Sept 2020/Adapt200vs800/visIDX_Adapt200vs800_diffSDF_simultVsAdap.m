%% visIDX_Adapt200vs800_diffSDF_simultVsAdap
% from visIDX_Adapt200vs800_monocX


%% Goal
% 2 diff plots - SDFs
% 1. Csimult - C200 vs ICsimult - IC200
% 2. Csimult - C800 vs ICsimult - IC800

%%
clear
close all

flag_savefigs   = 0;
variance = 'SEM';

IDXdir = 'C:\Users\Brock\Documents\MATLAB\diIDXdirectory';

IDXtextStr = 'diIDX_Adapt200vs800_monocX.mat';
figTitle  = 'diff plot -- Simult Vs Adaptation';
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
conditName = {'Csim-C200','ICsim-IC200','Csim-C800','ICsim-IC800'}';


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

%% Logicals for balanced conditions
clear balanceSimult balance200 balance800
balanceSimult   = ~any((CondTrialNum_SDF(:,[1 2]) == 0),2); %?? Not used for difference plots?
balance200      = ~any((CondTrialNum_SDF(:,[3 4]) == 0),2);
balance800      = ~any((CondTrialNum_SDF(:,[5 6]) == 0),2);



%% Diff Calc
% 1. Csimult - C200 vs ICsimult - IC200
diff200     = SDF(1:2,:,balance200) - SDF(3:4,:,balance200);

% 2. Csimult - C800 vs ICsimult - IC800
diff800     = SDF(1:2,:,balance800) - SDF(5:6,:,balance800);

%% Sum
DiffAvg_200      = squeeze(nanmean(diff200,3));
DiffAvg_800      = squeeze(nanmean(diff800,3));




%% Get out variance lines
switch variance
    case 'STD'
        error('not set up for balanced conditions')
        varUsed200 = nanstd(SDF,[],3);
    case 'SEM'
        varUsed200      = (nanstd(diff200,[],3))./sqrt(size(diff200,3));
        varUsed800      = (nanstd(diff800,[],3))./sqrt(size(diff800,3));
    case 'CI'
        error('not set up for balanced conditions')
        SEM = nanstd(SDF,[],3)/sqrt(varianceLength);	% Standard Error
        ts = tinv(0.99,varianceLength-1);               % T-Score at the 99th percentile
        varUsed200 = squeeze(nanmean(SDF,3))+ ts*SEM;          % Confidence Intervals
end

for a = 1:size(DiffAvg_200,1)
    VARline_Up_200(a,:) = DiffAvg_200(a,:) + varUsed200(a,:);
    VARline_Down_200(a,:) = DiffAvg_200(a,:) - varUsed200(a,:);
end
for a = 1:size(DiffAvg_800,1)
    VARline_Up_800(a,:) = DiffAvg_800(a,:) + varUsed800(a,:);
    VARline_Down_800(a,:) = DiffAvg_800(a,:) - varUsed800(a,:);
end

%% Plot SDF

figure
subplot(1,2,1)
colorMain = {'-k','-r','-b','-g','-b','-g'};
colorVar  = {':k',':r',':b',':g',':b',':g'};
clear i
for i = 1:2
p(i) = plot(TM,DiffAvg_200(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,VARline_Up_200(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,VARline_Down_200(i,:),colorVar{i},'LineWidth',1); hold on
ylim([-60 70]);
xlim([-.05 .35]);
end
vline(0)
hline(0)
legend([p(1) p(2)],conditName([1 2],:))
ylabel('impulses/sec')
xlabel('sec')
title('simult stim - 200ms adaptation')
hold on

subplot(1,2,2)
clear i
for i = 1:2
q(i) = plot(TM,DiffAvg_800(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,VARline_Up_800(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,VARline_Down_800(i,:),colorVar{i},'LineWidth',1); hold on
ylim([-60 70]);
xlim([-.05 .35]);
end
vline(0)
hline(0)
legend([q(1) q(2)],conditName{[3 4],:})
title('simult stim - 800ms adaptation')



sgtitle(figTitle)
