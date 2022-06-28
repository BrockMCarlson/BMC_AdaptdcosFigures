% Test LFP spec on MUA trial selection
clear
close all
PostSetup('BrockHome')
flag_SaveFigs = false;

%% load session data
global STIMDIR
cd(STIMDIR)

penetration = '151221_E_eD_LFP.mat';
load(penetration,'STIM')
matobj = matfile(penetration);

%% Establish variables to change
sdfwin  = [-0.150  .5];
ConditionToTest = 8; % 6 = congruent NS (this is what was shown on 151221)
% % It also has trials for 7 and 8, both IC configs

%% Set up variables for electrode loop
% Balance conditions
if ~any(contains(STIM.paradigm,'brfs'))
   warning('no brfs on day...')
   disp(penetration)
   error('noBrfs')
end
nel = length(STIM.el_labels);
difiles = unique(STIM.filen(STIM.ditask));
win_ms = matobj.win_ms;
if isequal(win_ms(3,:),[50 250])
    respDimension = 3;
elseif isequal(win_ms(4,:),[50 250])
    respDimension = 4;
else
    error('RESP dimension issue')
end
SupraCount = 0;
GranularCount = 0;
InfraCount = 0;
count = 0;

%% Electrode loop
for e = 1:nel
%% Load in electrode contact data
    disp(strcat(penetration,'/ / contact =_ ',num2str(e)))
    disp(strcat(['depth =_ '],string(STIM.depths(e,2))))

    clear RESP SDF sdf sdftm X M TRLS SUB 
    RESP = squeeze(matobj.RESP(e,respDimension,:));

    
    
%     %% Di Unit Tuning -- RESP is always from AUTO
%      X = diUnitTuning(RESP,STIM);
%      DE = X.dipref(1);
%      NDE = X.dinull(1);
%      PS = X.dipref(2);
%      NS = X.dinull(2);
%      

%Set manually for 151221 just for testing purposes -- see reliability
%feature selection code from Jake W.
% ipsi eye = 2. Contra eye = 3. Both eyes = 1.
DE  = 2;
NDE = 3;
PS  = 0;
NS  = 90;

% Ignore the contact selection for LFP
% % %% Set limits on acceptable tuning.
% % if X.diana ~= 1
% %     ErrorCount = ErrorCount+1;
% %     ERR(ErrorCount).reason = 'dichoptic analysis not run on unit';
% %     ERR(ErrorCount).penetration = STIM.penetration;
% %     ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
% %     continue
% % end
% % if X.dianp(2) > 0.05
% %     ErrorCount = ErrorCount+1;
% %     ERR(ErrorCount).reason = 'unit not tuned to ori';
% %     ERR(ErrorCount).penetration = STIM.penetration;
% %     ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
% %     continue
% % end
% % if X.dianp(3) > 0.05
% %     ErrorCount = ErrorCount+1;
% %     ERR(ErrorCount).reason = 'unit tuned to ori but NOT to contrast';
% %     ERR(ErrorCount).penetration = STIM.penetration;
% %     ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
% %     continue
% % end
% % if X.dianp(1) > 0.05
% %     ErrorCount = ErrorCount+1;
% %     ERR(ErrorCount).reason = 'unit tuned to ori and contrast but NOT to contrast';
% %     ERR(ErrorCount).penetration = STIM.penetration;
% %     ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
% %     continue
% % end


    
%% Conditions established to pull out SDFs
   % loop through different resp windows based on win_ms;
if ~isequal(win_ms(1,:),[50 100])
    error('RESP dimension issue')
end

if isnan(DE)
    error('check why this unit doesnt have monoc tuning considering previous catch')
    disp(uct+1);
end


[condition,conditionarray] = getCond(DE,NDE,PS,NS);



clear I
I = STIM.ditask...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0; 

% clear I
% I = strcmp(STIM.task,'mcosinteroc')...
%     & ~STIM.blank ...
%     & STIM.rns == 0 ...
%     & STIM.cued == 0 ...
%     & STIM.motion == 0; 



% determine main contrasts levels
%%%% BMC --> THIS IS CURRENTLY UNUSED 3-3-2020
clear uContrast contrast_*
uContrast = unique(STIM.contrast(I,:));
uContrast(uContrast==0) = [];
contrast_max = max(uContrast);
[~,idx] = min(abs(uContrast - contrast_max/2));
contrast_half   = uContrast(idx);
stimcontrast = [contrast_half contrast_max]; % note -- this is flipped from MAC's method of [max half]. This method makes more sense to me.


