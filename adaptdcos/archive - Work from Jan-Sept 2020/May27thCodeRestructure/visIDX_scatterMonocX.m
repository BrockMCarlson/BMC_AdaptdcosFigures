%% visIDX_scatterMonocX
% from visIDX_Adapt200vs800_monocX


%% Goal
% 4 plots, 1-2: 200ms-800msl

%%
clear
close all

flag_savefigs   = 0;
variance = 'SEM';

IDXdir = 'C:\Users\Brock\Documents\MATLAB\diIDXdirectory';

IDXtextStr = 'diIDX_March23Restructure.mat';
figTitle  = 'Scatter Monoc X';
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

%%
clear IDX


%% PLOT SCATTER
%NaN index
X_idx = isnan(Xval);
Y_idx = isnan(Yval);

%Congruent
subplot(1,2,1)
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
subplot(1,2,2)
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

set(gcf,'Position',[488 327.4000 931.4000 434.6000])
