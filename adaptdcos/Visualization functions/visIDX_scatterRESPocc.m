function visIDX_scatterRESPocc(IDX)


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
count = 0;
% loop uctLength
clear RESPout dII occ Xval Yval_simult Yval_adapted
for uct = 1:uctLength
     if ~any(isnan(IDX.allV1(uct).dII),'all') && ~any(isnan(IDX.allV1(uct).occ(1)))
         count = count + 1;
        RESPout(:,:,count) = IDX.allV1(uct).RESPout;
        dII(:,:,count) = IDX.allV1(uct).dII;
        occ(:,count)      = IDX.allV1(uct).occ(1:3);
        Xval(count)     = IDX.allV1(uct).occ(1);
        Yval_simult(count)     = IDX.allV1(uct).dII(1,3);
        Yval_adapted(count)     = IDX.allV1(uct).dII(2,3);
     end


end
clear IDX
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



%% PLOT SCATTER



%Simult
subplot(1,2,1)
scatter(Xval,Yval_simult,[],'magenta')
hold on
coef = polyfit(Xval,Yval_simult,1);
slope(1) = coef(1);
h(1) = refline(coef(1), coef(2));
h(1).Color = 'blue';
hold on

hline(0)
ylim([-.4 .4])
title('Simultaneous')

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
coef = polyfit(Xval,Yval_adapted,1);
slope(1) = coef(1);
h(1) = refline(coef(1), coef(2));
h(1).Color = 'red';
hold on

hline(0)
ylim([-.4 .4])
title('adapted')

sgtitle('dichoptic influence index vs occularity')

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

% set(gcf,'Position',[488 327.4000 931.4000 434.6000])

end