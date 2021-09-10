% FullTimeClassicBRFS - update to use Gramm
clear
close all
PostSetup('BrockWork')
flag_SaveFigs = false;


%% Get IDX
global IDXDIR
cd(IDXDIR)
if ~exist(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'),'file')
    IDXforGrammJuly2021
end
    load(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'))
    
%% Goal - 
% 1. Take the new IDXforGrammJuly2021 (based on SingleSessionIDX) 
% code and use it to create IDX variables
% for all of the sessions where you have trial average and also individual
% trial data

% 2. Plot all previous figures but update the bar plots and line plots to the
% gramm plotting structure. This will require new visualization fuctions
% for each and perhaps restrucuting of the IDX variable? 

% 3. Make a new plot for Alex using the Gramm scatter stacker where we show
% the violin plots of the response wins (trans and sustained) that
% describes all of the different conditions of varying levels of "drive".

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
gramm_driveAndGain(IDX)
gramm_adaptationEffect(IDX)


global OUTDIR
cd(OUTDIR)


