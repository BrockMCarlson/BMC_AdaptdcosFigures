% 1.4.5 Laminar Analysis - ReplicateOldResults
clear
close all
PostSetup('brockWork')
flag_SaveFigs = false;

%% Goal --
% Plot spectrograms, LFP averages, and chronux outpts that match old lab
% results...

%%
% Get our example STMM_LFP
global STIMDIR
cd(STIMDIR)
load('151221_E_eD_LFP')

%% 
    

% Find trials
test = ((STIM.tilt(:,1)) == (STIM.tilt(:,2)));
EqualTilts = STIM.tilt(test,:);

MainTiltTrls = ((STIM.tilt(:,1) == 90) & (STIM.tilt(:,2) == 90));
MainTilt = STIM.tilt(MainTiltTrls,:);
MainTilt_SDF = SDF(:,:,MainTiltTrls);

%% Plot average LFP
MainTilt_SDF_crop = MainTilt_SDF(:,1:551,:);
contactToTest = 5;
MainTilt_SDF_Avg = squeeze(nanmean(MainTilt_SDF_crop(contactToTest,:,:),3));


%% Bl correct LFP
% RESP bl period is (4,:)
baseline = mean(RESP(contactToTest,4,MainTiltTrls),3);
blSubSDF = squeeze(MainTilt_SDF_crop(contactToTest,:,:)) - baseline;

%% Alternate method to BL correcting --
% 1. dhow why this may be necessary
    % 1a. plot all of the LFPS for all of the trials
    close all
    figure
    plot(squeeze(MainTilt_SDF_crop(contactToTest,:,:)))
    title('all LFPs')
    
    % 1b. plot all of the LFPs for the trials with bl subtraction
    figure
    plot(blSubSDF)
    title('blSub LFPs')
    
    % 1c. plot the LFP average and the blSubLFP average on the same fig
    blSubSDFAvg = squeeze(mean(blSubSDF,2))';
    figure; hold on;
    plot(MainTilt_SDF_Avg)
    plot(blSubSDFAvg)
    legend('LFP Avg','bl sub LFP avg')
    title('SDF line average differences -- LFP is negative...')

% 2. new Bl correct method - find each trials bl period difference from
% zero, subtract or add that vlaue to every elements to every line starts
% at 0uV....
    % 2a. get a vector with the baseline value for each trial
    lfpBl_vec = squeeze(RESP(contactToTest,4,MainTiltTrls))';
    
    % 2b. subtract bl *trial-wise*
    lfpBl_SDF1 = squeeze(MainTilt_SDF_crop(contactToTest,:,:));
    lfpBl_SDF2 = lfpBl_SDF1 - lfpBl_vec;
    
    figure
    plot(lfpBl_SDF2)
    vline(150)
    title('LFP - trial wise bl corrected - stim onset at 150ms')


%% Throw this into chronux
movingwin = [0.04 0.004];
params.Fs = 1000;
params.tapers = [0.5 2];
params.fpass = [0 120];
params.pad = 2;
params.trialave = 1;
params.err = 0;

% %  "data" input is formatted as time x trial
% data = squeeze(MainTilt_SDF_crop(contactToTest ,:,:)); % data is now time x trials
% data = blSubSDF; % data is now time x trials
data = lfpBl_SDF2; % data is now time x trials
[S,f] = mtspectrumc(data,params); %% FFT
[S,t,f] = mtspecgramc(data,movingwin,params); %% spectogram

figure
plot_matrix(S,t,f)