% Sort by eyes      
clear SORTED
SORTED.eyes      = STIM.eyes;
SORTED.contrasts = STIM.contrast;
SORTED.tilts     = STIM.tilt;
SORTED.flippedSOA = zeros(size(STIM.tilt));

if DE == 2
    [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'ascend');
else
    [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'descend');
end
clear w
for w = 1:length(SORTED.eyes)
    SORTED.contrasts(w,:) = SORTED.contrasts(w,sortidx(w,:));
    SORTED.tilts(w,:)     = SORTED.tilts(w,sortidx(w,:));
end; clear w

%% Pull out SDF
% Pre-allocate
clear  cond SDF SDF_uncrop sdf trlsLogical
CondTrialNum_SDF = nan(size(condition,1),1);
CondTrials = cell(size(condition,1),1);
sdf  = squeeze(matobj.SDF(e,:,:));
SDF_uncrop  = cell(size(condition,1),1);
SDF_crop    = cell(size(condition,1),1);

for cond = 1:size(conditionarray,1)
    clear trls    
    % get monocular trials
    if cond < 5
      trls = I &...
            STIM.eye        == conditionarray(cond,1) &...
            STIM.tilt(:,1)  == conditionarray(cond,2) & ...
            STIM.tiltmatch  == conditionarray(cond,3) & ...
            STIM.adapter   == conditionarray(cond,4) & ...  
            STIM.suppressor == conditionarray(cond,5) & ...
            STIM.soa        == conditionarray(cond,6) & ...
            STIM.monocular  == conditionarray(cond,7) & ...
            (STIM.contrast(:,1)  >= .3 & STIM.contrast(:,1) <= .6);
        trlsLogical(:,cond) = trls;
        CondTrials{cond} = find(trls);
        CondTrialNum_SDF(cond,1) = sum(trls); 
        SDF_uncrop{cond}   = sdf(:,trls);    
    elseif cond >= 5 && cond <= 8 % get simultaneous trials
        trls = I &...
            SORTED.tilts(:,1) == conditionarray(cond,2) & ...
            STIM.tiltmatch == conditionarray(cond,3) & ...
            STIM.adapter   == conditionarray(cond,4) & ...  
            STIM.suppressor   == conditionarray(cond,5) & ...
            STIM.soa       == conditionarray(cond,6) & ...
            STIM.monocular == conditionarray(cond,7) & ...
            ((SORTED.contrasts(:,1)  >= .3) & (SORTED.contrasts(:,1)  <= .6 )) &...
            ((SORTED.contrasts(:,2)  >= .3) & (SORTED.contrasts(:,2)  <= .6 ));
        trlsLogical(:,cond) = trls;
        CondTrials{cond} = find(trls);
        CondTrialNum_SDF(cond,1) = sum(trls); 
        SDF_uncrop{cond}   = sdf(:,trls);    
        
    elseif cond == 9 || cond == 11 || cond == 13 || cond == 15 || cond == 17 || cond == 19 || cond == 21 || cond == 23
    % get adapter trials
    trls = I &... %everything is in second column bc BRFS format is [adapter STIM.suppressor]
        STIM.eyes(:,2) == conditionarray(cond,1) &...
        STIM.tilt(:,1) == conditionarray(cond,2) & ...
        STIM.tiltmatch == conditionarray(cond,3) & ...
        STIM.adapter   == conditionarray(cond,4) & ...  
        STIM.suppressor   == conditionarray(cond,5) & ...  
        STIM.soa       == conditionarray(cond,6) & ...
        STIM.monocular == conditionarray(cond,7) & ...
        ((STIM.contrast(:,1)  >= .3) & (STIM.contrast(:,1)   <= .6 ));
        
    trlsLogical(:,cond) = trls;
    CondTrials{cond} = find(trls);
    CondTrialNum_SDF(cond,1) = sum(trls); 
    SDF_uncrop{cond}   = sdf(:,trls);    
    
    
    elseif cond == 10 || cond == 12 || cond == 14 || cond == 16 || cond == 18 || cond == 20 || cond == 22 || cond == 24
    % get suppresor trials
    trls = I &... %everything is in second column bc BRFS format is [adapter STIM.suppressor]
        STIM.eyes(:,2) == conditionarray(cond,1) &...
        STIM.tilt(:,2) == conditionarray(cond,2) & ...
        STIM.tiltmatch == conditionarray(cond,3) & ...
        STIM.adapter   == conditionarray(cond,4) & ...  
        STIM.suppressor   == conditionarray(cond,5) & ...  
        STIM.soa       == conditionarray(cond,6) & ...
        STIM.monocular == conditionarray(cond,7) & ...
        ((STIM.contrast(:,1)  >= .3) & (STIM.contrast(:,1)   <= .6 )) &...
        ((STIM.contrast(:,2)  >= .3) & (STIM.contrast(:,2)   <= .6 ));
    trlsLogical(:,cond) = trls;
    CondTrials{cond} = find(trls);
    CondTrialNum_SDF(cond,1) = sum(trls); 
    SDF_uncrop{cond}   = sdf(:,trls);    
    end
    
