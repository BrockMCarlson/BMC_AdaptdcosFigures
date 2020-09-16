%% visIDX_EffectOFAdap_laminar_subtractionPlots
% from visIDX_PairwiseComp_laminar


%% Goal
%just like JoV fig 4 
%plotted as a difference relative to monocular stimulation

%%
clear
close all

flag_savefigs   = 1;
variance = 'SEM';
layer    = 'all';
CongOrIC = 'IC';

IDXdir = 'C:\Users\Brock\Documents\MATLAB\diIDXdirectory';

IDXtextStr = 'diIDX_EffectOfAdap_IC.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = IDXdir;
figName = strcat('EffectOfAdap_IC_subtraction'); 

if flag_savefigs
    cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end
end

TM = IDX.tm;

%% Laminar dissection
    
% Get Laminar Counts to create NaN matrices with proper dimensions
SupraLength = 0;
GranuLength = 0;
InfraLength = 0;
for uct = 1:uctLength
    if IDX(uct).depth(2) >5
        SupraLength = SupraLength+1;        
    elseif IDX(uct).depth(2) >= 0 && IDX(uct).depth(2) <= 5
        GranuLength = GranuLength + 1;
    elseif IDX(uct).depth(2) < 0
        InfraLength = InfraLength + 1;
    end

end

if strcmp(CongOrIC,'Cong')
    binocDim = 1;
elseif strcmp(CongOrIC,'IC')
    binocDim = 2;
else
    error('fix binocDim')
end


count = 0;
switch layer
    case 'supragranular'
        SDF = nan(size(IDX(1).SDF_S,1),size(IDX(1).SDF_S,2),SupraLength);
        for uct = 1:uctLength
            if IDX(uct).depth(2) >5
                count = count+1;
                SDF(1,:,count) = IDX(uct).SDF_monoc(1,:);
                SDF(2,:,count) = IDX(uct).SDF_Bi(binocDim,:);
                SDF(3,:,count) = IDX(uct).SDF_S(binocDim,:);
            end
        end
        varianceLength = SupraLength;
    case 'granular'
        SDF = nan(size(IDX(1).SDF_S,1),size(IDX(1).SDF_S,2),GranuLength);
        for uct = 1:uctLength
            if IDX(uct).depth(2) >= 0 && IDX(uct).depth(2) <= 5
                count = count+1;
                SDF(1,:,count) = IDX(uct).SDF_monoc(1,:);
                SDF(2,:,count) = IDX(uct).SDF_Bi(binocDim,:);
                SDF(3,:,count) = IDX(uct).SDF_S(binocDim,:);
            end
        end
        varianceLength = GranuLength;
    case 'infragranular'
        SDF = nan(size(IDX(1).SDF_S,1),size(IDX(1).SDF_S,2),InfraLength);
        for uct = 1:uctLength
            if IDX(uct).depth(2) < 0
                count = count+1;
                SDF(1,:,count) = IDX(uct).SDF_monoc(1,:);
                SDF(2,:,count) = IDX(uct).SDF_Bi(binocDim,:);
                SDF(3,:,count) = IDX(uct).SDF_S(binocDim,:);
            end
        end
        varianceLength = InfraLength;
    case 'all'
        SDF = nan(size(IDX(1).SDF_S,1),size(IDX(1).SDF_S,2),uctLength);
        for uct = 1:uctLength
                count = count+1;
                SDF(1,:,count) = IDX(uct).SDF_monoc(1,:);
                SDF(2,:,count) = IDX(uct).SDF_Bi(binocDim,:);
                SDF(3,:,count) = IDX(uct).SDF_S(binocDim,:);
        end
        varianceLength = uctLength;
end


% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
clear IDX



%% Sum
SDFavg = squeeze(nanmean(SDF,3));

%% STD
STD = nanstd(SDF,[],3); 

%% SEM
SEM = (nanstd(SDF,[],3))./sqrt(varianceLength);

%% Confidence interval calculation - for both adapter and suppressor

SEM = nanstd(SDF,[],3)/sqrt(varianceLength);	% Standard Error
ts = tinv(0.99,varianceLength-1);                   % T-Score at the 99th percentile
CI = squeeze(nanmean(SDF,3))+ ts*SEM;          % Confidence Intervals
CI_A(:,:) = CI;
    
%% Subtraction

SUB(1,:) = SDFavg(2,:)-SDFavg(1,:);
SUB(2,:) = SDFavg(3,:)-SDFavg(1,:);


%% Get out variance lines
switch variance
    case 'STD'
        error('This variance not set up yet')
        varUsed = STD;
    case 'SEM'
        varUsed(1,:) = SEM(2,:)+SEM(1,:);
        varUsed(2,:) = SEM(3,:)+SEM(1,:);
        
    case 'CI'
        varUsed = CI_A;
        error('This variance not set up yet')
end
for a = 1:size(SUB,1)
    SEMline_Up(a,:) = SUB(a,:) + varUsed(a,:);
    SEMline_Down(a,:) = SUB(a,:) - varUsed(a,:);

end




%% Set Parameters for Plot
maxYval = max(max(SUB));

conditName = {...
    'Simult',...
    'Suppressor'};




%% Plot
% Every comparison

figure
colorMain = {'-b','-m'};
colorVar  = {':b',':m'};
clear i
for i = 1:2
p(i) = plot(TM,SUB(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,SEMline_Up(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,SEMline_Down(i,:),colorVar{i},'LineWidth',1); hold on
ylim([-0.25 .2]);
xlim([-.05 .8]);
end
vline(0)
hline(0)
legend([p(1) p(2)],conditName)
title({CongOrIC,strcat('Layer=',layer)})

if flag_savefigs
    cd(figDir)
    export_fig(figName,'-jpg','-nocrop') 
end