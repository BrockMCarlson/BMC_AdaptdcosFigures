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
            x1(count_MvsDiop,:) = IDX.allV1(uct).SDF_avg{monocCond}';
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

%% Evaluate moving window binned stats for dioptic
% Monoc vs dioptic
monocCond = 1;
diopCond = 5;
count_missData_Diop = 0;
count_monoc = 0;
count_diop = 0;
clear x1 y1
for uct = 1:uctLength %for each unit
    % Check that both Monocular and dichoptic conditions are present
    if ~isempty(IDX.allV1(uct).SDF_avg{monocCond}) && ~isempty(IDX.allV1(uct).SDF_avg{diopCond}) % if either condition is missing, do not include unit in the plot.
        % If neither condition is missing, we collect the Monocular and
        % then the dichoptic data for the unit
        count_monoc = count_monoc + 1;
            x1(count_monoc,:) = IDX.allV1(uct).SDF_avg{monocCond}';
        count_diop = count_diop + 1; % now we grab the dioptic
            y1(count_diop,:) = IDX.allV1(uct).SDF_avg{diopCond}';
    end
end

% create 59 x 17 vector that is the moving binned average
binStartTimeVector = 1:25:350;
for contMat = 1:size(x1,1) %"continuous Matrix"
    for bins = 1:length(binStartTimeVector)
        binWindow = binStartTimeVector:binStartTimeVector+25;
        x1ForStats(contMat,bins) = nanmean(x1(contMat,binWindow));
        y1ForStats(contMat,bins) = nanmean(y1(contMat,binWindow));
    end
end

clear bins
for bins = 1:size(x1ForStats,2)
    [p_diop(bins),h_diop(bins)] = signrank(x1ForStats(:,bins),y1ForStats(:,bins));
end

% Monoc vs dichoptic
monocCond = 1;
dichopCond = 7;
count_missData_Diop = 0;
count_monoc = 0;
count_dichop = 0;
clear x1 y1
for uct = 1:uctLength %for each unit
    % Check that both Monocular and dichoptic conditions are present
    if ~isempty(IDX.allV1(uct).SDF_avg{monocCond}) && ~isempty(IDX.allV1(uct).SDF_avg{dichopCond}) % if either condition is missing, do not include unit in the plot.
        % If neither condition is missing, we collect the Monocular and
        % then the dichoptic data for the unit
        count_monoc = count_monoc + 1;
            x1(count_monoc,:) = IDX.allV1(uct).SDF_avg{monocCond}';
        count_dichop = count_dichop + 1; % now we grab the dioptic
            y1(count_dichop,:) = IDX.allV1(uct).SDF_avg{dichopCond}';
    end
end

% create 59 x 17 vector that is the moving binned average
binStartTimeVector = 1:25:350;
for contMat = 1:size(x1,1) %"continuous Matrix"
    for bins = 1:length(binStartTimeVector)
        binWindow = binStartTimeVector:binStartTimeVector+25;
        x1ForStats(contMat,bins) = nanmean(x1(contMat,binWindow));
        y1ForStats(contMat,bins) = nanmean(y1(contMat,binWindow));
    end
end

clear bins
for bins = 1:size(x1ForStats,2)
    [p_dichop(bins),h_dichop(bins)] = signrank(x1ForStats(:,bins),y1ForStats(:,bins));
end

%% Gramm plots for vis repeated trajectories

clear g

g(1,1)=gramm('x',TM,'y',MvsDiop.SDF,'color',MvsDiop.condLabel);
g(1,2)=gramm('x',TM,'y',MvsDichop.SDF,'color',MvsDichop.condLabel);
g.axe_property('XLim',[-.050 .35]);
g.axe_property('YLim',[-.5 5]);
g.geom_vline('xintercept',0)

g(1,1).stat_summary();
g(1,1).set_title('Monoc vs dioptic');
g(1,1).set_color_options('map','brewer2');
g(1,1).set_order_options('x',0,'color',0);
g(1,1).geom_polygon('x',{[.05 .145 .145 .05] ; [.155 .25 .25 .155]} ,'y',{[50 50 160 160];  [50 50 160 160]},'color',[.5 .5 .5]);

g(1,2).stat_summary();
g(1,2).set_title('Monoc vs dichoptic');
g(1,2).set_color_options('map','brewer2');
g(1,2).set_order_options('x',0,'color',0);
g(1,2).geom_polygon('x',{[.05 .145 .145 .05] ; [.155 .25 .25 .155]} ,'y',{[50 50 160 160];  [50 50 160 160]},'color',[.5 .5 .5]);


g.set_names('x','Time (sec)','y','% Change from baseline','color','Visual Stimulus');
g.set_title('% change from baseline');
% figure('Position',[100 100 800 550]);
figure('Position',[166.6,157.8,1299.4,549.6]);

g.draw();

set([g(1,1).results.stat_summary.line_handle],'LineWidth',3);
set([g(1,2).results.stat_summary.line_handle],'LineWidth',3);




end

