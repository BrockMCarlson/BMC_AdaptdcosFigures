%% What is missing between the old IDX and the newIDX?

%oldIDX - vector var that lists identifier by unit
oldIDX = load('D:\5 diIDX dir\IDX_iScienceSubmission.mat');
oldPenetration = {oldIDX.IDX.allV1.penetration}.';
oldPenetration(:,2) = {oldIDX.IDX.allV1.depth}.';
for i = 1:size(oldPenetration,1)
    oldPenetration{i,3} = oldPenetration{i,2}(3);
end
oldIdentifier = strcat(oldPenetration(:,1),'-depth_',string(oldPenetration(:,3)));





%newIDX - vector var that lists identifier by unit
newIDX = load('S:\FormattedDataOutputs\IDX_iScienceSubmission.mat');
newPenetration = {newIDX.IDX.allV1.penetration}.';
newPenetration(:,2) = {newIDX.IDX.allV1.depth}.';
for i = 1:size(newPenetration,1)
    newPenetration{i,3} = newPenetration{i,2}(3);
end
newIdentifier = strcat(newPenetration(:,1),'-depth_',string(newPenetration(:,3)));



%% Set Diff
 % returns the data in A that is not in B, with no repetitions. C is in sorted order.
 oldIdentNotInNewIdent = setdiff(oldIdentifier,newIdentifier);
 newIdentNotInOldIdent = setdiff(newIdentifier,oldIdentifier);
 
%% Overlap between new and old
 mutualLogical = contains(oldIdentifier,newIdentifier);
mutual = oldIdentifier(mutualLogical);
 
%% Mutual Errors
oldERR = {oldIDX.ERR.penetration}.';
oldERR(:,2) = {oldIDX.ERR.depthFromSinkBtm}.';
oldERRIdentifier = strcat(oldERR(:,1),'-depth_',string(oldERR(:,2)));

newERR = {newIDX.ERR.penetration}.';
newERR(:,2) = {newIDX.ERR.depthFromSinkBtm}.';
newERRIdentifier = strcat(newERR(:,1),'-depth_',string(newERR(:,2)));

 mutualErrorsLogical = contains(oldERRIdentifier,newERRIdentifier);
mutualErrors = oldERRIdentifier(mutualErrorsLogical);