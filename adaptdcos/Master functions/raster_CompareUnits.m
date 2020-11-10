% raster_CompareUnits
% adapted from twoUnit_TestSortConfigs.m
%BMC - 10/8/2020

%The purpose of this code is to plot a condition-specific 2xN subplot 
%where N is the number of units in the SORTDIR,
% i.e. monoc PS compared across all sorted units as visualized by a stacked
% SDF and raster in each column. Each column is a different unit.
% "input" allows the condition to be selected. 

%% PROCESS
% 1. Select Condition and create output sgtitles
% 2. get info about units (within a preallocation loop)
%   a. correctly load STIMs 
%   
%   b. number of trials for selected condition for unit
% 3. big-loop
%   a. continuous D
%%
clear
close all
PostSetup('brock')
global SORTDIR PLOTDIR STIMDIR

folders = recursdir(SORTDIR,'spike_clusters.npy');
DirsToLoop = cellfun(@(x) x(1:end-18),folders,'UniformOutput',false); %UniOut must be false because

%establish figures
    close all
    f1 = figure;
    textForTitle = 'Monoc stim 1, eye 1';
    sgtitle(textForTitle)

    f2 = figure;
    textForTitle = 'Monoc stim 1, eye 2';
    sgtitle(textForTitle)

    f3 = figure;
    textForTitle = 'Monoc stim 2, eye 1';
    sgtitle(textForTitle)
    
    f4 = figure;
    textForTitle = 'Monoc stim 2, eye 2';
    sgtitle(textForTitle)



count = 0;
% % for i = 1:size(DirsToLoop,2) % looping through recording sessions
    % get info of units on recordings sessions
    i = 1; % Only works for first seesion rn
    sortConfigDir = DirsToLoop{i};
    load([STIMDIR sortConfigDir(end-8:end-1) '_eD.mat']);
    STIM.units = [];
    STIM.phy = [];
    cd(DirsToLoop{i})
    disp(strcat('importPhy run on...',sortConfigDir))
    [STIM] = importPhy(STIM,sortConfigDir);
    holder = [STIM.units.depth]';
    unitsDepth = holder(:,2)';
    
    disp('running diNeuralDat_UsePhy')
    [AllUnits.RESP, win_ms, AllUnits.SDF, sdftm, PSTH, psthtm, AllUnits.SUA] = diNeuralDat_usePhy(STIM,'kls',true,[50 100; 150 250; 50 250; -50 0]); %(STIM,datatype,flag_1kHz,win_ms)
    disp('DONE!')
    
    
    for j = 1:length(unitsDepth) % 1 at depth -3, 2 at depth 9. looping through units of interest
        ContinuousDat.SDF = squeeze(AllUnits.SDF(j,:,:));
        ContinuousDat.SUA = squeeze(AllUnits.SUA(j,:,:));
        

        %compare monoc presentations
            [SDF_fulltm,SUA_fulltm,condition,CondTrialNum] =...
                continuousDatMonocCompare(STIM,ContinuousDat);
        
        %Crop down to time window of interest
            sdfwin  = [-0.05  .4];
            [SDF.condNum1,TM] = cropDATA(SDF_fulltm.condNum1,sdftm,sdfwin); 
                warning('a lot of trials do not have reponses here....?')
            [SUA.condNum1,TM] = cropDATA(SUA_fulltm.condNum1,sdftm,sdfwin); 
                warning('SPY is basically a raster plot! Nz = 33... Also looks sparse:( some trials with no responses -- unit lost? ')
            %output here should be (19[monoc trials]x450[ms])
            
            
       %Crop down to time window of interest
            sdfwin  = [-0.05  .4];
            [SDF.condNum2,TM] = cropDATA(SDF_fulltm.condNum2,sdftm,sdfwin); 
                warning('a lot of trials do not have reponses here....?')
            [SUA.condNum2,TM] = cropDATA(SUA_fulltm.condNum2,sdftm,sdfwin); 
                warning('SPY is basically a raster plot! Nz = 33... Also looks sparse:( some trials with no responses -- unit lost? ')
            %output here should be (19[monoc trials]x450[ms])
        % PLOT (raster/SDF)

        if j == 1
            figure(f1) %unit #1. depth -3
        elseif j == 2
            figure(f2)   % unit #2  . depth 9     
        end
        %create subplot indexes
        numOfConfigs = size(unitsDepth,2);
        numOfSubPlots = numOfConfigs*4;
        subIndex = reshape(1:numOfSubPlots, [numOfConfigs,2]);

        %SDF plot
            subplot(2,size(unitsDepth,2),subIndex(i,1))
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
        subplot(2,size(unitsDepth,2),subIndex(i,2))
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
 

% % end
cd(PLOTDIR)
figure(f1)
export_fig('depth-3','-pdf','-nocrop')
figure(f2)
export_fig('depth9','-pdf','-nocrop')


