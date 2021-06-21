% 1.4.6  Laminar Analysis - Spectrograms
%% Goal --
% 1. Simultaneous - congruent vs incongruent. 
%   1a. Individual plots averaged across the whole electrode for C and IC
%   1b. Subtraction plot of C-IC plotted in greyscale. Whole el average.

% 2. Adapted - C vs IC.
%   2a. Individual plots averaged across the whole electrode for C and IC
%   2b. Subtraction plot of C-IC plotted in greyscale. Whole el average. 

% 3. Replicate on second session
%   3a. Run reliability analysis on 2nd session. Find PS and NS, compare to
%   the results from DiUnitTuning run on the MUA.
%   3b. replicate point #1 (Simult C vs IC plots and subtraction plot) on
%   this new session
%   3c. replicate point #2 (adapted C vs IC) for this session

% 4. Create a system to loop through every single electrode and average all
% sessions together
%   4a. Run reliability analysis on all sessions. Compare results to
%   diUnitTuning, and put all "final" answers into a spreadsheet for
%   posterity.
%   4b. Compute all-session averages.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Goal # 1. Simultaneous c vs IC
%   1a. Individual plots averaged across the whole electrode for C and IC
%   1b. Subtraction plot of C-IC plotted in greyscale. Whole el average.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1a. C vs IC averaged across the whole electrode
clear
close all
PostSetup('BrockHome')
flag_SaveFigs = false;

%% load session data
penetration = '151221_E_eD_LFP.mat';
sdfwin  = [-0.150  .5];
% Assign preverences
    X.DE  = 2;
    X.NDE = 3;
    X.PS  = 0;
    X.NS  = 90;
IDX = singleSessionIDX(penetration,sdfwin,X);


CondIdx.C   = [NaN 6]; % 6 = congruent NS (this is what was shown on 151221)
CondIdx.IC  = [7 8]; %It also has trials for 7 and 8, both IC configs





