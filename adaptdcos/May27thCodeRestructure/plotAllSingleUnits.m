%% plotAllSingleUnits
% taken from diIDX_May27


%goal --> plot nanmean response of every unit for all visual stimulation.
%Weather driven well or not.

clear
tic

global STIMDIR
didir = STIMDIR;
saveName = 'diIDX_-test-KLS';
anaType = '_KLS.mat';
flag_saveFigs   = 1;

kls = 0;
list    = dir([didir '*' anaType]);

sdfwin  = [-0.05  .3];

clear holder IDX
SupraCount = 0;
GranularCount = 0;
InfraCount = 0;
count = 0;

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
   continue
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

        
%% Di Unit Tuning -- RESP is always from AUTO
     X = diUnitTuning(RESP,STIM,goodfiles);
     DE = X.dipref(1);
     NDE = X.dinull(1);
     PS = X.dipref(2);
     NS = X.dinull(2);
 



%% Set limits on acceptable tuning.
UnitTitle = {'','',''};
if X.diana ~= 1
    continue
    UnitTitle{1} = 'dichoptic analysis not run on unit';
    UnitTitle{2} = STIM.penetration;
    UnitTitle{3} = num2str(STIM.depths(e,2));
elseif X.dianp(2) > 0.05
    continue
    UnitTitle{1} = 'unit not tuned to ori';
    UnitTitle{2} = STIM.penetration;
    UnitTitle{3} = num2str(STIM.depths(e,2));
elseif X.dianp(3) > 0.05
    continue
    UnitTitle{1} = 'unit tuned to ori but NOT to contrast';
    UnitTitle{2} = STIM.penetration;
    UnitTitle{3} = num2str(STIM.depths(e,2));
elseif X.dianp(1) > 0.05
    continue
    UnitTitle{1} = 'unit tuned to ori and contrast but NOT to contrast';
    UnitTitle{2} = STIM.penetration;
    UnitTitle{3} = STIM.depths(e,2);
else
    UnitTitle{1} = 'unit included in adaptdcos analysis';
    UnitTitle{2} = STIM.penetration;
    UnitTitle{3} = num2str(STIM.depths(e,2));
end
    
%% NaN mean all responses
% Pre-allocate
clear    SDF_uncrop sdf 
sdf  = squeeze(matobj_SDF.SDF(e,:,:));
clear I
I = ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & STIM.suppressor == 0 ...
    & ismember(STIM.filen,goodfiles); 
SDF_uncrop  = nanmean(sdf(:,I),2); clear sdf;   % Use trls to pull out continuous data   


%% crop/pad SDF
        % crop / pad SDF   
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
        clear SDF
        SDF.raw = SDF_uncrop(st : en); clear SDF_uncrop;                  
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
    
    % Z-score
    % ZscoreDat = (ContinuousData - popAvgOfBL)./popSTDOfBL
    SDF.zs = (SDF.raw - blAvg)./blStd;
    

   






%% PLOT
close all
figure
plot(TM,SDF.raw)
vline(0)
title(UnitTitle,'interpreter', 'none')

if flag_saveFigs
    count = count + 1;
    cd('C:\Users\Brock\Documents\MATLAB\Working IDX Dir\May27CodeRestructure\allNeurons')
    if count == 1
        export_fig('AnalyzedUnits','-pdf','-nocrop') 
    else
        export_fig('AnalyzedUnits','-pdf','-nocrop','-append')
    end
end
end
end


toc 
load gong
sound(y,Fs)