% twoUnit_TestSortConfigs
%BMC - 10/8/2020

% The purpose of this code is a result of my conversation with Alex on
% 10/7/2020, wherin I outlined the reults of checkKiloSortOutputs.m

% The new goal of this code is to compare two units on session 151221 under
% different sort conditions so as to be abole to play with the parameters
% in the kiloconfig file and directly see their results.

% checkKiloSortoutputs. pulled from two directories "Old Outputs" and "New
% Outputs" for 151221. A lot of information had to be manually set,
% such as the tuning information. The biggest hassel when going between
% the old and new sort parameters is that the electrode number (under "e"
% or "nel") is not consistant across sorts. This code hopes to rectify this
% issues by finding units based on the desired depth on the session.

% Fun info for posterity: This code is created while listening to Dark Side
% of the Moon and BRONSON...

%% Where are you pulling things from?

%         SORTDIR  =  'C:\Users\Brock\Desktop\151221_E_eD\KLSoutputs\';
%         PLOTDIR   =  'C:\Users\Brock\Desktop\151221_E_eD\Plot Directory\';


%% Process
% 
% Date = 151221;
% Depths = {-3,9}; check what should be the second unit - use highest ... 
%     firing unit available. pull from STIM.units
% 
% BIG QUESTION --- how to I organize my sorts???
% 
% I think I should use
% recursdir(KLSoutputDirecotry) which would hold all of the individual sorts 
% so a folder could be added with each sort, and this code can still run on it
% 
% 
% Big "i" loop will be around how many sorts are in the output directory!
% 
% Better yet - why not create a plot for each unit, and plot the different configurations side by side!


%%
clear
close all
PostSetup('brock')
global SORTDIR PLOTDIR STIMDIR


Date = 151221;
Depths = {-3,9}; 
folders = recursdir(SORTDIR,'spike_clusters.npy');
DirsToLoop = cellfun(@(x) x(1:end-18),folders,'UniformOutput',false); %UniOut must be false because


%establish figures
close all
f1 = figure;
textForTitle = {'Unit at depth -3','Monoc. Pref Stim. Dom Eye.'};

sgtitle(textForTitle)
f2 = figure;
textForTitle = {'Unit at depth 9','Monoc. Pref Stim. Dom Eye.'};
sgtitle(textForTitle)

cd(STIMDIR)
load('151221_E_eD.mat')
count = 0;
for i = 1:size(DirsToLoop,2) % looping through KLS config settings
    sortConfigDir = DirsToLoop{i};
    STIM.units = [];
    STIM.phy = [];
    cd(DirsToLoop{i})
    disp(strcat('importPhy run on...',sortConfigDir))
    [STIM] = importPhy(STIM,sortConfigDir);
    unitsDepth = [STIM.units.depth]';
    unitIndex(1) = find(unitsDepth(:,2) == -3);
    unitIndex(2) = find(unitsDepth(:,2) ==  9);

    
    disp('running diNeuralDat_UsePhy')
    [AllUnits.RESP, win_ms, AllUnits.SDF, sdftm, PSTH, psthtm, AllUnits.SUA] = diNeuralDat_usePhy(STIM,'kls',true,[50 100; 150 250; 50 250; -50 0]); %(STIM,datatype,flag_1kHz,win_ms)
    disp('DONE!')
    
    


    
    for j = 1:2 % 1 at depth -3, 2 at depth 9. looping through units of interest
        ContinuousDat.SDF = squeeze(AllUnits.SDF(unitIndex(j),:,:));
        ContinuousDat.SUA = squeeze(AllUnits.SUA(unitIndex(j),:,:));
        
        % Pull out the unit's tuning. -- Tuning should be same for both
        % units according to PhyPref.mat in STIMDIR
            tune.DE = 3;
            tune.NDE = 2;
            tune.PS = 90;
            tune.NPS = 180;
            
        %Condition selection -- pulls continuous data array at the full
        %sdftm window from diNeuralDat for every condition of interest.
        %Requires user input to select the condition. Select "1" for
        %monocular PS DE
            [SDF_fulltm,SUA_fulltm,condition,CondTrialNum] =...
                continuousDatConditionSelect(tune,STIM,ContinuousDat);
        
        %Crop down to time window of interest
            sdfwin  = [-0.05  .4];
            [SDF,TM] = cropDATA(SDF_fulltm,sdftm,sdfwin); 
                warning('a lot of trials do not have reponses here....?')
            [SUA,TM] = cropDATA(SUA_fulltm,sdftm,sdfwin); 
                warning('SPY is basically a raster plot! Nz = 33... Also looks sparse:( some trials with no responses -- unit lost? ')
            %output here should be (19[monoc trials]x450[ms])


        % PLOT (raster/SDF)

        if j == 1
            figure(f1) %unit #1. depth -3
        elseif j == 2
            figure(f2)   % unit #2  . depth 9     
        end
        %create subplot indexes
        numOfConfigs = size(DirsToLoop,2);
        numOfSubPlots = numOfConfigs*2;
        subIndex = reshape(1:numOfSubPlots, [numOfConfigs,2]);

        %SDF plot
            subplot(2,size(DirsToLoop,2),subIndex(i,1))
            SDFTrlsMean   = nanmean(SDF,1);    % Use trls to pull out continuous data   
            plot(TM,SDFTrlsMean)  
            vline(0)
            ylabel('spks/sec')
            xlabel('Time(sec)')
            %title
                fr = string(STIM.units(unitIndex(j)).rate);
                title({strcat('ConfigNum',num2str(i)),strcat('FiringRate=',fr)})

        
        % raster
        count = count+1;
        subplot(2,size(DirsToLoop,2),subIndex(i,2))
            spikesIn = SUA == 1;
            MarkerFormat.MarkerSize = 5;
            MarkerFormat.Marker = '.';
            plotSpikeRaster(spikesIn,'PlotType','scatter','MarkerFormat',MarkerFormat);
            newTM = TM(50:50:end);
            if newTM(9) ~= .4
                error('check the manual TM input')
            end
            newNewTM = nan(1,length(newTM)+1);
            newNewTM(1) = -.050;
            newNewTM(2:length(newTM)+1) = newTM;
            xticks(0:50:450);
            xticklabels(newNewTM);
            vline(50) % This unfortunatly is an index and not a label.
            ylabel('Trial Number')   
            
    end
 

end
cd(PLOTDIR)
figure(f1)
export_fig('depth-3','-pdf','-nocrop')
figure(f2)
export_fig('depth9','-pdf','-nocrop')


