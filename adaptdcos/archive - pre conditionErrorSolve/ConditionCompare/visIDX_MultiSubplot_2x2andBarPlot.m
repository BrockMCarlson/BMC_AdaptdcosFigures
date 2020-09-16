%visIDX_MultiSubplot_2x2andBarPlot

% SDFs for all 8 conditions shown. Subtraction of the SDFs shown below.
% Subtract the adapted response from the simultaneous response. Show 2x2
% plot below that. Display the N for each condition above it. Show the
% Subtraction bar graphs for three time windows to the left.

clear
close all

flag_savefigs = 1;
IDXdir = 'C:\Users\Brock\Documents\adaptdcos figs';
figDir = 'C:\Users\Brock\Documents\adaptdcos figs\adaptdcosSessionData_Lenovo';
IDXtextStr = 'IDX_FULLUnitAna.mat';

cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);
clear IDX

if flag_savefigs == 1
    figName = strcat('FullUnitAna_wLabels_2x2fix.pdf'); 
       cd(figDir)
        if isfile(figName) && flag_savefigs
            error('figure already exists')        
        end
end

conditName = {'PE,PS,C','NE,PS,C','PE,NS,C','NE,NS,C',...
    'PE,PS,IC','NE,PS,IC','PE,NS,IC','NE,NS,IC'};


% loop for length of units
for uct = 1:uctLength
    %Get necessary variables
    X = [' unit # ',num2str(uct)];
    disp(X)
    cd(IDXdir)
    load(IDXtextStr)
    UNITSTRUCT = IDX(uct);
    clear IDX
        if flag_savefigs
        close all
    end
    if UNITSTRUCT.kls == 1
        error('not currently equiped to handle KLS')
    end
   TM = -99:1:250;
   if ~isnan(UNITSTRUCT.dianov(2))
       oriPval = num2str(UNITSTRUCT.dianov(2));
   elseif isnan(UNITSTRUCT.dianov(2))
       oriPval = num2str(UNITSTRUCT.ori(1));
   end
   unitInfo = {...
       strcat(UNITSTRUCT.header,'---','Depth=',num2str(UNITSTRUCT.depth(2)),'----','Kls=',num2str(UNITSTRUCT.kls))...
        strcat('anova p val for prefori=',oriPval)};
   
   titleVec_2x2 = {strcat('PSxDE','-n=',num2str(UNITSTRUCT.monocTrlNum(1))),...
            strcat('NSxDE','-n=',num2str(UNITSTRUCT.monocTrlNum(2))),...
            strcat('PSxNDE','-n=',num2str(UNITSTRUCT.monocTrlNum(3))),...
            strcat('NSxNDE','-n=',num2str(UNITSTRUCT.monocTrlNum(4)))}';
   

    %Perform necessary calculations
    SEMline_2x2 = nan(4,350,2);
    for a = 1:4
        SEMline_2x2(a,:,1) = UNITSTRUCT.monocSDF(a,:) + UNITSTRUCT.monocSEM(a,:);
        SEMline_2x2(a,:,2) = UNITSTRUCT.monocSDF(a,:) - UNITSTRUCT.monocSEM(a,:);
    end
    
    SEMline_dcos = nan(16,350,2);
    for b = 1:16
        SEMline_dcos(b,:,1) = UNITSTRUCT.CondMeanSDF(b,1:350,1) + UNITSTRUCT.CondMeanSEM(b,1:350,1);
        SEMline_dcos(b,:,2) = UNITSTRUCT.CondMeanSDF(b,1:350,1) - UNITSTRUCT.CondMeanSEM(b,1:350,1);
    end
     
   maxVal_2x2 = max(UNITSTRUCT.monocSDF,[],'all','omitnan');
   if isnan(maxVal_2x2) 
        disp('maxVal is NaN for uct')
        disp(uct)
        maxVal_2x2 = 150;
   end
    
   maxYval_sub = max(max(max(abs(UNITSTRUCT.SubtractionSDF))));
    if isnan(maxYval_sub)
        continue
    end
    %Massive SubPlot
    figure
    clear i j k
    for i = 1:16
        subplot(5,8,i)
        plot(TM,UNITSTRUCT.CondMeanSDF(i,1:350,1),'-b','LineWidth',2); hold on                
        plot(TM,SEMline_dcos(i,:,1),':m','LineWidth',.8); hold on
        plot(TM,SEMline_dcos(i,:,2),':m','LineWidth',.8);
        ylim([0 maxVal_2x2*1.2])
        vline(0)
        if i < 9
            title(conditName(i))
        end
        if i == 1
            ylabel('simultaneous')
        elseif i == 9
            ylabel('adapted')
        end
    end
    for j = 1:8
        subplot(5,8,j+16)
        plot(TM,UNITSTRUCT.SubtractionSDF(j,1:350,1),'-b','LineWidth',1); hold on
        ylim([-maxYval_sub*1.2 maxYval_sub*1.2])
        vline(50)
        hline(0)
        xticklabels([-50 50 150 250])
        if j == 1
            ylabel('subtraction')
        end
    end
    clear position
    for k = 1:4
        if k == 1
            position = 25;
        elseif k ==2
            position = 26;
        elseif k == 3 
            position = 33;
        elseif k == 4 
            position = 34;
        end
            
        s(position) = subplot(5,8,position);
        plot(TM,UNITSTRUCT.monocSDF(k,:),'-b','LineWidth',2); hold on
        plot(TM,SEMline_2x2(k,:,1),':m','LineWidth',1); hold on
        plot(TM,SEMline_2x2(k,:,2),':m','LineWidth',1);
        ylim([0 maxVal_2x2*1.2])
        vline(0)
        
        if k == 1
            title('Pref Stim')
            ylabel('Dom Eye')
        elseif k ==2
            title('Null Stim')
        elseif k == 3 
            ylabel({'Imp/sec','Null Eye'})
        end
        
    end

       xlabel(s(33),'sec')
       
    clear position
    for win = 1:3
        if win == 1
            position = [27 28 35 36];
        elseif win ==2
            position = [29 30 37 38];
        elseif win == 3 
            position = [31 32 39 40];
        end
            subplot(5,8,position);
            
            x1 = UNITSTRUCT.Subtraction(:,win,1);
            bar(x1,.8,'FaceColor',[0.8500, 0.3250, 0.0980],'EdgeColor','k','LineWidth',0.8);
            ylim([-maxYval_sub maxYval_sub])
            xticklabels({'A','B','C','D','E','F','G','H'})

    end
    
    % figure properties
    
    sgtitle(unitInfo,'Interpreter','none')
    set(gcf, 'Position',[1 41 1536 755.2000])
    
    
    
       if flag_savefigs
       cd(figDir)

            if uct == 1
                export_fig(figName,'-pdf','-nocrop') 
            else
                export_fig(figName,'-pdf','-nocrop','-append')
            end
        end
    
    
end


 
