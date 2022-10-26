function IDX = IDX_iScienceSubmission_findTimingOffsets

%% load session data
global STIMDIR
cd(STIMDIR)



didir = strcat(STIMDIR,'\');
saveName = 'IDX_iScienceSubmission_highContrast.mat'; % THIS IS CONTRAST LEVELS OF .41-.75 INCLUSIVE
anaType = '_AUTO.mat';
flag_saveIDX    = true;

kls = 0;
list    = dir([didir '*' anaType]);

sdfwin  = [-0.05  .9];

clear holder IDX
SupraCount = 0;
GranularCount = 0;
InfraCount = 0;
count = 0;
ErrorCount = 0;
noBrfs = 0;
yesBrfs = 0;
paradigm = cell(32,8);
%% For loop on unit
for i = 1:length(list)

%% load session data
clear penetration
penetration = list(i).name(1:11); 


clear STIM nel difiles
load([didir penetration '.mat'],'STIM')
for j = 1:length(STIM.paradigm)
    paradigm(i,j)= STIM.paradigm(j)';
end


% Balance conditions
if ~any(contains(STIM.paradigm,'brfs'))
   warning('no brfs on day...')
   disp(penetration)
   noBrfs = noBrfs + 1;
   MISSING(noBrfs,:) = penetration;
   error('there was a continue here')
else
    yesBrfs = yesBrfs+1;
    FOUND(yesBrfs,:) = penetration;
end


nel = length(STIM.el_labels);

difiles = unique(STIM.filen(STIM.ditask));



clear matobj matobj win_ms
matobj = matfile([didir penetration anaType]);
if contains(anaType,'CSD') || contains(anaType,'AUTO')
    youAreGood = true;
else
    matobj= matfile([didir penetration anaType]);
end

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
    disp(strcat(penetration,'/ / contact =_ ',num2str(e)))
    
   

    clear respFullTM resp sdf sdftm X M TRLS SUB 
    respFullTM = squeeze(matobj.RESP(e,respDimension,:));

    % get "goodfiles" for each cluster
    % i.e., the files over which the cluster is present
    % pref for ditasks if there are more than 1 set of clusters at depth
    % DEV:  should be able to scrape more from
    %       STIM.rclusters, and non-used STIM.clusters
    clear goodfiles allfiles
    goodfiles = 1:length(STIM.filelist);
    
   
        
%% Di Unit Tuning -- RESP is always from AUTO
     X = diUnitTuning(respFullTM,STIM,goodfiles);
     DE = X.dipref(1);
     NDE = X.dinull(1);
     PS = X.dipref(2);
     NS = X.dinull(2);
     
     
 
%% Set limits on acceptable tuning.
% Unit must be tuned to eye and orientation to be included in analysis
if X.diana ~= 1
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'dichoptic analysis not run on unit';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    warning('diana not run on unit')
    continue
end

% X.diann   = {'eye','tilt','contrast'};
if X.dianp(1) > 0.05
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'unit not tuned to eye';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    warning('Unit not tuned to eye')
    continue
end
if X.dianp(2) > 0.05
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'unit not tuned to ori';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    warning('Unit not tuned to ori')
    continue
end
% We are not worried about being tuned to contrast - re: Blake Mitchell


    
%% Conditions established to pull out SDFs
   % loop through different resp windows based on win_ms;
if ~isequal(win_ms(1,:),[50 150])
    error('RESP dimension issue')
end

if isnan(DE)
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'check why this unit doesnt have monoc tuning considering previous catch';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    warning('check why this unit doesnt have monoc tuning considering previous catch')
    continue
end


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


%% Z-score normalize the data
sdf  = squeeze(matobj.SDF(e,:,:));
resp = squeeze(matobj.RESP(e,:,:));

if isequal(win_ms(4,:),[-50 0])
    blDimension = 4;
else
    error('RESP dimension issue. fix by programatically finding where the window is.')
end    
baselineOfOnsetsOnly = resp(blDimension,~STIM.suppressor);
blAvg = nanmean(baselineOfOnsetsOnly);
blStd = nanstd(baselineOfOnsetsOnly);
SDF_Zscore = (sdf- blAvg) ./ blStd;
RESP_Zscore = (resp - blAvg) ./ blStd;


%% Pull out conditions of interest

clear I
I = STIM.ditask...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0; 



% We need to get rid of the "condition" loop.
% But I have no fucking idea how to do that...
clear trls    
% get monocular trials
  trls_monoc = I &...
        STIM.eye        == DE &...
        STIM.tilt(:,1)  == PS & ...
        STIM.tiltmatch  == 1  & ...
        STIM.adapter    == 0  & ...  
        STIM.suppressor == 0  & ...
        STIM.soa        == 0  & ...
        STIM.monocular  == 1  & ...
        (STIM.contrast(:,1)  >= .8);

 % get simultaneous trials
    trls_dCOS = I &...
        SORTED.tilts(:,1)   == PS & ... %we want the prefered stimulus in the dominant eye
        STIM.tiltmatch      == 0 & ...
        STIM.adapter        == 0 & ...  
        STIM.suppressor     == 0 & ...
        STIM.soa            == 0 & ...
        STIM.monocular      == 0 & ...
        (SORTED.contrasts(:,1)  >= .8) &...
        (SORTED.contrasts(:,2)  >= .8); 

 
trlsLogical(:,cond) = trls;
CondTrials{cond} = find(trls);
CondTrialNum(cond,1) = sum(trls); 
SDF_uncrop{cond}   = SDF_Zscore(:,trls); 
RESP_alltrls{cond}        = RESP_Zscore(:,trls);






%% crop/pad SDF
% crop / pad SDF    
% Pad works for MUA but not for LFP requires trial averaging...
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
%         warning('no data in this condition')
%         disp(strcat(penetration,'/ / contact =_ ',num2str(e)))
        continue
    else
        data_crop = data(st:en,:);
    end
    SDF_crop{cond} = data_crop;
end




%% Get avg results and cumsum
SDF_avg     = cell(size(condition,1),1);
SDF_cumsum 	= cell(size(condition,1),1);
RESP_avg    = cell(size(condition,1),1);
clear cond
for cond = 1:size(conditionarray,1)
    sdfholder = SDF_crop{cond};
    SDF_avg{cond} = mean(SDF_crop{cond},2);
    SDF_cumsum{cond} = mean(cumsum(sdfholder),2); %get the cumulative sum for each trial, average over all trials, ouput is trial-averaged cumulative sum for each condition.
    RESP_avg{cond}= mean(RESP_alltrls{cond},2);
end
        

%% SAVE  IDX



        % SAVE UNIT INFO!
        clear holder
        holder.penetration = penetration;
        holder.header = penetration(1:8);
        holder.monkey = penetration(8);
        holder.runtime = [date string(now)];

        holder.depth = STIM.depths(e,:)';

        holder.dicontrast   = stimcontrast';
        
        %Anove tuning from diUnitTuning
        holder.DE    = DE;
        holder.PS    = PS;
        holder.NDE    = NDE;
        holder.NS    = NS; 
        holder.X    = X; % This should get you all the tuning info
        holder.occ  = X.occ(3);
        
        % Condition info
        holder.CondTrials = CondTrials;
        holder.condition        = condition;
        holder.CondTrialNum     = CondTrialNum;        

        % Continuous data info
        holder.TM           = TM;
        holder.SDF_crop     = SDF_crop;
        holder.SDF_avg      = SDF_avg;
        holder.SDF_cumsum   = SDF_cumsum;  %get the cumulative sum for each trial, average over all trials, ouput is trial-averaged cumulative sum for each condition.

        % Time-win binned info;
        holder.win_ms           = win_ms;
        holder.RESP_alltrls     = RESP_alltrls;
        holder.RESP_avg         = RESP_avg;
        
        
        %Save the STIM - in case you ever need to troubleshoot what the
        %selections are for each trial. Access from CondTrials
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


end


%%

%% SAVE
if flag_saveIDX
    global IDXDIR
    cd(IDXDIR)
%     if isfile(strcat(saveName,'.mat'))
%         error('file already exists')        
%     end
    save(saveName,'IDX','ERR')
else
    warning('IDX not saved')
end



load gong
sound(y,Fs)







end