%visIDX_CompareConditions
% Make the bar-plots of 8 comparisons


clear
close all

flag_savefigs = 0;

IDXdir = 'C:\Users\Brock\Documents\adaptdcos figs';

IDXtextStr = 'IDX_FULLUnitAna.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);
clear IDX

if flag_savefigs == 1
    figDir = 'G:\LaCie\Adaptdcos figs';
    figName = strcat('Comparecond_sub.pdf'); 
       cd(figDir)
        if isfile(figName) && flag_savefigs
            error('figure already exists')        
        end
end


        
for uct = 1:uctLength
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
   TM = UNITSTRUCT.tm;
   if ~isnan(UNITSTRUCT.dianov(2))
       oriPval = num2str(UNITSTRUCT.dianov(2));
   elseif isnan(UNITSTRUCT.dianov(2))
       oriPval = num2str(UNITSTRUCT.ori(1));
   end
   unitInfo = {...
       strcat(UNITSTRUCT.header,'---','Depth=',num2str(UNITSTRUCT.depth(2)),'----','Kls=',num2str(UNITSTRUCT.kls))...
        strcat('Dom Eye for uct=',num2str(UNITSTRUCT.prefeye))...
        strcat('prefori for uct=',num2str(UNITSTRUCT.prefori),'----','anova p val for prefori=',oriPval)...
        strcat('nullori for uct=',num2str(UNITSTRUCT.nullori))};
   
maxYval = max(max(max(abs(UNITSTRUCT.Subtraction))));
if isnan(maxYval)
    continue
end

 figure
 count = 0;
 for c = 1:2
       for win = 1:3
           count = count+1;
            s(count) = subplot(2,3,count);
            
            x1 = UNITSTRUCT.Subtraction(:,win,c);
            bar(x1,.8,'FaceColor',[0.8500, 0.3250, 0.0980],'EdgeColor','k','LineWidth',0.8);
            ylim([-maxYval maxYval])
            xticklabels({'A','B','C','D','E','F','G','H'})

       end
 end
       ylabel(s(1),{'half contrast','Simult-Adapted'}) 
       ylabel(s(4),{'max contrast','Simult-Adapted'}) 
       xlabel(s(4),{'Conditions compared','transient'})
       xlabel(s(5),{'Conditions compared','sustained'})
       xlabel(s(6),{'Conditions compared','fullWindow'})
       sgtitle(unitInfo,'Interpreter','none')
       set(gcf, 'Position',[227 123.8000 821 638.2000])
%        annotation('textbox',[.8 .9 .1 .1],'String',conditionN,'FitBoxToText','on')
  
       if flag_savefigs
       cd(figDir)

        if uct == 1
        	export_fig(figName,'-pdf','-nocrop') 
        else
            export_fig(figName,'-pdf','-nocrop','-append')
        end
   end

    
end


load gong
sound(y,Fs)