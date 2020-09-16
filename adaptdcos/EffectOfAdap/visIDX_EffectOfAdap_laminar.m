%% visIDX_EffectOFAdap_laminar
% from visIDX_PairwiseComp_laminar


%% Goal
% 2 plots: The first is comparing congruent and the second is comparing
% incongruent. Condition are balanced within plot. Fig 1. is MonocPSDE vs
% BinocSimultCongPS vs BinocSuppressorCongPSflashtoDE. Fig2 is MonocPSDE vs
% BinocSimultIncongPStoDe vs BinocSuppresorIncongPSflashtoDE.

%Total number of units with either one or the other condigition balanced is
%127.


%%
clear
close all

flag_savefigs   = 1;
variance = 'SEM';
layer    = 'infragranular';
CongOrIC = 'IC';

IDXdir = 'C:\Users\Brock\Documents\MATLAB\diIDXdirectory';

IDXtextStr = 'diIDX_EffectOfAdap_IC_CSD-notNorm.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = IDXdir;
figName = strcat('EffectOfAdap_IC_infragranular_CSD'); 

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
    


%% Get out variance lines
switch variance
    case 'STD'
        varUsed = STD;
    case 'SEM'
        varUsed = SEM;
    case 'CI'
        varUsed = CI_A;
end
for a = 1:size(SDFavg,1)
    SEMline_Up(a,:) = SDFavg(a,:) + varUsed(a,:);
    SEMline_Down(a,:) = SDFavg(a,:) - varUsed(a,:);

end




%% Set Parameters for Plot
maxYval = max(max(SDFavg));

conditName = {...
    'monoc',...
    'Simult',...
    'Suppressor'};




%% Plot
% Every comparison

figure
colorMain = {'-k','-b','-m'};
colorVar  = {':k',':b',':m'};
clear i
for i = 1:3
p(i) = plot(TM,SDFavg(i,:),colorMain{i},'LineWidth',2); hold on
plot(TM,SEMline_Up(i,:),colorVar{i},'LineWidth',1); hold on
plot(TM,SEMline_Down(i,:),colorVar{i},'LineWidth',1); hold on
% % ylim([0 1.1]);
xlim([-.05 .8]);
end
vline(0)
legend([p(1) p(2) p(3)],conditName)
title({CongOrIC,strcat('Layer=',layer)})

if flag_savefigs
    cd(figDir)
    export_fig(figName,'-jpg','-nocrop') 
end