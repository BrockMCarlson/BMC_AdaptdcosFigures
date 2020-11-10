%% visIDX_IndividualSession.m
% from visIDX_fullTime


%%
% Find a way to take the first triggered stim and the second triggered and
% knit them together. This will need to be taken from the new IDX variable
% that I just made



%%
clear
close all

flag_savefigs   = 0;

IDXdir = 'C:\Users\Brock\Documents\MATLAB\GitHub\ephys-analysis\dichoptic\adaptdcos\PairwiseComp';

IDXtextStr = 'diIDX_IndividualSession.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);

figDir = IDXdir;
figName = strcat('diIDX_IndividualSession.pdf'); 

if flag_savefigs
    cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end
end

TM = IDX.tm;


% Dimension are (layer, condition, window, contrast, SDF/SEM/STD/%Change/Subtraction)

for uct = 1:uctLength
clear PlotThis HoldThis
PlotThis.SDF_A = IDX(uct).SDF_A;
PlotThis.SDF_S = IDX(uct).SDF_S;
HoldThis.CI_A = IDX(uct).CI_A;
HoldThis.CI_S = IDX(uct).CI_S;
PlotThis.SDF_monoc = IDX(uct).SDF_monoc;
HoldThis.CI_monoc = IDX(uct).CI_monoc;

if ~isnan(IDX(uct).dianov(2))
   oriPval = num2str(IDX(uct).dianov(2));
elseif isnan(IDX(uct).dianov(2))
   oriPval = num2str(IDX(uct).ori(1));
end
unitInfo = {...
   strcat(IDX(uct).header,'---','Depth=',num2str(IDX(uct).depth(2)),'----','Kls=',num2str(IDX(uct).kls))...
   strcat('DE=',num2str(IDX(uct).DE),'----','PS=',num2str(IDX(uct).PS),'-----','anova p val for prefori=',oriPval)};





%% Get out variance lines
% 8 conditions
clear a
for a = 1:size(HoldThis.CI_A,1)
    PlotThis.SEMline_Up_A(a,:) = PlotThis.SDF_A(a,:) + HoldThis.CI_A(a,:);
    PlotThis.SEMline_Dn_A(a,:) = PlotThis.SDF_A(a,:) + HoldThis.CI_A(a,:);
    PlotThis.SEMline_Up_S(a,:) = PlotThis.SDF_S(a,:) + HoldThis.CI_S(a,:);
    PlotThis.SEMline_Dn_S(a,:) = PlotThis.SDF_S(a,:) + HoldThis.CI_S(a,:);
end
clear a
for a = 1:4
    PlotThis.SEMline_Up_monoc(a,:) = PlotThis.SDF_monoc(a,:) + HoldThis.CI_monoc(a,:);
    PlotThis.SEMline_Dn_monoc(a,:) = PlotThis.SDF_monoc(a,:) + HoldThis.CI_monoc(a,:);
end




%% Set Parameters for Plot
maxYval_A = max(max(PlotThis.SDF_A));
maxYval_S = max(max(PlotThis.SDF_S));
maxYval = max(maxYval_A,maxYval_S);
if isnan(maxYval)
    maxYval = 150;
end
conditNameA = {...
    'adpDExPS_flC',...
    'adpNDExPS_flC',...
    'adpDExNS_flC',...
    'adpNDExNS_flC',...
    'adpDExPS_flIC',...
    'adpNDExPS_flIC',...
    'adpDExNS_flIC',...
    'adpNDExNS_flIC',...
    };

conditNameS = {...
    'adpC_flNDExPS',...
    'adpC_flDExPS',...
    'adpC_flNDExNS',...
    'adpC_flDExNS',...
    'adpIC_flNDExNS',...
    'adpIC_flDExNS',...
    'adpIC_flNDExPS',...
    'adpIC_flDExPS_flIC',...
    };


%% Plot
close all

monoccond = {'DExPS','NDExPS','DExNS','NDExNS'};
figure
clear i
for i = 1:4
   subplot(2,2,i)
    plot(TM,PlotThis.SDF_monoc(i,:),'-b','LineWidth',2); hold on
    plot(TM,PlotThis.SEMline_Up_monoc(i,:),':m','LineWidth',1); hold on
    plot(TM,PlotThis.SEMline_Dn_monoc(i,:),':m','LineWidth',1); hold on
    ylim([0 maxYval*1.5]);
    xlim([-.05 .2]);
    vline(0)
    title(monoccond(i), 'interpreter', 'none')
end

    sgtitle(unitInfo,'Interpreter','none')
    set(gcf,'Position',[185.4000 103.4000 862.6000 658.6000])


if flag_savefigs
   cd(figDir)
    if uct == 1
        export_fig('adaptdcos_EveryUnit','-pdf','-nocrop') 
    else
        export_fig('adaptdcos_EveryUnit','-pdf','-nocrop','-append')
    end
end



close all
subplotdim = [2 1 4 3 8 7 6 5];
count = 0;


figure
clear i
for i = 1:8
count = count + 1;
subplot(4,4,count)
plot(TM,PlotThis.SDF_A(subplotdim(i),:),'-b','LineWidth',2); hold on
plot(TM,PlotThis.SEMline_Up_A(subplotdim(i),:),':m','LineWidth',1); hold on
plot(TM,PlotThis.SEMline_Dn_A(subplotdim(i),:),':m','LineWidth',1); hold on
ylim([0 maxYval*1.5]);
xlim([-.05 .8]);
vline(0)
title(conditNameA(subplotdim(i)), 'interpreter', 'none')

count = count + 1;
subplot(4,4,count)
plot(TM,PlotThis.SDF_S(subplotdim(i),:),'-b','LineWidth',2); hold on
plot(TM,PlotThis.SEMline_Up_S(subplotdim(i),:),':m','LineWidth',1); hold on
plot(TM,PlotThis.SEMline_Dn_S(subplotdim(i),:),':m','LineWidth',1); hold on
ylim([0 maxYval*1.5]);
xlim([-.05 .8]);
vline(0)
title(conditNameS(subplotdim(i)), 'interpreter', 'none')
end

    sgtitle(unitInfo,'Interpreter','none')
    set(gcf,'Position',[1 41 1536 755.2000])



if flag_savefigs
   cd(figDir)
    if uct == 1
        export_fig('adaptdcos_EveryUnit','-pdf','-nocrop') 
    else
        export_fig('adaptdcos_EveryUnit','-pdf','-nocrop','-append')
    end
end 
end




        








     
 