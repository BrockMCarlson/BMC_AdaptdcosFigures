%% diIDX_SingleTrials
% taken from  --- diIDX_PhyTesting - v1 of AssignEyePref.m


clear
tic

global STIMDIR
didir = STIMDIR;
cd(STIMDIR)
saveName = 'diIDX_Phy_PrefSelected';
anaType = '_KLS.mat';
flag_saveFigs   = 1;
load('PhyPref.mat')

list    = dir([didir '*' anaType]);

sdfwin  = [-0.05  .4];

clear holder IDX
SupraCount = 0;
GranularCount = 0;
InfraCount = 0;
count = 0;
ErrorCount = 0;
noBrfs = 0;
yesBrfs = 0;
%% For loop on unit
% % % for i = 1:length(list)

i = 1; % forces 151221_E_eD
%% load session data
clear penetration
penetration = list(i).name(1:11); 

clear STIM nel difiles
load([didir penetration '.mat'],'STIM')

% Balance conditions
if ~any(contains(STIM.paradigm,'brfs'))
   error('no brfs on day...')
% % % %    disp(penetration)
% % % %    noBrfs = noBrfs + 1;
% % % %    MISSNIG(noBrfs,:) = penetration;
% % % %    continue
else
    yesBrfs = yesBrfs+1;
    FOUND(yesBrfs,:) = penetration;
end
if contains(anaType,'KLS')
    nel = length(STIM.units);
else
    nel = length(STIM.el_labels);
end
difiles = unique(STIM.filen(STIM.ditask));


clear matobj_RESP matobj_SDF win_ms
matobj_RESP = matfile([didir penetration '_AUTO.mat']);
if contains(anaType,'CSD') || contains(anaType,'AUTO')
    youAreGood = true;
else
    matobj_RESP= matfile([didir penetration anaType]);
end
matobj_SDF = matfile([didir penetration anaType]);

win_ms = matobj_RESP.win_ms;
if isequal(win_ms(3,:),[50 250])
    respDimension = 3;
elseif isequal(win_ms(4,:),[50 250])
    respDimension = 4;
else
    error('RESP dimension issue')
end

%% Electrode loop
%     for e = 1:nel
e = 4; % forces depth of -3 on this day

    % get data needed for diUnitTuning.m
        disp(strcat(penetration,'/ / contact =_ ',num2str(e)))
        disp('depth equals...')
        disp(STIM.units(e).depth(2))

        clear RESP SDF sdf sdftm X M TRLS SUB 
        RESP = squeeze(matobj_RESP.RESP(e,respDimension,:));
       

    %% Pull out the unit's tuning.
    clear prefIndex
    prefIndex = find(contains(table2array(PhyPref(:,1)),penetration) & table2array(PhyPref(:,3)) == STIM.kls.cluster(e));
    clust = table2array(PhyPref(prefIndex,3));
    DE = table2array(PhyPref(prefIndex,4));
    if DE == 2
        NDE = 3;
    elseif DE == 3
        NDE = 2;
    end
    PS = table2array(PhyPref(prefIndex,5));
    NS = table2array(PhyPref(prefIndex,6));


    %% Conditions established to pull out SDFs
       % loop through different resp windows based on win_ms;
    if ~isequal(win_ms(1,:),[50 100])
        error('RESP dimension issue')
    end

    if isnan(DE)
        error('check why this unit doesnt have monoc tuning considering previous catch')
        disp(uct+1);
    end

    % 1 - simult
    %   1. Monocular DE PS
    %   2. Cong Simult
    %   3. IC   Simult
    % 2 - 200ms
    %   4. Cong 200
    %   5. IC   200
    % 3 - 800ms
    %   6. Cong 800
    %   7. IC   800
    condition= table(...
    [DE  NDE DE  NDE DE  DE  DE  DE  DE  DE]',... %eyes1
    [PS  PS  NS  NS  PS  PS  PS  PS  PS  PS]',... %tilt1
    [1   1   1   1   1   0   1   0   1   0]',... %tiltmatch
    [0   0   0   0   0   0   1   1   1   1]',... %suppressor
    [0   0   0   0   0   0   200 200 800 800]',... %soa
    [1   1   1   1   0   0   0   0   0   0]',... %monoc
    'VariableNames',{'eyes1','tilt1','tiltmatch','suppressor','soa','monoc'});

    condition.Properties.RowNames = {...
        'Monocualr PS DE',...
        'Monocualr PS NDE',...
        'Monocualr NS DE',...
        'Monocualr NS NDE',...
        'Cong Simult',...
        'IC   Simult',...
        'Cong 200',...
        'IC   200',...
        'Cong 800',...
        'IC   800',...
        };
    conditionarray = table2array(condition);

    brfsFileNum = STIM.units(1).fileclust(1);
    clear I
    I = STIM.ditask...
        & STIM.filen == brfsFileNum ...
        & ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0; 


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

    %% preallocate for SDF
    % Pre-allocate
    clear  cond SDF SDF_uncrop sdf sua trlsLogical CondTrialNum CondTrials
