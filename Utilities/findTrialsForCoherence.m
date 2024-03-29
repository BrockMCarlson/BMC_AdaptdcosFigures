function [congruentTrls, incongruentTrls]...
    = findTrialsForCoherence(STIM,PS)
% Pull trials from STIM for use in mscohere or wcoherence

        trls = I &...
            SORTED.tilts(:,1) == conditionarray(cond,2) & ...
            STIM.tiltmatch == conditionarray(cond,3) & ...
            STIM.adapter   == conditionarray(cond,4) & ...  
            STIM.suppressor   == conditionarray(cond,5) & ...
            STIM.soa       == conditionarray(cond,6) & ...
            STIM.monocular == conditionarray(cond,7) & ...
            ((SORTED.contrasts(:,1)  >= .3) & (SORTED.contrasts(:,1)  <= .6 )) &...
            ((SORTED.contrasts(:,2)  >= .3) & (SORTED.contrasts(:,2)  <= .6 ));


%congruentTrls
congruentTrls=  ~STIM.blank & ...
    contains(STIM.task,'brfs') &...
    STIM.tiltmatch  == 1 &...
    STIM.tilt(1)  ==  PS &...
    STIM.adapter    == 0 & ...  
    STIM.suppressor == 0 & ...
    STIM.soa        == 0 & ...
    STIM.monocular  == 0;

%incongruentTrls
incongruentTrls=  ~STIM.blank & ...
    contains(STIM.task,'brfs') &...
    STIM.tiltmatch  == 0 &...
    STIM.adapter    == 0 & ...  
    STIM.suppressor == 0 & ...
    STIM.soa        == 0 & ...
    STIM.monocular  == 0;

sum(congruentTrls)
sum(incongruentTrls)


end