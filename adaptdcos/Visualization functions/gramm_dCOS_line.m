function gramm_dCOS_line(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"

%% Initial variables
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
TM = IDX.allV1(1).TM;

%% Grab Monoc and Diop/Dichop, but only if conditions are balanced per unit
uctLength = length(IDX.allV1);

% Monoc vs dioptic
monocCond = 1;
diopCond = 5;
count_missData_Diop = 0;
count_MvsDiop = 0;
for uct = 1:uctLength %for each unit
    % Check that both Monocular and dichoptic conditions are present
    if isempty(IDX.allV1(uct).SDF_avg{monocCond}) || isempty(IDX.allV1(uct).SDF_avg{diopCond}) % if either condition is missing, do not include unit in the plot.
        count_missData_Diop = count_missData_Diop + 1;
        missingData_Diop{count_missData_Diop,1} = strcat(IDX.allV1(uct).penetration,'_depth=',string(IDX.allV1(uct).depth(2)));
    else
        % If neither condition is missing, we collect the Monocular and
        % then the dichoptic data for the unit
        count_MvsDiop = count_MvsDiop + 1;
            MvsDiop.SDF{count_MvsDiop,1} = IDX.allV1(uct).SDF_avg{monocCond}';
            MvsDiop.condLabel{count_MvsDiop,1} = conditNameForCC{monocCond};
        count_MvsDiop = count_MvsDiop + 1; % now we grab the dioptic
            MvsDiop.SDF{count_MvsDiop,1} = IDX.allV1(uct).SDF_avg{diopCond}';
            MvsDiop.condLabel{count_MvsDiop,1} = conditNameForCC{diopCond};
    end
end

% Monoc vs dichoptic
monocCond = 1;
dichopCond = 7;
count_missData_Dichop = 0;
count_MvsDichop = 0;
for uct = 1:uctLength %for each unit
    % Check that both Monocular and dichoptic conditions are present
    if isempty(IDX.allV1(uct).SDF_avg{monocCond}) || isempty(IDX.allV1(uct).SDF_avg{dichopCond}) % if either condition is missing, do not include unit in the plot.
        count_missData_Dichop = count_missData_Dichop + 1;
        missingData_Dichop{count_missData_Dichop,1} = strcat(IDX.allV1(uct).penetration,'_depth=',string(IDX.allV1(uct).depth(2)));
    else
        % If neither condition is missing, we collect the Monocular and
        % then the dichoptic data for the unit
        count_MvsDichop = count_MvsDichop + 1;
            MvsDichop.SDF{count_MvsDichop,1} = IDX.allV1(uct).SDF_avg{monocCond}';
            MvsDichop.condLabel{count_MvsDichop,1} = conditNameForCC{monocCond};
        count_MvsDichop = count_MvsDichop + 1; % now we grab the dichoptic
            MvsDichop.SDF{count_MvsDichop,1} = IDX.allV1(uct).SDF_avg{dichopCond}';
            MvsDichop.condLabel{count_MvsDichop,1} = conditNameForCC{dichopCond};
    end
end




%% Gramm plots for vis repeated trajectories

clear g

g(1,1)=gramm('x',TM,'y',MvsDiop.SDF,'color',MvsDiop.condLabel);
g(1,2)=gramm('x',TM,'y',MvsDichop.SDF,'color',MvsDichop.condLabel);
g.axe_property('XLim',[-.050 .25]);
g.axe_property('YLim',[-.5 6]);
g.geom_vline('xintercept',0)

g(1,1).stat_summary();
g(1,1).set_title('stat_summary()');
g(1,1).set_color_options('map','brewer2');
g(1,1).set_order_options('x',0,'color',0);
g(1,1).geom_polygon('x',{[.05 .149 .149 .05] ; [.151 .25 .25 .151]} ,'y',{[0 0 5 5];  [0 0 5 5]},'color',[.5 .5 .5]);

g(1,2).stat_summary();
g(1,2).set_title('stat_summary()');
g(1,2).set_color_options('map','brewer2');
g(1,2).set_order_options('x',0,'color',0);
g(1,2).geom_polygon('x',{[.05 .149 .149 .05] ; [.151 .25 .25 .151]} ,'y',{[0 0 5 5];  [0 0 5 5]},'color',[.5 .5 .5]);


g.set_names('x','Time (sec)','y','Z-Scored change from baseline','color','Visual Stimulus');
g.set_title('Classic Interocular Suppression');
% figure('Position',[100 100 800 550]);
figure('Position',[166.6,157.8,1299.4,549.6]);

g.draw();

set([g(1,1).results.stat_summary.line_handle],'LineWidth',3);
set([g(1,2).results.stat_summary.line_handle],'LineWidth',3);




end

