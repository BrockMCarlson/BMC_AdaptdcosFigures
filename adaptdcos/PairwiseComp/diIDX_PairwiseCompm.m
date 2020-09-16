%% diIDX_PairwiseComp


% 1600 ms from adapter onset to see if NDE reponse truly is abolished.


clear

didir = 'C:\Users\Brock\Documents\MATLAB\diSTIM_Sep23\';
list    = dir([didir '*_AUTO.mat']);
flag_saveIDX    = 1;
normalize       = 0;
saveName = 'diIDX_PairwiseComp-notnorm';

kls = 0;


sdfwinAS  = [-0.05  .9];
sdfwinCat = [-0.05 1.6];
Fs = 1000;

clear IDX
uct = 0;

%% For loop on unit
for i = 1:length(list)


%% load session data
clear penetration
penetration = list(i).name(1:11); 

if (strcmp(penetration,'160108_E_eD')) || (strcmp(penetration,'161005_E_eB'))
else
    continue
end

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
%% Set monocular contrast levels
%%%%% BLAKE DELETE THIS OR USE TO SET SESSION SPECIFIC VARS
clear monocContrast
if ismember(penetration,{'151221_E_eD','151222_E_eD','151231_E_eD','160211_I_eD','160215_I_eD'})
    monocContrast = 1;
elseif ismember(penetration,{'160427_E_eD','160510_E_eD','160523_E_eD','161005_E_eB'})
    monocContrast = .9;
elseif ismember(penetration,{'160102_E_eD','160104_E_eD','160108_E_eD','160111_E_eD'})
    monocContrast = .8;        
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
            continue
        elseif ~isequal(goodfiles,allfiles)...
                && length(goodfiles)>1 ...
                && any(diff(goodfiles) > 1)
            goodfiles = unique(STIM.filen(ismember(STIM.filen, goodfiles) & STIM.ditask));
        end
    end
    if any(diff(goodfiles) > 1)
        %error('check goodfiles')
        continue %DEV: need to figure out a way to slavage
    end

        
%% Di Unit Tuning
     X = diUnitTuning(RESP,STIM,goodfiles);
     DE = X.dipref(1);
     NDE = X.dinull(1);
     PS = X.dipref(2);
     NS = X.dinull(2);
 
    
%% PULL OUT ADAPTER SDF
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
    warning('check why this unit doesnt have monoc tuning')
    disp(uct+1)
end




conditionA = table(...
[DE   NDE   DE   NDE   DE   NDE   DE   NDE]',... %eyes1
[PS   PS    NS   NS    PS   PS    NS   NS]',... %tilt1
[1   1   1   1   0   0   0   0]',... %tiltmatch
[0   0   0   0   0   0   0   0]',... %soa
[1   1   1   1   1   1   1   1]',... %monoc
'VariableNames',{'eyes1','tilt1','tiltmatch','soa','monoc'});
conditionA.Properties.RowNames = {...
    'adpDExPS_flC',...
    'adpNDExPS_flC',...
    'adpDExNS_flC',...
    'adpNDExNS_flC',...
    'adpDExPS_flIC',...
    'adpNDExPS_flIC',...
    'adpDExNS_flIC',...
    'adpNDExNS_flIC',...
    };
conditionarrayA = table2array(conditionA);

conditionS = table(...
[NDE DE  NDE DE  NDE DE  NDE DE]',... %eyes1
[PS  PS  NS  NS  NS  NS  PS  PS]',... %tilt1
[1   1   1   1   0   0   0   0]',... %tiltmatch
[800 800 800 800 800 800 800 800]',... %soa
[0   0   0   0   0   0   0   0]',... %monoc
'VariableNames',{'eyes1','tilt1','tiltmatch','soa','monoc'});
conditionS.Properties.RowNames = {...
    'adpC_flNDExPS',...
    'adpC_flDExPS',...
    'adpC_flNDExNS',...
    'adpC_flDExNS',...
    'adpIC_flNDExNS',...
    'adpIC_flDExNS',...
    'adpIC_flNDExPS',...
    'adpIC_flDExPS_flIC',...
    };
