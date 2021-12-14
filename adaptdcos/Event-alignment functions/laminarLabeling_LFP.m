function IDX = laminarLabeling_LFP

%% For each session - format the LFP (ch x time x trls)
% This needs to be trial-wise bl corrected
% Do NOT trial avg.
% Keep all stimulus presentations (no condition selection at all)
% Make sure stimulus was on screen for 500ms. 


%% load session data
global STIMDIR
cd(STIMDIR)



didir = strcat(STIMDIR,'\');
saveName = 'laminarLabeling_LFP'; % THIS IS CONTRAST LEVELS OF .41-.75 INCLUSIVE
anaType = '_LFP.mat';
flag_saveIDX    = 1;

kls = 0;
list    = dir([didir '*' anaType]);

sdfwin  = [-0.15  .5];

clear holder IDX
SupraCount = 0;
GranularCount = 0;
InfraCount = 0;
count = 0;
ErrorCount = 0;
noBrfs = 0;
yesBrfs = 0;
paradigm = cell(length(list),8);
%% For loop on unit
for i = 1:length(list)

%% load session data
clear penetration
penetration = list(i).name(1:11); 


clear STIM nel difiles
load([didir penetration '_LFP' '.mat'],'STIM')
for j = 1:length(STIM.paradigm)
    paradigm(i,j)= STIM.paradigm(j)';
end

nel = length(STIM.el_labels);

clear matobj matobj win_ms
matobj = matfile([didir penetration anaType]);
win_ms = matobj.win_ms;

tm = matobj.sdftm;
if tm(end) < sdfwin(2)
    warningMessage = strcat(penetration,'--> tm shorter than .5. What is tm?');
   warning(warningMessage);
   continue
end

%% Electrode loop
for e = 1:nel
% get data needed for diUnitTuning.m
    disp(strcat(penetration,'/ / contact =_ ',num2str(e)))
     
%% Pull out SDF for trials that have data out to 500ms.
% Pre-allocate
clear   sdf resp TrialNum SDF_uncrop RESP_alltrls SDF_crop
sdf  = squeeze(matobj.SDF(e,:,:));
resp = squeeze(matobj.RESP(e,:,:));

% get index of 500ms stimulus
tm500 = find((tm == sdfwin(2)));

% pull out photo diode trial lengths.
idx_sdfLongPrez = ~isnan(sdf(tm500,:));
eventCodeDiff = (STIM.tp_pt(:,2) - STIM.tp_pt(:,1))/30000;
idx_eventCode = (eventCodeDiff > sdfwin(2))';% if the event code offset is more than .5 sec after the event code onset, then the data should fill out past the index of 500ms in our tm vector
if any(idx_sdfLongPrez ~= idx_eventCode)
    error('stimulus offsets not well represented')
end

TrialNum = sum(idx_sdfLongPrez);
SDF_uncrop  = sdf(:,idx_sdfLongPrez); %(ms x trials)
RESP_alltrls       = resp(:,idx_sdfLongPrez);



%% crop/pad SDF
% crop / pad SDF    
%% Pad works for MUA but not for LFP requires trial averaging...
clear pad st en
en = find(tm == sdfwin(2))-1;
st = find(tm == sdfwin(1));
TM = tm(st : en);



data_crop = SDF_uncrop(st:en,:); %(time x trials)


%bl (baseline) correct
if win_ms(4,:) ~= [-50 0]
    error('incorrect bl resp win')
end
blSubData = data_crop - RESP_alltrls(4,:);
SDF_crop = blSubData;


   


%% SAVE  IDX



        % SAVE UNIT INFO!
        clear holder
        holder.penetration = penetration;
        holder.header = penetration(1:8);
        holder.monkey = penetration(8);
        holder.runtime = [date string(now)];

        holder.depth = STIM.depths(e,:)';

        holder.TrialNum     = TrialNum;        

        % Continuous data info
        holder.TM           = TM;
        holder.tmFromMatobj = tm;
        holder.SDF_crop     = SDF_crop; % time x trials
       
        % Time-win binned info;
        holder.win_ms           = win_ms;
        holder.RESP_alltrls     = RESP_alltrls;
        
        
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

error('here is where you can reformat and save individual LFP files')

end

%%

%% SAVE
if flag_saveIDX
    global IDXDIR
    cd(IDXDIR)
%     if isfile(strcat(saveName,'.mat'))
%         error('file already exists')        
%     end
    clearvars -except IDX
    save(saveName,'IDX','-v7.3')
else
    warning('IDX not saved')
end



load gong
sound(y,Fs)







end