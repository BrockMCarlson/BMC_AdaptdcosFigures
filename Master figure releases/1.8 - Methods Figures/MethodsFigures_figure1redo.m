% Methods Figure - Figure 1 redo
% Goal: Single Session Example Plots
    % 1. LFP --> CSD --> PSD --> MUA for example depth
    % 2. 1x2 (2 eyes) ori tuning curves for eye and ori pref of contact
    % average - this shows what was selected on the day
    % 3. 2x2 plots with a different line color for each contact along the
    % probe - shows variance across the electode depth. And how we set
    % PS+DE in post.
    
% Goal: Population average descriptive plots
    % 1. Rf location for each unit
    % 2. Electrode graphic of each probe's depth

    

%% Setup
clear
close all
PostSetup('BrockHome');
flag_SaveFigs = false;


%% Get IDX
global IDXDIR; cd(IDXDIR)
% % if ~exist(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'),'file')
% %     IDXforbmcBRFS2021
% % end
    load(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'))



%% A1. LFP --> CSD --> PSD --> MUA for example depth
% preProcessNeuralData_IOT

sessionListName = '151221_E';
global RIGDIR ; cd(RIGDIR)
cd(sessionListName)
% Create file name
EVPName = strcat(...
    RIGDIR,...
    sessionListName,filesep,...
    sessionListName,...
    '_evp00','1');
BRFSName = strcat(...
    RIGDIR,...
    sessionListName,filesep,...
    sessionListName,...
    '_brfs00','1');

% establish useChans and interpChans
useChans = 1:24;
interpTheseChans = [];
plotCSDandPSDfromNEV(EVPName,useChans,interpTheseChans);
plotCSDandPSDfromNEV(BRFSName,useChans,interpTheseChans);




%% A2. 1x2 ori tuning curves for avg of all contacts on a single session
    % 2. 1x2 (2 eyes) ori tuning curves for eye and ori pref of contact
    % average - this shows what was selected on the day
    % Can I plot the gaussians that are used? These would be in
    % dIUnitTuning!
%%% diUnitTuning plot


%% A3. 2x2 for full electrode
    % 3. 2x2 plots with a different line color for each contact along the
    % probe - shows variance across the electode depth. And how we set
    % PS+DE in post.
% % gramm_2x2_line(IDX)
% % gramm_2x2_subline(IDX)
% % gramm_2x2_RESP(IDX)


%% B1



%% B2 


%% Save plots / variables
global OUTDIR
cd(OUTDIR)


