% SingleSession_hyperdMUA

clear 
close all
setup('brockSand')
global SAVEDIR STIMDIR RIGDIR HOMEDIR
cd(STIMDIR)
penetration = '160108_E_eD';
sdfwin  = [-0.05  .3];


load('160108_E_eD.mat')

 matobj = matfile([STIMDIR penetration '_AUTO.mat']);
win_ms = matobj.win_ms;
if isequal(win_ms(3,:),[50 250])
    respDimension = 3;
elseif isequal(win_ms(4,:),[50 250])
    respDimension = 4;
else
    error('RESP dimension issue')
end
goodfiles = 1:length(STIM.filelist);

nel = length(STIM.el_labels);

%% Electrode loop
clear HdMUA_DE HdMUA_NDE
HdMUA_DE = nan(nel,70);
HdMUA_NDE = nan(nel,70);
ErrorCount = 0;
for e = 1:nel
     clear RESP SDF sdf sdftm X M TRLS SUB 
     RESP = squeeze(matobj.RESP(e,respDimension,:));
          
     
     X = diUnitTuning(RESP,STIM,goodfiles);
     DE = X.dipref(1);
     NDE = X.dinull(1);
     PS = X.dipref(2);
     NS = X.dinull(2);
    

if X.dianp(1) > 0.05
    ErrorCount = ErrorCount+1;
    ERR(ErrorCount).reason = 'unit NOT tuned to eye';
    ERR(ErrorCount).penetration = STIM.penetration;
    ERR(ErrorCount).depthFromSinkBtm = STIM.depths(e,2);
    continue
end


clear I 
I = STIM.ditask...
    & ~STIM.blank ...
    & STIM.rns == 0 ...
    & STIM.cued == 0 ...
    & STIM.motion == 0 ...
    & ismember(STIM.filen,goodfiles);

clear  cond SDF SDF_uncrop sdf trlsLogical preWhite
sdf  = squeeze(matobj.SDF(e,:,:));
preWhite = nanmean(sdf,2);

BUT wait! We need the same contrast and same ori! choose the PS. And then go trial by trial
trlsDE = I &... 
     STIM.monocular == 1 &...
     STIM.eye == DE;
foundTrlsDE = find(trlsDE); 
numTrls1 = sum(trlsDE); 
getRidofNaNTrialMean
SDF_uncrop(1,:)   = nanmean(sdf(:,trlsDE),2);    % Use trls to pull out continuous data    
        
trlsNDE = I &...
     STIM.monocular == 1 &...
     STIM.eye == NDE;
foundTrlsNDE = find(trlsNDE); 
numTrls1 = sum(trlsNDE); 
CutThisNaNTrialMeanCrap
SDF_uncrop(2,:)   = nanmean(sdf(:,trlsNDE),2);    % Use trls to pull out continuous data     
    
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
padrows = repmat(pad,2,1); % pads with NANs if you are not in that condition any more. 
    clear SDF
    SDF = cat(2,SDF_uncrop(:, st : en,:), padrows); clear SDF_uncrop;                  
    if size(SDF,2) ~= length(tm)
        error('check tm')
    end
    TM = tm;
    
%% hdMUA
if isequal(win_ms(4,:),[-50 0])
            blDimension = 4;
else
    error('RESP dimension issue. fix by programatically finding where the window is.')
end    
baselineAll = squeeze(matobj.RESP(e,blDimension,:));
blAvg = nanmean(baselineAll(~STIM.adapted,1));
threshold = blAvg + 15; %% BMC DEV here -- this is just a rough threshold

% Create bins
TimeSize = size(SDF,2);
NofBin = TimeSize/5;
xMin = -4;
xMax = 0;
clear bin
for b = 1:NofBin
    xMin = xMin + 5;
    xMax = xMax + 5;
    bin = nanmean(SDF(:,xMin:xMax),2);
    if bin(1) > threshold
        HdMUA_DE(e,b) = 1;
    else
        HdMUA_DE(e,b) = 0;
    end
    if bin(2) > threshold
        HdMUA_NDE(e,b) = 1;
    else
        HdMUA_NDE(e,b) = 0;
    end
    
end
        
end