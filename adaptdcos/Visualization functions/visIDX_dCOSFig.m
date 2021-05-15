function visIDX_dCOSFig(IDX,dataType)

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).tm;


uctLength = length(IDX.allV1);

% B. pull out all laminar matrices 3x(6,450,el#)
%preallocate

SDF = nan(size(IDX.allV1(1).SDF.raw,1),size(IDX.allV1(1).SDF.raw,2),uctLength);

% loop uctLength
count = 0;
for uct = 1:uctLength
        switch dataType
            case 'raw'
                sdf = IDX.allV1(uct).SDF.raw;
            case 'z-scored'
                sdf = IDX.allV1(uct).SDF.zs;
        end
        count = count + 1;
        SDF(:,:,count) = sdf;
end
clear IDX

dCOScond(1,:,:) = SDF(1,:,:);
dCOScond(2,:,:) = SDF(5,:,:);
holder(1,:,:) = SDF(7,:,:);
holder(2,:,:) = SDF(8,:,:);
dCOScond(3,:,:) = squeeze(nanmean(holder,1));




% C. Average across laminar compartments 3x(6,450)
% Avg
clear SDFavg 
SDFavg = nanmean(squeeze(dCOScond(:,:,:)),3);


%SEM
sdfsem  = (nanstd(squeeze(SDF(:,:,:)),[],3))./sqrt(count);
for a = 1:size(SDFavg,1)
    SDFsem.up(a,:) = SDFavg(a,:) + sdfsem(a,:);
    SDFsem.down(a,:) = SDFavg(a,:) - sdfsem(a,:);
end


AvgSDFOut.SDFavg      = SDFavg;
AvgSDFOut.SDFsem      = SDFsem;



%% Plot SDF Condition Comparisons - fig 2. Monoc vs
SDFmax = max(AvgSDFOut.SDFavg,[],'all');
close all

figure;

%Monoc PS DE
plot(TM,AvgSDFOut.SDFavg(1,:),'-k','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;

% Congruent Simult PS
plot(TM,AvgSDFOut.SDFavg(2,:),'-b','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;

% IC not-average
plot(TM,AvgSDFOut.SDFavg(3,:),'-r','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(3,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(3,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;


xlim([-0.05 0.3])
ylim([-.5 1.2*SDFmax])
vline(0)

titleText = 'dCOS';
title(titleText,'interpreter', 'none')



end

