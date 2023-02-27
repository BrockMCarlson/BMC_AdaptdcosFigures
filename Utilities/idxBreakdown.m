function numUnits = idxBreakdown(IDX,ERR)
% Total number of multi-unit channels
totalN = length(IDX.allV1) + length(ERR);

% Number of sessions
penetrationInIDX = {IDX.allV1.penetration}.';
penetrationInIDX_unique = unique(penetrationInIDX); % N = 14
penetrationInERR = {ERR.penetration}.';
penetrationInERR_unique = unique(penetrationInERR); % N = 19
    % total possible should be 19. Looks like every session as at least one
    % error, while ever session is not represented in the IDX var.
    missingFromIDX = penetrationInERR_unique(~ismember(penetrationInERR_unique,penetrationInIDX_unique));
        %     {'151221_E_eD'}  --- diana not run on unit
        %     {'151222_E_eD'}   --- diana not run on unit
        %     {'151231_E_eD'} --- diana not run on unit
        %     {'160102_E_eD'} --- diana not run on unit
        %     {'160204_I_eD'} --- NOT A SINGLE UNIT WAS TUNED?

% Session per monkey
numForE = sum(contains(penetrationInIDX_unique,'_E_'));
numForI = sum(contains(penetrationInIDX_unique,'_I_'));
 
% # of units tuned or not tuned on each session
idxPenetrationByUnit = {IDX.allV1.penetration}.';
errPenetrationByUnit = {ERR.penetration}.';
numUnits = table;
numUnits.penetration = penetrationInERR_unique;
% # Tuned
for i = 1:length(numUnits.penetration)
    sessionID = numUnits.penetration{i};
    numUnits.tunedUnits{i}      = sum(contains(idxPenetrationByUnit,sessionID));
    numUnits.untunedUnits{i}    = sum(contains(errPenetrationByUnit,sessionID));
    numUnits.total{i} = numUnits.tunedUnits{i} + numUnits.untunedUnits{i};
end
end