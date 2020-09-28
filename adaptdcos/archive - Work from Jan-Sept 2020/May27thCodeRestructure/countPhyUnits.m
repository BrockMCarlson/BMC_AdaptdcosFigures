%% countPhyUnits.m
% taken from diIDX_May27


clear


global STIMDIR
didir = STIMDIR;
cd(STIMDIR)
saveName = 'diIDX_Phy_EyeTunedOnly';
anaType = '_KLS.mat';

list    = dir([didir '*' anaType]);


count = 0;
count_S = 0;
count_G = 0;
count_I = 0;
%% For loop on unit
for i = 1:length(list)


%% load session data
clear penetration
penetration = list(i).name(1:11); 

clear STIM nel 
load([didir penetration '.mat'],'STIM')

nel = length(STIM.units);




%% Electrode loop
for e = 1:nel
count = count + 1;
PhyOut(count).name      = strcat(penetration,'/contact num_ ',num2str(e));
PhyOut(count).cluster   = STIM.units(e).fileclust(2);
PhyOut(count).depth     = STIM.units(e).depth(2);
    % Laminar Division
    if STIM.units(e).depth(2) >5
        count_S = count_S+1;
        PhyOut(count).layer = 'supra';
    elseif STIM.units(e).depth(2)>= 0 && STIM.units(e).depth(2) <= 5
        count_G = count_G+1;
        PhyOut(count).layer = 'granu';
    elseif STIM.units(e).depth(2) < 0
        count_I = count_I+1;
        PhyOut(count).layer = 'infra';
    end
end





end




