%% diIDX_pHYtESTING


%goal --> Fig 2 and 3 -- kls
% all are binned laminar
% 2 parts to each - binned laminar and difference plots
% 2a. Monoc vs C Simult
% 2b. Monoc vs IC Simult

% 3a. C vs IC simult - show dCOS
% 3b. C vs IC suppressor - show dCOF

clear
tic

global STIMDIR
didir = STIMDIR;
cd(STIMDIR)
saveName = 'diIDX_Phy_PrefSelected';
anaType = '_KLS.mat';
flag_saveIDX    = 0;
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
for i = 1:length(list)


%% load session data
clear penetration
penetration = list(i).name(1:11); 

clear STIM nel difiles
load([didir penetration '.mat'],'STIM')

% Balance conditions
if ~any(contains(STIM.paradigm,'brfs'))
   warning('no brfs on day...')
   disp(penetration)
   noBrfs = noBrfs + 1;
   MISSNIG(noBrfs,:) = penetration;
   continue
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
    for e = 1:nel
    % get data needed for diUnitTuning.m
        disp(strcat(penetration,'/ / contact =_ ',num2str(e)))



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
        continue
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

    %% Pull out SDF
    % Pre-allocate
    clear  cond SDF SDF_uncrop sdf trlsLogical
    CondTrialNum = nan(size(condition,1),1);
    CondTrials = cell(size(condition,1),1);
    sdf  = squeeze(matobj_SDF.SDF(e,:,:));
    SDF_uncrop = nan(size(conditionarray,1),size(sdf,1));
    SEM_uncrop = nan(size(conditionarray,1),size(sdf,1));

    for cond = 1:size(conditionarray,1)
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

        CondTrials{cond} = find(trls);
        CondTrialNum(cond,1) = sum(trls); 
        SDF_uncrop(cond,:)   = nanmean(sdf(:,trls),2);    % Use trls to pull out continuous data   
        SEM_uncrop(cond,:)   = (nanstd(sdf(:,trls),[],2))./sqrt(sum(trls));





    end

    if any(isnan(CondTrialNum))
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
                SDF.raw = cat(2,SDF_uncrop(:, st : en,:), padrows); clear SDF_uncrop;                  
                SEM.raw = cat(2,SEM_uncrop(:, st : en,:), padrows); clear SEM_uncrop;                  
                if size(SDF.raw,2) ~= length(tm)
                    error('check tm')
                end
                TM = tm;


    %% Normalize SDF
        % out --> z-score, 
        % inputs --> baseline population mean, baselin population stdev,
        % SDF from binoc PS congruent simultaneous.

        %get inputs
            % Pull out baseline period
            % nota bene -- Exclude basline of suppressor trials later!! - cannot
            % do it on the squeeze line because index must be numeric.
            if isequal(win_ms(4,:),[-50 0])
                blDimension = 4;
            else
                error('RESP dimension issue. fix by programatically finding where the window is.')
            end    
            baselineAll = squeeze(matobj_RESP.RESP(e,blDimension,:));

            %bl pop average
            % Get min response (avg of baseline period for all non-suppressor trials)
            blAvg = nanmean(baselineAll(~STIM.suppressor,1));

            %bl pop stdev
            % Get min response (avg of baseline period for all non-suppressor trials)
            blStd = nanstd(baselineAll(~STIM.suppressor,1));
            
            %Max of avg Binoc Simult PS - dimension 5 is cong simult.
            maxSDF = max(SDF.raw(5,:));
            

        % Z-score
        % ZscoreDat = (ContinuousData - popAvgOfBL)./popSTDOfBL
        SDF.zs = (SDF.raw - blAvg)./blStd;
        SEM.zs = (SEM.raw - blAvg)./blStd; %% This calculation might not be correct -- BMC 6/24/2020

        % fs - feature scale
        % fs dat = (x - blAvg)./(BinocPrefStimMax - blAvg)
        SDF.fs = (SDF.raw - blAvg)./(maxSDF - blAvg);
        SEM.fs = (SEM.raw - blAvg)./(maxSDF - blAvg);




    %% SAVE  IDX

            % SAVE UNIT INFO!
            clear holder
            holder.penetration = penetration;
            holder.header = penetration(1:8);
            holder.monkey = penetration(8);
            holder.runtime = [date string(now)];

            holder.depth = STIM.kls.depth(e,:)';


            holder.DE    = DE;
            holder.PS    = PS;
            holder.NDE    = NDE;
            holder.NS    = NS;        

            %%%% NEW ADDITIONS FROM BMC
            holder.tm        = TM;

            holder.SDF      = SDF;
            holder.SEM      = SEM;


            holder.condition        = condition;
            holder.CondTrialNum_SDF     = CondTrialNum;        

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
    global SAVEDIR
    cd(SAVEDIR)
%     if isfile(strcat(saveName,'.mat'))
%         error('file already exists')        
%     end
    save(saveName,'IDX')
    save('ERR','ERR')
else
    warning('IDX not saved')
end

toc

load gong
sound(y,Fs)