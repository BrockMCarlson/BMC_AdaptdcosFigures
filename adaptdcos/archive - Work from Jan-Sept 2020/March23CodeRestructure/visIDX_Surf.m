%% visIDX_Surf
% from visIDX_SDF in March23Restructure


%% Goal
% 2 plots main color - C vs IC 800ms adaptation
% 1 plot - black and white - C-IC subtraction

%%
clear

flag_savefigs   = 0;
IDXdir = 'C:\Users\Brock\Documents\MATLAB\Working IDX Dir';
cd(IDXdir)
IDXtextStr = 'diIDX_March23Restructure-CSD.mat';
dataType = 'raw';

%% Loop for SDF/norm type

    load(IDXtextStr)
    uctLength = length(IDX);
    conditNameForCC = IDX(1).condition.Properties.RowNames;
    TM = IDX.tm;

    close all
    count = 0;
%% Pull out SDF variable    
switch dataType
    case 'raw'
        SDF = nan(size(IDX(1).SDF,1),size(IDX(1).SDF,2),uctLength);
        CondTrialNum_SDF = nan(uctLength,size(IDX(1).SDF,1));
        for uct = 1:uctLength
                count = count+1;
                SDF(:,:,count) = IDX(uct).SDF;
                depth(uct) = IDX(uct).depth(2);
                penetration(uct,:) = IDX(uct).penetration;
                CondTrialNum_SDF(count,:) = IDX(uct).CondTrialNum_SDF;

        end
    case 'z-scored' 
        SDF = nan(size(IDX(1).SDF_zs,1),size(IDX(1).SDF_zs,2),uctLength);
        CondTrialNum_SDF = nan(uctLength,size(IDX(1).SDF_zs,1));
        for uct = 1:uctLength
                count = count+1;
                SDF(:,:,count) = IDX(uct).SDF_zs;
                depth(uct) = IDX(uct).depth(2);
                penetration(uct,:) = IDX(uct).penetration;
                CondTrialNum_SDF(count,:) = IDX(uct).CondTrialNum_SDF;
        end        
end

% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
clear IDX
    
%% Pull out surface matrix
clear strdiff pentct sortedDepths sortedSDF
numPenet = unique(penetration,'rows');
sortedDepths = nan(32,size(numPenet,1));
sortedSDF = cell(32,size(numPenet,1));
penct = 1;
elct = 0;
dim = 5; %This depends on how you set up your SDF, here dimension of 5 is my IC 800soa condition
for uct = 2:uctLength
    strdiff(uct,1) = ~strcmp(penetration(uct,:),penetration(uct-1,:));
    if strdiff(uct,1) == true
        penct = penct+1;
        elct = 0;
    end
    elct = elct+1;
    sortedDepths(elct,penct) = depth(uct);
    sortedSDF(elct,penct) = {SDF(dim,:,uct)};
end



%% @Blake --> This is as far as I got, added some things below that might
% help... hmu if you have questions. Sorry it's not polished.

%preallocate
SurfMatrix = nan(100,size(SDF,2),size(numPenet,1));
findSink = (sortedDepths == 0);
clear i
for i  = 1:size(numPenet,1)
    sinkSpot(i,1) = find(findSink(:,i));
    topDepth(i,1) = sortedDepths(1,i);
    btmDepth(i,1) = sortedDepths(find(isnan(sortedDepths(:,i)),1)-1,i); 
    topIDX(i,1) = 50 - topDepth(i,1) - 1;
    clear j
    for j = 1:size(sortedSDF,1)
        if ~isempty(sortedSDF{j,i})
            SurfMatrix(topIDX(i,1)+j,:,i) = sortedSDF{j,i};
        end
    end
    
end

AVGSURF = nanmean(SurfMatrix,3);
CutSurf = AVGSURF(32:55,:); %%BLAKE THIS SHOULD BE YOUR FINAL OUTPUT

%% Logicals for balanced conditions
clear balanceSimult balance200 balance800
balanceSimult   = ~any((CondTrialNum_SDF(:,[1 2]) == 0),2);
balance200      = ~any((CondTrialNum_SDF(:,[3 4]) == 0),2);
balance800      = ~any((CondTrialNum_SDF(:,[5 6]) == 0),2);



%% Align
clear Aligned
Aligned = nan(6,450,100);

