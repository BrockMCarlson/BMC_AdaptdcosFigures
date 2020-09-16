% visIDX_summaryPlot_SDF
clear
close all

flag_savefigs = 0;

IDXdir = 'C:\Users\Brock\Documents\adaptdcos figs';

IDXtextStr = 'IDX_FULLUnitAna_longSDF.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = 'C:\Users\Brock\Documents\adaptdcos figs';
figName = strcat('Summary_SDF_BugFix_CSD.pdf'); 

   cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end

       
    
% Get Laminar Counts to create NaN matrices with proper dimensions
SupraCount = 0;
GranuCount = 0;
InfraCount = 0;
for uct = 1:uctLength
    if IDX(uct).depth(2) >5
        SupraCount = SupraCount+1;        
    elseif IDX(uct).depth(2) >= 0 && IDX(uct).depth(2) <= 5
        GranuCount = GranuCount + 1;
    elseif IDX(uct).depth(2) < 0
        InfraCount = InfraCount + 1;
    end

end
    
S.CondMeanSDF           = nan(SupraCount,16,1816); % CondMeanSDF dimensions are (Condition# x Time x ContrastInNDE)
S.CondMeanSEM           = nan(SupraCount,16,1816); 
S.SubtractionSDF        = nan(SupraCount,8,1816);        

G.CondMeanSDF           = nan(GranuCount,16,1816); % CondMeanSDF dimensions are (Condition# x Time x ContrastInNDE)
G.CondMeanSEM           = nan(GranuCount,16,1816); 
G.SubtractionSDF		= nan(GranuCount,8,1816);        

I.CondMeanSDF           = nan(InfraCount,16,1816); % CondMeanSDF dimensions are (Condition# x Time x ContrastInNDE)
I.CondMeanSEM       	= nan(InfraCount,16,1816); 
I.SubtractionSDF        = nan(InfraCount,8,1816);        
    
SupraCount = 0;
GranuCount = 0;
InfraCount = 0;
for uct = 1:uctLength
    if IDX(uct).depth(2) >5
        % new dimension is (LayerCount x condition# x ContinuousTime/WindowAvg)
        SupraCount = SupraCount+1;
        S.CondMeanSDF(SupraCount,:,1:size(IDX(uct).CondMeanSDF,2))      = IDX(uct).CondMeanSDF(:,:,1); % CondMeanSDF dimensions are (Condition# x Time x ContrastInNDE)
        S.CondMeanSEM(SupraCount,:,1:size(IDX(uct).CondMeanSEM,2))       = IDX(uct).CondMeanSEM(:,:,1); 
        S.SubtractionSDF(SupraCount,:,1:size(IDX(uct).SubtractionSDF,2))       = IDX(uct).SubtractionSDF(:,:,1);         
    elseif IDX(uct).depth(2) >= 0 && IDX(uct).depth(2) <= 5
        GranuCount = GranuCount + 1;
        G.CondMeanSDF(GranuCount,:,1:size(IDX(uct).CondMeanSDF,2))       = IDX(uct).CondMeanSDF(:,:,1); % CondMeanSDF dimensions are (Condition# x Time x ContrastInNDE)
        G.CondMeanSEM(GranuCount,:,1:size(IDX(uct).CondMeanSEM,2))       = IDX(uct).CondMeanSEM(:,:,1); 
        G.SubtractionSDF(GranuCount,:,1:size(IDX(uct).SubtractionSDF,2))       = IDX(uct).SubtractionSDF(:,:,1);         
    elseif IDX(uct).depth(2) < 0
        InfraCount = InfraCount + 1;
        I.CondMeanSDF(InfraCount,:,1:size(IDX(uct).CondMeanSDF,2))       = IDX(uct).CondMeanSDF(:,:,1); % CondMeanSDF dimensions are (Condition# x Time x ContrastInNDE)
        I.CondMeanSEM(InfraCount,:,1:size(IDX(uct).CondMeanSEM,2))       = IDX(uct).CondMeanSEM(:,:,1); 
        I.SubtractionSDF(InfraCount,:,1:size(IDX(uct).SubtractionSDF,2))       = IDX(uct).SubtractionSDF(:,:,1);         
    end
end
% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
tm = IDX(1).tm;
clear IDX



%% Sum
S.CondSum(:,:) = squeeze(nanmean(S.CondMeanSDF,1));
G.CondSum(:,:) = squeeze(nanmean(G.CondMeanSDF,1));
I.CondSum(:,:) = squeeze(nanmean(I.CondMeanSDF,1));

%% Set Parameters for Plot
maxYval = 200;
% % tm = -50:1:449;
conditName = {'PE,PS,C','NE,PS,C','PE,NS,C','NE,NS,C',...
    'PE,PS,IC','NE,PS,IC','PE,NS,IC','NE,NS,IC'};
Ylabels = {'S','G','I'};


%% Plot
close all
t = tiledlayout(2,8);
for i = 1:16
    CompsForCond = nan(500,3);
    CompsForCond(:,1) = S.CondSum(i,1:500);
    CompsForCond(:,2) = G.CondSum(i,1:500);
    CompsForCond(:,3) = I.CondSum(i,1:500);
    nexttile
    if i == 1
        s(i) = stackedplot(tm,CompsForCond,'DisplayLabels',Ylabels);
    elseif i == 9
        s(i) = stackedplot(tm,CompsForCond,'DisplayLabels',Ylabels);
    else
        s(i) = stackedplot(tm,CompsForCond,'DisplayLabels',{'','',''});
    end
    s(i).AxesProperties(1).YLimits = [0 maxYval];
    s(i).AxesProperties(2).YLimits = [0 maxYval];
    s(i).AxesProperties(3).YLimits = [0 maxYval];

    if i <= 8
        title(conditName{i})
    end
end
ylabel(t,'Impulses/sec')
xlabel(t,'sec')
t.TileSpacing = 'compact';
t.Padding = 'compact';











