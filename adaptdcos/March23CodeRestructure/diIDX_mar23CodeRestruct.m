%% diIDX
% taken from diIDX_Adapt200vs800_monocX


%goal --> x axis for scatters as a function of monocular equivilancy
%subtraction in monocular activity


clear

global STIMDIR

didir = STIMDIR;
cd(didir)
saveName = 'diIDX_pipelineTEST_AUTO';
anaType = '_AUTO.mat';
flag_saveIDX    = 1;

kls = 0;
list    = dir([didir '*' anaType]);

sdfwin  = [-0.05  .4];

clear IDX
uct = 0;
ErrorCount = 0;
%% For loop on unit
for i = 1:length(list)


%% load session data
clear penetration
penetration = list(i).name(1:11); 



clear STIM nel difiles
load([didir penetration '.mat'],'STIM')
nel = length(STIM.el_labels);
difiles = unique(STIM.filen(STIM.ditask));



clear matobj_RESP matobj_SDF win_ms
if strcmp(anaType,'_CSD.mat')
    matobj_RESP = matfile([didir penetration '_AUTO.mat']);
    matobj_SDF = matfile([didir penetration anaType]);
else
    matobj_RESP = matfile([didir penetration anaType]);
    matobj_SDF = matfile([didir penetration anaType]);
end
win_ms = matobj_RESP.win_ms;
if isequal(win_ms(3,:),[50 250])
    respDimension = 3;
elseif isequal(win_ms(4,:),[50 250])
    respDimension = 4;
else
    error('RESP dimension issue')
end

%% Electrode loop
for e = 1:nel
% get data needed for diUnitTuning.m
    disp(uct)
    tic

    clear RESP SDF sdf sdftm X M TRLS SUB 
    RESP = squeeze(matobj_RESP.RESP(e,respDimension,:));

    % get "goodfiles" for each cluster
    % i.e., the files over which the cluster is present
    % pref for ditasks if there are more than 1 set of clusters at depth
    % DEV:  should be able to scrape more from
    %       STIM.rclusters, and non-used STIM.clusters
    clear goodfiles allfiles
    allfiles = 1:length(STIM.filelist);
    if ~kls
        goodfiles = allfiles;
    else
        goodfiles = find(~isnan(STIM.clusters(e,:)));
        if isempty(goodfiles)
            ErrorCount = ErrorCount+1;
            ERR(ErrorCount).reason = 'goodfiles is empty';
            ERR(ErrorCount).penetration = STIM.penetration;
            ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
            continue
        elseif ~isequal(goodfiles,allfiles)...
                && length(goodfiles)>1 ...
                && any(diff(goodfiles) > 1)
            goodfiles = unique(STIM.filen(ismember(STIM.filen, goodfiles) & STIM.ditask));
        end
    end
    if any(diff(goodfiles) > 1)
        ErrorCount = ErrorCount+1;
        ERR(ErrorCount).reason = 'goodfiles diff > 1 - salvage?';
        ERR(ErrorCount).penetration = STIM.penetration;
        ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
        continue
    end

        
%% Di Unit Tuning
     X = diUnitTuning(RESP,STIM,goodfiles);
     DE = X.dipref(1);
     NDE = X.dinull(1);
     PS = X.dipref(2);
     NS = X.dinull(2);
 
%% Set limits on acceptable tuning.
if X.diana ~= 1
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'dichoptic analysis not run on unit';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    continue
end
if X.dianp(2) > 0.05
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'unit not tuned to ori';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    continue
end
if X.dianp(3) > 0.05
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'unit tuned to ori but NOT to contrast';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    continue
end
if X.dianp(1) > 0.05
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'unit tuned to ori and contrast but NOT to eye';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    continue
end
    
%% Conditions established to pull out SDFs
   % loop through different resp windows based on win_ms;
if ~isequal(win_ms(1,:),[50 100])
    error('RESP dimension issue')