%% Sum
SDFavg_Simult   = squeeze(nanmean(SDF(:,:,balanceSimult),3));
SDFavg_200      = squeeze(nanmean(SDF(:,:,balance200),3));
SDFavg_800      = squeeze(nanmean(SDF(:,:,balance800),3));





%% Plot SDF Condition Comparisons

fig1 = figure;
subplot(1,2,1)
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
legend([p(1) p(2) p(3) p(4)],conditNameForCC)
ylabel('impulses/sec')
xlabel('sec')
title('200 ms adaptation vs simultaneous stim')
hold on

subplot(1,2,2)
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
legend([p(1) p(2) p(5) p(6)],conditNameForCC{[1 2 5 6],:})
title('800 ms adaptation vs simultaneous stim')
sgtitle('Condition Comparisons')
set(gcf,'Position',[45.8000 389 1.0022e+03 373])

% % % %% Plot Diff Simult-Adapt
% % % conditName = {'Csim-C200','ICsim-IC200','Csim-C800','ICsim-IC800'}';
% % % 
% % % % Diff Calc
% % %     % 1. Csimult - C200 vs ICsimult - IC200
% % %     diff200     = SDF(1:2,:,balance200) - SDF(3:4,:,balance200);
% % %     % 2. Csimult - C800 vs ICsimult - IC800
% % %     diff800     = SDF(1:2,:,balance800) - SDF(5:6,:,balance800);
% % % 
% % % % Sum
% % %     DiffAvg_200      = squeeze(nanmean(diff200,3));
% % %     DiffAvg_800      = squeeze(nanmean(diff800,3));
% % %     
% % % % Get out variance lines
% % %     switch variance
% % %         case 'STD'
% % %             error('not set up for balanced conditions')
% % %             varUsed200 = nanstd(SDF,[],3);
% % %         case 'SEM'
% % %             varUsed200      = (nanstd(diff200,[],3))./sqrt(size(diff200,3));
% % %             varUsed800      = (nanstd(diff800,[],3))./sqrt(size(diff800,3));
% % %         case 'CI'
% % %             error('not set up for balanced conditions')
% % %             SEM = nanstd(SDF,[],3)/sqrt(varianceLength);	% Standard Error
% % %             ts = tinv(0.99,varianceLength-1);               % T-Score at the 99th percentile
% % %             varUsed200 = squeeze(nanmean(SDF,3))+ ts*SEM;          % Confidence Intervals
% % %     end
% % % 
% % %     for a = 1:size(DiffAvg_200,1)
% % %         VARline_Up_200(a,:) = DiffAvg_200(a,:) + varUsed200(a,:);
% % %         VARline_Down_200(a,:) = DiffAvg_200(a,:) - varUsed200(a,:);
% % %     end
% % %     for a = 1:size(DiffAvg_800,1)
% % %         VARline_Up_800(a,:) = DiffAvg_800(a,:) + varUsed800(a,:);
% % %         VARline_Down_800(a,:) = DiffAvg_800(a,:) - varUsed800(a,:);
% % %     end
% % %     
% % % % Plot SDF for Diff Simult-Adap
% % %   fig2 =  figure;
% % %     subplot(1,2,1)
% % %     colorMain = {'-k','-r','-b','-g','-b','-g'};
% % %     colorVar  = {':k',':r',':b',':g',':b',':g'};
% % %     clear i
% % %     for i = 1:2
% % %         p(i) = plot(TM,DiffAvg_200(i,:),colorMain{i},'LineWidth',2); hold on
% % %         plot(TM,VARline_Up_200(i,:),colorVar{i},'LineWidth',1); hold on
% % %         plot(TM,VARline_Down_200(i,:),colorVar{i},'LineWidth',1); hold on
% % % % % %         if type == 1
% % % % % %             ylim([-60 70]);
% % % % % %         elseif type == 2
% % % % % %             ylim([-1.5 2.5]);
% % % % % %         end
% % %         xlim([-.05 .35]);
% % %     end
% % %     vline(0)
% % %     hline(0)
% % %     legend([p(1) p(2)],conditName([1 2],:))
% % %     ylabel('impulses/sec')
% % %     xlabel('sec')
% % %     title('simult stim - 200ms adaptation')
% % %     hold on
% % % 
% % %     subplot(1,2,2)
% % %     clear i
% % %     for i = 1:2
% % %         q(i) = plot(TM,DiffAvg_800(i,:),colorMain{i},'LineWidth',2); hold on
% % %         plot(TM,VARline_Up_800(i,:),colorVar{i},'LineWidth',1); hold on
% % %         plot(TM,VARline_Down_800(i,:),colorVar{i},'LineWidth',1); hold on
% % % % % %         if type == 1
% % % % % %             ylim([-60 70]);
% % % % % %         elseif type == 2
% % % % % %              ylim([-1.5 2.5]);
% % % % % %         end
% % %         xlim([-.05 .35]);
% % %     end
% % %     vline(0)
% % %     hline(0)
% % %     legend([q(1) q(2)],conditName{[3 4],:})
% % %     title('simult stim - 800ms adaptation')
% % % 
% % %     sgtitle('Diff Simult-Adapt')
% % %     set(gcf,'Position',[199.4000 289 1.0024e+03 372.8000])

