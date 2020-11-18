function visIDX_fig3_fromAUTO_I34Only(IDX,dataType)
%% taken from visIDX_fig3aAllV1_CvsIC.m

% viIDX_fig3_fromAUTO.m can be found in Visualization functions. 
% It takes the SDFs from all of V1 in the IDX variable and averages them 
% together. This can be done with raw dMUA inputs or z-scored inputs. 
% Both are plotted in dMUAdCOF master fuction



%% Initial variables
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
CondTrialNum_SDF = nan(3,uctLength,10); %admittidly the dimensions here are a bit confusint --(laminarCompartment,numberofContacts,10differentConditionTypes) -- also, IDK how I would use this to balance as I used to...
SDF = nan(10,450,uctLength);    
count = 0;
clear uct
for uct = 1:uctLength
    if ~strcmp(IDX.allV1(uct).monkey,'I')
        continue
    end
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




allV1 = figure;
    plot(TM,AvgSDFOut.SDFavg(5,:),'-b','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
   
    plot(TM,AvgSDFOut.SDFavg(6,:),'-r','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;

    plot(TM,AvgSDFOut.SDFavg(9,:),'-c','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(9,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(9,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;
    
    plot(TM,AvgSDFOut.SDFavg(10,:),'-m','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(10,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(10,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;
     
    legend('biSimult','diSimult','biAdapted','diAdapted')
    
    xlim([-0.05 0.3])
    ylim([-.5 1.2*SDFmax])
    vline(0)
   


    title(strcat('allV1_I34_',dataType,'_average'),'interpreter', 'none')
set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])





end

