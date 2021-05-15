function [rsq_simult,rsq_adapted] = visIDX_scatterRESPocc_binnedOcc(IDX,flag_SaveFigs)


%% Goal
% 2 plots; dII index vs occ. 
% plot 1 - simult
% plot 2 - adapted


%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;


uctLength = length(IDX.allV1);

% B. pull out all laminar matrices 3x(6,450,el#)
%preallocate

% RESPout = nan(size(IDX.allV1(1).RESPout,1),size(IDX.allV1(1).RESPout,2),uctLength);
% dII = nan(size(IDX.allV1(1).dII,1),size(IDX.allV1(1).dII,2),uctLength);
% occ = nan(3,uctLength);

%for RespWin = 1:4
RespWin = 1;
% 1 = transient, 2 = sustained, 3 = full time, 4 = baseline.
% loop uctLength
count = 0;
clear RESPout dII occ Xval Yval_simult Yval_adapted
for uct = 1:uctLength
     if ~any(isnan(IDX.allV1(uct).dII),'all') && ~any(isnan(IDX.allV1(uct).occ(1))) % This is now tuned to occularity
         count = count + 1;
        RESPout(:,:,count) = IDX.allV1(uct).RESPout;
        dII(:,:,count) = IDX.allV1(uct).dII;
        occ(:,count)      = IDX.allV1(uct).occ(1:3);
        Xval(count)     = IDX.allV1(uct).occ(3);
%          Xval(count)     = IDX.allV1(uct).adapEffindex(1,RespWin);
        Yval_simult(count)     = IDX.allV1(uct).dII(1,RespWin);
        Yval_adapted(count)     = IDX.allV1(uct).dII(2,RespWin);
     end


end

% Find quartiles, 
absOcc = abs(Xval');
quartileOccValues = quantile(absOcc,4);

countEquiocular = 0;
clear RESPout dII occ Xval Yval_simult Yval_adapted
for uct = 1:uctLength
     if ~any(isnan(IDX.allV1(uct).dII),'all') && ~any(isnan(IDX.allV1(uct).occ(1)))...
             && (abs(IDX.allV1(uct).occ(3)) <= quartileOccValues(1)) %equiocular - lower quartile of occularity
         countEquiocular = countEquiocular + 1;
        RESPout.Equiocular(:,:,countEquiocular) = IDX.allV1(uct).RESPout;
        dII.Equiocular(:,:,countEquiocular) = IDX.allV1(uct).dII;
        occ.Equiocular(:,countEquiocular)      = IDX.allV1(uct).occ(1:3);
        Xval.Equiocular(countEquiocular)     = IDX.allV1(uct).occ(3);
%          Xval(count)     = IDX.allV1(uct).adapEffindex(1,RespWin);
        Yval_simult.Equiocular(countEquiocular)     = IDX.allV1(uct).dII(1,RespWin);
        Yval_adapted.Equiocular(countEquiocular)     = IDX.allV1(uct).dII(2,RespWin);
     end


end

countOccBiased = 0;
for uct = 1:uctLength
     if ~any(isnan(IDX.allV1(uct).dII),'all') && ~any(isnan(IDX.allV1(uct).occ(1)))...
             && (abs(IDX.allV1(uct).occ(3)) >= quartileOccValues(4)) %equiocular - lower quartile of occularity
         countOccBiased = countOccBiased + 1;
        RESPout.OccBiased(:,:,countOccBiased) = IDX.allV1(uct).RESPout;
        dII.OccBiased(:,:,countOccBiased) = IDX.allV1(uct).dII;
        occ.OccBiased(:,countOccBiased)      = IDX.allV1(uct).occ(1:3);
        Xval.OccBiased(countOccBiased)     = IDX.allV1(uct).occ(3);
%          Xval(count)     = IDX.allV1(uct).adapEffindex(1,RespWin);
        Yval_simult.OccBiased(countOccBiased)     = IDX.allV1(uct).dII(1,RespWin);
        Yval_adapted.OccBiased(countOccBiased)     = IDX.allV1(uct).dII(2,RespWin);
     end


end

OutVal = nan(15,4);
OutVal(:,1) = Yval_simult.Equiocular;
OutVal(:,2) = Yval_adapted.Equiocular;
OutVal(:,3) = Yval_simult.OccBiased;
OutVal(:,4) = Yval_adapted.OccBiased;

[p,tbl,stats] = anova1(OutVal);

%resp dimension
%    50   100
%    150   250
%     50   250
%    -50     0
% %    % occ(1:3) sub selected AND balanced
% %     occ(3) =  (nanmean(RESP(cell2mat(SUB(2,:)))) - nanmean(RESP(cell2mat(SUB(3,:)))) )...
% %         ./ (nanmean(RESP(cell2mat(SUB(2,:)))) + nanmean(RESP(cell2mat(SUB(3,:)))) ) ;
% %     [~,p,~,stats]=ttest2(RESP(cell2mat(SUB(2,:))),RESP(cell2mat(SUB(3,:))));
% %     occ(2) = stats.tstat;
% %     occ(1) = p;

%% Linear Regression
% Simult
    % test for linearity
    
    % Model the regression
    coef_simult = polyfit(Xval,Yval_simult,1);
    
    %Find an R^2
    clear yfit yresid SSresid SStotal
    yfit = polyval(coef_simult,Xval);
    yresid = Yval_simult - yfit;
    SSresid = sum(yresid.^2);
    SStotal = (length(Yval_simult)-1) * var(Yval_simult);
    rsq_simult(RespWin) = 1 - SSresid/SStotal;
    
% adapted
    % test for linearity
    
    % Model the regression
    coef_adapted = polyfit(Xval,Yval_adapted,1);
    
    %Find an R^2
    clear yfit yresid SSresid SStotal
    yfit = polyval(coef_adapted,Xval);
    yresid = Yval_adapted - yfit;
    SSresid = sum(yresid.^2);
    SStotal = (length(Yval_adapted)-1) * var(Yval_adapted);
    rsq_adapted(RespWin) = 1 - SSresid/SStotal;

%% PLOT SCATTER


figure(RespWin)
%Simult
subplot(1,2,1)
scatter(Xval,Yval_simult,[],'magenta')
hold on
slope(1) = coef_simult(1);
h(1) = refline(coef_simult(1), coef_simult(2));
h(1).Color = 'blue';
hold on

ylim([-.5 .4])
hline(0)
vline(0)
clear simultTitleText
r2Text = string(rsq_simult(RespWin));
simultTitleText = {'Simultaneous',strcat('R2 equals_',r2Text)};
title(simultTitleText,'interpreter', 'none')

% % scatter(Xval,Yval(3,:),[],'red')
% % hold on
% % coef = polyfit(Xval(1,~Y_idx(3,:)),Yval(3,~Y_idx(3,:)),1);
% % slope(2) = coef(1);
% % h(2) = refline(coef(1), coef(2));
% % h(2).Color = 'red';
% % slope(2) = coef(1);
% % 
% % 
% % legend([h(1) h(2)],{'200','800'})
% % title({'congruent',strcat('slope 200 =',num2str(slope(1))),strcat('slope 800 =',num2str(slope(2)))})
% % ylabel({'Change in spiking, unadapted - adapted','Feature-Scaled'})
% % ylim([-.5 .5])
% % % xlim([-.5 .5])
% % vline(0)
% % xlabel('Increasing excitatory response on monocular controll')

% adapted
subplot(1,2,2)
scatter(Xval,Yval_adapted,[],'green')
hold on
coef_adapted = polyfit(Xval,Yval_adapted,1);
slope(1) = coef_adapted(1);
h(1) = refline(coef_adapted(1), coef_adapted(2));
h(1).Color = 'red';
hold on

ylim([-.5 .4])
hline(0)
vline(0)
clear adaptedTitleText r2Text
r2Text = string(rsq_adapted(RespWin));
adaptedTitleText = {'Adapted',strcat('R2 equals_',r2Text)};
title(adaptedTitleText,'interpreter', 'none')

if RespWin == 1
    WinText = 'Transient';
elseif RespWin == 2
    WinText = 'Sustained';
elseif RespWin == 3
    WinText = 'FullTM';
elseif RespWin == 4
    WinText = 'Baseline';
end
bigTitleText = {'Dichoptic influence index vs adapted effect',WinText};
sgtitle(bigTitleText)

% % scatter(Xval,Yval(4,:),[],'red')
% % hold on
% % coef = polyfit(Xval(1,~Y_idx(4,:)),Yval(4,~Y_idx(4,:)),1);
% % slope(2) = coef(1);
% % h(2) = refline(coef(1), coef(2));
% % h(2).Color = 'red';
% % 
% % legend([h(1) h(2)],{'200','800'})
% % title({'Incongruent',strcat('slope 200 =',num2str(slope(1))),strcat('slope 800 =',num2str(slope(2)))})
% % ylim([-.5 .5])
% % % xlim([-.3 .3])
% % vline(0)
% % sgtitle(figTitle)

set(gcf,'Position',[680 558 1005 420])

%% Save Figs?
if flag_SaveFigs
    cd('D:\6 Plot Dir\dIIvsOcc')
    saveas(gcf,strcat('satterRespOcc_',WinText,'.png'))
end


end


