function gramm_2x2_line(IDX)
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
for condLabel = [5 7 10 18]
   for uct = 1:uctLength
       count = count + 1;       
       % Categoricals - IVs
       if condLabel == 5
           DataForVis.condLabel{count} = 'Binocular';
       elseif condLabel == 7
           DataForVis.condLabel{count} = 'Dichoptic';
       elseif condLabel == 10
           DataForVis.condLabel{count} = 'Binoc Adapted';
       elseif condLabel == 18
           DataForVis.condLabel{count} = 'Dichop Adapted';
       end

       % DV - SDF
       if isempty(IDX.allV1(uct).SDF_avg{condLabel}) || any(isnan(IDX.allV1(uct).SDF_avg{condLabel}(1:560)'))
%            DataForVis.SDF{count,1} = nan(1,size(TM,2));
           count = count - 1; %dont count it - rewrite over variable
       else
           DataForVis.SDF{count,1} = IDX.allV1(uct).SDF_avg{condLabel}(1:560)';
       end
       
   end
end



%% Gramm plots for vis repeated trajectories
clear g
% g(1,1)=gramm('x',x,'y',y,'color',c);

g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel);
g.axe_property('XLim',[-.050 .3]);
g.axe_property('YLim',[-.5 6]);
g.geom_vline('xintercept',0)

g(1,1).stat_summary();
g(1,1).set_title('stat_summary()');
g(1,1).set_color_options('map','brewer2');
g(1,1).set_order_options('color',0);
g(1,1).geom_polygon('x',{[.05 .149 .149 .05] ; [.151 .25 .25 .151]} ,'y',{[0 0 5 5];  [0 0 5 5]},'color',[.5 .5 .5]);


g.set_names('x','Time (sec)','y','Z-Scored change from baseline','color','Visual Stimulus');g.set_title('Simult vs Adapted');
figure('Position',[166.6000 157.8000 644.4000 549.6000]);
g.draw();

set([g.results.stat_summary.line_handle],'LineWidth',3);





end

