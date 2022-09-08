% FullTimeClassicBRFS - update to use Gramm
clear
close all
PostSetup('BrockHome')
flag_SaveFigs = true;
anaName = 'IDX_iScienceSubmission_unbalancedContrast';


%% Get IDX
global IDXDIR
cd(IDXDIR)
if ~exist(strcat(IDXDIR,strcat(filesep,anaName,'.mat')),'file')
    IDX_iScienceSubmission
end
    load(strcat(IDXDIR,strcat(filesep,anaName,'.mat')))
    
%% IDX breakdown
numUnits = idxBreakdown(IDX,ERR);

%% gramm_dCOS -- built from dCOS fig and violinPlots
gramm_dCOS_line(IDX);
gramm_dCOS_RESP(IDX);

%% Gramm adaptation control
gramm_adaptation_line(IDX)
gramm_adaptation_RESP(IDX)

hold off
%% gramm_2x2 -- built from visIDX_2x2Fig and violin plots
gramm_2x2_line(IDX)
gramm_2x2_subline(IDX)
gramm_2x2_RESP(IDX)


%% gramm_2x2 laminar.
% gramm_2x2laminar_line(IDX)
% gramm_2x2laminar_subline(IDX)


%% gramm_adaptationEffect -- across all levels of drive
% gramm_driveAndGain(IDX)
gramm_adaptationEffect(IDX)


%% Save all the figs
global OUTDIR
folderName = strcat(OUTDIR,filesep,anaName);
cd(folderName)

if flag_SaveFigs
    figNameList = flip({'IS_Line', 'IS_dioptic_RESP','IS_dichoptic_RESP', ...
        'adaptation_line', 'adaptation_RESP',...
        '2x2_line', '2x2_subline', '2x2_RESP',...
        'adaptationEffect'});
    saveAllTheFigs(figNameList,folderName)
end

