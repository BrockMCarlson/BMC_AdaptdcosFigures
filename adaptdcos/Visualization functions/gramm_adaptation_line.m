function gramm_adaptation_line(IDX)
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
for condLabel = [5 10]
   for uct = 1:uctLength
       count = count + 1;       
       
       
       % DV - SDF
       if isempty(IDX.allV1(uct).SDF_avg{condLabel}) || any(isnan(IDX.allV1(uct).SDF_avg{condLabel}(1:560)'))
%            DataForVis.SDF{count,1} = nan(1,size(TM,2));
           count = count - 1; %dont count it - rewrite over variable
           continue
       else
           DataForVis.SDF{count,1} = IDX.allV1(uct).SDF_avg{condLabel}(1:560)';
       end
       
       
       % Categoricals - IVs
       if condLabel == 5
           DataForVis.condLabel{count} = 'Dioptic Simultaneous';
       elseif condLabel == 10
           DataForVis.condLabel{count} = 'Dioptic Adapted';
% %        elseif condLabel == 8
% %            DataForVis.condLabel{count} = 'Dichoptic Simultaneous';  
% %        elseif condLabel == 18
% %            DataForVis.condLabel{count} = 'Dichoptic Adapted';  
       end


       
   end
end



%% Gramm plots for vis repeated trajectories
clear g

g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel);
g.axe_property('XLim',[-.050 .30]);
g.axe_property('YLim',[-.5 6]);
g.geom_vline('xintercept',0)

g(1,1).stat_summary();
g(1,1).set_title('stat_summary()');
g(1,1).set_color_options('map','brewer2');
g(1,1).set_order_options('x',0,'color',0);
g(1,1).geom_polygon('x',{[.05 .149 .149 .05] ; [.151 .25 .25 .151]} ,'y',{[0 0 5 5];  [0 0 5 5]},'color',[.5 .5 .5]);


g.set_names('x','Time (sec)','y','Z-Scored change from baseline','color','Visual Stimulus');
g.set_title('Effect of Adaptation');
% figure('Position',[100 100 800 550]);
figure('Position',[166.6000 157.8000 644.4000 549.6000]);

g.draw();

set([g.results.stat_summary.line_handle],'LineWidth',3);





end

