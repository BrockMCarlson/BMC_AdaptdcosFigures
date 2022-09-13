function gramm_dCOS_RESP(IDX)
%% Goal
% use gramm and plot the simultaneous congruent, incongruent, and monoc
% preferred.

% line plots using "methods for visualizing repeated trajectories"


%% Grab Monoc and Diop/Dichop, but only if conditions are balanced per unit
conditNameForCC = IDX.allV1(1).condition.Properties.RowNames;
uctLength = length(IDX.allV1);

% Monoc vs dioptic
monocCond = 1;
diopCond = 5;
count_missData_Diop = 0;
count_MvsDiop = 0;
for tmBlock = 1:2
    for uct = 1:uctLength %for each unit
        % Check that both Monocular and dichoptic conditions are present
        if isempty(IDX.allV1(uct).RESP_avg{monocCond}(tmBlock)) || isempty(IDX.allV1(uct).RESP_avg{diopCond}(tmBlock))...
               || isnan(IDX.allV1(uct).RESP_avg{monocCond}(tmBlock)) || isnan(IDX.allV1(uct).RESP_avg{diopCond}(tmBlock)) % if either condition is missing, do not include unit in the plot.
            count_missData_Diop = count_missData_Diop + 1;
            missingData_Diop{count_missData_Diop,1} = strcat(IDX.allV1(uct).penetration,'_depth=',string(IDX.allV1(uct).depth(2)));
        else
            % If neither condition is missing, we collect the Monocular and
            % then the dichoptic data for the unit
            count_MvsDiop = count_MvsDiop + 1;
                MvsDiop.RESP(count_MvsDiop,1) = IDX.allV1(uct).RESP_avg{monocCond}(tmBlock);
                MvsDiop.condLabel{count_MvsDiop,1} = conditNameForCC{monocCond};
                if tmBlock == 1
                    MvsDiop.tmBlock{count_MvsDiop,1} = 'Transient';
                elseif tmBlock == 2
                    MvsDiop.tmBlock{count_MvsDiop,1} = 'Sustained';
                end
            count_MvsDiop = count_MvsDiop + 1; % now we grab the dioptic
                MvsDiop.RESP(count_MvsDiop,1) = IDX.allV1(uct).RESP_avg{diopCond}(tmBlock);
                MvsDiop.condLabel{count_MvsDiop,1} = conditNameForCC{diopCond};
                if tmBlock == 1
                    MvsDiop.tmBlock{count_MvsDiop,1} = 'Transient';
                elseif tmBlock == 2
                    MvsDiop.tmBlock{count_MvsDiop,1} = 'Sustained';
                end
        end
    end
end

% Monoc vs dichoptic
monocCond = 1;
dichopCond = 7;
count_missData_Dichop = 0;
count_MvsDichop = 0;
for tmBlock = 1:2
    for uct = 1:uctLength %for each unit
        % Check that both Monocular and dichoptic conditions are present
        if isempty(IDX.allV1(uct).RESP_avg{monocCond}(tmBlock)) || isempty(IDX.allV1(uct).RESP_avg{dichopCond}(tmBlock))...
                || isnan(IDX.allV1(uct).RESP_avg{monocCond}(tmBlock)) || isnan(IDX.allV1(uct).RESP_avg{dichopCond}(tmBlock)) % if either condition is missing, do not include unit in the plot.
            count_missData_Dichop = count_missData_Dichop + 1;
            missingData_Dichop{count_missData_Dichop,1} = strcat(IDX.allV1(uct).penetration,'_depth=',string(IDX.allV1(uct).depth(2)));
        else
            % If neither condition is missing, we collect the Monocular and
            % then the dichoptic data for the unit
            count_MvsDichop = count_MvsDichop + 1;
                MvsDichop.RESP(count_MvsDichop,1) = IDX.allV1(uct).RESP_avg{monocCond}(tmBlock);
                MvsDichop.condLabel{count_MvsDichop,1} = conditNameForCC{monocCond};
                if tmBlock == 1
                    MvsDichop.tmBlock{count_MvsDichop,1} = 'Transient';
                elseif tmBlock == 2
                    MvsDichop.tmBlock{count_MvsDichop,1} = 'Sustained';
                end
            count_MvsDichop = count_MvsDichop + 1; % now we grab the dichoptic
                MvsDichop.RESP(count_MvsDichop,1) = IDX.allV1(uct).RESP_avg{dichopCond}(tmBlock);
                MvsDichop.condLabel{count_MvsDichop,1} = conditNameForCC{dichopCond};
                if tmBlock == 1
                    MvsDichop.tmBlock{count_MvsDichop,1} = 'Transient';
                elseif tmBlock == 2
                    MvsDichop.tmBlock{count_MvsDichop,1} = 'Sustained';
                end
        end
    end
