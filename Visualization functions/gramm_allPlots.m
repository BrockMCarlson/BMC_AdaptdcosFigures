function gramm_allPlots(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM;

uctLength = length(IDX.allV1);

clear DataForVis
count = 0;
for condLabel = 1:length(conditNameForCC)
   for uct = 1:uctLength
       count = count + 1;       
       % Categoricals - IVs
       DataForVis.condLabel{count,1} = conditNameForCC{condLabel};
       
       % DV - SDF
       if isempty(IDX.allV1(uct).SDF_avg{condLabel}) 
           count = count - 1; %dont count it - rewrite over variable
       else
           DataForVis.SDF{count,1} = IDX.allV1(uct).SDF_avg{condLabel}';
       end
       
   end
end



%% Gramm plots for vis repeated trajectories
clear g

g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel );
g.geom_vline('xintercept',0)

g(1,1).stat_summary();
g(1,1).set_title('stat_summary()');
% g(1,1).set_color_options('map','brewer2');
g(1,1).set_order_options('x',0,'color',0);
g(1,1).geom_polygon('x',{[.05 .149 .149 .05] ; [.151 .25 .25 .151]} ,'y',{[0 0 5 5];  [0 0 5 5]},'color',[.5 .5 .5]);
g(1,1).facet_grid(DataForVis.condLabel,DataForVis.condLabel);



g.set_names('x','Time (sec)','y','Z-Scored change from baseline','color','Visual Stimulus');
g.set_title('Dichoptic Suppression');
% figure('Position',[100 100 800 550]);
figure('Position',[166.6,157.8,1299.4,549.6]);

g.draw();



end




% % % 
% % % %% Gramm plots for vis repeated trajectories
% % % clear g
% % % 
% % % g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',...
% % %     (strcmp(DataForVis.condLabel,'Monocualr PS DE') | strcmp(DataForVis.condLabel,'Cong PS Simult')) );
% % % g(1,2)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',...
% % %     (strcmp(DataForVis.condLabel,'Monocualr PS DE') | strcmp(DataForVis.condLabel,'IC PS DE - NS NDE Simult')  ) );
% % % g.axe_property('XLim',[-.050 .30]);
% % % g.axe_property('YLim',[-.5 6]);
% % % g.geom_vline('xintercept',0)
% % % 
% % % g(1,1).stat_summary();
% % % g(1,1).set_title('stat_summary()');
% % % g(1,1).set_color_options('map','brewer2');
% % % g(1,1).set_order_options('x',0,'color',0);
% % % g(1,1).geom_polygon('x',{[.05 .149 .149 .05] ; [.151 .25 .25 .151]} ,'y',{[0 0 5 5];  [0 0 5 5]},'color',[.5 .5 .5]);
% % % 
% % % g(1,2).stat_summary();
% % % g(1,2).set_title('stat_summary()');
% % % g(1,2).set_color_options('map','brewer2');
% % % g(1,2).set_order_options('x',0,'color',0);
% % % g(1,2).geom_polygon('x',{[.05 .149 .149 .05] ; [.151 .25 .25 .151]} ,'y',{[0 0 5 5];  [0 0 5 5]},'color',[.5 .5 .5]);
% % % 
% % % 
% % % g.set_names('x','Time (sec)','y','Z-Scored change from baseline','color','Visual Stimulus');
% % % g.set_title('Dichoptic Suppression');
% % % % figure('Position',[100 100 800 550]);
% % % figure('Position',[166.6,157.8,1299.4,549.6]);
% % % 
% % % g.draw();
% % % 
% % % % % set([g(1,1).results.stat_summary.line_handle],'LineWidth',3);
% % % % % set([g(1,1).results.stat_summary(1).line_handle],'Color',[0 0 0]);
% % % % % set([g(1,1).results.stat_summary(1).line_handle],'Color',[ 0.310, 0.120, 0.179]);
% % % % % set([g(1,1).legend_axe_handle],'ColorOrder',[0, 0, 0,; 0.310, 0.120, 0.179]);
% % % 
% % % % set([g(1,2).results.stat_summary.line_handle],'LineWidth',3);
