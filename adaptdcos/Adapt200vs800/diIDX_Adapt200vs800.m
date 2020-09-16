%% diIDX_Adapt200vs800
% taken from diIDX_EffectOfAdap


%Fig 1.
% 200ms in subplot 1. 800ms in subplot 2. 4 lines on each plot.
% BinocSimultCongruentPS, BinocSimultIncongPS, AdaptCongPSflash,
% AdaptICPSflash

% 1 export matrix with all 3 datatypes
% 1 - simult
%   a. Cong Simult
%   b. IC   Simult
% 2 - 200ms
%   c. Cong 200
%   d. IC   200
% 3 - 800ms
%   e. Cong 800
%   f. IC   800


clear

didir = 'C:\Users\Brock\Documents\MATLAB\diSTIM_Sep23\';
list    = dir([didir '*_AUTO.mat']);
flag_saveIDX    = 1;
normalize       = 1;
saveName = 'diIDX_Adapt200vs800_PS-subX-featureScaleNormY';

kls = 0;

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

%%% ALLOW BRFS ADAPTORS TO BE TAKEN INTO MONOCULAR TRIALS
clear ADAPTER SUPPRESOR
ADAPTER = false(size(STIM.adapted));
ADAPTER(find(STIM.adapted)+1) = true;
SUPPRESOR  = STIM.adapted;
STIM.monocular(find(STIM.adapted)+1) = 1;

clear matobj win_ms
matobj = matfile([didir penetration '_AUTO.mat']);

win_ms = matobj.win_ms;
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

    clear *RESP* *SDF* sdf sdftm X M TRLS SUB 
    RESP = squeeze(matobj.RESP(e,respDimension,:));

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
    
%% Conditions established to pull out SDFs
   % loop through different resp windows based on win_ms;
if ~isequal(win_ms(1,:),[50 100])
    error('RESP dimension issue')
end
if ~all(STIM.contrast(find(STIM.adapted)+1,1) ==...
        STIM.contrast(find(STIM.adapted),1) & ...
        STIM.tilt(find(STIM.adapted)+1,1) ==...
        STIM.tilt(find(STIM.adapted),1)) & ...
        STIM.monocular(find(STIM.adapted)+1,1) ~= 1
    error({'The following needs to be true: STIM.eyes(:,1) == 1st stimulus on,'...
        'adaptor STIM.eyes(:,2) == 2nd stimulus on, supressor,'...
        'AND adaptor must be set to monocular'})
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
clear  cond *SDF* sdf trlsLogical
CondTrialNum = nan(size(condition,1),1);
CondTrials = cell(size(condition,1),1);
sdf  = squeeze(matobj.SDF(e,:,:));
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
        CondTrialNum(cond,1) = sum(trls); 
        SDF_uncrop(cond,:)   = nanmean(sdf(:,trls),2);    % Use trls to pull out continuous data     
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
        (STIM.contrast(:,1)  >= .3 & STIM.contrast(:,1) <= .5) &...
        (STIM.contrast(:,2)  >= .3 & STIM.contrast(:,2) <= .5); 
    trlsLogical(:,cond) = trls;
    CondTrials{cond} = find(trls);
    CondTrialNum(cond,1) = sum(trls); 
    SDF_uncrop(cond,:)   = nanmean(sdf(:,trls),2);    % Use trls to pull out continuous data    
    end
    
end

if any(isnan(CondTrialNum))
    error('all conditions not met')
end



%% crop/pad SDF
        % crop / pad SDF    %%%%DEV_BMC: LATER - concatenate HERE
        clear tm pad st en
        tm = matobj.sdftm;
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
if normalize == 1
    % Max taken from binoc simult DExPS max response
    maxSDF = max(SDF(1,:));
   	% Get min response (avg of baseline period)
    if isequal(win_ms(4,:),[-50 0])
        blDimension = 4;
    else
        error('RESP dimension issue')
    end
    baselineAll = squeeze(matobj.RESP(e,blDimension,:));
    BiDExPStrls = CondTrials{1};    
    baselineDExPS = baselineAll(BiDExPStrls);
    blAvg       = nanmean(baselineDExPS);
    
    % Normalize with "feature scaling" formula
    % Xnorm = (dat-Xmin)./(Xmax-Xmin)
    SDF = (SDF-blAvg)./(maxSDF-blAvg);
end

%% Pull out Cong or IC scatterplots
deltaContrast = SORTED.contrasts(:,1) - SORTED.contrasts(:,2); %DE - NDE
uniqueDeltaContrast = nanunique(deltaContrast);

% RESULTofRESP is (6 x 27[variable] ) which is (conditions x unique contrast differences NDE-DE)
clear i h 
RespOfTrls = nan(size(RESP,1),length(uniqueDeltaContrast));
for h = 1:6
    for i = 1:length(uniqueDeltaContrast)
        clear trls
        trls = (trlsLogical(:,h)) & (deltaContrast == uniqueDeltaContrast(i));
        RespOfTrls(1:sum(trls),i) = RESP(trls,:);
    end
    % FEATURE SCALING ADDITION -- 3/12/20
    meanOfRESP = nanmean(RespOfTrls,1);
    maxForDeltaContrast = max(RespOfTrls);
    minForDeltaContrast = min(RespOfTrls);
    RESULTofRESP(h,:) = (meanOfRESP-minForDeltaContrast)./(maxForDeltaContrast-minForDeltaContrast);
end

clear a b nodc x y
for a = 1:6
       nodc = 0; %number of displayed contrasts
   for b = 1:length(uniqueDeltaContrast)
       if ~isnan(RESULTofRESP(a,b))
          nodc = nodc+1;
          x(a,nodc) = uniqueDeltaContrast(b);
          y(a,nodc) = RESULTofRESP(a,b);          
       end
   end
end



if exist('x','var')
    x = x(1:4,:);
    % Calculate deltaAdaptation - conduct the adaptation subtraction here.
    % Simultaneous - 200 or Simultaneous - 800
    clear deltaY
    deltaY(1,:) = y(1,:) - y(3,:); %Congruent Simult - Cong 200
    deltaY(2,:) = y(2,:) - y(4,:); %IC Simult - IC 200
    deltaY(3,:) = y(1,:) - y(5,:); %Cong Simult - Cong 800
    deltaY(4,:) = y(2,:) - y(6,:); %IC Simult - IC 800
else
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'RESP exists but not for deltaContrast? examine if a lot of units are lost';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    continue
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

        IDX(uct).condition        = condition;
        IDX(uct).CondTrialNum     = CondTrialNum;        
        
        IDX(uct).STIM               = STIM;

        IDX(uct).x              = x;
        IDX(uct).deltaY         = deltaY;
        

toc
end
% % % %     end   %%%%% KLS loop removed for now
end


%%

%% SAVE
if flag_saveIDX
    cd('C:\Users\Brock\Documents\MATLAB\diIDXdirectory')
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