end





%% crop/pad SDF
        % crop / pad SDF    
        %% Pad works for MUA but not for LFP requires trial averaging...
        clear tm pad st en
        tm = matobj.sdftm;
        if tm(end) < sdfwin(2)  
           error('padding not correctly set up for LFP -- check MAC code')
        else
            pad = [];
            en = find(tm == sdfwin(2))-1;
            st = find(tm == sdfwin(1));
            TM = tm(st : en);
        end
        clear cond
        for cond = 1:size(conditionarray,1)
            data = SDF_uncrop{cond}; % data is in [time x trials]
            if isempty(data)
                % No conditions of this type were presented on this session
                continue
            else
                data_crop = data(st:en,:);
            end
            SDF_crop{cond} = data_crop;
        end
        
        

%% SAVE  IDX



        % SAVE UNIT INFO!
        clear holder
        holder.penetration = penetration;
        holder.header = penetration(1:8);
        holder.monkey = penetration(8);
        holder.runtime = [date string(now)];

        holder.depth = STIM.depths(e,:)';

        holder.mask         = any(STIM.rsvpmask(STIM.cued ~=0));
        holder.dicontrast   = stimcontrast';

        holder.DE    = DE;
        holder.PS    = PS;
        holder.NDE    = NDE;
        holder.NS    = NS;        
        holder.TM        = TM;

        holder.SDF_crop      = SDF_crop;
        holder.SDF_uncrop    = SDF_uncrop;


        holder.condition        = condition;
        holder.CondTrialNum_SDF     = CondTrialNum_SDF;        
        
        holder.STIM               = STIM;


        
        % Laminar Division
        if holder.depth(2) >5
            SupraCount = SupraCount + 1;  
            IDX.Supra(SupraCount) = holder;
        elseif holder.depth(2) >= 0 && holder.depth(2) <= 5
            GranularCount = GranularCount + 1;
            IDX.Granular(GranularCount) = holder;
        elseif holder.depth(2) < 0
            InfraCount = InfraCount + 1;
            IDX.Infra(InfraCount) = holder;
        end
        count = count + 1;
        IDX.allV1(count) = holder;

        
end



%% Spectrogram
clearvars -except IDX sdfwin ContactToTest ConditionToTest flag_SaveFigs


% Plot each contact
global OUTDIR
for c = 1:size(IDX.allV1,2)
    
    ContactToTest = c;
    depth = string(IDX.allV1(c).depth(2));

    % Grab an individual electrode contact you want to look at
    DATA = IDX.allV1(ContactToTest);
    SDF = DATA.SDF_crop{ConditionToTest}; % SDF is in [time x trials]
    TM = DATA.TM;

    if sum(isnan(SDF),'all') > 0
        error('NaNs in Data')
    end

    % spectrogram conventions
    window = 2^7;
    rsampt = 0.0010; % 1 kHz
    frange = [1 250]; % look at 1 to 100 Hz only
    fs = floor(1/rsampt);
    noverlap = window-2^6;
    start = find(TM == 0);
    poststim = 1:size(DATA.TM,2) - start + 1; % limit time window
    poststimTM = TM(start:end);

    % preallocate for spectrogram
    x = SDF(:,1);
    [~,F,T] = spectrogram(x,window,noverlap,[],fs);
    tInSamples = T*1000';
    newTimeVector = TM(tInSamples);
    basetm = (newTimeVector < 0);

    fsel = (F<frange(2) & F > frange(1));

    % pull out spectrogram
    clear trv
    [tottm,tottr] = size(SDF);
    for tr = 1:tottr
    %     dcoffs = mean(SDF(poststim,tr),1);
    %     mntrvlfp = repmat(dcoffs,tottm);
    %     cttrvlfp = SDF(:,tr)-mntrvlfp; %center
        x = SDF(:,tr);
        [tmp,F,T] = spectrogram(x,window,noverlap,[],fs); %tmp 129x523
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
    travg_spc_mn = squeeze(nanmean(trv.spgm,3));
    % plot
    travg_spc = imrotate(travg_spc_mn,0);
    h(c) = figure;
    f = F(fsel);
    imagesc(newTimeVector,f,travg_spc) %travg_spc is (f x t)
    set(gca,'ydir','normal');   
    xlabel('Time (sec)')
    ylabel('Hz')
    vline(0)
    title(strcat('Depth is...',depth))
    
    if flag_SaveFigs
        cd(OUTDIR)
        savename = strcat('SpectraByContact',string(c),'.pdf');
        exportgraphics(h(c),savename)
    end
 

