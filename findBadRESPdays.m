%% findBadRESPdays.m


clear

didir = 'C:\Users\Brock\Documents\MATLAB\diSTIM_Sep23\';
list    = dir([didir '*_AUTO.mat']);

saveName = 'diIDX_Adapt200vs800-deltaContrast-nullstim';

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


clear matobj win_ms
matobj = matfile([didir penetration '_AUTO.mat']);

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

    clear *RESP* *SDF* sdf sdftm X M TRLS SUB RESPnanIDX TaskNaNLog
    RESP = squeeze(matobj.RESP(e,:,:));
    
    
    
    
    if sum(any(isnan(RESP))) > 0
        % SAVE IDX
        % SAVE UNIT INFO!
        
        RESPnanIDX = isnan(RESP);
        TaskNaNLog.trans    = STIM.task(RESPnanIDX(1,:),1);
        TaskNaNLog.sust     = STIM.task(RESPnanIDX(2,:),1);
        TaskNaNLog.fullTM   = STIM.task(RESPnanIDX(3,:),1);
        TaskNaNLog.bl       = STIM.task(RESPnanIDX(4,:),1);
        
        
        uct = uct + 1;
        IDX(uct).penetration = penetration;
        IDX(uct).header = penetration(1:8);
        IDX(uct).monkey = penetration(8);
        IDX(uct).runtime = [date string(now)];
        IDX(uct).depth = STIM.depths(e,:)';
        
        IDX(uct).RESP       = RESP;
        IDX(uct).win_ms     = win_ms;
        IDX(uct).RESPnanIDX = RESPnanIDX;
        IDX(uct).sumNaNs    = sum(sum(RESPnanIDX(:,:)));
        
        IDX(uct).findNaN_transient      = find(RESPnanIDX(1,:));
        IDX(uct).findNaN_sustained      = find(RESPnanIDX(2,:));
        IDX(uct).findNaN_fullWindow     = find(RESPnanIDX(3,:));
        IDX(uct).findNaN_baseline       = find(RESPnanIDX(4,:));

        IDX(uct).TaskNaNLog             = TaskNaNLog;
        
                
    end
    

       
end
end


