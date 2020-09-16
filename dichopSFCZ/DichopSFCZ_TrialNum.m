% DichopSFCZ_TrialNum

% 1. In the current dataset - ust STIM files to count how many...
    % A - Penetrations
    % B - File types with dichoptic presentation (brfs,mcosinteroc,___?)
    % C** - trials of each condition type
        % i.    - monocular eye 1
        % ii.   - monocular eye 2
        % iii.  - binocular
        % iv.   - dichoptic
       
% Perhaps take this from runTuneList?
% - dependency - setup.m

clear all
close all

setup('brock')

analysis = 'diNeuralDat';
flag_checkforexisting = true;

global STIMDIR
if ~isempty(STIMDIR)
    didir = STIMDIR;
else
    didir = '/Volumes/LaCie/Dichoptic Project/vars/diSTIM_Dec12/';
end
cd(didir)
list = dir([didir '1*.mat']);
findSTIMfiles = cellfun(@length,{list.name}) == 15; % This is how only STIM is pulled out - genius.
list = list(findSTIMfiles);

fixCount = 0;
for i = 1:length(list)
list(i).name
clear STIM RESP SDF sdftm PSTH psthtm CLUST
load([didir list(i).name],'STIM')

INFO(i).penetration = STIM.penetration;

ct = 0; 
I = [];
for j = 1:length(STIM.paradigm)
    fileOfInterest = contains(STIM.paradigm{j},'interoc');
    if fileOfInterest
        ct = ct + 1;
        I(:,ct) = STIM.filen == j;
        fileOut = STIM.paradigm{j};
    end
    if ct > 1
        fixCount = fixCount + 1;
        warning('cutting additional files')
        SALVAGE(fixCount,:) = STIM.penetration;
        I = I(:,1);
    end
end
if isempty(I)
    warning([STIM.penetration, '_has no interoc file'])
    continue
end

% C** - trials of each condition type
    % i.    - monocular eye 1
    % ii.   - monocular eye 2
    % iii.  - binocular
    % iv.   - dichoptic
    
    %Stim.eye 2 = right, 3 = left, 1 = both (bi or di), 
    %0 = when grating.blank is true -- not sure on this yet. seems to be 0
    %for when tiltmatch = 0 too.
       
% Find all trials that meet requirements
    %mR
    mR = I ...
        & STIM.monocular == 1 ...
        & STIM.eye == 2 ... 
        & ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0;


    
    %mL
    mL = I ...
        & STIM.monocular == 1 ...
        & STIM.eye == 3 ... 
        & ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0;
    
    %bi
    bi = I ...
        & STIM.monocular == 0 ...
        & STIM.eye == 1 ...
        & STIM.tiltmatch == 1 ...
        & ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0;
    
    %di
    di = I ...
        & STIM.monocular == 0 ...
        & STIM.eye == 0 ... 
        & STIM.tiltmatch == 0 ...
        & ~STIM.blank ...
        & STIM.rns == 0 ...
        & STIM.cued == 0 ...
        & STIM.motion == 0;
    
% Find number of trials presented for each condition


% Save important data
INFO(i).paradigm   = fileOut;
INFO(i).mR         = sum(mR);
INFO(i).mL         = sum(mL);
INFO(i).bi         = sum(bi);
INFO(i).di         = sum(di);

     
            
end

global SAVEDIR
cd(SAVEDIR)
save('INFO.mat','INFO','SALVAGE')

load gong
sound(y,Fs)

