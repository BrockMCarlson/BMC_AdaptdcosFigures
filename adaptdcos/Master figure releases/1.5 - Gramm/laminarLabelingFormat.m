% laminarLabelingFormat
clear
close all
PostSetup('BrockWork')

%% Create STIM variables with all channels (do not limit to cortex)
% --> (next pass)
error('rewrite -- this into the simplest path possible')
qetl;nie;ligln24lkn#! 

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
lfpDir = 'E:\5 diIDX dir\laminarLabelingLFPs\';
didir = strcat(lfpDir);
anaType = '_4LLC.mat';
list    = dir([didir '*' anaType]);
for i = 1:length(list)
    penetration = list(i).name(1:11); 
    clear holderLFP LFP EVP CSD
    holder = load(list(i).name); % LFP loaded in is ch x time x trials
    holderLFP = holder.LFP;
    
    % replicate the top and bottom channel of LFP so the N comes out of
    % calcCSD correctly 
    LFP(1,:,:) = holderLFP(1,:,:);
    idxEnd = size(holderLFP,1)+1;
    LFP(2:idxEnd,:,:) = holderLFP;
    LFP(idxEnd+1,:,:) = holderLFP(end,:,:); %lfp is ch x time x trl
    
    % permute into correct calcCSD input dimensions and calcCSD
    EVP = permute(LFP,[2 1 3]);  %expected calcCSD input is time x ch x trials
    CSD = calcCSD(EVP); %CSD output is ch x time x trials
    
    %Z-score normalize each CSD channels across trials
    % Z = (x-u)./sigma
    % u for each channel at each time point, over trials
    u = mean(CSD,3);
    s = std(CSD,0,3); %0 weigh is recomended. form is std(X,weight,dim)
    CSD_Z = (CSD-u)./s;
    
    %baseline correct
    CSD_bl = mean(CSD_Z(:,51:150,:),2);
    CSD_Z_blsub = CSD_Z - CSD_bl;
    
    % Average
    CSD_Zavg = mean(CSD_Z,3);
    
    
    %format in terms of depths
error('fix z-score')
use 1-24, make sure you use all ofyour CSD channels (no cutting cortex based on V2 lims)
re-write your CSD code so that is follows the schroeder paper


1. Pre step, vakmin approximation - 1-26( by doubling your top and bottom)
2. calculate for i = 1:24, define the index of your CSD matrix, to compute those matricds and get x you use x = i+1 or i+h
3. z score that includes your basleine normalization (mean is taken from the baseoine)
in addition to channel you also have time and tiral.

    
end
CSDf = filterCSD(CSD_Zavg);
TM = [-.15:.001:.499];
corticaldepth = [1:1:30];
imagesc(TM,corticaldepth,CSDf); colormap(flipud(jet));

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


