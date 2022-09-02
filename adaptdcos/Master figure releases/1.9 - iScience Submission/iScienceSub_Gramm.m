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
    
%% IDX breakdown
numUnits = idxBreakdown(IDX,ERR);
    
%% gramm_dCOS -- built from dCOS fig and violinPlots
gramm_dCOS_line(IDX);
gramm_dCOS_RESP(IDX);

%% Gramm adaptation control
gramm_adaptation_line(IDX)
gramm_adaptation_RESP(IDX)

%% gramm_2x2 -- built from visIDX_2x2Fig and violin plots
gramm_2x2_line(IDX)
gramm_2x2_subline(IDX)
gramm_2x2_RESP(IDX)


%% gramm_2x2 laminar.
% % % gramm_2x2laminar_line(IDX)
% % % gramm_2x2laminar_subline(IDX)


%% gramm_adaptationEffect -- across all levels of drive
% gramm_driveAndGain(IDX)
gramm_adaptationEffect(IDX)


%% Save all the figs
global OUTDIR
cd(OUTDIR)
if flag_SaveFigs
    figNameList = flip({'dCOS_line', 'dCOS_RESP', 'adaptation_line', 'adaptation_RESP', '2x2_line', '2x2_subline', '2x2_RESP', 'adaptationEffect'});
    saveAllTheFigs(figNameList,OUTDIR)
end

