%% visIDX_2x2.m



%%
clear
close all


flag_savefigs   = 0;
savename = '2x2.svg';
IDXtextStr = 'diIDX_add2x2-test-AUTO.mat'; 


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

% loop uctLength
depth = nan(3,uctLength);
penetration = nan(3,uctLength,11);
CondTrialNum_SDF = nan(3,uctLength,10); %admittidly the dimensions here are a bit confusint --(laminarCompartment,numberofContacts,6differentConditionTypes) -- also, IDK how I would use this to balance as I used to...
SDF = nan(10,450,uctLength);    
count = 0;
clear uct
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



% C. Average across laminar compartments 3x(10,450)
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




SubTitle= IDX.allV1(1).condition.Properties.RowNames;
SubTitle = SubTitle(1:4,:);

clear IDX   



%% Plot SDF Condition Comparisons - fig 2. Monoc vs
SDFmax = max(AvgSDFOut.SDFavg,[],'all');


close all
Monoc2x2 = figure;
for i = 1:4
subplot(2,2,i)
    plot(TM,AvgSDFOut.SDFavg(i,:),'-k','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(i,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(i,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;

    xlim([-0.05 0.3])
    ylim([0 1.2*SDFmax])
    vline(0)
    title(SubTitle{i})
end


%     title(IDXtextStr,'interpreter', 'none')
set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])



%% SAVE FIGS
if flag_savefigs
    cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\May27CodeRestructure\fig2 - MvsBi')
        saveas(Monoc2x2,savename);

end