end
if ~all((STIM.contrast(find(STIM.adapter)+1,1) == STIM.contrast(STIM.suppressor,1)) & ...
        (STIM.tilt(find(STIM.adapter)+1,1) == STIM.tilt(STIM.suppressor,1)) & ...
        (STIM.monocular(find(STIM.adapter)) == 1))
    error('The following needs to be true: STIM.eyes(:,1) == 1st stimulus on,adaptor STIM.eyes(:,2) == 2nd stimulus on, supressor,AND adaptor must be set to monocular')
end

if isnan(DE)
    error('check why this unit doesnt have monoc tuning considering previous catch')
    disp(uct+1)
end

% 1 - simult
%   a. Cong Simult
%   b. IC   Simult
% 2 - 200ms
%   c. Cong 200
%   d. IC   200
% 3 - 800ms
%   e. Cong 800
%   f. IC   800
condition= table(...
[DE  DE  DE  DE  DE  DE]',... %eyes1
[PS  PS  PS  PS  PS  PS]',... %tilt1
[1   0   1   0   1   0]',... %tiltmatch
[0   0   1   1   1   1]',... %adapted
[0   0   200 200 800 800]',... %soa
[0   0   0   0   0   0]',... %monoc
'VariableNames',{'eyes1','tilt1','tiltmatch','adapted','soa','monoc'});
condition.Properties.RowNames = {...
    'Cong Simult',...
    'IC   Simult',...
    'Cong 200',...
    'IC   200',...
    'Cong 800',...
    'IC   800',...
    };
conditionarray = table2array(condition);

clear I
I = STIM.ditask...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,goodfiles);


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
sdf  = squeeze(matobj_SDF.SDF(e,:,:));
SDF_uncrop = nan(size(conditionarray,1),size(sdf,1));

for cond = 1:size(conditionarray,1)
    clear trls    
    % get simultaneous trials
    if cond == 1 || 2
        trls = I &...
            SORTED.tilts(:,1) == conditionarray(cond,2) & ...
            STIM.tiltmatch == conditionarray(cond,3) & ...
            STIM.adapted   == conditionarray(cond,4) & ...
            STIM.soa       == conditionarray(cond,5) & ...
            STIM.monocular == conditionarray(cond,6) & ...
            (SORTED.contrasts(:,1)  >= .3 & SORTED.contrasts(:,1) <= .5) &...
            (SORTED.contrasts(:,2)  >= .3 & SORTED.contrasts(:,2) <= .5); 
        trlsLogical(:,cond) = trls;
        CondTrials{cond} = find(trls);
        CondTrialNum_SDF(cond,1) = sum(trls); 
        SDF_uncrop(cond,:)   = nanmean(sdf(:,trls),2);    % Use trls to pull out continuous data     
    else    
    % get STIM.suppressor trials
    trls = I &... %everything is in second column bc BRFS format is [adapter suppresor]
        STIM.suppressor &...
        STIM.eyes(:,2) == conditionarray(cond,1) &...
        STIM.tilt(:,2) == conditionarray(cond,2) & ...
        STIM.tiltmatch == conditionarray(cond,3) & ...
        STIM.adapted   == conditionarray(cond,4) & ...  
        STIM.soa       == conditionarray(cond,5) & ...
        STIM.monocular == conditionarray(cond,6) & ...
        (STIM.contrast(:,1)  >= .3 & STIM.contrast(:,1) <= .5) &...
        (STIM.contrast(:,2)  >= .3 & STIM.contrast(:,2) <= .5); 
    trlsLogical(:,cond) = trls;
    CondTrials{cond} = find(trls);
    CondTrialNum_SDF(cond,1) = sum(trls); 
    SDF_uncrop(cond,:)   = nanmean(sdf(:,trls),2);    % Use trls to pull out continuous data    
    end
    
end

if any(isnan(CondTrialNum_SDF))
    error('all conditions not met')
end



