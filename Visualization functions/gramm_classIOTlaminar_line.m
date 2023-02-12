function gramm_classIOTlaminar_line(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM;

clear DataForVis uctLength
count = 0;
uctLength = length(IDX.allV1);
for condLabel = [1 10]
   for uct = 1:uctLength
       count = count + 1;       
       % Categoricals - IVs
        DataForVis.condLabel{count,1} = conditNameForCC{condLabel};

       if IDX.allV1(uct).depth(2) > 5
           DataForVis.depth{count} = 'Supra';
       elseif IDX.allV1(uct).depth(2) >= 0 && IDX.allV1(uct).depth(2) <= 5
           DataForVis.depth{count} = 'Granular';
       elseif IDX.allV1(uct).depth(2) < 0
           DataForVis.depth{count} = 'Infra';
       end
       
       
       % DV - SDF
       if isempty(IDX.allV1(uct).SDF_avg{condLabel}) 
%            DataForVis.SDF{count,1} = nan(1,size(TM,2));
           count = count - 1; %dont count it - rewrite over variable
       else
           DataForVis.SDF{count,1} = IDX.allV1(uct).SDF_avg{condLabel};
       end
       
   end
end


%% Gramm plots for vis repeated trajectories
clear g
% g(1,1)=gramm('x',x,'y',y,'color',c);

g(1,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',strcmp(DataForVis.depth,'Supra'));
g(1,1).set_title('Supragranular');
g(2,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',strcmp(DataForVis.depth,'Granular'));
g(2,1).set_title('Granular');
g(3,1)=gramm('x',TM,'y',DataForVis.SDF,'color',DataForVis.condLabel,'subset',strcmp(DataForVis.depth,'Infra'));
g(3,1).set_title('Infragranular');




for i = 1:3
    g(i,1).stat_summary();
    g(i,1).set_color_options('map','brewer2');
    g(i,1).set_order_options('color',0);
    g(i,1).geom_polygon('x',{[.05 .1 .1 .05] ; [.15 .25 .25 .15]} ,'y',{[40 40 190 190];  [40 40 190 190]},'color',[.5 .5 .5]);
    g(i,1).axe_property('XLim',[-.050 .3]);
%     g(i,1).axe_property('YLim',[0 200]);
    g(i,1).geom_vline('xintercept',0)
end

g.set_names('x','Time (sec)','y','Impulses/sec','color','Visual Stimulus');
g.set_title('Simult vs Adapted');
figure('Position',[292 76 429 734]);
g.draw();

set([g(1,1).results.stat_summary.line_handle],'LineWidth',3);
set([g(2,1).results.stat_summary.line_handle],'LineWidth',3);
set([g(3,1).results.stat_summary.line_handle],'LineWidth',3);






end

