% LLC v2.
% December 2021.
% Brock Carlson. 
% 2nd year - Vanderbilt University Psychology Graduate Program

% Master code, from start to finish, of the processing for the Maier/Bastos
% laminar labeling collaboration. This code takes in .ns2 data recorded on
% BlackRock and triggers the LFP to stimulus onsets. Then, we process CSD
% and CSD from the LFP to assign cortical depths from each type of data.
% Finally, we get the average CSD and PSD profile for each penetration,
% aligned to the granular input layer, and compare coherence across
% sessions.

%% Pre-processing
% This section must perform the following tasks:

%   1. Process the .NEV file to find relevant stimulus onsets.
%       Relevant stimuli are any stimuli on the screen for at least 500ms. 
%       The macaque subject must have fixated through the whole trial.
%   2. Align the .ns2 (1kHz) LFP data to stimulus onsets
%       We then subsequently align to the photo diode onset

%% CSD processing
%   1. Identify Layer 4c CSD sink bottom.
%   2. Align all penetrations along depth via CSD sink bottom.


%% PSD processing
%   1. Identify gamma x beta cross
%   2. Align all penetrations along depth via PSD's gamma x beta cross

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Pre-processing - utilizing the ephys analysis framework.
% This section must perform the following tasks:

%   1. Process the .NEV file to find relevant stimulus onsets.
%       Relevant stimuli are any stimuli on the screen for at least 500ms. 
%       The macaque subject must have fixated through the whole trial.
%   2. Align the .ns2 (1kHz) LFP data to stimulus onsets
%       We then subsequently align to the photo diode onset

clear
close all
PostSetup('BrockHome_LLC')

% Recreate analysis done in runTuneList so we can 









