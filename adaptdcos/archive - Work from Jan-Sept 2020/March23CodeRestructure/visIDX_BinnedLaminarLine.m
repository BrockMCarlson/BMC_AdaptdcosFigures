%% visIDX_BinnedLaminarLine.m
% from visIDX_Surf


%% Goal
% two "report" plots that show one factor chanfe and one "difference" plot.
% All must be binned based on layer.

%1. C vs IC --> first priority
%2. Simult vs adapt

%%
clear

flag_savefigs   = 1;
global SAVEDIR
IDXdir = SAVEDIR;
cd(IDXdir)
IDXtextStr = 'diIDX_pipelineTEST_MUA.mat';
dataType = 'z-scored';
savename = 'laminarBin_MUA_MACsettings.png';

%% Initial variables
load(IDXtextStr)
uctLength = length(IDX);
conditNameForCC = IDX(1).condition.Properties.RowNames;
TM = IDX.tm;

close all
count = 0;


%% Laminar breakdown
%%
%     a. laminar counts
%     b. pull out all laminar matrices 3x(6,450,el#)
%     c. average across laminar compartments 3x(6,450)
%     d. split conditions and put into laminar matrices "reshape" 2x(3,450)
%     e. repeat for other data type
%%%%%%%%%%%
%%%%%%%%%%%

%% A. Get Laminar Counts to create NaN matrices with proper dimensions
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
longest = max([SupraLength GranuLength InfraLength]);

%% B. pull out all laminar matrices 3x(6,450,el#)
%preallocate
switch dataType
    case 'raw'
        SDF = nan(size(IDX(1).SDF,1),size(IDX(1).SDF,2),uctLength);
        CondTrialNum_SDF = nan(uctLength,size(IDX(1).SDF,1));
    case 'z-scored'
        SDF = nan(size(IDX(1).SDF_zs,1),size(IDX(1).SDF_zs,2),uctLength);
        CondTrialNum_SDF = nan(uctLength,size(IDX(1).SDF_zs,1));
end

% loop uctLength
count_S = 0;
count_G = 0;
count_I = 0;
depth = nan(3,longest);
penetration = nan(3,longest,11);
CondTrialNum_SDF = nan(3,longest,6); %admittidly the dimensions here are a bit confusint --(laminarCompartment,numberofContacts,6differentConditionTypes) -- also, IDK how I would use this to balance as I used to...
SDF = nan(6,450,3,longest);       
clear uct
for uct = 1:uctLength
    switch dataType
        case 'raw'
            dat = IDX(uct).SDF;
        case 'z-scored'
            dat = IDX(uct).SDF_zs;
    end
    if IDX(uct).depth(2) >5
        count_S = count_S + 1;
        SDF(:,:,1,count_S) = dat;
        depth(1,count_S) = IDX(uct).depth(2);
        penetration(1,count_S,:) = IDX(uct).penetration;
        CondTrialNum_SDF(1,count_S,:) = IDX(uct).CondTrialNum_SDF;
    elseif IDX(uct).depth(2) >= 0 && IDX(uct).depth(2) <= 5
        count_G = count_G + 1;
        SDF(:,:,2,count_G) = dat;
        depth(2,count_G) = IDX(uct).depth(2);
        penetration(2,count_G,:) = IDX(uct).penetration;
        CondTrialNum_SDF(2,count_G,:) = IDX(uct).CondTrialNum_SDF;
    elseif IDX(uct).depth(2) < 0
        count_I = count_I + 1;
        SDF(:,:,3,count_I) = dat;
        depth(3,count_I) = IDX(uct).depth(2);
        penetration(3,count_I,:) = IDX(uct).penetration;
        CondTrialNum_SDF(3,count_I,:) = IDX(uct).CondTrialNum_SDF;
    end
end


% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)
clear IDX
    

% % % %% Logicals for balanced conditions -- ADD THESE BACK IN??
% % % clear balanceSimult balance200 balance800
% % % balanceSimult   = ~any((CondTrialNum_SDF(:,[1 2]) == 0),2);
% % % balance200      = ~any((CondTrialNum_SDF(:,[3 4]) == 0),2);
% % % balance800      = ~any((CondTrialNum_SDF(:,[5 6]) == 0),2);

% % % %% Sum
% % % SDFavg_Simult   = squeeze(nanmean(SDF(:,:,balanceSimult),3));
% % % SDFavg_200      = squeeze(nanmean(SDF(:,:,balance200),3));
% % % SDFavg_800      = squeeze(nanmean(SDF(:,:,balance800),3));

%% C. Average across laminar compartments 3x(6,450)
clear supSDFavg granSDFavg infraSDFabg
supSDFavg = nanmean(squeeze(SDF(:,:,1,:)),3);
granSDFavg = nanmean(squeeze(SDF(:,:,2,:)),3); % This returns all NaNs... ?
infraSDFabg = nanmean(squeeze(SDF(:,:,3,:)),3); % This returns all NaNs...?

%% D. Split conditions and put into laminar matrices "reshape" 2x(450,3)
clear C800SDFavg IC800SDFavg ICsimultSDFavg
C800SDFavg(1,:) = supSDFavg(5,:);
C800SDFavg(2,:) = granSDFavg(5,:);
C800SDFavg(3,:) = infraSDFabg(5,:);

IC800SDFavg(1,:) = supSDFavg(6,:);
IC800SDFavg(2,:) = granSDFavg(6,:);
IC800SDFavg(3,:) = infraSDFabg(6,:);


%% E. Repeat for other data type
CsimultSDFavg(1,:) = supSDFavg(1,:);
CsimultSDFavg(2,:) = granSDFavg(1,:);
CsimultSDFavg(3,:) = infraSDFabg(1,:);

ICsimultSDFavg(1,:) = supSDFavg(2,:);
ICsimultSDFavg(2,:) = granSDFavg(2,:);
ICsimultSDFavg(3,:) = infraSDFabg(2,:);


%% Plot SDF Condition Comparisons
close all
fig1 = figure;
set(gcf,'Position',[488 25.8000 376.6000 736.2000])
clear i
for i = 1:3
    subplot(3,1,i)
    plot(TM,CsimultSDFavg(i,:),'k');hold on;
    plot(TM,ICsimultSDFavg(i,:),'r'); hold on;
    plot(TM,C800SDFavg(i,:),'b');hold on;
    plot(TM,IC800SDFavg(i,:),'g');
% %     switch dataType
% %         case 'raw'
% %             ylim([-800 300])
% %         case 'z-scored'
% %             ylim([-50 20])
% %     end
    xlim([TM(1) TM(end)])
    hline(0)
    vline(0)
end
legend({'C_Simult','IC_Simult','C_800','IC_800'},'Interpreter', 'none')
sgtitle({'CSD',dataType})

%% SAVE FIGS
if flag_savefigs
    cd(SAVEDIR)
    saveas(fig1,savename);
end

