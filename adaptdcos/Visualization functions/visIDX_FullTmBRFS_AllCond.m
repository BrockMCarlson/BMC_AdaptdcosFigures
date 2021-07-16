function visIDX_FullTmBRFS_AllCond(IDX,dataType)

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM;


uctLength = length(IDX.allV1);

% B. pull out all laminar matrices 3x(6,450,el#)
%preallocate

SDF = nan(size(IDX.allV1(1).SDF.raw,1),size(IDX.allV1(1).SDF.raw,2),uctLength);

% loop uctLength
count = 0;
for uct = 1:uctLength
    if strcmp(IDX.allV1(uct).penetration,'160108_E_eD')
        count = count + 1;
        switch dataType
            case 'raw'
                sdf = IDX.allV1(uct).SDF.raw;
            case 'z-scored'
                sdf = IDX.allV1(uct).SDF.zs;
        end
        SDF(:,:,count) = sdf;
    end
end
clear IDX


% C. Average across laminar compartments 3x(6,450)
% Avg
clear SDFavg 
SDFavg = nanmean(squeeze(SDF(:,:,:)),3);


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
for i = 1:size(AvgSDFOut.SDFavg,1)

	figure;
    plot(TM,AvgSDFOut.SDFavg(i,:),'-k','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(i,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(i,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
   
    xlim([-0.05 0.8])
    ylim([-.5 1.2*SDFmax])
    vline(0)
   
    titleText = strcat('160108_',conditNameForCC{i,1});
    title(titleText,'interpreter', 'none')
%     set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])
end


end

