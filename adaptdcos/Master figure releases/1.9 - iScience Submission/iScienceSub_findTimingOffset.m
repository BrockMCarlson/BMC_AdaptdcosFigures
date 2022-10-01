% FullTimeClassicBRFS - update to use Gramm
clear
close all
PostSetup('BrockWork')
flag_SaveFigs = false;


global IDXDIR
cd(IDXDIR)

%% Raw
load('IDX_findTimingOffsets_rawResp.mat')   
gramm_dCOS_line(IDX);

%% % change
load('IDX_findTimingOffsets_%changeFromBl.mat')  
gramm_dCOS_line(IDX);

%% Control (i.e. z-scored)
load('IDX_findTimingOffsets_control.mat')  
gramm_dCOS_line(IDX);

%% Within the control (z-score normalized data), which session is the problem?
%% Control (i.e. z-scored)
load('IDX_findTimingOffsets_control.mat')  
findOutlierInZscoreResp(IDX);