%% crop/pad SDF
        % crop / pad SDF    %%%%DEV_BMC: LATER - concatenate HERE
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
            SDF = cat(2,SDF_uncrop(:, st : en,:), padrows); clear SDF_uncrop;                  
            if size(SDF,2) ~= length(tm)
                error('check tm')
            end
            TM = tm;
%% Skip units that do not have binoc congruent stim (added for null-stim problems)
if isnan(SDF(1,1))
% % %     warning('Congruent not shown')
% % %     warning('changed for null stim -- double-check that this works for pref stim')
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'Congruent not shown? unsure if this is correct- double check if a lot of units are lost';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    continue
end
            
%% Normalize SDF
    % out --> feature scale, z-score, %change
    % inputs --> baseline population mean, baselin population stdev, max
    % SDF from binoc PS congruent simultaneous.

    %get inputs
        % Pull out baseline period
        % nota bene -- Exclude basline of adapted trials later!! - cannot
        % do it on the squeeze line because index must be numeric.
        if isequal(win_ms(4,:),[-50 0])
            blDimension = 4;
        else
            error('RESP dimension issue. fix by programatically finding where the window is.')
        end    
        baselineAll = squeeze(matobj_RESP.RESP(e,blDimension,:));

        %bl pop average
        % Get min response (avg of baseline period for all non-adapted trials)
        blAvg = nanmean(baselineAll(~STIM.adapted,1));
 
        %bl pop stdev
        % Get min response (avg of baseline period for all non-adapted trials)
        blStd = nanstd(baselineAll(~STIM.adapted,1));

        % Max 
        % taken from binoc simult DExPS max response for this unit
        maxSDF = max(SDF(1,:));
    
    % Normalize with "feature scaling" formula
    % Xnorm = (dat-Xmin)./(Xmax-Xmin)
    SDF_fs = (SDF-blAvg)./(maxSDF-blAvg);
    
    % Z-score
    % ZscoreDat = (ContinuousData - popAvgOfBL)./popSTDOfBL
    SDF_zs = (SDF - blAvg)./blStd;
    
    % PercentChange from baseline
    % PerctChangeDat = (NewData - OldData)./(OldData)
    SDF_pc = (SDF - blAvg)./blAvg;


%%
%% Pull out Cong or IC scatterplots
%%
% Pre-allocate
clear  CondTrialNum_RESP CondTrials trlsLogical respForTTest
CondTrialNum_RESP = nan(size(condition,1),1);
CondTrials = cell(size(condition,1),1);
deltaContrast = SORTED.contrasts(:,1) - SORTED.contrasts(:,2); %DE - NDE
% % uniqueDeltaContrast = nanunique(deltaContrast);
% % trlsLogical = nan(size(RESP,1),size(conditionarray,1),size(uniqueDeltaContrast,1));
% % dcX = nan(size(conditionarray,1),size(uniqueDeltaContrast,1));
% % FeatureScale_y = nan(size(conditionarray,1),size(uniqueDeltaContrast,1));
% % respForTTest = nan(size(RESP,1),size(conditionarray,1),size(uniqueDeltaContrast,1));

    % Try inserting contrastCombinations here
    ContrastComb = nanunique(SORTED.contrasts,'rows');
    % Modified old code
    trlsLogical = nan(size(RESP,1),size(conditionarray,1),size(ContrastComb,1));
    dcX = nan(size(conditionarray,1),size(ContrastComb,1));
    FeatureScale_y = nan(size(conditionarray,1),size(ContrastComb,1));
    respForTTest = nan(size(RESP,1),size(conditionarray,1),size(ContrastComb,1));
    
