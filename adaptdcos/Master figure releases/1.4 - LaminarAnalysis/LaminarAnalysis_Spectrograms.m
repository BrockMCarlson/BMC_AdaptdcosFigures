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


%% Initial settings
    clear
    close all
    PostSetup('BrockHome')
    flag_SaveFigs = false;

% load session data
    penetration = '151221_E_eD_LFP.mat';
    sdfwin  = [-0.150  .5];

% Assign preferences
    X.DE  = 2;
    X.NDE = 3;
    X.PS  = 0;
    X.NS  = 90;
    IDX = singleSessionIDX(penetration,sdfwin,X);

% note: Available conditions fro 151221 are as follows:
% [ 2 3  6 7 8  11 12 13 14  17 18  23 24]
% Null stim (90) always - when congruent. NS adapted when adapted. all
% simuls IC conditions available


%% Goal # 1. Simultaneous c vs IC
%   1a. Individual plots averaged across the whole electrode for C and IC
%   1b. Subtraction plot of C-IC plotted in greyscale. Whole el average.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% 1a. C vs IC averaged across the whole electrode

CondIdx.C   = [NaN 6]; % 6 = congruent NS (this is what was shown on 151221)
CondIdx.IC  = [7 8]; %It also has trials for 7 and 8, both IC configs

clear SpcContactAvg
close all

ConditionToTest = CondIdx.C(2);
[SpcTimeVector,F,SpcContactAvg.C] =...
    plotSpectrogramFullContactAvg(IDX,ConditionToTest);

ConditionToTest = CondIdx.IC(1);
[~,~,SpcContactAvg.IC_highDrive] =...
    plotSpectrogramFullContactAvg(IDX,ConditionToTest);

ConditionToTest = CondIdx.IC(2);
[~,~,SpcContactAvg.IC_lowDrive] =...
    plotSpectrogramFullContactAvg(IDX,ConditionToTest);


%% 1b: Subtract two spectrograms

SpcContactAvg.diff_highDrive =...
    abs(SpcContactAvg.C - SpcContactAvg.IC_highDrive);

SpcContactAvg.diff_lowDrive =...
    abs(SpcContactAvg.C - SpcContactAvg.IC_highDrive);


% plot
figure
imagesc(SpcTimeVector,F,SpcContactAvg.diff_highDrive) %travg_spc is (f x t)
colormap bone
set(gca,'ydir','normal');   
xlabel('Time (sec)')
ylabel('Hz')
vline(0)
title({'C - IC diff','highDriveIC'})


% plot
figure
imagesc(SpcTimeVector,F,SpcContactAvg.diff_highDrive) %travg_spc is (f x t)
colormap bone
set(gca,'ydir','normal');   
xlabel('Time (sec)')
ylabel('Hz')
vline(0)
title({'C - IC diff','lowDriveIC'})


%% Goal # 2. Adapted C vs IC
%   2a. Individual plots averaged across the whole electrode for C and IC
%   2b. Subtraction plot of C-IC plotted in greyscale. Whole el average.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 2a. Individual adapted stimulus onsets - averaged across the whole electrode

clear SpcContactAvg
close all

CondVec = [11 12 13 14 17 18 23 24];


for i = 1:length(CondVec)

    [~,~,SpcContactAvg(i,:,:)] =...
        plotSpectrogramFullContactAvg(IDX,CondVec(i));

end

%% 2b.
Edit plotSpectorgramFullcontactAvg (maybe save a new file) so that you have
% Both types of conditions in the file. Just concatenate the conditions
% together on line 18. Don't worry about balancing the conditions quite
% yet. Do that when everything is more finalized. 