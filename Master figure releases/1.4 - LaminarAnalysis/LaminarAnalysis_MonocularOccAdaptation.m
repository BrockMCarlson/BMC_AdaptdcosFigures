% 1.4.2 Laminar Analysis - Monocular Occularity adaptation
clear
close all
PostSetup('brock')
flag_SaveFigs = true;

%% Goal --
% Do the responses of the two eyes eventually normalize to each other?
% What does this look like across the layers?
% Is that time point before or after 200ms? before 800ms?
% What can we leverage against the timecourse of adaptation vs occularity?


%% Get IDX - response only (no SDF)


% Full Time Course IDX
cd('E:\5 diIDX dir\')
if ~exist('E:\5 diIDX dir\diIDX_AUTO_monocOccCompare.mat','file')
    AUTOdiIDX_monocOccCompare
end
error('THIS DOES NOT WORK')

%%%%%%%%%%%%%%%%%%
%%% BMC MAKE EDITS SO THE MONOC DOES NOT COME OUT AS NANs %%
%%%%%%
    load('E:\5 diIDX dir\diIDX_AUTO_monocOccCompare.mat')


%% Vis code - gram X~Y with categorical X

dataType = 'z-scored';
visIDX_monocPlots(IDX,dataType)