end


%% Gramm plots dioptic comparison to moncular

clear g

x_resp = MvsDiop.tmBlock;
y_resp = MvsDiop.RESP;% Y values must be in format "double"
c_resp = MvsDiop.condLabel;


% Violin plot with stat_summary
g(1,1)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(x_resp,'Transient'));
g(1,1).set_order_options('x',0,'color',0)
g(1,1).set_names('x','Stimulus Presented','y','Z-Scored change from baseline','color','Stimulus Presented');
% g(1,1).stat_violin('normalization','width','dodge',0,'fill','transparent');
% g(1,1).stat_boxplot('width',0.5,'dodge',0,'notch',true);
g(1,1).stat_summary('geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
g(1,1).set_title('Transient time period (50-100ms)');
g(1,1).set_color_options('map','brewer_dark');



g(1,2)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(x_resp,'Sustained'));
g(1,2).set_order_options('x',0,'color',0)
g(1,2).set_names('x','Stimulus Presented','y','Z-Scored change from baseline','color','Stimulus Presented');
% g(1,2).stat_violin('normalization','width','dodge',0,'fill','transparent');
% g(1,2).stat_boxplot('width',0.5,'dodge',0,'notch',true);
g(1,2).stat_summary('type','sem','geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
g(1,2).set_title('Sustained time period (150-250ms)');
g(1,2).set_color_options('map','brewer_dark');

figure('Position',[2.1738e+03 28.2000 1172 520]);
g.axe_property('YLim',[0 6]);
g.draw();


%% Gramm plots Dichoptic comparison to moncular

clear h

x_resp = MvsDichop.tmBlock;
y_resp = MvsDichop.RESP;% Y values must be in format "double"
c_resp = MvsDichop.condLabel;


% Violin plot with stat_summary
h(1,1)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(x_resp,'Transient'));
h(1,1).set_order_options('x',0,'color',0)
h(1,1).set_names('x','Stimulus Presented','y','Z-Scored change from baseline','color','Stimulus Presented');
% h(1,1).stat_violin('normalization','width','dodge',0,'fill','transparent');
% h(1,1).stat_boxplot('width',0.5,'dodge',0,'notch',true);
h(1,1).stat_summary('type','sem','geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
h(1,1).set_title('Transient time period (50-100ms)');
h(1,1).set_color_options('map','brewer_dark');



h(1,2)=gramm('x',c_resp,'y',y_resp,'color',c_resp,'subset',strcmp(x_resp,'Sustained'));
h(1,2).set_order_options('x',0,'color',0)
h(1,2).set_names('x','Stimulus Presented','y','Z-Scored change from baseline','color','Stimulus Presented');
% h(1,2).stat_violin('normalization','width','dodge',0,'fill','transparent');
% h(1,2).stat_boxplot('width',0.5,'dodge',0,'notch',true);
h(1,2).stat_summary('geom',{'point' 'errorbar'},'dodge',0.3,'width',0.5);
h(1,2).set_title('Sustained time period (150-250ms)');
h(1,2).set_color_options('map','brewer_dark');

figure('Position',[2.1738e+03 28.2000 1172 520]);
h.axe_property('YLim',[0 6]);
h.draw();






end

