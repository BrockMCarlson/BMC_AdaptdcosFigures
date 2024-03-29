function gramm_2x2_subline(IDX)
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
for condLabel = [1 2]
   for uct = 1:uctLength
       count = count + 1;   

       % DV - SDF
       if condLabel == 1
           if isempty(IDX.allV1(uct).SDF_avg{5}) || ...
                   any(isnan(IDX.allV1(uct).SDF_avg{5}(1:560))) ||...
                   isempty(IDX.allV1(uct).SDF_avg{7})||...
                   any(isnan(IDX.allV1(uct).SDF_avg{7}(1:560)))
               count = count - 1;
               continue
           else
               congSDF = IDX.allV1(uct).SDF_avg{5}(1:560)';
               inCoSDF = IDX.allV1(uct).SDF_avg{7}(1:560)';
               subSDF = inCoSDF - congSDF;
               DataForVis.SDF{count,1} = subSDF;
           end
       elseif condLabel == 2
           if isempty(IDX.allV1(uct).SDF_avg{10}) || ...
                   any(isnan(IDX.allV1(uct).SDF_avg{10}(1:560))) ||...
                   isempty(IDX.allV1(uct).SDF_avg{18})||...
                   any(isnan(IDX.allV1(uct).SDF_avg{18}(1:560)))
               count = count - 1;
               continue
           else
               congSDF = IDX.allV1(uct).SDF_avg{10}(1:560)';
               inCoSDF = IDX.allV1(uct).SDF_avg{18}(1:560)';
               subSDF = inCoSDF - congSDF;
               DataForVis.SDF{count,1} = subSDF;
           end
       end
 
       
       % Categoricals - IVs
       if condLabel == 1
           DataForVis.condLabel{count} = 'Simultaneous';
       elseif condLabel == 2
           DataForVis.condLabel{count} = 'Adapted';
       end

      
   end
end



%% Gramm plots for vis repeated trajectories
clear g
% g(1,1)=gramm('x',x,'y',y,'color',c);

g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel);
g.axe_property('XLim',[-.050 .35]);
g.axe_property('YLim',[-1 2]);
g.geom_vline('xintercept',0)

g(1,1).stat_summary();
g(1,1).set_title('stat_summary()');
g(1,1).set_color_options('map','brewer2');
g(1,1).set_order_options('color',0);
g(1,1).geom_polygon('x',{[.05 .145 .145 .05] ; [.155 .25 .25 .155]} ,'y',{[-30 -30 40 40];  [-30 -30 40 40]},'color',[.5 .5 .5]);
g.geom_hline('yintercept',0)


g.set_names('x','Time (sec)','y','Z-Scored change from baseline','color','Visual Stimulus');g.set_title('Simult vs Adapted');
figure('Position',[166.6000 157.8000 644.4000 549.6000]);
g.draw();

set([g.results.stat_summary.line_handle],'LineWidth',3);





end

