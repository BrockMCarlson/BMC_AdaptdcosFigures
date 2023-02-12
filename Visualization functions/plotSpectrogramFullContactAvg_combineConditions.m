function [SpcTimeVector,F,SpcContactAvg] = ...
    plotSpectrogramFullContactAvg_combineConditions(IDX,CondToCombine)

conditionTable = IDX.allV1(1).condition;
conditionName{1} = conditionTable.Properties.RowNames{CondToCombine(1)};
conditionName{2} = conditionTable.Properties.RowNames{CondToCombine(2)};

titleText = {'FullContactAvg',conditionName{1},conditionName{2}};


% Average across contacts
travg_spc = nan(size(IDX.allV1,2),63,523);
for c = 1:size(IDX.allV1,2)
    
    ContactToTest = c;
    depth = string(IDX.allV1(c).depth(2));

    % Grab an individual electrode contact you want to look at
    DATA = IDX.allV1(ContactToTest);
    sdf_1 = DATA.SDF_crop{CondToCombine(1)}; % SDF is in [time x trials]
    sdf_2 = DATA.SDF_crop{CondToCombine(2)}; % SDF is in [time x trials]
    SDF = [sdf_1 sdf_2];
    TM = DATA.TM;

    if sum(isnan(SDF),'all') > 0
        error('NaNs in Data')
    end

    % spectrogram conventions
    window = 2^7;
    rsampt = 0.0010; % 1 kHz
    frange = [1 250]; % look at 1 to 100 Hz only
    fs = floor(1/rsampt);
    noverlap = window-1;
    start = find(TM == 0);

    % preallocate for spectrogram
    x = SDF(:,1);
    [~,f,t] = spectrogram(x,window,noverlap,[],fs);
    tInSamples = t*1000';
    SpcTimeVector = TM(tInSamples);
    basetm = (SpcTimeVector < 0);

    fsel = (f<frange(2) & f > frange(1));

    % pull out spectrogram
    clear trv
    [tottm,tottr] = size(SDF);
    for tr = 1:tottr
    %     dcoffs = mean(SDF(poststim,tr),1);
    %     mntrvlfp = repmat(dcoffs,tottm);
    %     cttrvlfp = SDF(:,tr)-mntrvlfp; %center
        x = SDF(:,tr);
        [tmp,f,t] = spectrogram(x,window,noverlap,[],fs); %tmp 129x523
        spc = (abs(tmp(fsel,:))); %63 x 523
            spc(:,:) = 20*log10(abs(tmp(fsel,:))); %spc is in [F x T] (63 x 523)
        % baseline correct
            basespc = mean(spc(:,basetm),2);
            [bnds,tmn] = size(spc);
            basemat = repmat(basespc,1,tmn);
            spc = spc-basemat; % => baseline subtracted
        % collect spectra
            trv.spgm(:,:,tr) = spc; clear spc

    end


    
    %compute trial average
    travg_spc_mn = squeeze(mean(trv.spgm,3));
    travg_spc(c,:,:) = imrotate(travg_spc_mn,0);
    
    if isnan(travg_spc_mn)
        error('no nans should be here...')
    end


end

%Average across contacts
SpcContactAvg = squeeze(mean(travg_spc,1));

% plot
plotFullContact = figure;
F = f(fsel);
imagesc(SpcTimeVector,F,SpcContactAvg) %travg_spc is (f x t)
set(gca,'ydir','normal');   
xlabel('Time (sec)')
ylabel('Hz')
vline(0)
title(titleText)







end