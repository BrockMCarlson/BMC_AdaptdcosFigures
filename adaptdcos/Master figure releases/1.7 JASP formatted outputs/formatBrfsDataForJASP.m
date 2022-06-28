clear
close all
PostSetup('BrockWork')
flag_SaveFigs = false;


%% Get IDX
global IDXDIR
cd(IDXDIR)
% % if ~exist(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'),'file')
% %     IDXforGrammJuly2021
% % end
load(strcat(IDXDIR,'\IDXforGrammJuly2021.mat'))

%% JASP conversion
% JASP requires each unit to be in a row vector with each column as the
% different conditions.
% Currently each row of IDX.allV1 is for its own unit (that's good).
% IDX.allV1.RESP_avg contains a 24x1 cell, where each cell contains the
% average for all 4 time periods of the RESP vector. 
% We have 24 potential conditions
% The output required are 88 x 24 arrays.
% We need 1 array for the transient period and 1 array for the sustained.
% win_ms is [transient, sustained, whole time, baseline]

numberOfUnits = size(IDX.allV1,2);

for i = 1:numberOfUnits
    for j = 1:24
        outputForJASP_transient(i,j) = IDX.allV1(i).RESP_avg{j}(1);
        outputForJASP_sustained(i,j) = IDX.allV1(i).RESP_avg{j}(2);
    end
end

%% Writetable
% Now we need to export these values to .csv for JASP import. It would be
% great if I did not have to input 24 condition labels by hand

conditionLabels = IDX.allV1(1).condition;
conditionNames = conditionLabels.Properties.RowNames;
outputForJASP_transient_table = array2table(outputForJASP_transient);
outputForJASP_sustained_table = array2table(outputForJASP_sustained);

outputForJASP_transient_table.Properties.VariableNames = conditionNames;
outputForJASP_sustained_table.Properties.VariableNames = conditionNames;

global OUTDIR
cd(OUTDIR)
writetable(outputForJASP_transient_table,'outputForJASP_transient_table.csv')
writetable(outputForJASP_sustained_table,'outputForJASP_sustained_table.csv')
