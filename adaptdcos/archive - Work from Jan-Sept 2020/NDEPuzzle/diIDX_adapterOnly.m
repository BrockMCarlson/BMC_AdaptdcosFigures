%% diIDX_adapterOnly

% 1600 ms from adapter onset to see if NDE reponse truly is abolished.


clear

didir = 'C:\Users\Brock\Documents\MATLAB\diSTIM_Sep23\';
list    = dir([didir '*_AUTO.mat']);
flag_saveIDX = 1;
saveName = 'diIDX_adapterOnly';

kls = 0;


sdfwin  = [-0.05 1.6]; %s
Fs = 1000;

clear IDX
uct = 0;

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




condition = table(...
[DE   NDE   DE   NDE   DE   NDE   DE   NDE]',... %eyes1
[PS   PS    NS   NS    PS   PS    NS   NS]',... %tilt1
[1   1   1   1   0   0   0   0]',... %tiltmatch
[0   0   0   0   0   0   0   0]',... %soa
[1   1   1   1   1   1   1   1]',... %monoc
'VariableNames',{'eyes1','tilt1','tiltmatch','soa','monoc'});
condition.Properties.RowNames = {...
    'adpDExPS_flC',...
    'adpNDExPS_flC',...
    'adpDExNS_flC',...
    'adpNDExNS_flC',...
    'adpDExPS_flIC',...
    'adpNDExPS_flIC',...
    'adpDExNS_flIC',...
    'adpNDExNS_flIC',...
    };
conditionarray = table2array(condition);

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
clear  trls c win cond SDF CondMeanSDF_uncrop CondMeanSEM_uncrop...
    PercentChangeSDF_uncrop SubtractionSDF_uncrop
CondTrialNum = nan(8,1);
CondTrials = cell(8,1);
sdf  = squeeze(matobj.SDF(e,:,:));
SDF_uncrop = nan(size(conditionarray,1),size(sdf,1));

for cond = 1:size(conditionarray,1)
    clear trls   

    trls = I &... %everything is in first column bc BRFS format is [adapter suppresor]
        ADAPTER &...
        STIM.eyes(:,1) == conditionarray(cond,1) &...
        STIM.tilt(:,1) == conditionarray(cond,2) & ...
        STIM.tiltmatch == conditionarray(cond,3) & ...
        STIM.soa       == conditionarray(cond,4) & ...
        STIM.monocular == conditionarray(cond,5) & ...
        STIM.contrast(:,1)  == contrast_half;   

    CondTrials{cond} = find(trls);
    CondTrialNum(cond,1) = sum(trls); 

    % Use trls to pull out continuous data
    SDF_uncrop(cond,:)   = nanmean(sdf(:,trls),2);




end


        % crop / pad SDF
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
        pad8rows = repmat(pad,8,1); % pads with NANs if you are not in that condition any more. 
            clear TwoByTwo monocTM

            SDF = cat(2,SDF_uncrop(:, st : en,:), pad8rows); clear SDF_uncrop;                  

            if size(SDF,2) ~= length(tm)
                error('check tm')
            end
            TM = tm;

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
        
        

        
        IDX(uct).condition          = condition;
        IDX(uct).CondTrialNum       = CondTrialNum;
        
        IDX(uct).CondMeanSDF        = SDF;

        
        IDX(uct).STIM               = STIM;
        

toc
    end
% % % %     end   %%%%% KLS loop removed for now
end


%%

%% SAVE
if flag_saveIDX
    cd('C:\Users\Brock\Documents\MATLAB\GitHub\ephys-analysis\dichoptic\adaptdcos\NDEPuzzle')
    if isfile(saveName)
        error('file already exists')        
    end
    save(saveName,'IDX')
else
    warning('IDX not saved')
end

load gong
sound(y,Fs)