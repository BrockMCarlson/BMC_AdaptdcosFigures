%visIDX_2x2
%   Simply plot 2x2 for every unit. 145 units.

clear
close all

flag_savefigs = 0;

IDXdir = 'G:\LaCie\Adaptdcos figs\adaptdcosCompareConditions';

IDXtextStr = 'IDX_FULLUnitAna.mat';
cd(IDXdir)
load(IDXtextStr)
uctLength = length(IDX);
clear IDX

figDir = 'G:\LaCie\Adaptdcos figs\adaptdcosCompareConditions\all2x2plots';
figName = strcat('2x2.pdf'); 
   cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
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
   
   titleVec = {strcat('PSxDE','-n=',num2str(UNITSTRUCT.monocTrlNum(1))),...
            strcat('NSxDE','-n=',num2str(UNITSTRUCT.monocTrlNum(2))),...
            strcat('PSxNDE','-n=',num2str(UNITSTRUCT.monocTrlNum(3))),...
            strcat('NSxNDE','-n=',num2str(UNITSTRUCT.monocTrlNum(4)))}';
   
 
SEMline = nan(4,350,2);
for a = 1:4
    SEMline(a,:,1) = UNITSTRUCT.monocSDF(a,:) + UNITSTRUCT.monocSEM(a,:);
    SEMline(a,:,2) = UNITSTRUCT.monocSDF(a,:) - UNITSTRUCT.monocSEM(a,:);
end
                
   maxVal = max(UNITSTRUCT.monocSDF,[],'all','omitnan');
   if isnan(maxVal) 
        disp('maxVal is NaN for uct')
        disp(uct)
        maxVal = 150;
   end


 figure
       for i = 1:4
            s(i) = subplot(2,2,i);
            plot(TM,UNITSTRUCT.monocSDF(i,:),'-b','LineWidth',2); hold on
            plot(TM,SEMline(i,:,1),':m','LineWidth',1); hold on
            plot(TM,SEMline(i,:,2),':m','LineWidth',1);
            ylim([0 maxVal])
            xlim([-.05 .3])
            vline(0)
            title(s(i),titleVec(i),'Interpreter','none')
       end

       ylabel(s(1),{'max contrast','Imp/sec'})
       xlabel(s(3),'sec')
       sgtitle(unitInfo,'Interpreter','none')
       set(gcf, 'Position',[227 123.8000 821 638.2000])
       
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