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

didir = 'G:\LaCie\diSTIM_Sep23\';
list    = dir([didir '161005_E_eB' '*_AUTO.mat']);
flag_saveIDX = 1;
saveName = 'IDX_2x2ANDCC';


sdfwin  = [-0.05 0.3]; %s
statwin = [0.15 0.25; .05 .10]; %s
Fs = 1000;

clear IDX
uct = 0;

%% For loop on unit
% % % for i = 1:length(list)
i = 1;

%% load session data
clear penetration
penetration = list(i).name(1:11); 

clear STIM nel difiles
load([didir penetration '.mat'],'STIM')
nel = length(STIM.el_labels);
difiles = unique(STIM.filen(STIM.ditask));


% % % % % % % %     for kls = 0:1 %%%%KLS Loop removed for now.
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
    brfstilts       = nan(1,2);
    TwoByTwoSDF     = nan(4,350);
    TwoByTwoSEM     = nan(4,350);
    monocTrlNum     = nan(1,4);
elseif ~isnan(prefeye)
    clear brfstilts TwoByTwoSDF TwoByTwoSEM monocTrlNum
   
    % Sort based on preference
        clear eyes sortidx contrasts tilts
        eyes      = STIM.eyes;
        contrasts = STIM.contrast;
        tilts     = STIM.tilt;
        if prefeye == 2
            [eyes,sortidx] = sort(eyes,2,'ascend');
        else
            [eyes,sortidx] = sort(eyes,2,'descend');
        end
        for w = 1:length(eyes)
            contrasts(w,:) = contrasts(w,sortidx(w,:)); % sort contrasts in dominant eye and non-dominant eye
            tilts(w,:)     = tilts(w,sortidx(w,:));
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
    brfstilts = nanunique(tilts(I,:));
    if ~any(ismember(brfstilts,prefori))
        warning('prefori not shown during brfs session. Must be fixed.')
        disp(strcat('listNum=',num2str(i),'elNum=',num2str(e)))

    end

    % determin main contrasts levels
    clear I
    I = STIM.ditask...
        & STIM.adapted == 0 ...
        & ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0 ...
        & ismember(STIM.filen,goodfiles);
    
    
        clear uContrast contrast_*
        uContrast = unique(STIM.contrast(I,:));
        uContrast(uContrast==0) = [];
        contrast_max = max(uContrast);
        [~,idx] = min(abs(uContrast - contrast_max/2));
        contrast_half   = uContrast(idx);
        
        
        
    % Pull out 2x2 SDF matrix                                                                 
    % analyze by DI condition
        clear sdftm monocSDF sdf
        sdf   = squeeze(matobj.SDF(e,:,:)); % load only the channel of interest from matobj
        sdftm =  matobj.sdftm;
        monoccond       = {'PSxDE','NSxDE','PSxNDE','NSxNDE'};
        sdfct           = 0; 
        monocSDF        = nan(4,length(sdftm));
        monocSEM        = nan(4,length(sdftm));
        monocTrlNum     = nan(4,1);

        nullori = setdiff(brfstilts,prefori);
        nulleye = nanunique(setdiff(eyes,prefeye)); 

            for monoc = 1:size(monoccond,2)
                clear trls
                switch monoccond{monoc}           % Find the trials you want to look at
                    case 'PSxDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == prefori & ...  
                            STIM.eye == prefeye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
                            STIM.monocular;  
                    case 'NSxDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == nullori & ...  
                            STIM.eye == prefeye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
                            STIM.monocular; 
                    case 'PSxNDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == prefori & ...  
                            STIM.eye == nulleye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
                            STIM.monocular; 
                    case 'NSxNDE'
                        trls = I &...
                            STIM.adapted == 0 & ...
                            STIM.tilt(:,1) == nullori & ...  
                            STIM.eye == nulleye & ...                     
                            STIM.contrast(:,1) == contrast_max & ...
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


                            % crop / pad SDF
                    clear tm pad st en
                    tm = sdftm;
                    if tm(end) < sdfwin(2)   % Make sure the SDF is the same across all of the sessions. I may want to change this. change sdfwin to be -100 to 800 ??? 
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
                    padSDF = repmat(pad,size(monocSDF,1),1); % pads with NANs if you are not in that condition any more. 
                    padSEM = repmat(pad,size(monocSEM,1),1);
                        clear TwoByTwo nTM
                        TwoByTwoSDF = cat(2,monocSDF(:, st : en), padSDF); clear monocSDF;
                        TwoByTwoSEM = cat(2,monocSEM(:, st : en), padSEM); clear monocSEM;
                        if size(TwoByTwoSDF,2) ~= length(tm)
                            error('check tm')
                        end
                        nTM = tm;


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

stimcontrast = [contrast_half contrast_max]; % note -- this is flipped from above. This method makes more sense to me.
clear  trls c win cond 
CondMeanResp = nan(16,3,2);
CondTrialNum = nan(16,3,2);
for win = 1:3 
    clear RESP
    RESP = squeeze(matobj.RESP(e,win,:));
    for c = 1:2
        for cond = 1:size(conditionarray,1)
            clear trls
            trls = I &...
                STIM.eyes(:,1) == conditionarray(cond,1) &...
                STIM.tilt(:,1) == conditionarray(cond,2) & ...
                STIM.tiltmatch == conditionarray(cond,3) & ...
                STIM.soa == conditionarray(cond,4) & ...
                STIM.monocular == conditionarray(cond,5) & ...
                STIM.contrast(:,1) == stimcontrast(c) & ...
                STIM.contrast(:,2) == contrast_max;   % Contrast max is always in the non-dominant eye.
            CondMeanResp(cond,win,c) = nanmean(RESP(trls));
            CondTrialNum(cond,win,c) = sum(trls);
        end
    end    
end    

PercentChange = nan(8,3,2);
Subtraction = nan(8,3,2);
for win = 1:3  
    for c = 1:2
        for compare = 1:8
            x = CondMeanResp(compare,win,c);
            y = CondMeanResp(compare+8,win,c);
            PercentChange(compare,win,c) = (x-y)./y;
            Subtraction(compare,win,c) = x-y;
        end
    end
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


%       IDX.(uct).SDF       = ALL 16 CONDITIONS FOR SDF HERE!!!!!!!!!!!!
%       MULTI CONTRAST LEVELS???
        IDX(uct).tm        = nTM;
        
        IDX(uct).brfstilts = brfstilts;
        IDX(uct).monocSDF  = TwoByTwoSDF;
        IDX(uct).monocSEM  = TwoByTwoSEM;
        IDX(uct).monocTrlNum = monocTrlNum;
        
        IDX(uct).condition      = condition;
        IDX(uct).PercentChange  = PercentChange;
        IDX(uct).Subtraction    = Subtraction;
        IDX(uct).CondTrialNum   = CondTrialNum;



toc
    end
% % % %     end   %%%%% KLS loop removed for now
% % % end


%%
saveNotReady
% % % 
% % % %% SAVE
% % % if flag_saveIDX
% % %     cd('G:\LaCie\Adaptdcos figs\adaptdcosCompareConditions')
% % %     if isfile(saveName)
% % %         error('file already exists')        
% % %     end
% % %     save(saveName,'IDX')
% % % end
% % % 
% % % load gong
% % % sound(y,Fs)