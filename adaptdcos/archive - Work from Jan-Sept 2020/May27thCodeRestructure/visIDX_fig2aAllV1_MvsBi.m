%% visIDX_fig2aAllV1_MvsBi.m



%% Goal
% two "report" plots that show one factor chanfe and one "difference" plot.
% All must be binned based on layer.

%1. C vs IC --> first priority
%2. Simult vs adapt

%%
clear
close all


flag_savefigs   = 0;
savename = 'testContrast_KLS.svg';
IDXtextStr = 'diIDX_-test-KLS.mat'; 


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
SDF = nan(10,450,uctLength);    
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

% T-test between Monoc, BiSimult, and DiSimult
m = squeeze(SDF(1,:,:));
bi = squeeze(SDF(5,:,:));
di = squeeze(SDF(6,:,:));

clear i h_bi h_di p_bi p_di
for i = 1:size(m,1)
    [h_bi(i,1) p_bi(i)] = ttest(m(i,:),bi(i,:));
    [h_di(i,1) p_di(i)] = ttest(m(i,:),di(i,:));
end

clear negative_Bi negative_Di
negative_Bi = false(450,1);
negative_Di = false(450,1);
negative_Bi((AvgSDFOut.SDFavg(5,:)-AvgSDFOut.SDFavg(1,:)) < 0) = true;
negative_Di((AvgSDFOut.SDFavg(6,:)-AvgSDFOut.SDFavg(1,:)) < 0) = true;


clear i xValBi  xValDi
xValBi = false(450,1);
xValDi = false(450,1);
for i = 1:size(m,1)
    if ((h_bi(i) == 1) && (negative_Bi(i)))
        xValBi(i) = true;
    end
    if ((h_di(i) == 1) && (negative_Di(i)))
        xValDi(i) = true;
    end

end


clear IDX

%% Plot SDF Condition Comparisons - fig 2. Monoc vs
SDFmax = max(AvgSDFOut.SDFavg,[],'all');

xlnBi = nan(450,1);
xlnDi = nan(450,1);
xlnBi(xValBi) = 1.1*SDFmax;
xlnDi(xValDi) = SDFmax;



close all
allV1 = figure;
    plot(TM,AvgSDFOut.SDFavg(1,:),'-k','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFavg(5,:),'-b','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(5,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;

    plot(TM,AvgSDFOut.SDFavg(6,:),'-r','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.SDFsem.up(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.SDFsem.down(6,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,xlnBi,'-b','LineWidth',2,'HandleVisibility','off'); hold on;
    plot(TM,xlnDi,'-r','LineWidth',2,'HandleVisibility','off'); hold on;
    xlim([-0.05 0.3])
    ylim([0 1.2*SDFmax])
    vline(0)


%     title(IDXtextStr,'interpreter', 'none')
set(gcf,'Position',[300.8000 83.4000 494.6000 466.2000])



%% SAVE FIGS
if flag_savefigs
    cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\May27CodeRestructure\fig2 - MvsBi')
        saveas(allV1,savename);

end