% %     CondTrialNum = nan(size(condition,1),1);
% %     CondTrials = cell(size(condition,1),1);
    sdf  = squeeze(matobj_SDF.SDF(e,:,:));
    sua  = squeeze(matobj_SDF.SUA(e,:,:));
% % %     SDF_uncrop = nan(size(conditionarray,1),size(sdf,1));
% % %     SEM_uncrop = nan(size(conditionarray,1),size(sdf,1));

    
    %% Choose the condition to look at
    prompt = 'What condition shall we look at each trial for? ';
    cond = input(prompt);
    disp('condition chosen')
    disp(condition.Properties.RowNames{cond})
    
    %% Pull out response for all trials with that condition.
    % %     for cond = 1:size(conditionarray,1)
        clear trls    
        % get monocular trials
        if cond < 5
            trls = I &...
                STIM.eye        == conditionarray(cond,1) &...
                STIM.tilt(:,1)  == conditionarray(cond,2) & ...
                STIM.tiltmatch  == conditionarray(cond,3) & ...
                STIM.suppressor == conditionarray(cond,4) & ...
                STIM.soa        == conditionarray(cond,5) & ...
                STIM.monocular  == conditionarray(cond,6) & ...
                (STIM.contrast(:,1)  >= .3 & STIM.contrast(:,1) <= 1);
        elseif cond == 5 || cond == 6 % get simultaneous trials
            trls = I &...
                SORTED.tilts(:,1) == conditionarray(cond,2) & ...
                STIM.tiltmatch == conditionarray(cond,3) & ...
                STIM.suppressor   == conditionarray(cond,4) & ...
                STIM.soa       == conditionarray(cond,5) & ...
                STIM.monocular == conditionarray(cond,6) & ...
                ((SORTED.contrasts(:,1)  >= .3) & (SORTED.contrasts(:,1)  <= 1 )) &...
                ((SORTED.contrasts(:,2)  >= .9) & (SORTED.contrasts(:,2)  <= 1 ));
       else    
            % get suppressor trials
            trls = I &... %everything is in second column bc BRFS format is [adapter STIM.suppressor]
                STIM.suppressor &...
                STIM.eyes(:,2) == conditionarray(cond,1) &...
                STIM.tilt(:,2) == conditionarray(cond,2) & ...
                STIM.tiltmatch == conditionarray(cond,3) & ...
                STIM.suppressor   == conditionarray(cond,4) & ...  
                STIM.soa       == conditionarray(cond,5) & ...
                STIM.monocular == conditionarray(cond,6) & ...
                ((SORTED.contrasts(:,1)  >= .3) & (SORTED.contrasts(:,1)  <= 1 )) &...
                ((SORTED.contrasts(:,2)  >= .9) & (SORTED.contrasts(:,2)  <= 1 ));
        end

% % %         CondTrials{cond} = find(trls);
% % %         CondTrialNum(cond,1) = sum(trls); 
        CondTrials = find(trls);
        CondTrialNum = sum(trls);

% % %         
        disp(strcat('Number of trials for this condition is..._',num2str(CondTrialNum)))
       
        
        %% HERE IS WHAT I WANT TO grab from a trial loop
        clear trlLoop
        SDF_uncrop = nan(size(CondTrials,1),size(sdf,1));
        SUA_uncrop = nan(size(CondTrials,1),size(sua,1));
        for trlLoop = 1:size(CondTrials,1)
            SDF_uncrop(trlLoop,:)   = sdf(:,CondTrials(trlLoop));    % Use trls to pull out continuous data   
            SUA_uncrop(trlLoop,:)   = sua(:,CondTrials(trlLoop));    % Use trls to pull out spk data   
        end



