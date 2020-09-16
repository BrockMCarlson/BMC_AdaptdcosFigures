% visIDX_constrainOri.m



clear
close all

sessionNum = '160427'; % change every session
BMCprefori = 30; % Change this each session
BMCnullori = 120; % Change this each session
BMCprefeye = 2;
BMCnulleye = 3;




flag_savefigs = 1;

IDXdir = 'G:\LaCie\Adaptdcos figs\adaptdcosSessionData\SessionMatFiles';
cd(IDXdir)
load(strcat('IDXadaptdcos_session',sessionNum,'_IDX.mat'))

figDir = 'G:\LaCie\Adaptdcos figs\adaptdcosSessionData';
figName = strcat('IDXadaptdcos_session',sessionNum,'_line.pdf'); 
   cd(figDir)
    if isfile(figName) && flag_savefigs
        error('figure already exists')        
    end


        
        
for uct = 1:length(IDX)
    if flag_savefigs
        close all
    end
    if IDX(uct).kls == 1
        continue
    end
   TM = IDX(uct).tm;
   if ~isnan(IDX(uct).dianov(2))
       oriPval = num2str(IDX(uct).dianov(2));
   elseif isnan(IDX(uct).dianov(2))
       oriPval = num2str(IDX(uct).ori(1));
   end
   unitInfo = {...
       strcat(IDX(uct).header,'---','Depth=',num2str(IDX(uct).depth(2)),'----','Kls=',num2str(IDX(uct).kls))...
       strcat('Main Ori set in MonkeyLogic=',num2str(BMCprefori))...
       strcat('prefori for uct=',num2str(IDX(uct).prefori),'----','anova p val for prefori=',oriPval)};
   
   titleVec = {strcat('Monoc','-n=',num2str(IDX(uct).trlNum(4))),...
            strcat('Binoc_Simult','-n=',num2str(IDX(uct).trlNum(5))),...
            strcat('Binoc_Adapt','-n=',num2str(IDX(uct).trlNum_adapt(5))),...
            strcat('Di_Simult','-n=',num2str(IDX(uct).trlNum(6))),...
            strcat('Di_Adapt','-n=',num2str(IDX(uct).trlNum_adapt(6))),...
            strcat('Monoc','-n=',num2str(IDX(uct).trlNum(1))),...
            strcat('Binoc_Simult','-n=',num2str(IDX(uct).trlNum(2))),...
            strcat('Binoc_Adapt','-n=',num2str(IDX(uct).trlNum_adapt(2))),...
            strcat('Di_Simult','-n=',num2str(IDX(uct).trlNum(3))),...
            strcat('Di_Adapt','-n=',num2str(IDX(uct).trlNum_adapt(3)))}';
   
   clear plotThis
   plotThis = nan(10,350);
%%%%% -- SDF   
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
 
%%%%% -- SEM  
   % Half Contrast in DE
        % Monoc
            plotThis_SEM(1,:)       = IDX(uct).rSEM(4,:);
        % Binocular
            % Simultaneous
                plotThis_SEM(2,:)	= IDX(uct).rSEM(5,:);    
            % Adapted
                plotThis_SEM(3,:)	= IDX(uct).rSEM_adapt(5,:);
                
        % Dichoptic
            % Simultaneous
                plotThis_SEM(4,:) 	= IDX(uct).rSEM(6,:);    
            % Adapted
                plotThis_SEM(5,:)	= IDX(uct).rSEM_adapt(6,:);
        
   % Max Contrast in DE
        % Monoc
            plotThis_SEM(6,:)       = IDX(uct).rSEM(1,:);
        % Binocular
            % Simultaneous
                plotThis_SEM(7,:)	= IDX(uct).rSEM(2,:);    
            % Adapted           
                plotThis_SEM(8,:)	= IDX(uct).rSEM_adapt(2,:);
        % Dichoptic
            % Simultaneous           
                plotThis_SEM(9,:) 	= IDX(uct).rSEM(3,:);    
            % Adapted            
                plotThis_SEM(10,:)	= IDX(uct).rSEM_adapt(3,:);
                 
SEMline = nan(10,350,2);
for a = 1:10
    SEMline(a,:,1) = plotThis(a,:) + plotThis_SEM(a,1:350);
    SEMline(a,:,2) = plotThis(a,:) - plotThis_SEM(a,1:350);
end
                
%    maxVal = max(plotThis,[],'all','omitnan');
%    if isnan(maxVal) 
%         disp('maxVal is NaN for uct')
%         disp(uct)
%         maxVal = 150;
%    end

maxVal = 300;
errTMpts =  50:50:350;  
 figure
       for i = 1:10
            s(i) = subplot(2,5,i);
            plot(TM,plotThis(i,:),'-b','LineWidth',2); hold on
            plot(TM,SEMline(i,:,1),':m','LineWidth',1); hold on
            plot(TM,SEMline(i,:,2),':m','LineWidth',1);
            ylim([0 maxVal])
            vline(0)
            title(s(i),titleVec(i),'Interpreter','none')
       end
       ylabel(s(1),'half contrast')
       ylabel(s(6),{'max contrast','Imp/sec'})
       xlabel(s(6),'sec')
       sgtitle(unitInfo,'Interpreter','none')
       set(gcf, 'Position',[680 511 776 587])
       
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