conditionarrayS = table2array(conditionS);


clear I
I = STIM.ditask...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,goodfiles);



% determin main contrasts levels
clear uContrast contrast_*
uContrast = unique(STIM.contrast(I,:));
uContrast(uContrast==0) = [];
contrast_max = max(uContrast);
[~,idx] = min(abs(uContrast - contrast_max/2));
contrast_half   = uContrast(idx);
stimcontrast = [contrast_half contrast_max]; % note -- this is flipped from MAC's method of [max half]. This method makes more sense to me.

% Get Trls
clear  cond *SDF* sdf
CondTrialNumA = nan(8,1);
CondTrialNumS = nan(8,1);
CondTrialsA = cell(8,1);
CondTrialsS = cell(8,1);
sdf  = squeeze(matobj.SDF(e,:,:));
SDF_uncropA = nan(size(conditionarrayA,1),size(sdf,1));
SDF_uncropS = nan(size(conditionarrayS,1),size(sdf,1));

for cond = 1:size(conditionarrayA,1)
    clear trlsA trlsS   
    
    % get suppressor trials
    trlsS = I &... %everything is in second column bc BRFS format is [adapter suppresor]
        SUPPRESOR &...
        STIM.eyes(:,2) == conditionarrayS(cond,1) &...
        STIM.tilt(:,2) == conditionarrayS(cond,2) & ...
        STIM.tiltmatch == conditionarrayS(cond,3) & ...
        STIM.soa       == conditionarrayS(cond,4) & ...
        STIM.monocular == conditionarrayS(cond,5) & ...
        (STIM.contrast(:,1)  >= .3 & STIM.contrast(:,1) <= .5) &...
        (STIM.contrast(:,2)  >= .3 & STIM.contrast(:,2) <= .5);   
    CondTrialsS{cond} = find(trlsS);
    CondTrialNumS(cond,1) = sum(trlsS); 
    SDF_uncropS(cond,:)   = nanmean(sdf(:,trlsS),2);    % Use trls to pull out continuous data 
    
    % get adapter trials
    trlsA = false(size(trlsS));
    trlsA(find(trlsS)+1) = true;   
    CondTrialsA{cond} = find(trlsA);
    CondTrialNumA(cond,1) = sum(trlsA); 
    SDF_uncropA(cond,:)   = nanmean(sdf(:,trlsA),2);    % Use trls to pull out continuous data 
    
    %Double-check that adapter and suppresor are from same trials
    reportAdapter = STIM.trl(trlsA,:);
    reportSuppresor = STIM.trl(trlsS,:);
    if ~isequal(reportAdapter,reportSuppresor)
        error('Adapter and Suppresor must be from same trials')
    end
    
end

%% Pull out 2x2 SDF

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
    
     % Get max monocular response
    clear I
    I = ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0 ...
        & STIM.monocular...
        & ismember(STIM.filen,goodfiles);
    
    % preallocate
    monoccond = {'DExPS','NDExPS','DExNS','NDExNS'};
    SDF_monoc_uncrop = nan(size(monoccond,2),size(sdf,1));
    CI_monoc_uncrop = nan(size(monoccond,2),size(sdf,1));
    % monocular loop
    clear m trlsM
    for m = 1:4
       switch monoccond{m}
           case 'DExPS'
               trlsM = I...
                & (SORTED.contrasts(:,1)  >= .3 & SORTED.contrasts(:,1) <= .5)...    
                & SORTED.tilts(:,1) == PS;
           case 'NDExPS'
               trlsM = I...
                & (SORTED.contrasts(:,2)  >= .3 & SORTED.contrasts(:,2) <= .5)...    
                & SORTED.tilts(:,2) == PS;
           case 'DExNS'
               trlsM = I...
                & (SORTED.contrasts(:,1)  >= .3 & SORTED.contrasts(:,1) <= .5)...    
                & SORTED.tilts(:,1) == NS;
           case 'NDExNS'
               trlsM = I...
                & (SORTED.contrasts(:,2)  >= .3 & SORTED.contrasts(:,2) <= .5)...    
                & SORTED.tilts(:,2) == NS;
       end
        SDF_monoc_uncrop(m,:)   = nanmean(sdf(:,trlsM),2);
        SEM = std(sdf(:,trlsM),[],2)/sqrt(sum(trlsM));	% Standard Error
        ts = tinv(0.99,sum(trlsM)-1);                   % T-Score at the 99th percentile
        CI_monoc_uncrop(m,:) = nanmean(sdf(:,trlsM),2) + ts*SEM;        
    end
        




