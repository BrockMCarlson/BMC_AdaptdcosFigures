%% visholder_fig2_MvsBi.m



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
conditNameForCC = IDX.Supra(1).condition.Properties.RowNames;
TM = IDX.Supra(1).tm;



% Loop through compartment for averages and data out.
for i = 1:3

    if i == 1
        holder = IDX.Supra;
    elseif i == 2
        holder = IDX.Granular;
    elseif i == 3
        holder = IDX.Infra;
    end

    uctLength = length(holder);
    
    % B. pull out all laminar matrices 3x(6,450,el#)
    %preallocate

    SDF = nan(size(holder(1).SDF.raw,1),size(holder(1).SDF.raw,2),uctLength);
    DIFF = nan(size(holder(1).SDFdiff.raw,1),size(holder(1).SDFdiff.raw,2),uctLength);

    % loop uctLength
    depth = nan(3,uctLength);
    penetration = nan(3,uctLength,11);
    CondTrialNum_SDF = nan(3,uctLength,7); %admittidly the dimensions here are a bit confusint --(laminarCompartment,numberofContacts,6differentConditionTypes) -- also, IDK how I would use this to balance as I used to...
    SDF = nan(size(holder(1).SDF.raw,1),450,3,uctLength);    
    count = 0;
    clear uct
    for uct = 1:uctLength
        switch dataType
            case 'raw'
                sdf = holder(uct).SDF.raw;
                diff = holder(uct).SDFdiff.raw;
            case 'z-scored'
                sdf = holder(uct).SDF.zs;
                diff = holder(uct).SDFdiff.zs;
        end
        count = count + 1;
        SDF(:,:,count) = sdf;
        DIFF(:,:,count) = diff;
    end

    clear holder    


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
    
    %layers bruh
    if i == 1
        AvgSDFOut.Supra.SDFavg      = SDFavg;
        AvgSDFOut.Supra.SDFsem      = SDFsem;
        AvgSDFOut.Supra.DIFFavg     = DIFFavg;
        AvgSDFOut.Supra.DIFFsem     = DIFFsem;
    elseif i == 2
        AvgSDFOut.Granular.SDFavg = SDFavg;
        AvgSDFOut.Granular.SDFsem    = SDFsem;
        AvgSDFOut.Granular.DIFFavg     = DIFFavg;
        AvgSDFOut.Granular.DIFFsem     = DIFFsem;
    elseif i == 3
        AvgSDFOut.Infra.SDFavg = SDFavg;
        AvgSDFOut.Infra.SDFsem    = SDFsem;
        AvgSDFOut.Infra.DIFFavg     = DIFFavg;
        AvgSDFOut.Infra.DIFFsem     = DIFFsem;
    end

end
clear IDX

%% Plot SDF Condition Comparisons - fig 2. Monoc vs


layers = fieldnames(AvgSDFOut);

close all
fig2ai = figure; % Monoc vs C. line plots
for ai = 1:3    
    subplot(3,1,ai)
    plot(TM,AvgSDFOut.(layers{ai}).SDFavg(1,:),'-k','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.(layers{ai}).SDFsem.up(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{ai}).SDFsem.down(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{ai}).SDFavg(2,:),'-b','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.(layers{ai}).SDFsem.up(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{ai}).SDFsem.down(2,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    xlim([-0.05 0.3])
    ylim([0 200])
    vline(0)
end
    sgtitle(IDXtextStr,'interpreter', 'none')
set(gcf,'Position',[169.8000 233 210.4000 485.6000])


fig2bi = figure; % Monoc vs IC line plots
for bi = 1:3    
    subplot(3,1,bi)
    plot(TM,AvgSDFOut.(layers{bi}).SDFavg(1,:),'-k','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.(layers{bi}).SDFsem.up(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{bi}).SDFsem.down(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{bi}).SDFavg(3,:),'-r','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.(layers{bi}).SDFsem.up(3,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{bi}).SDFsem.down(3,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    xlim([-0.05 0.3])
    ylim([0 200])
    vline(0)
end
    sgtitle(IDXtextStr,'interpreter', 'none')
set(gcf,'Position',[310.6000 74.6000 210.4000 485.6000])

fig2diff = figure; % Monoc vs IC. diff lines
for bii = 1:3    
    subplot(3,1,bii)
    plot(TM,AvgSDFOut.(layers{bii}).DIFFavg(1,:),'-b','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.(layers{bii}).DIFFsem.up(1,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{bii}).DIFFsem.down(1,:),':b','LineWidth',1,'HandleVisibility','off'); hold on;
    
    plot(TM,AvgSDFOut.(layers{bii}).DIFFavg(2,:),'-r','LineWidth',2);hold on;
    plot(TM,AvgSDFOut.(layers{bii}).DIFFsem.up(2,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,AvgSDFOut.(layers{bii}).DIFFsem.down(2,:),':r','LineWidth',1,'HandleVisibility','off'); hold on;
      
    xlim([-0.05 0.3])
    ylim([-30 60])
    vline(0)
    hline(0)
end
    sgtitle(IDXtextStr,'interpreter', 'none')
set(gcf,'Position',[770.6000 93 210.4000 485.6000])


%% SAVE

if flag_savefigs
    cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\May27CodeRestructure\fig2 - MvsBi')
        saveas(fig2ai,strcat('MvsC_line_',savename));
        saveas(fig2bi,strcat('MvsIC_line_',savename));
        saveas(fig2diff,strcat('MvsIC_diff_',savename));

end
   


