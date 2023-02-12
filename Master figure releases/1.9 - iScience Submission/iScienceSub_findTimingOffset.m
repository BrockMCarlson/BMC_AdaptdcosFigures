% iScienceSub_findTimingOffset.m
% Written by BMC - 10/1/2022

% This code needs to help us decide which parameters to use for the BRFS
% iScience submission. These include contrast levels, time period of
% stastical comparison, and format of normalization. 

% We will plot monoc vs dCOS in 9 plots (3x3 facit gid)
% X dim - scale with normlilzation method. 

%%
clear
close all
PostSetup('BrockWork')
flag_SaveFigs = false;


global IDXDIR
cd(IDXDIR)

%% Get desired variables out of STIM files
IDX = IDX_iScienceSubmission_findTimingOffsets;






%% Other analysis ideas...
% I would also like to evaluate for outliers. Part of this process may
% simply involve replotitng descriptive stats for each session as well as
% each unit. These can all be supplemental figures!

% There are two main desired oututs - a latency analysis figure, and
% supplemental methods figs for each session/unit. (I don't want to clean
% these in illustrator, so I have to make "cleaner" plotting scripts.

% We could compare mean vs median (median could be taken in gramm).

% Right now this code is SUPER SLOW. The problem is twofold:
    % 1. I load in different IDX variables
    % 2. I plot every varaible with the same plotting funciton. 
    % This is *terrible* organization. I should load in 1 piece of data and
    % then have several differnt ploting function. Right now, the plots
    % have incorect axises, range values, titles, etc. 

% what descriptive values should i look at for each unit?
    % 1. receptive field map
    % 2. waveform
    % 3. SDF shape/size compared to population (outlier analysis). Compare
    %       across median vs mean and normalization methods.

% what descriptives do we want for each session? (everything in methods).
    % LFP, CSD, PSD, MUA, rfAlignment with lines indicating MAC's laminar
    % boundaries.
    % Average response rate (for session) in impulses/sec and normalized
    % values with respect to the mean/median
    % Eye and orientation tuning across the electrode. (results may vary
    % based on normalization method...
