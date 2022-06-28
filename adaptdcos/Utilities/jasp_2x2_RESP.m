function dataForJASP = jasp_2x2_RESP(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM(1:560);

clear DataForJASP

count = 0;
uctLength = length(IDX.allV1);
DataForJASP = nan(uctLength,4);


for uct = 1:uctLength
   DataForJASP(uct,1) = IDX.allV1(uct).RESP_avg{5}(1); %binocular congruent, transient period
   DataForJASP(uct,2) = IDX.allV1(uct).RESP_avg{7}(1); %Dichoptic, transient period
   DataForJASP(uct,3) = IDX.allV1(uct).RESP_avg{10}(1); %Binoc Adapted, transient period
   DataForJASP(uct,4) = IDX.allV1(uct).RESP_avg{18}(1); %Dichop Adapted, transient perio

end

[rows, columns] = find(isnan(DataForJASP));
UnitsWithoutAllConditions = unique(rows);
UnitsWithAllConditions = setdiff(1:uctLength,UnitsWithoutAllConditions);

outputData = DataForJASP(UnitsWithAllConditions,:);

csvwrite('outputForJASP_2x2.csv',outputData) 






end