clear cond cc
for cond = 1:size(conditionarray,1)
    for cc = 1:size(ContrastComb,1)
        clear trls    
        % get simultaneous trials
        if cond == 1 || 2
            trls = I &...
                SORTED.tilts(:,1) == conditionarray(cond,2) & ...
                STIM.tiltmatch == conditionarray(cond,3) & ...
                STIM.adapted   == conditionarray(cond,4) & ...
                STIM.soa       == conditionarray(cond,5) & ...
                STIM.monocular == conditionarray(cond,6) & ...
                SORTED.contrasts(:,1)  == ContrastComb(cc,1) & ...
                SORTED.contrasts(:,2)  == ContrastComb(cc,2); 
        else    
        % get suppressor trials
            trls = I &... %everything is in second column bc BRFS format is [adapter suppresor]
                SUPPRESOR &...
                STIM.eyes(:,2) == conditionarray(cond,1) &...
                STIM.tilt(:,2) == conditionarray(cond,2) & ...
                STIM.tiltmatch == conditionarray(cond,3) & ...
                STIM.adapted   == conditionarray(cond,4) & ...  
                STIM.soa       == conditionarray(cond,5) & ...
                STIM.monocular == conditionarray(cond,6) & ...  
                SORTED.contrasts(:,1)  == ContrastComb(cc,1) & ...
                SORTED.contrasts(:,2)  == ContrastComb(cc,2);
        end
            
        trlsLogical(:,cond,cc) = trls;
        CondTrials{cond,cc} = find(trls);
        CondTrialNum_RESP(cond,cc) = sum(trls);           
        % FEATURE SCALING ADDITION -- 3/12/20
        meanOfRESP = nanmean(RESP(trls,:),1);
        maxForDeltaContrast = max(RESP(trls,:));
        minForDeltaContrast = min(RESP(trls,:));
        if sum(trls) == 0
            FeatureScale_y(cond,cc)             = NaN;
            respForTTest(:,cond,cc)             = nan(size(RESP,1),1);            
        else
            FeatureScale_y(cond,cc)             = (meanOfRESP-minForDeltaContrast)./(maxForDeltaContrast-minForDeltaContrast);;
            respForTTest(1:sum(trls),cond,cc)   = RESP(trls,:); 
        end
   end
end

if any(isnan(CondTrialNum_RESP))
    error('all conditions not met')
end





% Simultaneous - 200 or Simultaneous - 800
% feature scaling
    clear FS_deltaY
    FS_deltaY(1,:) = FeatureScale_y(1,:) - FeatureScale_y(3,:); %Congruent Simult - Cong 200
    FS_deltaY(2,:) = FeatureScale_y(2,:) - FeatureScale_y(4,:); %IC Simult - IC 200
    FS_deltaY(3,:) = FeatureScale_y(1,:) - FeatureScale_y(5,:); %Cong Simult - Cong 800
    FS_deltaY(4,:) = FeatureScale_y(2,:) - FeatureScale_y(6,:); %IC Simult - IC 800
    
    
% T-test
    clear TT_deltaY dTT
    TT_deltaY = nan(4,size(dcX,2));
    for dTT = 1:size(dcX,2)
        %Congruent Simult - Cong 200
        [~,~,~,stats] = ttest(respForTTest(:,1,dTT),respForTTest(:,3,dTT));
        TT_deltaY(1,dTT) = stats.tstat;
        %IC Simult - IC 200
        [~,~,~,stats] = ttest(respForTTest(:,2,dTT),respForTTest(:,4,dTT));
        TT_deltaY(2,dTT) = stats.tstat;
        %Cong Simult - Cong 800
        [~,~,~,stats] = ttest(respForTTest(:,1,dTT),respForTTest(:,5,dTT));
        TT_deltaY(3,dTT) = stats.tstat;
        %IC Simult - IC 800
        [~,~,~,stats] = ttest(respForTTest(:,2,dTT),respForTTest(:,6,dTT));
        TT_deltaY(4,dTT) = stats.tstat;
    end
%% Monocular subtraction for controll of interocular transfer
uniqueContrasts = nanunique(SORTED.contrasts);

clear I
 I = ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,goodfiles)...
    & STIM.monocular == 1;

