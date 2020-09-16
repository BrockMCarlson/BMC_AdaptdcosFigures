%% visIDX_BinnedLaminarLine.m
% from visIDX_Surf


%% Goal
% two "report" plots that show one factor chanfe and one "difference" plot.
% All must be binned based on layer.

%1. C vs IC --> first priority
%2. Simult vs adapt

%%
clear

flag_savefigs   = 0;
IDXdir = 'C:\Users\Brock\Documents\MATLAB\Working IDX Dir';
cd(IDXdir)
IDXtextStr = 'diIDX_March23Restructure.mat'; % pref tuning based on AUTO -- SDF from CSD
dataType = 'raw';

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

clear IDX    



%% C. Average across laminar compartments 3x(6,450)
% Avg
clear supSDFavg granSDFavg infraSDFabg
supSDFavg = nanmean(squeeze(SDF(:,:,1,:)),3);
granSDFavg = nanmean(squeeze(SDF(:,:,2,:)),3); 
infraSDFabg = nanmean(squeeze(SDF(:,:,3,:)),3); 

%SEM
SEM_S  = (nanstd(squeeze(SDF(:,:,1,:)),[],3))./sqrt(count_S);
for a = 1:size(supSDFavg,1)
    SEMline_Up_S(a,:) = supSDFavg(a,:) + SEM_S(a,:);
    SEMline_Down_S(a,:) = supSDFavg(a,:) - SEM_S(a,:);
end
SEM_G  = (nanstd(squeeze(SDF(:,:,2,:)),[],3))./sqrt(count_G);
for a = 1:size(granSDFavg,1)
    SEMline_Up_G(a,:) = granSDFavg(a,:) + SEM_G(a,:);
    SEMline_Down_G(a,:) = granSDFavg(a,:) - SEM_G(a,:);
end
SEM_I  = (nanstd(squeeze(SDF(:,:,3,:)),[],3))./sqrt(count_I);
for a = 1:size(infraSDFabg,1)
    SEMline_Up_I(a,:) = infraSDFabg(a,:) + SEM_I(a,:);
    SEMline_Down_I(a,:) = infraSDFabg(a,:) - SEM_I(a,:);
end

%% D. Split conditions and put into laminar matrices "reshape" 2x(450,3)
%Avg
clear C800SDFavg IC800SDFavg 
C800SDFavg(1,:) = supSDFavg(5,:);
C800SDFavg(2,:) = granSDFavg(5,:);
C800SDFavg(3,:) = infraSDFabg(5,:);

IC800SDFavg(1,:) = supSDFavg(6,:);
IC800SDFavg(2,:) = granSDFavg(6,:);
IC800SDFavg(3,:) = infraSDFabg(6,:);

%SEM
clear C800SDF_sem_up C800SDF_sem_down IC800SDF_sem_up IC800SDF_sem_down
C800SDF_sem_up(1,:) = SEMline_Up_S(5,:);
C800SDF_sem_up(2,:) = SEMline_Up_G(5,:);
C800SDF_sem_up(3,:) = SEMline_Up_I(5,:);

C800SDF_sem_down(1,:) = SEMline_Down_S(5,:);
C800SDF_sem_down(2,:) = SEMline_Down_G(5,:);
C800SDF_sem_down(3,:) = SEMline_Down_I(5,:);

IC800SDF_sem_up(1,:) = SEMline_Up_S(6,:);
IC800SDF_sem_up(2,:) = SEMline_Up_G(6,:);
IC800SDF_sem_up(3,:) = SEMline_Up_I(6,:);

IC800SDF_sem_down(1,:) = SEMline_Down_S(6,:);
IC800SDF_sem_down(2,:) = SEMline_Down_G(6,:);
IC800SDF_sem_down(3,:) = SEMline_Down_I(6,:);

%% E. Repeat for other data type
%AVG
clear CsimultSDFavg ICsimultSDFavg 
CsimultSDFavg(1,:) = supSDFavg(1,:);
CsimultSDFavg(2,:) = granSDFavg(1,:);
CsimultSDFavg(3,:) = infraSDFabg(1,:);

ICsimultSDFavg(1,:) = supSDFavg(2,:);
ICsimultSDFavg(2,:) = granSDFavg(2,:);
ICsimultSDFavg(3,:) = infraSDFabg(2,:);

%SEM
clear CsimultSDF_sem_up CsimultSDF_sem_down ICsimultSDF_sem_up ICsimultSDF_sem_down
CsimultSDF_sem_up(1,:) = SEMline_Up_S(1,:);
CsimultSDF_sem_up(2,:) = SEMline_Up_G(1,:);
CsimultSDF_sem_up(3,:) = SEMline_Up_I(1,:);

CsimultSDF_sem_down(1,:) = SEMline_Down_S(1,:);
CsimultSDF_sem_down(2,:) = SEMline_Down_G(1,:);
CsimultSDF_sem_down(3,:) = SEMline_Down_I(1,:);

ICsimultSDF_sem_up(1,:) = SEMline_Up_S(2,:);
ICsimultSDF_sem_up(2,:) = SEMline_Up_G(2,:);
ICsimultSDF_sem_up(3,:) = SEMline_Up_I(2,:);

ICsimultSDF_sem_down(1,:) = SEMline_Down_S(2,:);
ICsimultSDF_sem_down(2,:) = SEMline_Down_G(2,:);
ICsimultSDF_sem_down(3,:) = SEMline_Down_I(2,:);


%% Plot SDF Condition Comparisons
close all
fig1 = figure;
set(gcf,'Position',[488 25.8000 376.6000 736.2000])
colorMain = {'-k','-r','-b','-g','-b','-g'};
colorVar  = {':k',':r',':b',':g',':b',':g'};
clear i
for i = 1:3
    colorCount = 1;
    subplot(3,1,i)
    plot(TM,CsimultSDFavg(i,:),colorMain{colorCount},'LineWidth',2);hold on;
    plot(TM,CsimultSDF_sem_up(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,CsimultSDF_sem_down(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;
    
    colorCount = colorCount +1;
    plot(TM,ICsimultSDFavg(i,:),'r','LineWidth',2); hold on;
    plot(TM,ICsimultSDF_sem_up(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,ICsimultSDF_sem_down(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;

    colorCount = colorCount +1;
    plot(TM,C800SDFavg(i,:),'b','LineWidth',2);hold on;
    plot(TM,C800SDF_sem_up(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,C800SDF_sem_down(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;

    colorCount = colorCount +1;
    plot(TM,IC800SDFavg(i,:),'g','LineWidth',2);
    plot(TM,IC800SDF_sem_up(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;
    plot(TM,IC800SDF_sem_down(i,:),colorVar{colorCount},'LineWidth',1,'HandleVisibility','off'); hold on;
   
    switch dataType
        case 'raw'
            ylim([0 200])
        case 'z-scored'
            ylim([0 5])
    end
    xlim([TM(1) TM(end)])
    hline(0)
    vline(0)
end
legend({'C_Simult','IC_Simult','C_800','IC_800'},'Interpreter', 'none')
sgtitle({'dMUA',dataType})



