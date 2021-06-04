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

% Supragranular
    % Loop through trials of interest for C, mscohere chan 0 vs chan 1
    % Get out coherence value for each trial
    chan0 = find(STIM.depths(:,2) == 5);
    chan1 = find(STIM.depths(:,2) == 6);
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

    close all
    figure
    hold on
    plot(F,cxy_Cong_Avg)
    plot(F,cxy_Incong_Avg)
    legend('Congruent','Incongruent')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude-Squared Coherence')
    title('Supragranular coherence')


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