%% crop/pad SDF
        % crop / pad SDF    %%%%DEV_BMC: LATER - concatenate HERE
        clear tm pad st en
        tm = matobj.sdftm;
        if tm(end) < sdfwinAS(2)  
            pad = [tm(end):diff(tm(1:2)):sdfwinAS(2)];
            pad(1) = [];
            en = length(tm);
            st = find(tm> sdfwinAS(1),1);
            tm = [tm pad];
            tm = tm(st : end);
            pad(:) = NaN;
        else
            pad = [];
            en = find(tm > sdfwinAS(2),1)-1;
            st = find(tm > sdfwinAS(1),1);
            tm = tm(st : en);
        end
        if isnan(pad)
            warning('this might not be set up to properly pad the contrast dimension')
        end
        pad4rows = repmat(pad,4,1); % pads with NANs if you are not in that condition any more. 
        pad8rows = repmat(pad,8,1); % pads with NANs if you are not in that condition any more. 
            clear SDF_A SDF_S

            SDF_A = cat(2,SDF_uncropA(:, st : en,:), pad8rows); clear SDF_uncropA;                  
            SDF_S = cat(2,SDF_uncropS(:, st : en,:), pad8rows); clear SDF_uncropS;                  

            SDF_monoc       = cat(2,SDF_monoc_uncrop(:, st : en,:), pad4rows); clear SDF_monoc_uncrop; 
            
            if size(SDF_A,2) ~= length(tm)
                error('check tm')
            end
            TM = tm;

            
%% Normalize
if normalize == 1

    maxMonoc = max(max(SDF_monoc));
    
   
	% Get min response (from anything?? From min monoc transient? From
	% baseline period???
    minMonoc = min(min(SDF_monoc));
    
    % Normalize with "feature scaling" formula
    % Xnorm = (dat-Xmin)./(Xmax-Xmin)
    SDF_A = (SDF_A-minMonoc)./(maxMonoc-minMonoc);
    SDF_S = (SDF_S-minMonoc)./(maxMonoc-minMonoc);
    
    SDF_monoc = (SDF_monoc-minMonoc)./(maxMonoc-minMonoc);
    


end

%% SAVE IDX
        % skip if no data
        if ~any([X.oriana X.occana X.diana])
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
        
        

        
        IDX(uct).conditionA         = conditionA;
        IDX(uct).CondTrialNumA      = CondTrialNumA;        
        IDX(uct).SDF_A              = SDF_A;

        IDX(uct).conditionS         = conditionA;
        IDX(uct).CondTrialNumS      = CondTrialNumS;        
        IDX(uct).SDF_S              = SDF_S;        
        
        IDX(uct).STIM               = STIM;
        

toc
    end
% % % %     end   %%%%% KLS loop removed for now
end


%%

%% SAVE
if flag_saveIDX
    cd('C:\Users\Brock\Documents\MATLAB\GitHub\ephys-analysis\dichoptic\adaptdcos\PairwiseComp')
    if isfile(saveName)
        error('file already exists')        
    end
    save(saveName,'IDX')
else
    warning('IDX not saved')
end

load gong
sound(y,Fs)