clear uc ep macRESP
macRESP = nan(2,size(uniqueContrasts,1));
for ep = 1:2
    for cc = 1:size(uniqueContrasts,1)
        clear trls    
            trls = I ...
                & SORTED.contrasts(:,ep)  == uniqueContrasts(cc); 
          
        % FEATURE SCALING ADDITION -- 3/12/20
        meanOfRESP = nanmean(RESP(trls,:),1);
        maxForDeltaContrast = max(RESP(trls,:));
        minForDeltaContrast = min(RESP(trls,:));
        if sum(trls) == 0
            macRESP(ep,cc)    = NaN;            
        else
            macRESP(ep,cc)   = nanmean(RESP(trls,:)); 
        end
    end

end

clear cc monocDiffOut
MonocDiffOut = nan(1,size(ContrastComb,1));
for cc = 1:size(ContrastComb,1)
    deIDX = find((ContrastComb(cc,1) == uniqueContrasts));
    ndeIDX = find((ContrastComb(cc,2) == uniqueContrasts));
    DERESP = macRESP(1,deIDX);
    NDERESP = macRESP(2,ndeIDX);
    MonocDiffOut(1,cc) = DERESP - NDERESP;
end


%% SAVE IDX
        % skip if no data
        if ~any([X.oriana X.occana X.diana])
            ErrorCount = ErrorCount+1;
            ERR(ErrorCount).reason = 'diana not run and not caught earlier - investigate';
            ERR(ErrorCount).penetration = STIM.penetration;
            ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
            continue
        end

        % SAVE UNIT INFO!
        uct = uct + 1;
        IDX(uct).penetration = penetration;
        IDX(uct).header = penetration(1:8);
        IDX(uct).monkey = penetration(8);
        IDX(uct).runtime = [date string(now)];

        IDX(uct).depth = STIM.depths(e,:)';
        IDX(uct).kls   = kls;

        
        IDX(uct).X      =   X;
        
        IDX(uct).occana       = X.occana;
        IDX(uct).oriana       = X.oriana;
        IDX(uct).diana        = X.diana;
        IDX(uct).mask         = any(STIM.rsvpmask(STIM.cued ~=0));
        IDX(uct).dicontrast   = stimcontrast';


        IDX(uct).ori   = X.ori';
        IDX(uct).occ   = X.occ';   % how much it prefers one eye over the other
        IDX(uct).bio   = X.bio';        % How much it prefers both eyes over one

        IDX(uct).DE    = DE;
        IDX(uct).PS    = PS;
        IDX(uct).NDE    = NDE;
        IDX(uct).NS    = NS;        
        IDX(uct).dianov     = X.dianp; % p for main effect of each 'eye' 'tilt' 'contrast'

        %%%% NEW ADDITIONS FROM BMC
        IDX(uct).tm        = TM;

        IDX(uct).SDF            = SDF;
        IDX(uct).SDF_fs         = SDF_fs;
        IDX(uct).SDF_zs         = SDF_zs;
        IDX(uct).SDF_pc         = SDF_pc;

        IDX(uct).condition        = condition;
        IDX(uct).CondTrialNum_SDF     = CondTrialNum_SDF;        
        IDX(uct).CondTrialNum_RESP     = CondTrialNum_RESP;        
        
        IDX(uct).STIM               = STIM;

        IDX(uct).ContrastComb      = ContrastComb;
        IDX(uct).MonocDiffOut      = MonocDiffOut;
        IDX(uct).FS_deltaY         = FS_deltaY;
        IDX(uct).TT_deltaY         = TT_deltaY;
        

toc
end
% % % %     end   %%%%% KLS loop removed for now
end


%%

%% SAVE
if flag_saveIDX
    global SAVEDIR
    cd(SAVEDIR)
    if isfile(saveName)
        error('file already exists')        
    end
    save(saveName,'IDX')
    save('ERR','ERR')
else
    warning('IDX not saved')
end

load gong
sound(y,Fs)