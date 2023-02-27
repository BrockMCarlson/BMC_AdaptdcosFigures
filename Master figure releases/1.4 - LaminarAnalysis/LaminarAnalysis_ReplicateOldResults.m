% 1.4.5 Laminar Analysis - ReplicateOldResults
clear
close all
PostSetup('BrockHome')
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

contactToTest = 5;


%% Plot average LFP
MainTilt_SDF_crop = MainTilt_SDF(:,1:551,:);
MainTilt_SDF_Avg = squeeze(nanmean(MainTilt_SDF_crop(contactToTest,:,:),3));


%% Bl correct LFP
% RESP bl period is (4,:)
baseline = mean(RESP(contactToTest,4,MainTiltTrls),3);
blSubSDF = squeeze(MainTilt_SDF_crop(contactToTest,:,:)) - baseline;



%% 3. Bl correct in the frequency domain
    % Do chronux toolbox on short time window, average in freq domain,
    % repmat to a large time vector (plot a banded image), and subtract the
    % two images

movingwin = [0.04 0.004];
params.Fs = 1000;
params.tapers = [0.5 2];
params.fpass = [0 120];
params.pad = 2;
params.trialave = 1;
params.err = 0;

%bl chronux
    % %  "data" input is formatted as time x trial
    % data = squeeze(MainTilt_SDF_crop(contactToTest ,:,:)); % data is now time x trials
    % data = blSubSDF; % data is now time x trials
    stopIdx = find(sdftm == 0);
    data_bl = squeeze(MainTilt_SDF(contactToTest,1:stopIdx,:)); % data is now time x trials
    [S_bl,f] = mtspectrumc(data_bl,params); %% FFT
    [S_bl,t,f] = mtspecgramc(data_bl,movingwin,params); %% spectogram
    
    % full bl timeperiod
    figure
    plot_matrix(S_bl,t,f)
    
    %Average bl time period
    % S is time bins x freq
    % S_BlRep need to be 128x31
    S_blAvg = mean(S_bl,1);
    S_BlRep = repmat(S_blAvg,128,1);
    figure
    plot_matrix(S_BlRep,t,f)
    
%full Data chronux
    % %  "data" input is formatted as time x trial
    % data = squeeze(MainTilt_SDF_crop(contactToTest ,:,:)); % data is now time x trials
    % data = blSubSDF; % data is now time x trials
    data = squeeze(MainTilt_SDF(contactToTest,1:551,:)); % data is now time x trials
    [S,f] = mtspectrumc(data,params); %% FFT
    [S,t,f] = mtspecgramc(data,movingwin,params); %% spectogram
    
    %s is time bins x freq
    % time bins is 128
    figure
    plot_matrix(S(1:64,:),t(1,1:64),f)
    
% Subtraction plot
    S_Subbed = S - S_BlRep;
    S_Subbed(S_Subbed < 0) = 0;
    figure
    plot_matrix(S_Subbed,t,f)
    
    
    
% FIX -- 
    specStopIdx = (t<.151);
    blData = S(specStopIdx,:);
    S_blAvg = mean(blData,1);
    S_BlRep = repmat(S_blAvg,128,1);
    figure
    plot_matrix(S_BlRep,t,f)
    
    S_Subbed = S - S_BlRep;
    S_Subbed(S_Subbed < 0) = 0;
    figure
    plot_matrix(S_Subbed,t,f)
    
    
    
    size(S) 
    S_Bl = mean(S([1:50],:),1);
    S_BlRep = repmat(S_Bl,128,1);
    S_Subbed = S - S_BlRep;
    S_Subbed(S_Subbed < 0) = 0;
    figure
    plot_matrix(S_Subbed,t,f)
    

%%
%%
%% Spectrogram
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

    
%% Get out data to test
MainTiltTrls = ((~STIM.blank) &(STIM.tilt(:,1) == 90) & (STIM.tilt(:,2) == 90));
stopTmIDX = find(sdftm == .300);
depthToTest = 0;
contactToTest = find(STIM.depths(:,2) == depthToTest);
PlotLabel = {'Spectrogram',strcat('Depth = ',string(depthToTest))};
SDF_use = squeeze(SDF(contactToTest,1:stopTmIDX,MainTiltTrls));
sdftm_use = sdftm(1,1:stopTmIDX);

figure
plot(sdftm_use,SDF_use(:,25:50))

window = 128;
noverlap = 120;
fs = 1000;

for i = 1:size(SDF_use,2)
    clear x
    x = SDF_use(:,i);
    [s(:,:,i),f,t,ps(:,:,i)] = spectrogram(x,window,noverlap,[],fs);
    
end

tInSamples = t*1000;
newTimeVector = sdftm_use(tInSamples);

sAbs = abs(s);
s_avg = mean(sAbs,3)'; %s_avg is time x freq
plot_matrix(log(s_avg),newTimeVector,f) % expects time x freq 
ylim([0 200])

% bl correct in freq domain across bl time period
blTimeIDX = newTimeVector < 0;
s_baseline = mean(s_avg(blTimeIDX,:),1); 
s_2dBl = repmat(s_baseline,41,1); % output should be 41x129
figure
plot_matrix(s_2dBl,newTimeVector,f) % expects time x freq 

% Subtract across the freq domain
s_blSubbed = s_avg - s_2dBl;
s_blSubbed(s_blSubbed < 0) = 0;
figure
plot_matrix(s_blSubbed,newTimeVector,f) % expects time x freq 
vline(0)
ylim([0 200])
ylabel('freq (Hz)')
xlabel('time (sec)')
title(PlotLabel)

%% Example trial
figure
trlsToTest = [1:50];
plot(sdftm_use,SDF_use)
vline(0)

figure
spectrogram(SDF_use(:,52),window,noverlap,[],fs,'yaxis')
