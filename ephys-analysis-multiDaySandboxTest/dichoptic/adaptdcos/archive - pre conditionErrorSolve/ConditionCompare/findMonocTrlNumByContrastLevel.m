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
list    = dir([didir '*_AUTO.mat']);
flag_saveIDX = 0;
saveName = 'IDX_FULLUnitAna';


sdfwin  = [-0.05 0.3]; %s
statwin = [0.15 0.25; .05 .10]; %s
Fs = 1000;

clear IDX
uct = 0;


for a = 1:13
    name(a,:) = {list(a).name(1:11)};
end

allPossibleContrasts = [0;0.0500000000000000;0.150000000000000;0.225000000000000;0.300000000000000;0.450000000000000;0.500000000000000;0.600000000000000;0.800000000000000;0.900000000000000;1];
MTNBCL = nan(length(allPossibleContrasts),14);
MTNBCL(:,1) = allPossibleContrasts;
sessionCount = 1;
%% For loop on unit
for i = 1:length(list)
sessionCount = sessionCount + 1;

%% load session data
clear penetration
penetration = list(i).name(1:11); 

clear STIM nel 
load([didir penetration '.mat'],'STIM')
nel = length(STIM.el_labels);

    % get "goodfiles" for each cluster
    % i.e., the files over which the cluster is present
    % pref for ditasks if there are more than 1 set of clusters at depth
    % DEV:  should be able to scrape more from
    %       STIM.rclusters, and non-used STIM.clusters
    clear goodfiles allfiles
    allfiles = 1:length(STIM.filelist);
   
    goodfiles = allfiles;
   


    %% Lets get down to buisness       
    % determin all contrasts levels for this Session
    clear I
    I = ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0 ...
        & ismember(STIM.filen,goodfiles);
      

    
 
    clear a
    for a = 1:length(allPossibleContrasts)
        clear trls          
        trls = I &...
            STIM.contrast(:,1) == allPossibleContrasts(a) & ...
            STIM.monocular;  

        % Monoc Trial Number By Contrast Level (MTNBCL)
        MTNBCL(a,sessionCount) = sum(trls);
    end  
        
 



end


