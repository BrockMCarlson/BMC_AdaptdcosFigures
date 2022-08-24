% FullTimeClassicBRFS - update to use Gramm
clear
close all
PostSetup('BrockHome')
flag_SaveFigs = true;


%% Get IDX
global IDXDIR
cd(IDXDIR)
if ~exist(strcat(IDXDIR,'\IDX_iScienceSubmission.mat'),'file')
    IDX_iScienceSubmission
end
    load(strcat(IDXDIR,'\IDX_iScienceSubmission.mat'))
    
%% Main loop
for i = 1:size(IDX.allV1,2)
    UNIT.allV1 = IDX.allV1(1,i);

    % gramm_dCOS -- built from dCOS fig and violinPlots
    gramm_dCOS_line(UNIT);
    gramm_dCOS_RESP(UNIT);

    % Gramm adaptation control
    gramm_adaptation_line(UNIT)
    gramm_adaptation_RESP(UNIT)

    % gramm_2x2 -- built from visIDX_2x2Fig and violin plots
    gramm_2x2_line(UNIT)
    gramm_2x2_subline(UNIT)
    gramm_2x2_RESP(UNIT)

    % gramm_adaptationEffect -- across all levels of drive
    gramm_adaptationEffect(UNIT)

pause 
end

