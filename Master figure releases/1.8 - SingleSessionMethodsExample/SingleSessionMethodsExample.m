% SingleSessionMethodsExample
clear
close all
PostSetup('BrockWork')
flag_SaveFigs = false;


%% Get IDX
global IDXDIR
cd(IDXDIR)
% % % if ~exist(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'),'file')
% % %     IDXforGrammJuly2021
% % % end
    load(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'))
    
%% Goal - 
% 1. Take data in with IDXforGrammJuly2021 (stored on TEBA as of July 1st,
% 2022). With this formatted dataset I will find an example session to use
% for the methods figure plots. The proposed figures include the following:
    % - LFP
    % - CSD
    % - laminar MUA plotting
    % - analyRfOriTuningSPK plot outputs - but modified to average across
    %   the whole electrode
    % - example indivieual contact with 2x2 plot that goes with probe
    %   average
    %   example individual contact with 2x2 plot that goes AGAINST probe
    %   average
    % - all rf location plots for every unit -- (how did blake do this?)


close all

%% gramm_dCOS -- built from dCOS fig and violinPlots
gramm_dCOS_line(IDX);
gramm_dCOS_RESP(IDX);

%% gramm_2x2 -- built from visIDX_2x2Fig and violin plots
gramm_2x2_line(IDX)
gramm_2x2_subline(IDX)
gramm_2x2_RESP(IDX)



%% gramm_2x2 laminar.
gramm_2x2laminar_line(IDX)
gramm_2x2laminar_subline(IDX)


%% gramm_driveAndGain
% gramm_driveAndGain(IDX)
gramm_adaptationEffect(IDX)


global OUTDIR
cd(OUTDIR)