% % % % 
% % % % 
% % % % %%
% % % % % % %     end
% % % % `       % This was removed as former endpoitn for cond loop
% % % % 
% % % % %% Idk what to title this seciton.....
% % % % % %     if any(isnan(CondTrialNum))
% % % % % %         error('all conditions not met')
% % % % % %     end
% % % % 
% % % % 
% % % % 
% % % % 
%% crop/pad SDF
    % crop / pad SDF    
    clear tm pad st en 
    tm = matobj_SDF.sdftm;
    if tm(end) < sdfwin(2)  
        pad = [tm(end):diff(tm(1:2)):sdfwin(2)];
        pad(1) = [];
        en = length(tm);
        st = find(tm> sdfwin(1),1);
        tm = [tm pad];
        tm = tm(st : end);
        pad(:) = NaN;
    else
        pad = [];
        en = find(tm > sdfwin(2),1)-1;
        st = find(tm > sdfwin(1),1);
        tm = tm(st : en);
    end
    if isnan(pad)
        warning('this might not be set up to properly pad the contrast dimension')
    end
    padrows = repmat(pad,size(condition,1),1); % pads with NANs if you are not in that condition any more. 
        clear SDF
        SDF.raw = cat(2,SDF_uncrop(:, st : en,:), padrows); clear SDF_uncrop;                  
% % %                 SEM.raw = cat(2,SEM_uncrop(:, st : en,:), padrows); clear SEM_uncrop;                  
        if size(SDF.raw,2) ~= length(tm)
            error('check tm')
        end
        TM = tm;


%% CROP/PAD SPK
% crop / pad SDF    
    clear tm pad st en spktm
    tm = matobj_SDF.sdftm;
    if size(sua,1) ~= size(tm,2)
        front = -.300:.001:-.151;
        back = tm(end)+.001:.001:tm(end)+.150;
        spktm = [front tm back];
    else
        error('remove spktm correction from code - diNeuralDat_usePhy has been rerun to also trim SUA')
    end
    error('do not use spktm. This changes for each trial based on the spike times out.')
    if spktm(end) < sdfwin(2)  
        pad = [spktm(end):diff(spktm(1:2)):sdfwin(2)];
        pad(1) = [];
        en = length(spktm);
        st = find(spktm> sdfwin(1),1);
        spktm = [spktm pad];
        spktm = spktm(st : end);
        pad(:) = NaN;
    else
        pad = [];
        en = find(spktm > sdfwin(2),1)-1;
        st = find(spktm > sdfwin(1),1);
        spktm = spktm(st : en);
    end
    if isnan(pad)
        warning('this might not be set up to properly pad the contrast dimension')
    end
    padrows = repmat(pad,size(condition,1),1); % pads with NANs if you are not in that condition any more. 
        clear SUA
        SUA.raw = cat(2,SUA_uncrop(:, st : en,:), padrows); clear SUA_uncrop;                  
% % %                 SEM.raw = cat(2,SEM_uncrop(:, st : en,:), padrows); clear SEM_uncrop;                  
        if size(SUA.raw,2) ~= length(spktm)
            error('check tm')
        end


               
%% SET UP PLOTING
close all
global SAVEDIR
cd(SAVEDIR) 
if ~flag_saveFigs
    error('did you want to save these?')
end

%% HERE IS WHERE WE PLOT THE SDF for all trials  

spkMax = max(SDF.raw,[],'all');
count = 0;
clear trlLoop
for trlLoop = 1:size(CondTrials,1)
    count = count + 1;
    figure
    plot(TM,SDF.raw(trlLoop,:))
    ylim([0 spkMax])
    vline(0)
    titleText = strcat('TrlNum--',num2str(CondTrials(trlLoop)));
    title(titleText)
    ylabel('spks/sec')
    xlabel('Time(sec)')

     if count == 1
        export_fig('SingleTrial_MonocPS','-pdf','-nocrop') 
    else
        export_fig('SingleTrial_MonocPS','-pdf','-nocrop','-append')
    end
end

%% MEAN PLOT (raster/SDF)
figure
subplot(2,1,1)
spikesIn = SUA.raw == 1;
MarkerFormat.MarkerSize = 5;
MarkerFormat.Marker = '.';
plotSpikeRaster(spikesIn,'PlotType','scatter','MarkerFormat',MarkerFormat)

newTM = TM(50:50:end);
if newTM(9) ~= .4
    error('check the manual TM input')
end
newNewTM = nan(1,length(newTM)+1);
newNewTM(1) = -.050;
newNewTM(2:length(newTM)+1) = newTM;
xticks([0:50:450])
xticklabels(newNewTM)
vline(50) % This unfortunatly is an index and not a label.
ylabel('Trial Number')
        
% Subplot of mean SDF ---
subplot(2,1,2)
SDFTrlsMean   = nanmean(SDF.raw,1);    % Use trls to pull out continuous data   
plot(TM,SDFTrlsMean)  
% ylim([0 spkMax])
vline(0)
ylabel('spks/sec')
xlabel('Time(sec)')

titleText = {'TrlAvgResponse - Session 151221. Unit at depth -3','Monoc. Pref Stim. Dom Eye.'};
sgtitle(titleText)

export_fig('TrlMean_MonocPS','-pdf','-nocrop')




