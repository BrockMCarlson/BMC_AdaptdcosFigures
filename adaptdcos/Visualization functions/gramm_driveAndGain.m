function gramm_driveAndGain(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM(1:560);

clear DataForVis
count = 0;
uctLength = length(IDX.allV1);
for tmBlock = 1:2
    for condLabel = [1 4 3 2 10 16 14 12 18 24 22 20]
       for uct = 1:uctLength
           count = count + 1;       
           % Categoricals - IVs
           if tmBlock == 1
               DataForVis.tmBlock{count,1} = 'Transient';
           elseif tmBlock == 2
               DataForVis.tmBlock{count,1} = 'Sustained';
           end
           
           if IDX.allV1(uct).depth(2) > 5
               DataForVis.depth{count} = 'Supra';
           elseif IDX.allV1(uct).depth(2) >= 0 && IDX.allV1(uct).depth(2) <= 5
               DataForVis.depth{count} = 'Granular';
           elseif IDX.allV1(uct).depth(2) < 0
               DataForVis.depth{count} = 'Infra';
           end
       
           DataForVis.condLabel{count,1} = conditNameForCC{condLabel};
           
           if ismember(condLabel,[1 2 3 4])
               DataForVis.catX{count} = 'Monocular';
           elseif ismember(condLabel,[10 12 14 16])
               DataForVis.catX{count} = 'Congruent Adapted';
           elseif ismember(condLabel,[18 20 22 24])
               DataForVis.catX{count} = 'Incongruent Adapted';
           end  
           
           if ismember(condLabel,[1 10 18])
               DataForVis.catColor{count} = 'PS DE';
           elseif ismember(condLabel,[3 14 22])
               DataForVis.catColor{count} = 'NS DE';
           elseif ismember(condLabel,[4 16 24])
               DataForVis.catColor{count} = 'PS NDE';
           elseif ismember(condLabel,[2 12 20])
               DataForVis.catColor{count} = 'NS NDE';
           end  
           
               
          % DV - RESP
           DataForVis.RESP(count,1) = IDX.allV1(uct).RESP_avg{condLabel}(tmBlock);
           
           if isnan(DataForVis.RESP(count,1))
               count = count - 1;  %write over NaNs
           end

       end
    end
end



%% Gramm plots for vis repeated trajectories


clear g

x_resp = DataForVis.catX;
y_resp = DataForVis.RESP;% Y values must be in format "double"
c_resp = DataForVis.catColor;


% Violin plot with stat_summary
g(1,1)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(DataForVis.tmBlock,'Transient'));
g(2,1)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(DataForVis.tmBlock,'Sustained'));
% % for i = 1:2
% %     g(i,1).stat_violin('normalization','width','dodge',0,'fill','transparent');
% %     g(i,1).facet_grid([],x_resp);
% %     g(i,1).stat_boxplot('width',0.5);
% % end

for i = 1:2
    g(i,1).stat_summary('geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
    g(i,1).facet_grid([],x_resp);
end

g.set_order_options('x',0,'color',0,'column',0)
g.set_names('x','Stimulus Presented','y','Impulses/sec','color','Stimulus Presented');
g.set_title('Transient time period (50-100ms)');
g.set_color_options('map','brewer_dark');



figure('Position',[107 71 1304 824]);
g.axe_property('YLim',[0 450]);
g.draw();







end

