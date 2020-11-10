% checkKiloSortOutputs
% Made by BMC - 9/28/2020

% Take Kilosort, individual trial align, plot rasters
% Take Kilosort, all visual event median and mean, plot SDFs

%Kilosort outputs are in .rez file. 

clear



close all
PostSetup('brock')
global SORTDIR CODEDIR STIMDIR 
cd(STIMDIR)
load('PhyPref.mat') %Matlab version of excel doc. Made by hand

%% 1. Manually set inputs
% Choose desired unit
Date = '151221';
e = 6; %Available unit found on that day 

InputVars = PhyPref(e,:);

error('LOOP ALL UNITS HERE -- NEED TO PULL OUT PREFERENCE TUNING BY DEPTH AND DATE. wILL BE MISSING PREFERENCE TUNING FOR NEW FOUND UNIT.....')

%% 2. Create STIM.mat (trial info) and _KLS.mat (trial-aligned)
cd(STIMDIR)
load('151221_E_eD.mat')
STIM.units = [];
STIM.phy = [];

    % cluster_info.tsv needs to be made by Phy first... I need to organize
    % the directories....
cd(SORTDIR)
disp(strcat('importPhy run on...',SORTDIR))
[STIM,fileError]  = importPhy(STIM);


datatype = 'kls';
flag_1kHz = true;
win_ms    = [50 100; 150 250; 50 250; -50 0]; % ms;
disp('running diNeuralDat_UsePhy')
[AllUnits.RESP, win_ms, AllUnits.SDF, sdftm, PSTH, psthtm, AllUnits.SUA] = diNeuralDat_usePhy(STIM,datatype,flag_1kHz,win_ms);
disp('DONE!')



nel = length(STIM.units);


    %% Pull out the unit's tuning.
tune.DE = 3;
tune.NDE = 2;
tune.PS = 90;
tune.NPS = 180;

ContinuousDat.SDF = squeeze(AllUnits.SDF(e,:,:));
ContinuousDat.SUA = squeeze(AllUnits.SUA(e,:,:));


%% 5. All visual event average
[SDF_fulltm,SUA_fulltm,condition,CondTrialNum] = continuousDatConditionSelect(tune,STIM,ContinuousDat);
sdfwin  = [-0.05  .4];
% BMC - 10/6/2020 - I believe that the crop functions are working well
% now...
[SDF,TM] = cropDATA(SDF_fulltm,sdftm,sdfwin); warning('a lot of trials do not have reponses here....?')
[SUA,TM] = cropDATA(SUA_fulltm,sdftm,sdfwin); warning('SPY is basically a raster plot! Nz = 33... Also looks sparse:( some trials with no responses -- unit lost? ')

%% 6. Plots
%  PLOT THE SDF for all trials  
clear textIn
textForSave = strcat('SingleTrialSDF_',STIM.penetration,'__depth_',string(STIM.units(e).depth(2)));
global OUTDIR
cd(OUTDIR)
plotSDF_AllTrialsForCondition(SDF,TM,textForSave)

% MEAN PLOT (raster/SDF)
textForTitle = {'TrlAvgResponse - Session', Date, 'Unit at depth',...
    STIM.units(e).depth(2),'Monoc. Pref Stim. Dom Eye.'};
textForSave = strcat('RasterAndSDF_',STIM.penetration,'__depth_',string(STIM.units(e).depth(2)));
global OUTDIR
cd(OUTDIR)
 plotRasterAndMeanSDFForTrialsInCondition(SUA,SDF,TM,textForSave,textForTitle)


% mean/median SDFs for all visual events. 



