%% visIDX_Adapt200vs800_monocX
% from visIDX_Adapt200vs800


%% Goal
% 4 plots, 1-2: 200ms-800msl

%%
clear
close all

flag_savefigs   = 0;
variance = 'SEM';

IDXdir = 'C:\Users\Brock\Documents\MATLAB\diIDXdirectory';

IDXtextStr = 'diIDX_Adapt200vs800_monocX.mat';
figTitle  = 'FS Y - monocX';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = IDXdir;
figName = strcat('diIDX_Adapt200vs800'); 

if flag_savefigs
    cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end
end

TM = IDX.tm;
conditName = IDX(1).condition.Properties.RowNames;


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

%% PUll out Scatterplot
clear uct count SCATTER Yval Xval st ed
for uct = 1:uctLength
    if uct == 1
        Yval(:,:)      = IDX(uct).FS_deltaY(:,:);
        Xval(1,:)      = IDX(uct).MonocDiffOut(1,:); 
    else
        st = size(Yval,2) + 1;
        ed = size(IDX(uct).FS_deltaY,2) + st - 1;
        Yval(:,st:ed)   = IDX(uct).FS_deltaY(:,:);
        Xval(1,st:ed)   = IDX(uct).MonocDiffOut(1,:); 
    end
end


clear IDX

%% Logicals for balanced conditions
clear balanceSimult balance200 balance800
balanceSimult   = ~any((CondTrialNum_SDF(:,[1 2]) == 0),2);
balance200      = ~any((CondTrialNum_SDF(:,[3 4]) == 0),2);
balance800      = ~any((CondTrialNum_SDF(:,[5 6]) == 0),2);





%% Sum
SDFavg_Simult   = squeeze(nanmean(SDF(:,:,balanceSimult),3));
SDFavg_200      = squeeze(nanmean(SDF(:,:,balance200),3));
SDFavg_800      = squeeze(nanmean(SDF(:,:,balance800),3));

% % maxYval = max(max(SDFavg));

%% Get out variance lines
switch variance
    case 'STD'
        error('not set up for balanced conditions')
        varUsed200 = nanstd(SDF,[],3);
    case 'SEM'
        varUsedSimult   = (nanstd(SDF(:,:,balance200),[],3))./sqrt(varianceLength);
        varUsed200      = (nanstd(SDF(:,:,balance200),[],3))./sqrt(varianceLength);
        varUsed800  = (nanstd(SDF(:,:,balance800),[],3))./sqrt(varianceLength);
    case 'CI'
        error('not set up for balanced conditions')
        SEM = nanstd(SDF,[],3)/sqrt(varianceLength);	% Standard Error
        ts = tinv(0.99,varianceLength-1);               % T-Score at the 99th percentile
        varUsed200 = squeeze(nanmean(SDF,3))+ ts*SEM;          % Confidence Intervals
end
for a = 1:size(SDFavg_Simult,1)
    VARline_Up_Simult(a,:) = SDFavg_Simult(a,:) + varUsedSimult(a,:);
    VARline_Down_Simult(a,:) = SDFavg_Simult(a,:) - varUsedSimult(a,:);
end
for a = 1:size(SDFavg_200,1)
    VARline_Up_200(a,:) = SDFavg_200(a,:) + varUsed200(a,:);
    VARline_Down_200(a,:) = SDFavg_200(a,:) - varUsed200(a,:);
end
for a = 1:size(SDFavg_800,1)
    VARline_Up_800(a,:) = SDFavg_800(a,:) + varUsed800(a,:);
    VARline_Down_800(a,:) = SDFavg_800(a,:) - varUsed800(a,:);
end

%% Plot SDF

figure
subplot(2,2,1)
colorMain = {'-k','-r','-b','-g','-b','-g'};
colorVar  = {':k',':r',':b',':g',':b',':g'};
clear i
for i = 1:2
p(i) = plot(TM,SDFavg_Simult(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,VARline_Up_Simult(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,VARline_Down_Simult(i,:),colorVar{i},'LineWidth',1); hold on
% % ylim([-.1 1]);
xlim([-.05 .35]);
end
for i = 3:4
p(i) = plot(TM,SDFavg_200(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,VARline_Up_200(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,VARline_Down_200(i,:),colorVar{i},'LineWidth',1); hold on
% % ylim([-.1 1]);
xlim([-.05 .35]);
end
vline(0)
legend([p(1) p(2) p(3) p(4)],conditName)
ylabel('impulses/sec')
xlabel('sec')
title('200 ms adaptation vs simultaneous stim')
hold on

subplot(2,2,2)
clear i
for i = 1:2
p(i) = plot(TM,SDFavg_Simult(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,VARline_Up_Simult(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,VARline_Down_Simult(i,:),colorVar{i},'LineWidth',1); hold on
% % ylim([-.1 1]);
xlim([-.05 .35]);
end
for i = [5,6]
p(i) = plot(TM,SDFavg_800(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,VARline_Up_800(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,VARline_Down_800(i,:),colorVar{i},'LineWidth',1); hold on
% % ylim([-.1 1]);
xlim([-.05 .35]);
end
vline(0)
legend([p(1) p(2) p(5) p(6)],conditName{[1 2 5 6],:})
title('800 ms adaptation vs simultaneous stim')


%% PLOT SCATTER
%NaN index
X_idx = isnan(Xval);
Y_idx = isnan(Yval);

%Congruent
subplot(2,2,3)
scatter(Xval,Yval(1,:),[],'blue')
hold on
coef = polyfit(Xval(1,~Y_idx(1,:)),Yval(1,~Y_idx(1,:)),1);
slope(1) = coef(1);
h(1) = refline(coef(1), coef(2));
h(1).Color = 'blue';
hold on

scatter(Xval,Yval(3,:),[],'red')
hold on
coef = polyfit(Xval(1,~Y_idx(3,:)),Yval(3,~Y_idx(3,:)),1);
slope(2) = coef(1);
h(2) = refline(coef(1), coef(2));
h(2).Color = 'red';
slope(2) = coef(1);


legend([h(1) h(2)],{'200','800'})
title({'congruent',strcat('slope 200 =',num2str(slope(1))),strcat('slope 800 =',num2str(slope(2)))})
ylabel({'Change in spiking, unadapted - adapted','Feature-Scaled'})
ylim([-.5 .5])
% xlim([-.5 .5])
vline(0)
xlabel('Increasing excitatory response on monocular controll')

% Incongruent
clear slope
subplot(2,2,4)
scatter(Xval,Yval(2,:),[],'blue')
hold on
coef = polyfit(Xval(1,~Y_idx(2,:)),Yval(2,~Y_idx(2,:)),1);
slope(1) = coef(1);
h(1) = refline(coef(1), coef(2));
h(1).Color = 'blue';
hold on


scatter(Xval,Yval(4,:),[],'red')
hold on
coef = polyfit(Xval(1,~Y_idx(4,:)),Yval(4,~Y_idx(4,:)),1);
slope(2) = coef(1);
h(2) = refline(coef(1), coef(2));
h(2).Color = 'red';

legend([h(1) h(2)],{'200','800'})
title({'Incongruent',strcat('slope 200 =',num2str(slope(1))),strcat('slope 800 =',num2str(slope(2)))})
ylim([-.5 .5])
% xlim([-.3 .3])
vline(0)
sgtitle(figTitle)
