% laminarLabelingFormat
clear
close all
PostSetup('BrockWork')

%% Create STIM variables with all channels (do not limit to cortex)
% --> (next pass)


%% For each session - format the LFP (ch x time x trls)
% This needs to be trial-wise bl corrected
% Do NOT trial avg.
% Keep all stimulus presentations (no condition selection at all)
% Make sure stimulus was on screen for 500ms. 

global IDXDIR
cd(IDXDIR)
if ~exist(strcat(IDXDIR,'\laminarLabeling_LFP.mat'),'file')
    laminarLabeling_LFP
end
    load(strcat(IDXDIR,'\laminarLabeling_LFP.mat')) %317s (aka 5 min)


% Save the individual LFP session-wise matrices
for i = 1:size(IDX.allV1,2)
    sessions{i} = IDX.allV1(i).penetration; 
end
individualSes = unique(sessions)';
clearvars -except IDX


% 30 sessions. 25 from E, 5 from I
lfpDir = 'E:\5 diIDX dir\laminarLabelingLFPs\';
cd(lfpDir)
refLLL = false;
if refLLL
    reformatLamLabLFP(IDX) %138sec (aka 3.3min)
else
    disp('you have LFP properly formatted - no need to run')
end

clear IDX


%% Calculate CSD from the LFP on a session level
% 1. replicate top and bottom lfp channels
% 1.5 Calculate CSD.
% 2. Z-score normalize each CSD channel across trials
% 3. Average across trials. Output is (ch x time)
% 4. Format depth in terms of grand alignment depth (100um).
% 5. Save each session's CSD.

anaType = '_4LLC.mat';
for i = 1:length(list)
    
end

%% Pull out all sessions of CSD data and concatenate along 1st dimension.
% output is (session x ch x time)

%% Calculate PSD from the LFP on a session level
% 1. calculate PSD across trials. Output is (ch x freq)
% 2. identify gamma x beta cross
% 3. format depth in terms of the grand alignment depth (100um).
% save each session's PSD

%% Pull out all sessions of PSD data and concatenate along 1st dimension.
% output is (session x ch x freq)

%% Create a bookkeeping structure that mimics Andre's format.

%% Output
global OUTDIR
cd(OUTDIR)


