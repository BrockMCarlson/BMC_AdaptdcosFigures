%% visIDX_fig3aAllV1_allUnitsAvg.m



%%
clear
close all


flag_saveFigs   = 1;
savename = 'fig3AllUnits_Phy';
IDXtextStr = 'diIDX_Phy_PrefSelected.mat'; 

global SAVEDIR
IDXdir = SAVEDIR;
cd(SAVEDIR)


%% Initial variables
load(IDXtextStr)
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).tm;
uctLength = length(IDX.allV1);



%% Plot SDF Condition Comparisons - fig 2. Monoc vs
count = 0;
clear uct SDF
for uct = 1:uctLength

depth = num2str(IDX.allV1(uct).depth(2));
penetration = IDX.allV1(uct).penetration;
CondTrialNum_SDF = IDX.allV1(uct).CondTrialNum_SDF;
if  CondTrialNum_SDF(5) > 5 || CondTrialNum_SDF(6) > 5 ||  CondTrialNum_SDF(9) > 5 || CondTrialNum_SDF(10) > 5
    continue
end
count = count + 1;


SDF(:,:,count) = IDX.allV1(uct).SDF.fs;
end
SDFavg = nanmean(SDF,3);
SEM.val = (nanstd(SDF,[],3))./sqrt(size(SDF,3));

SEM.up = SDFavg+SEM.val;
SEM.down = SDFavg-SEM.val;
SDFmax = max(SDF,[],'all');




close all
figure   
    plot(TM,SDFavg(5,:),'-b','LineWidth',2);hold on;
    plot(TM,SEM.up(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,SEM.down(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;   
   
    plot(TM,SDFavg(6,:),'-r','LineWidth',2);hold on;
    plot(TM,SEM.up(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,SEM.down(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;    
    

    xlim([-0.05 0.3])
    ylim([0 1.1])
    vline(0)
    ylabel('spks/sec - Normalized to max binoc congruent resp')

    
    set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])
    CondTrialNum_SDF = num2str(CondTrialNum_SDF);
    titletext = {'Simultaneous congruent vs incongruent','N = 17 units with balanced conditions'};
    title(titletext,'interpreter','none')
    legend('congruent','incongruent')
    
    cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\PhyTesting\fig2EachUnit_PhyOutput')
        export_fig('fig3a','-pdf','-nocrop') 

    
figure   
    plot(TM,SDFavg(9,:),'-c','LineWidth',2);hold on;
    plot(TM,SEM.up(9,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,SEM.down(9,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;   
   
    plot(TM,SDFavg(10,:),'-m','LineWidth',2);hold on;
    plot(TM,SEM.up(10,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,SEM.down(10,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;    
    

    xlim([-0.05 0.3])
    ylim([0 1.1])
    ylabel('spks/sec - Normalized to max binoc congruent resp')
    vline(0)


%     title(IDXtextStr,'interpreter', 'none')
    set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])
    CondTrialNum_SDF = num2str(CondTrialNum_SDF);
    titletext = {'Suppressors after 800ms adaptation to PS DE.','N = 17 units with balanced conditions'};
    title(titletext,'interpreter','none')
    legend('congruent 800ms SOA','incongruent 800ms SOA')


cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\PhyTesting\fig2EachUnit_PhyOutput')
        export_fig('fig3b','-pdf','-nocrop') 

