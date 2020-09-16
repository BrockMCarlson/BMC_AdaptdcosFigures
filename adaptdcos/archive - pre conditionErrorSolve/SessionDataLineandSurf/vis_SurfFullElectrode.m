% visIDX_surfacePlot

clear
close all

sessionNum = '160427'; % change every session
BMCprefori = 30; % Change this each session
BMCnullori = 120; % Change this each session
BMCprefeye = 2;
BMCnulleye = 3;






flag_blCorrect = 0;
flag_savefigs = 1;

IDXdir = 'G:\LaCie\Adaptdcos figs\adaptdcosSessionData\SessionMatFiles';
cd(IDXdir)
load(strcat('IDXadaptdcos_session',sessionNum,'_IDX.mat'))
figDir = 'G:\LaCie\Adaptdcos figs\adaptdcosSessionData';
figName = strcat('IDXadaptdcos_session',sessionNum,'_surface.png'); 





%% get out unit info


clear plotThis       

for uct = 1:length(IDX)
    if IDX(uct).kls == 1
        continue
    end
    
%%%%% -- SDF   
% Half Contrast in DE
    % Monoc
        MUA(uct,:,1)       = IDX(uct).SDF(4,:);  %%% -- (channel x time x condition)
    % Binocular
        % Simultaneous
            MUA(uct,:,2)	= IDX(uct).SDF(5,:);    
        % Adapted
            MUA(uct,:,3)	= IDX(uct).SDF_adapt(5,:);

    % Dichoptic
        % Simultaneous
            MUA(uct,:,4) 	= IDX(uct).SDF(6,:);    
        % Adapted
            MUA(uct,:,5)	= IDX(uct).SDF_adapt(6,:);

% Max Contrast in DE
    % Monoc
        MUA(uct,:,6)       = IDX(uct).SDF(1,:);
    % Binocular
        % Simultaneous
            MUA(uct,:,7)	= IDX(uct).SDF(2,:);    
        % Adapted           
            MUA(uct,:,8)	= IDX(uct).SDF_adapt(2,:);
    % Dichoptic
        % Simultaneous           
            MUA(uct,:,9) 	= IDX(uct).SDF(3,:);    
        % Adapted            
            MUA(uct,:,10)	= IDX(uct).SDF_adapt(3,:);
            

    
            
   unitInfo(uct,:) = {...
       strcat(IDX(uct).header,'-','Depth=',num2str(IDX(uct).depth(2)),'-','Kls=',num2str(IDX(uct).kls))...
       strcat('diana=',num2str(IDX(uct).diana),'-','prefeye=',num2str(IDX(uct).prefeye),'-','prefori=',num2str(IDX(uct).prefori))...
       strcat('occ p value, subselected AND Balanced=',num2str(IDX(uct).occ(1)))};
   
    UnitPref(uct) = IDX(uct).prefori;
    if UnitPref(uct) == BMCprefori 
        UnitKey{uct} = 'match';
    elseif UnitPref(uct) == BMCnullori
        UnitKey{uct} = 'anti';
    elseif isnan(UnitPref(uct))
        UnitKey{uct} = 'NS';
    else
        error('no match, double check manual PrefOri and NullOri')
    end
    corticaldepth(uct) = IDX(uct).depth(2);
end



%% get parameters to plot the figure
TM = IDX(1).tm;

titleVec = {strcat('Monoc','-n=',num2str(IDX(1).trlNum(4))),...
    strcat('Binoc_Simult','-n=',num2str(IDX(1).trlNum(5))),...
    strcat('Binoc_Adapt','-n=',num2str(IDX(1).trlNum_adapt(5))),...
    strcat('Di_Simult','-n=',num2str(IDX(1).trlNum(6))),...
    strcat('Di_Adapt','-n=',num2str(IDX(1).trlNum_adapt(6))),...
    strcat('Monoc','-n=',num2str(IDX(1).trlNum(1))),...
    strcat('Binoc_Simult','-n=',num2str(IDX(1).trlNum(2))),...
    strcat('Binoc_Adapt','-n=',num2str(IDX(1).trlNum_adapt(2))),...
    strcat('Di_Simult','-n=',num2str(IDX(1).trlNum(3))),...
    strcat('Di_Adapt','-n=',num2str(IDX(1).trlNum_adapt(3)))}';

%% Baseline correct
if flag_blCorrect %%%% fix this, this is wrong. subtract the monoc stim pertinent
    for b = 1:10
        if (b == 3) || (b == 5) || (b == 8) || (b == 10)
            blMUA(:,:,b) = bsxfun(@minus,MUA(:,:,b),mean(MUA(:,TM<0,b-1),2)); %adapt - simultbl
        else
            blMUA(:,:,b) = bsxfun(@minus,MUA(:,:,b),mean(MUA(:,TM<0,b),2)); %simult - simultbl
        end
    end
    MUA = blMUA;
end



%% loop through plotting the 10 surface plots
clear I y x sz
I(1,:) = strcmp(UnitKey,'anti');
if sum(I(1,:)) > 0
    y(1,:) = corticaldepth(I(1,:));
    x(1,:) = repelem(-0.03,length(y(1,:)));
end

I(2,:) = strcmp(UnitKey,'NS');
if sum(I(2,:)) > 0
    y(2,:) = corticaldepth(I(2,:));
    x(2,:) = repelem(-0.01,length(y(2,:)));
end
sz = 40;
    
figure
set(gcf, 'Position', [1 41 1920 1083]);
for j = 1:10
  

  filt_MUA(:,:,j) = filterCSD(MUA(:,:,j));

  f(j) = subplot(2,5,j);cla

    % plot surface plots
    imagesc(TM,corticaldepth,filt_MUA(:,:,j));
    colorbar('eastoutside')
    title(titleVec{j},'Interpreter','none')
    colormap(jet);
    hold on;
    
    %  plot ori tuned scatter plot
    if sum(I(1,:)) > 0
        sct1 = scatter(x(1,:),y(1,:),sz,'MarkerEdgeColor',[1 1 1],...
              'MarkerFaceColor',[1 1 1],...
              'LineWidth',1.5); 
        hold on;
    end
    if sum(I(2,:)) > 0
        sct2 = scatter(x(2,:),y(2,:),sz,'MarkerEdgeColor',[0 0.8 0.3],...
              'MarkerFaceColor',[0 0.8 0.3],...
              'LineWidth',1.5);        
        hold on;
    end
    plot([0 0],ylim,'k');
    set(gca,'ydir','normal','tickdir','out')
          
    
end
    cmax = max(max(abs(cell2mat(get(f,'clim')))));
    set(f,'Clim',[0 1].*cmax)

    
if flag_savefigs
    cd(figDir)
    if isfile(figName)
        error('figure already exists')        
    end
    
    export_fig(figName,'-png','-nocrop')
    
end 