end

% Average across contacts
travg_spc = nan(size(IDX.allV1,2),63,523);
for c = 1:size(IDX.allV1,2)
    
    ContactToTest = c;
    depth = string(IDX.allV1(c).depth(2));

    % Grab an individual electrode contact you want to look at
    DATA = IDX.allV1(ContactToTest);
    SDF = DATA.SDF_crop{ConditionToTest}; % SDF is in [time x trials]
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
    poststim = 1:size(DATA.TM,2) - start + 1; % limit time window
    poststimTM = TM(start:end);

    % preallocate for spectrogram
    x = SDF(:,1);
    [~,F,T] = spectrogram(x,window,noverlap,[],fs);
    tInSamples = T*1000';
    newTimeVector = TM(tInSamples);
    basetm = (newTimeVector < 0);

    fsel = (F<frange(2) & F > frange(1));

    % pull out spectrogram
    clear trv
    [tottm,tottr] = size(SDF);
    for tr = 1:tottr
    %     dcoffs = mean(SDF(poststim,tr),1);
    %     mntrvlfp = repmat(dcoffs,tottm);
    %     cttrvlfp = SDF(:,tr)-mntrvlfp; %center
        x = SDF(:,tr);
        [tmp,F,T] = spectrogram(x,window,noverlap,[],fs); %tmp 129x523
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
    travg_spc_mn = squeeze(nanmean(trv.spgm,3));
    travg_spc(c,:,:) = imrotate(travg_spc_mn,0);


end

%Average across contacts
ContactAvg = squeeze(mean(travg_spc,1));

% plot
plotFullContact = figure;
f = F(fsel);
imagesc(newTimeVector,f,ContactAvg) %travg_spc is (f x t)
set(gca,'ydir','normal');   
xlabel('Time (sec)')
ylabel('Hz')
vline(0)
title('FullContactAvg')

if flag_SaveFigs
    cd(OUTDIR)
    savename = strcat('FullContactAvg.pdf');
    exportgraphics(plotFullContact,savename)
end
    
%% Sanity testing for LFP and imagesc plot dirction - archive
%     %imagesc sanity test. Plot the frequencies in increasing color
%     figure
%     testMatrix = zeros(63,523);
%     count = 0;
%     for test = 1:63
%        testMatrix(test,:) =  f(test);
%     end
%      imagesc(newTimeVector,f,testMatrix) %travg_spc is (f x t)
%         set(gca,'ydir','normal');   
%         xlabel('Time (sec)')
%         ylabel('Hz')
%         vline(0)
%     
% 
% %% Average LFP
% figure
% LFP_Avg = median(SDF,2);
% plot(TM',LFP_Avg)
% vline(0)
% xlim([TM(1) TM(end)])
% title('LFP median')
% 
% figure
% plot(TM,SDF)
% vline(0)
% xlim([TM(1) TM(end)])
% 
% % rand 3 select
% figure
% test = randi(size(SDF,2),1,3);
% plot(TM,SDF(:,test))
% vline(0)
% xlim([TM(1) TM(end)])
% 
% SDF_3trlAvg = mean(SDF(:,test),2);
% figure
% plot(TM,SDF_3trlAvg)
% vline(0)
% xlim([TM(1) TM(end)])
% 
