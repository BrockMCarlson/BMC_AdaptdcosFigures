% 1.4.3 Laminar Analysis - Reliability Analysis
clear
close all
PostSetup('BrockWork')
flag_SaveFigs = false;

%% Goal --
% create publish-quality plots (for supp. figures) of feature tuning across
% the electrode for each penetration to visually show how we chose the
% tuning preferences of the column
% A -- Eye tuning
% B -- Ori tuning

%% Step 1 - plot each chan on 1 example session
% Y axis - % choice (with hline(50))
% X axis - # of trials
% Do this for A - eye tuning and B - ori tuning. 
%
%

%%
% Get our example STMM_LFP
global STIMDIR
cd(STIMDIR)
% load('151221_E_eD_LFP')
load('160102_E_eD_LFP')

%bl Average all lfp data
blSDF = blSubSDF(SDF,sdftm);



% Band pass filter our data 
[croppedSDF,croppedSdftm] = cropNaNsFromSDF(blSDF,STIM,sdftm);
    close all
    figure
    plot(croppedSdftm,squeeze(croppedSDF(5,:,randi(529,1,50))));
    title('Raw LFP')
    vline(0)
    xlabel('time from stim onset (sec)')

GammaBand = D_BAND_BASIC_NODECI(croppedSDF, 1000, [70 150], 'highGamma');
    figure
    plot(croppedSdftm,squeeze(GammaBand.data(5,:,randi(529,1,50)))); hold on;
    title('GammaBand')
    vline(0)
    xlabel('time from stim onset (sec)')
    
    figure
    plot(croppedSdftm,squeeze(GammaBand.highGamma_pwr(5,:,randi(529,1,50)))); hold on;
    title('GammaPwr')
    vline(0)
    xlabel('time from stim onset (sec)')

[trimGammaBand,trimSdftm] = trimGammaBand(GammaBand,croppedSdftm);
    figure
    plot(trimSdftm,squeeze(trimGammaBand.data(5,:,randi(529,1,50)))); hold on;
    title('GammaBand-trimToTransient')
    xlabel('time from stim onset (sec)')
    
    figure
    plot(trimSdftm,squeeze(trimGammaBand.highGamma_pwr(5,:,randi(529,1,50)))); hold on;
    title('GammaPwr-trimToTransient')
    xlabel('time from stim onset (sec)')

% Pull trials from STIM for use in RELIABILITY_SELECTION.m
[eyeFeatureTrls, oriFeatureTrls, tiltOfOriFeature] = findTrialsForFeatures(STIM);


%% Reliability analysis - loop through channels
% 1. pull out data by channel (mean across transient time win for each trial)
% 2. perform reliability analysis

transAvgGammaPwr = squeeze(nanmean(trimGammaBand.highGamma_pwr,2));
clear ch eyeFeatureSummary oriFeatureSummary eyeFeatureData oriFeatureData
for ch = 1:size(GammaBand.data,1)
    clear chData
    chDataGammapwr = transAvgGammaPwr(ch,:)';
    
    eyeFeatureData{1} = chDataGammapwr(eyeFeatureTrls{1},1);
    eyeFeatureData{2} = chDataGammapwr(eyeFeatureTrls{2},1);
    
    oriFeatureData{1} = chDataGammapwr(oriFeatureTrls{1},1);
    oriFeatureData{2} = chDataGammapwr(oriFeatureTrls{2},1);

    
    eyeFeatureSummary(ch) = RELIABILITY_SELECTION(eyeFeatureData);
    oriFeatureSummary(ch) = RELIABILITY_SELECTION(oriFeatureData);
    
end

%% Vis code for each channel

close all

%eye loop
figure(1); hold on;
clear ch
for ch = 1:size(GammaBand.data,1)
        
    subplot(size(GammaBand.data,1),1,ch)
    plot(eyeFeatureSummary(ch).choice_percentage(:,1)); hold on;
    plot(eyeFeatureSummary(ch).choice_percentage(:,2)); hold on;
    xlim([0 size(eyeFeatureSummary(ch).choice_percentage,1)])
    ylim([0 100])
    hline(50)
    
    if ch < size(GammaBand.data,1)
        set(gca,'XTick',[])
    end

end
    EyeTitleText = {'Eye Selection',STIM.penetration};
    sgtitle('Eye Selection')
    legend('IpsiEye','ContraEye')

%ori loop
figure(2); hold on;
clear ch
for ch = 1:size(GammaBand.data,1)
        
    subplot(size(GammaBand.data,1),1,ch)
    plot(oriFeatureSummary(ch).choice_percentage(:,1)); hold on;
    plot(oriFeatureSummary(ch).choice_percentage(:,2)); hold on;
    xlim([0 size(oriFeatureSummary(ch).choice_percentage,1)])
    ylim([0 100])
    hline(50)
    if ch < size(GammaBand.data,1)
        set(gca,'XTick',[])
    end

end
    EyeTitleText = {'Eye Selection',STIM.penetration};
    sgtitle('Ori Selection')
    legend(string(tiltOfOriFeature(1)),string(tiltOfOriFeature(2)))
    




% % 
% % % Save plots
% % global OUTDIR
% % cd(OUTDIR)
% % 




