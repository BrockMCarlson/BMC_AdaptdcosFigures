% FullTimeClassicBRFS - update to use Gramm
clear
close all
PostSetup('BrockWork')
flag_SaveFigs = false;


%% Get IDX
global IDXDIR
cd(IDXDIR)
if ~exist(strcat(IDXDIR,'\IDX_iScienceSubmission.mat'),'file')
    IDX_iScienceSubmission
end
    load(strcat(IDXDIR,'\IDX_iScienceSubmission.mat'))
    
%% gramm_dCOS -- built from dCOS fig and violinPlots
gramm_dCOS_line(IDX);
gramm_dCOS_RESP(IDX);

%% gramm_2x2 -- built from visIDX_2x2Fig and violin plots
gramm_2x2_line(IDX)
gramm_2x2_subline(IDX)
gramm_2x2_RESP(IDX)


%% gramm_2x2 laminar.
% % % gramm_2x2laminar_line(IDX)
% % % gramm_2x2laminar_subline(IDX)


%% gramm_driveAndGain
% gramm_driveAndGain(IDX)
gramm_adaptationEffect(IDX)


global OUTDIR
cd(OUTDIR)


