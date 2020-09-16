% PlotSessionData_adaptdcos.m
% 10 plots. 5 at half contrast DE, 5 at max contrast DE.
% In order of the 5 figures we want to show...
% Monoc; Binoc_Simult; Binoc_Adapt; Dichop_Simult; Dichop_Adapt;
%%%%%%%%%%%%%%%%%%%%%%%

%%% SDF-row4; SDF-row5; SDF_adapt-row5; SDF-row6; SDF_adapt-row6;
%%% SDF-row1; SDF-row2; SDF_adapt-row2; SDF-row3; SDF_adapt-row3;


clear
close all

flag_savefigs = 1;
figDir = 'C:\Users\Brock\Documents\VSS2 2020 figs Lenovo\adaptdcosSessionData_Lenovo';

IDXdir = 'C:\Users\Brock\Documents\MATLAB';
cd(IDXdir)
load('testIDX.mat')

titleVec = {'Monoc','Binoc_Simult','Binoc_Adapt','Di_Simult','Di_Adapt',...
            'Monoc','Binoc_Simult','Binoc_Adapt','Di_Simult','Di_Adapt'}';

for uct = 1:length(IDX)
 
  close all
   TM = IDX(uct).tm;
   unitInfo = {...
       strcat(IDX(uct).header,'-','Depth=',num2str(IDX(uct).depth(2)),'-','Kls=',num2str(IDX(uct).kls))...
       strcat('diana=',num2str(IDX(uct).diana),'-','prefeye=',num2str(IDX(uct).prefeye),'-','prefori=',num2str(IDX(uct).prefori))...
       strcat('occ p value, subselected AND Balanced=',num2str(IDX(uct).occ(1)))};
   
   clear plotThis
   plotThis = nan(10,350);
   % Half Contrast in DE
        % Monoc
            plotThis(1,:)       = IDX(uct).SDF(4,:);
        % Binocular
            % Simultaneous
                plotThis(2,:)	= IDX(uct).SDF(5,:);    
            % Adapted
                plotThis(3,:)	= IDX(uct).SDF_adapt(5,:);
                
        % Dichoptic
            % Simultaneous
                plotThis(4,:) 	= IDX(uct).SDF(6,:);    
            % Adapted
                plotThis(5,:)	= IDX(uct).SDF_adapt(6,:);
        
   % Max Contrast in DE
        % Monoc
            plotThis(6,:)       = IDX(uct).SDF(1,:);
        % Binocular
            % Simultaneous
                plotThis(7,:)	= IDX(uct).SDF(2,:);    
            % Adapted           
                plotThis(8,:)	= IDX(uct).SDF_adapt(2,:);
        % Dichoptic
            % Simultaneous           
                plotThis(9,:) 	= IDX(uct).SDF(3,:);    
            % Adapted            
                plotThis(10,:)	= IDX(uct).SDF_adapt(3,:);
 
   maxVal = max(plotThis,[],'all','omitnan');
   if isnan(maxVal) 
        disp('maxVal is NaN for uct')
        disp(uct)
        maxVal = 150;
   end
   
   figure
       for i = 1:10
            s(i) = subplot(2,5,i);
            plot(TM,plotThis(i,:)) 
            ylim([0 maxVal])
            vline(0)
            title(s(i),titleVec(i),'Interpreter','none')
       end
       ylabel(s(1),'half contrast')
       ylabel(s(6),{'max contrast','Imp/sec'})
       xlabel(s(6),'sec')
       sgtitle(unitInfo,'Interpreter','none')
       
   if flag_savefigs
       cd(figDir)
        if uct == 1
        	export_fig('adaptdcos_EveryUnit','-pdf','-nocrop') 
        else
            export_fig('adaptdcos_EveryUnit','-pdf','-nocrop','-append')
        end
   end
           
end