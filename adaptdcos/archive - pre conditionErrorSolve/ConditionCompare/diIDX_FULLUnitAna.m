%% diIDX_FULLUnitAna_test1day
% 1) old diIDX code, 
% 2) simplified with Blake's and MAC's new version of diUnitTuning.m,
% 3) SEM calculation fixed ?????
% 4) SDF for all 16 conditions pulled out.


%% Old Code for diIDX_CompareConditions.m
% set up the 4 percent-change and subtraction calculations of the
% Simultaneous - Adapted signals. This matrix should be 4 potential
% windws on just the AUTO signal by their time-windows by the 8
% subtractions.



% Desired output ---> 
%   Pref Ori
%   Null Ori
%   Dom Eye
%   Non-Dom Eye
%   SDF of 4x350 (PSxDE,NSxDE,PSxNDE,NSxNDE) --> This is the 2x2 plot structure 
%   SDF of 8x100 for Transient
%   SDF of 8x100 for Sustained
        % The 8 Dimensions are as follows:
        % A -- Flash of Bi,PS,DE  - Simult Bi,PS (#9  - #5)
        % B -- Flash of Bi,PS,NDE - Simult Bi,PS (#10 - #5)
        % C -- Flash of BI,NS,DE  - Simult BI,NS (#11 - #6)
        % D -- Flash of Bi,NS,NDS - Simult Bi,NS (#12 - #6)
        % E -- Flash of Di,PS,DE  - Simult Di,PStoDE (#13 - #7)
        % F -- Flash of Di,NS,NDE - Simult Di,PStoDE (#14 - #7)
        % G -- Flash of Di,NS,DE  - Simult Di,NStoDE (#15 - #8)
        % H -- Flash of Di,PS,NDE - Simult Di,NStoDE (#16 - #8)


clear

didir = 'C:\Users\Brock\Documents\MATLAB\diSTIM_Sep23\';
list    = dir([didir '*_AUTO.mat']);
flag_saveIDX = 1;
saveName = 'IDX_FULLUnitAna_1600sdf';


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
%%%%%% Use this commented-out script below as a sanity check if needed
% % % adaptor     = STIM.trl(find(STIM.adapted)+1);
% % % suppressor  = STIM.trl(find(STIM.adapted));
% % % test = adaptor ~= suppressor;
% % % sum(test)
STIM.monocular(find(STIM.adapted)+1) = 1;

%%%%% OLD KLS loop started here.
kls = 0;
clear matobj win_ms
if kls == 1
    matobj = matfile([didir penetration '_KLS.mat']);
else
    matobj = matfile([didir penetration '_AUTO.mat']);
end
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
     prefeye = X.dipref(1);
     nulleye = X.dinull(1);
     prefori = X.dipref(2);
     nullori = X.dinull(2);
 


%% pull out your 4x350 SDF matrix of PSvsNPSvsDEvsNDE. 2x2 matrix SDF

if  isnan(prefeye)
    sdftm = matobj.sdftm;
    brfstilts       = nan(1,2);
    TwoByTwoSDF     = nan(4,350);
    TwoByTwoSEM     = nan(4,350);
    monocTrlNum     = nan(1,4);
    monocSDF        = nan(4,length(sdftm));
    monocSEM        = nan(4,length(sdftm));
    monocTrlNum     = nan(4,1);
elseif ~isnan(prefeye)
    clear brfstilts TwoByTwoSDF TwoByTwoSEM monocTrlNum
   
    % Sort based on preference
        clear SORTED
        SORTED.eyes      = STIM.eyes;
        SORTED.contrasts = STIM.contrast;
        SORTED.tilts     = STIM.tilt;
        SORTED.flippedSOA = zeros(size(STIM.tilt));
        
        if prefeye == 2
            [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'ascend');
        else
            [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'descend');
        end
        clear w
        for w = 1:length(SORTED.eyes)
            SORTED.contrasts(w,:) = SORTED.contrasts(w,sortidx(w,:));
            SORTED.tilts(w,:)     = SORTED.tilts(w,sortidx(w,:));
        end; clear w

 


    % Find the two orientations shown during brfs, and which is closest to prefori
    clear I
    I = STIM.ditask...
        & STIM.adapted == 1 ...
        & ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0 ...
        & ismember(STIM.filen,goodfiles);
    brfstilts = nanunique(SORTED.tilts(I,:));
    if ~any(ismember(brfstilts,prefori))
        warning('prefori not shown during brfs session. Must be fixed.')
        disp(strcat('listNum=',num2str(i),'elNum=',num2str(e)))

    end        
        
    % Pull out 2x2 SDF matrix                                                                 
    clear I
    I = ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0 ...
        & ismember(STIM.filen,goodfiles);
    
    clear sdftm monocSDF sdf
    sdf   = squeeze(matobj.SDF(e,:,:)); % load only the channel of interest from matobj
    sdftm =  matobj.sdftm;
    monoccond       = {'PSxDE','NSxDE','PSxNDE','NSxNDE'};
    sdfct           = 0; 
    monocSDF        = nan(4,length(sdftm));
    monocSEM        = nan(4,length(sdftm));
    monocTrlNum     = nan(4,1);


        for monoc = 1:size(monoccond,2)
            clear trls
            switch monoccond{monoc}           % Find the trials you want to look at
                case 'PSxDE'
                    trls = I &...
                        STIM.adapted == 0 & ...
                        SORTED.tilts(:,1) == prefori & ...  
                        SORTED.eyes(:,1) == prefeye & ...   %This line is redundant                              
                        SORTED.contrasts(:,1) >= monocContrast & ...
                        STIM.monocular;  
                case 'NSxDE'
                    trls = I &...
                        STIM.adapted == 0 & ...
                        SORTED.tilts(:,1) == nullori & ...  
                        SORTED.eyes(:,1) == prefeye & ...   %This line is redundant                  
                        SORTED.contrasts(:,1) >= monocContrast & ...
                        STIM.monocular; 
                case 'PSxNDE'
                    trls = I &...
                        STIM.adapted == 0 & ...
                        SORTED.tilts(:,2) == prefori & ...  
                        SORTED.eyes(:,2) == nulleye & ...      %This line is redundant                           
                        SORTED.contrasts(:,2) >= monocContrast & ...
                        STIM.monocular; 
                case 'NSxNDE'
                    trls = I &...
                        STIM.adapted == 0 & ...
                        SORTED.tilts(:,2) == nullori & ...  
                        SORTED.eyes(:,2) == nulleye & ...  %This line is redundant                               
                        SORTED.contrasts(:,2) >= monocContrast & ...
                        STIM.monocular; 
            end
            if sum(trls) >= 5  
                monocSDF(monoc,:)   = nanmean(sdf(:,trls),2); 
                monocSEM(monoc,:)   = (nanstd(sdf(:,trls),[],2))./sqrt(sum(trls));                
            else
                monocSDF(monoc,:)   = nan(size(sdf,1),1);              
                monocSEM(monoc,:)   = nan(size(sdf,1),1);
            end
            monocTrlNum(monoc,:) = sum(trls);
        end  
end

    
%% PULL OUT CONDITION COMPARISION
%   Pref Ori
%   Null Ori
%   Dom Eye
%   Non-Dom Eye
%   SDF of 4x350 (PSxDE,NSxDE,PSxNDE,NSxNDE) --> This is the 2x2 plot structure 
%   SDF of 8x50 for Transient ------- note: seperate variables needed due to mis-match of time window lengths. 
%   SDF of 8x100 for Sustained
%   SDF of 8x200 for Full Window
        % The 8 Dimensions are as follows:
        % A -- Flash of Bi,PS,DE  - Simult Bi,PS (#9  - #5)
        % B -- Flash of Bi,PS,NDE - Simult Bi,PS (#10 - #5)
        % C -- Flash of BI,NS,DE  - Simult BI,NS (#11 - #6)
        % D -- Flash of Bi,NS,NDS - Simult Bi,NS (#12 - #6)
        % E -- Flash of Di,PS,DE  - Simult Di,PStoDE (#13 - #7)
        % F -- Flash of Di,NS,NDE - Simult Di,PStoDE (#14 - #7)
        % G -- Flash of Di,NS,DE  - Simult Di,NStoDE (#15 - #8)
        % H -- Flash of Di,PS,NDE - Simult Di,NStoDE (#16 - #8)
        
%% COMPARE CONDITIONS show DATA PULL STRUCTURE
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

if isnan(prefeye)
    warning('check why this unit doesnt have monoc tuning')
    disp(uct+1)
    sdftm = matobj.sdftm;
end

%%%%%%%%%%%%%%%%% DEV!! SORTED is currently unused. DO I NEED TO USE IT?
 % sort data so that they are [prefeye nulleye]
        clear SORTED
        SORTED.eyes      = STIM.eyes;
        SORTED.contrasts = STIM.contrast;
        SORTED.tilts     = STIM.tilt;
        SORTED.flippedSOA = zeros(size(STIM.tilt));
        
        if prefeye == 2
            [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'ascend');
        else
            [SORTED.eyes,sortidx] = sort(SORTED.eyes,2,'descend');
        end
        clear w
        for w = 1:length(SORTED.eyes)
            SORTED.contrasts(w,:) = SORTED.contrasts(w,sortidx(w,:));
            SORTED.tilts(w,:)     = SORTED.tilts(w,sortidx(w,:));
        end; clear w




condition = table(...
[prefeye   nulleye   prefeye   nulleye   prefeye   nulleye   prefeye   nulleye   prefeye   nulleye   prefeye   nulleye   prefeye   nulleye   prefeye   nulleye  ]',... %eyes1
[prefori   prefori   nullori   nullori   prefori   nullori   nullori   prefori   prefori   prefori   nullori   nullori   prefori   nullori   nullori   prefori  ]',... %tilt1
[1   1   1   1   0   0   0   0   1   1   1   1   0   0   0   0  ]',... %tiltmatch
[0   0   0   0   0   0   0   0   800 800 800 800 800 800 800 800]',... %soa
[0   0   0   0   0   0   0   0   0   0   0   0   0   0   0   0  ]',... %monoc
'VariableNames',{'eyes1','tilt1','tiltmatch','soa','monoc'});
condition.Properties.RowNames = {'5.1','5.2','6.1','6.2','7.1','7.2','8.1','8.2','9','10','11','12','13','14','15','16'};
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
stimcontrast = [contrast_half contrast_max]; % note -- this is flipped from above. This method makes more sense to me.

% Get Trls
clear  trls c win cond SDF CondMeanSDF_uncrop CondMeanSEM_uncrop...
    PercentChangeSDF_uncrop SubtractionSDF_uncrop
CondTrialNum = nan(16,2);
CondTrials = cell(16,2);
SDF  = squeeze(matobj.SDF(e,:,:));
CondMeanSDF_uncrop = nan(size(conditionarray,1),size(SDF,1),2);
CondMeanSEM_uncrop = nan(size(conditionarray,1),size(SDF,1),2);
CondMeanSTD_uncrop = nan(size(conditionarray,1),size(SDF,1),2);
CondMeanResp = nan(16,3,2);
for c = 1:2 %BMC method is contrast_half THEN contrast_max (flipped from MAC code)
    for cond = 1:size(conditionarray,1)
        clear trls   

        %%%%% BMC ADD IN 3 NEW SDF MATRICES. 
            %%%% 1. simultaneous conditions
            
        
        
        
        trls = I &...
            STIM.eyes(:,1) == conditionarray(cond,1) &...
            STIM.tilt(:,1) == conditionarray(cond,2) & ...
            STIM.tiltmatch == conditionarray(cond,3) & ...
            STIM.soa       == conditionarray(cond,4) & ...
            STIM.monocular == conditionarray(cond,5) & ...
            ismember(STIM.contrast,contrasts,'rows');   

        CondTrials{cond,c} = find(trls);
        CondTrialNum(cond,c) = sum(trls); 
        
        % Use trls to pull out continuous data
        CondMeanSDF_uncrop(cond,:,c)   = nanmean(SDF(:,trls),2);
        CondMeanSEM_uncrop(cond,:,c)   = (nanstd(SDF(:,trls),[],2))./sqrt(sum(trls)); 
        CondMeanSTD_uncrop(cond,:,c)   = nanstd(SDF(:,trls),[],2);

        
        % Use trls to pull out response across three binned windows
        for win = 1:3 
            clear RESP 
            RESP = squeeze(matobj.RESP(e,win,:));
            CondMeanResp(cond,win,c) = nanmean(RESP(trls));
        end 
    end
end    


% Get out %Change and subtraction matrices
PercentChangeRESP = nan(8,3,2);
SubtractionRESP = nan(8,3,2);
for win = 1:3  
    for c = 1:2
        for compare = 1:8
            clear x y
            x = CondMeanResp(compare,win,c);
            y = CondMeanResp(compare+8,win,c);
            PercentChangeRESP(compare,win,c) = (x-y)./y;
            SubtractionRESP(compare,win,c) = x-y;
        end
    end
end
  
PercentChangeSDF_uncrop = nan(size(conditionarray,1)/2,size(SDF,1),2);
SubtractionSDF_uncrop = nan(size(conditionarray,1)/2,size(SDF,1),2); 
for c = 1:2
    for compare = 1:8
        clear x y
        x = CondMeanSDF_uncrop(compare,:,c); 
        y = CondMeanSDF_uncrop(compare+8,:,c); 
        PercentChangeSDF_uncrop(compare,:,c) = (x-y)./y;
        SubtractionSDF_uncrop(compare,:,c) = x-y;
    end
end



        % crop / pad SDF
        clear tm pad st en
        tm = sdftm;
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
        pad4rows = repmat(pad,4,1); % pads with NANs if you are not in that condition any more. 
        pad16rows = repmat(pad,16,1); % pads with NANs if you are not in that condition any more. 
        pad8rows = repmat(pad,8,1); % pads with NANs if you are not in that condition any more. 
            clear TwoByTwo monocTM
            TwoByTwoSDF = cat(2,monocSDF(:, st : en), pad4rows); clear monocSDF;
            TwoByTwoSEM = cat(2,monocSEM(:, st : en), pad4rows); clear monocSEM;
            
            CondMeanSDF = cat(2,CondMeanSDF_uncrop(:, st : en,:), pad16rows); clear CondMeanSDF_uncrop;
            CondMeanSEM = cat(2,CondMeanSEM_uncrop(:, st : en,:), pad16rows); clear CondMeanSEM_uncrop;            
            CondMeanSTD = cat(2,CondMeanSTD_uncrop(:, st : en,:), pad16rows); clear CondMeanSTD_uncrop;
            PercentChangeSDF = cat(2,PercentChangeSDF_uncrop(:, st : en,:), pad8rows); clear PercentChangeSDF_uncrop;            
            SubtractionSDF = cat(2,SubtractionSDF_uncrop(:, st : en,:), pad8rows); clear SubtractionSDF_uncrop;            
            

            if size(TwoByTwoSDF,2) ~= length(tm)
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
        IDX(uct).runtime = now;

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

        IDX(uct).prefeye    = prefeye;
        IDX(uct).prefori    = prefori;
        IDX(uct).nulleye    = nulleye;
        IDX(uct).nullori    = nullori;        
        IDX(uct).dianov     = X.dianp; % p for main effect of each 'eye' 'tilt' 'contrast'

        %%%% NEW ADDITIONS FROM BMC
        IDX(uct).tm        = TM;
        
        IDX(uct).brfstilts = brfstilts;
        
        IDX(uct).monocContrast      = monocContrast;
        IDX(uct).monocSDF           = TwoByTwoSDF;
        IDX(uct).monocSEM           = TwoByTwoSEM;
        IDX(uct).monocTrlNum        = monocTrlNum;
        
        IDX(uct).condition          = condition;
        IDX(uct).PercentChange      = PercentChangeRESP;
        IDX(uct).Subtraction        = SubtractionRESP;
        IDX(uct).CondTrialNum       = CondTrialNum;
        
        IDX(uct).CondMeanSDF        = CondMeanSDF;
        IDX(uct).CondMeanSEM        = CondMeanSEM;
        IDX(uct).CondMeanSTD        = CondMeanSTD;              
        IDX(uct).PercentChangeSDF	= PercentChangeSDF;
        IDX(uct).SubtractionSDF     = SubtractionSDF;
        
        IDX(uct).STIM               = STIM;
        IDX(uct).SORTED             = SORTED;
        
 



toc
    end
% % % %     end   %%%%% KLS loop removed for now
end


%%

%% SAVE
if flag_saveIDX
    cd('C:\Users\Brock\Documents\adaptdcos figs')
    if isfile(saveName)
        error('file already exists')        
    end
    save(saveName,'IDX')
else
    warning('IDX not saved')
end

load gong
sound(y,Fs)