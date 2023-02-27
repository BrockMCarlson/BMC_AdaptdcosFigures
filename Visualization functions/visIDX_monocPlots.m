function visIDX_monocPlots(IDX,dataType)

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
% 
%     {'Monocualr PS DE'                         }
%     {'Monocualr NS NDE'                        }
%     {'Monocualr NS DE'                         }
%     {'Monocualr PS NDE'                        }
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

monocCond(1,:,:) = SDF(1,:,:);
monocCond(2,:,:) = SDF(4,:,:);







% C. Average across laminar compartments 3x(6,450)
% Avg
clear SDFavg 
SDFavg = nanmean(squeeze(monocCond(:,:,:)),3);


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

%Monoc PS NDE
plot(TM,AvgSDFOut.SDFavg(2,:),'-b','LineWidth',2);hold on;
plot(TM,AvgSDFOut.SDFsem.up(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
plot(TM,AvgSDFOut.SDFsem.down(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;




xlim([-0.05 0.85])
ylim([-.5 1.2*SDFmax])
vline(0)

titleText = 'Monoc DE vs NDE - always pref Stim';
title(titleText,'interpreter', 'none')



end

