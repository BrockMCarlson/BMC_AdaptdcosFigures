% 1.4.1 Laminar Analysis - dII_laminarViolin
clear
close all
PostSetup('brock')
flag_SaveFigs = true;

%% Goal --
% Make violin plots using Gramm
% Violin Plots of dII with x categorical of transient and sustained.
% "Stacked plot" at supragranular, granular, and infraganular levels.
% In Gramm these do not need to be stacked plots.
    % Gramm "Methods for visualizing Y~X relationships with X as
    % categorical variable"
    


%% Get IDX - response only (no SDF)
if ~exist('E:\5 diIDX dir\AUTOdiIDX_RESPonly_AllTMandAdaptedEffect.mat','file')
    AUTOdiIDX_RESPonly_AllTMandAdaptedEffect
end
    load('E:\5 diIDX dir\AUTOdiIDX_RESPonly_AllTMandAdaptedEffect.mat')

%     % Full Time Course IDX
%     cd('E:\5 diIDX dir\')
%     if ~exist('E:\5 diIDX dir\diIDX_AUTO_halfTM_MedMedC.mat','file')
%         AUTOdiIDX_halfTM_MedMedC
%     end
%         load('E:\5 diIDX dir\diIDX_AUTO_halfTM_MedMedC.mat')
% 

%% Vis code - gram X~Y with categorical X


violinPlots(IDX,flag_SaveFigs)



