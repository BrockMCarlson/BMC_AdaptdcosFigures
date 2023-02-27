function [SDF_fulltm,SUA_fulltm,condition,CondTrialNum] =...
                continuousDatMonocCompare(STIM,ContinuousDat)

%% BMC -- 10-29-20

sdf = ContinuousDat.SDF; % timepoints x trials
sua = ContinuousDat.SUA;

warning('hardcoding DE and PS')
DE = 2;
NDE = 3;
PS = 90;
NS = 180;
% 1 - simult
%   1. Monoc 1
%   2. Monoc 2
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

%% preallocate for SDF
% Pre-allocate

SDF_fulltm.condNum1 = [];
SDF_fulltm.condNum2 = [];
SDF_fulltm.condNum3 = [];
SDF_fulltm.condNum4 = [];
SUA_fulltm.condNum1 = [];
SUA_fulltm.condNum2 = [];
SUA_fulltm.condNum3 = [];
SUA_fulltm.condNum4 = [];

for cond = 1:4

%% Pull out response for all trials with that condition.
% %     for cond = 1:size(conditionarray,1)
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

% % %         CondTrials{cond} = find(trls);
% % %         CondTrialNum(cond,1) = sum(trls); 
    clear CondTrials
    CondTrials = find(trls);
    CondTrialNum(cond) = sum(trls);

% % %         


    %% HERE IS WHAT I WANT TO grab from a trial loop

    clear trlLoop
    for trlLoop = 1:size(CondTrials,1)
        SDF_fulltm.(strcat('condNum',num2str(cond)))(trlLoop,:)   = sdf(:,CondTrials(trlLoop));    % Use trls to pull out continuous data   
        SUA_fulltm.(strcat('condNum',num2str(cond)))(trlLoop,:)   = sua(:,CondTrials(trlLoop));    % Use trls to pull out spk data   
    end

end
end