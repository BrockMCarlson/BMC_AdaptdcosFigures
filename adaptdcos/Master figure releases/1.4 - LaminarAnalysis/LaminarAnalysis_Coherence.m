% 1.4.4 Laminar Analysis - Coherence
clear
close all
PostSetup('brockWork')
flag_SaveFigs = false;

%% Goal --
% Compare to coherence between two electrode contacts during C and IC
% stimulation
% Version 1 -- mscohere
%   fig A - coherence vs time at given frequencies for C  stim
%   fig B - coherence vs time at given frequencies for IC stim
% Version 2 -- wcoherence
%   fig A - coherence vs time at given frequencies for C  stim
%   fig B - coherence vs time at given frequencies for IC stim


%%
% Get our example STMM_LFP
global STIMDIR
cd(STIMDIR)
load('151221_E_eD_LFP')

%% MSCOHERE
% I can append 'mimo' later to do a matrix evaluation - this may speed up
% the computation if needed, but to make sure I am comparing the correct
% thing I will start vector vs vector computation.
    % x - Chan 0 raw LFP for whole time of trial 1234
    % y - Chan 1 raw LFP for whole time of trial 1234
    

% Find trials
 [congruentTrls, incongruentTrls] = findTrialsForCoherence(STIM);

% get SDF out for trils of interest
SDF_CongTrials = SDF(:,:,congruentTrls);
SDF_IncongTrials = SDF(:,:,incongruentTrls);


% Crop SDF to time window of interest
 [SDF_CongCropped,croppedSdftmforSimult] = cropSDF_getSimultBRFS(SDF_CongTrials,STIM,sdftm);
 [SDF_IncongCropped,croppedSdftmforSimult] = cropSDF_getSimultBRFS(SDF_IncongTrials,STIM,sdftm);

%% Mscohere in laminar compartments
x = 7;
nfft = 2^x; % must be 2^x
window = nfft*2; %window = nfft also would work if too slow
noverlap = window-1; %noverlap = window/2 could also work if too slow
clear cxy_Cong cxy_Incong


% Supragranular
    % Loop through trials of interest for C, mscohere chan 0 vs chan 1
    % Get out coherence value for each trial
    chan0 = find(STIM.depths(:,2) == 0);
    chan1 = find(STIM.depths(:,2) == 6);
    SDF_CongCropped_chan0 = squeeze(SDF_CongCropped(chan0,:,:));
    SDF_CongCropped_chan1 = squeeze(SDF_CongCropped(chan1,:,:));
    SDF_IncongCropped_chan0 = squeeze(SDF_IncongCropped(chan0,:,:));
    SDF_IncongCropped_chan1 = squeeze(SDF_IncongCropped(chan1,:,:));

% tic
    for i = 1:size(SDF_CongCropped_chan0,2)
        clear holder0 holder1
        holder0 = squeeze(SDF_CongCropped_chan0(:,i));
        holder1 = squeeze(SDF_CongCropped_chan1(:,i));

%          [cxy_Cong(:,i),F] = mscohere(holder0,holder1,window,noverlap,nfft,1000); 
        [wcoh(:,:,i),~,f,coi] = wcoherence(holder0,holder1,1000);

    end
    
    wcohAvg = mean(wcoh,3);
    TrialTested = randi(100)
    wcohTest = wcoh(:,:,TrialTested);
    helperPlotCoherence(wcohAvg,croppedSdftmforSimult,f,coi,'Seconds','Hz');
    vline(0)
    
    % Question 1 - why does it go to 256 Hz? The F vector that I put in has
    % 97 samples ranging from 1.8 Hz to 477 Hz
    
    % Question 2 - why don't I see a transient either in the individual trial
    % signals (always anyway..) or in the average overall signal?
    
    % Question 3 - why is the average overall signal a large smear? Even
    % the individual trials looks more smeared than the NIRS data.
    
    % trial 35 and 36 miiight have a transient around 40-64 Hz (low gamma)
    % this could be teased out and kinda looks right in the average data.
    % But why don't we see this in every session? Why does the coherence
    % look so broad at the low frequencies? AHHHHHH - because its no local.
    % Maybe I should look at coherence between laminar compartments?
    
    % Ok - so I was looking at the supragranular layers. The granular input
    % might have a more distinc transient on an individual trial basis, but
    % its still hard to see. 
    
    % Things do indeed become more discrete between the layers.
    
    
    
    % Loop through trials of interest for IC, mscohere chan 0 vs chan 1
    % Get out coherence values for each trial
    for i = 1:size(SDF_IncongCropped_chan0,2)
        clear holder0 holder1
        holder0 = squeeze(SDF_IncongCropped_chan0(:,i));
        holder1 = squeeze(SDF_IncongCropped_chan1(:,i));

        [cxy_Incong(:,i)] = mscohere(holder0,holder1,window,noverlap,nfft,1000); 

    end
    toc

    % Trial - average coherence for C and IC

    cxy_Cong_Avg = mean(cxy_Cong,2);
    cxy_Incong_Avg = mean(cxy_Incong,2);

