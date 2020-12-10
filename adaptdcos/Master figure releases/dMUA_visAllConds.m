% dMUA_visAllConds
% take fro, diIDX_AUTO_JoVContrast.mat found in D:\5 diIDX dir\ and plot
% all the conditions for each individual contact found with significant
% responses within V1,

% Manually input the day to use. I will use 160108 first becuase of the
% example KLS units that can go with this... However, I should also look at
% 161005.

% The bulk of this code will be in setting up a new visualization function
% that, for each "unit" (Multi-unit in this case" plots the whole condition
% matrix. I estimate four figures will be needed. They are as follows:

% fig1 - Monoc 2x2 (perhaps I already have a vis funciton for this?)
% fig2 - All simultaneous conditions. binocular and dichoptic. Done at JoV
% contrast to hopefully see dCOS
% fig3 - binocular adapted conditions -- all of these are the same stim in
% each eye, but with varying history and PS vs NS
% fig4 - dichoptic adapted conditions - BRFS with each eye and ori. All
% options are avaialbe. 
    % Note - if you don't see a clean result in figure 4 make sure you
    % check 161005


clear
close all


flag_saveFigs = false;

cd('D:\5 diIDX dir')
<<<<<<< Updated upstream:adaptdcos/Master figure releases/dMUA_visAllConds.m
load('diIDX_AUTO_160108')
=======
if exist('diIDX_AUTO_160108','file')
    load('diIDX_AUTO_160108') % this has all 16 conditions.
else
    AUTOdiIDX_160108allCond
    clear
    load('diIDX_AUTO_160108')
end
>>>>>>> Stashed changes:adaptdcos/Master figure releases/1.2 dMUAdCOF/dMUA_visAllConds.m





uctLength = length(IDX.allV1);
% loop uctLength
count = 0;
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).tm;

clear uct
for uct = 1:uctLength
    if strcmp(IDX.allV1(uct).penetration,'160108_E_eD')
    
        sdf = IDX.allV1(uct).SDF.zs;

        count = count + 1;
        SDF(:,:,count)  = sdf; clear sdf;
        INFO(count).Depth    = IDX.allV1(uct).depth(2);
        INFO(count).DE  = IDX.allV1(uct).DE;
        INFO(count).NDE   = IDX.allV1(uct).NDE;
        INFO(count).PS   = IDX.allV1(uct).PS;
        INFO(count).NS    = IDX.allV1(uct).NS;
        INFO(count).CondTrialNum_SDF    = IDX.allV1(uct).CondTrialNum_SDF;
        INFO(count).conditNameForCC    = conditNameForCC;
        INFO(count).TM    = TM;

    end
end

clear IDX


%% Figures!
for i = 1:size(SDF,3)
    close all
    sdf = squeeze(SDF(:,:,i));
    info = INFO(i);
    Monoc = visIDX_Monoc_fromAUTO(sdf,info);
    Simult = visIDX_Simult_fromAUTO(sdf,info);
    Csoa = visIDX_Csoa_fromAUTO(sdf,info);
    ICsoa = visIDX_ICsoa_fromAUTO(sdf,info);


    if flag_saveFigs
        cd('D:\6 Plot Dir\dMUAdCOF\160108 All Cond')
        saveas(Monoc,strcat('_',string(info.Depth),'_Monoc.png'));
        saveas(Simult,strcat('_',string(info.Depth),'_Simult.png'));
        saveas(Csoa,strcat('_',string(info.Depth),'_Csoa.png'));
        saveas(ICsoa,strcat('_',string(info.Depth),'_ICsoa.png'));
    end

end
