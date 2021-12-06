function IDX = IDXforbmcBRFS2021

%% load session data
global STIMDIR
cd(STIMDIR)



didir = strcat(STIMDIR,'\');
saveName = 'IDXforbmcBRFS2021'; % THIS IS CONTRAST LEVELS OF .41-.75 INCLUSIVE
anaType = '_MUA.mat';
flag_saveIDX    = 1;

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
if strcmp(penetration,'160422_E_eD')
    warning('160422 skipped -- problem with 4 null oris in di Unit Tuning?')
    continue
end

clear STIM nel difiles
load([didir penetration '.mat'],'STIM')
for j = 1:length(STIM.paradigm)
    paradigm(i,j)= STIM.paradigm(j)';
end


% Balance conditions
if ~any(contains(STIM.paradigm,'bmcBRFS'))
   warning('no brfs on day...')
   disp(penetration)
   noBrfs = noBrfs + 1;
   MISSING(noBrfs,:) = penetration;
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

% %         
% % %% Di Unit Tuning -- RESP is always from AUTO
% %      X = diUnitTuning(respFullTM,STIM,goodfiles);
% %      DE = X.dipref(1);
% %      NDE = X.dinull(1);
% %      PS = X.dipref(2);
% %      NS = X.dinull(2);
% %      
% %      
% %  
% % %% Set limits on acceptable tuning.
% % if X.diana ~= 1
% %     ErrorCount = ErrorCount+1;
% %     ERR(ErrorCount).reason = 'dichoptic analysis not run on unit';
% %     ERR(ErrorCount).penetration = STIM.penetration;
% %     ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
% %     continue
% % end
% % 
% % % X.diang   = {'eye','tilt','contrast'};
% % if X.dianp(1) > 0.05
% %     ErrorCount = ErrorCount+1;
% %     ERR(ErrorCount).reason = 'unit not tuned to eye';
% %     ERR(ErrorCount).penetration = STIM.penetration;
% %     ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
% %     continue
% % end
% % if X.dianp(2) > 0.05
% %     ErrorCount = ErrorCount+1;
% %     ERR(ErrorCount).reason = 'unit not tuned to eye and ori';
% %     ERR(ErrorCount).penetration = STIM.penetration;
% %     ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
% %     continue
% % end


    
%% Conditions established to pull out SDFs
   % loop through different resp windows based on win_ms;
if ~isequal(win_ms(1,:),[50 100])
    error('RESP dimension issue')
end


%% Pull out SDF
% Pre-allocate
clear  cond SDF SDF_uncrop SDF_crop sdf resp trlsLogical
sdf  = squeeze(matobj.SDF(e,:,:));
resp = squeeze(matobj.RESP(e,:,:));


PULL OUT THE DESIRED CONDITIONS HERE
You need full trial conditions adaptetor and suppressor. Thats it.

clear trls  
trls.Monocular1 = STIM.bmcBRFSparamNum == 8 &...
    STIM.first800 == true;
trls.Monocular2 = STIM.bmcBRFSparamNum == 9 &...
    STIM.first800 == true;
trls.Monocular3 = STIM.bmcBRFSparamNum == 10 &...
    STIM.first800 == true;
trls.Monocular4 = STIM.bmcBRFSparamNum == 11 &...
    STIM.first800 == true;

trls.First800_1 = STIM.bmcBRFSparamNum == 8 &...
    STIM.first800 == true &...
    STIM.fullTrial == true;
trls.Secon800_1 = STIM.bmcBRFSparamNum == 8 &...
    STIM.first800 == false &...
    STIM.fullTrial == true;


fields = fieldnames(trls);
for f = 1:length(fields)
    TuneList.(fields{f})(~I) = [];
    
    trlsLogical(:,f) = trls.(fields{f});
    CondTrials{f} = find(trls);
    CondTrialNum(f,1) = sum(trls); 
    SDF_uncrop{f}   = sdf(:,trls); 
    RESP_alltrls{f}        = resp(:,trls);
    
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
    save(saveName,'IDX')
    save('ERR','ERR')
else
    warning('IDX not saved')
end



load gong
sound(y,Fs)







end