%     close all
    figure
    hold on
    plot(F,cxy_Cong_Avg)
    plot(F,cxy_Incong_Avg)
    legend('Congruent','Incongruent')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude-Squared Coherence')
    title('Supragranular coherence')

    error('new mscohere parameters not established past this point.')

% Granular
    % Loop through trials of interest for C, mscohere chan 0 vs chan 1
    % Get out coherence value for each trial
    chan0 = find(STIM.depths(:,2) == 0);
    chan1 = find(STIM.depths(:,2) == 1);
    SDF_CongCropped_chan0 = squeeze(SDF_CongCropped(chan0,:,:));
    SDF_CongCropped_chan1 = squeeze(SDF_CongCropped(chan1,:,:));
    SDF_IncongCropped_chan0 = squeeze(SDF_IncongCropped(chan0,:,:));
    SDF_IncongCropped_chan1 = squeeze(SDF_IncongCropped(chan1,:,:));


    for i = 1:size(SDF_CongCropped_chan0,2)
        clear holder0 holder1
        holder0 = squeeze(SDF_CongCropped_chan0(:,i));
        holder1 = squeeze(SDF_CongCropped_chan1(:,i));

         [cxy_Cong(:,i),F] = mscohere(holder0,holder1,[],[],[],1000); 


    end
    % Loop through trials of interest for IC, mscohere chan 0 vs chan 1
    % Get out coherence values for each trial
    for i = 1:size(SDF_IncongCropped_chan0,2)
        clear holder0 holder1
        holder0 = squeeze(SDF_IncongCropped_chan0(:,i));
        holder1 = squeeze(SDF_IncongCropped_chan1(:,i));

        [cxy_Incong(:,i)] = mscohere(holder0,holder1,[],[],[],1000); 

    end

    % Trial - average coherence for C and IC

    cxy_Cong_Avg = mean(cxy_Cong,2);
    cxy_Incong_Avg = mean(cxy_Incong,2);

    figure
    hold on
    plot(F,cxy_Cong_Avg)
    plot(F,cxy_Incong_Avg)
    legend('Congruent','Incongruent')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude-Squared Coherence')
    title('Granular coherence')    
    
    
% Infragranular
    % Loop through trials of interest for C, mscohere chan 0 vs chan 1
    % Get out coherence value for each trial
    chan0 = find(STIM.depths(:,2) == -3);
    chan1 = find(STIM.depths(:,2) == -2);
    SDF_CongCropped_chan0 = squeeze(SDF_CongCropped(chan0,:,:));
    SDF_CongCropped_chan1 = squeeze(SDF_CongCropped(chan1,:,:));
    SDF_IncongCropped_chan0 = squeeze(SDF_IncongCropped(chan0,:,:));
    SDF_IncongCropped_chan1 = squeeze(SDF_IncongCropped(chan1,:,:));


    for i = 1:size(SDF_CongCropped_chan0,2)
        clear holder0 holder1
        holder0 = squeeze(SDF_CongCropped_chan0(:,i));
        holder1 = squeeze(SDF_CongCropped_chan1(:,i));

         [cxy_Cong(:,i),F] = mscohere(holder0,holder1,[],[],[],1000); 


    end
    % Loop through trials of interest for IC, mscohere chan 0 vs chan 1
    % Get out coherence values for each trial
    for i = 1:size(SDF_IncongCropped_chan0,2)
        clear holder0 holder1
        holder0 = squeeze(SDF_IncongCropped_chan0(:,i));
        holder1 = squeeze(SDF_IncongCropped_chan1(:,i));

        [cxy_Incong(:,i)] = mscohere(holder0,holder1,[],[],[],1000); 

    end

    % Trial - average coherence for C and IC

    cxy_Cong_Avg = mean(cxy_Cong,2);
    cxy_Incong_Avg = mean(cxy_Incong,2);

    figure
    hold on
    plot(F,cxy_Cong_Avg)
    plot(F,cxy_Incong_Avg)
    legend('Congruent','Incongruent')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude-Squared Coherence')
    title('Infragranular coherence')


