%% visIDX_fig2aAllV1_MvsBi.m



%% Goal
% two "report" plots that show one factor chanfe and one "difference" plot.
% All must be binned based on layer.

%1. C vs IC --> first priority
%2. Simult vs adapt

%%
clear
close all


flag_saveFigs   = 1;
savename = 'fig2EachUnit_Phy';
IDXtextStr = 'diIDX_Phy_PrefSelected.mat'; 

global SAVEDIR
IDXdir = SAVEDIR;
cd(SAVEDIR)
dataType = 'raw';


%% Initial variables
load(IDXtextStr)
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).tm;
uctLength = length(IDX.allV1);



%% Plot SDF Condition Comparisons - fig 2. Monoc vs
count = 0;
clear uct
for uct = 1:uctLength

depth = num2str(IDX.allV1(uct).depth(2));
penetration = IDX.allV1(uct).penetration;
CondTrialNum_SDF = num2str(IDX.allV1(uct).CondTrialNum_SDF); 
SDF = IDX.allV1(uct).SDF.raw;
SEM.val = IDX.allV1(uct).SEM.raw;
SEM.up = SDF+SEM.val;
SEM.down = SDF-SEM.val;
SDFmax = max(SDF,[],'all');

if SDFmax == 0
    continue
end
if isnan(SDFmax)
    continue
end

close all
allV1 = figure;
    plot(TM,SDF(1,:),'-k','LineWidth',2);hold on;
    plot(TM,SEM.up(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,SEM.down(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
   
    plot(TM,SDF(5,:),'-b','LineWidth',2);hold on;
    plot(TM,SEM.up(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,SEM.down(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;   
   
    plot(TM,SDF(6,:),'-r','LineWidth',2);hold on;
    plot(TM,SEM.up(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,SEM.down(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;    
    

    xlim([-0.05 0.3])
    ylim([0 1.2*SDFmax])
    vline(0)


%     title(IDXtextStr,'interpreter', 'none')
set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])
titletext = {penetration,strcat('at depth_',depth),strcat('MonocTrlNum=',CondTrialNum_SDF(1,:),'_BiTrlNum=',CondTrialNum_SDF(5,:),'_DiTrlNum=',CondTrialNum_SDF(6,:))};
title(titletext,'interpreter','none')

%% SAVE FIGS



if flag_saveFigs
    count = count + 1;
    global SAVEDIR
%         cd(SAVEDIR)    
cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\PhyTesting\fig2EachUnit_PhyOutput')
    if count == 1
        export_fig(savename,'-pdf','-nocrop') 
    else
        export_fig(savename,'-pdf','-nocrop','-append')
    end
end
end
