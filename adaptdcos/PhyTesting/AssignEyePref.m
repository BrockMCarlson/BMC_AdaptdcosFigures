%% AssignEyePref.m

clear
close all

global STIMDIR
didir = STIMDIR;
cd(STIMDIR)
saveName = 'diIDX_Phy_oneDay';
anaType = '_KLS.mat';
flag_saveFigs   = 1;


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
i = 3;

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
   error('needs BRFS')
else
    yesBrfs = yesBrfs+1;
    FOUND(yesBrfs,:) = penetration;
end

nel = length(STIM.units);

difiles = unique(STIM.filen(STIM.ditask));


clear matobj_RESP matobj_SDF win_ms
matobj = matfile([didir penetration '_KLS.mat']);

win_ms = matobj.win_ms;
if isequal(win_ms(3,:),[50 250])
    respDimension = 3;
elseif isequal(win_ms(4,:),[50 250])
    respDimension = 4;
else
    error('RESP dimension issue')
end

%% Count trialnum for STIM
%Monoc2, Monoc3, Tilt1, Tilt2,
brfsFileNum = STIM.units(1).fileclust(1);
if ~contains(STIM.filelist(brfsFileNum),'brfs')
    error('why is this not brfs on the phy sorted units?')
end
clear monoc2 monoc3
monoc2 = ~STIM.blank &...
    STIM.filen == brfsFileNum &...
    STIM.contrast(:,1)  >= .5 &...
    STIM.monocular == 1 & ...
    STIM.eyes(:,1) == 2;
monoc2tilts = nanunique(STIM.tilt(monoc2,:),'rows');
sum(monoc2)
monoc2tilts

monoc3 =  ~STIM.blank &...
    STIM.filen == brfsFileNum &...
    STIM.contrast(:,1) >= .5 &...
    STIM.monocular == 1 & ...
    STIM.eyes(:,1) == 3;
monoc3tilts = nanunique(STIM.tilt(monoc3,:),'rows');
sum(monoc3)
monoc3tilts

Binoc =  ~STIM.blank &...
    STIM.filen == brfsFileNum &...
    STIM.monocular == 0 & ...
    STIM.tiltmatch == 1;
Binoctilts = nanunique(STIM.tilt(Binoc,:),'rows');


Dichop =  ~STIM.blank &...
    STIM.filen == brfsFileNum &...
    STIM.monocular == 0 & ...
    STIM.tiltmatch == 0;
Dichoptilts = nanunique(STIM.tilt(Dichop,:),'rows');


Suppressors =  ~STIM.blank &...
    STIM.filen == brfsFileNum &...
    STIM.suppressor == 1;

% Are there multiple options in the unique tilsts? If so, plot and figure
% out which is preferred. Right now, only 2 options are avaialbe for the
% first day, so I will just plot the conditions for those...

% Find pref eye for each contact


%% Electrode loop
for e = 1:nel
% get data needed for diUnitTuning.m
clear RESP SDF sdf sdftm CondTrialNum
disp(strcat(penetration,'/ / contact =_ ',num2str(e)))
depth = num2str(STIM.kls.depth(e,2));
RESP = squeeze(matobj.RESP(e,respDimension,:));
sdf  = squeeze(matobj.SDF(e,:,:));
SDF_uncrop = nan(2,size(sdf,1));
SEM_uncrop = nan(2,size(sdf,1));

 for cond = 1:2     
    if cond == 1
        trls = monoc2;
    elseif cond == 2
        trls = monoc3;
    end
    CondTrials{cond} = find(trls);
    CondTrialNum{cond,:} = num2str(sum(trls)); 
    SDF_uncrop(cond,:)   = nanmean(sdf(:,trls),2);    % Use trls to pull out continuous data   
    SEM_uncrop(cond,:)   = (nanstd(sdf(:,trls),[],2))./sqrt(sum(trls));
 end






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
        padrows = repmat(pad,size(SDF_uncrop,1),1); % pads with NANs if you are not in that condition any more. 
            clear SDF
            SDF = cat(2,SDF_uncrop(:, st : en,:), padrows); clear SDF_uncrop;                  
            SEM = cat(2,SEM_uncrop(:, st : en,:), padrows); clear SEM_uncrop;                  
            if size(SDF,2) ~= length(tm)
                error('check tm')
            end
            TM = tm;
     
   


%% Plot units
figure 
plot(TM,SDF(1,:),'-k','LineWidth',2); hold on
plot(TM,SDF(1,:)-SEM(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on
plot(TM,SDF(1,:)+SEM(1,:),':k','LineWidth',1,'HandleVisibility','off'); hold on
plot(TM,SDF(2,:),'-c','LineWidth',2); hold on
plot(TM,SDF(2,:)-SEM(2,:),':c','LineWidth',1,'HandleVisibility','off'); hold on
plot(TM,SDF(2,:)+SEM(2,:),':c','LineWidth',1,'HandleVisibility','off'); hold on

legend({'monoc2','monoc3'})
vline(0)
titletext = {strcat('EyeSelect_',penetration),strcat('at depth_',depth),strcat('Monoc2trlNum=',CondTrialNum{1,:},'___Monoc3trlNum=',CondTrialNum{2,:})};
title(titletext,'interpreter','none')

if e == 1 && flag_saveFigs
    global SAVEDIR
    cd(SAVEDIR)
end
if flag_saveFigs
    count = count + 1;
    if count == 1
        export_fig(strcat('EyeSelect_',penetration),'-pdf','-nocrop') 
    else
        export_fig(strcat('EyeSelect_',penetration),'-pdf','-nocrop','-append')
    end
end

end


load gong
sound(y,Fs)

