% FullTimeClassicBRFS - update to use Gramm
clear
close all
PostSetup('BrockHome')
flag_SaveFigs = false;


%% Get IDX
if ~exist('D:\5 diIDX dir\IDXforGrammJuly2021.mat','file')
    IDXforGrammJuly2021
end
    load('D:\5 diIDX dir\IDXforGrammJuly2021.mat')
    
%% Goal - 
% 1. Take the new SingleSessionIDX code and use it to create IDX variables
% for all of the sessions where you have trial average and also individual
% trial data

% 2. Plot all previous figures but update the bar plots and line plots to the
% gramm plotting structure. This will require new visualization fuctions
% for each and perhaps restrucuting of the IDX variable? 

% 3. Make a new plot for Alex using the Gramm scatter stacker where we show
% the violin plots of the response wins (trans and sustained) that
% describes all of the different conditions of varying levels of "drive".

%%

dataType = 'z-scored';
visIDX_FullTmBRFS_AllCond(IDX,dataType)

% Save all plots
% Hopefully in an intelligent way that is doccumented on GitHub
if flag_SaveFigs
    FolderName = 'D:\6 Plot Dir\FullTm_160108_AllCond';   % Your destination folder
    cd(FolderName)
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = num2str(get(FigHandle, 'Number'));
      set(0, 'CurrentFigure', FigHandle);
      savefig(fullfile(FolderName, [FigName '.fig']));
      saveas(FigHandle,fullfile(FolderName, [FigName '.svg']));
    end
end


%% Plot and save re-trig
%Plot
close all
dataType = 'z-scored';
visIDX_FullTmBRFS_ReTrig(IDX,dataType)

%Save

if flag_SaveFigs
    FolderName = 'D:\6 Plot Dir\FullTm__160108_BRFSonlyreTrig';   % Your destination folder
    cd(FolderName)
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = num2str(get(FigHandle, 'Number'));
      set(0, 'CurrentFigure', FigHandle);
      savefig(fullfile(FolderName, [FigName '.fig']));
      saveas(FigHandle,fullfile(FolderName, [FigName '.svg']));
    end
end

%% Plot conditions as average of all units
close all
dataType = 'z-scored';
visIDX_FullTmBRFS_AllCond_AllContacts(IDX,dataType)
if flag_SaveFigs
    FolderName = 'D:\6 Plot Dir\FullTm_AllContacts_AllCond';   % Your destination folder
    cd(FolderName)
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = num2str(get(FigHandle, 'Number'));
      set(0, 'CurrentFigure', FigHandle);
      savefig(fullfile(FolderName, [FigName '.fig']));
      saveas(FigHandle,fullfile(FolderName, [FigName '.svg']));
    end
end

%% Plot dCOS as average of two IC
close all
dataType = 'z-scored';
visIDX_dCOSFig(IDX,dataType)
if flag_SaveFigs
    cd('D:\6 Plot Dir')
    saveas(gcf,'dCOS.svg')
end

%% Plot 2x2
close all
dataType = 'z-scored';
visIDX_2x2Fig(IDX,dataType)
if flag_SaveFigs
    FolderName = 'D:\6 Plot Dir\2x2';   % Your destination folder
    cd(FolderName)
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = num2str(get(FigHandle, 'Number'));
      set(0, 'CurrentFigure', FigHandle);
      savefig(fullfile(FolderName, [FigName '.fig']));
      saveas(FigHandle,fullfile(FolderName, [FigName '.svg']));
    end
end


%%

%%
%%
%% Get new untuned IDX -- This did not work as expected
% % clear
% % close all
% % dataType = 'z-scored';
% % if ~exist('D:\5 diIDX dir\diIDX_AUTO_halfTM_MedMedC_Untuned.mat','file')
% %     AUTOdiIDX_halfTM_MedMedC_Untuned
% % end
% %     load('D:\5 diIDX dir\diIDX_AUTO_halfTM_MedMedC_Untuned.mat')
% % % visIDX_EffectofTuning(IDX,dataType)




%% Get IDX
if ~exist('E:\5 diIDX dir\AUTOdiIDX_RESPonly_AllTMandAdaptedEffect.mat','file')
    AUTOdiIDX_RESPonly_AllTMandAdaptedEffect
end
    load('E:\5 diIDX dir\AUTOdiIDX_RESPonly_AllTMandAdaptedEffect.mat')

 flag_SaveFigs = false;
 close all
[rsq_simult,rsq_adapted] = visIDX_scatterRESPocc(IDX,flag_SaveFigs)



if ~exist('E:\5 diIDX dir\AUTOdiIDX_RESPonly_equiocularIncluded.mat','file')
    AUTOdiIDX_RESPonly_equiocularIncluded
end
    load('E:\5 diIDX dir\AUTOdiIDX_RESPonly_equiocularIncluded.mat')
close all


%% BMC new occular split analysis 4/30/2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 visIDX_scatterRESPocc_binnedOcc(IDX,flag_SaveFigs)
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


%% %% Bar plots on fig 2 and 3
% optional - use the incongruent stimulus with PS/DE rather than both IC
% stim.
% % bmcSuperBarAdaptation_ICPSDE(IDX)
bmcSuperBarAdaptation(IDX)

if flag_SaveFigs
    FolderName = 'D:\6 Plot Dir\dCOSand2x2BarPlots';   % Your destination folder
    cd(FolderName)
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1:length(FigList)
      FigHandle = FigList(iFig);
      FigName   = num2str(get(FigHandle, 'Number'));
      set(0, 'CurrentFigure', FigHandle);
      savefig(fullfile(FolderName, [FigName '.fig']));
      saveas(FigHandle,fullfile(FolderName, [FigName '.svg']));
    end
end
