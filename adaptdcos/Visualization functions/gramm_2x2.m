function gramm_2x2(IDX,dataType)

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

CvsICvsSvsAd(1,:,:) = SDF(5,:,:);
CvsICvsSvsAd(2,:,:) = SDF(7,:,:);
CvsICvsSvsAd(3,:,:) = SDF(10,:,:);
CvsICvsSvsAd(4,:,:) = SDF(18,:,:);

DIFF(1,:,:) = CvsICvsSvsAd(1,:,:) - CvsICvsSvsAd(2,:,:);
DIFF(2,:,:) = CvsICvsSvsAd(3,:,:) - CvsICvsSvsAd(4,:,:);


% C. Average across laminar compartments 3x(6,450)
% Avg
clear SDFavg 
SDFavg = nanmean(squeeze(CvsICvsSvsAd(:,:,:)),3);
DIFFavg = nanmean(squeeze(DIFF(:,:,:)),3);


%SEM
sdfsem  = (nanstd(squeeze(CvsICvsSvsAd(:,:,:)),[],3))./sqrt(count);
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
AvgDIFFOut.SDFavg      = DIFFavg;
AvgDIFFOut.SDFsem      = DIFFsem;


%% Plot SDF Condition Comparisons - fig 2. Monoc vs
SDFmax = max(AvgSDFOut.SDFavg,[],'all');
close all

figure;

%C Simult PS DE
plot(TM,AvgSDFOut.SDFavg(1,:),'-b','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(1,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(1,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;

% IC Simult PS DE
plot(TM,AvgSDFOut.SDFavg(2,:),'-r','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(2,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(2,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;

% C adapted PS DE flash
plot(TM,AvgSDFOut.SDFavg(3,:),'-c','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(3,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(3,:),':c','LineWidth',1,'HandleVisibility','off'); hold on;

% IC adapted PS DE flash
plot(TM,AvgSDFOut.SDFavg(4,:),'-y','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(4,:),':y','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(4,:),':y','LineWidth',1,'HandleVisibility','off'); hold on;

xlim([-0.05 0.5])
ylim([-.5 1.2*SDFmax])
vline(0)

titleText = '2x2';
title(titleText,'interpreter', 'none')

figure
%C Simult PS DE
plot(TM,AvgDIFFOut.SDFavg(1,:),'-m','LineWidth',2);hold on;
plot(TM,AvgDIFFOut.SDFsem.up(1,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgDIFFOut.SDFsem.down(1,:),':m','LineWidth',1,'HandleVisibility','off'); hold on;

% IC Simult PS DE
plot(TM,AvgDIFFOut.SDFavg(2,:),'-g','LineWidth',2);hold on;
plot(TM,AvgDIFFOut.SDFsem.up(2,:),':g','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgDIFFOut.SDFsem.down(2,:),':g','LineWidth',1,'HandleVisibility','off'); hold on;

xlim([-0.05 0.5])
% ylim([-.5 1.2*SDFmax])
vline(0)
hline(0)

titleText = 'diff';
title(titleText,'interpreter', 'none')


end

