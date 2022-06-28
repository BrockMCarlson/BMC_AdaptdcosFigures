function gramm_dCOS(IDX)
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
for condLabel = [1 5 7 8]
   for uct = 1:uctLength
       count = count + 1;       
       % Categoricals - IVs
       if condLabel == 1
           DataForVis.condLabel{count} = 'Monocular';
       elseif condLabel == 5
           DataForVis.condLabel{count} = 'Binocular';
       elseif condLabel == 7
           DataForVis.condLabel{count} = 'Dichoptic';
       elseif condLabel == 8
           DataForVis.condLabel{count} = 'Dichoptic';       
       end

       % DV - SDF
       if isempty(IDX.allV1(uct).SDF_avg{condLabel}) || any(isnan(IDX.allV1(uct).SDF_avg{condLabel}(1:560)'))
%            DataForVis.SDF{count,1} = nan(1,size(TM,2));
           count = count - 1; %dont count it - rewrite over variable
       else
           DataForVis.SDF{count,1} = IDX.allV1(uct).SDF_avg{condLabel}(1:560)';
       end
       
       % DV - RESP
       DataForVis.RESPtrans{count,1} = IDX.allV1(uct).RESP_avg{condLabel}(1);
       DataForVis.RESPsusta{count,1} = IDX.allV1(uct).RESP_avg{condLabel}(2);
       
   end
end



%% Gramm plots for vis repeated trajectories
close all
clear g
% g(1,1)=gramm('x',x,'y',y,'color',c);

g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel);
g.axe_property('XLim',[-.050 .350]);
g.axe_property('YLim',[0 200]);
g.geom_vline('xintercept',0)

g(1,1).stat_summary();
g(1,1).set_title('stat_summary()');
g(1,1).set_color_options('map','brewer2');
g(1,1).set_order_options('x',0);


g.set_title('Dichoptic Suppression');
figure('Position',[100 100 800 550]);
g.draw();

set([g.results.stat_summary.line_handle],'LineWidth',3);





end

