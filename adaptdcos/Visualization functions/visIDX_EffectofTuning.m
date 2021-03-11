function visIDX_EffectofTuning(IDX,dataType)

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).tm;

ThisCodeDidNotProduceExpectedResults_CheckForBug

uctLength = length(IDX.allV1);

% B. pull out all laminar matrices 3x(6,450,el#)
%preallocate

SDF = nan(size(IDX.allV1(1).SDF.raw,1),size(IDX.allV1(1).SDF.raw,2),uctLength);

% loop uctLength
count = 0;
for uct = 1:uctLength
    if IDX.allV1(uct).occ(3) >= .05 && strcmp(IDX.allV1(uct).penetration,'160108_E_eD')
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


%% Concatenate the re-triggered BRFS full tm
% SDF(17,1:850,:) + SDF(18,50:849), least exciting adapter, most exciting
% suppressor
% SDF(19,1:850,:) + SDF(20,50:849), most exciting adapter, least exciting
% suppressor.
clear PreAvg
PreAvg(1,:,:) = [squeeze(SDF(17,1:850,:))',squeeze(SDF(18,50:899,:))']';
PreAvg(2,:,:) = [squeeze(SDF(19,1:850,:))',squeeze(SDF(20,50:899,:))']';


%% C. Average across laminar compartments 3x(6,450)
% Avg
clear SDFavg filtThis indexForFilt
SDFavg = nanmean(squeeze(PreAvg(:,:,:)),3);
% % filtThis = SDFavg(:,1:1663);
% % 
% % Fs = 1000;
% % nyq = Fs/2;
% % lpc = 20; %low pass cutoff
% % lWn = lpc/nyq;
% % [bwb,bwa] = butter(4,lWn,'low');
% % filteredSDF = abs(filtfilt(bwb,bwa,filtThis')); 
% % 
% % close all
% % figure
% % plot(filteredSDF(:,1))
% % figure
% % plot(filteredSDF(:,2))

        
        
%SEM
sdfsem  = (nanstd(squeeze(PreAvg(:,:,:)),[],3))./sqrt(count);
for a = 1:size(SDFavg,1)
    SDFsem.up(a,:) = SDFavg(a,:) + sdfsem(a,:);
    SDFsem.down(a,:) = SDFavg(a,:) - sdfsem(a,:);
end


AvgSDFOut.SDFavg      = SDFavg;
AvgSDFOut.SDFsem      = SDFsem;



%% Plot SDF Condition Comparisons - fig 2. Monoc vs
SDFmax = max(AvgSDFOut.SDFavg,[],'all');
close all
fullTm = -.05:.001:1.599;
for i = 1:size(AvgSDFOut.SDFavg,1)

	figure;
    plot(fullTm,AvgSDFOut.SDFavg(i,1:1650),'-k','LineWidth',2);hold on;
    plot(fullTm,AvgSDFOut.SDFsem.up(i,1:1650),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(fullTm,AvgSDFOut.SDFsem.down(i,1:1650),':k','LineWidth',1,'HandleVisibility','off'); hold on;
   
    xlim([-0.05 1.6])
    ylim([-.5 1.2*SDFmax])
    vline(0)
    vline(.8)
   
    titleText = strcat('allunitWithNoTuningOriOrEye_',num2str(count));
    title(titleText,'interpreter', 'none')
    set(gcf,'Position',[220.2000 275.4000 1.1408e+03 440.0000])
end


end

