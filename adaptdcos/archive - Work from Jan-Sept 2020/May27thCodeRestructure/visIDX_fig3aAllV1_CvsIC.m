%% visIDX_fig3aAllV1_CvsIC.m



%%
clear
close all


flag_savefigs   = 1;
savename = 'fig3-AllV1.svg';
IDXtextStr = 'diIDX_testAllData-AUTO.mat'; 


IDXdir = 'C:\Users\Brock\Documents\MATLAB\Working IDX Dir';
cd(IDXdir)
dataType = 'raw';


%% Initial variables
load(IDXtextStr)
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).tm;


uctLength = length(IDX.allV1);

% B. pull out all laminar matrices 3x(6,450,el#)
%preallocate

SDF = nan(size(IDX.allV1(1).SDF.raw,1),size(IDX.allV1(1).SDF.raw,2),uctLength);
DIFF = nan(size(IDX.allV1(1).SDFdiff.raw,1),size(IDX.allV1(1).SDFdiff.raw,2),uctLength);

% loop uctLength
depth = nan(3,uctLength);
penetration = nan(3,uctLength,11);
CondTrialNum_SDF = nan(3,uctLength,7); %admittidly the dimensions here are a bit confusint --(laminarCompartment,numberofContacts,6differentConditionTypes) -- also, IDK how I would use this to balance as I used to...
SDF = nan(7,450,uctLength);    
count = 0;
clear uct
for uct = 1:uctLength
    switch dataType
        case 'raw'
            sdf = IDX.allV1(uct).SDF.raw;
            diff = IDX.allV1(uct).SDFdiff.raw;
        case 'z-scored'
            sdf = IDX.allV1(uct).SDF.zs;
            diff = IDX.allV1(uct).SDFdiff.zs;
    end
    count = count + 1;
    SDF(:,:,count) = sdf;
    DIFF(:,:,count) = diff;
end

clear IDX   


% C. Average across laminar compartments 3x(6,450)
% Avg
clear SDFavg 
SDFavg = nanmean(squeeze(SDF(:,:,:)),3);
DIFFavg = nanmean(squeeze(DIFF(:,:,:)),3);
%SEM
sdfsem  = (nanstd(squeeze(SDF(:,:,:)),[],3))./sqrt(count);
for a = 1:size(SDFavg,1)
    SDFsem.up(a,:) = SDFavg(a,:) + sdfsem(a,:);
    SDFsem.down(a,:) = SDFavg(a,:) - sdfsem(a,:);
end
diffsem  = (nanstd(squeeze(DIFF(:,:,:)),[],3))./sqrt(count);
for a = 1:size(DIFFavg,1)
    DIFFsem.up(a,:) = DIFFavg(a,:) + diffsem(a,:);
    DIFFsem.down(a,:) = DIFFavg(a,:) - diffsem(a,:);
end


    AvgSDFOut.SDFavg      = SDFavg;
    AvgSDFOut.SDFsem      = SDFsem;
    AvgSDFOut.DIFFavg     = DIFFavg;
    AvgSDFOut.DIFFsem     = DIFFsem;

clear IDX

%% Plot SDF Condition Comparisons - fig 2. Monoc vs
SDFmax = max(AvgSDFOut.SDFavg,[],'all');




close all
allV1 = figure;
    plot(TM,AvgSDFOut.SDFavg(2,:),'-b','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
   
    plot(TM,AvgSDFOut.SDFavg(3,:),'-r','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(3,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(3,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;

    plot(TM,AvgSDFOut.SDFavg(6,:),'-c','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(6,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(6,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;
    
    plot(TM,AvgSDFOut.SDFavg(7,:),'-m','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(7,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(7,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;
        
    xlim([-0.05 0.3])
    ylim([0 1.2*SDFmax])
    vline(0)


    title(IDXtextStr,'interpreter', 'none')
set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])



%% SAVE FIGS
if flag_savefigs
    cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\May27CodeRestructure\fig3 - CvsIC')
        saveas(allV1,savename);

end

