% plotIndividualSessionsFromIDX

clear
close all
PostSetup('BrockHome')
flag_SaveFigs = true;


%% Get IDX
global IDXDIR
cd(IDXDIR)
if ~exist(strcat(IDXDIR,'\IDX_iScienceSubmission.mat'),'file')
    IDX_iScienceSubmission
end
    load(strcat(IDXDIR,'\IDX_iScienceSubmission.mat'))
    
%% Loop through IDX, to plot individually
for i = 1:size(IDX.allV1,2)
    mPS_DE      = IDX.allV1(i).SDF_avg{1,1};
    mNS_NDE     = IDX.allV1(i).SDF_avg{2,1};
    mNS_DE      = IDX.allV1(i).SDF_avg{3,1};
    mPS_NDE     = IDX.allV1(i).SDF_avg{4,1};
    TM          = IDX.allV1(i).TM;
    
    
    figure
    subplot(2,2,1)
    plot(TM,mPS_DE)
    ylim([-.5 6])
    xlim([TM(1) .3])
    title('PS_DE','Interpreter','none')
    
    subplot(2,2,2)
    plot(TM,mPS_NDE)
    ylim([-.5 6])
    xlim([TM(1) .3])
    title('PS_NDE','Interpreter','none')
    
    subplot(2,2,3)
    plot(TM,mNS_DE)
    ylim([-.5 6])
    xlim([TM(1) .3])
    title('NS_DE','Interpreter','none')
    
    subplot(2,2,4)
    plot(TM,mNS_NDE)
    ylim([-.5 6])
    xlim([TM(1) .3])
    title('NS_NDE','Interpreter','none')
    
    depthName = strcat('depth=',string(IDX.allV1(i).depth(2)));
    sgtitle({IDX.allV1(i).penetration;depthName},'Interpreter','none');
    
end


%% Loop through IDX, to plot average (w/out Gramm)
close all
monocLine = nan(size(IDX.allV1,2),length(IDX.allV1(1).TM));
diopticSimultPS = nan(size(IDX.allV1,2),length(IDX.allV1(1).TM));

for i = 1:size(IDX.allV1,2)
    monocLine(i,:)      = IDX.allV1(i).SDF_avg{1,1}; 
    if ~isempty(IDX.allV1(i).SDF_avg{5,1})
        diopticSimultPS(i,:)      = IDX.allV1(i).SDF_avg{5,1}; 
    end

    
end
monocAVGERAGE = nanmean(monocLine,1);
dopticSimultPSAVERAGE = nanmean(diopticSimultPS,1);
TM          = IDX.allV1(1).TM;   
figure
plot(TM,monocAVGERAGE);
hold on
plot(TM,dopticSimultPSAVERAGE)
ylim([-.5 6])
xlim([TM(1) .3])
vline(0)
title('average','Interpreter','none')
legend('monoc PS DE','dioptic simult PS')