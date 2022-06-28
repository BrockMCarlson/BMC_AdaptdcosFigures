% FullTimeClassicBRFS
clear
% % close all
PostSetup('BrockWork')
flag_SaveFigs = false;


%% Get IDX
% % % if ~exist('E:\5 diIDX dir\diIDX_AUTO_halfTM_MedMedC.mat','file')
% % %     AUTOdiIDX_halfTM_MedMedC
% % % end
global IDXDIR

    load(strcat(IDXDIR,'diIDX_AUTO_halfTM_MedMedC.mat'))


%% Plot Full time course for 1 ex day with physically identical stimulus
% Make sure that you plot each history
% Not exactly sure where the tm is set, but I need to make sure it is not
% cut down to 400 - this is where the cropping/padding algorythim that I
% don't totally understand is going to help or hurt me 
% I miiiiight skip this if it is too hard.

% Ok. 12.29.20 update. I am indeed going to skip this because, no matter
% what, making two tm lengths of SDF varibles will require different IDXes.
% I do want to do the full time IDX but im not sure if it will be too big
% of data and crash the computer. Also, I'm not sure if going past a second
% stimulus will create other issues in the code (it shouldent but I'm not
% sure) so I will tackle this later either. A) as a sanity check or B) if
% the re-trigger option does not line up well or does not look right.

% I made loose trials with this version as trials that did not go for 1800
% ms of fixation may not be kept. . Althought I know that these trials do
% exist becaus othersie the re-triggered brfs suppressor stimuli should be
% aborted.



%% Plot the same as above but re-triggered at second stimulus onset
% this is a sanity check to make sure I am not mis-finding the 
% This may be all I have (I guess I'll just have to start looking in order
% to know). 
% HOWEVER, an additional problem may be that all of the timecourses are cut
% at 400ms post stimulus onset and I cannot therefore represent the whole
% sequence without re-acquiring an IDX. I think this is correct.

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
% % % close all
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
% % % close all
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
% % % close all
dataType = 'z-scored';
visIDX_dCOSFig(IDX,dataType)
if flag_SaveFigs
    cd('D:\6 Plot Dir')
    saveas(gcf,'dCOS.svg')
end

%% Plot 2x2
% % close all
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




%% Get IDX
% if ~exist('E:\5 diIDX dir\AUTOdiIDX_RESPonly_AllTMandAdaptedEffect.mat','file')
%     AUTOdiIDX_RESPonly_AllTMandAdaptedEffect
% end
    load(strcat(IDXDIR,'AUTOdiIDX_RESPonly_AllTMandAdaptedEffect.mat'))
    

 flag_SaveFigs = false;
%  % % close all
[rsq_simult,rsq_adapted] = visIDX_scatterRESPocc(IDX,flag_SaveFigs)


% % 
% % if ~exist('E:\5 diIDX dir\AUTOdiIDX_RESPonly_equiocularIncluded.mat','file')
% %     AUTOdiIDX_RESPonly_equiocularIncluded
% % end
    load(strcat(IDXDIR,'AUTOdiIDX_RESPonly_equiocularIncluded.mat'))
    
% % % close all


%% BMC new occular split analysis 4/30/2021
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %  visIDX_scatterRESPocc_binnedOcc(IDX,flag_SaveFigs)
% % % % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


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