% % % %% Plot SDF Diff - Congruent-IC
% % % conditName = {'Simult','200','800'}';
% % % % Diff Calc
% % %     clear DIFF
% % %     % Simult C - Simult IC
% % %     DIFF(1,:,:) = SDF(1,:,:) - SDF (2,:,:);
% % %     % 200 C - 200 IC
% % %     DIFF(2,:,:) = SDF(3,:,:) - SDF (4,:,:);
% % % 
% % %     % 800 C - 800 IC
% % %     DIFF(3,:,:) = SDF(5,:,:) - SDF (6,:,:);
% % %     
% % % % Sum
% % %     DIFFAvg      = squeeze(nanmean(DIFF,3));
% % %     
% % % % Get out variance lines
% % %     switch variance
% % %         case 'STD'
% % %             error('not set up for balanced conditions')
% % %             varUsed = nanstd(SDF,[],3);
% % %         case 'SEM'
% % %             varUsed      = (nanstd(DIFF,[],3))./sqrt(size(DIFF,3));
% % %         case 'CI'
% % %             error('not set up for balanced conditions')
% % %             SEM = nanstd(SDF,[],3)/sqrt(varianceLength);	% Standard Error
% % %             ts = tinv(0.99,varianceLength-1);               % T-Score at the 99th percentile
% % %             varUsed = squeeze(nanmean(SDF,3))+ ts*SEM;          % Confidence Intervals
% % %     end
% % % 
% % %     for a = 1:size(DIFFAvg,1)
% % %         VARline_Up(a,:) = DIFFAvg(a,:) + varUsed(a,:);
% % %         VARline_Down(a,:) = DIFFAvg(a,:) - varUsed(a,:);
% % %     end
% % % 
% % % % Plot SDF for C-IC
% % %     colorMain = {'-k','-b','-g'};
% % %     colorVar  = {':k',':b',':g'};
% % %     
% % %  fig3 = figure;
% % %     clear i
% % %     for i = 1:3
% % %         p(i) = plot(TM,DIFFAvg(i,:),colorMain{i},'LineWidth',2); hold on
% % %         plot(TM,VARline_Up(i,:),colorVar{i},'LineWidth',1); hold on
% % %         plot(TM,VARline_Down(i,:),colorVar{i},'LineWidth',1); hold on
% % %         % ylim([-60 70]);
% % %         xlim([-.05 .35]);
% % %     end
% % %     vline(0)
% % %     hline(0)
% % %     legend([p(1) p(2) p(3)],conditName([1 2 3],:))
% % %     ylabel('impulses/sec')
% % %     xlabel('sec')
% % %     title('Congruent - Incongruent')
% % %     set(gcf,'Position',[381.8000 227.4000 424.0000 343.2000])
% % %     
% % % %% SAVE FIGS
% % % if flag_savefigs
% % %     cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\March23Restructure figs')
% % %     switch dataType 
% % %         case 'raw'
% % %             saveas(fig1,'SDF_ConditionCompare_RAW.jpg');
% % %             saveas(fig2,'SDF_DiffSimultVsAdapt_RAW.jpg');
% % %             saveas(fig3,'SDF_DiffCongVsIC_RAW.jpg');
% % %         case 'z-scored'
% % %             saveas(fig1,'SDF_ConditionCompare_ZS.jpg');
% % %             saveas(fig2,'SDF_DiffSimultVsAdapt_ZS.jpg');
% % %             saveas(fig3,'SDF_DiffCongVsIC_ZS.jpg');    
% % %     end
% % % end

