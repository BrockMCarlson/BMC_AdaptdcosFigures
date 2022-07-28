function IDX = IDXforbmcBRFS2021

%% load session data
global STIMDIR
cd(STIMDIR)



didir = strcat(STIMDIR,'\');
saveName = 'IDXforIOTana'; 
anaType = '_MUA_old.mat';
flag_saveIDX    = true;
saveYourFigs = true;

kls = 0;
list    = dir([didir '*' anaType]);

sdfwin  = [-0.15  .8];

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

clear trls  
%Monoc PO LeftEye 
trls.monocular = STIM.bmcBRFSparamNum == 16 &...
    STIM.first800 == true;
% Monoc PO LeftEye adapting post other eye adapt 
trls.IOT = STIM.bmcBRFSparamNum == 13 &...
    STIM.first800 == false &...
    STIM.fullTrial == true;

% % % % brfs 9
% % % trls.adapter_9 = STIM.bmcBRFSparamNum == 9 &...
% % %     STIM.first800 == true &...
% % %     STIM.fullTrial == true;
% % % trls.suppressor_9 = STIM.bmcBRFSparamNum == 9 &...
% % %     STIM.first800 == false &...
% % %     STIM.fullTrial == true;
% % % % brfs 10
% % % trls.adapter_10 = STIM.bmcBRFSparamNum == 10 &...
% % %     STIM.first800 == true &...
% % %     STIM.fullTrial == true;
% % % trls.suppressor_10 = STIM.bmcBRFSparamNum == 10 &...
% % %     STIM.first800 == false &...
% % %     STIM.fullTrial == true;
% % % % brfs 11
% % % trls.adapter_11 = STIM.bmcBRFSparamNum == 11 &...
% % %     STIM.first800 == true &...
% % %     STIM.fullTrial == true;
% % % trls.suppressor_11 = STIM.bmcBRFSparamNum == 11 &...
% % %     STIM.first800 == false &...
% % %     STIM.fullTrial == true;
% % % % brfs 12
% % % trls.adapter_12 = STIM.bmcBRFSparamNum == 12 &...
% % %     STIM.first800 == true &...
% % %     STIM.fullTrial == true;
% % % trls.suppressor_12 = STIM.bmcBRFSparamNum == 12 &...
% % %     STIM.first800 == false &...
% % %     STIM.fullTrial == true;


conditions = fieldnames(trls);
for f = 1:length(conditions)
    
    trlsLogical(:,f) = trls.(conditions{f});
    CondTrials{f} = find(trls.(conditions{f}));
    CondTrialNum(f,1) = sum(trls.(conditions{f})); 
    % SDF is a (1xf) cell. Each cell is (ms x trls) of data. i.e. (999 x 39) double
        SDF_uncrop{f}   = sdf(:,trls.(conditions{f}));  
    % RESP is a (1xf) cell. Each cell is (ms x trls) of data. i.e. (999 x 39) double
        RESP_alltrls{f} = resp(:,trls.(conditions{f}));  
end

% Condition codes:
% 1     'Simult. Dioptic. PO',...
% 2     'Simult. Dioptic. NPO',...
% 3     'Simult. Dichoptic. PO LeftEye - NPO RightEye',...
% 4     'Simult. Dichoptic. NPO LeftEye - PO RightEye',...
% 5     'BRFS-like Congruent Adapted Flash. C PO RightEye adapting - PO LeftEye flashed',... 
% 6     'BRFS-like Congruent Adapted Flash. C NPO LeftEye adapting - NPO RightEye flashed',... 
% 7     'BRFS-like Congruent Adapted Flash. C NPO RightEye  adapting - NPO LeftEye flashed',... 
% 8     'BRFS-like Congruent Adapted Flash. C PO LeftEye adapting - PO RightEye flashed',... 
% 9     'BRFS IC Adapted Flash. NPO RightEye adapting - PO LeftEye flashed',... 
% 10    'BRFS IC Adapted Flash. PO LeftEye adapting - NPO RightEye flashed',... 
% 11    'BRFS IC Adapted Flash. PO RightEye adapting - NPO LeftEye flashed',... 
% 12    'BRFS IC Adapted Flash. NPO LeftEye adapting - PO RightEye flashed',... 
% 13    'Monoc Alt Congruent Adapted. C PO RightEye adapting - PO LeftEye alternat monoc presentation',... 
% 14    'Monoc Alt Congruent Adapted. C NPO LeftEye adapting - NPO RightEye alternat monoc presentation',... 
% 15    'Monoc Alt Congruent Adapted. C NPO RightEye  adapting - NPO LeftEye alternat monoc presentation',... 
% 16    'Monoc Alt Congruent Adapted. C PO LeftEye adapting - PO RightEye alternat monoc presentation',... 
% 17    'Monoc Alt IC Adapted. NPO RightEye adapting - PO LeftEye alternat monoc presentation',... 
% 18    'Monoc Alt IC Adapted. PO LeftEye adapting - NPO RightEye alternat monoc presentation',... 
% 19    'Monoc Alt IC Adapted. PO RightEye adapting - NPO LeftEye alternat monoc presentation',... 
% 20    'Monoc Alt IC Adapted. NPO LeftEye adapting - PO RightEye alternat monoc presentation',... 




%% crop SDF
        % crop SDF    
        %% Pad works for MUA but not for LFP requires trial averaging...
        clear tm pad st en
        tm = matobj.sdftm;
        if tm(end) < sdfwin(2)  
           error('this code is set to crop, not to pad, check your window')
        else
            en = find(tm == sdfwin(2))-1;
            st = find(tm == sdfwin(1));
            TM = tm(st : en);
        end
        clear cond
        for cond = 1:length(conditions)
            data = SDF_uncrop{cond}; % data is in [time x trials]
            if isempty(data)
                error('no data found')                
            else
                data_crop = data(st:en,:);
            end
            SDF_crop{cond} = data_crop;
        end
        
%% baseline correct SDF
clear cond
for cond = 1:size(conditions,1)
    sdfholder = SDF_crop{cond};
    respholder = RESP_alltrls{cond};
    SDF_blCor{cond} = sdfholder - respholder(4,:);
end

error('z-score normalize your data')
%% Get avg results
SDF_avg     = cell(size(conditions,1),1);
RESP_avg    = cell(size(conditions,1),1);

clear cond
for cond = 1:size(conditions,1)
    sdfholder = SDF_crop{cond};
    SDF_avg{cond} = mean(SDF_blCor{cond},2);
    RESP_avg{cond}= mean(RESP_alltrls{cond},2);
end


% Plot the electrode's BFFS and save
clear cond
close all
h = figure;
for cond = 1:size(conditions,1)
    subplot(2,2,cond)
    plot(TM,SDF_avg{cond})
    ylim([0 10])
end
titleText = strcat(penetration,'_el#_',string(e));
 sgtitle(titleText,'interpreter', 'none')  
 global OUTDIR
 cd(OUTDIR)
 
if saveYourFigs
    saveas(h,strcat(titleText, '.png'))
end

%% SAVE  IDX



        % SAVE UNIT INFO!
        clear holder
        holder.penetration = penetration;
        holder.header = penetration(1:8);
        holder.monkey = penetration(8);
        holder.runtime = [date string(now)];

        holder.depth = STIM.depths(e,:)';


        % Condition info
        holder.CondTrials = CondTrials;
        holder.conditions        = conditions;
        holder.CondTrialNum     = CondTrialNum;        

        % Continuous data info
        holder.TM           = TM;
        holder.SDF_crop     = SDF_crop;
        holder.SDF_avg      = SDF_avg;

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
else
    warning('IDX not saved')
end



load gong
sound(y,Fs)







end